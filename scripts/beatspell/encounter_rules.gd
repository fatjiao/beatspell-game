extends RefCounted

## Encounter choice changes scheduling, never the shared rhythm or spell grammar.
const Director = preload("res://scripts/beatspell/battle_director.gd")
const MODES := ["ritual", "duel", "gauntlet", "prism"]
const LABELS := ["RITUAL", "DUEL", "GAUNTLET", "PRISM"]


static func normalize(mode: Variant) -> String:
	return mode if mode is String and mode in MODES else "ritual"


static func label(mode: String) -> String:
	return LABELS[MODES.find(normalize(mode))]


static func boss_health(mode: String) -> int:
	return 72 if normalize(mode) == "prism" else 60


static func stance(mode: String, bar: int) -> String:
	if normalize(mode) != "prism" or bar < 0:
		return "neutral"
	return "armored" if bar % 4 < 2 else "open"


static func flare_modifier(mode: String, bar: int) -> int:
	match stance(mode, bar):
		"armored": return -1
		"open": return 1
	return 0


static func tutorial_skill(mode: String, bar: int) -> String:
	return Director.new().tutorial_skill(bar) if normalize(mode) == "ritual" else ""


static func phase(mode: String, bar: int, hp: int, max_hp: int) -> int:
	if normalize(mode) == "ritual" and bar < 9:
		return 1
	return Director.new().phase_for_health(hp, max_hp)


static func is_attack_bar(mode: String, bar: int, phase_number: int) -> bool:
	if bar < 0:
		return false
	match normalize(mode):
		"ritual":
			return Director.new().is_attack_bar(bar, phase_number)
		"gauntlet", "prism":
			return (bar + 1) % 2 == 0
		_:
			match phase_number:
				1: return (bar + 1) % 4 == 0
				2: return (bar + 1) % 3 == 0
				3: return (bar + 1) % 2 == 0
	return false


static func attack_damage(mode: String, phase_number: int) -> int:
	return 2 if normalize(mode) in ["gauntlet", "prism"] else Director.new().attack_damage(phase_number)


static func attack_pattern(mode: String, bar: int, phase_number: int) -> String:
	match normalize(mode):
		"ritual":
			return Director.new().attack_pattern(bar, phase_number)
		"gauntlet":
			# First attack is zero-based bar 1. Each attack advances one pattern.
			var ordinal := maxi(0, int(floor(float(bar + 1) / 2.0)) - 1)
			return ["standard", "syncopated", "rush"][ordinal % 3]
		"prism":
			var ordinal := maxi(0, int(floor(float(bar + 1) / 2.0)) - 1)
			return "echo" if ordinal % 2 == 0 else "offbeat"
		_:
			if phase_number <= 1:
				return "standard"
			if phase_number == 2:
				var ordinal := int(floor(float(bar + 1) / 3.0))
				return "syncopated" if ordinal % 2 == 1 else "standard"
			var ordinal := int(floor(float(bar + 1) / 2.0))
			return "rush" if ordinal % 2 == 0 else "syncopated"
