extends Control

var _title_label: Label
var _denomination_label: Label
var _currency_label: Label
var _summary_label: Label
var _watermark_label: Label
var _source_label: Label
var _source_button: Button
var _features_title: Label
var _feature_box: VBoxContainer
var _artwork_holder: Control
var _status_label: Label
var _margin: MarginContainer
var _preview: PanelContainer
var _root: VBoxContainer
var _preview_box: VBoxContainer
var _artwork_max_size: Vector2 = Vector2.ZERO
var _body_font_size := 28
var _nav_buttons: Array[Button] = []


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	_apply_layout()
	_refresh()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_apply_layout()


func _build_ui() -> void:
	var background := ColorRect.new()
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.color = Color("101010")
	add_child(background)

	_margin = MarginContainer.new()
	_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_margin)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_margin.add_child(scroll)

	_root = VBoxContainer.new()
	_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_root.add_theme_constant_override("separation", 14)
	scroll.add_child(_root)
	ScreenBuilder.enable_touch_scroll(scroll, _root)

	var bar := HBoxContainer.new()
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.add_theme_constant_override("separation", 12)
	_root.add_child(bar)

	var back := Button.new()
	back.text = AppState.t("back")
	back.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/CurrencyInfo.tscn")
	)
	_nav_buttons.append(back)
	bar.add_child(back)

	var prev := Button.new()
	prev.text = AppState.t("previous")
	prev.pressed.connect(_select_previous)
	_nav_buttons.append(prev)
	bar.add_child(prev)

	var next := Button.new()
	next.text = AppState.t("next")
	next.pressed.connect(_select_next)
	_nav_buttons.append(next)
	bar.add_child(next)

	_title_label = Label.new()
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 32)
	_root.add_child(_title_label)

	_preview = PanelContainer.new()
	_preview.custom_minimum_size = Vector2(0, 380)
	_preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_root.add_child(_preview)

	_preview_box = VBoxContainer.new()
	_preview_box.alignment = BoxContainer.ALIGNMENT_CENTER
	_preview_box.add_theme_constant_override("separation", 10)
	_preview.add_child(_preview_box)

	_artwork_holder = Control.new()
	_artwork_holder.custom_minimum_size = Vector2(0, 240)
	_artwork_holder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_artwork_holder.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_artwork_holder.clip_contents = true
	_preview_box.add_child(_artwork_holder)

	_denomination_label = Label.new()
	_denomination_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_denomination_label.add_theme_font_size_override("font_size", 40)
	_preview_box.add_child(_denomination_label)

	_currency_label = Label.new()
	_currency_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_preview_box.add_child(_currency_label)

	_summary_label = Label.new()
	_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_preview_box.add_child(_summary_label)

	_watermark_label = Label.new()
	_watermark_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_watermark_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_preview_box.add_child(_watermark_label)

	_source_label = Label.new()
	_source_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_source_label.modulate = Color(0.75, 0.85, 1.0)
	_preview_box.add_child(_source_label)

	_source_button = Button.new()
	_source_button.text = AppState.t("open_official_source")
	_source_button.pressed.connect(_open_source)
	_preview_box.add_child(_source_button)

	_features_title = Label.new()
	_features_title.text = AppState.t("security_features")
	_features_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_features_title.add_theme_font_size_override("font_size", 22)
	_preview_box.add_child(_features_title)

	_feature_box = VBoxContainer.new()
	_feature_box.add_theme_constant_override("separation", 8)
	_preview_box.add_child(_feature_box)

	_status_label = Label.new()
	_status_label.text = AppState.t("note_viewer_status")
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_root.add_child(_status_label)


func _apply_layout() -> void:
	if _margin == null or _preview == null:
		return

	var viewport_size := get_viewport_rect().size
	var compact := viewport_size.x < 720.0 or viewport_size.y < 960.0
	var margin_size := 18 if compact else 34
	var bottom_margin := margin_size + ScreenBuilder.get_bottom_ad_reserve_height(self)
	var title_size := 34 if compact else 50
	var denomination_size := 42 if compact else 60
	var currency_size := 28 if compact else 38
	_body_font_size = 26 if compact else 34
	var button_font_size := 26 if compact else 34
	var button_height := 88 if compact else 112
	var feature_title_size := 30 if compact else 40
	var status_size := 25 if compact else 32
	var preview_height := 620 if compact else 900
	var artwork_height := 380 if compact else 610
	var separation := 14 if compact else 22
	var preview_separation := 14 if compact else 18
	var align := HORIZONTAL_ALIGNMENT_LEFT if compact else HORIZONTAL_ALIGNMENT_CENTER
	_artwork_max_size = Vector2(viewport_size.x - float(margin_size * 2), float(artwork_height))

	_margin.add_theme_constant_override("margin_left", margin_size)
	_margin.add_theme_constant_override("margin_top", margin_size)
	_margin.add_theme_constant_override("margin_right", margin_size)
	_margin.add_theme_constant_override("margin_bottom", bottom_margin)
	_root.add_theme_constant_override("separation", separation)
	_preview.custom_minimum_size = Vector2(0, preview_height)
	_preview_box.add_theme_constant_override("separation", preview_separation)
	_artwork_holder.custom_minimum_size = Vector2(0, artwork_height)
	_title_label.add_theme_font_size_override("font_size", title_size)
	_denomination_label.add_theme_font_size_override("font_size", denomination_size)
	_currency_label.add_theme_font_size_override("font_size", currency_size)
	_summary_label.add_theme_font_size_override("font_size", _body_font_size)
	_watermark_label.add_theme_font_size_override("font_size", _body_font_size)
	_source_label.add_theme_font_size_override("font_size", _body_font_size)
	_features_title.add_theme_font_size_override("font_size", feature_title_size)
	_summary_label.horizontal_alignment = align
	_watermark_label.horizontal_alignment = align
	_source_label.horizontal_alignment = align
	_source_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_source_button.custom_minimum_size = Vector2(0, button_height)
	_source_button.add_theme_font_size_override("font_size", button_font_size)
	_status_label.horizontal_alignment = align
	_status_label.add_theme_font_size_override("font_size", status_size)

	for button in _nav_buttons:
		button.custom_minimum_size = Vector2(0, button_height)
		button.add_theme_font_size_override("font_size", button_font_size)

	if not has_node("BottomAdFallback"):
		ScreenBuilder.add_bottom_ad_reserve(self)

	for child in _feature_box.get_children():
		if child is Label:
			(child as Label).horizontal_alignment = align
			(child as Label).add_theme_font_size_override("font_size", _body_font_size)


