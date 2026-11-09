extends RefCounted

const BattleDirectorScript = preload("res://scripts/beatspell/battle_director.gd")


func run() -> Array:
	var failures: Array = []
	var director = BattleDirectorScript.new()
	_expect_equal(failures, director.tutorial_skill(0), "fireball", "opening bars teach FLARE")
	_expect_equal(failures, director.tutorial_skill(2), "fireball", "bar 2 still teaches FLARE")
	_expect_equal(failures, director.tutorial_skill(3), "heal", "later practice bars teach MEND")
	_expect_equal(failures, director.tutorial_skill(5), "heal", "bar 5 still teaches MEND")
	_expect_equal(failures, director.tutorial_skill(6), "shield", "final practice bars teach AEGIS")
	_expect_equal(failures, director.tutorial_skill(8), "shield", "bar 8 demonstrates AEGIS")
	_expect_equal(failures, director.tutorial_skill(9), "", "tutorial ends after bar 8")

	_expect_equal(failures, director.phase_for_health(36, 36), 1, "high health is phase one")
	_expect_equal(failures, director.phase_for_health(24, 36), 2, "two-thirds health begins phase two")
	_expect_equal(failures, director.phase_for_health(12, 36), 3, "one-third health begins phase three")
	_expect_equal(failures, director.phase_name(3), "OVERDRIVE", "phase three has a readable name")

	_expect_false(failures, director.is_attack_bar(7, 1), "early tutorial bars stay safe")
	_expect_true(failures, director.is_attack_bar(8, 1), "AEGIS tutorial ends with a teaching strike")
	_expect_true(failures, director.is_attack_bar(11, 1), "phase one attacks every fourth bar after the tutorial")
	_expect_false(failures, director.is_attack_bar(9, 1), "phase one rests after the teaching strike")
	_expect_true(failures, director.is_attack_bar(11, 2), "phase two attacks every third bar")
	_expect_true(failures, director.is_attack_bar(9, 3), "phase three attacks every other bar")
	_expect_equal(failures, director.attack_damage(1), 1, "phase one attack is forgiving")
	_expect_equal(failures, director.attack_damage(2), 2, "phase two attack is dangerous")
	_expect_equal(failures, director.attack_damage(3), 2, "phase three stays survivable")
	_expect_equal(failures, director.attack_pattern(8, 1), "standard", "teaching strike keeps the standard pulse")
	_expect_equal(failures, director.attack_pattern(11, 2), "standard", "phase two begins with a readable standard attack")
	_expect_equal(failures, director.attack_pattern(14, 2), "syncopated", "phase two alternates into a syncopated attack")
	_expect_equal(failures, director.attack_pattern(9, 3), "syncopated", "phase three uses the syncopated attack")
	_expect_equal(failures, director.attack_pattern(11, 3), "rush", "phase three alternates into a rush attack")
	_expect_equal(failures, director.attack_cue_steps(8, 1), [0, 2, 4, 6], "standard attack cues occupy quarter-note subdivisions")
	_expect_equal(failures, director.attack_cue_steps(14, 2), [0, 3, 4, 7], "syncopated attack uses uneven eighth-note spacing")
	_expect_equal(failures, director.attack_cue_steps(11, 3), [0, 4, 6, 7], "rush attack accelerates through its final cues")

	_expect_equal(failures, director.attack_cue_index(15_999, 7, 1), -1, "safe bar has no warning cue")
	_expect_equal(failures, director.attack_cue_index(16_000, 8, 1), 0, "attack warning starts on its first beat")
	_expect_equal(failures, director.attack_cue_index(16_500, 8, 1), 1, "attack warning advances on beat two")
	_expect_equal(failures, director.attack_cue_index(17_000, 8, 1), 2, "attack warning advances on beat three")
	_expect_equal(failures, director.attack_cue_index(17_500, 8, 1), 3, "attack warning reaches the final beat")
	_expect_equal(failures, director.attack_cue_index(18_000, 8, 1), -1, "attack warning ends at the bar boundary")
	_expect_equal(failures, director.attack_cue_index(28_000, 14, 2), 0, "syncopated warning starts on subdivision zero")
	_expect_equal(failures, director.attack_cue_index(28_500, 14, 2), 0, "syncopated warning holds through its first rest")
	_expect_equal(failures, director.attack_cue_index(28_750, 14, 2), 1, "syncopated second cue lands on subdivision three")
	_expect_equal(failures, director.attack_cue_index(29_000, 14, 2), 2, "syncopated third cue returns to a whole beat")
	_expect_equal(failures, director.attack_cue_index(29_750, 14, 2), 3, "syncopated final cue lands just before impact")
	_expect_equal(failures, director.attack_cue_index(22_000, 11, 3), 0, "rush warning starts immediately")
	_expect_equal(failures, director.attack_cue_index(22_750, 11, 3), 0, "rush warning preserves its long opening rest")
	_expect_equal(failures, director.attack_cue_index(23_000, 11, 3), 1, "rush second cue begins the acceleration")
	_expect_equal(failures, director.attack_cue_index(23_500, 11, 3), 2, "rush third cue lands late in the bar")
	_expect_equal(failures, director.attack_cue_index(23_750, 11, 3), 3, "rush final cue lands directly before impact")
	return failures


func _expect_equal(failures: Array, actual, expected, message: String) -> void:
	if actual != expected:
		failures.append("%s: expected %s, got %s" % [message, expected, actual])


func _expect_true(failures: Array, actual: bool, message: String) -> void:
	if not actual:
		failures.append("%s: expected true" % message)


func _expect_false(failures: Array, actual: bool, message: String) -> void:
	if actual:
		failures.append("%s: expected false" % message)
