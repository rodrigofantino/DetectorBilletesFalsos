@tool
extends EditorPlugin

var _export_plugin: EditorExportPlugin


func _enter_tree() -> void:
	_export_plugin = StartIoAndroidExportPlugin.new()
	add_export_plugin(_export_plugin)


func _exit_tree() -> void:
	remove_export_plugin(_export_plugin)
	_export_plugin = null


class StartIoAndroidExportPlugin extends EditorExportPlugin:
	const STARTIO_APP_ID_SETTING := "startio/app_id"
	const STARTIO_APP_ID_FALLBACK := "203891181"

	func _get_name() -> String:
		return "StartIoBanner"

	func _supports_platform(platform: EditorExportPlatform) -> bool:
		return platform is EditorExportPlatformAndroid

	func _get_android_dependencies(_platform: EditorExportPlatform, _debug: bool) -> PackedStringArray:
		return PackedStringArray([
			"com.startapp:inapp-sdk:5.3.0"
		])

	func _get_android_dependencies_maven_repos(_platform: EditorExportPlatform, _debug: bool) -> PackedStringArray:
		return PackedStringArray([
			"https://repo1.maven.org/maven2"
		])

	func _get_android_manifest_element_contents(_platform: EditorExportPlatform, _debug: bool) -> String:
		return "\n".join([
			"<uses-permission android:name=\"com.google.android.gms.permission.AD_ID\" />"
		])

	func _get_android_manifest_application_element_contents(_platform: EditorExportPlatform, _debug: bool) -> String:
		return "\n".join([
			"<meta-data android:name=\"com.startapp.sdk.APPLICATION_ID\" android:value=\"%s\" />" % _get_startio_app_id(),
			"<meta-data android:name=\"com.startapp.sdk.SPLASH_ENABLED\" android:value=\"false\" />",
			"<meta-data android:name=\"com.startapp.sdk.RETURN_ADS_ENABLED\" android:value=\"false\" />"
		])

	func _get_startio_app_id() -> String:
		var configured_id := str(ProjectSettings.get_setting(STARTIO_APP_ID_SETTING, STARTIO_APP_ID_FALLBACK)).strip_edges()
		if configured_id.is_empty():
			return STARTIO_APP_ID_FALLBACK
		return configured_id
