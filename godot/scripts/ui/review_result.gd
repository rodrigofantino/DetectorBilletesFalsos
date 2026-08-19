extends Control

const MAIN_MENU_SCENE := "res://scenes/MainMenu.tscn"
const SETUP_SCENE := "res://scenes/ReviewSetup.tscn"

var _favorite_button: Button


func _ready() -> void:
	if not GuidedReviewSession.has_active_session() or not GuidedReviewSession.is_complete():
		AppAds.hide_banner()
		get_tree().change_scene_to_file(SETUP_SCENE)
		return
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_record_completion_once()
	_build_ui()


func _build_ui() -> void:
	var root := ScreenBuilder.setup_root(self, Color(0.04, 0.07, 0.11, 1.0))
	var content := ScreenBuilder.add_scroll_content(root)
	ScreenBuilder.add_title(content, AppState.t("review_result_title"))
	var note := GuidedReviewSession.get_note()
	ScreenBuilder.add_subtitle(content, AppState.get_note_title(note))
	var counts := GuidedReviewSession.get_counts()
	ScreenBuilder.add_body(content, AppState.t("result_observed") % int(counts.get(GuidedReviewSession.ANSWER_OBSERVED, 0)))
	ScreenBuilder.add_body(content, AppState.t("result_mismatch") % int(counts.get(GuidedReviewSession.ANSWER_MISMATCH, 0)))
	ScreenBuilder.add_body(content, AppState.t("result_unable") % int(counts.get(GuidedReviewSession.ANSWER_UNABLE, 0)))

	var disclaimer := ScreenBuilder.add_body(content, AppState.t("review_disclaimer"))
	disclaimer.modulate = Color(1.0, 0.82, 0.42)
	ScreenBuilder.add_body(content, AppState.t("review_result_advice"))

	var source_url := AppState.get_note_source_url(note)
	if ScreenBuilder.is_valid_web_url(source_url):
		var source := ScreenBuilder.add_button(content, AppState.t("open_official_source"))
		source.pressed.connect(func() -> void: ScreenBuilder.open_source_url(source_url))

	_favorite_button = ScreenBuilder.add_button(content, "")
	_favorite_button.pressed.connect(_toggle_favorite)
	_refresh_favorite_button()
	var another := ScreenBuilder.add_button(content, AppState.t("review_another"))
	another.pressed.connect(_review_another)
	var home := ScreenBuilder.add_button(content, AppState.t("return_home"))
	home.pressed.connect(_return_home)

	ScreenBuilder.add_bottom_ad_reserve(self, true, AppAds.PLACEMENT_REVIEW_RESULT)
	ScreenBuilder.add_spacer(content, ScreenBuilder.get_bottom_ad_reserve_height(self))


func _record_completion_once() -> void:
	if GuidedReviewSession.history_recorded:
		return
	ReviewHistoryStore.add_completed_review(
		GuidedReviewSession.note_id,
		GuidedReviewSession.started_at_unix,
		GuidedReviewSession.is_generic_guide
	)
	GuidedReviewSession.history_recorded = true
	var play_review := get_node_or_null("/root/AppReview")
	if play_review != null:
		play_review.record_successful_use()


func _toggle_favorite() -> void:
	ReviewHistoryStore.toggle_favorite(GuidedReviewSession.note_id)
	_refresh_favorite_button()


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
