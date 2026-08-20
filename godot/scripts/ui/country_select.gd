extends Control


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	theme = ScreenBuilder._make_app_theme(self)
	_build_ui()


func _build_ui() -> void:
	var ui_scale := ScreenBuilder.readable_ui_scale(self)
	var margin_size := int(round(30.0 * ui_scale))
	var bottom_margin := margin_size + ScreenBuilder.get_bottom_ad_reserve_height(self)
	var button_height := int(round(132.0 * ui_scale))
	var button_font := int(round(34.0 * ui_scale))

	var background := ColorRect.new()
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.color = Color("111827")
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", margin_size)
	margin.add_theme_constant_override("margin_top", margin_size)
	margin.add_theme_constant_override("margin_right", margin_size)
	margin.add_theme_constant_override("margin_bottom", bottom_margin)
	add_child(margin)
	var root := VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", int(round(22.0 * ui_scale)))
	margin.add_child(root)

	var back := Button.new()
	back.text = AppState.t("back")
	back.custom_minimum_size = Vector2(0, button_height)
	back.add_theme_font_size_override("font_size", button_font)
	ScreenBuilder.style_button(back, "secondary")
	back.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	)
	root.add_child(back)

	var title := Label.new()
	title.text = AppState.t("select_country_title")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size", int(round(56.0 * ui_scale)))
	root.add_child(title)

	var hint := Label.new()
	hint.text = AppState.t("country_hint")
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", int(round(30.0 * ui_scale)))
	root.add_child(hint)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(scroll)

	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", int(round(18.0 * ui_scale)))
	scroll.add_child(list)

	for country in AppState.get_countries():
		var button := Button.new()
		button.text = AppState.get_country_label(country)
		button.custom_minimum_size = Vector2(0, button_height)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", button_font)
		ScreenBuilder.style_button(button, "secondary")
		button.pressed.connect(_open_country.bind(country))
		list.add_child(button)

	ScreenBuilder.enable_touch_scroll(scroll, list)
	set_meta("screen_builder_content", root)
	ScreenBuilder.add_bottom_ad_reserve(self, true, AppAds.PLACEMENT_CURRENCY_INFO)


func _open_country(country: String) -> void:
	AppState.set_selected_country(country)
	get_tree().change_scene_to_file("res://scenes/CurrencyInfo.tscn")
