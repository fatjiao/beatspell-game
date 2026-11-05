extends RefCounted

const PERFECT_WINDOW_MS := 55
const GOOD_WINDOW_MS := 135
const PATTERNS := {
	"fireball": ["charge", "cast", "charge", "cast"],
	"shield": ["charge", "charge", "", "cast"],
	"heal": ["cast", "", "cast", "cast"],
}


func quantize_input(phrase_time_ms: int, beat_ms: float = 500.0) -> Dictionary:
	var slot := int(round(float(phrase_time_ms) / beat_ms))
	var offset_ms := int(round(float(phrase_time_ms) - float(slot) * beat_ms))
	var valid := slot >= 0 and slot < 4 and absi(offset_ms) <= GOOD_WINDOW_MS
	var grade := "miss"
	if valid:
		grade = "perfect" if absi(offset_ms) <= PERFECT_WINDOW_MS else "good"
	return {
		"valid": valid,
		"slot": slot if valid else -1,
		"offset_ms": offset_ms,
		"grade": grade,
	}


func match_phrase(inputs: Array) -> Dictionary:
	var slots := ["", "", "", ""]
	var phrase_grade := "perfect"
	for entry in inputs:
		var slot := int(entry.get("slot", -1))
		var action := str(entry.get("action", ""))
		if slot < 0 or slot >= slots.size() or action not in ["charge", "cast"]:
			return _miss()
		if not slots[slot].is_empty():
			return _miss()
		slots[slot] = action
		if entry.get("grade", "miss") != "perfect":
			phrase_grade = "good"
	for skill in PATTERNS:
		if slots == PATTERNS[skill]:
			return {"skill": skill, "grade": phrase_grade}
	return _miss()


func pattern_for(skill: String) -> Array:
	return PATTERNS.get(skill, []).duplicate()


func _miss() -> Dictionary:
	return {"skill": "", "grade": "miss"}
