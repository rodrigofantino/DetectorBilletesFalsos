extends Control

const MAIN_MENU_SCENE := "res://scenes/MainMenu.tscn"

var _light_rect: ColorRect

func _ready() -> void:
	var content := ScreenBuilder.setup_root(self, Color(0.03, 0.03, 0.08, 1.0))
	_light_rect = get_child(0) as ColorRect
	_set_light(Color(0.2, 0.2, 0.95, 1.0))

	var overlay := VBoxContainer.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	overlay.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(overlay)

	ScreenBuilder.add_spacer(overlay, 12)
	ScreenBuilder.add_title(overlay, "UV detector")
	ScreenBuilder.add_subtitle(overlay, "Strong blue and violet light for UV inspection")
	ScreenBuilder.add_spacer(overlay, 8)

	var controls := HBoxContainer.new()
	controls.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	controls.add_theme_constant_override("separation", 10)
	overlay.add_child(controls)

	var blue_button := ScreenBuilder.add_button(controls, "Blue")
	blue_button.pressed.connect(func() -> void:
		_set_light(Color(0.2, 0.2, 0.95, 1.0))
	)

	var violet_button := ScreenBuilder.add_button(controls, "Violet")
	violet_button.pressed.connect(func() -> void:
		_set_light(Color(0.35, 0.08, 0.75, 1.0))
	)

	ScreenBuilder.add_spacer(overlay, 12)
	var back_button := ScreenBuilder.add_button(overlay, "Back to menu")
	back_button.pressed.connect(_on_back_pressed)

func _set_light(color: Color) -> void:
	_light_rect.color = color

func _on_back_pressed() -> void:
	AppState.go_to_scene(MAIN_MENU_SCENE)
