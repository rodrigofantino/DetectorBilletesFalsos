extends Node

const DATA_PATH := "res://data/currencyinfo.json"
const SETTINGS_PATH := "user://settings.cfg"
const APP_VERSION := "V.1.621"
const DEFAULT_LOCALE := "en"
const SUPPORTED_LOCALES := ["en", "es", "pt", "zh"]
const ABOUT_UPDATE_SUMMARY := {
	"en": "Refreshed banknote artwork and improved external source opening.",
	"es": "Se actualizaron imagenes de billetes y se mejoro la apertura de fuentes externas.",
	"pt": "Imagens de notas atualizadas e abertura de fontes externas melhorada.",
	"zh": "Banknote artwork refreshed and external source opening improved."
}

const UI_TEXTS := {
	"en": {
		"app_title": "Counterfeit Banknote Detector",
		"boot_subtitle": "Booting the app...",
		"back": "Back",
		"previous": "Previous",
		"next": "Next",
		"close": "Close",
		"select_country_title": "Select a country",
		"country_hint": "Choose a country to browse the notes and their security details.",
		"currency_info_title": "Currency info",
		"country_prefix": "Country: %s",
		"no_notes_found": "No notes found for this country.",
		"open_official_source": "Open official source",
		"security_features": "Security features",
		"open_note_viewer": "Open note viewer",
		"thumbnail": "Thumbnail",
		"thumbnail_preview": "Thumbnail preview",
		"no_note_selected": "No note selected",
		"note_viewer_status": "The viewer uses data-driven note details and country-matched images.",
		"watermark_prefix": "Watermark: %s",
		"source_prefix": "Source: %s",
		"uv_title": "UV detector",
		"uv_message": "Place the phone over the bill in a dark area. The screen stays bright and blue-violet to mimic UV inspection.",
		"watermark_title": "Watermark viewer",
		"watermark_message": "The color cycle helps reveal watermark and paper changes when the bill is held in front of the screen.",
		"pause": "Pause",
		"resume": "Resume",
		"menu_uv": "UV detector",
		"menu_watermark": "Watermark viewer",
		"menu_currency": "Currency info",
		"menu_about": "About",
		"menu_exit": "Exit",
		"language_label": "Language",
		"follow_phone_language": "Follow phone language",
		"menu_subtitle": "UV light, watermark checking, and currency info in one app.",
		"about_title": "About",
		"about_version_label": "Version: %s",
		"about_update_label": "Last update: %s",
		"about_body": "This port focuses on the three core tools: UV detector, watermark viewer, and currency info browser."
	},
	"es": {
		"app_title": "Detector de Billetes Falsos",
		"boot_subtitle": "Iniciando la app...",
		"back": "Atrás",
		"previous": "Anterior",
		"next": "Siguiente",
		"close": "Cerrar",
		"select_country_title": "Elegir país",
		"country_hint": "Elegí un país para recorrer los billetes y sus medidas de seguridad.",
		"currency_info_title": "Información de moneda",
		"country_prefix": "País: %s",
		"no_notes_found": "No se encontraron billetes para este país.",
		"open_official_source": "Abrir fuente oficial",
		"security_features": "Medidas de seguridad",
		"open_note_viewer": "Abrir visor de billete",
		"thumbnail": "Miniatura",
		"thumbnail_preview": "Vista previa",
		"no_note_selected": "No hay billete seleccionado",
		"note_viewer_status": "El visor usa datos dinámicos y miniaturas correctas para cada país.",
		"watermark_prefix": "Marca de agua: %s",
		"source_prefix": "Fuente: %s",
		"uv_title": "Detector UV",
		"uv_message": "Colocá el teléfono sobre el billete en un lugar oscuro. La pantalla se mantiene brillante en azul/violeta para simular la inspección UV.",
		"watermark_title": "Visor de marca de agua",
		"watermark_message": "El ciclo de colores ayuda a revelar cambios de marca de agua y papel cuando el billete se coloca frente a la pantalla.",
		"pause": "Pausar",
		"resume": "Reanudar",
		"menu_uv": "Detector UV",
		"menu_watermark": "Visor de marca de agua",
		"menu_currency": "Información de moneda",
		"menu_about": "Acerca de",
		"menu_exit": "Salir",
		"language_label": "Idioma",
		"follow_phone_language": "Seguir idioma del teléfono",
		"menu_subtitle": "Luz UV, marca de agua e información de moneda en una sola app.",
		"about_title": "Acerca de",
		"about_version_label": "Versión: %s",
		"about_update_label": "Última actualización: %s",
		"about_body": "Este port se centra en las tres herramientas principales: detector UV, visor de marca de agua y navegador de información de billetes."
	},
	"pt": {
		"app_title": "Detector de Cédulas Falsas",
		"boot_subtitle": "Iniciando o app...",
		"back": "Voltar",
		"previous": "Anterior",
		"next": "Próximo",
		"close": "Fechar",
		"select_country_title": "Escolha um país",
		"country_hint": "Escolha um país para navegar pelas cédulas e seus detalhes de segurança.",
		"currency_info_title": "Informações da moeda",
		"country_prefix": "País: %s",
		"no_notes_found": "Nenhuma cédula encontrada para este país.",
		"open_official_source": "Abrir fonte oficial",
		"security_features": "Recursos de segurança",
		"open_note_viewer": "Abrir visualizador da nota",
		"thumbnail": "Miniatura",
		"thumbnail_preview": "Prévia da miniatura",
		"no_note_selected": "Nenhuma nota selecionada",
		"note_viewer_status": "O visualizador usa detalhes de notas baseados em dados e imagens correspondentes ao país.",
		"watermark_prefix": "Marca-d'água: %s",
		"source_prefix": "Fonte: %s",
		"uv_title": "Detector UV",
		"uv_message": "Coloque o telefone sobre a cédula em um local escuro. A tela fica brilhante em azul/violeta para simular a inspeção UV.",
		"watermark_title": "Visualizador de marca-d'água",
		"watermark_message": "O ciclo de cores ajuda a revelar mudanças na marca-d'água e no papel quando a cédula fica na frente da tela.",
		"pause": "Pausar",
		"resume": "Continuar",
		"menu_uv": "Detector UV",
		"menu_watermark": "Visualizador de marca-d'água",
		"menu_currency": "Informações da moeda",
		"menu_about": "Sobre",
		"menu_exit": "Sair",
		"language_label": "Idioma",
		"follow_phone_language": "Usar idioma do telefone",
		"menu_subtitle": "Luz UV, checagem de marca-d'água e informação de cédulas em um app.",
		"about_title": "Sobre",
		"about_version_label": "Versão: %s",
		"about_update_label": "Última atualização: %s",
		"about_body": "Este port foca nas três ferramentas principais: detector UV, visualizador de marca-d'água e navegador de informações de cédulas."
	},
	"zh": {
		"app_title": "假钞检测器",
		"boot_subtitle": "正在启动应用...",
		"back": "返回",
		"previous": "上一张",
		"next": "下一张",
		"close": "关闭",
		"select_country_title": "选择国家",
		"country_hint": "选择一个国家以浏览纸币及其安全特征。",
		"currency_info_title": "货币信息",
		"country_prefix": "国家：%s",
		"no_notes_found": "该国家没有可用纸币。",
		"open_official_source": "打开官方来源",
		"security_features": "防伪特征",
		"open_note_viewer": "打开纸币查看器",
		"thumbnail": "缩略图",
		"thumbnail_preview": "缩略图预览",
		"no_note_selected": "未选择纸币",
		"note_viewer_status": "查看器使用数据驱动的纸币详情和与国家匹配的图像。",
		"watermark_prefix": "水印：%s",
		"source_prefix": "来源：%s",
		"uv_title": "UV 检测器",
		"uv_message": "把手机放在纸币上方的暗处。屏幕会保持蓝紫色高亮，以模拟紫外检测。",
		"watermark_title": "水印查看器",
		"watermark_message": "颜色循环有助于观察纸币放到屏幕前时的水印和纸张变化。",
		"pause": "暂停",
		"resume": "继续",
		"menu_uv": "UV 检测器",
		"menu_watermark": "水印查看器",
		"menu_currency": "货币信息",
		"menu_about": "关于",
		"menu_exit": "退出",
		"language_label": "语言",
		"follow_phone_language": "跟随手机语言",
		"menu_subtitle": "在一个应用里提供 UV 光、看水印和货币信息。",
		"about_title": "关于",
		"about_version_label": "版本：%s",
		"about_update_label": "最近更新：%s",
		"about_body": "这个移植版专注于三个核心功能：UV 检测器、水印查看器和纸币信息浏览。"
	}
}

