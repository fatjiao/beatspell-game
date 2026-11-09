extends RefCounted

const TimingProfileScript = preload("res://scripts/beatspell/timing_profile.gd")


func run() -> Array[String]:
	var failures: Array[String] = []
	var profile = TimingProfileScript.new()
	_expect_equal(failures, profile.bpm, 120.0, "default tempo is 120 BPM")
	_expect_equal(failures, profile.beat_ms(), 500.0, "120 BPM produces 500 ms beats")
	_expect_equal(failures, profile.bar_ms(), 2000, "default bar contains four beats")
	_expect_equal(failures, profile.grade_for_offset(55), "perfect", "perfect window includes its boundary")
	_expect_equal(failures, profile.grade_for_offset(-55), "perfect", "perfect window is symmetric")
	_expect_equal(failures, profile.grade_for_offset(56), "good", "one millisecond beyond perfect is good")
	_expect_equal(failures, profile.grade_for_offset(135), "good", "good window includes its boundary")
	_expect_equal(failures, profile.grade_for_offset(-136), "miss", "one millisecond beyond good is a miss")
	profile.input_offset_ms = 35
	_expect_equal(failures, profile.adjusted_song_time(1000), 965, "positive calibration offset moves input earlier")
	_expect_equal(failures, profile.adjusted_song_time(20), 0, "adjusted input time never becomes negative")
	var quantized: Dictionary = profile.quantize(556)
	_expect_equal(failures, quantized.tick, 1, "quantization uses the configured beat duration")
	_expect_equal(failures, quantized.offset_ms, 56, "quantization preserves signed timing error")
	_expect_equal(failures, quantized.grade, "good", "quantization uses configured timing windows")
	_expect(failures, quantized.valid, "good timing remains valid")
	_expect_equal(failures, profile.command_expiry_ms(), 1625.0, "command expiry uses configured beat length")
	return failures


func _expect(failures: Array[String], condition: bool, label: String) -> void:
	if not condition:
		failures.append(label)


func _expect_equal(failures: Array[String], actual: Variant, expected: Variant, label: String) -> void:
	if actual != expected:
		failures.append("%s: expected %s, got %s" % [label, expected, actual])
