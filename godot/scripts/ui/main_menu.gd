extends Control

const UV_SCENE := "res://scenes/UvDetector.tscn"
const WATERMARK_SCENE := "res://scenes/WatermarkViewer.tscn"
const COUNTRY_SCENE := "res://scenes/CountrySelect.tscn"
const BILL_SCENE := "res://scenes/BillViewer.tscn"
const REVIEW_SETUP_SCENE := "res://scenes/ReviewSetup.tscn"
const REVIEW_LIBRARY_SCENE := "res://scenes/ReviewLibrary.tscn"
const BASE_VIEWPORT := Vector2(1080.0, 1920.0)

@onready var _background: ColorRect = $Background
@onready var _margin: MarginContainer = %SafeAreaMargin
@onready var _panel: PanelContainer = %SurfacePanel
@onready var _root_content: VBoxContainer = %RootContent
@onready var _layout_root: VBoxContainer = %MenuContent
@onready var _title_label: Label = %TitleLabel
@onready var _subtitle_label: Label = %SubtitleLabel
@onready var _language_label: Label = %LanguageLabel
@onready var _icon: TextureRect = %Icon
@onready var _language_select: OptionButton = %LanguageSelect
@onready var _language_row: HBoxContainer = %LanguageRow
@onready var _library_button: Button = %LibraryButton
@onready var _analytics_button: Button = %AnalyticsButton
@onready var _action_buttons: Array[Button] = [
	%GuidedReviewButton, %LibraryButton, %UvButton, %WatermarkButton,
	%CurrencyButton, %AboutButton, %RemoveAdsButton, %AnalyticsButton, %ExitButton
]
@onready var _button_rows: Array[Container] = [%ToolsGrid, %ExploreGrid, %SettingsGrid]


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_configure_static_ui()
	resized.connect(_apply_responsive_layout)
	_apply_responsive_layout()
	call_deferred("_maybe_request_analytics_consent")


func _configure_static_ui() -> void:
	theme = ScreenBuilder._make_app_theme(self)
	_background.color = ScreenBuilder.COLOR_BACKGROUND
	_panel.add_theme_stylebox_override("panel", ScreenBuilder._style_box(Color("101a2a"), Color("24324a"), 22, 1, 20))
	set_meta("screen_builder_content", _root_content)
	ScreenBuilder.set_root_margin(self, _margin, 24)
	_layout_root.alignment = BoxContainer.ALIGNMENT_BEGIN
	_layout_root.add_theme_constant_override("separation", 14)
	_title_label.text = AppState.t("app_title")
	_subtitle_label.text = AppState.t("menu_subtitle")
	%GuidedReviewHint.text = AppState.t("menu_review_hint")
	%ContinueLabel.text = AppState.t("menu_continue").to_upper()
	%GuidedReviewButton.text = AppState.t("menu_guided_review")
	_library_button.text = AppState.t("menu_library")
	%UvButton.text = AppState.t("menu_uv")
	%WatermarkButton.text = AppState.t("menu_watermark")
	%CurrencyButton.text = AppState.t("menu_currency")
	%AboutButton.text = AppState.t("menu_about")
	%RemoveAdsButton.text = AppState.t("menu_remove_ads")
	%ExitButton.text = AppState.t("menu_exit")
	_library_button.disabled = ReviewHistoryStore.get_recents().is_empty() and ReviewHistoryStore.get_favorites().is_empty()
	_analytics_button.visible = AnalyticsService.is_available()
	_analytics_button.text = AppState.t("analytics_disable") if AnalyticsService.is_collection_enabled() else AppState.t("analytics_enable")
	_populate_language_options(_language_select)
	_language_select.item_selected.connect(_on_language_selected.bind(_language_select))
	%GuidedReviewButton.pressed.connect(_open_guided_review)
	_library_button.pressed.connect(_open_review_library)
	%UvButton.pressed.connect(_open_uv)
	%WatermarkButton.pressed.connect(_open_watermark)
	%CurrencyButton.pressed.connect(_open_countries)
	%AboutButton.pressed.connect(_show_about)
	%RemoveAdsButton.pressed.connect(_purchase_remove_ads)
	_analytics_button.pressed.connect(_toggle_analytics)
	%ExitButton.pressed.connect(_exit_app)
	for button in _action_buttons:
		ScreenBuilder.style_button(button, str(button.get_meta("menu_variant", "secondary")))
		if bool(button.get_meta("play_click", true)):
			button.pressed.connect(_play_click)
	ScreenBuilder.style_option_button(_language_select)
	ScreenBuilder.add_bottom_ad_reserve(self, true, AppAds.PLACEMENT_MAIN_MENU)
	var purchases := get_node_or_null("/root/AppPurchases")
	if purchases != null:
		purchases.entitlement_changed.connect(_on_entitlement_changed)
		purchases.purchase_message.connect(_on_purchase_message)

func _apply_responsive_layout() -> void:
	var viewport: Viewport = get_viewport()
	if viewport == null:
		return

	var viewport_size: Vector2 = viewport.get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return

	var ui_scale: float = ScreenBuilder.visual_ui_scale(self)
	_layout_root.custom_minimum_size.x = min(900.0 * ui_scale, max(0.0, viewport_size.x - 72.0))
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
	var dialog := AcceptDialog.new()
	dialog.theme = theme
	dialog.borderless = true
	dialog.unresizable = true
	dialog.exclusive = true
	dialog.min_size = Vector2(min(720.0, get_viewport_rect().size.x * 0.86), 0)
	dialog.add_theme_stylebox_override("panel", ScreenBuilder._style_box(ScreenBuilder.COLOR_SURFACE, ScreenBuilder.COLOR_BORDER, 22, 1, 24))
	add_child(dialog)
	dialog.get_ok_button().hide()
	dialog.close_requested.connect(dialog.queue_free)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", int(round(18.0 * ScreenBuilder.visual_ui_scale(self))))
	dialog.add_child(content)

	var title := ScreenBuilder.add_title(content, AppState.t("about_title"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var body := ScreenBuilder.add_body(content, AppState.get_about_text())
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var actions := HBoxContainer.new()
	actions.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_theme_constant_override("separation", int(round(14.0 * ScreenBuilder.visual_ui_scale(self))))
	content.add_child(actions)
	var back := ScreenBuilder.add_button(actions, AppState.t("back"), "secondary")
	back.pressed.connect(dialog.queue_free)
	var rate := ScreenBuilder.add_button(actions, AppState.t("rate_this_app"), "primary")
	rate.disabled = not AppReview.can_request_manual_review()
	rate.pressed.connect(func() -> void:
		dialog.queue_free()
		call_deferred("_request_manual_review")
	)
	dialog.popup_centered()


func _request_manual_review() -> void:
	AppReview.request_manual_review()


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
