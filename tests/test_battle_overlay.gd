extends RefCounted

const BattleOverlayScript = preload("res://scripts/beatspell/battle_overlay.gd")


func run() -> Array[String]:
	var failures: Array[String] = []
	var overlay = BattleOverlayScript.new()
	overlay.show_title()
	_expect_equal(failures, overlay.mode, "title", "overlay can show the title state")
	overlay.show_count_in(3)
	_expect_equal(failures, overlay.mode, "count_in", "overlay can show count-in state")
	_expect_equal(failures, overlay.count_value, 3, "count-in preserves its displayed value")
	overlay.show_pause()
	_expect_equal(failures, overlay.mode, "pause", "overlay can show pause state")
	overlay.flash_phase(3, "OVERDRIVE", Color("ff4f70"), 900)
	_expect_equal(failures, overlay.phase_number, 3, "phase flash stores the active phase")
	_expect_equal(failures, overlay.phase_name, "OVERDRIVE", "phase flash stores the phase name")
	overlay.show_result({
		"title": "BEAST DISPELLED", "color": Color("69f0a5"), "rank": "A",
		"successful_casts": 8, "attempts": 10, "perfect_casts": 5,
		"good_casts": 3, "failed_casts": 2, "inputs": 18,
		"average_offset_ms": 42, "timing_bias": "ON TIME", "boss_hp": 0,
		"boss_max_hp": 36,
	})
	_expect_equal(failures, overlay.mode, "result", "overlay can show result state")
	_expect_equal(failures, overlay.result_data.rank, "A", "result state preserves battle rank")
	overlay.hide_primary()
	_expect_equal(failures, overlay.mode, "", "overlay can return to unobstructed battle state")
	overlay.free()
	return failures


func _expect_equal(failures: Array[String], actual: Variant, expected: Variant, label: String) -> void:
	if actual != expected:
		failures.append("%s: expected %s, got %s" % [label, expected, actual])
