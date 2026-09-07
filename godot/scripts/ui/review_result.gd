extends Control

const MAIN_MENU_SCENE := "res://scenes/MainMenu.tscn"
const SETUP_SCENE := "res://scenes/ReviewSetup.tscn"
const PLAY_STORE_LISTING_URL := "https://play.google.com/store/apps/details?id=com.appsimple.DetectorBilleteFalso2"

var _favorite_button: Button
var _completion_feedback_triggered := false
var _completion_feedback_pending_action := Callable()


func _ready() -> void:
	if not GuidedReviewSession.has_active_session() or not GuidedReviewSession.is_complete():
		AppAds.hide_banner()
		get_tree().change_scene_to_file(SETUP_SCENE)
		return
	set_anchors_preset(Control.PRESET_FULL_RECT)
	AnalyticsService.track_screen("review_result")
	_record_completion_once()
	_build_ui()


func _build_ui() -> void:
	var root := ScreenBuilder.setup_root(self, Color(0.04, 0.07, 0.11, 1.0))
	var content := ScreenBuilder.add_scroll_content(root)
	var title := ScreenBuilder.add_title(content, AppState.t("review_result_title"))
	title.add_theme_font_size_override("font_size", 58)
	var note := GuidedReviewSession.get_note()
	var note_title := ScreenBuilder.add_subtitle(content, AppState.get_note_title(note))
	note_title.add_theme_font_size_override("font_size", 38)
	var counts := GuidedReviewSession.get_counts()
	for text in [AppState.t("result_observed") % int(counts.get(GuidedReviewSession.ANSWER_OBSERVED, 0)), AppState.t("result_mismatch") % int(counts.get(GuidedReviewSession.ANSWER_MISMATCH, 0)), AppState.t("result_unable") % int(counts.get(GuidedReviewSession.ANSWER_UNABLE, 0))]:
		var result_line := ScreenBuilder.add_body(content, text)
		result_line.add_theme_font_size_override("font_size", 36)

	var disclaimer := ScreenBuilder.add_body(content, AppState.t("review_disclaimer"))
	disclaimer.add_theme_font_size_override("font_size", 36)
	disclaimer.modulate = Color(1.0, 0.82, 0.42)
	var advice := ScreenBuilder.add_body(content, AppState.t("review_result_advice"))
	advice.add_theme_font_size_override("font_size", 36)

	var source_url := AppState.get_note_source_url(note)
	if ScreenBuilder.is_valid_web_url(source_url):
		var source := ScreenBuilder.add_button(content, AppState.t("open_official_source"))
		source.pressed.connect(func() -> void:
			_show_completion_feedback_before_action(func() -> void: ScreenBuilder.open_source_url(source_url))
		)

	_favorite_button = ScreenBuilder.add_button(content, "")
	_favorite_button.pressed.connect(_toggle_favorite)
	_refresh_favorite_button()
	var another := ScreenBuilder.add_button(content, AppState.t("review_another"), "primary")
	another.pressed.connect(func() -> void: _show_completion_feedback_before_action(_review_another))
	var home := ScreenBuilder.add_button(content, AppState.t("return_home"), "secondary")
	home.pressed.connect(func() -> void: _show_completion_feedback_before_action(_return_home))
	for child in content.get_children():
		if child is Button:
			(child as Button).add_theme_font_size_override("font_size", 40)

	ScreenBuilder.add_bottom_ad_reserve(self, true, AppAds.PLACEMENT_REVIEW_RESULT)
	if has_meta("show_review_interstitial"):
		call_deferred("_show_review_interstitial")


func _record_completion_once() -> void:
	if GuidedReviewSession.history_recorded:
		return
	ReviewHistoryStore.add_completed_review(
		GuidedReviewSession.note_id,
		GuidedReviewSession.started_at_unix,
		GuidedReviewSession.is_generic_guide
	)
	AnalyticsService.track("guide_completed", {
		"guide_kind": "generic" if GuidedReviewSession.is_generic_guide else "specific",
	})
	GuidedReviewSession.history_recorded = true
	var play_review := get_node_or_null("/root/AppReview")
	if play_review != null:
		if play_review.record_completed_review():
			set_meta("show_review_interstitial", true)


func _show_review_interstitial() -> void:
	AppAds.show_interstitial()


func _show_completion_feedback_before_action(action: Callable) -> void:
	if _completion_feedback_triggered or has_meta("show_review_interstitial"):
		action.call()
		return
	var play_review := get_node_or_null("/root/AppReview")
	if play_review == null or not play_review.has_method("can_show_completion_feedback") or not play_review.can_show_completion_feedback():
		action.call()
		return
	_completion_feedback_triggered = true
	_completion_feedback_pending_action = action
	_show_completion_feedback()


