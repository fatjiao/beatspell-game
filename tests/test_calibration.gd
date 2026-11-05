extends RefCounted


func run() -> Array[String]:
	var failures: Array[String] = []
	var calibration_script = load("res://scripts/settings/calibration.gd")
	var settings_script = load("res://scripts/settings/settings_store.gd")
	if calibration_script == null or settings_script == null:
		failures.append("Calibration scripts are missing")
		return failures

	_assert_equal(
		failures,
		calibration_script.stable_offset([18, 20, 21, 22, 500]),
		20,
		"outlier-resistant median"
	)
	_assert_equal(
		failures,
		calibration_script.stable_offset([-500, -450, -400]),
		-300,
		"negative clamp"
	)
	_assert_equal(
		failures,
		calibration_script.stable_offset([450, 500, 550]),
		300,
		"positive clamp"
	)
	_assert_equal(
		failures,
		calibration_script.stable_offset([]),
		0,
		"empty samples"
	)

	var defaults: Dictionary = settings_script.parse_settings_text("not valid json")
	_assert_equal(failures, defaults.audio_offset_ms, 0, "malformed settings fallback")
	_assert_equal(failures, defaults.assist_mode, false, "default assist mode")
	var parsed: Dictionary = settings_script.parse_settings_text(
		'{"audio_offset_ms":85,"assist_mode":true}'
	)
	_assert_equal(failures, parsed.audio_offset_ms, 85, "saved audio offset")
	_assert_equal(failures, parsed.assist_mode, true, "saved assist mode")
	return failures


func _assert_equal(failures: Array[String], actual: Variant, expected: Variant, label: String) -> void:
	if actual != expected:
		failures.append("%s: expected %s, got %s" % [label, expected, actual])

