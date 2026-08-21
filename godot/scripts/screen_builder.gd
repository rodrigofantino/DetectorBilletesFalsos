class_name ScreenBuilder
extends Node

const BASE_VIEWPORT := Vector2(1080.0, 1920.0)
const MIN_DIALOG_SIZE_RATIO := Vector2(0.9, 0.64)
const MIN_DIALOG_BUTTON_HEIGHT := 118.0
const COLOR_BACKGROUND := Color("0b1220")
const COLOR_SURFACE := Color("162033")
const COLOR_SURFACE_ALT := Color("1e293b")
const COLOR_SURFACE_HOVER := Color("27364d")
const COLOR_PRIMARY := Color("1d4ed8")
const COLOR_PRIMARY_HOVER := Color("2563eb")
const COLOR_PRIMARY_PRESSED := Color("1e40af")
const COLOR_TEXT := Color("f8fafc")
const COLOR_TEXT_MUTED := Color("cbd5e1")
const COLOR_BORDER := Color("334155")
const COLOR_FOCUS := Color("60a5fa")
const COLOR_WARNING := Color("fbbf24")

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

static func dialog_ui_scale(control: Control) -> float:
	return clamp(readable_ui_scale(control), 1.15, 2.4)

static func visual_ui_scale(control: Control) -> float:
	return clamp(readable_ui_scale(control), 1.0, 1.25)

static func _style_box(background: Color, border: Color = Color.TRANSPARENT, radius: int = 18, border_width: int = 0, padding: int = 18) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.content_margin_left = padding
	style.content_margin_top = padding
	style.content_margin_right = padding
	style.content_margin_bottom = padding
	return style

static func _make_app_theme(control: Control) -> Theme:
	var scale := visual_ui_scale(control)
	var theme := Theme.new()
	theme.default_font_size = int(round(24.0 * scale))
	theme.set_color("font_color", "Label", COLOR_TEXT)
	theme.set_color("font_color", "Button", COLOR_TEXT)
	theme.set_color("font_hover_color", "Button", COLOR_TEXT)
	theme.set_color("font_pressed_color", "Button", COLOR_TEXT)
	theme.set_color("font_disabled_color", "Button", Color(COLOR_TEXT_MUTED, 0.46))
	theme.set_font_size("font_size", "Button", int(round(26.0 * scale)))
	theme.set_stylebox("normal", "Button", _style_box(COLOR_SURFACE_ALT, COLOR_BORDER, 16, 1, int(round(16.0 * scale))))
	theme.set_stylebox("hover", "Button", _style_box(COLOR_SURFACE_HOVER, COLOR_FOCUS, 16, 1, int(round(16.0 * scale))))
	theme.set_stylebox("pressed", "Button", _style_box(Color("172238"), COLOR_FOCUS, 16, 2, int(round(16.0 * scale))))
	theme.set_stylebox("disabled", "Button", _style_box(Color(COLOR_SURFACE_ALT, 0.48), Color(COLOR_BORDER, 0.5), 16, 1, int(round(16.0 * scale))))
	theme.set_stylebox("focus", "Button", _style_box(Color.TRANSPARENT, COLOR_FOCUS, 16, 2, int(round(14.0 * scale))))
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		theme.set_stylebox(state, "OptionButton", theme.get_stylebox(state, "Button"))
	for color_name in ["font_color", "font_hover_color", "font_pressed_color", "font_disabled_color"]:
		theme.set_color(color_name, "OptionButton", theme.get_color(color_name, "Button"))
	theme.set_font_size("font_size", "OptionButton", int(round(25.0 * scale)))
	theme.set_stylebox("panel", "PanelContainer", _style_box(COLOR_SURFACE, COLOR_BORDER, 22, 1, int(round(22.0 * scale))))
	theme.set_stylebox("panel", "PopupMenu", _style_box(COLOR_SURFACE, COLOR_BORDER, 14, 1, int(round(10.0 * scale))))
	theme.set_stylebox("hover", "PopupMenu", _style_box(COLOR_SURFACE_HOVER, Color.TRANSPARENT, 10, 0, int(round(8.0 * scale))))
	theme.set_color("font_color", "PopupMenu", COLOR_TEXT)
	theme.set_color("font_hover_color", "PopupMenu", COLOR_TEXT)
	theme.set_font_size("font_size", "PopupMenu", int(round(24.0 * scale)))
	return theme

