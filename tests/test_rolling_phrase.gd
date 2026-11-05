extends RefCounted

const RollingPhraseScript = preload("res://scripts/beatspell/rolling_phrase.gd")


func run() -> Array[String]:
	var failures: Array[String] = []
	var phrase = RollingPhraseScript.new()
	var first: Dictionary = phrase.register_input(2510, "charge", 500.0)
	_expect(failures, first.status == "accepted", "arbitrary beat can start a phrase")
	_expect(failures, phrase.anchor_beat == 5 and first.slot == 0, "first input becomes relative slot zero")
	_expect(failures, phrase.inputs[0].ring_slot == 1, "first input keeps its absolute ring position")
	var second: Dictionary = phrase.register_input(2990, "cast", 500.0)
	_expect(failures, second.status == "accepted" and second.slot == 1, "next global beat becomes relative slot one")
	_expect(failures, phrase.inputs[1].ring_slot == 2, "later input advances from the global ring position")
	_expect(failures, not phrase.is_due(4499, 500.0), "phrase remains active before four beats elapse")
	_expect(failures, phrase.is_due(4500, 500.0), "phrase expires four beats after its anchor")

	phrase.reset()
	phrase.register_input(5000, "cast", 500.0)
	var duplicate: Dictionary = phrase.register_input(5030, "charge", 500.0)
	_expect(failures, duplicate.status == "duplicate" and phrase.broken, "two moves on one relative beat break the phrase")

	phrase.reset()
	var off_pulse: Dictionary = phrase.register_input(5170, "charge", 500.0)
	_expect(failures, off_pulse.status == "off_pulse" and not phrase.is_active(), "off-pulse input does not anchor an idle phrase")

	phrase.reset()
	phrase.register_input(6000, "charge", 500.0)
	var late: Dictionary = phrase.register_input(8000, "cast", 500.0)
	_expect(failures, late.status == "expired", "input beyond the four slots cannot enter the old phrase")
	return failures


func _expect(failures: Array[String], condition: bool, label: String) -> void:
	if not condition:
		failures.append(label)
