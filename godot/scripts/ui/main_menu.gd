extends Control

const UV_SCENE := "res://scenes/UvDetector.tscn"
const WATERMARK_SCENE := "res://scenes/WatermarkViewer.tscn"
const COUNTRY_SCENE := "res://scenes/CountrySelect.tscn"
const BILL_SCENE := "res://scenes/BillViewer.tscn"
const BASE_VIEWPORT := Vector2(1080.0, 1920.0)

var _title_label: Label
var _subtitle_label: Label
var _ad_banner_spacer: Control
var _language_label: Label
var _icon: TextureRect
var _language_select: OptionButton
var _language_row: HBoxContainer
var _action_buttons: Array[Button] = []
var _layout_root: VBoxContainer
var _button_rows: Array[HBoxContainer] = []


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	resized.connect(_apply_responsive_layout)
	_apply_responsive_layout()


func _build_ui() -> void:
	var content: VBoxContainer = ScreenBuilder.setup_root(self, Color(0.05, 0.08, 0.12, 1.0))
	content.add_theme_constant_override("separation", 14)

	var header := HBoxContainer.new()
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_theme_constant_override("separation", 16)
	content.add_child(header)

	_icon = TextureRect.new()
	_icon.texture = load("res://assets/ui/ic_launcher.png")
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	header.add_child(_icon)

	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.add_theme_constant_override("separation", 8)
	header.add_child(text_box)

	_title_label = Label.new()
	_title_label.text = AppState.t("app_title")
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_box.add_child(_title_label)

	_subtitle_label = Label.new()
	_subtitle_label.text = AppState.t("menu_subtitle")
	_subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_subtitle_label.modulate = Color(0.86, 0.91, 1.0)
	text_box.add_child(_subtitle_label)

	_language_row = HBoxContainer.new()
	_language_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_language_row.add_theme_constant_override("separation", 12)
	text_box.add_child(_language_row)

	_language_label = Label.new()
	_language_label.custom_minimum_size = Vector2(120, 0)
	_language_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_language_row.add_child(_language_label)

	_language_select = OptionButton.new()
	_language_select.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_populate_language_options(_language_select)
	_language_select.item_selected.connect(_on_language_selected.bind(_language_select))
	_language_row.add_child(_language_select)

	_layout_root = VBoxContainer.new()
	_layout_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_layout_root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_layout_root.add_theme_constant_override("separation", 14)
	content.add_child(_layout_root)

	_build_button_row(
		AppState.t("menu_uv"),
		Callable(self, "_open_uv"),
		AppState.t("menu_watermark"),
		Callable(self, "_open_watermark")
	)
	_build_button_row(
		AppState.t("select_country_title"),
		Callable(self, "_open_countries"),
		AppState.t("menu_about"),
		Callable(self, "_show_about")
	)
	_build_single_button_row(
		AppState.t("menu_exit"),
		Callable(self, "_exit_app")
	)

	_ad_banner_spacer = Control.new()
	_ad_banner_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(_ad_banner_spacer)
	ScreenBuilder.add_bottom_ad_reserve(self, true)


func _build_button_row(left_text: String, left_callback: Callable, right_text: String, right_callback: Callable) -> void:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 16)
	_layout_root.add_child(row)
	_button_rows.append(row)

	_add_menu_button(row, left_text, left_callback)
	_add_menu_button(row, right_text, right_callback)


func _build_single_button_row(text: String, callback: Callable) -> void:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 16)
	_layout_root.add_child(row)
	_button_rows.append(row)

	_add_menu_button(row, text, callback)


