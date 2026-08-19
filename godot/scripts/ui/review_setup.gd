extends Control

const MAIN_MENU_SCENE := "res://scenes/MainMenu.tscn"
const GUIDED_REVIEW_SCENE := "res://scenes/GuidedReview.tscn"

var _country_select: OptionButton
var _note_select: OptionButton
var _camera_status: Label
var _start_button: Button


func _ready() -> void:
	AppAds.hide_banner()
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()


func _build_ui() -> void:
	var root := ScreenBuilder.setup_root(self, Color(0.04, 0.07, 0.11, 1.0))
	var content := ScreenBuilder.add_scroll_content(root)
	ScreenBuilder.add_title(content, AppState.t("review_setup_title"))
	ScreenBuilder.add_subtitle(content, AppState.t("guided_review_subtitle"))
	ScreenBuilder.add_body(content, AppState.t("review_setup_intro"))

	var disclaimer := ScreenBuilder.add_body(content, AppState.t("review_disclaimer"))
	disclaimer.modulate = Color(1.0, 0.82, 0.42)

	var camera_button := ScreenBuilder.add_button(content, AppState.t("identify_camera"))
	camera_button.disabled = not BillRecognitionService.is_available()
	camera_button.pressed.connect(_identify_with_camera)
	_camera_status = ScreenBuilder.add_body(content, "")
	_camera_status.visible = camera_button.disabled
	if camera_button.disabled:
		_camera_status.text = AppState.t("camera_unavailable")

	ScreenBuilder.add_subtitle(content, AppState.t("choose_country"))
	_country_select = OptionButton.new()
	_country_select.custom_minimum_size = Vector2(0, 96)
	_country_select.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_country_select.item_selected.connect(_on_country_selected)
	content.add_child(_country_select)

	ScreenBuilder.add_subtitle(content, AppState.t("choose_banknote"))
	_note_select = OptionButton.new()
	_note_select.custom_minimum_size = Vector2(0, 96)
	_note_select.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_note_select.item_selected.connect(_on_note_selected)
	content.add_child(_note_select)

	_start_button = ScreenBuilder.add_button(content, AppState.t("start_review"))
	_start_button.pressed.connect(_start_review)
	var back := ScreenBuilder.add_button(content, AppState.t("back"))
	back.pressed.connect(_return_home)

	_populate_countries()


func _populate_countries() -> void:
	_country_select.clear()
	var countries := AppState.get_countries()
	var selected_index := 0
	for index in countries.size():
		var country := countries[index]
		_country_select.add_item(AppState.get_country_label(country))
		_country_select.set_item_metadata(index, country)
		if country == AppState.selected_country:
			selected_index = index
	_country_select.select(selected_index)
	_on_country_selected(selected_index)


func _on_country_selected(index: int) -> void:
	if index < 0 or index >= _country_select.item_count:
		return
	var country := str(_country_select.get_item_metadata(index))
	AppState.set_selected_country(country)
	_note_select.clear()
	var notes := AppState.get_notes_for_country(country)
	for note_index in notes.size():
		var note := notes[note_index]
		_note_select.add_item(AppState.get_note_badge(note))
		_note_select.set_item_metadata(note_index, AppState.get_note_id(note))
	_start_button.disabled = notes.is_empty()
	if not notes.is_empty():
		_note_select.select(0)


func _on_note_selected(index: int) -> void:
	if index >= 0 and index < _note_select.item_count:
		AppState.select_note_by_id(str(_note_select.get_item_metadata(index)))


func _identify_with_camera() -> void:
	_camera_status.visible = true
	_camera_status.text = AppState.t("camera_unavailable")
	BillRecognitionService.identify_front()


func _start_review() -> void:
	var index := _note_select.selected
	if index < 0 or index >= _note_select.item_count:
		return
	var note_id := str(_note_select.get_item_metadata(index))
	if not AppState.select_note_by_id(note_id):
		return
	if GuidedReviewSession.begin(AppState.get_selected_note()):
		get_tree().change_scene_to_file(GUIDED_REVIEW_SCENE)


func _return_home() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
