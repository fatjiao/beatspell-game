extends RefCounted

const SECTIONS := [
	{
		"id": "drums",
		"start_ms": 0,
		"instrument": "drums",
		"key": "D",
		"title": "FIND THE PULSE",
		"instruction": "DRUMS / PRESS D ON THE BEAT",
	},
	{
		"id": "bass",
		"start_ms": 4000,
		"instrument": "bass",
		"key": "F",
		"title": "ADD THE WEIGHT",
		"instruction": "BASS / PRESS F ON THE BEAT",
	},
	{
		"id": "synth",
		"start_ms": 6500,
		"instrument": "synth",
		"key": "J",
		"title": "LIGHT THE TUNNEL",
		"instruction": "SYNTH / PRESS J ON THE BEAT",
	},
	{
		"id": "lead",
		"start_ms": 9000,
		"instrument": "lead",
		"key": "K",
		"title": "CALL THE CROWD",
		"instruction": "LEAD / PRESS K ON THE BEAT",
	},
	{
		"id": "ensemble",
		"start_ms": 12000,
		"instrument": "ensemble",
		"key": "",
		"title": "ONE PERSON. FULL BAND.",
		"instruction": "FOLLOW THE COLOR / FOLLOW THE KEY",
	},
]


func section_at(time_ms: int) -> Dictionary:
	var safe_time := maxi(0, time_ms)
	var current: Dictionary = SECTIONS[0]
	for section in SECTIONS:
		if safe_time < int(section.start_ms):
			break
		current = section
	return current


func cue_progress(delta_ms: int, window_ms: int = 1000) -> float:
	var safe_window := maxi(1, window_ms)
	return clampf(1.0 - float(maxi(0, delta_ms)) / float(safe_window), 0.0, 1.0)
