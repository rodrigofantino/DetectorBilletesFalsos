extends Control


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	theme = ScreenBuilder._make_app_theme(self)
	_build_ui()


func _build_ui() -> void:
	var ui_scale := ScreenBuilder.readable_ui_scale(self)
	var margin_size := int(round(30.0 * ui_scale))
	var bottom_margin := margin_size + ScreenBuilder.get_bottom_ad_reserve_height(self)
	var button_height := int(round(124.0 * ui_scale))
	var button_font := int(round(32.0 * ui_scale))
	var title_font := int(round(50.0 * ui_scale))
	var body_font := int(round(27.0 * ui_scale))
	var header_font := int(round(34.0 * ui_scale))
	var section_font := int(round(30.0 * ui_scale))
	var card_padding := int(round(18.0 * ui_scale))

	var background := ColorRect.new()
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.color = Color("0f172a")
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
	root.add_theme_constant_override("separation", int(round(22.0 * ui_scale)))
	margin.add_child(root)

	var title := Label.new()
	title.text = AppState.t("currency_info_title")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size", title_font)
	root.add_child(title)

	var country := Label.new()
	country.text = AppState.t("country_prefix") % AppState.get_country_label(AppState.selected_country)
	country.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	country.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	country.add_theme_font_size_override("font_size", body_font)
	root.add_child(country)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(scroll)

	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", int(round(22.0 * ui_scale)))
	scroll.add_child(list)

	var notes := AppState.get_selected_notes()
	if notes.is_empty():
		var empty := Label.new()
		empty.text = AppState.t("no_notes_found")
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty.add_theme_font_size_override("font_size", body_font)
		list.add_child(empty)
		return

	for i in notes.size():
		var note := notes[i]
		var card := PanelContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var card_margin := MarginContainer.new()
		card_margin.add_theme_constant_override("margin_left", card_padding)
		card_margin.add_theme_constant_override("margin_top", card_padding)
		card_margin.add_theme_constant_override("margin_right", card_padding)
		card_margin.add_theme_constant_override("margin_bottom", card_padding)
		card.add_child(card_margin)

		var inner := VBoxContainer.new()
		inner.add_theme_constant_override("separation", int(round(14.0 * ui_scale)))
		inner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card_margin.add_child(inner)

		var header := Label.new()
		header.text = AppState.get_note_badge(note)
		header.add_theme_font_size_override("font_size", header_font)
		header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		inner.add_child(header)
		inner.add_child(_build_thumbnail(note, ui_scale))

		var summary := Label.new()
		summary.text = AppState.get_note_summary(note)
		summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		summary.add_theme_font_size_override("font_size", body_font)
		inner.add_child(summary)

		var watermark := Label.new()
		watermark.text = AppState.t("watermark_prefix") % AppState.get_note_watermark(note)
		watermark.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		watermark.add_theme_font_size_override("font_size", body_font)
		inner.add_child(watermark)

		var source_url := AppState.get_note_source_url(note)
		var source := AppState.get_note_source(note)
		if not source.is_empty():
			var source_label := Label.new()
			source_label.text = AppState.t("source_prefix") % source
			source_label.modulate = Color(0.75, 0.85, 1.0)
			source_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			source_label.add_theme_font_size_override("font_size", body_font)
			inner.add_child(source_label)


		var features := AppState.get_note_features(note)
		if not features.is_empty():
			var features_title := Label.new()
			features_title.text = AppState.t("security_features")
			features_title.add_theme_font_size_override("font_size", section_font)
			inner.add_child(features_title)

			for feature in features:
				var bullet := Label.new()
				bullet.text = "- %s" % feature
				bullet.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				bullet.add_theme_font_size_override("font_size", body_font)
				inner.add_child(bullet)

		var actions := HBoxContainer.new()
		actions.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		actions.add_theme_constant_override("separation", int(round(14.0 * ui_scale)))
		inner.add_child(actions)
		if ScreenBuilder.is_valid_web_url(source_url):
			var source_button := Button.new()
			source_button.text = AppState.t("open_official_source")
			source_button.custom_minimum_size = Vector2(0, button_height)
			source_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			source_button.add_theme_font_size_override("font_size", button_font)
			ScreenBuilder.style_button(source_button, "secondary")
			source_button.pressed.connect(_open_source.bind(source_url))
			actions.add_child(source_button)
		var open := Button.new()
		open.text = AppState.t("show_banknote")
		open.custom_minimum_size = Vector2(0, button_height)
		open.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		open.add_theme_font_size_override("font_size", button_font)
		ScreenBuilder.style_button(open, "secondary")
		open.pressed.connect(_open_note.bind(i))
		actions.add_child(open)

		list.add_child(card)
		if i < notes.size() - 1:
			var separator := HSeparator.new()
			separator.add_theme_constant_override("separation", int(round(12.0 * ui_scale)))
			list.add_child(separator)

	ScreenBuilder.enable_touch_scroll(scroll, list)
	var back := Button.new()
	back.text = AppState.t("back")
	back.custom_minimum_size = Vector2(0, button_height)
	back.add_theme_font_size_override("font_size", button_font)
	ScreenBuilder.style_button(back, "secondary")
	back.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/CountrySelect.tscn")
	)
	root.add_child(back)
	set_meta("screen_builder_content", root)
	ScreenBuilder.add_bottom_ad_reserve(self, true, AppAds.PLACEMENT_CURRENCY_INFO)


