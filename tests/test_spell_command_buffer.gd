extends RefCounted

const CommandBufferScript = preload("res://scripts/beatspell/spell_command_buffer.gd")


func run() -> Array[String]:
	var failures: Array[String] = []
	var command = CommandBufferScript.new()

	var start: Dictionary = command.register_step(2510, 500.0)
	_expect(failures, start.status == "accepted", "FLARE can begin on an arbitrary whole beat")
	_expect(failures, command.events[0].ring_tick == 1, "step preserves its absolute four-position ring phase")
	_expect(failures, command.events[0].has("ring_phase"), "step stores its unquantized live ring phase")
	_expect(failures, command.events[0].input_time_ms == 2510, "step stores its adjusted input time for trail fading")
	if command.events[0].has("ring_phase"):
		_expect(failures, command.events[0].ring_phase > 0.25, "late step is drawn after its target corner")
	var flare: Dictionary = command.finish(2990, 500.0)
	_expect(failures, flare.skill == "fireball" and flare.grade == "perfect", "whole-beat step then finish casts FLARE")
	_expect(failures, flare.events.size() == 2 and flare.events[1].ring_tick == 2, "finish event keeps its global ring phase")
	_expect(failures, flare.events.size() == 2 and flare.events[1].has("ring_phase"), "finish stores its unquantized live ring phase")
	if flare.events.size() == 2 and flare.events[1].has("ring_phase"):
		_expect(failures, flare.events[1].ring_phase < 0.5, "early finish is drawn before its target corner")
	_expect(failures, not command.is_active(), "successful finish clears the command")

	command.register_step(4000, 500.0)
	command.register_step(4500, 500.0)
	var mend: Dictionary = command.finish(5000, 500.0)
	_expect(failures, mend.skill == "heal", "three consecutive whole beats cast MEND")
	_expect(failures, mend.events[1].ring_tick == 1, "second MEND step advances to the next whole-beat corner")

	var empty_finish: Dictionary = command.finish(5000, 500.0)
	_expect(failures, empty_finish.skill.is_empty(), "finish without steps misses safely")
	var half_start: Dictionary = command.register_step(5250, 500.0)
	_expect(failures, half_start.status == "off_pulse" and not command.is_active(), "half-beat input is no longer accepted")
	_expect(failures, command.display_events.size() == 1, "off-pulse step is still kept for visual feedback")
	if command.display_events.size() == 1:
		_expect(failures, command.display_events[0].grade == "miss", "off-pulse step is marked as a miss")
		_expect(failures, is_equal_approx(command.display_events[0].ring_phase, 0.625), "off-pulse step keeps its exact ring position")
	var off_pulse: Dictionary = command.register_step(5200, 500.0)
	_expect(failures, off_pulse.status == "off_pulse", "input outside the whole-beat timing window is rejected")
	_expect(failures, command.display_events.size() == 1, "a new attempt replaces a standalone missed marker")

	var missed_finish: Dictionary = command.finish(5350, 500.0)
	_expect(failures, missed_finish.events.size() == 2, "off-pulse finish is also returned in the visual trail")
	if missed_finish.events.size() == 2:
		_expect(failures, missed_finish.events[1].action == "finish" and missed_finish.events[1].grade == "miss", "off-pulse finish keeps its shape and miss state")

	command.register_step(6000, 500.0)
	command.register_step(7000, 500.0)
	var wrong: Dictionary = command.finish(7500, 500.0)
	_expect(failures, wrong.skill.is_empty() and not command.is_active(), "unknown rhythm misses and resets immediately")

	command.register_step(8010, 500.0)
	var good_flare: Dictionary = command.finish(8570, 500.0)
	_expect(failures, good_flare.skill == "fireball" and good_flare.grade == "good", "near-beat finish casts with a good grade")
	return failures


func _expect(failures: Array[String], condition: bool, label: String) -> void:
	if not condition:
		failures.append(label)
