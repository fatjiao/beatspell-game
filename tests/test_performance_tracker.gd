extends RefCounted

const PerformanceTrackerScript = preload("res://scripts/beatspell/performance_tracker.gd")


func run() -> Array[String]:
	var failures: Array[String] = []
	var tracker = PerformanceTrackerScript.new()
	_expect_equal(failures, tracker.input_count, 0, "tracker starts with no inputs")
	_expect_equal(failures, tracker.attempt_count, 0, "tracker starts with no spell attempts")

	tracker.record_input({"grade": "perfect", "offset_ms": -20})
	tracker.record_input({"grade": "good", "offset_ms": 40})
	tracker.record_input({"grade": "miss", "offset_ms": 160})
	_expect_equal(failures, tracker.input_count, 3, "every physical input is counted")
	_expect_equal(failures, tracker.perfect_input_count, 1, "perfect inputs are counted")
	_expect_equal(failures, tracker.good_input_count, 1, "good inputs are counted")
	_expect_equal(failures, tracker.missed_input_count, 1, "missed inputs are counted")
	_expect_equal(failures, tracker.average_absolute_offset_ms(), 73, "average absolute timing error is rounded")
	_expect_equal(failures, tracker.average_signed_offset_ms(), 60, "signed timing average preserves early and late direction")
	_expect_equal(failures, tracker.timing_bias(), "LATE", "positive timing average reports late bias")

	tracker.record_attempt("fireball", "perfect")
	tracker.record_attempt("heal", "good")
	tracker.record_attempt("", "miss")
	_expect_equal(failures, tracker.attempt_count, 3, "finish presses create spell attempts")
	_expect_equal(failures, tracker.successful_cast_count, 2, "recognized spells count as successful casts")
	_expect_equal(failures, tracker.perfect_cast_count, 1, "perfect spells are counted")
	_expect_equal(failures, tracker.good_cast_count, 1, "good spells are counted")
	_expect_equal(failures, tracker.failed_cast_count, 1, "broken rhythms count as failed casts")
	_expect_equal(failures, tracker.rank(), "B", "mixed run receives a proportional rank")

	var perfect_tracker = PerformanceTrackerScript.new()
	perfect_tracker.record_input({"grade": "perfect", "offset_ms": -12})
	perfect_tracker.record_input({"grade": "perfect", "offset_ms": 18})
	perfect_tracker.record_attempt("fireball", "perfect")
	perfect_tracker.record_attempt("shield", "perfect")
	_expect_equal(failures, perfect_tracker.rank(), "S", "clean accurate run earns S rank")

	tracker.reset()
	_expect_equal(failures, tracker.input_count, 0, "reset clears input statistics")
	_expect_equal(failures, tracker.attempt_count, 0, "reset clears attempt statistics")
	_expect_equal(failures, tracker.timing_bias(), "ON TIME", "empty tracker has neutral timing bias")
	_expect_equal(failures, tracker.rank(), "C", "empty run does not earn a high rank")
	return failures


func _expect_equal(failures: Array[String], actual: Variant, expected: Variant, label: String) -> void:
	if actual != expected:
		failures.append("%s: expected %s, got %s" % [label, expected, actual])
