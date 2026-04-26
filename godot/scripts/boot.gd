extends Control

const MAIN_MENU_SCENE := "res://scenes/MainMenu.tscn"

func _ready() -> void:
	var content := ScreenBuilder.setup_root(self, Color(0.04, 0.05, 0.08, 1.0))
	ScreenBuilder.add_spacer(content, 120)
	ScreenBuilder.add_title(content, "Detector de Billetes Falsos")
	ScreenBuilder.add_subtitle(content, "Godot 4.5 skeleton")
	ScreenBuilder.add_spacer(content, 40)
	ScreenBuilder.add_body(content, "Preparing the menu and loading currency data...")
	await get_tree().process_frame
	AppState.go_to_scene(MAIN_MENU_SCENE)

