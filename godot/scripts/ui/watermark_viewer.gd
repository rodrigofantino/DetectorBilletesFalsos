extends Control

var _hue := 0.0
var _paused := false
var _tool_light: ColorRect


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	AppState.acquire_tool_screen()
	_build_ui()
	set_process(true)


func _process(delta: float) -> void:
	if _paused:
		return

	_hue = fposmod(_hue + delta * 0.14, 1.0)
	_tool_light.color = Color.from_hsv(_hue, 0.72, 0.95)


func _build_ui() -> void:
	var root := ScreenBuilder.setup_root(self, ScreenBuilder.COLOR_BACKGROUND)
	var title := ScreenBuilder.add_title(root, AppState.t("watermark_title"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 58)
	var message := ScreenBuilder.add_body(root, AppState.t("watermark_message"))
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.add_theme_font_size_override("font_size", 36)

	_tool_light = ColorRect.new()
	_tool_light.name = "ToolLight"
	_tool_light.color = Color(0.6, 0.8, 1.0)
	_tool_light.custom_minimum_size = Vector2(0, 420)
	_tool_light.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tool_light.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_tool_light.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_tool_light)

	var bar := HBoxContainer.new()
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.add_theme_constant_override("separation", 14)
	root.add_child(bar)

	var back := ScreenBuilder.add_button(bar, AppState.t("back"), "secondary")
	back.add_theme_font_size_override("font_size", 40)
	back.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	)

	var pause := ScreenBuilder.add_button(bar, AppState.t("pause"), "secondary")
	pause.add_theme_font_size_override("font_size", 40)
	pause.pressed.connect(func() -> void:
		_paused = !_paused
		pause.text = AppState.t("resume") if _paused else AppState.t("pause")
	)
	ScreenBuilder.add_bottom_ad_reserve(self, true, AppAds.PLACEMENT_TOOL)


func _exit_tree() -> void:
	AppState.release_tool_screen()
