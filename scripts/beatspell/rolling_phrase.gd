extends RefCounted

const PERFECT_WINDOW_MS := 55
const GOOD_WINDOW_MS := 135
const WINDOW_BEATS := 4

var anchor_beat := -1
var inputs: Array = []
var broken := false


func is_active() -> bool:
	return anchor_beat >= 0


func register_input(song_time_ms: int, action: String, beat_ms: float = 500.0) -> Dictionary:
	var global_beat := int(round(float(song_time_ms) / beat_ms))
	var offset_ms := int(round(float(song_time_ms) - float(global_beat) * beat_ms))
	if absi(offset_ms) > GOOD_WINDOW_MS:
		if is_active():
			broken = true
		return {"status": "off_pulse", "slot": -1, "offset_ms": offset_ms, "grade": "miss"}
	if not is_active():
		anchor_beat = global_beat
	var slot := global_beat - anchor_beat
	if slot < 0 or slot >= WINDOW_BEATS:
		return {"status": "expired", "slot": -1, "offset_ms": offset_ms, "grade": "miss"}
	for entry in inputs:
		if entry.slot == slot:
			broken = true
			return {"status": "duplicate", "slot": slot, "offset_ms": offset_ms, "grade": "miss"}
	var grade := "perfect" if absi(offset_ms) <= PERFECT_WINDOW_MS else "good"
	inputs.append({"slot": slot, "action": action, "grade": grade, "offset_ms": offset_ms})
	inputs.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.slot < b.slot)
	return {"status": "accepted", "slot": slot, "offset_ms": offset_ms, "grade": grade}


func is_due(song_time_ms: int, beat_ms: float = 500.0) -> bool:
	return is_active() and float(song_time_ms) >= float(anchor_beat + WINDOW_BEATS) * beat_ms


func progress(song_time_ms: int, beat_ms: float = 500.0) -> float:
	if not is_active():
		return 0.0
	var start_ms := float(anchor_beat) * beat_ms
	return clampf((float(song_time_ms) - start_ms) / (beat_ms * float(WINDOW_BEATS)), 0.0, 1.0)


func current_slot(song_time_ms: int, beat_ms: float = 500.0) -> int:
	if not is_active():
		return -1
	var elapsed := (float(song_time_ms) - float(anchor_beat) * beat_ms) / beat_ms
	return clampi(int(floor(elapsed)), 0, WINDOW_BEATS - 1)


func reset() -> void:
	anchor_beat = -1
	inputs.clear()
	broken = false
