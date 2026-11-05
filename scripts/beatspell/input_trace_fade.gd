extends RefCounted

const HOLD_MS := 650.0
const FADE_MS := 350.0
const TOTAL_MS := HOLD_MS + FADE_MS


static func alpha_for(events: Array, current_song_ms: int, phrase_active: bool) -> float:
	if events.is_empty():
		return 0.0
	if phrase_active:
		return 1.0
	var newest_input_ms := int(events[0].get("input_time_ms", current_song_ms))
	for event in events:
		newest_input_ms = maxi(newest_input_ms, int(event.get("input_time_ms", current_song_ms)))
	var age_ms := maxf(0.0, float(current_song_ms - newest_input_ms))
	if age_ms <= HOLD_MS:
		return 1.0
	return clampf(1.0 - (age_ms - HOLD_MS) / FADE_MS, 0.0, 1.0)