const COUNTRY_LABELS := {
	"en": {
		"Argentina": "Argentina",
		"Brazil": "Brazil",
		"Chile": "Chile",
		"Canada": "Canada",
		"Australia": "Australia",
		"New Zealand": "New Zealand",
		"Japan": "Japan",
		"India": "India",
		"South Africa": "South Africa",
		"Switzerland": "Switzerland",
		"South Korea": "South Korea",
		"Hong Kong": "Hong Kong",
		"Philippines": "Philippines",
		"United States": "United States",
		"Eurozone": "Eurozone",
		"Colombia": "Colombia",
		"China": "China",
		"Mexico": "Mexico",
		"Peru": "Peru",
		"United Kingdom": "United Kingdom"
	},
	"es": {
		"Argentina": "Argentina",
		"Brazil": "Brasil",
		"Chile": "Chile",
		"Canada": "Canada",
		"Australia": "Australia",
		"New Zealand": "Nueva Zelanda",
		"Japan": "Japón",
		"India": "India",
		"South Africa": "Sudáfrica",
		"Switzerland": "Suiza",
		"South Korea": "Corea del Sur",
		"Hong Kong": "Hong Kong",
		"Philippines": "Filipinas",
		"United States": "Estados Unidos",
		"Eurozone": "Zona euro",
		"Colombia": "Colombia",
		"China": "China",
		"Mexico": "Mexico",
		"Peru": "Peru",
		"United Kingdom": "Reino Unido"
	},
	"pt": {
		"Argentina": "Argentina",
		"Brazil": "Brasil",
		"Chile": "Chile",
		"Canada": "Canadá",
		"Australia": "Austrália",
		"New Zealand": "Nova Zelândia",
		"Japan": "Japão",
		"India": "Índia",
		"South Africa": "África do Sul",
		"Switzerland": "Suíça",
		"South Korea": "Coreia do Sul",
		"Hong Kong": "Hong Kong",
		"Philippines": "Filipinas",
		"United States": "Estados Unidos",
		"Eurozone": "Zona do euro",
		"Colombia": "Colômbia",
		"China": "China",
		"Mexico": "México",
		"Peru": "Peru",
		"United Kingdom": "Reino Unido"
	},
	"zh": {
		"Argentina": "阿根廷",
		"Brazil": "巴西",
		"Chile": "智利",
		"Canada": "加拿大",
		"Australia": "澳大利亚",
		"New Zealand": "新西兰",
		"Japan": "日本",
		"India": "印度",
		"South Africa": "南非",
		"Switzerland": "瑞士",
		"South Korea": "韩国",
		"Hong Kong": "香港",
		"Philippines": "菲律宾",
		"United States": "美国",
		"Eurozone": "欧元区",
		"Colombia": "哥伦比亚",
		"China": "中国",
		"Mexico": "墨西哥",
		"Peru": "秘鲁",
		"United Kingdom": "英国"
	}
}

