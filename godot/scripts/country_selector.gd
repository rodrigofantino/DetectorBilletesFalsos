extends Control

const MAIN_MENU_SCENE := "res://scenes/MainMenu.tscn"
const CURRENCY_INFO_SCENE := "res://scenes/CurrencyInfo.tscn"

func _ready() -> void:
	var content := ScreenBuilder.setup_root(self, Color(0.05, 0.07, 0.1, 1.0))
	ScreenBuilder.add_spacer(content, 12)
	ScreenBuilder.add_title(content, "Country selector")
	ScreenBuilder.add_subtitle(content, "Choose a country to browse its currency data")
	ScreenBuilder.add_spacer(content, 8)

	var countries := AppState.get_countries()
	if countries.is_empty():
		ScreenBuilder.add_body(content, "No currency data could be loaded.")
	else:
		var scroll_content := ScreenBuilder.add_scroll_content(content)
		for country in countries:
			_add_country_button(scroll_content, country)

	ScreenBuilder.add_spacer(content, 8)
	var actions := HBoxContainer.new()
	actions.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_theme_constant_override("separation", 10)
	content.add_child(actions)

	var menu_button := ScreenBuilder.add_button(actions, "Back to menu")
	menu_button.pressed.connect(_on_menu_pressed)

func _add_country_button(parent: VBoxContainer, country: String) -> void:
	var label := AppState.get_country_label(country)
	var count := AppState.get_notes_for_country(country).size()
	var button := ScreenBuilder.add_button(parent, "%s (%d notes)" % [label, count])
	button.pressed.connect(_on_country_pressed.bind(country))

func _on_country_pressed(country: String) -> void:
	AppState.set_selected_country(country)
	get_tree().change_scene_to_file(CURRENCY_INFO_SCENE)

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
