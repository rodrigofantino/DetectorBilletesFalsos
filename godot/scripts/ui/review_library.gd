extends Control

const MAIN_MENU_SCENE := "res://scenes/MainMenu.tscn"
const GUIDED_REVIEW_SCENE := "res://scenes/GuidedReview.tscn"

var _content: VBoxContainer


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	AnalyticsService.track_screen("review_library")
	_build_ui()


func _build_ui() -> void:
	var root := ScreenBuilder.setup_root(self, Color(0.04, 0.07, 0.11, 1.0))
	_content = ScreenBuilder.add_scroll_content(root)
	var title := ScreenBuilder.add_title(_content, AppState.t("library_title"))
	title.add_theme_font_size_override("font_size", 58)

	var favorites := ReviewHistoryStore.get_favorites()
	var recents := ReviewHistoryStore.get_recents()
	if favorites.is_empty() and recents.is_empty():
		var empty := ScreenBuilder.add_body(_content, AppState.t("library_empty"))
		empty.add_theme_font_size_override("font_size", 36)
	else:
		if not favorites.is_empty():
			var favorites_title := ScreenBuilder.add_subtitle(_content, AppState.t("library_favorites"))
			favorites_title.add_theme_font_size_override("font_size", 38)
			_add_note_buttons(favorites)
		if not recents.is_empty():
			var recent_title := ScreenBuilder.add_subtitle(_content, AppState.t("library_recent"))
			recent_title.add_theme_font_size_override("font_size", 38)
			_add_note_buttons(recents)
			var clear := ScreenBuilder.add_button(_content, AppState.t("clear_history"), "warning")
			clear.add_theme_font_size_override("font_size", 40)
			clear.pressed.connect(_clear_history)

	var back := ScreenBuilder.add_button(root, AppState.t("back"), "secondary")
	back.add_theme_font_size_override("font_size", 40)
	back.pressed.connect(func() -> void: get_tree().change_scene_to_file(MAIN_MENU_SCENE))
	ScreenBuilder.add_bottom_ad_reserve(self, true, AppAds.PLACEMENT_GUIDED_REVIEW)


func _add_note_buttons(note_ids: Array[String]) -> void:
	var seen: Dictionary = {}
	for note_id in note_ids:
		if seen.has(note_id):
			continue
		seen[note_id] = true
		var note := AppState.find_note_by_id(note_id)
		if note.is_empty():
			continue
		var button := ScreenBuilder.add_button(_content, AppState.get_note_title(note))
		button.add_theme_font_size_override("font_size", 40)
		button.pressed.connect(_start_review.bind(note_id))


func _start_review(note_id: String) -> void:
	if not AppState.select_note_by_id(note_id):
		return
	if GuidedReviewSession.begin(AppState.get_selected_note()):
		AnalyticsService.track("review_started", {"path": "library"})
		get_tree().change_scene_to_file(GUIDED_REVIEW_SCENE)


func _clear_history() -> void:
	ReviewHistoryStore.clear_history()
	get_tree().reload_current_scene()
