extends RefCounted


func run() -> Array[String]:
	var failures: Array[String] = []
	if Engine.get_version_info().get("major", 0) < 4:
		failures.append("Godot 4 or newer is required")
	if not InputMap.has_action("instrument_drums"):
		failures.append("instrument_drums input action is missing")
	if not InputMap.has_action("instrument_bass"):
		failures.append("instrument_bass input action is missing")
	if not InputMap.has_action("instrument_synth"):
		failures.append("instrument_synth input action is missing")
	if not InputMap.has_action("instrument_lead"):
		failures.append("instrument_lead input action is missing")
	return failures

