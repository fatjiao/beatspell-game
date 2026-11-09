extends SceneTree

const SettingsStore = preload("res://scripts/settings/settings_store.gd")
const TEST_PATH := "user://beatspell-flow-test-settings.json"
var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var stage = load("res://scenes/beatspell/beatspell_battle.tscn").instantiate()
	# Never read or write the player's actual settings.
	stage.set("_settings_path", TEST_PATH)
	root.add_child(stage)
	await process_frame
	stage.set_process(false)
	_check(stage.get("_waiting_to_start"), "title waits for input")
	_check(stage.get_node("BattleOverlay").mode == "title", "title overlay appears")
	stage.call("_start_run", true)
	stage.set("_song_time_ms", 0)
	_check(stage.get("_practice_mode"), "practice starts independently")
	_check(not stage.call("_is_attack_bar", 11), "practice disables boss attacks")
	for lesson in [["charge", "cast"], ["charge", "charge", "cast"], ["charge", "rest", "cast"]]:
		for repetition in 2:
			var time_ms := 0
			stage.get("_command").reset()
			for action in lesson:
				stage.set("_song_time_ms", time_ms)
				if action != "rest":
					stage.call("_register_action", action)
				time_ms += 500
	_check(stage.get("_practice").current_skill().is_empty(), "six casts unlock free practice")
	_check(stage.get("_battle").boss_hp == 36, "practice restores target health")
	_check(stage.get("_performance").successful_cast_count == 6, "practice casts reach performance statistics")
	stage.call("_open_options")
	_check(stage.get("_paused"), "opening options pauses the battle")
	_check(stage.get_node("BattleOverlay").mode == "options", "options overlay appears")
	stage.set("_options_index", 0)
	stage.call("_handle_options_input", KEY_LEFT)
	var saved: Dictionary = SettingsStore.load_settings(TEST_PATH)
	_check(is_equal_approx(saved.music_volume, stage.get("_options").music_volume), "volume change persists to isolated settings")
	stage.call("_handle_options_input", KEY_ESCAPE)
	_check(stage.get("_paused") and stage.get_node("BattleOverlay").mode == "pause", "closing options preserves pause")
	stage.call("_toggle_pause")
	_check(not stage.get("_paused"), "battle resumes from pause")
	stage.call("_show_title")
	_check(stage.get("_waiting_to_start") and not stage.get("_practice_mode"), "returning to title clears practice")
	stage.call("_start_run")
	_check(not stage.get("_practice_mode"), "normal battle starts after practice")
	_check(stage.get("_performance").input_count == 0, "new battle clears previous statistics")
	stage.call("_finish_battle", "TEST RESULT", false)
	_check(stage.get_node("BattleOverlay").mode == "result", "result overlay follows finish")
	stage.queue_free()
	await process_frame
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(TEST_PATH)
	if failures.is_empty():
		print("PASS: playtest_flow (practice, options, pause, save, title, restart, result)")
		quit(0)
	else:
		for failure in failures:
			printerr("FAIL: playtest_flow: " + failure)
		quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
