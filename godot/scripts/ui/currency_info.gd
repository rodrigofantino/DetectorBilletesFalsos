extends Control


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()


func _build_ui() -> void:
	var background := ColorRect.new()
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.color = Color("0f172a")
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

	var back := Button.new()
	back.text = AppState.t("back")
	back.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/CountrySelect.tscn")
	)
	root.add_child(back)

	var title := Label.new()
	title.text = AppState.t("currency_info_title")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	root.add_child(title)

	var country := Label.new()
	country.text = AppState.t("country_prefix") % AppState.get_country_label(AppState.selected_country)
	country.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(country)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(scroll)

	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 14)
	scroll.add_child(list)

	var notes := AppState.get_selected_notes()
	if notes.is_empty():
		var empty := Label.new()
		empty.text = AppState.t("no_notes_found")
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		list.add_child(empty)
		return

	for i in notes.size():
		var note := notes[i]
		var card := PanelContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		card.add_child(row)

		row.add_child(_build_thumbnail(note))

		var inner := VBoxContainer.new()
		inner.add_theme_constant_override("separation", 8)
		inner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(inner)

		var header := Label.new()
		header.text = AppState.get_note_badge(note)
		header.add_theme_font_size_override("font_size", 24)
		inner.add_child(header)

		var summary := Label.new()
		summary.text = AppState.get_note_summary(note)
		summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		inner.add_child(summary)

		var watermark := Label.new()
		watermark.text = AppState.t("watermark_prefix") % AppState.get_note_watermark(note)
		watermark.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		inner.add_child(watermark)

		var source := AppState.get_note_source(note)
		if not source.is_empty():
			var source_label := Label.new()
			source_label.text = AppState.t("source_prefix") % source
			source_label.modulate = Color(0.75, 0.85, 1.0)
			inner.add_child(source_label)

			var source_url := AppState.get_note_source_url(note)
			if not source_url.is_empty():
				var source_button := Button.new()
				source_button.text = AppState.t("open_official_source")
				source_button.pressed.connect(_open_source.bind(source_url))
				inner.add_child(source_button)

		var features := AppState.get_note_features(note)
		if not features.is_empty():
			var features_title := Label.new()
			features_title.text = AppState.t("security_features")
			features_title.add_theme_font_size_override("font_size", 18)
			inner.add_child(features_title)

			for feature in features:
				var bullet := Label.new()
				bullet.text = "- %s" % feature
				bullet.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				inner.add_child(bullet)

		var open := Button.new()
		open.text = AppState.t("open_note_viewer")
		open.pressed.connect(_open_note.bind(i))
		inner.add_child(open)

		list.add_child(card)


func _open_note(index: int) -> void:
	AppState.set_selected_note_index(index)
	get_tree().change_scene_to_file("res://scenes/BillViewer.tscn")


func _open_source(url: String) -> void:
	if not url.is_empty():
		OS.shell_open(url)


func _build_thumbnail(note: Dictionary) -> Control:
	var texture := _load_note_texture(note)
	if texture != null:
		var image := TextureRect.new()
		image.custom_minimum_size = Vector2(112, 112)
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		image.texture = texture
		return image

	var thumb := Control.new()
	thumb.custom_minimum_size = Vector2(112, 112)

	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = AppState.get_country_accent_color(str(note.get("country", "")))
	thumb.add_child(bg)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	thumb.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_bottom", 6)
	panel.add_child(margin)

	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 4)
	margin.add_child(col)

	var country := Label.new()
	country.text = AppState.get_country_label(str(note.get("country", "")))
	country.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	country.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	country.add_theme_font_size_override("font_size", 12)
	col.add_child(country)

	var denom := Label.new()
	denom.text = AppState.get_note_badge(note)
	denom.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	denom.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	denom.add_theme_font_size_override("font_size", 18)
	col.add_child(denom)

	var hint := Label.new()
	hint.text = AppState.t("thumbnail")
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 10)
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
	if texture_path.is_empty() or not ResourceLoader.exists(texture_path):
		return null

	var resource := ResourceLoader.load(texture_path)
	if resource is Texture2D:
		return resource as Texture2D
	return null
