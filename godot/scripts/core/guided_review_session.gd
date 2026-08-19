extends Node

signal session_changed

const ANSWER_OBSERVED := "observed"
const ANSWER_MISMATCH := "mismatch"
const ANSWER_UNABLE := "unable"

var note_id: String = ""
var steps: Array[Dictionary] = []
var answers: Dictionary = {}
var current_step_index: int = 0
var started_at_unix: int = 0
var is_generic_guide: bool = false
var history_recorded: bool = false


func begin(note: Dictionary) -> bool:
	clear()
	note_id = AppState.get_note_id(note)
	if note_id.is_empty():
		return false
	steps = AppState.get_note_review_steps(note)
	is_generic_guide = not AppState.has_specific_review_steps(note)
	started_at_unix = int(Time.get_unix_time_from_system())
	session_changed.emit()
	return not steps.is_empty()


func clear() -> void:
	note_id = ""
	steps.clear()
	answers.clear()
	current_step_index = 0
	started_at_unix = 0
	is_generic_guide = false
	history_recorded = false
	session_changed.emit()


func has_active_session() -> bool:
	return not note_id.is_empty() and not steps.is_empty()


func get_note() -> Dictionary:
	return AppState.find_note_by_id(note_id)


func get_current_step() -> Dictionary:
	if current_step_index < 0 or current_step_index >= steps.size():
		return {}
	return steps[current_step_index]


func answer_current(answer: String) -> bool:
	if not [ANSWER_OBSERVED, ANSWER_MISMATCH, ANSWER_UNABLE].has(answer):
		return false
	var step := get_current_step()
	if step.is_empty():
		return false
	answers[str(step.get("step_id", current_step_index))] = answer
	if current_step_index < steps.size() - 1:
		current_step_index += 1
	session_changed.emit()
	return true


func is_complete() -> bool:
	return not steps.is_empty() and answers.size() >= steps.size()


func get_counts() -> Dictionary:
	var counts := {
		ANSWER_OBSERVED: 0,
		ANSWER_MISMATCH: 0,
		ANSWER_UNABLE: 0,
	}
	for value in answers.values():
		var key := str(value)
		if counts.has(key):
			counts[key] = int(counts[key]) + 1
	return counts
