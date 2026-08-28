extends Control

const MAIN_MENU_SCENE := "res://scenes/MainMenu.tscn"
const GUIDED_REVIEW_SCENE := "res://scenes/GuidedReview.tscn"

var _country_select: OptionButton
var _note_select: OptionButton
var _camera_status: Label
var _camera_button: Button
var _start_button: Button
var _candidate_box: VBoxContainer
var _camera_section: VBoxContainer
var _manual_section: VBoxContainer
var _scan_in_progress := false
var _selection_path := "manual"


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	AnalyticsService.track_screen("review_setup")
	_build_ui()
	if not BillRecognitionService.recognition_finished.is_connected(_on_recognition_finished):
		BillRecognitionService.recognition_finished.connect(_on_recognition_finished)


func _build_ui() -> void:
	var root := ScreenBuilder.setup_root(self, Color(0.04, 0.07, 0.11, 1.0))
	var content := ScreenBuilder.add_scroll_content(root)
	var title := ScreenBuilder.add_title(content, AppState.t("review_setup_title"))
	title.add_theme_font_size_override("font_size", 58)
	var subtitle := ScreenBuilder.add_subtitle(content, AppState.t("guided_review_subtitle"))
	subtitle.add_theme_font_size_override("font_size", 38)
	var intro := ScreenBuilder.add_body(content, AppState.t("review_setup_intro"))
	intro.add_theme_font_size_override("font_size", 36)

	var method_label := ScreenBuilder.add_subtitle(content, AppState.t("review_choose_method"))
	method_label.add_theme_font_size_override("font_size", 38)
	var camera_choice := ScreenBuilder.add_button(content, AppState.t("review_camera_option"), "primary")
	camera_choice.pressed.connect(_choose_camera)
	var manual_choice := ScreenBuilder.add_button(content, AppState.t("review_manual_option"))
	manual_choice.pressed.connect(_choose_manual)

	_camera_section = VBoxContainer.new()
	_camera_section.add_theme_constant_override("separation", 10)
	_camera_section.visible = false
	content.add_child(_camera_section)
	_camera_button = ScreenBuilder.add_button(_camera_section, AppState.t("identify_camera"))
	_camera_button.pressed.connect(_identify_with_camera)
	_camera_status = ScreenBuilder.add_body(_camera_section, "")
	_camera_status.add_theme_font_size_override("font_size", 36)
	_refresh_camera_availability()
	call_deferred("_refresh_camera_availability")
	_candidate_box = VBoxContainer.new()
	_candidate_box.add_theme_constant_override("separation", 10)
	_camera_section.add_child(_candidate_box)

	_manual_section = VBoxContainer.new()
	_manual_section.add_theme_constant_override("separation", 12)
	_manual_section.visible = false
	content.add_child(_manual_section)
	var country_label := ScreenBuilder.add_subtitle(_manual_section, AppState.t("choose_country"))
	country_label.add_theme_font_size_override("font_size", 38)
	_country_select = OptionButton.new()
	_country_select.custom_minimum_size = Vector2(0, 96)
	_country_select.add_theme_font_size_override("font_size", 40)
	_country_select.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_country_select.item_selected.connect(_on_country_selected)
	_manual_section.add_child(_country_select)
	ScreenBuilder.style_option_button(_country_select)
	_country_select.get_popup().add_theme_font_size_override("font_size", 40)

	var banknote_label := ScreenBuilder.add_subtitle(_manual_section, AppState.t("choose_banknote"))
	banknote_label.add_theme_font_size_override("font_size", 38)
	_note_select = OptionButton.new()
	_note_select.custom_minimum_size = Vector2(0, 96)
	_note_select.add_theme_font_size_override("font_size", 40)
	_note_select.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_note_select.item_selected.connect(_on_note_selected)
	_manual_section.add_child(_note_select)
	ScreenBuilder.style_option_button(_note_select)
	_note_select.get_popup().add_theme_font_size_override("font_size", 40)

	_start_button = ScreenBuilder.add_button(_manual_section, AppState.t("start_review"), "primary")
	_start_button.pressed.connect(_start_review)
	var back := ScreenBuilder.add_button(content, AppState.t("back"), "secondary")
	back.pressed.connect(_return_home)
	for button in [camera_choice, manual_choice, _camera_button, _start_button, back]:
		button.add_theme_font_size_override("font_size", 40)
	ScreenBuilder.add_bottom_ad_reserve(self, true, AppAds.PLACEMENT_GUIDED_REVIEW)

	_populate_countries()


