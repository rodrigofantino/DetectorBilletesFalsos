extends Control

var _hue := 0.0
var _paused := false


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	AppState.acquire_tool_screen()
	_build_ui()
	set_process(true)


func _process(delta: float) -> void:
	if _paused:
		return

	_hue = fposmod(_hue + delta * 0.14, 1.0)
	$ColorRect.color = Color.from_hsv(_hue, 0.72, 0.95)


func _build_ui() -> void:
	var background := ColorRect.new()
	background.name = "ColorRect"
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.color = Color(0.6, 0.8, 1.0)
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)

	var root := VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 16)
	margin.add_child(root)

	var bar := HBoxContainer.new()
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.add_theme_constant_override("separation", 12)
	root.add_child(bar)

	var back := Button.new()
	back.text = AppState.t("back")
	back.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	)
	bar.add_child(back)

	var pause := Button.new()
	pause.text = AppState.t("pause")
	pause.pressed.connect(func() -> void:
		_paused = !_paused
		pause.text = AppState.t("resume") if _paused else AppState.t("pause")
	)
	bar.add_child(pause)

	var title := Label.new()
	title.text = AppState.t("watermark_title")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	root.add_child(title)

	var message := Label.new()
	message.text = AppState.t("watermark_message")
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(message)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(spacer)


func _exit_tree() -> void:
	AppState.release_tool_screen()
