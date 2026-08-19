package com.appsimple.billrecognition

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Color
import android.net.Uri
import android.os.Bundle
import android.view.Gravity
import android.view.ViewGroup
import android.widget.Button
import android.widget.FrameLayout
import android.widget.TextView
import androidx.activity.ComponentActivity
import androidx.activity.result.contract.ActivityResultContracts
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageCapture
import androidx.camera.core.ImageCaptureException
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.core.content.ContextCompat
import com.google.android.gms.tasks.Task
import com.google.android.gms.tasks.Tasks
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.Text
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.TextRecognizer
import com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions
import com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions
import com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions
import com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import java.io.File
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class BillScanActivity : ComponentActivity() {
    companion object {
        const val EXTRA_STATUS = "bill_scan_status"
        const val EXTRA_TEXT = "bill_scan_text"
        const val EXTRA_LOCALE = "bill_scan_locale"
        private const val FILE_PREFIX = "bill_scan_"
    }

    private lateinit var previewView: PreviewView
    private lateinit var statusView: TextView
    private lateinit var captureButton: Button
    private var imageCapture: ImageCapture? = null
    private var cameraExecutor: ExecutorService? = null
    private var captureFile: File? = null
    private var selectedLanguage = "en"

    private val permissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { granted ->
        if (granted) startCamera() else finishWith("permission_denied")
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        selectedLanguage = intent.getStringExtra(EXTRA_LOCALE)
            ?.lowercase()
            ?.takeIf { it in setOf("en", "es", "pt", "zh") }
            ?: "en"
        requestedOrientation = android.content.pm.ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
        clearOrphanedCaptures()
        buildUi()
        cameraExecutor = Executors.newSingleThreadExecutor()
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED) {
            startCamera()
        } else {
            permissionLauncher.launch(Manifest.permission.CAMERA)
        }
    }

    private fun buildUi() {
        val root = FrameLayout(this).apply { setBackgroundColor(Color.BLACK) }
        previewView = PreviewView(this).apply {
            scaleType = PreviewView.ScaleType.FILL_CENTER
            layoutParams = FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
        }
        root.addView(previewView)

        statusView = TextView(this).apply {
            text = localized(
                "Place the front of the banknote inside the frame",
                "Colocá el frente del billete dentro del marco",
                "Coloque a frente da cédula dentro da moldura",
                "将纸币正面放入取景框"
            )
            setTextColor(Color.WHITE)
            setBackgroundColor(0x99000000.toInt())
            textSize = 18f
            gravity = Gravity.CENTER
            setPadding(24, 24, 24, 24)
            layoutParams = FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT,
                Gravity.TOP
            )
        }
        root.addView(statusView)

        captureButton = Button(this).apply {
            text = localized("Capture front", "Capturar frente", "Capturar frente", "拍摄正面")
            isEnabled = false
            setOnClickListener { captureAndRecognize() }
            layoutParams = FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT,
                Gravity.BOTTOM
            ).apply { setMargins(32, 32, 32, 48) }
        }
        root.addView(captureButton)
        setContentView(root)
    }

    private fun startCamera() {
        val providerFuture = ProcessCameraProvider.getInstance(this)
        providerFuture.addListener({
            try {
                val provider = providerFuture.get()
                val preview = Preview.Builder().build().also {
                    it.surfaceProvider = previewView.surfaceProvider
                }
                imageCapture = ImageCapture.Builder()
                    .setCaptureMode(ImageCapture.CAPTURE_MODE_MAXIMIZE_QUALITY)
                    .build()
                provider.unbindAll()
                provider.bindToLifecycle(
                    this,
                    CameraSelector.DEFAULT_BACK_CAMERA,
                    preview,
                    imageCapture
                )
                captureButton.isEnabled = true
            } catch (_: Exception) {
                finishWith("camera_error")
            }
        }, ContextCompat.getMainExecutor(this))
    }

    private fun captureAndRecognize() {
        val capture = imageCapture ?: return
        captureButton.isEnabled = false
        statusView.text = localized(
            "Reading reference text…",
            "Leyendo texto de referencia…",
            "Lendo o texto de referência…",
            "正在读取参考文字…"
        )
        val output = File(cacheDir, "$FILE_PREFIX${System.currentTimeMillis()}.jpg")
        captureFile = output
        val options = ImageCapture.OutputFileOptions.Builder(output).build()
        capture.takePicture(
            options,
            cameraExecutor ?: ContextCompat.getMainExecutor(this),
            object : ImageCapture.OnImageSavedCallback {
                override fun onImageSaved(result: ImageCapture.OutputFileResults) {
                    if (output.length() < 30_000L) {
                        finishWith("poor_quality")
                    } else {
                        runRecognition(output)
                    }
                }

                override fun onError(exception: ImageCaptureException) {
                    finishWith("camera_error")
                }
            }
        )
    }

    private fun runRecognition(file: File) {
        val input = try {
            InputImage.fromFilePath(this, Uri.fromFile(file))
        } catch (_: Exception) {
            finishWith("poor_quality")
            return
        }
        val recognizers = createRecognizers()
        val tasks: List<Task<Text>> = recognizers.map { it.process(input) }
        Tasks.whenAllComplete(tasks).addOnCompleteListener {
            val text = tasks.mapNotNull { task ->
                if (task.isSuccessful) {
                    task.result?.text?.trim()?.takeIf(String::isNotEmpty)
                } else {
                    null
                }
            }.distinct().joinToString("\n")
            recognizers.forEach(TextRecognizer::close)
            finishWith(if (text.isBlank()) "poor_quality" else "ok", text)
        }
    }

    private fun createRecognizers(): List<TextRecognizer> = listOf(
        TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS),
        TextRecognition.getClient(ChineseTextRecognizerOptions.Builder().build()),
        TextRecognition.getClient(DevanagariTextRecognizerOptions.Builder().build()),
        TextRecognition.getClient(JapaneseTextRecognizerOptions.Builder().build()),
        TextRecognition.getClient(KoreanTextRecognizerOptions.Builder().build())
    )

    private fun finishWith(status: String, text: String = "") {
        runOnUiThread {
            captureFile?.delete()
            setResult(Activity.RESULT_OK, Intent().apply {
                putExtra(EXTRA_STATUS, status)
                putExtra(EXTRA_TEXT, text)
            })
            finish()
        }
    }

    private fun clearOrphanedCaptures() {
        cacheDir.listFiles { file -> file.name.startsWith(FILE_PREFIX) }?.forEach(File::delete)
    }

    private fun localized(en: String, es: String, pt: String, zh: String): String =
        when (selectedLanguage) {
            "es" -> es
            "pt" -> pt
            "zh" -> zh
            else -> en
        }

    override fun onDestroy() {
        captureFile?.delete()
        cameraExecutor?.shutdown()
        super.onDestroy()
    }
}
