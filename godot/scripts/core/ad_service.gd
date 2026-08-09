extends Node

signal banner_attached
signal banner_hidden
signal banner_loaded
signal banner_failed(error: String)

const ADMOB_BANNER_UNIT_ID := "ca-app-pub-4703386652643425/9145624203"
const BANNER_RESERVED_HEIGHT := 96

var _ad_view: AdView
var _ad_listener: AdListener
var _initialized := false
var _initializing := false
var _banner_loaded := false
var _show_requested := false


func _ready() -> void:
	call_deferred("_connect_purchase_signals")


func should_reserve_banner_space() -> bool:
	return _is_android() and not _ads_removed()


func get_reserved_banner_height() -> int:
	if should_reserve_banner_space():
		return BANNER_RESERVED_HEIGHT
	return 0


func is_native_banner_attached() -> bool:
	return _ad_view != null and _is_android()


func is_banner_loaded() -> bool:
	return _banner_loaded and _is_android()


func show_banner() -> void:
	if _ads_removed():
		return
	_show_requested = true
	if not _is_android():
		return

	_initialize_admob_once()
	if not _initialized:
		return

	if _ad_view == null:
		_create_banner()

	if _ad_view != null:
		_ad_view.show()
		if not _banner_loaded:
			_ad_view.load_ad(AdRequest.new())


func show_main_menu_banner() -> void:
	show_banner()


func hide_banner() -> void:
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

	_ad_view = AdView.new(ADMOB_BANNER_UNIT_ID, ad_size, AdPosition.Values.BOTTOM)
	_ad_view.ad_listener = _ad_listener
	banner_attached.emit()


func _on_admob_initialized(_status: InitializationStatus) -> void:
	_initializing = false
	_initialized = true
	if _show_requested:
		show_banner()


func _on_ad_loaded() -> void:
	_banner_loaded = true
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