func _refresh() -> void:
	var note := AppState.get_selected_note()
	if note.is_empty():
		_title_label.text = AppState.t("no_note_selected")
		_denomination_label.text = ""
		_currency_label.text = ""
		_summary_label.text = ""
		_watermark_label.text = ""
		_source_label.text = ""
		_source_button.visible = false
		_clear_features()
		_set_artwork(_load_texture("res://assets/ui/appsimplelogo.jpg"))
		return

	_title_label.text = AppState.get_note_title(note)
	_denomination_label.text = AppState.get_note_badge(note)
	_currency_label.text = AppState.t("country_prefix") % AppState.get_country_label(str(note.get("country", "")))
	_summary_label.text = AppState.get_note_summary(note)
	_watermark_label.text = AppState.t("watermark_prefix") % AppState.get_note_watermark(note)

	var source := AppState.get_note_source(note)
	_source_label.text = "" if source.is_empty() else AppState.t("source_prefix") % source
	var source_url := AppState.get_note_source_url(note)
	_source_button.visible = ScreenBuilder.is_valid_web_url(source_url)

	_clear_features()
	var features := AppState.get_note_features(note)
	for feature in features:
		var bullet := Label.new()
		bullet.text = "- %s" % feature
		bullet.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		bullet.add_theme_font_size_override("font_size", _body_font_size)
		_feature_box.add_child(bullet)

	var texture := _load_note_texture(note)
	if texture != null:
		_set_artwork(texture)
	else:
		_set_artwork(_build_fallback_artwork(note))


func _clear_features() -> void:
	for child in _feature_box.get_children():
		child.queue_free()


func _set_artwork(content: Variant) -> void:
	for child in _artwork_holder.get_children():
		child.queue_free()
	if content is Texture2D:
		var texture := content as Texture2D
		var image := TextureRect.new()
		image.set_anchors_preset(Control.PRESET_FULL_RECT)
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		image.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		image.size_flags_vertical = Control.SIZE_EXPAND_FILL
		image.custom_minimum_size = _cap_texture_size(texture, _artwork_max_size)
		image.texture = texture
		_artwork_holder.add_child(image)
	elif content is Node:
		if content is Control:
			(content as Control).set_anchors_preset(Control.PRESET_FULL_RECT)
		_artwork_holder.add_child(content)


func _build_fallback_artwork(note: Dictionary) -> Control:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.custom_minimum_size = _artwork_holder.custom_minimum_size
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = AppState.get_country_accent_color(str(note.get("country", "")))
	root.add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	root.add_child(margin)

	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 8)
	margin.add_child(col)

	var country := Label.new()
	country.text = AppState.get_country_label(str(note.get("country", "")))
	country.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	country.add_theme_font_size_override("font_size", 34)
	col.add_child(country)

	var denom := Label.new()
	denom.text = AppState.get_note_badge(note)
	denom.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	denom.add_theme_font_size_override("font_size", 48)
	col.add_child(denom)

	var hint := Label.new()
	hint.text = AppState.t("thumbnail_preview")
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 28)
	hint.modulate = Color(1, 1, 1, 0.8)
	col.add_child(hint)

	return root


func _select_previous() -> void:
	AppState.set_selected_note_index(AppState.selected_note_index - 1)
	_refresh()


func _select_next() -> void:
	AppState.set_selected_note_index(AppState.selected_note_index + 1)
	_refresh()


func _open_source() -> void:
	var note := AppState.get_selected_note()
	if note.is_empty():
		return

	var source_url := AppState.get_note_source_url(note)
	if ScreenBuilder.is_valid_web_url(source_url):
		ScreenBuilder.open_source_url(source_url)


func _cap_texture_size(texture: Texture2D, max_size: Vector2) -> Vector2:
	if texture == null:
		return max_size

	var source_size := Vector2(texture.get_width(), texture.get_height())
	if source_size.x <= 0.0 or source_size.y <= 0.0:
		return max_size

	var scale: float = min(1.0, min(max_size.x / source_size.x, max_size.y / source_size.y))
	return source_size * scale


func _load_texture(texture_path: String) -> Texture2D:
	if texture_path.is_empty():
		return null

	if ResourceLoader.exists(texture_path):
		var resource := ResourceLoader.load(texture_path)
		if resource is Texture2D:
			return resource as Texture2D

	var image := Image.new()
	var error := image.load(texture_path)
	if error == OK:
		return ImageTexture.create_from_image(image)

	return null


func _load_note_texture(note: Dictionary) -> Texture2D:
	var texture_path := AppState.get_note_texture_path(note)
	return _load_texture(texture_path)