func _refresh_camera_availability() -> void:
	var available := BillRecognitionService.is_available()
	_camera_button.disabled = not available or _scan_in_progress
	_camera_status.visible = not available
	_camera_status.text = "" if available else AppState.t("camera_unavailable")


func _choose_camera() -> void:
	_selection_path = "camera"
	_camera_section.visible = true
	_manual_section.visible = false
	_identify_with_camera()


func _choose_manual() -> void:
	_selection_path = "manual"
	_camera_section.visible = false
	_manual_section.visible = true
	_clear_candidates()


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
		_selection_path = "manual"
		AppState.select_note_by_id(str(_note_select.get_item_metadata(index)))


func _identify_with_camera() -> void:
	if _scan_in_progress or not BillRecognitionService.is_available():
		_refresh_camera_availability()
		return
	_scan_in_progress = true
	_camera_button.disabled = true
	_camera_status.visible = true
	_camera_status.text = AppState.t("scan_processing")
	_clear_candidates()
	BillRecognitionService.identify_front()


func _on_recognition_finished(result: Dictionary) -> void:
	_scan_in_progress = false
	_refresh_camera_availability()
	var status := str(result.get("status", "unknown"))
	AnalyticsService.track("camera_result", {"result_kind": status})
	var candidates: Variant = result.get("candidates", [])
	_clear_candidates()
	if status == "candidate" and candidates is Array and not candidates.is_empty():
		_camera_status.text = AppState.t("scan_candidates")
		for candidate in candidates:
			if not (candidate is Dictionary):
				continue
			var note_id := str((candidate as Dictionary).get("note_id", ""))
			var note := AppState.find_note_by_id(note_id)
			if note.is_empty():
				continue
			var button := ScreenBuilder.add_button(_candidate_box, AppState.get_note_title(note))
			button.add_theme_font_size_override("font_size", 40)
			button.pressed.connect(_confirm_candidate.bind(note_id))
		return
	match status:
		"permission_denied":
			_camera_status.text = AppState.t("scan_permission_denied")
		"poor_quality", "camera_error":
			_camera_status.text = AppState.t("scan_poor_quality")
		"cancelled":
			_camera_status.text = AppState.t("scan_cancelled")
		"unavailable":
			_camera_status.text = AppState.t("camera_unavailable")
		_:
			_camera_status.text = AppState.t("scan_unknown")


func _confirm_candidate(note_id: String) -> void:
	if not AppState.select_note_by_id(note_id):
		return
	AnalyticsService.track("candidate_confirmed")
	for country_index in _country_select.item_count:
		if str(_country_select.get_item_metadata(country_index)) == AppState.selected_country:
			_country_select.select(country_index)
			_on_country_selected(country_index)
			break
	for note_index in _note_select.item_count:
		if str(_note_select.get_item_metadata(note_index)) == note_id:
			_note_select.select(note_index)
			_on_note_selected(note_index)
			break
	_selection_path = "camera"
	_clear_candidates()
	_start_review()


func _clear_candidates() -> void:
	if _candidate_box == null:
		return
	for child in _candidate_box.get_children():
		child.queue_free()


func _start_review() -> void:
	var index := _note_select.selected
	if index < 0 or index >= _note_select.item_count:
		return
	var note_id := str(_note_select.get_item_metadata(index))
	if not AppState.select_note_by_id(note_id):
		return
	if GuidedReviewSession.begin(AppState.get_selected_note()):
		AnalyticsService.track("review_started", {"path": _selection_path})
		get_tree().change_scene_to_file(GUIDED_REVIEW_SCENE)


func _return_home() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
