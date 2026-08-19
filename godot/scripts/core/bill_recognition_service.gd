extends Node

signal recognition_finished(result: Dictionary)


func is_available() -> bool:
	return Engine.has_singleton("BillRecognitionPlugin")


func identify_front() -> void:
	if not is_available():
		recognition_finished.emit({"status": "unavailable", "candidates": []})
		return
	var plugin := Engine.get_singleton("BillRecognitionPlugin")
	if plugin != null and plugin.has_method("identify_front"):
		plugin.identify_front()
	else:
		recognition_finished.emit({"status": "unavailable", "candidates": []})
