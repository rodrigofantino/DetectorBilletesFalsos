extends Node

const DATA_PATH := "res://data/currencyinfo.json"
const SETTINGS_PATH := "user://settings.cfg"
const APP_VERSION := "V.319"
const DEFAULT_LOCALE := "en"
const SUPPORTED_LOCALES := ["en", "es", "pt", "zh"]
const ABOUT_UPDATE_SUMMARY := {
	"en": "Refreshed official banknote images and improved viewer scaling.",
	"es": "Se actualizaron las imagenes oficiales de billetes y se mejoro la escala del visor.",
	"pt": "As imagens oficiais de cedulas foram atualizadas e o zoom do visor foi melhorado.",
	"zh": "已刷新官方纸币图片并改进查看器缩放。"
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
		"menu_help": "Help",
		"menu_about": "About",
		"menu_exit": "Exit",
		"language_label": "Language",
		"follow_phone_language": "Follow phone language",
		"menu_subtitle": "UV light, watermark checking, and currency info in one app.",
		"menu_baseline": "Portrait-first, offline-friendly, no ads.",
		"help_title": "How to use",
		"help_body": "Put a bill on the screen and check the UV tone or the watermark colors.\nUse a dark place for the UV mode and keep the phone screen at maximum brightness.",
		"about_title": "About",
		"about_version_label": "Version: %s",
		"about_update_label": "Last update: %s",
		"about_body": "This port focuses on the three core tools: UV detector, watermark viewer, and currency info browser."
	},
	"es": {
		"app_title": "Detector de Billetes Falsos",
		"boot_subtitle": "Iniciando la app...",
		"back": "AtrÃ¡s",
		"previous": "Anterior",
		"next": "Siguiente",
		"close": "Cerrar",
		"select_country_title": "Elegir paÃ­s",
		"country_hint": "ElegÃ­ un paÃ­s para recorrer los billetes y sus medidas de seguridad.",
		"currency_info_title": "InformaciÃ³n de moneda",
		"country_prefix": "PaÃ­s: %s",
		"no_notes_found": "No se encontraron billetes para este paÃ­s.",
		"open_official_source": "Abrir fuente oficial",
		"security_features": "Medidas de seguridad",
		"open_note_viewer": "Abrir visor de billete",
		"thumbnail": "Miniatura",
		"thumbnail_preview": "Vista previa",
		"no_note_selected": "No hay billete seleccionado",
		"note_viewer_status": "El visor usa datos dinÃ¡micos y miniaturas correctas para cada paÃ­s.",
		"watermark_prefix": "Marca de agua: %s",
		"source_prefix": "Fuente: %s",
		"uv_title": "Detector UV",
		"uv_message": "ColocÃ¡ el telÃ©fono sobre el billete en un lugar oscuro. La pantalla se mantiene brillante en azul/violeta para simular la inspecciÃ³n UV.",
		"watermark_title": "Visor de marca de agua",
		"watermark_message": "El ciclo de colores ayuda a revelar cambios de marca de agua y papel cuando el billete se coloca frente a la pantalla.",
		"pause": "Pausar",
		"resume": "Reanudar",
		"menu_uv": "Detector UV",
		"menu_watermark": "Visor de marca de agua",
		"menu_currency": "InformaciÃ³n de moneda",
		"menu_help": "Ayuda",
		"menu_about": "Acerca de",
		"menu_exit": "Salir",
		"language_label": "Idioma",
		"follow_phone_language": "Seguir idioma del telÃ©fono",
		"menu_subtitle": "Luz UV, marca de agua e informaciÃ³n de moneda en una sola app.",
		"menu_baseline": "Port sin publicidad, pensado para vertical.",
		"help_title": "CÃ³mo usar",
		"help_body": "PonÃ© un billete sobre la pantalla y revisÃ¡ el tono UV o los colores de la marca de agua.\nUsÃ¡ un lugar oscuro para el modo UV y mantenÃ© el brillo del telÃ©fono al mÃ¡ximo.",
		"about_title": "Acerca de",
		"about_version_label": "VersiÃ³n: %s",
		"about_update_label": "Ãšltima actualizaciÃ³n: %s",
		"about_body": "Este port se centra en las tres herramientas principales: detector UV, visor de marca de agua y navegador de informaciÃ³n de billetes."
	},
	"pt": {
		"app_title": "Detector de CÃ©dulas Falsas",
		"boot_subtitle": "Iniciando o app...",
		"back": "Voltar",
		"previous": "Anterior",
		"next": "PrÃ³ximo",
		"close": "Fechar",
		"select_country_title": "Escolha um paÃ­s",
		"country_hint": "Escolha um paÃ­s para navegar pelas cÃ©dulas e seus detalhes de seguranÃ§a.",
		"currency_info_title": "InformaÃ§Ãµes da moeda",
		"country_prefix": "PaÃ­s: %s",
		"no_notes_found": "Nenhuma cÃ©dula encontrada para este paÃ­s.",
		"open_official_source": "Abrir fonte oficial",
		"security_features": "Recursos de seguranÃ§a",
		"open_note_viewer": "Abrir visualizador da nota",
		"thumbnail": "Miniatura",
		"thumbnail_preview": "PrÃ©via da miniatura",
		"no_note_selected": "Nenhuma nota selecionada",
		"note_viewer_status": "O visualizador usa detalhes de notas baseados em dados e imagens correspondentes ao paÃ­s.",
		"watermark_prefix": "Marca-d'Ã¡gua: %s",
		"source_prefix": "Fonte: %s",
		"uv_title": "Detector UV",
		"uv_message": "Coloque o telefone sobre a cÃ©dula em um local escuro. A tela fica brilhante em azul/violeta para simular a inspeÃ§Ã£o UV.",
		"watermark_title": "Visualizador de marca-d'Ã¡gua",
		"watermark_message": "O ciclo de cores ajuda a revelar mudanÃ§as na marca-d'Ã¡gua e no papel quando a cÃ©dula fica na frente da tela.",
		"pause": "Pausar",
		"resume": "Continuar",
		"menu_uv": "Detector UV",
		"menu_watermark": "Visualizador de marca-d'Ã¡gua",
		"menu_currency": "InformaÃ§Ãµes da moeda",
		"menu_help": "Ajuda",
		"menu_about": "Sobre",
		"menu_exit": "Sair",
		"language_label": "Idioma",
		"follow_phone_language": "Usar idioma do telefone",
		"menu_subtitle": "Luz UV, checagem de marca-d'Ã¡gua e informaÃ§Ã£o de cÃ©dulas em um app.",
		"menu_baseline": "Porta ad-free, priorizando retrato.",
		"help_title": "Como usar",
		"help_body": "Coloque uma cÃ©dula sobre a tela e confira o tom UV ou as cores da marca-d'Ã¡gua.\nUse um lugar escuro para o modo UV e mantenha o brilho do telefone no mÃ¡ximo.",
		"about_title": "Sobre",
		"about_version_label": "VersÃ£o: %s",
		"about_update_label": "Ãšltima atualizaÃ§Ã£o: %s",
		"about_body": "Este port foca nas trÃªs ferramentas principais: detector UV, visualizador de marca-d'Ã¡gua e navegador de informaÃ§Ãµes de cÃ©dulas."
	},
	"zh": {
		"app_title": "å‡é’žæ£€æµ‹å™¨",
		"boot_subtitle": "æ­£åœ¨å¯åŠ¨åº”ç”¨...",
		"back": "è¿”å›ž",
		"previous": "ä¸Šä¸€å¼ ",
		"next": "ä¸‹ä¸€å¼ ",
		"close": "å…³é—­",
		"select_country_title": "é€‰æ‹©å›½å®¶",
		"country_hint": "é€‰æ‹©ä¸€ä¸ªå›½å®¶ä»¥æµè§ˆçº¸å¸åŠå…¶å®‰å…¨ç‰¹å¾ã€‚",
		"currency_info_title": "è´§å¸ä¿¡æ¯",
		"country_prefix": "å›½å®¶ï¼š%s",
		"no_notes_found": "è¯¥å›½å®¶æ²¡æœ‰å¯ç”¨çº¸å¸ã€‚",
		"open_official_source": "æ‰“å¼€å®˜æ–¹æ¥æº",
		"security_features": "é˜²ä¼ªç‰¹å¾",
		"open_note_viewer": "æ‰“å¼€çº¸å¸æŸ¥çœ‹å™¨",
		"thumbnail": "ç¼©ç•¥å›¾",
		"thumbnail_preview": "ç¼©ç•¥å›¾é¢„è§ˆ",
		"no_note_selected": "æœªé€‰æ‹©çº¸å¸",
		"note_viewer_status": "æŸ¥çœ‹å™¨ä½¿ç”¨æ•°æ®é©±åŠ¨çš„çº¸å¸è¯¦æƒ…å’Œä¸Žå›½å®¶åŒ¹é…çš„å›¾åƒã€‚",
		"watermark_prefix": "æ°´å°ï¼š%s",
		"source_prefix": "æ¥æºï¼š%s",
		"uv_title": "UV æ£€æµ‹å™¨",
		"uv_message": "æŠŠæ‰‹æœºæ”¾åœ¨çº¸å¸ä¸Šæ–¹çš„æš—å¤„ã€‚å±å¹•ä¼šä¿æŒè“ç´«è‰²é«˜äº®ï¼Œä»¥æ¨¡æ‹Ÿç´«å¤–æ£€æµ‹ã€‚",
		"watermark_title": "æ°´å°æŸ¥çœ‹å™¨",
		"watermark_message": "é¢œè‰²å¾ªçŽ¯æœ‰åŠ©äºŽè§‚å¯Ÿçº¸å¸æ”¾åˆ°å±å¹•å‰æ—¶çš„æ°´å°å’Œçº¸å¼ å˜åŒ–ã€‚",
		"pause": "æš‚åœ",
		"resume": "ç»§ç»­",
		"menu_uv": "UV æ£€æµ‹å™¨",
		"menu_watermark": "æ°´å°æŸ¥çœ‹å™¨",
		"menu_currency": "è´§å¸ä¿¡æ¯",
		"menu_help": "å¸®åŠ©",
		"menu_about": "å…³äºŽ",
		"menu_exit": "é€€å‡º",
		"language_label": "è¯­è¨€",
		"follow_phone_language": "è·Ÿéšæ‰‹æœºè¯­è¨€",
		"menu_subtitle": "åœ¨ä¸€ä¸ªåº”ç”¨é‡Œæä¾› UV å…‰ã€çœ‹æ°´å°å’Œè´§å¸ä¿¡æ¯ã€‚",
		"menu_baseline": "ä»¥ç«–å±å’Œæ— å¹¿å‘Šä½œä¸ºåŸºç¡€ç‰ˆæœ¬ã€‚",
		"help_title": "ä½¿ç”¨è¯´æ˜Ž",
		"help_body": "æŠŠçº¸å¸æ”¾åœ¨å±å¹•ä¸Šï¼ŒæŸ¥çœ‹ UV é¢œè‰²æˆ–æ°´å°é¢œè‰²ã€‚\nUV æ¨¡å¼è¯·åœ¨é»‘æš—çŽ¯å¢ƒä½¿ç”¨ï¼Œå¹¶æŠŠæ‰‹æœºäº®åº¦è°ƒåˆ°æœ€å¤§ã€‚",
		"about_title": "å…³äºŽ",
		"about_version_label": "ç‰ˆæœ¬ï¼š%s",
		"about_update_label": "æœ€è¿‘æ›´æ–°ï¼š%s",
		"about_body": "è¿™ä¸ªç§»æ¤ç‰ˆä¸“æ³¨äºŽä¸‰ä¸ªæ ¸å¿ƒåŠŸèƒ½ï¼šUV æ£€æµ‹å™¨ã€æ°´å°æŸ¥çœ‹å™¨å’Œçº¸å¸ä¿¡æ¯æµè§ˆã€‚"
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
		"Japan": "JapÃ³n",
		"India": "India",
		"South Africa": "SudÃ¡frica",
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
		"Canada": "CanadÃ¡",
		"Australia": "AustrÃ¡lia",
		"New Zealand": "Nova ZelÃ¢ndia",
		"Japan": "JapÃ£o",
		"India": "Ãndia",
		"South Africa": "Ãfrica do Sul",
		"Switzerland": "SuÃ­Ã§a",
		"South Korea": "Coreia do Sul",
		"Hong Kong": "Hong Kong",
		"Philippines": "Filipinas",
		"United States": "Estados Unidos",
		"Eurozone": "Zona do euro",
		"Colombia": "ColÃ´mbia",
		"China": "China",
		"Mexico": "MÃ©xico",
		"Peru": "Peru",
		"United Kingdom": "Reino Unido"
	},
	"zh": {
		"Argentina": "é˜¿æ ¹å»·",
		"Brazil": "å·´è¥¿",
		"Chile": "æ™ºåˆ©",
		"Canada": "åŠ æ‹¿å¤§",
		"Australia": "æ¾³å¤§åˆ©äºš",
		"New Zealand": "æ–°è¥¿å…°",
		"Japan": "æ—¥æœ¬",
		"India": "å°åº¦",
		"South Africa": "å—éž",
		"Switzerland": "ç‘žå£«",
		"South Korea": "éŸ©å›½",
		"Hong Kong": "é¦™æ¸¯",
		"Philippines": "è²å¾‹å®¾",
		"United States": "ç¾Žå›½",
		"Eurozone": "æ¬§å…ƒåŒº",
		"Colombia": "å“¥ä¼¦æ¯”äºš",
		"China": "ä¸­å›½",
		"Mexico": "å¢¨è¥¿å“¥",
		"Peru": "ç§˜é²",
		"United Kingdom": "è‹±å›½"
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
		"pen": "sol"
	},
	"es": {
		"ars": "peso argentino",
		"brl": "real",
		"clp": "peso chileno",
		"cad": "dÃ³lar canadiense",
		"aud": "dÃ³lar australiano",
		"nzd": "dÃ³lar neozelandÃ©s",
		"jpy": "yen",
		"inr": "rupia india",
		"zar": "rand",
		"chf": "franco suizo",
		"krw": "won",
		"hkd": "dÃ³lar de Hong Kong",
		"php": "peso filipino",
		"usd": "dolar estadounidense",
		"eur": "euro",
		"cop": "peso colombiano",
		"cny": "yuan",
		"gbp": "libra esterlina",
		"mxn": "peso mexicano",
		"pen": "sol"
	},
	"pt": {
		"ars": "peso argentino",
		"brl": "real",
		"clp": "peso chileno",
		"cad": "dÃ³lar canadense",
		"aud": "dÃ³lar australiano",
		"nzd": "dÃ³lar neozelandÃªs",
		"jpy": "iene",
		"inr": "rupia indiana",
		"zar": "rand",
		"chf": "franco suÃ­Ã§o",
		"krw": "won",
		"hkd": "dÃ³lar de Hong Kong",
		"php": "peso filipino",
		"usd": "dÃ³lar americano",
		"eur": "euro",
		"cop": "peso colombiano",
		"cny": "yuan",
		"gbp": "libra esterlina",
		"mxn": "peso mexicano",
		"pen": "sol"
	},
	"zh": {
		"ars": "é˜¿æ ¹å»·æ¯”ç´¢",
		"brl": "é›·äºšå°”",
		"clp": "æ™ºåˆ©æ¯”ç´¢",
		"cad": "åŠ æ‹¿å¤§å…ƒ",
		"aud": "æ¾³å¤§åˆ©äºšå…ƒ",
		"nzd": "æ–°è¥¿å…°å…ƒ",
		"jpy": "æ—¥å…ƒ",
		"inr": "å°åº¦å¢æ¯”",
		"zar": "å…°ç‰¹",
		"chf": "ç‘žå£«æ³•éƒŽ",
		"krw": "éŸ©å…ƒ",
		"hkd": "æ¸¯å…ƒ",
		"php": "è²å¾‹å®¾æ¯”ç´¢",
		"usd": "ç¾Žå…ƒ",
		"eur": "æ¬§å…ƒ",
		"cop": "å“¥ä¼¦æ¯”äºšæ¯”ç´¢",
		"cny": "äººæ°‘å¸",
		"gbp": "è‹±é•‘",
		"mxn": "å¢¨è¥¿å“¥æ¯”ç´¢",
		"pen": "ç´¢å°”"
	}
}

const COUNTRY_IMAGE_PATHS := {
	"Argentina": "res://assets/bills_official/ar_10000_front.jpg",
	"Brazil": "res://assets/bills_official/br_100_front.jpg",
	"Chile": "res://assets/bills_official/cl_10000_front.jpg",
	"Canada": "res://assets/bills_official/ca_20_front.jpg",
	"Australia": "res://assets/bills_official/au_50_front.jpg",
	"New Zealand": "res://assets/bills_official/nz_100_front.jpg",
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
	"Peru": "res://assets/bills_official/pe_20000_front.jpg",
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
			return "EspaÃ±ol"
		"pt":
			return "PortuguÃªs"
		"zh":
			return "ä¸­æ–‡"
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