static func style_button(button: Button, variant: String = "secondary") -> void:
	if button == null:
		return
	enable_button_text_fit(button)
	var scale := visual_ui_scale(button)
	var padding := int(round(16.0 * scale))
	match variant:
		"primary":
			button.add_theme_stylebox_override("normal", _style_box(COLOR_PRIMARY, Color("3b82f6"), 20, 1, padding))
			button.add_theme_stylebox_override("hover", _style_box(COLOR_PRIMARY_HOVER, Color("93c5fd"), 20, 2, padding))
			button.add_theme_stylebox_override("pressed", _style_box(COLOR_PRIMARY_PRESSED, COLOR_FOCUS, 20, 2, padding))
			button.add_theme_stylebox_override("focus", _style_box(Color.TRANSPARENT, Color("bfdbfe"), 20, 3, max(8, padding - 3)))
			button.add_theme_font_size_override("font_size", int(round(30.0 * scale)))
		"positive":
			button.add_theme_stylebox_override("normal", _style_box(Color("047857"), Color("34d399"), 16, 1, padding))
			button.add_theme_stylebox_override("hover", _style_box(Color("059669"), Color("6ee7b7"), 16, 2, padding))
			button.add_theme_stylebox_override("pressed", _style_box(Color("065f46"), Color("34d399"), 16, 2, padding))
		"warning":
			button.add_theme_stylebox_override("normal", _style_box(Color("3a2d18"), Color("d6a739"), 16, 1, padding))
			button.add_theme_stylebox_override("hover", _style_box(Color("4a381b"), COLOR_WARNING, 16, 2, padding))
			button.add_theme_stylebox_override("pressed", _style_box(Color("2e2415"), COLOR_WARNING, 16, 2, padding))
		"quiet":
			button.add_theme_stylebox_override("normal", _style_box(Color.TRANSPARENT, Color.TRANSPARENT, 14, 0, padding))
			button.add_theme_stylebox_override("hover", _style_box(COLOR_SURFACE_ALT, COLOR_BORDER, 14, 1, padding))
			button.add_theme_stylebox_override("pressed", _style_box(Color("172238"), COLOR_BORDER, 14, 1, padding))
			button.add_theme_color_override("font_color", COLOR_TEXT_MUTED)
		_:
			button.add_theme_stylebox_override("normal", _style_box(COLOR_SURFACE_ALT, COLOR_BORDER, 16, 1, padding))
			button.add_theme_stylebox_override("hover", _style_box(COLOR_SURFACE_HOVER, COLOR_FOCUS, 16, 1, padding))
			button.add_theme_stylebox_override("pressed", _style_box(Color("172238"), COLOR_FOCUS, 16, 2, padding))


static func enable_button_text_fit(button: Button, minimum_font_size: int = 18) -> void:
	if button == null or button.has_meta("text_fit_enabled"):
		return
	button.set_meta("text_fit_enabled", true)
	button.set_meta("text_fit_minimum", minimum_font_size)
	button.autowrap_mode = TextServer.AUTOWRAP_OFF
	button.clip_text = true
	button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	button.resized.connect(func() -> void: _fit_button_text(button))


static func _fit_button_text(button: Button) -> void:
	if button == null or button.text.is_empty() or button.size.x <= 0.0:
		return
	var current_size := button.get_theme_font_size("font_size")
	var base_size := maxi(current_size, int(button.get_meta("text_fit_base", current_size)))
	button.set_meta("text_fit_base", base_size)
	var minimum_size := maxi(int(button.get_meta("text_fit_minimum", 18)), int(round(base_size * 0.72)))
	var stylebox := button.get_theme_stylebox("normal")
	var available_width := button.size.x - stylebox.get_margin(SIDE_LEFT) - stylebox.get_margin(SIDE_RIGHT)
	if button.icon != null:
		available_width -= button.icon.get_width() + button.get_theme_constant("h_separation")
	var font := button.get_theme_font("font")
	if font == null or available_width <= 0.0:
		return
	var fitted_size := base_size
	while fitted_size > minimum_size and font.get_string_size(button.text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, fitted_size).x > available_width:
		fitted_size -= 1
	button.add_theme_font_size_override("font_size", fitted_size)

static func style_option_button(button: OptionButton) -> void:
	if button == null:
		return
	style_button(button, "secondary")
	button.add_theme_color_override("font_color", COLOR_TEXT)
	button.add_theme_color_override("font_hover_color", COLOR_TEXT)
	var popup := button.get_popup()
	if popup != null:
		popup.add_theme_color_override("font_color", COLOR_TEXT)
		popup.add_theme_color_override("font_hover_color", COLOR_TEXT)

