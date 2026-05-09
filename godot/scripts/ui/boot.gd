extends Control


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	if OS.has_feature("android") or OS.has_feature("Android"):
		var window := get_window()
		if window != null:
			window.mode = Window.MODE_FULLSCREEN

	var background := ColorRect.new()
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.color = Color("07111f")
	add_child(background)
	ScreenBuilder.add_bottom_ad_reserve(self)

	var layout := CenterContainer.new()
	layout.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(layout)

	var panel := VBoxContainer.new()
	panel.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_theme_constant_override("separation", 14)
	layout.add_child(panel)

	var title := Label.new()
	title.text = AppState.t("app_title")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 42)
	panel.add_child(title)

	var subtitle := Label.new()
	subtitle.text = AppState.t("boot_subtitle")
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(subtitle)

	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
