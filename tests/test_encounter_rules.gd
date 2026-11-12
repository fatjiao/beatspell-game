extends RefCounted

const Rules = preload("res://scripts/beatspell/encounter_rules.gd")
const Director = preload("res://scripts/beatspell/battle_director.gd")


func run() -> Array[String]:
	var failures: Array[String] = []
	var director := Director.new()
	for invalid in [null, true, 2, "unknown", [], {}]:
		_equal(failures, Rules.normalize(invalid), "ritual", "invalid encounter safely selects ritual")
	_equal(failures, Rules.label("duel"), "DUEL", "stable display label")
	_equal(failures, Rules.normalize("prism"), "prism", "prism is a selectable encounter")
	_equal(failures, Rules.label("prism"), "PRISM", "prism display label")
	_equal(failures, Rules.label("unknown"), "RITUAL", "unknown label falls back")
	for bar in range(-1, 45):
		_equal(failures, Rules.tutorial_skill("ritual", bar), director.tutorial_skill(bar), "ritual retains tutorial at bar %d" % bar)
		for phase_number in [1, 2, 3]:
			_equal(failures, Rules.is_attack_bar("ritual", bar, phase_number), director.is_attack_bar(bar, phase_number), "ritual retains attack bars")
			_equal(failures, Rules.attack_pattern("ritual", bar, phase_number), director.attack_pattern(bar, phase_number), "ritual retains warning patterns")
	for mode in Rules.MODES:
		_equal(failures, Rules.is_attack_bar(mode, -1, 1), false, "count-in never attacks")
		_equal(failures, Rules.phase(mode, 9, 41, 60), 1, "above two-thirds remains phase one")
		_equal(failures, Rules.phase(mode, 9, 40, 60), 2, "two-thirds threshold")
		_equal(failures, Rules.phase(mode, 9, 20, 60), 3, "one-third threshold")
	_equal(failures, Rules.phase("ritual", 8, 1, 60), 1, "ritual teaching stays in phase one")
	_equal(failures, Rules.phase("ritual", 9, 1, 60), 3, "ritual health phase starts after teaching")
	for mode in ["duel", "gauntlet", "prism"]:
		for bar in range(9):
			_equal(failures, Rules.tutorial_skill(mode, bar), "", "advanced encounters have no timed lesson")
		_equal(failures, Rules.phase(mode, 0, 20, 60), 3, "advanced encounters follow health immediately")
	_equal(failures, _attack_bars("duel", 1, 12), [3, 7, 11], "duel phase one attacks at bar 4 without intro")
	_equal(failures, _attack_bars("duel", 2, 12), [2, 5, 8, 11], "duel phase two attacks every third bar")
	_equal(failures, _attack_bars("duel", 3, 8), [1, 3, 5, 7], "duel phase three attacks every other bar")
	_equal(failures, Rules.attack_pattern("duel", 8, 2), "syncopated", "duel has no special teaching strike at bar nine")
	for phase_number in [1, 2, 3]:
		_equal(failures, _attack_bars("gauntlet", phase_number, 8), [1, 3, 5, 7], "gauntlet schedule ignores health phase")
		_equal(failures, Rules.attack_damage("gauntlet", phase_number), 2, "gauntlet damage stays two")
		for index in 9:
			_equal(failures, Rules.attack_pattern("gauntlet", index * 2 + 1, phase_number), ["standard", "syncopated", "rush"][index % 3], "gauntlet warning rotation stays independent of phase")
	for mode in ["ritual", "duel"]:
		_equal(failures, Rules.attack_damage(mode, 1), 1, "normal phase one deals one")
		_equal(failures, Rules.attack_damage(mode, 2), 2, "normal phase two deals two")
	for mode in ["ritual", "duel", "gauntlet", "unknown"]:
		_equal(failures, Rules.boss_health(mode), 60, "existing boss health is unchanged")
		for bar in range(-1, 12):
			_equal(failures, Rules.stance(mode, bar), "neutral", "other encounters have no stance")
			_equal(failures, Rules.flare_modifier(mode, bar), 0, "other encounters have no flare modifier")
	_equal(failures, Rules.boss_health("prism"), 72, "prism has a longer health budget")
	_equal(failures, Rules.stance("prism", -1), "neutral", "count-in has no stance")
	_equal(failures, Rules.flare_modifier("prism", -1), 0, "count-in has no damage modifier")
	for bar in range(12):
		var armored := bar % 4 < 2
		_equal(failures, Rules.stance("prism", bar), "armored" if armored else "open", "prism stance follows four global bars")
		_equal(failures, Rules.flare_modifier("prism", bar), -1 if armored else 1, "prism stance supplies damage delta")
	for phase_number in [1, 2, 3]:
		_equal(failures, _attack_bars("prism", phase_number, 12), [1, 3, 5, 7, 9, 11], "prism attacks every two bars regardless of phase")
		_equal(failures, Rules.attack_damage("prism", phase_number), 2, "prism attack damage stays two")
		for index in 8:
			_equal(failures, Rules.attack_pattern("prism", index * 2 + 1, phase_number), "echo" if index % 2 == 0 else "offbeat", "prism alternates echo then offbeat")
	_equal(failures, Rules.phase("prism", 0, 49, 72), 1, "prism first health threshold scales to 72")
	_equal(failures, Rules.phase("prism", 0, 48, 72), 2, "prism phase two starts at 48 HP without tutorial")
	_equal(failures, Rules.phase("prism", 0, 24, 72), 3, "prism phase three starts at 24 HP")
	return failures


func _attack_bars(mode: String, phase_number: int, length: int) -> Array[int]:
	var bars: Array[int] = []
	for bar in length:
		if Rules.is_attack_bar(mode, bar, phase_number):
			bars.append(bar)
	return bars


func _equal(failures: Array[String], actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		failures.append("%s: expected %s, got %s" % [message, expected, actual])