static func add_card(parent: Control, emphasized: bool = false) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var border := COLOR_FOCUS if emphasized else COLOR_BORDER
	panel.add_theme_stylebox_override("panel", _style_box(COLOR_SURFACE, border, 22, 1, int(round(20.0 * visual_ui_scale(parent)))))
	parent.add_child(panel)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", int(round(12.0 * visual_ui_scale(parent))))
	panel.add_child(content)
	return content

static func add_section_label(parent: Control, text: String) -> Label:
	var label := Label.new()
	label.text = text.to_upper()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.add_theme_color_override("font_color", COLOR_TEXT_MUTED)
	label.add_theme_font_size_override("font_size", int(round(20.0 * visual_ui_scale(parent))))
	parent.add_child(label)
	return label

static func configure_large_dialog(dialog: AcceptDialog, parent: Control, title_text: String, close_text: String = "Close") -> float:
	var scale := dialog_ui_scale(parent)
	var viewport_size := parent.get_viewport_rect().size if parent != null else BASE_VIEWPORT
	var min_size := Vector2(
		max(760.0 * scale, viewport_size.x * MIN_DIALOG_SIZE_RATIO.x),
		max(520.0 * scale, viewport_size.y * MIN_DIALOG_SIZE_RATIO.y)
	)
	dialog.title = title_text
	dialog.ok_button_text = close_text
	dialog.min_size = min_size
	dialog.borderless = true
	dialog.unresizable = true
	dialog.exclusive = true
	dialog.close_requested.connect(dialog.queue_free)
	dialog.confirmed.connect(dialog.queue_free)

	var ok_button := dialog.get_ok_button()
	ok_button.custom_minimum_size = Vector2(0, MIN_DIALOG_BUTTON_HEIGHT * scale)
	ok_button.add_theme_font_size_override("font_size", int(round(40.0 * scale)))
	return scale

static func is_valid_web_url(url: String) -> bool:
	var clean_url := url.strip_edges()
	var separator_index := clean_url.find("://")
	if separator_index <= 0:
		return false

	var scheme := clean_url.substr(0, separator_index).to_lower()
	if scheme != "https" and scheme != "http":
		return false

	var host_start := separator_index + 3
	if host_start >= clean_url.length():
		return false

	var host_end := clean_url.find("/", host_start)
	var host := clean_url.substr(host_start) if host_end == -1 else clean_url.substr(host_start, host_end - host_start)
	return not host.strip_edges().is_empty()

static func add_dialog_header(parent: Control, title_text: String, close_callback: Callable, scale: float) -> void:
	var header := HBoxContainer.new()
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_theme_constant_override("separation", int(round(18.0 * scale)))
	parent.add_child(header)

	var title := Label.new()
	title.text = title_text
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size", int(round(44.0 * scale)))
	header.add_child(title)

	var close_button := Button.new()
	close_button.text = "X"
	close_button.custom_minimum_size = Vector2(104.0 * scale, 104.0 * scale)
	close_button.add_theme_font_size_override("font_size", int(round(48.0 * scale)))
	close_button.pressed.connect(close_callback)
	header.add_child(close_button)

static func setup_root(root: Control, background: Color = COLOR_BACKGROUND) -> VBoxContainer:
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	root.theme = _make_app_theme(root)
	var scale := _ui_scale(root)

	var background_rect := ColorRect.new()
	background_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background_rect.color = background
	root.add_child(background_rect)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var margin_size := int(round(24.0 * scale))
	margin.set_meta("screen_builder_base_margin", margin_size)
	root.add_child(margin)
	_apply_safe_area_margins(root, margin)
	root.resized.connect(_apply_safe_area_margins.bind(root, margin))

	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(panel)
	panel.add_theme_stylebox_override("panel", _style_box(Color("101a2a"), Color("24324a"), 22, 1, int(round(20.0 * visual_ui_scale(root)))))

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", int(round(16.0 * scale)))
	panel.add_child(content)
	root.set_meta("screen_builder_content", content)

	return content

static func set_root_margin(root: Control, margin: MarginContainer, base_margin: int) -> void:
	if root == null or margin == null:
		return
	margin.set_meta("screen_builder_base_margin", max(0, base_margin))
	_apply_safe_area_margins(root, margin)