const CURRENCY_LABELS := {
	"en": {
		"ars": "Argentine peso",
		"brl": "real",
		"clp": "Chilean peso",
		"cad": "Canadian dollar",
		"aud": "Australian dollar",
		"nzd": "New Zealand dollar",
		"jpy": "yen",
		"inr": "Indian rupee",
		"zar": "rand",
		"chf": "Swiss franc",
		"krw": "won",
		"hkd": "Hong Kong dollar",
		"php": "Philippine peso",
		"usd": "U.S. dollar",
		"eur": "euro",
		"cop": "Colombian peso",
		"cny": "yuan",
		"gbp": "pound sterling",
		"mxn": "Mexican peso",
		"pen": "sol",
		"pei": "inti"
	},
	"es": {
		"ars": "peso argentino",
		"brl": "real",
		"clp": "peso chileno",
		"cad": "dólar canadiense",
		"aud": "dólar australiano",
		"nzd": "dólar neozelandés",
		"jpy": "yen",
		"inr": "rupia india",
		"zar": "rand",
		"chf": "franco suizo",
		"krw": "won",
		"hkd": "dólar de Hong Kong",
		"php": "peso filipino",
		"usd": "dolar estadounidense",
		"eur": "euro",
		"cop": "peso colombiano",
		"cny": "yuan",
		"gbp": "libra esterlina",
		"mxn": "peso mexicano",
		"pen": "sol",
		"pei": "inti"
	},
	"pt": {
		"ars": "peso argentino",
		"brl": "real",
		"clp": "peso chileno",
		"cad": "dólar canadense",
		"aud": "dólar australiano",
		"nzd": "dólar neozelandês",
		"jpy": "iene",
		"inr": "rupia indiana",
		"zar": "rand",
		"chf": "franco suíço",
		"krw": "won",
		"hkd": "dólar de Hong Kong",
		"php": "peso filipino",
		"usd": "dólar americano",
		"eur": "euro",
		"cop": "peso colombiano",
		"cny": "yuan",
		"gbp": "libra esterlina",
		"mxn": "peso mexicano",
		"pen": "sol",
		"pei": "inti"
	},
	"zh": {
		"ars": "阿根廷比索",
		"brl": "雷亚尔",
		"clp": "智利比索",
		"cad": "加拿大元",
		"aud": "澳大利亚元",
		"nzd": "新西兰元",
		"jpy": "日元",
		"inr": "印度卢比",
		"zar": "兰特",
		"chf": "瑞士法郎",
		"krw": "韩元",
		"hkd": "港元",
		"php": "菲律宾比索",
		"usd": "美元",
		"eur": "欧元",
		"cop": "哥伦比亚比索",
		"cny": "人民币",
		"gbp": "英镑",
		"mxn": "墨西哥比索",
		"pen": "索尔",
		"pei": "inti"
	}
}

