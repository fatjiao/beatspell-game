extends RefCounted

const TimingProfileScript = preload("res://scripts/beatspell/timing_profile.gd")

var events: Array = []
var display_events: Array = []
var broken := false
var timing_profile


func _init(profile = null) -> void:
	timing_profile = profile if profile != null else TimingProfileScript.new()


func is_active() -> bool:
	return not events.is_empty()


func register_step(song_time_ms: int, beat_override_ms: float = -1.0) -> Dictionary:
	var current_beat_ms := _resolve_beat_ms(beat_override_ms)
	var quantized: Dictionary = timing_profile.quantize(song_time_ms, current_beat_ms)
	var event := _make_event("step", quantized, song_time_ms, current_beat_ms)
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


func finish(song_time_ms: int, beat_override_ms: float = -1.0) -> Dictionary:
	var current_beat_ms := _resolve_beat_ms(beat_override_ms)
	var quantized: Dictionary = timing_profile.quantize(song_time_ms, current_beat_ms)
	var completed_events := display_events.duplicate(true)
	completed_events.append(_make_event("finish", quantized, song_time_ms, current_beat_ms))
	var result := {"skill": "", "grade": "miss", "events": completed_events}
	if not quantized.valid or broken:
		reset()
		return result
	var finish_tick := int(quantized.tick)
	if events.size() == 1:
		var interval := finish_tick - int(events[0].tick)
		if interval == 1:
			result.skill = "fireball"
		elif interval == 2:
			result.skill = "shield"
	elif events.size() == 2 \
		and finish_tick - int(events[0].tick) == 2 \
		and finish_tick - int(events[1].tick) == 1:
		result.skill = "heal"
	if not result.skill.is_empty():
		result.grade = _combined_grade(completed_events)
	reset()
	return result


func expire_if_needed(song_time_ms: int, beat_override_ms: float = -1.0) -> bool:
	if not is_active():
		return false
	var current_beat_ms := _resolve_beat_ms(beat_override_ms)
	var first_time := float(events[0].tick) * current_beat_ms
	if float(song_time_ms) <= first_time + timing_profile.command_expiry_ms(current_beat_ms):
		return false
	reset()
	return true


func reset() -> void:
	events.clear()
	display_events.clear()
	broken = false


func _make_event(action: String, quantized: Dictionary, song_time_ms: int, beat_ms: float) -> Dictionary:
	var ring_ticks: int = timing_profile.beats_per_bar
	var cycle_ms := beat_ms * float(ring_ticks)
	return {
		"action": action,
		"tick": quantized.tick,
		"ring_tick": posmod(int(quantized.tick), ring_ticks),
		"ring_phase": fposmod(float(song_time_ms), cycle_ms) / cycle_ms,
		"input_time_ms": song_time_ms,
		"offset_ms": quantized.offset_ms,
		"grade": quantized.grade,
	}


func _resolve_beat_ms(beat_override_ms: float) -> float:
	return beat_override_ms if beat_override_ms > 0.0 else timing_profile.beat_ms()


func _combined_grade(completed_events: Array) -> String:
	for event in completed_events:
		if event.grade != "perfect":
			return "good"
	return "perfect"
