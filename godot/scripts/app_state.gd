extends Node

const CURRENCY_DATA_PATH := "res://data/currencyinfo.json"

var currency_entries: Array[Dictionary] = []
var country_index: Dictionary = {}
var country_order: Array[StringName] = []
var selected_country_key: StringName = &""
var selected_bill_index: int = 0
var data_loaded: bool = false

func _ready() -> void:
	load_currency_data()

func load_currency_data() -> void:
	if data_loaded:
		return

	currency_entries.clear()
	country_index.clear()
	country_order.clear()

	var file := FileAccess.open(CURRENCY_DATA_PATH, FileAccess.READ)
	if file == null:
		push_error("AppState: could not open %s" % CURRENCY_DATA_PATH)
		data_loaded = true
		return

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is not Dictionary:
		push_error("AppState: invalid JSON root in %s" % CURRENCY_DATA_PATH)
		data_loaded = true
		return

	var root: Dictionary = parsed
	var raw_entries: Variant = root.get("CurrencyInfo", [])
	if raw_entries is Array:
		for raw_entry in raw_entries:
			if raw_entry is Dictionary:
				_add_entry(raw_entry)
	else:
		push_error("AppState: missing CurrencyInfo array in %s" % CURRENCY_DATA_PATH)

	data_loaded = true
	_ensure_default_selection()

func _add_entry(raw_entry: Dictionary) -> void:
	var country_label := str(raw_entry.get("country", "")).strip_edges()
	if country_label.is_empty():
		return

	var country_key := _normalize_country_key(country_label)
	var entry: Dictionary = {
		"country": country_label,
		"country_key": country_key,
		"currency": str(raw_entry.get("currency", "")).strip_edges(),
		"denomination": str(raw_entry.get("denomination", "")).strip_edges(),
		"watermark": str(raw_entry.get("watermark", "")).strip_edges(),
		"description": str(raw_entry.get("description", "")).strip_edges(),
	}

	currency_entries.append(entry)

	var bucket: Dictionary = country_index.get(country_key, {})
	var bucket_label := str(bucket.get("label", country_label))
	var entries: Array[Dictionary] = []
	var raw_bucket_entries: Variant = bucket.get("entries", [])
	if raw_bucket_entries is Array:
		for item in raw_bucket_entries:
			if item is Dictionary:
				entries.append(item)

	entries.append(entry)
	bucket["label"] = bucket_label
	bucket["entries"] = entries
	country_index[country_key] = bucket

	if not country_order.has(country_key):
		country_order.append(country_key)

func _normalize_country_key(country_label: String) -> StringName:
	var normalized := country_label.strip_edges().to_lower()
	normalized = normalized.replace(" ", "_")
	normalized = normalized.replace("-", "_")
	return StringName(normalized)

func _ensure_default_selection() -> void:
	if country_order.is_empty():
		selected_country_key = &""
		selected_bill_index = 0
		return

	if selected_country_key == &"" or not country_index.has(selected_country_key):
		selected_country_key = country_order[0]

	var entries := _get_entries_for_country(selected_country_key)
	if entries.is_empty():
		selected_bill_index = 0
	else:
		selected_bill_index = clampi(selected_bill_index, 0, entries.size() - 1)

func get_countries() -> Array[Dictionary]:
	_ensure_default_selection()

	var result: Array[Dictionary] = []
	for country_key in country_order:
		var bucket: Dictionary = country_index.get(country_key, {})
		var entries: Array[Dictionary] = get_entries_for_country(country_key)
		result.append({
			"key": country_key,
			"label": str(bucket.get("label", country_key)),
			"count": entries.size(),
		})
	return result

func get_entries_for_country(country_key: StringName) -> Array[Dictionary]:
	return _get_entries_for_country(country_key)

func _get_entries_for_country(country_key: StringName) -> Array[Dictionary]:
	var bucket: Dictionary = country_index.get(country_key, {})
	var raw_entries: Variant = bucket.get("entries", [])
	var result: Array[Dictionary] = []
	if raw_entries is Array:
		for item in raw_entries:
			if item is Dictionary:
				result.append(item)
	return result

func select_country(country_key: StringName) -> void:
	if country_index.has(country_key):
		selected_country_key = country_key
		selected_bill_index = 0

func select_bill(index: int) -> void:
	var entries := get_selected_entries()
	if entries.is_empty():
		selected_bill_index = 0
		return

	selected_bill_index = clampi(index, 0, entries.size() - 1)

func get_selected_country_label() -> String:
	_ensure_default_selection()
	var bucket: Dictionary = country_index.get(selected_country_key, {})
	return str(bucket.get("label", ""))

func get_selected_entries() -> Array[Dictionary]:
	_ensure_default_selection()
	return _get_entries_for_country(selected_country_key)

func get_selected_entry() -> Dictionary:
	var entries := get_selected_entries()
	if entries.is_empty():
		return {}
	return entries[clampi(selected_bill_index, 0, entries.size() - 1)]

func go_to_scene(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)
