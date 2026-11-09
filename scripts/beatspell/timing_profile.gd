extends RefCounted

const DEFAULT_BPM := 120.0
const DEFAULT_BEAT_MS := 500.0
const DEFAULT_BEATS_PER_BAR := 4
const DEFAULT_BAR_MS := 2000
const DEFAULT_PERFECT_WINDOW_MS := 55
const DEFAULT_GOOD_WINDOW_MS := 135
const DEFAULT_COMMAND_EXPIRY_BEATS := 3.25

var bpm: float
var beats_per_bar: int
var perfect_window_ms: int
var good_window_ms: int
var command_expiry_beats: float
var input_offset_ms: int


func _init(
	custom_bpm: float = DEFAULT_BPM,
	custom_beats_per_bar: int = DEFAULT_BEATS_PER_BAR,
	custom_perfect_window_ms: int = DEFAULT_PERFECT_WINDOW_MS,
	custom_good_window_ms: int = DEFAULT_GOOD_WINDOW_MS,
	custom_command_expiry_beats: float = DEFAULT_COMMAND_EXPIRY_BEATS,
	custom_input_offset_ms: int = 0
) -> void:
	bpm = maxf(custom_bpm, 1.0)
	beats_per_bar = maxi(custom_beats_per_bar, 1)
	perfect_window_ms = maxi(custom_perfect_window_ms, 0)
	good_window_ms = maxi(custom_good_window_ms, perfect_window_ms)
	command_expiry_beats = maxf(custom_command_expiry_beats, 1.0)
	input_offset_ms = custom_input_offset_ms


func beat_ms() -> float:
	return 60_000.0 / bpm


func bar_ms() -> int:
	return int(round(beat_ms() * float(beats_per_bar)))


func adjusted_song_time(song_time_ms: int) -> int:
	return maxi(0, song_time_ms - input_offset_ms)


func grade_for_offset(offset_ms: int) -> String:
	var absolute_offset := absi(offset_ms)
	if absolute_offset <= perfect_window_ms:
		return "perfect"
	if absolute_offset <= good_window_ms:
		return "good"
	return "miss"


func quantize(song_time_ms: int, beat_override_ms: float = -1.0) -> Dictionary:
	var current_beat_ms := beat_override_ms if beat_override_ms > 0.0 else beat_ms()
	var tick := int(round(float(song_time_ms) / current_beat_ms))
	var offset_ms := int(round(float(song_time_ms) - float(tick) * current_beat_ms))
	var grade := grade_for_offset(offset_ms)
	return {
		"valid": grade != "miss",
		"tick": tick,
		"offset_ms": offset_ms,
		"grade": grade,
	}


func command_expiry_ms(beat_override_ms: float = -1.0) -> float:
	var current_beat_ms := beat_override_ms if beat_override_ms > 0.0 else beat_ms()
	return current_beat_ms * command_expiry_beats
