class_name ScreenBuilder
extends Node

const BASE_VIEWPORT := Vector2(1080.0, 1920.0)
const BOTTOM_AD_HEIGHT_RATIO := 0.1

static func _ui_scale(control: Control) -> float:
	if control == null:
		return 1.0

	var viewport: Viewport = control.get_viewport()
	if viewport == null:
		return 1.0

	var size: Vector2 = viewport.get_visible_rect().size
	if size.x <= 0.0 or size.y <= 0.0:
		return 1.0

	return clamp(min(size.x / BASE_VIEWPORT.x, size.y / BASE_VIEWPORT.y), 0.75, 1.5)


static func readable_ui_scale(control: Control) -> float:
	if control == null:
		return 1.0

	var viewport: Viewport = control.get_viewport()
	if viewport == null:
		return 1.0

	var size: Vector2 = viewport.get_visible_rect().size
	if size.x <= 0.0 or size.y <= 0.0:
		return 1.0

	var fit_scale: float = min(size.x / BASE_VIEWPORT.x, size.y / BASE_VIEWPORT.y)
	var large_screen_scale: float = min(size.x, size.y) / BASE_VIEWPORT.x
	return clamp(max(fit_scale, large_screen_scale), 1.0, 2.2)

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

static func get_bottom_ad_reserve_height(control: Control) -> int:
	if control == null:
		return 0

	var viewport := control.get_viewport()
	if viewport == null:
		return 0

	var size := viewport.get_visible_rect().size
	if size.y <= 0.0:
		return 0
	return int(round(size.y * BOTTOM_AD_HEIGHT_RATIO))

static func add_bottom_ad_reserve(root: Control, hide_when_banner_loaded: bool = true) -> TextureRect:
	AppAds.show_banner()
	var banner := TextureRect.new()
	banner.name = "BottomAdFallback"
	banner.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_update_bottom_ad_reserve_rect(root, banner)
	banner.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	banner.stretch_mode = TextureRect.STRETCH_SCALE
	banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	banner.texture = _make_ad_fallback_texture()
	banner.visible = false
	if hide_when_banner_loaded:
		AppAds.banner_loaded.connect(func() -> void:
			if is_instance_valid(banner):
				banner.visible = false
		)
		AppAds.banner_failed.connect(func(_error: String) -> void:
			if is_instance_valid(banner):
				banner.visible = false
		)
		AppAds.banner_hidden.connect(func() -> void:
			if is_instance_valid(banner):
				banner.visible = false
		)
	root.resized.connect(func() -> void:
		if is_instance_valid(banner):
			_update_bottom_ad_reserve_rect(root, banner)
	)
	root.add_child(banner)
	return banner

static func _update_bottom_ad_reserve_rect(root: Control, banner: Control) -> void:
	var height := get_bottom_ad_reserve_height(root)
	banner.offset_top = -height
	banner.offset_bottom = 0

static func _make_ad_fallback_texture() -> Texture2D:
	var image := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.35, 0.35, 0.35, 1.0))
	return ImageTexture.create_from_image(image)

static func enable_touch_scroll(scroll: ScrollContainer, content: Control) -> void:
	if scroll == null or content == null:
		return

	scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	_connect_touch_scroll(scroll, content)

static func _connect_touch_scroll(scroll: ScrollContainer, node: Node) -> void:
	if node is Control:
		var control := node as Control
		if not control.gui_input.is_connected(_relay_touch_scroll.bind(scroll)):
			control.gui_input.connect(_relay_touch_scroll.bind(scroll))

	for child in node.get_children():
		_connect_touch_scroll(scroll, child)

static func _relay_touch_scroll(event: InputEvent, scroll: ScrollContainer) -> void:
	if scroll == null:
		return

	if event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		scroll.scroll_vertical = max(0, scroll.scroll_vertical - int(round(drag.relative.y)))
		scroll.accept_event()
	elif event is InputEventPanGesture:
		var pan := event as InputEventPanGesture
		scroll.scroll_vertical = max(0, scroll.scroll_vertical + int(round(pan.delta.y * 48.0)))
		scroll.accept_event()

static func show_source_popup(parent: Control, url: String) -> void:
	if parent == null or url.strip_edges().is_empty():
		return

	var dialog := AcceptDialog.new()
	dialog.title = "Official source"
	dialog.ok_button_text = "Close"
	dialog.min_size = Vector2(720, 420)
	parent.add_child(dialog)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 18)
	dialog.add_child(content)

	var message := Label.new()
	message.text = "Embedded web preview is not available in this build. Use the official URL below."
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message.add_theme_font_size_override("font_size", 24)
	content.add_child(message)

	var url_label := Label.new()
	url_label.text = url
	url_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	url_label.selectable = true
	url_label.add_theme_font_size_override("font_size", 22)
	content.add_child(url_label)

	var open_button := Button.new()
	open_button.text = "Open in browser"
	open_button.custom_minimum_size = Vector2(0, 84)
	open_button.add_theme_font_size_override("font_size", 26)
	open_button.pressed.connect(func() -> void:
		OS.shell_open(url)
	)
	content.add_child(open_button)

	dialog.popup_centered()

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
