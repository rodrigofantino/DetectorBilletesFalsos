extends Node

signal recognition_finished(result: Dictionary)

const COUNTRY_TOKENS := {
	"Argentina": ["ARGENTINA", "BCRA"],
	"Brazil": ["BRASIL", "BANCO CENTRAL"],
	"United States": ["UNITED STATES", "FEDERAL RESERVE"],
	"Eurozone": ["EURO", "ECB", "BCE"],
	"Colombia": ["COLOMBIA", "BANCO DE LA REPUBLICA"],
	"China": ["中国人民银行", "中國人民銀行"],
	"Mexico": ["MEXICO", "BANCO DE MEXICO"],
	"Peru": ["PERU", "BANCO CENTRAL DE RESERVA"],
	"Chile": ["CHILE", "BANCO CENTRAL"],
	"United Kingdom": ["BANK OF ENGLAND"],
	"Canada": ["BANK OF CANADA", "BANQUE DU CANADA"],
	"Australia": ["RESERVE BANK OF AUSTRALIA", "AUSTRALIA"],
	"New Zealand": ["RESERVE BANK OF NEW ZEALAND", "NEW ZEALAND"],
	"Japan": ["日本銀行", "NIPPON GINKO"],
	"India": ["RESERVE BANK OF INDIA", "भारतीय रिजर्व बैंक", "RBI"],
	"South Africa": ["SOUTH AFRICAN RESERVE BANK", "SOUTH AFRICA"],
	"Switzerland": ["SCHWEIZERISCHE NATIONALBANK", "BANQUE NATIONALE", "BANCA NAZIONALE"],
	"South Korea": ["한국은행", "BANK OF KOREA"],
	"Hong Kong": ["HONG KONG", "香港"],
	"Philippines": ["BANGKO SENTRAL NG PILIPINAS", "PILIPINAS"],
}

var _plugin: Object


func _ready() -> void:
	if not Engine.has_singleton("BillRecognitionPluginV2"):
		return
	_plugin = Engine.get_singleton("BillRecognitionPluginV2")
	if _plugin != null and _plugin.has_signal("recognition_completed"):
		_plugin.connect("recognition_completed", Callable(self, "_on_native_recognition_completed"))


func is_available() -> bool:
	return _plugin != null


func identify_front() -> void:
	if not is_available():
		recognition_finished.emit({"status": "unavailable", "candidates": []})
		return
	if _plugin != null and _plugin.has_method("identify_front"):
		_plugin.identify_front(AppState.get_locale_code())
	else:
		recognition_finished.emit({"status": "unavailable", "candidates": []})


func _on_native_recognition_completed(status: String, recognized_text: String) -> void:
	if status != "ok":
		recognition_finished.emit({"status": status, "candidates": []})
		return
	var candidates := _match_candidates(recognized_text)
	recognition_finished.emit({
		"status": "candidate" if not candidates.is_empty() else "unknown",
		"candidates": candidates,
	})


func _match_candidates(recognized_text: String) -> Array[Dictionary]:
	var normalized := _normalize_text(recognized_text)
	var candidates: Array[Dictionary] = []
	for note in AppState.currency_entries:
		var recognition: Variant = note.get("recognition", {})
		if not (recognition is Dictionary):
			continue
		var score := 0
		var denomination_match := false
		var support_match := false
		for raw_token in (recognition as Dictionary).get("denomination_tokens", []):
			var token := _normalize_text(str(raw_token))
			if _contains_token(normalized, token):
				score += 4
				denomination_match = true
		for raw_token in (recognition as Dictionary).get("text_tokens", []):
			if _contains_token(normalized, _normalize_text(str(raw_token))):
				score += 5
				support_match = true
		var country := str(note.get("country", ""))
		for raw_token in COUNTRY_TOKENS.get(country, []):
			if _contains_token(normalized, _normalize_text(str(raw_token))):
				score += 3
				support_match = true
		if denomination_match and support_match and score >= 7:
			candidates.append({"note_id": AppState.get_note_id(note), "score": score})
	candidates.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		return int(left.get("score", 0)) > int(right.get("score", 0))
	)
	if candidates.size() > 3:
		candidates.resize(3)
	return candidates


func _normalize_text(value: String) -> String:
	var regex := RegEx.new()
	regex.compile("[^\\p{L}\\p{N}]+")
	return regex.sub(value.to_upper(), " ", true).strip_edges()


func _contains_token(haystack: String, needle: String) -> bool:
	if needle.is_empty():
		return false
	return (" %s " % haystack).contains(" %s " % needle)
