extends Control

const UV_SCENE := "res://scenes/UvDetector.tscn"
const WATERMARK_SCENE := "res://scenes/WatermarkViewer.tscn"
const COUNTRY_SCENE := "res://scenes/CountrySelect.tscn"
const BILL_SCENE := "res://scenes/BillViewer.tscn"
const REVIEW_SETUP_SCENE := "res://scenes/ReviewSetup.tscn"
const REVIEW_LIBRARY_SCENE := "res://scenes/ReviewLibrary.tscn"
const BASE_VIEWPORT := Vector2(1080.0, 1920.0)

var _title_label: Label
var _subtitle_label: Label
var _language_label: Label
var _icon: TextureRect
var _language_select: OptionButton
var _language_row: HBoxContainer
var _action_buttons: Array[Button] = []
var _layout_root: VBoxContainer
var _button_rows: Array[Container] = []


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	resized.connect(_apply_responsive_layout)
	_apply_responsive_layout()
	call_deferred("_maybe_request_analytics_consent")


func _build_ui() -> void:
	var root: VBoxContainer = ScreenBuilder.setup_root(self, ScreenBuilder.COLOR_BACKGROUND)
	_layout_root = ScreenBuilder.add_scroll_content(root, 900.0)
	_layout_root.add_theme_constant_override("separation", 22)

	var header_card := ScreenBuilder.add_card(_layout_root)

	var header := HBoxContainer.new()
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_theme_constant_override("separation", 16)
	header_card.add_child(header)

	_icon = TextureRect.new()
	_icon.texture = load("res://assets/ui/ic_launcher.png")
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	header.add_child(_icon)

	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.add_theme_constant_override("separation", 8)
	header.add_child(text_box)

	_title_label = Label.new()
	_title_label.text = AppState.t("app_title")
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_box.add_child(_title_label)

	_subtitle_label = Label.new()
	_subtitle_label.text = AppState.t("menu_subtitle")
	_subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_subtitle_label.add_theme_color_override("font_color", ScreenBuilder.COLOR_TEXT_MUTED)
	text_box.add_child(_subtitle_label)

	_language_row = HBoxContainer.new()
	_language_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_language_row.add_theme_constant_override("separation", 12)
	text_box.add_child(_language_row)

	_language_label = Label.new()
	_language_label.custom_minimum_size = Vector2(120, 0)
	_language_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_language_row.add_child(_language_label)

	_language_select = OptionButton.new()
	_language_select.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_populate_language_options(_language_select)
	_language_select.item_selected.connect(_on_language_selected.bind(_language_select))
	_language_row.add_child(_language_select)
	ScreenBuilder.style_option_button(_language_select)

	var primary := _add_menu_button(
		_layout_root,
		AppState.t("menu_guided_review"),
		Callable(self, "_open_guided_review"),
		"primary"
	)
	primary.set_meta("menu_size", "primary")
	var cta_hint := ScreenBuilder.add_body(_layout_root, AppState.t("menu_review_hint"))
	cta_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	if not ReviewHistoryStore.get_recents().is_empty() or not ReviewHistoryStore.get_favorites().is_empty():
		ScreenBuilder.add_section_label(_layout_root, AppState.t("menu_continue"))
		_add_menu_button(
			_layout_root,
			AppState.t("menu_library"),
			Callable(self, "_open_review_library"),
			"secondary"
		)

	ScreenBuilder.add_section_label(_layout_root, AppState.t("menu_quick_tools"))
	var tools_grid := _add_action_grid(_layout_root)
	_add_menu_button(
		tools_grid,
		AppState.t("menu_uv"),
		Callable(self, "_open_uv"),
		"secondary"
	)
	_add_menu_button(
		tools_grid,
		AppState.t("menu_watermark"),
		Callable(self, "_open_watermark"),
		"secondary"
	)

	ScreenBuilder.add_section_label(_layout_root, AppState.t("menu_explore"))
	var explore_grid := _add_action_grid(_layout_root)
	_add_menu_button(
		explore_grid,
		AppState.t("menu_currency"),
		Callable(self, "_open_countries"),
		"secondary"
	)
	_add_menu_button(
		explore_grid,
		AppState.t("menu_about"),
		Callable(self, "_show_about"),
		"secondary",
		false
	)

	ScreenBuilder.add_section_label(_layout_root, AppState.t("menu_more"))
	_add_menu_button(
		_layout_root,
		AppState.t("menu_remove_ads"),
		Callable(self, "_purchase_remove_ads"),
		"quiet",
		false
	)
	if AnalyticsService.is_available():
		_add_menu_button(
			_layout_root,
			AppState.t("analytics_disable") if AnalyticsService.is_collection_enabled() else AppState.t("analytics_enable"),
			Callable(self, "_toggle_analytics"),
			"quiet",
			false
		)
	_add_menu_button(
		_layout_root,
		AppState.t("menu_exit"),
		Callable(self, "_exit_app"),
		"quiet"
	)

	ScreenBuilder.add_bottom_ad_reserve(self, true, AppAds.PLACEMENT_MAIN_MENU)
	var purchases := get_node_or_null("/root/AppPurchases")
	if purchases != null:
		purchases.entitlement_changed.connect(_on_entitlement_changed)
		purchases.purchase_message.connect(_on_purchase_message)


