extends RefCounted

const SpellMatcher = preload("res://scripts/beatspell/spell_matcher.gd")


func run() -> Array[String]:
	var failures: Array[String] = []
	var matcher = SpellMatcher.new()
	var downbeat: Dictionary = matcher.quantize_input(10)
	_expect(failures, downbeat.valid and downbeat.slot == 0 and downbeat.grade == "perfect", "downbeat quantizes as perfect slot zero")
	var second_beat: Dictionary = matcher.quantize_input(490)
	_expect(failures, second_beat.valid and second_beat.slot == 1 and second_beat.offset_ms == -10, "input quantizes to nearest beat")
	var good: Dictionary = matcher.quantize_input(590)
	_expect(failures, good.valid and good.grade == "good", "ninety millisecond error is good")
	_expect(failures, not matcher.quantize_input(660).valid, "late input outside window is invalid")

	_expect_skill(failures, matcher, [_event(0, "charge"), _event(1, "cast"), _event(2, "charge"), _event(3, "cast")], "fireball")
	_expect_skill(failures, matcher, [_event(0, "charge"), _event(1, "charge"), _event(3, "cast")], "shield")
	_expect_skill(failures, matcher, [_event(0, "cast"), _event(2, "cast"), _event(3, "cast")], "heal")
	var duplicate: Dictionary = matcher.match_phrase([_event(0, "charge"), _event(0, "cast")])
	_expect(failures, duplicate.skill == "", "duplicate slot breaks phrase")
	var wrong: Dictionary = matcher.match_phrase([_event(0, "cast"), _event(1, "charge")])
	_expect(failures, wrong.skill == "", "unknown pattern does not cast")
	return failures


func _event(slot: int, action: String, grade: String = "perfect") -> Dictionary:
	return {"slot": slot, "action": action, "grade": grade}


func _expect_skill(failures: Array[String], matcher: RefCounted, inputs: Array, expected: String) -> void:
	var result: Dictionary = matcher.match_phrase(inputs)
	_expect(failures, result.skill == expected, "%s pattern casts %s" % [expected, expected])


func _expect(failures: Array[String], condition: bool, label: String) -> void:
	if not condition:
		failures.append(label)

