extends Control

const UV_SCENE := "res://scenes/UvDetector.tscn"
const WATERMARK_SCENE := "res://scenes/WatermarkViewer.tscn"
const COUNTRY_SCENE := "res://scenes/CountrySelector.tscn"
const BILL_SCENE := "res://scenes/BillViewer.tscn"

func _ready() -> void:
	var content := ScreenBuilder.setup_root(self, Color(0.05, 0.08, 0.12, 1.0))
	ScreenBuilder.add_spacer(content, 24)
	ScreenBuilder.add_title(content, "Main Menu")
	ScreenBuilder.add_subtitle(content, "Portrait-first, offline-friendly utility")
	ScreenBuilder.add_spacer(content, 12)
	ScreenBuilder.add_body(content, "Choose a tool to inspect bills or review the currency reference data.")
	ScreenBuilder.add_spacer(content, 12)

	var buttons := VBoxContainer.new()
	buttons.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buttons.size_flags_vertical = Control.SIZE_EXPAND_FILL
	buttons.add_theme_constant_override("separation", 10)
	content.add_child(buttons)

	var uv_button := ScreenBuilder.add_button(buttons, "UV detector")
	uv_button.pressed.connect(_on_uv_pressed)

	var watermark_button := ScreenBuilder.add_button(buttons, "Watermark viewer")
	watermark_button.pressed.connect(_on_watermark_pressed)

	var country_button := ScreenBuilder.add_button(buttons, "Country selector")
	country_button.pressed.connect(_on_country_pressed)

	var bill_button := ScreenBuilder.add_button(buttons, "Current bill viewer")
	bill_button.pressed.connect(_on_bill_pressed)

	ScreenBuilder.add_spacer(content, 8)
	ScreenBuilder.add_body(content, "Legacy ad SDKs are not reused in this Godot port.")

func _on_uv_pressed() -> void:
	AppState.go_to_scene(UV_SCENE)

func _on_watermark_pressed() -> void:
	AppState.go_to_scene(WATERMARK_SCENE)

func _on_country_pressed() -> void:
	AppState.go_to_scene(COUNTRY_SCENE)

func _on_bill_pressed() -> void:
	AppState.go_to_scene(BILL_SCENE)
