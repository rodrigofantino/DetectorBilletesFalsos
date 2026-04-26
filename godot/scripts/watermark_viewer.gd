extends Control

const MAIN_MENU_SCENE := "res://scenes/MainMenu.tscn"

var _cycle_rect: ColorRect
var _timer: Timer
var _colors: Array[Color] = [
	Color(0.16, 0.25, 0.95, 1.0),
	Color(0.75, 0.18, 0.95, 1.0),
	Color(0.95, 0.22, 0.24, 1.0),
	Color(0.2, 0.9, 0.38, 1.0),
	Color(0.96, 0.88, 0.18, 1.0),
]
var _color_index: int = 0
var _running: bool = true

func _ready() -> void:
	var content := ScreenBuilder.setup_root(self, Color(0.05, 0.05, 0.06, 1.0))
	_cycle_rect = get_child(0) as ColorRect
	_cycle_rect.color = _colors[0]

	var overlay := VBoxContainer.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	overlay.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(overlay)

	ScreenBuilder.add_spacer(overlay, 12)
	ScreenBuilder.add_title(overlay, "Watermark viewer")
	ScreenBuilder.add_subtitle(overlay, "Timed color cycling to help reveal paper differences")
	ScreenBuilder.add_spacer(overlay, 8)

	var controls := HBoxContainer.new()
	controls.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	controls.add_theme_constant_override("separation", 10)
	overlay.add_child(controls)

	var toggle_button := ScreenBuilder.add_button(controls, "Pause")
	toggle_button.pressed.connect(func() -> void:
		_running = not _running
		toggle_button.text = "Pause" if _running else "Resume"
	)

	var back_button := ScreenBuilder.add_button(controls, "Back to menu")
	back_button.pressed.connect(_on_back_pressed)

	ScreenBuilder.add_spacer(overlay, 8)
	ScreenBuilder.add_body(overlay, "The background cycles through saturated colors on a timer. This is a lightweight placeholder for the legacy watermark tool.")

	_timer = Timer.new()
	_timer.wait_time = 0.75
	_timer.one_shot = false
	_timer.autostart = true
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)

func _on_timer_timeout() -> void:
	if not _running:
		return

	_color_index = (_color_index + 1) % _colors.size()
	_cycle_rect.color = _colors[_color_index]

func _on_back_pressed() -> void:
	AppState.go_to_scene(MAIN_MENU_SCENE)