func _add_menu_button(parent: Container, text: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	button.pressed.connect(callback)
	button.pressed.connect(_play_click)
	parent.add_child(button)
	_action_buttons.append(button)


func _apply_responsive_layout() -> void:
	var viewport: Viewport = get_viewport()
	if viewport == null:
		return

	var viewport_size: Vector2 = viewport.get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return

	var fit_scale: float = min(viewport_size.x / BASE_VIEWPORT.x, viewport_size.y / BASE_VIEWPORT.y)
	var large_screen_scale: float = min(viewport_size.x, viewport_size.y) / BASE_VIEWPORT.x
	var ui_scale: float = clamp(max(fit_scale, large_screen_scale), 0.8, 2.2)
	var margin: int = int(round(24.0 * ui_scale))
	var icon_size: int = int(round(112.0 * ui_scale))
	var title_size: int = int(round(40.0 * ui_scale))
	var subtitle_size: int = int(round(18.0 * ui_scale))
	var label_size: int = int(round(34.0 * ui_scale))
	var language_height: int = int(round(118.0 * ui_scale))
	var language_label_width: int = int(round(190.0 * ui_scale))
	var button_height: int = int(round(108.0 * ui_scale))
	var button_size: int = int(round(24.0 * ui_scale))
	var ad_height: int = ScreenBuilder.get_bottom_ad_reserve_height(self)

	_icon.custom_minimum_size = Vector2(icon_size, icon_size)
	_title_label.add_theme_font_size_override("font_size", title_size)
	_subtitle_label.add_theme_font_size_override("font_size", subtitle_size)
	_language_label.text = "%s:" % AppState.t("language_label")
	_language_label.custom_minimum_size = Vector2(language_label_width, language_height)
	_language_label.add_theme_font_size_override("font_size", label_size)
	_language_select.custom_minimum_size = Vector2(0, language_height)
	_language_select.add_theme_font_size_override("font_size", label_size)
	_language_select.add_theme_constant_override("v_separation", int(round(18.0 * ui_scale)))
	var language_popup := _language_select.get_popup()
	if language_popup != null:
		language_popup.add_theme_font_size_override("font_size", label_size)
		language_popup.add_theme_constant_override("v_separation", int(round(20.0 * ui_scale)))
	if _language_row != null:
		_language_row.add_theme_constant_override("separation", int(round(18.0 * ui_scale)))
	_ad_banner_spacer.custom_minimum_size = Vector2(0, ad_height)

	var margin_container := _find_margin_container()
	if margin_container != null:
		margin_container.add_theme_constant_override("margin_left", margin)
		margin_container.add_theme_constant_override("margin_top", margin)
		margin_container.add_theme_constant_override("margin_right", margin)
		margin_container.add_theme_constant_override("margin_bottom", margin)

	for button in _action_buttons:
		button.custom_minimum_size = Vector2(0, button_height)
		button.add_theme_font_size_override("font_size", button_size)

	_layout_root.add_theme_constant_override("separation", int(round(14.0 * ui_scale)))
	for row in _button_rows:
		row.add_theme_constant_override("separation", int(round(16.0 * ui_scale)))


func _find_margin_container() -> MarginContainer:
	var container: int = get_child_count()
	for index in range(container):
		var child: Node = get_child(index)
		if child is MarginContainer:
			return child
	return null


func _play_click() -> void:
	var player := AudioStreamPlayer.new()
	player.stream = load("res://assets/ui/button.wav")
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()


func _populate_language_options(select: OptionButton) -> void:
	select.clear()
	select.add_item(AppState.t("follow_phone_language"), 0)

	var locales: Array[String] = AppState.get_supported_locales()
	for index in locales.size():
		var locale_code: String = locales[index]
		select.add_item(AppState.get_locale_display_name(locale_code), index + 1)

	var selected: int = 0
	if not AppState.uses_phone_locale():
		var current: String = AppState.get_locale_code()
		for index in locales.size():
			if locales[index] == current:
				selected = index + 1
				break
	select.select(selected)


func _on_language_selected(index: int, _select: OptionButton) -> void:
	if index <= 0:
		AppState.clear_locale_override()
	else:
		var locales: Array[String] = AppState.get_supported_locales()
		var locale_index: int = index - 1
		if locale_index >= 0 and locale_index < locales.size():
			AppState.set_locale_override(locales[locale_index])
	get_tree().reload_current_scene()


func _open_uv() -> void:
	get_tree().change_scene_to_file(UV_SCENE)


func _open_watermark() -> void:
	get_tree().change_scene_to_file(WATERMARK_SCENE)


func _open_countries() -> void:
	get_tree().change_scene_to_file(COUNTRY_SCENE)


func _show_about() -> void:
	_show_dialog(
		AppState.t("about_title"),
		AppState.get_about_text()
	)


func _show_dialog(title_text: String, body_text: String) -> void:
	var dialog := AcceptDialog.new()
	add_child(dialog)
	var dialog_scale := ScreenBuilder.configure_large_dialog(dialog, self, title_text, AppState.t("close"))

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", int(round(24.0 * dialog_scale)))
	dialog.add_child(content)

	ScreenBuilder.add_dialog_header(content, title_text, dialog.queue_free, dialog_scale)

	var body := Label.new()
	body.text = body_text
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_font_size_override("font_size", int(round(32.0 * dialog_scale)))
	content.add_child(body)

	dialog.popup_centered()


func _exit_app() -> void:
	get_tree().quit()
