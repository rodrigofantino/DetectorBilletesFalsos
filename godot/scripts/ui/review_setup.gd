extends Control

const MAIN_MENU_SCENE := "res://scenes/MainMenu.tscn"
const GUIDED_REVIEW_SCENE := "res://scenes/GuidedReview.tscn"

var _country_select: Button
var _country_popup: PopupPanel
var _country_scroll: ScrollContainer
var _country_list: VBoxContainer
var _countries: Array[String] = []
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
	_country_select = Button.new()
	_country_select.custom_minimum_size = Vector2(0, 96)
	_country_select.add_theme_font_size_override("font_size", 40)
	_country_select.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_country_select.pressed.connect(_show_country_popup)
	_manual_section.add_child(_country_select)
	ScreenBuilder.style_button(_country_select, "secondary")
	_build_country_popup()

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
	_countries = AppState.get_countries()
	for child in _country_list.get_children():
		child.queue_free()
	for country_value in _countries:
		var country := str(country_value)
		var button := ScreenBuilder.add_button(_country_list, AppState.get_country_label(country), "secondary")
		button.custom_minimum_size = Vector2(0, 96)
		button.add_theme_font_size_override("font_size", 40)
		_configure_country_button(button, country)
	ScreenBuilder.enable_touch_scroll(_country_scroll, _country_list, true)
	if _countries.is_empty():
		_country_select.text = ""
		_country_select.disabled = true
		_note_select.clear()
		_start_button.disabled = true
		return
	_country_select.disabled = false
	var selected_country := AppState.selected_country
	if not _countries.has(selected_country):
		selected_country = str(_countries[0])
	_select_country(selected_country)


func _select_country(country: String) -> void:
	if not _countries.has(country):
		return
	AppState.set_selected_country(country)
	_country_select.text = AppState.get_country_label(country)
	_note_select.clear()
	var notes := AppState.get_notes_for_country(country)
	for note_index in notes.size():
		var note := notes[note_index]
		_note_select.add_item(AppState.get_note_badge(note))
		_note_select.set_item_metadata(note_index, AppState.get_note_id(note))
	_start_button.disabled = notes.is_empty()
	if not notes.is_empty():
		_note_select.select(0)


func _build_country_popup() -> void:
	_country_popup = PopupPanel.new()
	_country_popup.theme = theme
	_country_popup.exclusive = true
	_country_popup.add_theme_stylebox_override("panel", ScreenBuilder._style_box(ScreenBuilder.COLOR_SURFACE, ScreenBuilder.COLOR_BORDER, 22, 1, 24))
	add_child(_country_popup)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	_country_popup.add_child(margin)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 14)
	margin.add_child(content)
	var title := ScreenBuilder.add_subtitle(content, AppState.t("choose_country"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 38)
	_country_scroll = ScrollContainer.new()
	_country_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_country_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_country_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content.add_child(_country_scroll)
	_country_list = VBoxContainer.new()
	_country_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_country_list.add_theme_constant_override("separation", 12)
	_country_scroll.add_child(_country_list)


func _show_country_popup() -> void:
	var viewport_size := get_viewport_rect().size
	var popup_size := Vector2i(
		int(maxf(1.0, minf(760.0, viewport_size.x * 0.90))),
		int(maxf(1.0, viewport_size.y * 0.72))
	)
	_country_popup.popup_centered(popup_size)


func _configure_country_button(button: Button, country: String) -> void:
	var gesture := {"dragged": false, "distance": 0.0}
	var ui_scale := ScreenBuilder.readable_ui_scale(self)
	button.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventScreenTouch and (event as InputEventScreenTouch).pressed:
			gesture.dragged = false
			gesture.distance = 0.0
		elif event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT and (event as InputEventMouseButton).pressed:
			gesture.dragged = false
			gesture.distance = 0.0
		elif event is InputEventScreenDrag:
			gesture.distance += (event as InputEventScreenDrag).relative.length()
		elif event is InputEventMouseMotion and ((event as InputEventMouseMotion).button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
			gesture.distance += (event as InputEventMouseMotion).relative.length()
		if gesture.distance >= 12.0 * ui_scale:
			gesture.dragged = true
	)
	button.pressed.connect(func() -> void:
		if gesture.dragged:
			return
		_select_country(country)
		_country_popup.hide()
	)


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
	_select_country(AppState.selected_country)
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
	if _country_popup != null and _country_popup.visible:
		_country_popup.hide()
		return
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
