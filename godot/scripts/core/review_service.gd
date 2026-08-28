extends Node

const STATE_PATH := "user://review_state.cfg"
const PLAY_STORE_LISTING_URL := "https://play.google.com/store/apps/details?id=com.appsimple.DetectorBilleteFalso2"
const PROMPT_COOLDOWN_DAYS := 1
const FEEDBACK_PROMPT_COOLDOWN_DAYS := 14
const INTERSTITIAL_REVIEW_INTERVAL := 3

var _usage_count := 0
var _first_launch_unix := 0
var _last_prompt_unix := 0
var _last_feedback_prompt_unix := 0
var _completed_review_pending := false
var _request_pending := false
var _manual_review_requested := false
var _manual_review_flow_pending := false
var _review_day := ""
var _daily_completed_reviews := 0


func _ready() -> void:
	_load_state()
	var purchases := get_node_or_null("/root/AppPurchases")
	if purchases != null and purchases.has_signal("billing_ready"):
		purchases.billing_ready.connect(_on_billing_ready)


func record_successful_use() -> void:
	_usage_count += 1
	_save_state()


func record_completed_review() -> bool:
	# The visible result screen offers the user an optional Play Store feedback action.
	_usage_count += 1
	_roll_daily_review_count()
	_daily_completed_reviews += 1
	_save_state()
	return _daily_completed_reviews % INTERSTITIAL_REVIEW_INTERVAL == 0


func can_show_completion_feedback() -> bool:
	var now := int(Time.get_unix_time_from_system())
	return _last_feedback_prompt_unix <= 0 or now - _last_feedback_prompt_unix >= FEEDBACK_PROMPT_COOLDOWN_DAYS * 86400


func mark_completion_feedback_shown() -> void:
	_last_feedback_prompt_unix = int(Time.get_unix_time_from_system())
	_save_state()


func can_request_manual_review() -> bool:
	if _manual_review_requested or _request_pending or not (OS.has_feature("android") or OS.has_feature("Android")):
		return false
	var billing := get_node_or_null("/root/AppPurchases")
	if billing == null or not billing.has_method("request_in_app_review"):
		return false
	return not billing.has_method("can_request_in_app_review") or billing.can_request_in_app_review()


func can_show_manual_review_action() -> bool:
	return OS.has_feature("android") or OS.has_feature("Android")


func request_manual_review() -> bool:
	if not can_request_manual_review():
		_open_play_store_listing()
		return false
	var billing := get_node_or_null("/root/AppPurchases")
	_request_pending = true
	_manual_review_flow_pending = true
	if billing.has_signal("review_flow_completed"):
		billing.review_flow_completed.connect(_on_review_finished, CONNECT_ONE_SHOT)
	if billing.has_signal("review_flow_error"):
		billing.review_flow_error.connect(_on_review_error, CONNECT_ONE_SHOT)
	billing.request_in_app_review()
	return true


func _maybe_request_review() -> void:
	if _request_pending or not _completed_review_pending or not (OS.has_feature("android") or OS.has_feature("Android")):
		return
	var now := int(Time.get_unix_time_from_system())
	if _last_prompt_unix > 0 and now - _last_prompt_unix < PROMPT_COOLDOWN_DAYS * 86400:
		return
	var billing := get_node_or_null("/root/AppPurchases")
	if billing == null or not billing.has_method("request_in_app_review"):
		return
	if billing.has_method("can_request_in_app_review") and not billing.can_request_in_app_review():
		return
	_request_pending = true
	_completed_review_pending = false
	_last_prompt_unix = now
	_save_state()
	if billing.has_signal("review_flow_completed"):
		billing.review_flow_completed.connect(_on_review_finished, CONNECT_ONE_SHOT)
	if billing.has_signal("review_flow_error"):
		billing.review_flow_error.connect(_on_review_error, CONNECT_ONE_SHOT)
	billing.request_in_app_review()


func _on_billing_ready() -> void:
	_maybe_request_review()


func _on_review_finished() -> void:
	_request_pending = false
	if _manual_review_flow_pending:
		# Google Play does not disclose whether a rating was submitted; record only
		# that its native review flow finished so the manual control is not repeated.
		_manual_review_requested = true
		_manual_review_flow_pending = false
		_save_state()


func _on_review_error(_message: String) -> void:
	var was_manual_request := _manual_review_flow_pending
	_request_pending = false
	_manual_review_flow_pending = false
	if was_manual_request:
		_open_play_store_listing()


func _open_play_store_listing() -> void:
	var error := OS.shell_open(PLAY_STORE_LISTING_URL)
	if error != OK:
		push_warning("Could not open Google Play listing: %s" % PLAY_STORE_LISTING_URL)


func _load_state() -> void:
	var config := ConfigFile.new()
	if config.load(STATE_PATH) != OK:
		_first_launch_unix = int(Time.get_unix_time_from_system())
		_save_state()
		return
	_usage_count = int(config.get_value("review", "usage_count", 0))
	_first_launch_unix = int(config.get_value("review", "first_launch_unix", Time.get_unix_time_from_system()))
	_last_prompt_unix = int(config.get_value("review", "last_prompt_unix", 0))
	_last_feedback_prompt_unix = int(config.get_value("review", "last_feedback_prompt_unix", 0))
	# Completion feedback is now a visible opt-in action from the result screen.
	# Clear pending state left by earlier automatic native review requests.
	_completed_review_pending = false
	_manual_review_requested = bool(config.get_value("review", "manual_review_requested", false))
	_review_day = str(config.get_value("review", "review_day", ""))
	_daily_completed_reviews = int(config.get_value("review", "daily_completed_reviews", 0))
	_roll_daily_review_count()


func _save_state() -> void:
	var config := ConfigFile.new()
	config.set_value("review", "usage_count", _usage_count)
	config.set_value("review", "first_launch_unix", _first_launch_unix)
	config.set_value("review", "last_prompt_unix", _last_prompt_unix)
	config.set_value("review", "last_feedback_prompt_unix", _last_feedback_prompt_unix)
	config.set_value("review", "completed_review_pending", _completed_review_pending)
	config.set_value("review", "manual_review_requested", _manual_review_requested)
	config.set_value("review", "review_day", _review_day)
	config.set_value("review", "daily_completed_reviews", _daily_completed_reviews)
	config.save(STATE_PATH)


func _roll_daily_review_count() -> void:
	var today := Time.get_date_string_from_system()
	if _review_day == today:
		return
	_review_day = today
	_daily_completed_reviews = 0
