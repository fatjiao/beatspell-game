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
