extends RefCounted


func run() -> Array[String]:
	var failures: Array[String] = []
	var calibration_script = load("res://scripts/settings/calibration.gd")
	var settings_script = load("res://scripts/settings/settings_store.gd")
	if calibration_script == null or settings_script == null:
		failures.append("Calibration scripts are missing")
		return failures
	_assert_equal(failures, calibration_script.sample_for_tap(-1, -1).accepted, false, "pre-roll tap is ignored")
	_assert_equal(failures, calibration_script.sample_for_tap(610, 1).accepted, false, "same beat cannot fill multiple calibration slots")
	_assert_equal(failures, calibration_script.sample_for_tap(580, 2).accepted, false, "backward beat is ignored")
	var sample: Dictionary = calibration_script.sample_for_tap(1218, 1)
	_assert_equal(failures, sample.accepted, true, "next distinct beat is accepted")
	_assert_equal(failures, sample.beat, 2, "sample tracks the nearest beat")
	_assert_equal(failures, sample.offset_ms, 18, "sample preserves timing offset")

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
	_assert_equal(failures, parsed.music_volume, 0.8, "old settings gain audio defaults")
	var invalid: Dictionary = settings_script.parse_settings_text('{"music_volume":2,"sfx_volume":-1,"screen_shake":"false","fullscreen":1}')
	_assert_equal(failures, invalid.music_volume, 1.0, "music volume clamps high")
	_assert_equal(failures, invalid.sfx_volume, 0.0, "SFX volume clamps low")
	_assert_equal(failures, invalid.screen_shake, true, "invalid shake value uses default")
	_assert_equal(failures, invalid.fullscreen, false, "invalid fullscreen value uses default")
	var valid: Dictionary = settings_script.parse_settings_text('{"music_volume":0.3,"sfx_volume":0.6,"screen_shake":false,"fullscreen":true,"audio_offset_ms":85}')
	_assert_equal(failures, valid.music_volume, 0.3, "music slider survives parsing")
	_assert_equal(failures, valid.screen_shake, false, "shake can be disabled")
	_assert_equal(failures, valid.audio_offset_ms, 85, "options preserve calibration")
	return failures


func _assert_equal(failures: Array[String], actual: Variant, expected: Variant, label: String) -> void:
	if actual != expected:
		failures.append("%s: expected %s, got %s" % [label, expected, actual])

