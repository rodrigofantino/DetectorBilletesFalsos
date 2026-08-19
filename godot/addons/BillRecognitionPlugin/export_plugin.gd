@tool
extends EditorPlugin

var export_plugin: BillRecognitionExportPlugin


func _enter_tree() -> void:
	export_plugin = BillRecognitionExportPlugin.new()
	add_export_plugin(export_plugin)


func _exit_tree() -> void:
	remove_export_plugin(export_plugin)
	export_plugin = null


class BillRecognitionExportPlugin extends EditorExportPlugin:
	const PLUGIN_NAME := "BillRecognitionPlugin"

	func _supports_platform(platform: EditorExportPlatform) -> bool:
		return platform is EditorExportPlatformAndroid

	func _get_android_libraries(_platform: EditorExportPlatform, debug: bool) -> PackedStringArray:
		var variant := "debug" if debug else "release"
		return PackedStringArray(["%s/bin/%s/%s-%s.aar" % [PLUGIN_NAME, variant, PLUGIN_NAME, variant]])

	func _get_android_dependencies(_platform: EditorExportPlatform, _debug: bool) -> PackedStringArray:
		return PackedStringArray([
			"androidx.activity:activity:1.10.1",
			"androidx.camera:camera-camera2:1.5.1",
			"androidx.camera:camera-core:1.5.1",
			"androidx.camera:camera-lifecycle:1.5.1",
			"androidx.camera:camera-view:1.5.1",
			"androidx.concurrent:concurrent-futures:1.2.0",
			"com.google.guava:listenablefuture:1.0",
			"com.google.mlkit:text-recognition:16.0.1",
			"com.google.mlkit:text-recognition-chinese:16.0.1",
			"com.google.mlkit:text-recognition-devanagari:16.0.1",
			"com.google.mlkit:text-recognition-japanese:16.0.1",
			"com.google.mlkit:text-recognition-korean:16.0.1",
		])

	func _get_name() -> String:
		return PLUGIN_NAME
