extends Control

var _phase := 0.0
var _tool_light: ColorRect


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	AppAds.hide_banner()
	AppState.acquire_tool_screen()
	_build_ui()


func _process(delta: float) -> void:
	_phase += delta * 0.75
	var pulse := 0.5 + 0.5 * sin(_phase)
	var color := Color.from_hsv(0.64 + 0.05 * pulse, 0.85, 0.25 + 0.15 * pulse)
	_tool_light.color = color


func _build_ui() -> void:
	var root := ScreenBuilder.setup_root(self, ScreenBuilder.COLOR_BACKGROUND)
	var title := ScreenBuilder.add_title(root, AppState.t("uv_title"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var message := ScreenBuilder.add_body(root, AppState.t("uv_message"))
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	_tool_light = ColorRect.new()
	_tool_light.name = "ToolLight"
	_tool_light.color = Color(0.02, 0.0, 0.2)
	_tool_light.custom_minimum_size = Vector2(0, 420)
	_tool_light.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tool_light.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_tool_light.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_tool_light)

	var back := ScreenBuilder.add_button(root, AppState.t("back"), "secondary")
	back.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	)


func _exit_tree() -> void:
	AppState.release_tool_screen()
