extends Control

const MAIN_MENU_SCENE := "res://scenes/MainMenu.tscn"
const COUNTRY_SELECTOR_SCENE := "res://scenes/CountrySelector.tscn"
const BILL_VIEWER_SCENE := "res://scenes/BillViewer.tscn"

func _ready() -> void:
	var content := ScreenBuilder.setup_root(self, Color(0.05, 0.08, 0.09, 1.0))
	ScreenBuilder.add_spacer(content, 12)
	ScreenBuilder.add_title(content, "Currency info")
	ScreenBuilder.add_subtitle(content, AppState.get_selected_country_label())
	ScreenBuilder.add_spacer(content, 8)

	var entries := AppState.get_selected_entries()
	if entries.is_empty():
		ScreenBuilder.add_body(content, "No bill data is available for the current country.")
	else:
		ScreenBuilder.add_body(content, "Select a note to view its stored security fields.")
		ScreenBuilder.add_spacer(content, 8)
		var scroll_content := ScreenBuilder.add_scroll_content(content)
		for index in entries.size():
			_add_bill_button(scroll_content, entries[index], index)

	ScreenBuilder.add_spacer(content, 8)
	var actions := HBoxContainer.new()
	actions.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_theme_constant_override("separation", 10)
	content.add_child(actions)

	var country_button := ScreenBuilder.add_button(actions, "Change country")
	country_button.pressed.connect(_on_country_pressed)

	var menu_button := ScreenBuilder.add_button(actions, "Back to menu")
	menu_button.pressed.connect(_on_menu_pressed)

func _add_bill_button(parent: VBoxContainer, entry: Dictionary, index: int) -> void:
	var currency := str(entry.get("currency", ""))
	var denomination := str(entry.get("denomination", ""))
	var button := ScreenBuilder.add_button(parent, "%s %s" % [currency, denomination])
	button.pressed.connect(_on_bill_pressed.bind(index))

func _on_bill_pressed(index: int) -> void:
	AppState.select_bill(index)
	AppState.go_to_scene(BILL_VIEWER_SCENE)

func _on_country_pressed() -> void:
	AppState.go_to_scene(COUNTRY_SELECTOR_SCENE)

func _on_menu_pressed() -> void:
	AppState.go_to_scene(MAIN_MENU_SCENE)

