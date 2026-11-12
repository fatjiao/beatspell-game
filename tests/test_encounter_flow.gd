extends SceneTree

const Settings = preload("res://scripts/settings/settings_store.gd")
const Records = preload("res://scripts/beatspell/run_records.gd")
const SETTINGS := "res://build/encounter-flow-settings.json"
const RECORDS := "res://build/encounter-flow-records.json"
var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _key(stage: Node, code: int) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = true
	stage.call("_unhandled_input", event)


func _stage() -> Node:
	var stage = load("res://scenes/beatspell/beatspell_battle.tscn").instantiate()
	stage.set("_settings_path", SETTINGS)
	stage.set("_records_path", RECORDS)
	root.add_child(stage)
	stage.set_process(false)
	return stage


func _run() -> void:
	Settings.save_settings(Settings.DEFAULTS, SETTINGS)
	Records.save_records(Records.empty_records(), RECORDS)
	var stage := _stage()
	_key(stage, KEY_LEFT)
	_check(stage.get("_encounter") == "prism", "title wraps left to prism")
	_key(stage, KEY_LEFT)
	_check(stage.get("_encounter") == "gauntlet", "title wraps left to gauntlet")
	_check(Settings.load_settings(SETTINGS).encounter == "gauntlet", "selection saves")
	stage.set("_settings_path", "res://build/nonexistent-settings-folder/settings.json")
	_key(stage, KEY_RIGHT)
	_check(stage.get_node("BattleOverlay").title_save_failed, "title reports selection save failure")
	stage.set("_settings_path", SETTINGS)
	_key(stage, KEY_LEFT)
	_check(not stage.get_node("BattleOverlay").title_save_failed, "successful selection save clears old error")
	_key(stage, KEY_V)
	_check(stage.get_node("BattleOverlay").mode == "records", "title V opens records")
	_key(stage, KEY_ENTER)
	_check(stage.get("_waiting_to_start"), "record book consumes start input")
	_key(stage, KEY_ESCAPE)
	_check(stage.get_node("BattleOverlay").mode == "title", "record book returns to title")
	_key(stage, KEY_ENTER)
	_check(stage.call("_teaching_skill").is_empty(), "trial skips tutorial")
	_check(stage.call("_is_attack_bar", 1) and not stage.call("_is_attack_bar", 0), "trial starts attacking at second bar")
	for sample in [[1, 2750, 1, "standard"], [3, 6750, 1, "syncopated"], [5, 11750, 3, "rush"]]:
		stage.set("_bar_index", sample[0])
		_check(stage.call("_practice_pattern") == sample[3], "shared attack pattern: " + sample[3])
		_check(stage.call("_attack_cue_index", sample[1]) == sample[2], "audio and visual cue use encounter pattern")
		_check(stage.call("_attack_pattern_color") == {"standard": Color("ff668e"), "syncopated": Color("ff7f66"), "rush": Color("ffc45e")}[sample[3]], "warning color follows encounter pattern")
	stage.set("_active_phase", 1)
	stage.call("_resolve_boss_attack", 12000)
	_check(stage.get("_battle").player_hp == 3, "trial phase I attacks deal two damage")
	stage.set("_song_time_ms", 40000)
	stage.get("_battle").max_combo = 12
	stage.call("_finish_battle", "BEAST DISPELLED", true)
	stage.call("_finish_battle", "RITUAL BROKEN", false)
	stage.call("_result_overlay_data")
	var saved := Records.load_records(RECORDS)
	_check(saved.modes.gauntlet.attempts == 1 and saved.modes.gauntlet.wins == 1, "completed run records exactly once")
	_check(saved.modes.gauntlet.best_clear_ms == 40000, "clear time uses song time without count-in")
	_check(stage.get_node("BattleOverlay").result_data.record_flags.new_clear, "result shows first clear record")
	_key(stage, KEY_V)
	_check(stage.get_node("BattleOverlay").mode == "records", "result V opens saved records")
	_key(stage, KEY_ESCAPE)
	_check(stage.get_node("BattleOverlay").mode == "result", "record book returns to result")
	_key(stage, KEY_R)
	_check(stage.get("_encounter") == "gauntlet" and not stage.get("_finished"), "restart keeps encounter")
	stage.call("_show_title")
	_key(stage, KEY_RIGHT)
	_key(stage, KEY_RIGHT)
	_key(stage, KEY_RIGHT)
	_check(stage.get("_encounter") == "duel", "right selects duel")
	stage.call("_start_run")
	stage.set("_bar_index", -1)
	stage.set("_song_time_ms", 0)
	stage.get("_battle").boss_hp = 20
	stage.call("_update_bar")
	_check(stage.get("_active_phase") == 3 and stage.call("_is_attack_bar", 1), "duel uses health phase immediately")
	stage.call("_show_title")
	_check(Records.load_records(RECORDS).modes.duel.attempts == 0, "abandon never records a run")
	stage.call("_start_run", true)
	stage.call("_finish_battle", "RITUAL EXPIRED", false)
	_check(Records.load_records(RECORDS).modes.duel.attempts == 0, "practice never records battle results")
	stage.call("_start_run")
	stage.set("_records_path", "res://build/nonexistent-record-folder/records.json")
	stage.call("_finish_battle", "RITUAL EXPIRED", false)
	_check(stage.get_node("BattleOverlay").result_data.record_save_failed, "failed persistence is visible")
	stage.queue_free()
	await process_frame
	var reloaded := _stage()
	_check(reloaded.get("_encounter") == "duel" and reloaded.get("_records").modes.gauntlet.wins == 1, "new scene restores selection and records")
	reloaded.queue_free()
	await create_timer(0.5).timeout
	for path in [SETTINGS, RECORDS]:
		DirAccess.remove_absolute(path)
	if failures.is_empty():
		print("PASS: encounter_flow (selection, cues, damage, records, restart, practice, failure, reload)")
		quit(0)
	else:
		for failure in failures:
			printerr("FAIL: encounter_flow: " + failure)
		quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
