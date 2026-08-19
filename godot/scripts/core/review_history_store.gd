extends Node

signal library_changed

const STORE_PATH := "user://guided_review_history.cfg"
const STORE_VERSION := 1
const MAX_HISTORY := 50
const MAX_RECENTS := 10

var _history: Array[Dictionary] = []
var _recents: Array[String] = []
var _favorites: Dictionary = {}


func _ready() -> void:
	_load()


func add_completed_review(note_id: String, started_at_unix: int, generic_guide: bool) -> void:
	if AppState.find_note_by_id(note_id).is_empty():
		return
	_history.push_front({
		"note_id": note_id,
		"completed_at": int(Time.get_unix_time_from_system()),
		"started_at": started_at_unix,
		"guide_kind": "generic" if generic_guide else "specific",
	})
	if _history.size() > MAX_HISTORY:
		_history.resize(MAX_HISTORY)
	_recents.erase(note_id)
	_recents.push_front(note_id)
	if _recents.size() > MAX_RECENTS:
		_recents.resize(MAX_RECENTS)
	_save()


func toggle_favorite(note_id: String) -> bool:
	if AppState.find_note_by_id(note_id).is_empty():
		return false
	if _favorites.has(note_id):
		_favorites.erase(note_id)
	else:
		_favorites[note_id] = true
	_save()
	return _favorites.has(note_id)


func is_favorite(note_id: String) -> bool:
	return _favorites.has(note_id)


func get_history() -> Array[Dictionary]:
	return _history.duplicate(true)


func get_recents() -> Array[String]:
	return _recents.duplicate()


func get_favorites() -> Array[String]:
	var result: Array[String] = []
	for key in _favorites.keys():
		result.append(str(key))
	return result


func clear_history() -> void:
	_history.clear()
	_recents.clear()
	_save()


func _load() -> void:
	var config := ConfigFile.new()
	if config.load(STORE_PATH) != OK:
		return
	if int(config.get_value("meta", "version", 0)) != STORE_VERSION:
		return
	var history_value: Variant = config.get_value("library", "history", [])
	var recents_value: Variant = config.get_value("library", "recents", [])
	var favorites_value: Variant = config.get_value("library", "favorites", {})
	if history_value is Array:
		for item in history_value:
			if item is Dictionary and not AppState.find_note_by_id(str(item.get("note_id", ""))).is_empty():
				_history.append((item as Dictionary).duplicate(true))
	if recents_value is Array:
		for item in recents_value:
			var note_id := str(item)
			if not AppState.find_note_by_id(note_id).is_empty() and not _recents.has(note_id):
				_recents.append(note_id)
	if favorites_value is Dictionary:
		for key in (favorites_value as Dictionary).keys():
			var note_id := str(key)
			if not AppState.find_note_by_id(note_id).is_empty():
				_favorites[note_id] = true
	_history = _history.slice(0, MAX_HISTORY)
	_recents = _recents.slice(0, MAX_RECENTS)


func _save() -> void:
	var config := ConfigFile.new()
	config.set_value("meta", "version", STORE_VERSION)
	config.set_value("library", "history", _history)
	config.set_value("library", "recents", _recents)
	config.set_value("library", "favorites", _favorites)
	var error := config.save(STORE_PATH)
	if error != OK:
		push_warning("Guided review library could not be saved: %s" % error)
	library_changed.emit()
