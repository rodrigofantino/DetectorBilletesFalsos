extends Node

signal banner_attached
signal banner_hidden
signal banner_loaded
signal banner_failed(error: String)

const ADMOB_BANNER_UNIT_ID := "ca-app-pub-4703386652643425/9145624203"
const ADMOB_TEST_BANNER_UNIT_ID := "ca-app-pub-3940256099942544/6300978111"
const BANNER_RESERVED_HEIGHT := 96
const PLACEMENT_NONE := "none"
const PLACEMENT_MAIN_MENU := "main_menu"
const PLACEMENT_REVIEW_RESULT := "review_result"
const PLACEMENT_GUIDED_REVIEW := "guided_review"
const PLACEMENT_TOOL := "tool"
const PLACEMENT_CURRENCY_INFO := "currency_info"

# Replace these placeholders with the supplied production unit IDs. Keeping the
# mapping here makes each placement explicit without scattering IDs in screens.
const BANNER_UNIT_IDS := {
	PLACEMENT_MAIN_MENU: "ca-app-pub-4703386652643425/7909010195",
	PLACEMENT_REVIEW_RESULT: "ca-app-pub-4703386652643425/6100768207",
	PLACEMENT_GUIDED_REVIEW: "ca-app-pub-4703386652643425/6100768207",
	PLACEMENT_TOOL: "ca-app-pub-4703386652643425/4448669986",
	PLACEMENT_CURRENCY_INFO: "ca-app-pub-4703386652643425/3127170833",
}

var _ad_view: AdView
var _ad_listener: AdListener
var _initialized := false
var _initializing := false
var _banner_loaded := false
var _show_requested := false
var _placement := PLACEMENT_NONE
var _banner_unit_id := ""


func _ready() -> void:
	call_deferred("_connect_purchase_signals")


func should_reserve_banner_space() -> bool:
	return _placement != PLACEMENT_NONE and _banner_loaded and _is_android() and not _ads_removed()


func get_reserved_banner_height() -> int:
	if should_reserve_banner_space():
		var reserve_height := BANNER_RESERVED_HEIGHT
		if _ad_view != null:
			var native_height := _ad_view.get_height_in_pixels()
			var window_size := DisplayServer.window_get_size()
			var viewport_size := get_viewport().get_visible_rect().size
			if native_height > 0 and window_size.y > 0 and viewport_size.y > 0.0:
				var logical_height := int(ceil(native_height * viewport_size.y / float(window_size.y)))
				reserve_height = max(reserve_height, logical_height)
		return reserve_height
	return 0


func is_native_banner_attached() -> bool:
	return _ad_view != null and _is_android()


func is_banner_loaded() -> bool:
	return _banner_loaded and _is_android()


func show_banner() -> void:
	set_banner_placement(PLACEMENT_MAIN_MENU)


func set_banner_placement(placement: String) -> void:
	if not [PLACEMENT_NONE, PLACEMENT_MAIN_MENU, PLACEMENT_REVIEW_RESULT, PLACEMENT_GUIDED_REVIEW, PLACEMENT_TOOL, PLACEMENT_CURRENCY_INFO].has(placement):
		placement = PLACEMENT_NONE
	_placement = placement
	if _placement == PLACEMENT_NONE:
		hide_banner()
		return
	if _ads_removed():
		hide_banner()
		return
	_show_requested = true
	if not _is_android():
		return

	_initialize_admob_once()
	if not _initialized:
		return

	var requested_unit_id := _get_banner_unit_id()
	if _ad_view != null and _banner_unit_id != requested_unit_id:
		_dispose_banner()
	if _ad_view == null:
		_create_banner()

	if _ad_view != null:
		_ad_view.show()
		if not _banner_loaded:
			_ad_view.load_ad(AdRequest.new())


func show_main_menu_banner() -> void:
	set_banner_placement(PLACEMENT_MAIN_MENU)


func show_review_result_banner() -> void:
	set_banner_placement(PLACEMENT_REVIEW_RESULT)


