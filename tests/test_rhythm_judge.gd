extends RefCounted


func run() -> Array[String]:
	var failures: Array[String] = []
	var event_script = load("res://scripts/rhythm/chart_event.gd")
	var judge_script = load("res://scripts/rhythm/rhythm_judge.gd")
	if event_script == null or judge_script == null:
		failures.append("Rhythm judgement scripts are missing")
		return failures

	_expect_grade(failures, event_script, judge_script, 1020, "drums", 0, "perfect")
	_expect_grade(failures, event_script, judge_script, 1080, "drums", 0, "good")
	_expect_grade(failures, event_script, judge_script, 1160, "drums", 0, "miss")
	_expect_grade(failures, event_script, judge_script, 1070, "drums", 50, "perfect")

	var consumed_event = event_script.new(1000, "drums", "tap")
	var consumed_judge = judge_script.new([consumed_event])
	var first: Dictionary = consumed_judge.judge(1000, "drums")
	var second: Dictionary = consumed_judge.judge(1000, "drums")
	_assert_equal(failures, first.grade, "perfect", "first input should score")
	_assert_equal(failures, second.grade, "miss", "consumed event must not score twice")

	var instrument_event = event_script.new(1000, "drums", "tap")
	var instrument_judge = judge_script.new([instrument_event])
	var wrong: Dictionary = instrument_judge.judge(1000, "bass")
	var right: Dictionary = instrument_judge.judge(1000, "drums")
	_assert_equal(failures, wrong.grade, "miss", "wrong instrument should miss")
	_assert_equal(failures, right.grade, "perfect", "wrong instrument must not consume event")
	return failures


func _expect_grade(
		failures: Array[String],
		event_script: Script,
		judge_script: Script,
		input_time_ms: int,
		instrument: String,
		calibration_ms: int,
		expected: String
) -> void:
	var chart_event = event_script.new(1000, "drums", "tap")
	var judge = judge_script.new([chart_event])
	var result: Dictionary = judge.judge(input_time_ms, instrument, calibration_ms)
	_assert_equal(failures, result.grade, expected, "grade at %d ms" % input_time_ms)


func _assert_equal(failures: Array[String], actual: Variant, expected: Variant, label: String) -> void:
	if actual != expected:
		failures.append("%s: expected %s, got %s" % [label, expected, actual])