static func _apply_safe_area_margins(root: Control, margin: MarginContainer) -> void:
	if root == null or margin == null:
		return
	var base_margin := int(margin.get_meta("screen_builder_base_margin", 0))
	var safe_left := 0.0
	var safe_top := 0.0
	var safe_right := 0.0
	var safe_bottom := 0.0
	if OS.get_name() in ["Android", "iOS"]:
		var safe_area := DisplayServer.get_display_safe_area()
		var window_size := DisplayServer.window_get_size()
		var viewport_size := root.get_viewport_rect().size
		if window_size.x > 0 and window_size.y > 0 and safe_area.size.x > 0 and safe_area.size.y > 0:
			var scale_x := viewport_size.x / float(window_size.x)
			var scale_y := viewport_size.y / float(window_size.y)
			safe_left = max(0.0, float(safe_area.position.x) * scale_x)
			safe_top = max(0.0, float(safe_area.position.y) * scale_y)
			safe_right = max(0.0, float(window_size.x - safe_area.end.x) * scale_x)
			safe_bottom = max(0.0, float(window_size.y - safe_area.end.y) * scale_y)
	margin.add_theme_constant_override("margin_left", base_margin + int(ceil(safe_left)))
	margin.add_theme_constant_override("margin_top", base_margin + int(ceil(safe_top)))
	margin.add_theme_constant_override("margin_right", base_margin + int(ceil(safe_right)))
	margin.add_theme_constant_override("margin_bottom", base_margin + int(ceil(safe_bottom)))

static func get_bottom_ad_reserve_height(control: Control) -> int:
	if control == null:
		return 0

	return AppAds.get_reserved_banner_height()

static func add_bottom_ad_reserve(root: Control, hide_when_banner_loaded: bool = true, placement: String = "none") -> TextureRect:
	AppAds.set_banner_placement(placement)
	var reserve: Control = null
	if root.has_meta("screen_builder_content"):
		var root_content: Variant = root.get_meta("screen_builder_content")
		if root_content is VBoxContainer:
			reserve = Control.new()
			reserve.name = "BottomAdReserve"
			reserve.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			(root_content as VBoxContainer).add_child(reserve)
			_update_ad_spacer(root, reserve)
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
			if is_instance_valid(reserve):
				_update_ad_spacer(root, reserve)
		)
		AppAds.banner_failed.connect(func(_error: String) -> void:
			if is_instance_valid(banner):
				banner.visible = false
			if is_instance_valid(reserve):
				_update_ad_spacer(root, reserve)
		)
		AppAds.banner_hidden.connect(func() -> void:
			if is_instance_valid(banner):
				banner.visible = false
			if is_instance_valid(reserve):
				_update_ad_spacer(root, reserve)
		)
	root.resized.connect(func() -> void:
		if is_instance_valid(banner):
			_update_bottom_ad_reserve_rect(root, banner)
		if is_instance_valid(reserve):
			_update_ad_spacer(root, reserve)
	)
	root.add_child(banner)
	return banner

static func _update_ad_spacer(root: Control, reserve: Control) -> void:
	reserve.custom_minimum_size = Vector2(0.0, get_bottom_ad_reserve_height(root))

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

static func open_source_url(url: String) -> void:
	url = url.strip_edges()
	if url.is_empty() or not is_valid_web_url(url):
		return

	var error := OS.shell_open(url)
	if error != OK:
		push_warning("Could not open official source URL: %s" % url)

static func add_title(parent: Control, text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", COLOR_TEXT)
	label.add_theme_font_size_override("font_size", int(round(38.0 * visual_ui_scale(parent))))
	parent.add_child(label)
	return label

static func add_subtitle(parent: Control, text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", COLOR_TEXT_MUTED)
	label.add_theme_font_size_override("font_size", int(round(25.0 * visual_ui_scale(parent))))
	parent.add_child(label)
	return label

static func add_body(parent: Control, text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_color_override("font_color", COLOR_TEXT_MUTED)
	label.add_theme_font_size_override("font_size", int(round(23.0 * visual_ui_scale(parent))))
	parent.add_child(label)
	return label

static func add_button(parent: Control, text: String, variant: String = "secondary") -> Button:
	var button := Button.new()
	button.text = text
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button.custom_minimum_size = Vector2(0.0, 96.0 * visual_ui_scale(parent))
	parent.add_child(button)
	style_button(button, variant)
	return button

static func add_spacer(parent: Container, height: float = 8.0) -> Control:
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0.0, height)
	parent.add_child(spacer)
	return spacer

static func add_scroll_content(parent: VBoxContainer, max_width: float = 0.0) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	parent.add_child(scroll)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	if max_width > 0.0:
		var viewport_width := parent.get_viewport_rect().size.x
		content.custom_minimum_size.x = min(max_width * visual_ui_scale(parent), max(0.0, viewport_width - 72.0))
		content.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	content.add_theme_constant_override("separation", int(round(12.0 * _ui_scale(parent))))
	scroll.add_child(content)
	return content
