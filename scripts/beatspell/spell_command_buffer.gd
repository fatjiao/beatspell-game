extends RefCounted

const PERFECT_WINDOW_MS := 55
const GOOD_WINDOW_MS := 135
const RING_TICKS := 4

var events: Array = []
var display_events: Array = []
var broken := false


func is_active() -> bool:
	return not events.is_empty()


func register_step(song_time_ms: int, beat_ms: float = 500.0) -> Dictionary:
	var quantized := _quantize(song_time_ms, beat_ms)
	var event := _make_event("step", quantized, song_time_ms, beat_ms)
	if not is_active() and not display_events.is_empty():
		display_events.clear()
	if not quantized.valid:
		if is_active():
			broken = true
		display_events.append(event)
		return {"status": "off_pulse", "event": event}
	if is_active() and int(quantized.tick) <= int(events[-1].tick):
		broken = true
		event.grade = "miss"
		display_events.append(event)
		return {"status": "duplicate", "event": event}
	events.append(event)
	display_events.append(event)
	return {"status": "accepted", "event": event}


func finish(song_time_ms: int, beat_ms: float = 500.0) -> Dictionary:
	var quantized := _quantize(song_time_ms, beat_ms)
	var completed_events := display_events.duplicate(true)
	completed_events.append(_make_event("finish", quantized, song_time_ms, beat_ms))
	var result := {"skill": "", "grade": "miss", "events": completed_events}
	if not quantized.valid or broken:
		reset()
		return result
	var finish_tick := int(quantized.tick)
	if events.size() == 1 and finish_tick - int(events[0].tick) == 1:
		result.skill = "fireball"
	elif events.size() == 2 \
		and finish_tick - int(events[0].tick) == 2 \
		and finish_tick - int(events[1].tick) == 1:
		result.skill = "heal"
	if not result.skill.is_empty():
		result.grade = _combined_grade(completed_events)
	reset()
	return result


func expire_if_needed(song_time_ms: int, beat_ms: float = 500.0) -> bool:
	if not is_active():
		return false
	var first_time := float(events[0].tick) * beat_ms
	if float(song_time_ms) <= first_time + beat_ms * 3.25:
		return false
	reset()
	return true


func reset() -> void:
	events.clear()
	display_events.clear()
	broken = false


func _quantize(song_time_ms: int, beat_ms: float) -> Dictionary:
	var tick_ms := beat_ms
	var tick := int(round(float(song_time_ms) / tick_ms))
	var offset_ms := int(round(float(song_time_ms) - float(tick) * tick_ms))
	var valid := absi(offset_ms) <= GOOD_WINDOW_MS
	return {
		"valid": valid,
		"tick": tick,
		"offset_ms": offset_ms,
		"grade": "perfect" if valid and absi(offset_ms) <= PERFECT_WINDOW_MS else "good" if valid else "miss",
	}


func _make_event(action: String, quantized: Dictionary, song_time_ms: int, beat_ms: float) -> Dictionary:
	var cycle_ms := beat_ms * float(RING_TICKS)
	return {
		"action": action,
		"tick": quantized.tick,
		"ring_tick": posmod(int(quantized.tick), RING_TICKS),
		"ring_phase": fposmod(float(song_time_ms), cycle_ms) / cycle_ms,
		"offset_ms": quantized.offset_ms,
		"grade": quantized.grade,
	}


func _combined_grade(completed_events: Array) -> String:
	for event in completed_events:
		if event.grade != "perfect":
			return "good"
	return "perfect"
