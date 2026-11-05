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
