extends RefCounted


func run() -> Array[String]:
	var failures: Array[String] = []
	var stage_script = load("res://scripts/prototype/prototype_stage.gd")
	if stage_script == null:
		failures.append("prototype stage script is missing")
		return failures

	var stage = stage_script.new()
	var events: Array = []
	events.resize(20)
	stage.set("_events", events)

	stage.set("_perfect_count", 19)
	stage.set("_good_count", 0)
	_expect_equal(failures, stage.call("_result_rank"), "S", "95 percent should earn S")

	stage.set("_perfect_count", 16)
	stage.set("_good_count", 3)
	_expect_equal(failures, stage.call("_result_rank"), "A", "90.5 percent should earn A")

	stage.set("_perfect_count", 10)
	stage.set("_good_count", 0)
	_expect_equal(failures, stage.call("_result_rank"), "C", "50 percent should earn C")
	stage.free()
	return failures


func _expect_equal(failures: Array[String], actual: Variant, expected: Variant, label: String) -> void:
	if actual != expected:
		failures.append("%s: expected %s, got %s" % [label, expected, actual])
