extends RefCounted

const CommandBufferScript = preload("res://scripts/beatspell/spell_command_buffer.gd")


func run() -> Array[String]:
	var failures: Array[String] = []
	var command = CommandBufferScript.new()

	var start: Dictionary = command.register_step(2510, 500.0)
	_expect(failures, start.status == "accepted", "FLARE can begin on an arbitrary whole beat")
	_expect(failures, command.events[0].ring_tick == 2, "step preserves its absolute eight-position ring phase")
	var flare: Dictionary = command.finish(2990, 500.0)
	_expect(failures, flare.skill == "fireball" and flare.grade == "perfect", "whole-beat step then finish casts FLARE")
	_expect(failures, flare.events.size() == 2 and flare.events[1].ring_tick == 4, "finish event keeps its global ring phase")
	_expect(failures, not command.is_active(), "successful finish clears the command")

	command.register_step(4000, 500.0)
	command.register_step(4250, 500.0)
	var mend: Dictionary = command.finish(4500, 500.0)
	_expect(failures, mend.skill == "heal", "whole, half, whole rhythm casts MEND")
	_expect(failures, mend.events[1].ring_tick == 1, "half-beat step is drawn between whole-beat corners")

	var empty_finish: Dictionary = command.finish(5000, 500.0)
	_expect(failures, empty_finish.skill.is_empty(), "finish without steps misses safely")
	var half_start: Dictionary = command.register_step(5250, 500.0)
	_expect(failures, half_start.status == "needs_whole_beat" and not command.is_active(), "idle command cannot begin on a half beat")
	var off_pulse: Dictionary = command.register_step(5120, 500.0)
	_expect(failures, off_pulse.status == "off_pulse", "input outside the half-beat timing window is rejected")

	command.register_step(6000, 500.0)
	command.register_step(6500, 500.0)
	var wrong: Dictionary = command.finish(7000, 500.0)
	_expect(failures, wrong.skill.is_empty() and not command.is_active(), "unknown rhythm misses and resets immediately")

	command.register_step(8010, 500.0)
	var good_flare: Dictionary = command.finish(8570, 500.0)
	_expect(failures, good_flare.skill == "fireball" and good_flare.grade == "good", "near-beat finish casts with a good grade")
	return failures


func _expect(failures: Array[String], condition: bool, label: String) -> void:
	if not condition:
		failures.append(label)
