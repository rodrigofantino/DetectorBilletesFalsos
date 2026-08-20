extends Control

const SETUP_SCENE := "res://scenes/ReviewSetup.tscn"
const RESULT_SCENE := "res://scenes/ReviewResult.tscn"

var _progress: Label
var _step_title: Label
var _instruction: Label
var _reference_image: TextureRect
var _reference_caption: Label
var _expected: Label


func _ready() -> void:
	if not GuidedReviewSession.has_active_session():
		get_tree().change_scene_to_file(SETUP_SCENE)
		return
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	_refresh_step()


func _build_ui() -> void:
	var root := ScreenBuilder.setup_root(self, Color(0.04, 0.07, 0.11, 1.0))
	var content := ScreenBuilder.add_scroll_content(root)
	ScreenBuilder.add_title(content, AppState.t("review_title"))
	var note := GuidedReviewSession.get_note()
	ScreenBuilder.add_subtitle(content, AppState.get_note_title(note))
	if GuidedReviewSession.is_generic_guide:
		var notice := ScreenBuilder.add_body(content, AppState.t("generic_guide_notice"))
		notice.modulate = Color(1.0, 0.82, 0.42)

	_progress = ScreenBuilder.add_subtitle(content, "")
	_step_title = ScreenBuilder.add_title(content, "")
	_instruction = ScreenBuilder.add_body(content, "")
	_reference_image = TextureRect.new()
	_reference_image.custom_minimum_size = Vector2(0, 260)
	_reference_image.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_reference_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_reference_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_reference_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(_reference_image)
	_reference_caption = ScreenBuilder.add_body(content, AppState.t("review_reference_caption"))
	_reference_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_reference_caption.add_theme_color_override("font_color", ScreenBuilder.COLOR_TEXT_MUTED)
	_expected = ScreenBuilder.add_body(content, "")
	var review_scale := ScreenBuilder.visual_ui_scale(self)
	_step_title.add_theme_font_size_override("font_size", int(round(54.0 * review_scale)))
	_instruction.add_theme_font_size_override("font_size", int(round(34.0 * review_scale)))
	_reference_image.custom_minimum_size.y = int(round(260.0 * review_scale))
	_reference_caption.add_theme_font_size_override("font_size", int(round(28.0 * review_scale)))
	_expected.add_theme_font_size_override("font_size", int(round(36.0 * review_scale)))
	_expected.modulate = Color(0.78, 0.9, 1.0)

	var observed := ScreenBuilder.add_button(content, AppState.t("observed"), "positive")
	observed.pressed.connect(_answer.bind(GuidedReviewSession.ANSWER_OBSERVED))
	var mismatch := ScreenBuilder.add_button(content, AppState.t("mismatch"), "warning")
	mismatch.pressed.connect(_answer.bind(GuidedReviewSession.ANSWER_MISMATCH))
	var unable := ScreenBuilder.add_button(content, AppState.t("unable"))
	unable.pressed.connect(_answer.bind(GuidedReviewSession.ANSWER_UNABLE))
	var back := ScreenBuilder.add_button(content, AppState.t("back"), "secondary")
	back.pressed.connect(func() -> void: get_tree().change_scene_to_file(SETUP_SCENE))
	ScreenBuilder.add_bottom_ad_reserve(self, true, AppAds.PLACEMENT_GUIDED_REVIEW)


func _refresh_step() -> void:
	var step := GuidedReviewSession.get_current_step()
	if step.is_empty():
		return
	_progress.text = AppState.t("step_progress") % [GuidedReviewSession.current_step_index + 1, GuidedReviewSession.steps.size()]
	_step_title.text = str(step.get("title", AppState.t("step_compare_title")))
	_instruction.text = str(step.get("instruction", AppState.t("step_compare_instruction")))
	var reference_path := str(step.get("reference_path", "")).strip_edges()
	var reference_texture: Texture2D = load(reference_path) if not reference_path.is_empty() else null
	_reference_image.texture = reference_texture
	_reference_image.visible = reference_texture != null
	_reference_caption.visible = reference_texture != null
	_expected.text = str(step.get("expected", ""))


func _answer(value: String) -> void:
	var step := GuidedReviewSession.get_current_step()
	if not GuidedReviewSession.answer_current(value):
		return
	AnalyticsService.track("guide_step_answered", {
		"method": str(step.get("method", "visual")),
	})
	if GuidedReviewSession.is_complete():
		get_tree().change_scene_to_file(RESULT_SCENE)
	else:
		_refresh_step()
