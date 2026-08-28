extends Node

const SETTINGS_PATH := "user://analytics_consent.cfg"
const FIREBASE_OPTIONS_PATH := "res://firebase_options.json"
const ALLOWED_EVENTS := {
	"screen_view": ["screen_name"],
	"review_started": ["path"],
	"camera_result": ["result_kind"],
	"candidate_confirmed": [],
	"guide_step_answered": ["method"],
	"guide_completed": ["guide_kind"],
	"favorite_toggled": ["enabled"],
}

const ALLOWED_SCREENS := {
	"main_menu": true,
	"about": true,
	"uv_detector": true,
	"watermark_viewer": true,
	"country_select": true,
	"currency_info": true,
	"bill_viewer": true,
	"review_setup": true,
	"guided_review": true,
	"review_result": true,
	"review_library": true,
}

var _consent_decided := false
var _collection_enabled := false
var _plugin: Object
var _native_configured := false


func _ready() -> void:
	_load_consent()
	if Engine.has_singleton("FirebaseAnalyticsBridge"):
		_plugin = Engine.get_singleton("FirebaseAnalyticsBridge")
	_configure_native()
	_apply_native_collection_state()


func should_request_consent() -> bool:
	return _native_configured and not _consent_decided


func is_available() -> bool:
	return _native_configured


func is_collection_enabled() -> bool:
	return _native_configured and _collection_enabled


func set_consent(enabled: bool) -> void:
	_consent_decided = true
	_collection_enabled = enabled
	var config := ConfigFile.new()
	config.set_value("analytics", "decided", true)
	config.set_value("analytics", "enabled", enabled)
	if config.save(SETTINGS_PATH) != OK:
		push_warning("Analytics consent preference could not be saved.")
	_apply_native_collection_state()


func track(event_name: String, parameters: Dictionary = {}) -> void:
	if not _collection_enabled or _plugin == null or not ALLOWED_EVENTS.has(event_name):
		return
	var filtered: Dictionary = {}
	for key in ALLOWED_EVENTS[event_name]:
		if parameters.has(key):
			filtered[key] = parameters[key]
	if _plugin.has_method("log_event"):
		_plugin.log_event(event_name, filtered)


func track_screen(screen_name: String) -> void:
	if not ALLOWED_SCREENS.has(screen_name):
		return
	track("screen_view", {
		"screen_name": screen_name,
	})


func _load_consent() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return
	_consent_decided = bool(config.get_value("analytics", "decided", false))
	_collection_enabled = _consent_decided and bool(config.get_value("analytics", "enabled", false))


func _apply_native_collection_state() -> void:
	if _plugin != null and _plugin.has_method("set_collection_enabled"):
		_plugin.set_collection_enabled(_collection_enabled)


func _configure_native() -> void:
	if _plugin == null or not _plugin.has_method("configure") or not FileAccess.file_exists(FIREBASE_OPTIONS_PATH):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(FIREBASE_OPTIONS_PATH))
	if not (parsed is Dictionary):
		push_warning("Firebase options file is invalid; Analytics remains disabled.")
		return
	var options := parsed as Dictionary
	var api_key := str(options.get("api_key", "")).strip_edges()
	var application_id := str(options.get("application_id", "")).strip_edges()
	var project_id := str(options.get("project_id", "")).strip_edges()
	var sender_id := str(options.get("gcm_sender_id", "")).strip_edges()
	if [api_key, application_id, project_id].any(func(value: String) -> bool:
		return value.is_empty() or value.begins_with("replace-with-")
	):
		push_warning("Firebase options are incomplete; Analytics remains disabled.")
		return
	_native_configured = bool(_plugin.configure(
		api_key,
		application_id,
		project_id,
		sender_id
	))
