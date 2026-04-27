class_name ScreenBuilder
extends Node

const BASE_VIEWPORT := Vector2(1080.0, 1920.0)

static func _ui_scale(control: Control) -> float:
	if control == null:
		return 1.0

	var viewport := control.get_viewport()
	if viewport == null:
		return 1.0

	var size := viewport.get_visible_rect().size
	if size.x <= 0.0 or size.y <= 0.0:
		return 1.0

	return clamp(min(size.x / BASE_VIEWPORT.x, size.y / BASE_VIEWPORT.y), 0.75, 1.5)

static func setup_root(root: Control, background: Color = Color(0.06, 0.07, 0.11, 1.0)) -> VBoxContainer:
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	var scale := _ui_scale(root)

	var background_rect := ColorRect.new()
	background_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background_rect.color = background
	root.add_child(background_rect)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var margin_size := int(round(24.0 * scale))
	margin.add_theme_constant_override("margin_left", margin_size)
	margin.add_theme_constant_override("margin_top", margin_size)
	margin.add_theme_constant_override("margin_right", margin_size)
	margin.add_theme_constant_override("margin_bottom", margin_size)
	root.add_child(margin)

	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(panel)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", int(round(16.0 * scale)))
	panel.add_child(content)

	return content

static func add_title(parent: Control, text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", int(round(30.0 * _ui_scale(parent))))
	parent.add_child(label)
	return label

static func add_subtitle(parent: Control, text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.modulate = Color(0.88, 0.9, 0.98, 1.0)
	label.add_theme_font_size_override("font_size", int(round(18.0 * _ui_scale(parent))))
	parent.add_child(label)
	return label

static func add_body(parent: Control, text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", int(round(16.0 * _ui_scale(parent))))
	parent.add_child(label)
	return label

static func add_button(parent: Control, text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(0.0, 88.0 * _ui_scale(parent))
	parent.add_child(button)
	return button

static func add_spacer(parent: Container, height: float = 8.0) -> Control:
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0.0, height)
	parent.add_child(spacer)
	return spacer

static func add_scroll_content(parent: VBoxContainer) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(scroll)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", int(round(12.0 * _ui_scale(parent))))
	scroll.add_child(content)
	return content