const COUNTRY_IMAGE_PATHS := {
	"Argentina": "res://assets/bills_official/ar_10000_front.jpg",
	"Brazil": "res://assets/bills_official/br_100_front.jpg",
	"Chile": "res://assets/bills_official/cl_10000_front.jpg",
	"Canada": "res://assets/bills_official/ca_20_front.jpg",
	"Australia": "res://assets/bills_official/au_50_front.jpg",
	"New Zealand": "res://assets/bills_official/nz_100_front.png",
	"Japan": "res://assets/bills_official/jp_10000_front.png",
	"India": "res://assets/bills_official/in_500_front.png",
	"South Africa": "res://assets/bills_official/za_200_front.png",
	"Switzerland": "res://assets/bills_official/ch_100_front.jpg",
	"South Korea": "res://assets/bills_official/kr_50000_front.jpg",
	"Hong Kong": "res://assets/bills_official/hk_10_front.jpg",
	"Philippines": "res://assets/bills_official/ph_1000_front.jpg",
	"United States": "res://assets/bills_official/us_100_front.jpg",
	"Eurozone": "res://assets/bills_official/eu_100_front.jpg",
	"Colombia": "res://assets/bills_official/co_100000_front.jpg",
	"China": "res://assets/bills_official/cn_100_front.jpg",
	"Mexico": "res://assets/bills_official/mx_500_front.png",
	"Peru": "res://assets/bills_official/pe_100000_front.png",
	"United Kingdom": "res://assets/bills_official/gb_20_front.jpg"
}

const COUNTRY_ACCENT_COLORS := {
	"Argentina": Color("#2c7be5"),
	"Brazil": Color("#16a085"),
	"Chile": Color("#1abc9c"),
	"Canada": Color("#d32f2f"),
	"Australia": Color("#ff8f00"),
	"New Zealand": Color("#2e7d32"),
	"Japan": Color("#b71c1c"),
	"India": Color("#ef6c00"),
	"South Africa": Color("#00695c"),
	"Switzerland": Color("#6a1b9a"),
	"South Korea": Color("#1565c0"),
	"Hong Kong": Color("#c2185b"),
	"Philippines": Color("#00838f"),
	"United States": Color("#1f3a93"),
	"Eurozone": Color("#8e44ad"),
	"Colombia": Color("#f4b400"),
	"China": Color("#c0392b"),
	"Mexico": Color("#2ecc71"),
	"Peru": Color("#d35400"),
	"United Kingdom": Color("#5d6d7e")
}

var currency_entries: Array[Dictionary] = []
var selected_country: String = ""
var selected_note_index: int = 0
var tool_screen_holds: int = 0
var current_locale: String = DEFAULT_LOCALE
var locale_override: String = ""


func _ready() -> void:
	load_user_settings()
	_apply_locale()
	load_currency_data()


func set_locale_from_system() -> void:
	locale_override = ""
	_apply_locale()


func set_locale_code(raw_locale: String) -> void:
	var locale := _normalize_locale(raw_locale)
	if not SUPPORTED_LOCALES.has(locale):
		locale = DEFAULT_LOCALE
	current_locale = locale
	if TranslationServer.has_method("set_locale"):
		TranslationServer.set_locale(current_locale)


func set_locale_override(locale_code: String) -> void:
	var locale := _normalize_locale(locale_code)
	if not SUPPORTED_LOCALES.has(locale):
		locale = DEFAULT_LOCALE
	locale_override = locale
	_apply_locale()
	save_user_settings()


