extends RefCounted


func run() -> Array[String]:
	var failures: Array[String] = []
	var loader_script = load("res://scripts/rhythm/chart_loader.gd")
	if loader_script == null:
		failures.append("Chart loader script is missing")
		return failures

	var loader = loader_script.new()
	var valid: Dictionary = loader.load_chart("res://data/charts/prototype.json")
	_assert_true(failures, valid.get("ok", false), "valid chart should load")
	if valid.get("ok", false):
		_assert_equal(failures, valid.data.bpm, 120.0, "chart BPM")
		_assert_equal(failures, valid.data.events.size(), 20, "event count")
		_assert_true(
			failures,
			valid.data.events[0].time_ms <= valid.data.events[-1].time_ms,
			"events should remain sorted"
		)

	var invalid: Dictionary = loader.load_chart("res://tests/fixtures/invalid_chart.json")
	_assert_true(failures, not invalid.get("ok", true), "invalid chart should fail")
	_assert_true(
		failures,
		"event 0" in invalid.get("error", ""),
		"invalid chart error should identify event index"
	)
	return failures


func _assert_true(failures: Array[String], condition: bool, label: String) -> void:
	if not condition:
		failures.append(label)


func _assert_equal(failures: Array[String], actual: Variant, expected: Variant, label: String) -> void:
	if actual != expected:
		failures.append("%s: expected %s, got %s" % [label, expected, actual])

