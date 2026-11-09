extends RefCounted

const BEAT_MS := 500
const SUBDIVISION_MS := 250
const BAR_MS := 2000
const STANDARD_CUE_STEPS := [0, 2, 4, 6]
const SYNCOPATED_CUE_STEPS := [0, 3, 4, 7]
const RUSH_CUE_STEPS := [0, 4, 6, 7]


func tutorial_skill(bar_index: int) -> String:
	if bar_index < 0 or bar_index >= 9:
		return ""
	if bar_index < 3:
		return "fireball"
	if bar_index < 6:
		return "heal"
	return "shield"


func phase_for_health(boss_hp: int, max_boss_hp: int) -> int:
	if boss_hp * 3 > max_boss_hp * 2:
		return 1
	if boss_hp * 3 > max_boss_hp:
		return 2
	return 3


func phase_name(phase: int) -> String:
	return {1: "AWAKENING", 2: "FRACTURE", 3: "OVERDRIVE"}.get(phase, "AWAKENING")


func is_attack_bar(bar_index: int, phase: int) -> bool:
	if bar_index < 8:
		return false
	if bar_index == 8:
		return true
	match phase:
		1:
			return (bar_index + 1) % 4 == 0
		2:
			return (bar_index + 1) % 3 == 0
		3:
			return (bar_index + 1) % 2 == 0
	return false


func attack_damage(phase: int) -> int:
	return 1 if phase <= 1 else 2


func attack_pattern(bar_index: int, phase: int) -> String:
	if bar_index == 8 or phase <= 1:
		return "standard"
	if phase == 2:
		var attack_ordinal := int(floor(float(bar_index + 1) / 3.0))
		return "syncopated" if attack_ordinal % 2 == 1 else "standard"
	var attack_ordinal := int(floor(float(bar_index + 1) / 2.0))
	return "rush" if attack_ordinal % 2 == 0 else "syncopated"


func attack_cue_steps(bar_index: int, phase: int) -> Array:
	var steps: Array
	match attack_pattern(bar_index, phase):
		"syncopated":
			steps = SYNCOPATED_CUE_STEPS
		"rush":
			steps = RUSH_CUE_STEPS
		_:
			steps = STANDARD_CUE_STEPS
	return steps.duplicate()


func attack_cue_index(song_time_ms: int, bar_index: int, phase: int) -> int:
	if not is_attack_bar(bar_index, phase):
		return -1
	var time_in_bar := song_time_ms - bar_index * BAR_MS
	if time_in_bar < 0 or time_in_bar >= BAR_MS:
		return -1
	var current_step := clampi(int(floor(float(time_in_bar) / float(SUBDIVISION_MS))), 0, 7)
	var cue_index := -1
	var cue_steps := attack_cue_steps(bar_index, phase)
	for index in cue_steps.size():
		if current_step < int(cue_steps[index]):
			break
		cue_index = index
	return cue_index
