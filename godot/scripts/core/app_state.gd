extends Node

const DATA_PATH := "res://data/currencyinfo.json"
const SETTINGS_PATH := "user://settings.cfg"
const APP_VERSION := "V.2.001"
const DEFAULT_LOCALE := "en"
const SUPPORTED_LOCALES := ["en", "es", "pt", "zh"]
const ABOUT_UPDATE_SUMMARY := {
	"en": "Improved readable UI styling, compact About content, configurable banner placements, and banknote information cards.",
	"es": "Mejoramos la legibilidad de la interfaz, compactamos Acerca de, configuramos las ubicaciones de banners y añadimos tarjetas de información de billetes.",
	"pt": "Melhoramos a legibilidade da interface, compactamos o conteúdo Sobre, configuramos os posicionamentos de banners e adicionamos cartões de informações sobre cédulas.",
	"zh": "优化了易读的界面样式、精简了“关于”内容、支持可配置的横幅广告位置，并新增了纸币信息卡片。"
}

const UI_TEXTS := {
	"en": {
		"app_title": "Banknote Security Guide",
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
		"show_banknote": "Show banknote",
		"thumbnail": "Thumbnail",
		"thumbnail_preview": "Thumbnail preview",
		"no_note_selected": "No note selected",
		"note_viewer_status": "The viewer uses data-driven note details and country-matched images.",
		"note_title_format": "%s — %s %s",
		"watermark_prefix": "Watermark: %s",
		"source_prefix": "Source: %s",
		"uv_title": "UV detector",
		"uv_message": "Use this violet screen only as a visual aid in a dark room. A phone does not emit real UV light; UV security features require an external UV lamp and visibility varies by device.",
		"watermark_title": "Watermark viewer",
		"watermark_message": "The color cycle helps reveal watermark and paper changes when the bill is held in front of the screen.",
		"pause": "Pause",
		"resume": "Resume",
		"menu_uv": "UV detector",
		"menu_watermark": "Watermark viewer",
		"menu_currency": "Currency info",
		"menu_about": "About",
		"menu_remove_ads": "Remove ads",
		"menu_exit": "Exit",
		"ads_removed": "Ads are already removed for this Google Play account.",
		"purchase_unavailable": "Purchases are unavailable until Google Play connects.",
		"purchase_failed": "Google Play could not start the purchase.",
		"purchase_pending": "The purchase is pending. Ads will be removed when payment is confirmed.",
		"language_label": "Language",
		"follow_phone_language": "Follow phone language",
		"menu_subtitle": "Check banknote security features step by step.",
		"about_title": "About",
		"about_version_label": "Version: %s",
		"about_update_label": "Last update: %s",
		"about_body": "This app provides an assisted review of banknote security references.",
		"rate_this_app": "Rate this app",
		"menu_guided_review": "Check security features",
		"menu_review_hint": "Follow the guide to check the banknote's security references. This app does not determine authenticity.",
		"menu_continue": "Continue",
		"menu_quick_tools": "Quick tools",
		"menu_explore": "Explore",
		"menu_more": "Settings",
		"guided_review_subtitle": "Review security features step by step.",
		"review_setup_title": "Start assisted review",
		"review_setup_intro": "Choose how to identify the banknote.",
		"review_disclaimer": "This assisted review does not fully determine authenticity.",
		"review_choose_method": "How would you like to identify the banknote?",
		"review_camera_option": "Use camera to identify it",
		"review_manual_option": "Choose country and denomination",
		"identify_camera": "Suggest from camera text",
		"camera_unavailable": "Camera text suggestions are unavailable. Choose the banknote manually.",
		"scan_processing": "Processing the image on this device…",
		"scan_candidates": "Experimental text matches. Confirm the correct banknote:",
		"scan_unknown": "No reliable match was found. Choose the banknote manually.",
		"scan_poor_quality": "We could not read the image. Try again with better light or choose manually.",
		"scan_permission_denied": "Camera permission was not granted. You can continue manually.",
		"scan_cancelled": "Capture cancelled. You can continue manually.",
		"choose_country": "Country",
		"choose_banknote": "Banknote",
		"start_review": "Start review",
		"review_title": "Security review",
		"generic_guide_notice": "This model does not yet have a structured guide. We will compare its registered common references.",
		"step_progress": "Step %d of %d",
		"step_compare_title": "Compare this reference",
		"step_compare_instruction": "Inspect the banknote and compare this registered security reference.",
		"review_reference_caption": "Official front reference — locate the feature described above.",
		"observed": "I observe it",
		"mismatch": "It does not match",
		"unable": "I cannot check it",
		"review_result_title": "Review completed",
		"result_observed": "Signals observed: %d",
		"result_mismatch": "Do not match: %d",
		"result_unable": "Not checked: %d",
		"review_result_advice": "If you still have doubts, do not recirculate the banknote and consult its issuer or a financial institution.",
		"review_another": "Review another banknote",
		"return_home": "Return to home",
		"add_favorite": "Add to favorites",
		"remove_favorite": "Remove from favorites",
		"analytics_consent_title": "Help improve the app",
		"analytics_consent_body": "Allow basic usage analytics? Photos, recognized text, serial numbers, selected banknotes, and review answers are never sent.",
		"analytics_allow": "Allow",
		"analytics_decline": "Not now",
		"analytics_enable": "Enable usage analytics",
		"analytics_disable": "Disable usage analytics",
		"menu_library": "Recent and favorites",
		"library_title": "Your banknotes",
		"library_recent": "Recently reviewed",
		"library_favorites": "Favorites",
		"library_empty": "Complete a review or add a favorite to see it here.",
		"clear_history": "Clear recent history"
	},
	"es": {
		"app_title": "Guía de Seguridad de Billetes",
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
		"show_banknote": "Mostrar billete",
		"thumbnail": "Miniatura",
		"thumbnail_preview": "Vista previa",
		"no_note_selected": "No hay billete seleccionado",
		"note_viewer_status": "El visor usa datos dinámicos y miniaturas correctas para cada país.",
		"note_title_format": "%s — %s %s",
		"watermark_prefix": "Marca de agua: %s",
		"source_prefix": "Fuente: %s",
		"uv_title": "Detector UV",
		"uv_message": "Usá esta pantalla violeta solo como ayuda visual en una habitación oscura. El teléfono no emite luz UV real; las medidas UV requieren una lámpara externa y la visibilidad varía según el dispositivo.",
		"watermark_title": "Visor de marca de agua",
		"watermark_message": "El ciclo de colores ayuda a revelar cambios de marca de agua y papel cuando el billete se coloca frente a la pantalla.",
		"pause": "Pausar",
		"resume": "Reanudar",
		"menu_uv": "Detector UV",
		"menu_watermark": "Visor de marca de agua",
		"menu_currency": "Información de moneda",
		"menu_about": "Acerca de",
		"menu_remove_ads": "Quitar anuncios",
		"menu_exit": "Salir",
		"ads_removed": "Los anuncios ya están desactivados para esta cuenta de Google Play.",
		"purchase_unavailable": "Las compras no están disponibles hasta conectar Google Play.",
		"purchase_failed": "Google Play no pudo iniciar la compra.",
		"purchase_pending": "La compra está pendiente. Los anuncios desaparecerán cuando se confirme el pago.",
		"language_label": "Idioma",
		"follow_phone_language": "Seguir idioma del teléfono",
		"menu_subtitle": "Revisá las medidas de seguridad del billete paso a paso.",
		"about_title": "Acerca de",
		"about_version_label": "Versión: %s",
		"about_update_label": "Última actualización: %s",
		"about_body": "Esta app ofrece una revisión asistida de referencias de seguridad de billetes.",
		"rate_this_app": "Calificar esta app",
		"menu_guided_review": "Verificar medidas de seguridad",
		"menu_review_hint": "Seguí la guía para comprobar las referencias de seguridad del billete. Esta app no determina autenticidad.",
		"menu_continue": "Continuar",
		"menu_quick_tools": "Herramientas rápidas",
		"menu_explore": "Explorar",
		"menu_more": "Ajustes",
		"guided_review_subtitle": "Revisá las medidas de seguridad paso a paso.",
		"review_setup_title": "Iniciar revisión asistida",
		"review_setup_intro": "Elegí cómo identificar el billete.",
		"review_disclaimer": "Esta revisión asistida no determina completamente la autenticidad.",
		"review_choose_method": "¿Cómo querés identificar el billete?",
		"review_camera_option": "Usar la cámara para identificarlo",
		"review_manual_option": "Elegir país y denominación",
		"identify_camera": "Sugerir por texto de cámara",
		"camera_unavailable": "Las sugerencias por texto de cámara no están disponibles. Elegí el billete manualmente.",
		"scan_processing": "Procesando la imagen en este dispositivo…",
		"scan_candidates": "Coincidencias experimentales de texto. Confirmá el billete correcto:",
		"scan_unknown": "No encontramos una coincidencia confiable. Elegí el billete manualmente.",
		"scan_poor_quality": "No pudimos leer la imagen. Probá con mejor luz o elegí manualmente.",
		"scan_permission_denied": "No se otorgó permiso para usar la cámara. Podés continuar manualmente.",
		"scan_cancelled": "Captura cancelada. Podés continuar manualmente.",
		"choose_country": "País",
		"choose_banknote": "Billete",
		"start_review": "Iniciar revisión",
		"review_title": "Revisión de seguridad",
		"generic_guide_notice": "Este modelo todavía no tiene una guía estructurada. Compararemos sus referencias comunes registradas.",
		"step_progress": "Paso %d de %d",
		"step_compare_title": "Compará esta referencia",
		"step_compare_instruction": "Inspeccioná el billete y compará esta referencia de seguridad registrada.",
		"review_reference_caption": "Referencia frontal oficial: ubicá la medida descrita arriba.",
		"observed": "Lo observo",
		"mismatch": "No coincide",
		"unable": "No pude comprobarlo",
		"review_result_title": "Revisión completada",
		"result_observed": "Señales observadas: %d",
		"result_mismatch": "No coinciden: %d",
		"result_unable": "Sin comprobar: %d",
		"review_result_advice": "Si todavía tenés dudas, no vuelvas a circular el billete y consultá al emisor o a una entidad financiera.",
		"review_another": "Revisar otro billete",
		"return_home": "Volver al inicio",
		"add_favorite": "Agregar a favoritos",
		"remove_favorite": "Quitar de favoritos",
		"analytics_consent_title": "Ayudanos a mejorar la app",
		"analytics_consent_body": "¿Permitís estadísticas básicas de uso? Nunca se envían fotos, texto reconocido, números de serie, billetes elegidos ni respuestas de la revisión.",
		"analytics_allow": "Permitir",
		"analytics_decline": "Ahora no",
		"analytics_enable": "Activar estadísticas de uso",
		"analytics_disable": "Desactivar estadísticas de uso",
		"menu_library": "Recientes y favoritos",
		"library_title": "Tus billetes",
		"library_recent": "Revisados recientemente",
		"library_favorites": "Favoritos",
		"library_empty": "Completá una revisión o agregá un favorito para verlo acá.",
		"clear_history": "Borrar historial reciente"
	},
	"pt": {
		"app_title": "Guia de Segurança de Cédulas",
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
		"show_banknote": "Mostrar cédula",
		"thumbnail": "Miniatura",
		"thumbnail_preview": "Prévia da miniatura",
		"no_note_selected": "Nenhuma nota selecionada",
		"note_viewer_status": "O visualizador usa detalhes de notas baseados em dados e imagens correspondentes ao país.",
		"note_title_format": "%s — %s %s",
		"watermark_prefix": "Marca-d'água: %s",
		"source_prefix": "Fonte: %s",
		"uv_title": "Detector UV",
		"uv_message": "Use esta tela violeta apenas como auxílio visual em um ambiente escuro. O telefone não emite luz UV real; as medidas UV exigem uma lâmpada externa e a visibilidade varia conforme o aparelho.",
		"watermark_title": "Visualizador de marca-d'água",
		"watermark_message": "O ciclo de cores ajuda a revelar mudanças na marca-d'água e no papel quando a cédula fica na frente da tela.",
		"pause": "Pausar",
		"resume": "Continuar",
		"menu_uv": "Detector UV",
		"menu_watermark": "Visualizador de marca-d'água",
		"menu_currency": "Informações da moeda",
		"menu_about": "Sobre",
		"menu_remove_ads": "Remover anúncios",
		"menu_exit": "Sair",
		"ads_removed": "Os anúncios já estão removidos para esta conta do Google Play.",
		"purchase_unavailable": "As compras não estão disponíveis até o Google Play se conectar.",
		"purchase_failed": "O Google Play não conseguiu iniciar a compra.",
		"purchase_pending": "A compra está pendente. Os anúncios serão removidos quando o pagamento for confirmado.",
		"language_label": "Idioma",
		"follow_phone_language": "Usar idioma do telefone",
		"menu_subtitle": "Revise os recursos de segurança da cédula passo a passo.",
		"about_title": "Sobre",
		"about_version_label": "Versão: %s",
		"about_update_label": "Última atualização: %s",
		"about_body": "Este aplicativo oferece uma revisão assistida de referências de segurança de cédulas.",
		"rate_this_app": "Avaliar este aplicativo",
		"menu_guided_review": "Verificar recursos de segurança",
		"menu_review_hint": "Siga o guia para verificar as referências de segurança da cédula. Este aplicativo não determina a autenticidade.",
		"menu_continue": "Continuar",
		"menu_quick_tools": "Ferramentas rápidas",
		"menu_explore": "Explorar",
		"menu_more": "Configurações",
		"guided_review_subtitle": "Revise os recursos de segurança passo a passo.",
		"review_setup_title": "Iniciar revisão assistida",
		"review_setup_intro": "Escolha como identificar a cédula.",
		"review_disclaimer": "Esta revisão assistida não determina totalmente a autenticidade.",
		"review_choose_method": "Como você quer identificar a cédula?",
		"review_camera_option": "Usar a câmera para identificá-la",
		"review_manual_option": "Escolher país e denominação",
		"identify_camera": "Sugerir pelo texto da câmera",
		"camera_unavailable": "As sugestões por texto da câmera não estão disponíveis. Escolha a cédula manualmente.",
		"scan_processing": "Processando a imagem neste dispositivo…",
		"scan_candidates": "Correspondências experimentais de texto. Confirme a cédula correta:",
		"scan_unknown": "Nenhuma correspondência confiável foi encontrada. Escolha a cédula manualmente.",
		"scan_poor_quality": "Não foi possível ler a imagem. Tente com mais luz ou escolha manualmente.",
		"scan_permission_denied": "A permissão da câmera não foi concedida. Você pode continuar manualmente.",
		"scan_cancelled": "Captura cancelada. Você pode continuar manualmente.",
		"choose_country": "País",
		"choose_banknote": "Cédula",
		"start_review": "Iniciar revisão",
		"review_title": "Revisão de segurança",
		"generic_guide_notice": "Este modelo ainda não tem um guia estruturado. Compararemos as referências comuns registradas.",
		"step_progress": "Etapa %d de %d",
		"step_compare_title": "Compare esta referência",
		"step_compare_instruction": "Inspecione a cédula e compare esta referência de segurança registrada.",
		"review_reference_caption": "Referência frontal oficial: localize o recurso descrito acima.",
		"observed": "Eu observo",
		"mismatch": "Não coincide",
		"unable": "Não pude verificar",
		"review_result_title": "Revisão concluída",
		"result_observed": "Sinais observados: %d",
		"result_mismatch": "Não coincidem: %d",
		"result_unable": "Não verificados: %d",
		"review_result_advice": "Se ainda tiver dúvidas, não recoloque a cédula em circulação e consulte o emissor ou uma instituição financeira.",
		"review_another": "Revisar outra cédula",
		"return_home": "Voltar ao início",
		"add_favorite": "Adicionar aos favoritos",
		"remove_favorite": "Remover dos favoritos",
		"analytics_consent_title": "Ajude a melhorar o aplicativo",
		"analytics_consent_body": "Permitir estatísticas básicas de uso? Fotos, texto reconhecido, números de série, cédulas escolhidas e respostas da revisão nunca são enviados.",
		"analytics_allow": "Permitir",
		"analytics_decline": "Agora não",
		"analytics_enable": "Ativar estatísticas de uso",
		"analytics_disable": "Desativar estatísticas de uso",
		"menu_library": "Recentes e favoritos",
		"library_title": "Suas cédulas",
		"library_recent": "Revisadas recentemente",
		"library_favorites": "Favoritos",
		"library_empty": "Conclua uma revisão ou adicione um favorito para vê-lo aqui.",
		"clear_history": "Limpar histórico recente"
	},
	"zh": {
		"app_title": "纸币安全指南",
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
		"show_banknote": "显示纸币",
		"thumbnail": "缩略图",
		"thumbnail_preview": "缩略图预览",
		"no_note_selected": "未选择纸币",
		"note_viewer_status": "查看器使用数据驱动的纸币详情和与国家匹配的图像。",
		"note_title_format": "%s · %s%s",
		"watermark_prefix": "水印：%s",
		"source_prefix": "来源：%s",
		"uv_title": "UV 检测器",
		"uv_message": "此紫色屏幕仅可在暗室中作为视觉辅助。手机不会发出真正的紫外线；检查紫外安全特征需要外置紫外灯，显示效果也因设备而异。",
		"watermark_title": "水印查看器",
		"watermark_message": "颜色循环有助于观察纸币放到屏幕前时的水印和纸张变化。",
		"pause": "暂停",
		"resume": "继续",
		"menu_uv": "UV 检测器",
		"menu_watermark": "水印查看器",
		"menu_currency": "货币信息",
		"menu_about": "关于",
		"menu_remove_ads": "移除广告",
		"menu_exit": "退出",
		"ads_removed": "此 Google Play 帐户已移除广告。",
		"purchase_unavailable": "Google Play 连接前无法购买。",
		"purchase_failed": "Google Play 无法开始购买。",
		"purchase_pending": "购买正在处理中，付款确认后广告将被移除。",
		"language_label": "语言",
		"follow_phone_language": "跟随手机语言",
		"menu_subtitle": "逐步检查纸币的安全特征。",
		"about_title": "关于",
		"about_version_label": "版本：%s",
		"about_update_label": "最近更新：%s",
		"about_body": "本应用提供纸币安全特征参考的辅助检查。",
		"rate_this_app": "评价此应用",
		"menu_guided_review": "检查防伪特征",
		"menu_review_hint": "请按照指南核对纸币的安全参考特征。本应用不判定真伪。",
		"menu_continue": "继续",
		"menu_quick_tools": "快捷工具",
		"menu_explore": "浏览",
		"menu_more": "设置",
		"guided_review_subtitle": "逐步检查安全特征。",
		"review_setup_title": "开始辅助检查",
		"review_setup_intro": "选择纸币识别方式。",
		"review_disclaimer": "此辅助检查不能完全判定纸币真伪。",
		"review_choose_method": "您想如何识别纸币？",
		"review_camera_option": "使用相机识别",
		"review_manual_option": "选择国家和面额",
		"identify_camera": "根据相机文字建议",
		"camera_unavailable": "相机文字建议不可用，请手动选择纸币。",
		"scan_processing": "正在此设备上处理图像…",
		"scan_candidates": "实验性文字匹配结果，请确认正确的纸币：",
		"scan_unknown": "未找到可靠匹配，请手动选择纸币。",
		"scan_poor_quality": "无法读取图像，请改善光线后重试或手动选择。",
		"scan_permission_denied": "未授予相机权限，您仍可手动继续。",
		"scan_cancelled": "已取消拍摄，您仍可手动继续。",
		"choose_country": "国家或地区",
		"choose_banknote": "纸币",
		"start_review": "开始检查",
		"review_title": "安全特征检查",
		"generic_guide_notice": "此型号尚无结构化指南，将对比已登记的常见参考特征。",
		"step_progress": "第 %d 步，共 %d 步",
		"step_compare_title": "对比此参考特征",
		"step_compare_instruction": "检查纸币并对比此已登记的安全参考特征。",
		"review_reference_caption": "官方正面参考图：请定位上方描述的特征。",
		"observed": "已观察到",
		"mismatch": "不相符",
		"unable": "无法检查",
		"review_result_title": "检查完成",
		"result_observed": "已观察到的特征：%d",
		"result_mismatch": "不相符：%d",
		"result_unable": "未检查：%d",
		"review_result_advice": "如果仍有疑问，请勿再次流通该纸币，并咨询发行机构或金融机构。",
		"review_another": "检查另一张纸币",
		"return_home": "返回首页",
		"add_favorite": "添加到收藏",
		"remove_favorite": "从收藏中移除",
		"analytics_consent_title": "帮助改进应用",
		"analytics_consent_body": "是否允许基本使用统计？照片、识别文字、序列号、所选纸币和检查答案绝不会被发送。",
		"analytics_allow": "允许",
		"analytics_decline": "暂不",
		"analytics_enable": "启用使用统计",
		"analytics_disable": "停用使用统计",
		"menu_library": "最近记录和收藏",
		"library_title": "您的纸币",
		"library_recent": "最近检查",
		"library_favorites": "收藏",
		"library_empty": "完成一次检查或添加收藏后，将显示在这里。",
		"clear_history": "清除最近记录"
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


func get_note_id(note: Dictionary) -> String:
	var stored_id := str(note.get("note_id", note.get("id", ""))).strip_edges()
	if not stored_id.is_empty():
		return stored_id
	var currency := str(note.get("currency", "")).to_lower().strip_edges()
	var denomination := str(note.get("denomination", "")).to_lower().strip_edges()
	return "%s_%s" % [currency, denomination.replace(" ", "_").replace(".", "")]


func find_note_by_id(note_id: String) -> Dictionary:
	for note in currency_entries:
		if get_note_id(note) == note_id:
			return note
	return {}


func select_note_by_id(note_id: String) -> bool:
	var note := find_note_by_id(note_id)
	if note.is_empty():
		return false
	set_selected_country(str(note.get("country", "")))
	var notes := get_selected_notes()
	for index in notes.size():
		if get_note_id(notes[index]) == note_id:
			selected_note_index = index
			return true
	return false


func has_specific_review_steps(note: Dictionary) -> bool:
	var review: Variant = note.get("review", {})
	if not review is Dictionary:
		return false
	var steps: Variant = (review as Dictionary).get("steps", [])
	return str((review as Dictionary).get("status", "draft")) == "ready" and steps is Array and not steps.is_empty()


func get_note_review_steps(note: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if has_specific_review_steps(note):
		var review := note.get("review", {}) as Dictionary
		for raw_step in review.get("steps", []):
			if raw_step is Dictionary:
				var step := raw_step as Dictionary
				result.append({
					"step_id": str(step.get("step_id", "step_%d" % result.size())),
					"method": str(step.get("method", "visual")),
					"title": _get_localized_map_text(step.get("title_texts", {}), t("step_compare_title")),
					"instruction": _get_localized_map_text(step.get("instruction_texts", {}), t("step_compare_instruction")),
					"expected": _get_localized_map_text(step.get("expected_texts", {}), ""),
					"reference_path": str(step.get("reference_path", get_note_texture_path(note))).strip_edges(),
				})
		return result

	var features := get_note_features(note)
	for index in features.size():
		result.append({
			"step_id": "reference_%d" % index,
			"method": "visual",
			"title": t("step_compare_title"),
			"instruction": t("step_compare_instruction"),
			"expected": features[index],
			"reference_path": get_note_texture_path(note),
		})
	if result.is_empty():
		result.append({
			"step_id": "general_reference",
			"method": "visual",
			"title": t("step_compare_title"),
			"instruction": t("step_compare_instruction"),
			"expected": get_note_summary(note),
			"reference_path": get_note_texture_path(note),
		})
	return result


func _get_localized_map_text(value: Variant, fallback: String) -> String:
	if value is Dictionary:
		var localized: Variant = _get_localized_variant(value as Dictionary)
		var text := str(localized).strip_edges()
		if not text.is_empty():
			return text
	return fallback


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
	return t("note_title_format") % [country, denomination, currency]


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
