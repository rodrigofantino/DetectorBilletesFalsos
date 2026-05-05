extends Node

const STARTIO_APP_ID_SETTING := "startio/app_id"
const STARTIO_APP_ID_FALLBACK := "203891181"
const BANNER_RESERVED_HEIGHT := 96

var _android_runtime: Object
var _java_wrapper: Object
var _activity: Object
var _banner: Object
var _initialized := false
var _show_requested := false


func should_reserve_banner_space() -> bool:
	return OS.has_feature("Android")


func get_reserved_banner_height() -> int:
	if should_reserve_banner_space():
		return BANNER_RESERVED_HEIGHT
	return 0


func show_main_menu_banner() -> void:
	_show_requested = true
	if not OS.has_feature("Android"):
		return

	if not _ensure_android_bridge():
		return

	var runnable: Object = _android_runtime.createRunnableFromGodotCallable(_show_banner_on_ui_thread)
	_activity.runOnUiThread(runnable)


func hide_banner() -> void:
	_show_requested = false
	if not OS.has_feature("Android"):
		return

	if not _ensure_android_bridge():
		return

	var runnable: Object = _android_runtime.createRunnableFromGodotCallable(_hide_banner_on_ui_thread)
	_activity.runOnUiThread(runnable)


func _ensure_android_bridge() -> bool:
	if _android_runtime == null:
		_android_runtime = Engine.get_singleton("AndroidRuntime")
	if _java_wrapper == null:
		_java_wrapper = Engine.get_singleton("JavaClassWrapper")
	if _android_runtime == null or _java_wrapper == null:
		push_warning("Start.io banner unavailable: AndroidRuntime or JavaClassWrapper singleton missing.")
		return false

	if _activity == null:
		_activity = _android_runtime.getActivity()
	if _activity == null:
		push_warning("Start.io banner unavailable: Android activity missing.")
		return false

	return true


func _show_banner_on_ui_thread() -> void:
	if not _show_requested:
		return

	if not _initialized:
		_initialize_startio()

	if _banner == null:
		_banner = _create_banner()
		if _banner == null:
			return
		_attach_banner_to_activity(_banner)
	elif _banner.getParent() == null:
		_attach_banner_to_activity(_banner)


func _hide_banner_on_ui_thread() -> void:
	if _banner == null:
		return

	var parent: Object = _banner.getParent()
	if parent != null:
		parent.removeView(_banner)
	_banner = null


func _initialize_startio() -> void:
	var startio_sdk: Object = _java_wrapper.wrap("com.startapp.sdk.adsbase.StartAppSDK")
	if startio_sdk == null:
		push_warning("Start.io SDK class not found. Check Gradle dependency export.")
		return

	startio_sdk.init(_activity, _get_startio_app_id())
	_initialized = true


func _create_banner() -> Object:
	var banner_class: Object = _java_wrapper.wrap("com.startapp.sdk.ads.banner.Banner")
	if banner_class == null:
		push_warning("Start.io Banner class not found. Check Gradle dependency export.")
		return null
	return banner_class.Banner(_activity)


func _attach_banner_to_activity(banner: Object) -> void:
	var root_view: Object = _activity.findViewById(16908290)
	if root_view == null:
		push_warning("Start.io banner could not find android.R.id.content.")
		return

	var view_group_params: Object = _java_wrapper.wrap("android.view.ViewGroup$LayoutParams")
	var frame_params_class: Object = _java_wrapper.wrap("android.widget.FrameLayout$LayoutParams")
	var gravity_class: Object = _java_wrapper.wrap("android.view.Gravity")
	if view_group_params == null or frame_params_class == null or gravity_class == null:
		push_warning("Start.io banner could not create Android layout params.")
		return

	var width: int = view_group_params.WRAP_CONTENT
	var height: int = view_group_params.WRAP_CONTENT
	var gravity: int = gravity_class.BOTTOM | gravity_class.CENTER_HORIZONTAL
	var params: Object = frame_params_class.LayoutParams(width, height, gravity)
	root_view.addView(banner, params)


func _get_startio_app_id() -> String:
	var configured_id := str(ProjectSettings.get_setting(STARTIO_APP_ID_SETTING, STARTIO_APP_ID_FALLBACK)).strip_edges()
	if configured_id.is_empty():
		return STARTIO_APP_ID_FALLBACK
	return configured_id
