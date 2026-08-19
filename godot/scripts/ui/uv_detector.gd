extends Control

var _phase := 0.0


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	AppState.acquire_tool_screen()
	_build_ui()


func _process(delta: float) -> void:
	_phase += delta * 0.75
	var pulse := 0.5 + 0.5 * sin(_phase)
	var color := Color.from_hsv(0.64 + 0.05 * pulse, 0.85, 0.25 + 0.15 * pulse)
	$ColorRect.color = color


func _build_ui() -> void:
	var ui_scale := ScreenBuilder._ui_scale(self)
	var margin_size := int(round(24.0 * ui_scale))
	var bottom_margin := margin_size + ScreenBuilder.get_bottom_ad_reserve_height(self)
	var button_height := int(round(112.0 * ui_scale))
	var button_font := int(round(28.0 * ui_scale))

	var background := ColorRect.new()
	background.name = "ColorRect"
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.color = Color(0.02, 0.0, 0.2)
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
	root.add_theme_constant_override("separation", 16)
	margin.add_child(root)

	var back := Button.new()
	back.text = AppState.t("back")
	back.custom_minimum_size = Vector2(0, button_height)
	back.add_theme_font_size_override("font_size", button_font)
	back.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	)
	root.add_child(back)

	var title := Label.new()
	title.text = AppState.t("uv_title")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", int(round(42.0 * ui_scale)))
	root.add_child(title)

	var message := Label.new()
	message.text = AppState.t("uv_message")
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.add_theme_font_size_override("font_size", int(round(22.0 * ui_scale)))
	root.add_child(message)

	var filler := Control.new()
	filler.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(filler)


func _exit_tree() -> void:
	AppState.release_tool_screen()
