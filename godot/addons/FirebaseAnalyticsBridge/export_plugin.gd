@tool
extends EditorPlugin

var export_plugin: FirebaseAnalyticsExportPlugin


func _enter_tree() -> void:
	export_plugin = FirebaseAnalyticsExportPlugin.new()
	add_export_plugin(export_plugin)


func _exit_tree() -> void:
	remove_export_plugin(export_plugin)
	export_plugin = null


class FirebaseAnalyticsExportPlugin extends EditorExportPlugin:
	const PLUGIN_NAME := "FirebaseAnalyticsBridge"

	func _supports_platform(platform: EditorExportPlatform) -> bool:
		return platform is EditorExportPlatformAndroid

	func _get_android_libraries(_platform: EditorExportPlatform, debug: bool) -> PackedStringArray:
		var variant := "debug" if debug else "release"
		return PackedStringArray(["%s/bin/%s/%s-%s.aar" % [PLUGIN_NAME, variant, PLUGIN_NAME, variant]])

	func _get_android_dependencies(_platform: EditorExportPlatform, _debug: bool) -> PackedStringArray:
		return PackedStringArray(["com.google.firebase:firebase-analytics:23.2.0"])

	func _get_name() -> String:
		return PLUGIN_NAME
