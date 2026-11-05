extends RefCounted

const PANEL_TOP := 134.0
const PANEL_BOTTOM := 167.0
const HIT_X := 70.0
const NOTE_SPEED_PX_PER_SECOND := 60.0
const LOOK_AHEAD_MS := 4000
const PAST_WINDOW_MS := 200
const NOTE_POSITIONS := {
	"drums": 143.0,
	"bass": 147.0,
	"synth": 153.0,
	"lead": 159.0,
}


func note_x(song_time_ms: int, event_time_ms: int) -> float:
	var delta_ms := event_time_ms - song_time_ms
	return HIT_X + float(delta_ms) / 1000.0 * NOTE_SPEED_PX_PER_SECOND


func is_note_visible(delta_ms: int) -> bool:
	return delta_ms >= -PAST_WINDOW_MS and delta_ms <= LOOK_AHEAD_MS


func note_y(instrument: String) -> float:
	return float(NOTE_POSITIONS.get(instrument, NOTE_POSITIONS.drums))