func _show_completion_feedback() -> void:
	if has_meta("show_review_interstitial"):
		return
	var play_review := get_node_or_null("/root/AppReview")
	if play_review == null or not play_review.has_method("can_show_completion_feedback") or not play_review.can_show_completion_feedback():
		return
	play_review.mark_completion_feedback_shown()
	var dialog := AcceptDialog.new()
	dialog.theme = theme
	dialog.borderless = true
	dialog.transparent = true
	dialog.unresizable = true
	dialog.exclusive = true
	var viewport_size := get_viewport_rect().size
	var dialog_width: float = minf(760.0, viewport_size.x * 0.88)
	var dialog_height: float = floor(viewport_size.y * 0.50)
	var dialog_size: Vector2 = Vector2(maxf(1.0, dialog_width), maxf(1.0, dialog_height))
	dialog.min_size = dialog_size
	dialog.max_size = Vector2i(int(dialog_size.x), int(dialog_size.y))
	dialog.add_theme_stylebox_override("panel", ScreenBuilder._style_box(ScreenBuilder.COLOR_SURFACE, ScreenBuilder.COLOR_BORDER, 22, 1, 24))
	add_child(dialog)
	dialog.get_ok_button().hide()
	dialog.close_requested.connect(_dismiss_completion_feedback.bind(dialog))

	var content := VBoxContainer.new()
	var content_padding := 24.0
	content.position = Vector2(content_padding, content_padding)
	content.size = Vector2(max(1.0, dialog_size.x - content_padding * 2.0), max(1.0, dialog_size.y - content_padding * 2.0))
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.clip_contents = true
	var feedback_scale := ScreenBuilder.visual_ui_scale(self)
	content.add_theme_constant_override("separation", int(round(18.0 * feedback_scale)))
	dialog.add_child(content)

	var title := ScreenBuilder.add_title(content, AppState.t("completion_feedback_title"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", int(round(36.0 * feedback_scale)))
	var feedback_scroll := ScrollContainer.new()
	feedback_scroll.custom_minimum_size = Vector2.ZERO
	feedback_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	feedback_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	feedback_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content.add_child(feedback_scroll)
	var body := ScreenBuilder.add_body(feedback_scroll, AppState.t("completion_feedback_body"))
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_theme_font_size_override("font_size", int(round(27.0 * feedback_scale)))
	ScreenBuilder.enable_touch_scroll(feedback_scroll, body)

	var actions := HBoxContainer.new()
	actions.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.layout_direction = Control.LAYOUT_DIRECTION_LTR
	actions.add_theme_constant_override("separation", int(round(12.0 * feedback_scale)))
	content.add_child(actions)
	var not_now := ScreenBuilder.add_button(actions, AppState.t("completion_feedback_not_now"), "secondary")
	not_now.custom_minimum_size = Vector2(0.0, max(64.0, 72.0 * feedback_scale))
	not_now.add_theme_font_size_override("font_size", int(round(26.0 * feedback_scale)))
	not_now.pressed.connect(_dismiss_completion_feedback.bind(dialog))
	var open_play := ScreenBuilder.add_button(actions, AppState.t("completion_feedback_open_play"), "primary")
	open_play.custom_minimum_size = Vector2(0.0, max(64.0, 72.0 * feedback_scale))
	open_play.add_theme_font_size_override("font_size", int(round(26.0 * feedback_scale)))
	open_play.pressed.connect(func() -> void:
		open_play.disabled = true
		_completion_feedback_pending_action = Callable()
		dialog.queue_free()
		call_deferred("_open_play_store_listing")
	)
	dialog.popup_centered(Vector2i(int(dialog_size.x), int(dialog_size.y)))


func _open_play_store_listing() -> void:
	ScreenBuilder.open_source_url(PLAY_STORE_LISTING_URL)


func _dismiss_completion_feedback(dialog: AcceptDialog) -> void:
	if is_instance_valid(dialog):
		dialog.queue_free()
	var action := _completion_feedback_pending_action
	_completion_feedback_pending_action = Callable()
	if action.is_valid():
		call_deferred("_invoke_completion_feedback_action", action)


func _invoke_completion_feedback_action(action: Callable) -> void:
	if action.is_valid():
		action.call()


func _toggle_favorite() -> void:
	var enabled := ReviewHistoryStore.toggle_favorite(GuidedReviewSession.note_id)
	AnalyticsService.track("favorite_toggled", {"enabled": enabled})
	_refresh_favorite_button()
	call_deferred("_show_completion_feedback_after_favorite")


func _show_completion_feedback_after_favorite() -> void:
	if _completion_feedback_triggered or has_meta("show_review_interstitial"):
		return
	var play_review := get_node_or_null("/root/AppReview")
	if play_review == null or not play_review.has_method("can_show_completion_feedback") or not play_review.can_show_completion_feedback():
		return
	_completion_feedback_triggered = true
	_show_completion_feedback()


func _refresh_favorite_button() -> void:
	var favorite := ReviewHistoryStore.is_favorite(GuidedReviewSession.note_id)
	_favorite_button.text = AppState.t("remove_favorite") if favorite else AppState.t("add_favorite")


func _review_another() -> void:
	AppAds.hide_banner()
	GuidedReviewSession.clear()
	get_tree().change_scene_to_file(SETUP_SCENE)


func _return_home() -> void:
	AppAds.hide_banner()
	GuidedReviewSession.clear()
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
