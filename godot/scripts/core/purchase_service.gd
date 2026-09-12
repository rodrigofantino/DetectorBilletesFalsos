extends Node

signal entitlement_changed(ads_removed: bool)
signal purchase_message(message_key: String)
signal billing_ready
signal review_flow_completed
signal review_flow_error(message: String)

const REMOVE_ADS_PRODUCT_ID := "remove_ads"
const PURCHASE_STATE_PATH := "user://purchase_state.cfg"

var _billing_client: BillingClient
var _product_available := false
var _ads_removed := false


func _init() -> void:
	_load_cached_entitlement()


func _ready() -> void:
	if not _is_android() or not Engine.has_singleton("GodotGooglePlayBilling"):
		return

	_billing_client = BillingClient.new()
	_billing_client.connected.connect(_on_billing_connected)
	_billing_client.connect_error.connect(_on_billing_connect_error)
	_billing_client.query_product_details_response.connect(_on_product_details_response)
	_billing_client.query_purchases_response.connect(_on_purchases_response)
	_billing_client.on_purchase_updated.connect(_on_purchase_updated)
	_billing_client.acknowledge_purchase_response.connect(_on_acknowledge_response)
	_billing_client.review_flow_completed.connect(review_flow_completed.emit)
	_billing_client.review_flow_error.connect(review_flow_error.emit)
	_billing_client.start_connection()


func is_ads_removed() -> bool:
	return _ads_removed


func can_purchase_remove_ads() -> bool:
	return _is_android() and _product_available and _billing_client != null and _billing_client.is_ready()


func purchase_remove_ads() -> void:
	if _ads_removed:
		purchase_message.emit("ads_removed")
		return
	if not can_purchase_remove_ads():
		purchase_message.emit("purchase_unavailable")
		return
	var result: Dictionary = _billing_client.purchase(REMOVE_ADS_PRODUCT_ID)
	if int(result.get("response_code", -1)) != BillingClient.BillingResponseCode.OK:
		purchase_message.emit("purchase_failed")


func request_in_app_review() -> void:
	if _billing_client != null and _billing_client.is_ready():
		_billing_client.request_in_app_review()


func can_request_in_app_review() -> bool:
	return _is_android() and _billing_client != null and _billing_client.is_ready()


func _on_billing_connected() -> void:
	billing_ready.emit()
	_billing_client.query_product_details(
		PackedStringArray([REMOVE_ADS_PRODUCT_ID]),
		BillingClient.ProductType.INAPP
	)
	_billing_client.query_purchases(BillingClient.ProductType.INAPP)


func _on_billing_connect_error(_response_code: int, _debug_message: String) -> void:
	# Keep the cached entitlement during temporary Play Store/network failures.
	_product_available = false


func _on_product_details_response(response: Dictionary) -> void:
	if int(response.get("response_code", -1)) != BillingClient.BillingResponseCode.OK:
		return
	_product_available = not (response.get("product_details", []) as Array).is_empty()


func _on_purchases_response(response: Dictionary) -> void:
	if int(response.get("response_code", -1)) != BillingClient.BillingResponseCode.OK:
		return
	_set_ads_removed(false)
	for purchase in response.get("purchases", []) as Array:
		_process_purchase(purchase)


func _on_purchase_updated(response: Dictionary) -> void:
	if int(response.get("response_code", -1)) != BillingClient.BillingResponseCode.OK:
		return
	for purchase in response.get("purchases", []) as Array:
		_process_purchase(purchase)


func _process_purchase(purchase: Dictionary) -> void:
	var product_ids: Array = purchase.get("product_ids", [])
	if not product_ids.has(REMOVE_ADS_PRODUCT_ID):
		return
	if int(purchase.get("purchase_state", -1)) != BillingClient.PurchaseState.PURCHASED:
		purchase_message.emit("purchase_pending")
		return

	_set_ads_removed(true)
	if not bool(purchase.get("is_acknowledged", false)):
		_billing_client.acknowledge_purchase(str(purchase.get("purchase_token", "")))
	purchase_message.emit("ads_removed")


func _on_acknowledge_response(response: Dictionary) -> void:
	if int(response.get("response_code", -1)) != BillingClient.BillingResponseCode.OK:
		push_warning("Google Play Billing: could not acknowledge remove_ads purchase")


func _set_ads_removed(value: bool) -> void:
	if _ads_removed == value:
		return
	_ads_removed = value
	_save_cached_entitlement()
	entitlement_changed.emit(_ads_removed)


func _load_cached_entitlement() -> void:
	var config := ConfigFile.new()
	if config.load(PURCHASE_STATE_PATH) == OK:
		_ads_removed = bool(config.get_value("purchase", "remove_ads", false))


func _save_cached_entitlement() -> void:
	var config := ConfigFile.new()
	config.set_value("purchase", "remove_ads", _ads_removed)
	config.save(PURCHASE_STATE_PATH)


func _is_android() -> bool:
	return OS.has_feature("android") or OS.has_feature("Android")
