extends Control

const MAIN_MENU_SCENE := "res://scenes/MainMenu.tscn"
const GUIDED_REVIEW_SCENE := "res://scenes/GuidedReview.tscn"

var _content: VBoxContainer


func _ready() -> void:
	AppAds.hide_banner()
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()


func _build_ui() -> void:
	var root := ScreenBuilder.setup_root(self, Color(0.04, 0.07, 0.11, 1.0))
	_content = ScreenBuilder.add_scroll_content(root)
	ScreenBuilder.add_title(_content, AppState.t("library_title"))
	var back := ScreenBuilder.add_button(_content, AppState.t("back"), "quiet")
	back.pressed.connect(func() -> void: get_tree().change_scene_to_file(MAIN_MENU_SCENE))

	var favorites := ReviewHistoryStore.get_favorites()
	var recents := ReviewHistoryStore.get_recents()
	if favorites.is_empty() and recents.is_empty():
		ScreenBuilder.add_body(_content, AppState.t("library_empty"))
		return

	if not favorites.is_empty():
		ScreenBuilder.add_subtitle(_content, AppState.t("library_favorites"))
		_add_note_buttons(favorites)
	if not recents.is_empty():
		ScreenBuilder.add_subtitle(_content, AppState.t("library_recent"))
		_add_note_buttons(recents)
		var clear := ScreenBuilder.add_button(_content, AppState.t("clear_history"), "warning")
		clear.pressed.connect(_clear_history)


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