func clear_locale_override() -> void:
	locale_override = ""
	_apply_locale()
	save_user_settings()


func uses_phone_locale() -> bool:
	return locale_override.is_empty()


func get_supported_locales() -> Array[String]:
	var locales: Array[String] = []
	for locale in SUPPORTED_LOCALES:
		locales.append(str(locale))
	return locales


func get_locale_display_name(locale_code: String) -> String:
	match _normalize_locale(locale_code):
		"es":
			return "Español"
		"pt":
			return "Português"
		"zh":
			return "中文"
		_:
			return "English"


func get_locale_code() -> String:
	return current_locale


func get_app_version() -> String:
	return APP_VERSION


func get_about_text() -> String:
	var update_text := str(ABOUT_UPDATE_SUMMARY.get(current_locale, ABOUT_UPDATE_SUMMARY[DEFAULT_LOCALE]))
	var version_line := t("about_version_label") % APP_VERSION
	var update_line := t("about_update_label") % update_text
	return "%s\n%s" % [version_line, update_line]


func t(key: String) -> String:
	var locale_map: Dictionary = UI_TEXTS.get(current_locale, UI_TEXTS[DEFAULT_LOCALE])
	if locale_map.has(key):
		return str(locale_map.get(key, key))
	return str(UI_TEXTS[DEFAULT_LOCALE].get(key, key))


func load_currency_data() -> void:
	currency_entries.clear()
	if not FileAccess.file_exists(DATA_PATH):
		push_error("Currency data not found: %s" % DATA_PATH)
		return

	var raw := FileAccess.get_file_as_string(DATA_PATH)
	var parsed: Variant = JSON.parse_string(raw)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Currency data is not a dictionary.")
		return

	var list: Array = (parsed as Dictionary).get("CurrencyInfo", [])
	if typeof(list) != TYPE_ARRAY:
		push_error("Currency data does not contain CurrencyInfo array.")
		return

	for item in list:
		if typeof(item) == TYPE_DICTIONARY:
			currency_entries.append(item)

	if selected_country.is_empty() and not currency_entries.is_empty():
		selected_country = str(currency_entries[0].get("country", ""))


func get_countries() -> Array[String]:
	var seen: Dictionary = {}
	for entry in currency_entries:
		var country := str(entry.get("country", "")).strip_edges()
		if not country.is_empty():
			seen[country] = true

	var countries: Array[String] = []
	for key in seen.keys():
		countries.append(str(key))
	countries.sort_custom(Callable(self, "_compare_country_labels"))
	return countries


func get_country_label(country: String) -> String:
	var locale_map: Dictionary = COUNTRY_LABELS.get(current_locale, COUNTRY_LABELS[DEFAULT_LOCALE])
	return str(locale_map.get(country, COUNTRY_LABELS[DEFAULT_LOCALE].get(country, humanize_key(country))))


func get_currency_label(code: String) -> String:
	var locale_map: Dictionary = CURRENCY_LABELS.get(current_locale, CURRENCY_LABELS[DEFAULT_LOCALE])
	return str(locale_map.get(code, CURRENCY_LABELS[DEFAULT_LOCALE].get(code, humanize_key(code))))


func set_selected_country(country: String) -> void:
	selected_country = country
	selected_note_index = 0


func get_selected_notes() -> Array[Dictionary]:
	return get_notes_for_country(selected_country)


func get_notes_for_country(country: String) -> Array[Dictionary]:
	var notes: Array[Dictionary] = []
	for entry in currency_entries:
		if str(entry.get("country", "")) == country:
			notes.append(entry)
	return notes


func get_selected_note() -> Dictionary:
	var notes := get_selected_notes()
	if notes.is_empty():
		return {}
	return notes[clampi(selected_note_index, 0, notes.size() - 1)]


func set_selected_note_index(index: int) -> void:
	var notes := get_selected_notes()
	if notes.is_empty():
		selected_note_index = 0
		return
	selected_note_index = posmod(index, notes.size())


func get_note_title(note: Dictionary) -> String:
	var country := get_country_label(str(note.get("country", "")))
	var denomination := str(note.get("denomination", ""))
	var currency := get_currency_label(str(note.get("currency", "")))
	return "%s - %s %s" % [country, denomination, currency]


func get_note_summary(note: Dictionary) -> String:
	var summary := _get_localized_note_string(note, "summary_text")
	if not summary.is_empty():
		return summary
	var key := str(note.get("description", ""))
	return humanize_key(key)


