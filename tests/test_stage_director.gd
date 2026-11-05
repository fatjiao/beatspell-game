extends RefCounted

const StageDirector = preload("res://scripts/presentation/stage_director.gd")


func run() -> Array[String]:
	var failures: Array[String] = []
	var director = StageDirector.new()
	_expect_section(failures, director, 0, "drums", "D")
	_expect_section(failures, director, 3999, "drums", "D")
	_expect_section(failures, director, 4000, "bass", "F")
	_expect_section(failures, director, 6500, "synth", "J")
	_expect_section(failures, director, 9000, "lead", "K")
	_expect_section(failures, director, 12000, "ensemble", "")
	_expect_float(failures, director.cue_progress(1000), 0.0, "cue begins at window edge")
	_expect_float(failures, director.cue_progress(500), 0.5, "cue is halfway at 500 ms")
	_expect_float(failures, director.cue_progress(0), 1.0, "cue closes on the beat")
	_expect_float(failures, director.cue_progress(-200), 1.0, "cue stays closed just after beat")
	return failures


func _expect_section(
	_failures: Array[String],
	director: RefCounted,
	time_ms: int,
	expected_id: String,
	expected_key: String
) -> void:
	var section: Dictionary = director.section_at(time_ms)
	if section.id != expected_id:
		_failures.append("section at %d ms: expected %s, got %s" % [time_ms, expected_id, section.id])
	if section.key != expected_key:
		_failures.append("key at %d ms: expected %s, got %s" % [time_ms, expected_key, section.key])


func _expect_float(failures: Array[String], actual: float, expected: float, label: String) -> void:
	if not is_equal_approx(actual, expected):
		failures.append("%s: expected %.2f, got %.2f" % [label, expected, actual])
