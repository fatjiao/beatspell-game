extends SceneTree

const SettingsStore = preload("res://scripts/settings/settings_store.gd")
const Lang = preload("res://scripts/beatspell/localization.gd")
const TEST_PATH := "res://build/beatspell-flow-test-settings.json"
var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	SettingsStore.save_settings(SettingsStore.DEFAULTS, TEST_PATH)
	var stage = load("res://scenes/beatspell/beatspell_battle.tscn").instantiate()
	# Never read or write the player's actual settings.
	stage.set("_settings_path", TEST_PATH)
	stage.set("_records_path", "res://build/beatspell-flow-test-records.json")
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
	_check(stage.get("_battle").boss_hp == stage.get("_battle").MAX_BOSS_HP, "practice restores target health")
	_check(stage.get("_performance").successful_cast_count == 6, "practice casts reach performance statistics")
	var drill_key := InputEventKey.new()
	drill_key.physical_keycode = KEY_T
	drill_key.pressed = true
	stage.call("_unhandled_input", drill_key)
	_check(stage.get("_practice_defense") and stage.call("_is_attack_bar", 1), "T unlocks defense drill after lessons")
	for bar in [1, 3]:
		stage.set("_bar_index", bar)
		stage.set("_song_time_ms", (bar + 1) * 2000 - 500)
		stage.call("_cast_skill", "shield", "perfect")
		stage.call("_resolve_bar", bar)
	_check(stage.get("_battle").perfect_guards == 2, "scene passes impact timestamps into perfect guard")
	_check(stage.get("_battle").exposed and stage.get("_battle").break_count == 1, "two precise guards expose drill target")
	_check(stage.get("_battle").player_hp == 5, "defense drill never damages player")
	stage.call("_cast_skill", "fireball", "perfect")
	_check(not stage.get("_battle").exposed, "next scene fireball consumes exposure")
	var mode_key := InputEventKey.new()
	mode_key.physical_keycode = KEY_RIGHT
	mode_key.pressed = true
	stage.set("_bar_index", 3)
	stage.set("_song_time_ms", 7500)
	stage.call("_unhandled_input", mode_key)
	_check(stage.get("_drill").pattern() == "standard", "mode switch does not change the warning already playing")
	stage.call("_cast_skill", "shield", "perfect")
	stage.set("_song_time_ms", 8000)
	stage.call("_update_bar")
	_check(stage.get("_drill").report().rows[0].attempts == 3, "impact belongs to old pattern before queued mode commits")
	_check(stage.get("_drill").pattern() == "syncopated", "queued selection commits at the new bar")
	stage.set("_bar_index", 5)
	_check(stage.call("_attack_cue_index", 10_500) == 0, "syncopated drill preserves the opening rest")
	_check(stage.call("_attack_cue_index", 10_750) == 1, "drill audio uses the selected cue positions")
	stage.set("_song_time_ms", 11_500)
	stage.call("_cast_skill", "shield", "good")
	stage.call("_resolve_bar", 5)
	_check(stage.get("_drill").report().last_outcome == "GOOD SHIELD", "ordinary block explains grade instead of false timing feedback")
	var report_key := InputEventKey.new()
	report_key.physical_keycode = KEY_TAB
	report_key.pressed = true
	stage.call("_unhandled_input", report_key)
	_check(stage.get("_paused") and stage.get_node("BattleOverlay").mode == "drill_report", "training report pauses gameplay")
	stage.call("_unhandled_input", mode_key)
	_check(stage.get("_drill").requested == 1, "report ignores mode changes while paused")
	stage.call("_unhandled_input", report_key)
	_check(stage.get("_paused") and stage.get_node("BattleOverlay").mode == "pause", "closing report retains pause")
	stage.call("_unhandled_input", report_key)
	var resume_key := InputEventKey.new()
	resume_key.physical_keycode = KEY_P
	resume_key.pressed = true
	stage.call("_unhandled_input", resume_key)
	_check(not stage.get("_paused") and not stage.get("_drill_report_open"), "P resumes directly from training report")
	stage.set("_song_time_ms", 11_900)
	stage.call("_unhandled_input", drill_key)
	stage.call("_unhandled_input", drill_key)
	_check(not stage.call("_is_attack_bar", 5) and stage.call("_is_attack_bar", 7), "mid-warning drill entry waits for a complete future warning")
	stage.call("_unhandled_input", report_key)
	var restart_key := InputEventKey.new()
	restart_key.physical_keycode = KEY_R
	restart_key.pressed = true
	stage.call("_unhandled_input", restart_key)
	_check(not stage.get("_paused") and not stage.get("_drill_report_open") and stage.get("_practice").step == 0, "R restarts practice directly from training report")
	stage.call("_open_options")
	_check(stage.get("_paused"), "opening options pauses the battle")
	_check(stage.get_node("BattleOverlay").mode == "options", "options overlay appears")
	stage.set("_options_index", 0)
	stage.call("_handle_options_input", KEY_LEFT)
	var saved: Dictionary = SettingsStore.load_settings(TEST_PATH)
	_check(is_equal_approx(saved.music_volume, stage.get("_options").music_volume), "volume change persists to isolated settings")
	stage.get("_options").language = "auto"
	stage.set("_options_index", 4)
	var frozen_song: int = stage.get("_song_time_ms")
	var frozen_command: Array = stage.get("_command").events.duplicate(true)
	var frozen_report: Dictionary = stage.get("_drill").report()
	stage.call("_show_feedback", "NEXT %s", Color.WHITE, 900, ["RUSH"])
	stage.call("_handle_options_input", KEY_RIGHT)
	_check(Lang.language == "zh_CN" and stage.get_node("BattleOverlay").options_data.language == "zh_CN", "language switches immediately in options")
	_check(Lang.text(stage.get("_feedback"), stage.get("_feedback_args")) == "下轮 疾奏", "pending feedback translates after switching")
	_check(stage.get("_paused") and stage.get("_song_time_ms") == frozen_song, "language switch retains pause and music position")
	_check(stage.get("_command").events == frozen_command and stage.get("_drill").report() == frozen_report, "language switch retains command and training records")
	_check(SettingsStore.load_settings(TEST_PATH).language == "zh_CN", "language preference persists")
	stage.call("_handle_options_input", KEY_RIGHT)
	_check(Lang.language == "en" and Lang.text(stage.get("_feedback"), stage.get("_feedback_args")) == "NEXT RUSH", "switching back restores English feedback")
	var restarted = load("res://scenes/beatspell/beatspell_battle.tscn").instantiate()
	restarted.set("_settings_path", TEST_PATH)
	restarted.set("_records_path", "res://build/beatspell-flow-test-records.json")
	root.add_child(restarted)
	_check(restarted.get("_options").language == "en" and Lang.language == "en", "new scene reloads saved language")
	restarted.queue_free()
	stage.set("_options_index", 0)
	stage.call("_handle_options_input", KEY_ESCAPE)
	_check(stage.get("_paused") and stage.get_node("BattleOverlay").mode == "pause", "closing options preserves pause")
	stage.call("_toggle_pause")
	_check(not stage.get("_paused"), "battle resumes from pause")
	stage.call("_show_title")
	_check(stage.get("_waiting_to_start") and not stage.get("_practice_mode"), "returning to title clears practice")
	var help_key := InputEventKey.new()
	help_key.physical_keycode = KEY_H
	help_key.pressed = true
	stage.call("_unhandled_input", help_key)
	_check(stage.get_node("BattleOverlay").mode == "guide", "H opens spellbook")
	stage.call("_unhandled_input", help_key)
	_check(stage.get_node("BattleOverlay").mode == "title", "closing spellbook restores title")
	stage.call("_start_run")
	_check(not stage.get("_practice_mode"), "normal battle starts after practice")
	_check(stage.get("_performance").input_count == 0, "new battle clears previous statistics")
	_check(stage.get("_drill").report().rows[0].attempts == 0, "restart clears round training statistics")
	stage.get("_command").register_step(0)
	stage.set("_song_time_ms", 1625)
	stage.call("_update_command")
	_check(stage.get("_performance").attempt_count == 0, "expiry boundary remains inclusive")
	stage.set("_song_time_ms", 1626)
	stage.call("_update_command")
	stage.call("_update_command")
	_check(stage.get("_performance").attempt_count == 1 and stage.get("_performance").failed_cast_count == 1, "expired command is one failed attempt, never duplicated")
	_check(stage.get("_performance").input_count == 0, "timeout does not invent a physical input")
	stage.get("_command").register_step(2000)
	stage.call("_finish_battle", "RITUAL EXPIRED", false)
	_check(stage.get("_performance").failed_cast_count == 2, "unfinished command at battle end counts once")
	stage.call("_start_run")
	stage.get("_battle").boss_hp = 3
	stage.get("_battle").exposed = true
	stage.set("_song_time_ms", 0)
	stage.call("_register_action", "charge")
	stage.set("_song_time_ms", 500)
	stage.call("_register_action", "cast")
	_check(stage.get("_finished") and stage.get("_battle").is_victory(), "bonus fireball win reaches scene result")
	_check(stage.get_node("BattleOverlay").mode == "result", "result overlay follows finish")
	# This test starts many sounds in a single frame. Let the audio server
	# process deferred playback cleanup before shutting down the test process.
	for player in stage.get("_sfx_players").values():
		player.stop()
	for player in stage.get("_music_players").values():
		player.stop()
	await create_timer(0.5).timeout
	stage.queue_free()
	await process_frame
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(TEST_PATH)
	DirAccess.remove_absolute("res://build/beatspell-flow-test-records.json")
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