func _add_action_grid(parent: Container) -> GridContainer:
	var grid := GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 14)
	parent.add_child(grid)
	_button_rows.append(grid)
	return grid


func _add_menu_button(parent: Container, text: String, callback: Callable, variant: String = "secondary", play_sound: bool = true) -> Button:
	var button := Button.new()
	button.text = text
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button.pressed.connect(callback)
	if play_sound:
		button.pressed.connect(_play_click)
	parent.add_child(button)
	ScreenBuilder.style_button(button, variant)
	button.set_meta("menu_size", "compact" if variant == "quiet" else "standard")
	_action_buttons.append(button)
	return button


func _apply_responsive_layout() -> void:
	var viewport: Viewport = get_viewport()
	if viewport == null:
		return

	var viewport_size: Vector2 = viewport.get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return

	var ui_scale: float = ScreenBuilder.visual_ui_scale(self)
	var margin: int = int(round(18.0 * ui_scale))
	var icon_size: int = int(round(82.0 * ui_scale))
	var title_size: int = int(round(34.0 * ui_scale))
	var subtitle_size: int = int(round(17.0 * ui_scale))
	var label_size: int = int(round(18.0 * ui_scale))
	var language_height: int = int(round(96.0 * ui_scale))
	var language_label_width: int = int(round(112.0 * ui_scale))
	var button_height: int = int(round(96.0 * ui_scale))
	var button_size: int = int(round(20.0 * ui_scale))

	_icon.custom_minimum_size = Vector2(icon_size, icon_size)
	_title_label.add_theme_font_size_override("font_size", title_size)
	_subtitle_label.add_theme_font_size_override("font_size", subtitle_size)
	_language_label.text = "%s:" % AppState.t("language_label")
	_language_label.custom_minimum_size = Vector2(language_label_width, language_height)
	_language_label.add_theme_font_size_override("font_size", label_size)
	_language_select.custom_minimum_size = Vector2(0, language_height)
	_language_select.add_theme_font_size_override("font_size", label_size)
	_language_select.add_theme_constant_override("v_separation", int(round(18.0 * ui_scale)))
	var language_popup := _language_select.get_popup()
	if language_popup != null:
		language_popup.add_theme_font_size_override("font_size", label_size)
		language_popup.add_theme_constant_override("v_separation", int(round(20.0 * ui_scale)))
	if _language_row != null:
		_language_row.add_theme_constant_override("separation", int(round(18.0 * ui_scale)))
	var margin_container := _find_margin_container()
	if margin_container != null:
		ScreenBuilder.set_root_margin(self, margin_container, margin)

	for button in _action_buttons:
		var size_kind := str(button.get_meta("menu_size", "standard"))
		var height := button_height
		var font_size := button_size
		if size_kind == "primary":
			height = int(round(122.0 * ui_scale))
			font_size = int(round(24.0 * ui_scale))
		elif size_kind == "compact":
			height = int(round(96.0 * ui_scale))
			font_size = int(round(17.0 * ui_scale))
		button.custom_minimum_size = Vector2(0, height)
		button.add_theme_font_size_override("font_size", font_size)

	_layout_root.add_theme_constant_override("separation", int(round(18.0 * ui_scale)))
	for row in _button_rows:
		row.add_theme_constant_override("h_separation", int(round(14.0 * ui_scale)))
		row.add_theme_constant_override("v_separation", int(round(14.0 * ui_scale)))


