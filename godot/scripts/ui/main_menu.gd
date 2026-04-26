extends Control


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()


func _build_ui() -> void:
	var background := TextureRect.new()
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.texture = load("res://assets/ui/appsimplelogo.jpg")
	background.modulate = Color(0.2, 0.25, 0.35, 0.22)
	add_child(background)

	var overlay := ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.06, 0.09, 0.18, 0.92)
	add_child(overlay)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 28)
	add_child(margin)

	var root := VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 18)
	margin.add_child(root)

	var brand := HBoxContainer.new()
	brand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	brand.add_theme_constant_override("separation", 16)
	root.add_child(brand)

	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(112, 112)
	icon.texture = load("res://assets/ui/ic_launcher.png")
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	brand.add_child(icon)

	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	brand.add_child(text_box)

	var title := Label.new()
	title.text = AppState.t("app_title")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title.add_theme_font_size_override("font_size", 40)
	text_box.add_child(title)

	var subtitle := Label.new()
	subtitle.text = AppState.t("menu_subtitle")
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.modulate = Color(0.86, 0.91, 1.0)
	text_box.add_child(subtitle)

	var language_row := HBoxContainer.new()
	language_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	language_row.add_theme_constant_override("separation", 12)
	text_box.add_child(language_row)

	var language_label := Label.new()
	language_label.text = "%s:" % AppState.t("language_label")
	language_label.custom_minimum_size = Vector2(120, 0)
	language_row.add_child(language_label)

	var language_select := OptionButton.new()
	language_select.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_populate_language_options(language_select)
	language_select.item_selected.connect(_on_language_selected.bind(language_select))
	language_row.add_child(language_select)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 16)
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(grid)

	_add_menu_button(grid, AppState.t("menu_uv"), Callable(self, "_open_uv"))
	_add_menu_button(grid, AppState.t("menu_watermark"), Callable(self, "_open_watermark"))
	_add_menu_button(grid, AppState.t("select_country_title"), Callable(self, "_open_countries"))
	_add_menu_button(grid, AppState.t("menu_help"), Callable(self, "_show_help"))
	_add_menu_button(grid, AppState.t("menu_about"), Callable(self, "_show_about"))
	_add_menu_button(grid, AppState.t("menu_exit"), Callable(self, "_exit_app"))

	var note := Label.new()
	note.text = AppState.t("menu_baseline")
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(note)


func _add_menu_button(parent: Node, text: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 88)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(callback)
	button.pressed.connect(_play_click)
	parent.add_child(button)


func _play_click() -> void:
	var player := AudioStreamPlayer.new()
	player.stream = load("res://assets/ui/button.wav")
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()


func _populate_language_options(select: OptionButton) -> void:
	select.clear()
	select.add_item(AppState.t("follow_phone_language"), 0)

	var locales := AppState.get_supported_locales()
	for index in locales.size():
		var locale_code := locales[index]
		select.add_item(AppState.get_locale_display_name(locale_code), index + 1)

	var selected := 0
	if not AppState.uses_phone_locale():
		var current := AppState.get_locale_code()
		for index in locales.size():
			if locales[index] == current:
				selected = index + 1
				break
	select.select(selected)


func _on_language_selected(index: int, select: OptionButton) -> void:
	if index <= 0:
		AppState.clear_locale_override()
	else:
		var locales := AppState.get_supported_locales()
		var locale_index := index - 1
		if locale_index >= 0 and locale_index < locales.size():
			AppState.set_locale_override(locales[locale_index])
	get_tree().reload_current_scene()


func _open_uv() -> void:
	get_tree().change_scene_to_file("res://scenes/UvDetector.tscn")


func _open_watermark() -> void:
	get_tree().change_scene_to_file("res://scenes/WatermarkViewer.tscn")


func _open_countries() -> void:
	get_tree().change_scene_to_file("res://scenes/CountrySelect.tscn")


func _show_help() -> void:
	_show_dialog(
		AppState.t("help_title"),
		AppState.t("help_body")
	)


func _show_about() -> void:
	_show_dialog(
		AppState.t("about_title"),
		AppState.get_about_text()
	)


func _show_dialog(title_text: String, body_text: String) -> void:
	var dialog := AcceptDialog.new()
	dialog.title = title_text
	dialog.dialog_text = body_text
	dialog.ok_button_text = AppState.t("close")
	dialog.min_size = Vector2(540, 260)
	add_child(dialog)
	dialog.popup_centered()


func _exit_app() -> void:
	get_tree().quit()
