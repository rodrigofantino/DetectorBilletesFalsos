extends Control

const MAIN_MENU_SCENE := "res://scenes/MainMenu.tscn"
const COUNTRY_INFO_SCENE := "res://scenes/CurrencyInfo.tscn"

func _ready() -> void:
	var content := ScreenBuilder.setup_root(self, Color(0.06, 0.06, 0.08, 1.0))
	ScreenBuilder.add_spacer(content, 12)
	ScreenBuilder.add_title(content, "Bill viewer")
	ScreenBuilder.add_subtitle(content, AppState.get_selected_country_label())
	ScreenBuilder.add_spacer(content, 8)

	var entry := AppState.get_selected_entry()
	if entry.is_empty():
		ScreenBuilder.add_body(content, "No bill is currently selected.")
	else:
		_show_entry(content, entry)

	ScreenBuilder.add_spacer(content, 8)
	var actions := HBoxContainer.new()
	actions.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_theme_constant_override("separation", 10)
	content.add_child(actions)

	var back_button := ScreenBuilder.add_button(actions, "Back")
	back_button.pressed.connect(_on_back_pressed)

	var menu_button := ScreenBuilder.add_button(actions, "Menu")
	menu_button.pressed.connect(_on_menu_pressed)

func _show_entry(parent: VBoxContainer, entry: Dictionary) -> void:
	var details := VBoxContainer.new()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.size_flags_vertical = Control.SIZE_EXPAND_FILL
	details.add_theme_constant_override("separation", 10)
	parent.add_child(details)

	ScreenBuilder.add_body(details, "Country: %s" % str(entry.get("country", "")))
	ScreenBuilder.add_body(details, "Currency: %s" % str(entry.get("currency", "")))
	ScreenBuilder.add_body(details, "Denomination: %s" % str(entry.get("denomination", "")))
	ScreenBuilder.add_body(details, "Watermark key: %s" % str(entry.get("watermark", "")))
	ScreenBuilder.add_body(details, "Description key: %s" % str(entry.get("description", "")))

func _on_back_pressed() -> void:
	AppState.go_to_scene(COUNTRY_INFO_SCENE)

func _on_menu_pressed() -> void:
	AppState.go_to_scene(MAIN_MENU_SCENE)

