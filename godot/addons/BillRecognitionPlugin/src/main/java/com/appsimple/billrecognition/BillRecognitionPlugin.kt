package com.appsimple.billrecognition

import android.app.Activity
import android.content.Intent
import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.SignalInfo
import org.godotengine.godot.plugin.UsedByGodot

class BillRecognitionPlugin(godot: Godot) : GodotPlugin(godot) {
    companion object { private const val REQUEST_SCAN = 7402 }

    override fun getPluginName() = "BillRecognitionPluginV2"

    override fun getPluginSignals(): MutableSet<SignalInfo> = mutableSetOf(
        SignalInfo("recognition_completed", String::class.java, String::class.java)
    )

    @UsedByGodot
    fun identify_front(locale: String) {
        val host = activity
        if (host == null) {
            emitSignal("recognition_completed", "unavailable", "")
            return
        }
        runOnUiThread {
            host.startActivityForResult(
                Intent(host, BillScanActivity::class.java).putExtra(BillScanActivity.EXTRA_LOCALE, locale),
                REQUEST_SCAN
            )
        }
    }

    override fun onMainActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode != REQUEST_SCAN) return
        val status = data?.getStringExtra(BillScanActivity.EXTRA_STATUS)
            ?: if (resultCode == Activity.RESULT_CANCELED) "cancelled" else "error"
        emitSignal(
            "recognition_completed",
            status,
            data?.getStringExtra(BillScanActivity.EXTRA_TEXT).orEmpty()
        )
    }
}
