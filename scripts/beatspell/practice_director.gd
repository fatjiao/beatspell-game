extends RefCounted

const SKILLS := ["fireball", "heal", "shield"]
const REQUIRED_CASTS := 2
var counts := {"fireball": 0, "heal": 0, "shield": 0}
var step := 0


func current_skill() -> String:
	return SKILLS[step] if step < SKILLS.size() else ""


func record_cast(skill: String) -> bool:
	if not counts.has(skill):
		return false
	counts[skill] += 1
	if skill == current_skill() and int(counts[skill]) >= REQUIRED_CASTS:
		step += 1
		# Spells cast before their lesson must still be repeated during it.
		if step < SKILLS.size():
			counts[SKILLS[step]] = 0
		return true
	return false


func reset() -> void:
	counts = {"fireball": 0, "heal": 0, "shield": 0}
	step = 0