func _open_note(index: int) -> void:
	AppState.set_selected_note_index(index)
	get_tree().change_scene_to_file("res://scenes/BillViewer.tscn")


func _open_source(url: String) -> void:
	if ScreenBuilder.is_valid_web_url(url):
		ScreenBuilder.open_source_url(url)


func _build_thumbnail(note: Dictionary, ui_scale: float) -> Control:
	var thumb_width := int(round(720.0 * ui_scale))
	var thumb_height := int(round(360.0 * ui_scale))
	var texture := _load_note_texture(note)
	if texture != null:
		var image := TextureRect.new()
		image.custom_minimum_size = Vector2(thumb_width, thumb_height)
		image.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		image.texture = texture
		return image

	var thumb := Control.new()
	thumb.custom_minimum_size = Vector2(thumb_width, thumb_height)

	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = AppState.get_country_accent_color(str(note.get("country", "")))
	thumb.add_child(bg)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	thumb.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", int(round(10.0 * ui_scale)))
	margin.add_theme_constant_override("margin_top", int(round(10.0 * ui_scale)))
	margin.add_theme_constant_override("margin_right", int(round(10.0 * ui_scale)))
	margin.add_theme_constant_override("margin_bottom", int(round(10.0 * ui_scale)))
	panel.add_child(margin)

	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", int(round(6.0 * ui_scale)))
	margin.add_child(col)

	var country := Label.new()
	country.text = AppState.get_country_label(str(note.get("country", "")))
	country.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	country.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	country.add_theme_font_size_override("font_size", int(round(32.0 * ui_scale)))
	col.add_child(country)

	var denom := Label.new()
	denom.text = AppState.get_note_badge(note)
	denom.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	denom.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	denom.add_theme_font_size_override("font_size", int(round(42.0 * ui_scale)))
	col.add_child(denom)

	var hint := Label.new()
	hint.text = AppState.t("thumbnail")
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", int(round(28.0 * ui_scale)))
	hint.modulate = Color(0.95, 0.95, 0.95, 0.8)
	col.add_child(hint)

	return thumb


func _cap_texture_size(texture: Texture2D, max_size: Vector2) -> Vector2:
	if texture == null:
		return max_size

	var source_size := Vector2(texture.get_width(), texture.get_height())
	if source_size.x <= 0.0 or source_size.y <= 0.0:
		return max_size

	var scale: float = min(1.0, min(max_size.x / source_size.x, max_size.y / source_size.y))
	return source_size * scale


func _load_note_texture(note: Dictionary) -> Texture2D:
	var texture_path := AppState.get_note_texture_path(note)
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