func _find_margin_container() -> MarginContainer:
	var container: int = get_child_count()
	for index in range(container):
		var child: Node = get_child(index)
		if child is MarginContainer:
			return child
	return null


func _play_click() -> void:
	var player := AudioStreamPlayer.new()
	player.stream = load("res://assets/ui/button.wav")
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()


func _populate_language_options(select: OptionButton) -> void:
	select.clear()
	select.add_item(AppState.t("follow_phone_language"), 0)

	var locales: Array[String] = AppState.get_supported_locales()
	for index in locales.size():
		var locale_code: String = locales[index]
		select.add_item(AppState.get_locale_display_name(locale_code), index + 1)

	var selected: int = 0
	if not AppState.uses_phone_locale():
		var current: String = AppState.get_locale_code()
		for index in locales.size():
			if locales[index] == current:
				selected = index + 1
				break
	select.select(selected)


func _on_language_selected(index: int, _select: OptionButton) -> void:
	if index <= 0:
		AppState.clear_locale_override()
	else:
		var locales: Array[String] = AppState.get_supported_locales()
		var locale_index: int = index - 1
		if locale_index >= 0 and locale_index < locales.size():
			AppState.set_locale_override(locales[locale_index])
	get_tree().reload_current_scene()


func _open_uv() -> void:
	AppAds.hide_banner()
	_record_review_use()
	get_tree().change_scene_to_file(UV_SCENE)


func _open_watermark() -> void:
	AppAds.hide_banner()
	_record_review_use()
	get_tree().change_scene_to_file(WATERMARK_SCENE)


func _open_countries() -> void:
	AppAds.hide_banner()
	_record_review_use()
	get_tree().change_scene_to_file(COUNTRY_SCENE)


func _open_guided_review() -> void:
	AppAds.hide_banner()
	get_tree().change_scene_to_file(REVIEW_SETUP_SCENE)


func _open_review_library() -> void:
	AppAds.hide_banner()
	get_tree().change_scene_to_file(REVIEW_LIBRARY_SCENE)


func _record_review_use() -> void:
	var review := get_node_or_null("/root/AppReview")
	if review != null:
		review.record_successful_use()


func _show_about() -> void:
	_show_dialog(
		AppState.t("about_title"),
		AppState.get_about_text()
	)


func _maybe_request_analytics_consent() -> void:
	if not AnalyticsService.should_request_consent():
		return
	var dialog := ConfirmationDialog.new()
	dialog.title = AppState.t("analytics_consent_title")
	dialog.dialog_text = AppState.t("analytics_consent_body")
	dialog.ok_button_text = AppState.t("analytics_allow")
	dialog.cancel_button_text = AppState.t("analytics_decline")
	dialog.confirmed.connect(AnalyticsService.set_consent.bind(true))
	dialog.canceled.connect(AnalyticsService.set_consent.bind(false))
	dialog.close_requested.connect(AnalyticsService.set_consent.bind(false))
	dialog.close_requested.connect(dialog.queue_free)
	dialog.confirmed.connect(dialog.queue_free)
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	dialog.popup_centered_ratio(0.88)


func _toggle_analytics() -> void:
	AnalyticsService.set_consent(not AnalyticsService.is_collection_enabled())
	get_tree().reload_current_scene()


func _purchase_remove_ads() -> void:
	var purchases := get_node_or_null("/root/AppPurchases")
	if purchases != null:
		purchases.purchase_remove_ads()


func _on_entitlement_changed(_ads_removed: bool) -> void:
	_apply_responsive_layout()


func _on_purchase_message(message_key: String) -> void:
	_show_dialog(AppState.t("menu_remove_ads"), AppState.t(message_key))


func _show_dialog(title_text: String, body_text: String) -> void:
	var dialog := AcceptDialog.new()
	add_child(dialog)
	var dialog_scale := ScreenBuilder.configure_large_dialog(dialog, self, title_text, AppState.t("close"))

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", int(round(24.0 * dialog_scale)))
	dialog.add_child(content)

	ScreenBuilder.add_dialog_header(content, title_text, dialog.queue_free, dialog_scale)

	var body := Label.new()
	body.text = body_text
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_font_size_override("font_size", int(round(32.0 * dialog_scale)))
	content.add_child(body)

	dialog.popup_centered()


func _exit_app() -> void:
	get_tree().quit()