func hide_banner() -> void:
	_placement = PLACEMENT_NONE
	_show_requested = false
	if _ad_view != null:
		_ad_view.hide()
	banner_hidden.emit()


func _connect_purchase_signals() -> void:
	var purchases := get_node_or_null("/root/AppPurchases")
	if purchases != null:
		purchases.entitlement_changed.connect(_on_entitlement_changed)


func _on_entitlement_changed(ads_removed: bool) -> void:
	if ads_removed:
		hide_banner()


func _ads_removed() -> bool:
	var purchases := get_node_or_null("/root/AppPurchases")
	return purchases != null and purchases.is_ads_removed()


func _initialize_admob_once() -> void:
	if _initialized or _initializing:
		return
	if not Engine.has_singleton("PoingGodotAdMob"):
		_log_failure("singleton missing: PoingGodotAdMob. Check Android export plugins.")
		banner_failed.emit("PoingGodotAdMob singleton missing")
		return
	_initializing = true
	var init_listener := OnInitializationCompleteListener.new()
	init_listener.on_initialization_complete = _on_admob_initialized
	MobileAds.initialize(init_listener)


func _is_android() -> bool:
	return OS.has_feature("android") or OS.has_feature("Android")


func _create_banner() -> void:
	if not Engine.has_singleton("PoingGodotAdMobAdView"):
		_log_failure("singleton missing: PoingGodotAdMobAdView. Check Android export plugins.")
		banner_failed.emit("PoingGodotAdMobAdView singleton missing")
		return
	if not Engine.has_singleton("PoingGodotAdMobAdSize"):
		_log_failure("singleton missing: PoingGodotAdMobAdSize. Check Android export plugins.")
		banner_failed.emit("PoingGodotAdMobAdSize singleton missing")
		return

	_ad_listener = AdListener.new()
	_ad_listener.on_ad_loaded = _on_ad_loaded
	_ad_listener.on_ad_failed_to_load = _on_ad_failed_to_load
	_ad_listener.on_ad_closed = _on_ad_closed

	var ad_size: AdSize = AdSize.get_current_orientation_anchored_adaptive_banner_ad_size(AdSize.FULL_WIDTH)
	if ad_size.width <= 0 or ad_size.height <= 0:
		ad_size = AdSize.BANNER

	var banner_unit_id := _get_banner_unit_id()
	print("AdMob: creating %s banner." % ("test" if banner_unit_id == ADMOB_TEST_BANNER_UNIT_ID else "production"))
	_ad_view = AdView.new(banner_unit_id, ad_size, AdPosition.Values.BOTTOM)
	_banner_unit_id = banner_unit_id
	_ad_view.ad_listener = _ad_listener
	banner_attached.emit()


func _dispose_banner() -> void:
	if _ad_view != null:
		_ad_view.hide()
		_ad_view.destroy()
	_ad_view = null
	_ad_listener = null
	_banner_unit_id = ""
	_banner_loaded = false


func _on_admob_initialized(_status: InitializationStatus) -> void:
	_initializing = false
	_initialized = true
	if _show_requested and _placement != PLACEMENT_NONE:
		# Keep the placement selected by the current screen. Calling show_banner()
		# here would always switch a review-result banner back to main_menu.
		set_banner_placement(_placement)


func _on_ad_loaded() -> void:
	_banner_loaded = true
	print("AdMob: banner loaded.")
	if _show_requested and _ad_view != null:
		_ad_view.show()
	banner_loaded.emit()


func _on_ad_failed_to_load(error: Variant = null) -> void:
	_banner_loaded = false
	var message := "unknown"
	if error != null and "message" in error:
		message = str(error.message)
	_log_failure("banner failed: %s" % message)
	banner_failed.emit(message)


func _on_ad_closed() -> void:
	_banner_loaded = false
	banner_hidden.emit()


func _log_failure(message: String) -> void:
	push_warning("AdMob: %s" % message)


func _get_banner_unit_id() -> String:
	if OS.is_debug_build():
		return ADMOB_TEST_BANNER_UNIT_ID
	return str(BANNER_UNIT_IDS.get(_placement, ADMOB_BANNER_UNIT_ID))
