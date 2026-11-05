extends RefCounted

const InputTraceFade = preload("res://scripts/beatspell/input_trace_fade.gd")


func run() -> Array[String]:
	var failures: Array[String] = []
	var events := [{"input_time_ms": 1000}, {"input_time_ms": 1500}]
	_expect(failures, InputTraceFade.alpha_for([], 1500, false) == 0.0, "empty trail is invisible")
	_expect(failures, InputTraceFade.alpha_for(events, 5000, true) == 1.0, "active phrase never fades")
	_expect(failures, InputTraceFade.alpha_for(events, 2100, false) == 1.0, "completed trail holds before fading")
	_expect(failures, is_equal_approx(InputTraceFade.alpha_for(events, 2325, false), 0.5), "completed trail fades as one group")
	_expect(failures, InputTraceFade.alpha_for(events, 2500, false) == 0.0, "completed trail disappears after one second")
	return failures


func _expect(failures: Array[String], condition: bool, label: String) -> void:
	if not condition:
		failures.append(label)