func get_note_watermark(note: Dictionary) -> String:
	var text := _get_localized_note_string(note, "watermark_text")
	if not text.is_empty():
		return text
	var key := str(note.get("watermark", ""))
	return humanize_key(key)


func get_note_badge(note: Dictionary) -> String:
	var denomination := str(note.get("denomination", ""))
	var currency := get_currency_label(str(note.get("currency", "")))
	return "%s %s" % [denomination, currency]


func get_note_texture_path(note: Dictionary) -> String:
	var image_path := str(note.get("image_path", "")).strip_edges()
	if not image_path.is_empty():
		return image_path

	var country := str(note.get("country", ""))
	return str(COUNTRY_IMAGE_PATHS.get(country, "")).strip_edges()


func get_country_accent_color(country: String) -> Color:
	return COUNTRY_ACCENT_COLORS.get(country, Color("#334155"))


func get_note_features(note: Dictionary) -> Array[String]:
	var localized: Variant = note.get("security_features_texts")
	if localized is Dictionary:
		var localized_array: Variant = _get_localized_variant(localized as Dictionary)
		if localized_array is Array:
			var localized_features: Array[String] = []
			for item in localized_array:
				var feature := str(item).strip_edges()
				if not feature.is_empty():
					localized_features.append(feature)
			if not localized_features.is_empty():
				return localized_features

	var raw: Variant = note.get("security_features", [])
	var features: Array[String] = []
	if raw is Array:
		for item in raw:
			var feature := str(item).strip_edges()
			if not feature.is_empty():
				features.append(feature)
	return features


func get_note_source(note: Dictionary) -> String:
	return str(note.get("source", "")).strip_edges()


func get_note_source_url(note: Dictionary) -> String:
	return str(note.get("source_url", "")).strip_edges()


func humanize_key(key: String) -> String:
	if key.is_empty():
		return ""

	var cleaned := key.replace("_", " ")
	var words := cleaned.split(" ", false)
	for i in words.size():
		words[i] = str(words[i]).capitalize()
	return " ".join(words)


func _compare_country_labels(a: String, b: String) -> bool:
	return get_country_label(a) < get_country_label(b)


func _apply_locale() -> void:
	if locale_override.is_empty():
		set_locale_code(OS.get_locale())
	else:
		set_locale_code(locale_override)


func _normalize_locale(raw_locale: String) -> String:
	var cleaned := raw_locale.strip_edges().to_lower().replace("-", "_")
	if cleaned.is_empty():
		return DEFAULT_LOCALE

	if cleaned.begins_with("zh"):
		return "zh"

	var language := cleaned.split("_", false, 1)[0]
	if language == "es" or language == "pt" or language == "en":
		return language
	return DEFAULT_LOCALE


func save_user_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("locale", "override", locale_override)
	var err := config.save(SETTINGS_PATH)
	if err != OK:
		push_warning("Could not save locale settings: %s" % err)


func load_user_settings() -> void:
	var config := ConfigFile.new()
	var err := config.load(SETTINGS_PATH)
	if err != OK:
		locale_override = ""
		return

	var value := str(config.get_value("locale", "override", "")).strip_edges()
	if value.is_empty():
		locale_override = ""
		return

	var locale := _normalize_locale(value)
	if SUPPORTED_LOCALES.has(locale):
		locale_override = locale
	else:
		locale_override = ""


func _get_localized_note_string(note: Dictionary, base_key: String) -> String:
	var locale_key: String = "%ss" % base_key
	var localized: Variant = note.get(locale_key)
	if localized is Dictionary:
		var localized_value: Variant = _get_localized_variant(localized as Dictionary)
		if localized_value is String:
			return str(localized_value).strip_edges()
	var fallback: String = str(note.get(base_key, "")).strip_edges()
	return fallback


func _get_localized_variant(values: Dictionary) -> Variant:
	if values.has(current_locale):
		return values.get(current_locale)
	if values.has(DEFAULT_LOCALE):
		return values.get(DEFAULT_LOCALE)
	var variants: Array = values.values()
	if not variants.is_empty():
		return variants[0]
	return ""


func acquire_tool_screen() -> void:
	tool_screen_holds += 1
	_apply_tool_screen_state()


func release_tool_screen() -> void:
	tool_screen_holds = maxi(tool_screen_holds - 1, 0)
	_apply_tool_screen_state()


func _apply_tool_screen_state() -> void:
	if DisplayServer.has_method("screen_set_keep_on"):
		DisplayServer.screen_set_keep_on(tool_screen_holds > 0)
