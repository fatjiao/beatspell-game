extends RefCounted


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
