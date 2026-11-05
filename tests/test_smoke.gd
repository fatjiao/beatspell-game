extends RefCounted


func run() -> Array[String]:
	var failures: Array[String] = []
	if Engine.get_version_info().get("major", 0) < 4:
		failures.append("Godot 4 or newer is required")
	if not InputMap.has_action("battle_charge"):
		failures.append("battle_charge input action is missing")
	if not InputMap.has_action("battle_cast"):
		failures.append("battle_cast input action is missing")
	if not ResourceLoader.exists("res://scenes/beatspell/beatspell_battle.tscn"):
		failures.append("beatspell battle scene is missing")
	if ProjectSettings.get_setting("application/run/main_scene") != "res://scenes/beatspell/beatspell_battle.tscn":
		failures.append("beatspell battle is not the main scene")
	if not InputMap.has_action("instrument_drums"):
		failures.append("instrument_drums input action is missing")
	if not InputMap.has_action("instrument_bass"):
		failures.append("instrument_bass input action is missing")
	if not InputMap.has_action("instrument_synth"):
		failures.append("instrument_synth input action is missing")
	if not InputMap.has_action("instrument_lead"):
		failures.append("instrument_lead input action is missing")
	if not ResourceLoader.exists("res://assets/art/subway/subway_background.png"):
		failures.append("subway background is missing")
	if not ResourceLoader.exists("res://assets/art/loop/loop_idle.png"):
		failures.append("Loop character art is missing")
	return failures
