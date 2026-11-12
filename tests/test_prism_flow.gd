extends SceneTree

const Settings = preload("res://scripts/settings/settings_store.gd")
const Records = preload("res://scripts/beatspell/run_records.gd")
const SETTINGS := "res://build/prism-flow-settings.json"
const RECORDS := "res://build/prism-flow-records.json"
var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _key(stage: Node, code: int) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = true
	stage.call("_unhandled_input", event)


func _run() -> void:
	Settings.save_settings(Settings.DEFAULTS, SETTINGS)
	Records.save_records(Records.empty_records(), RECORDS)
	var stage = load("res://scenes/beatspell/beatspell_battle.tscn").instantiate()
	stage.set("_settings_path", SETTINGS)
	stage.set("_records_path", RECORDS)
	root.add_child(stage)
	stage.set_process(false)
	stage.call("_handle_focus_lost")
	_check(not stage.get("_paused") and stage.get_node("BattleOverlay").mode == "title", "focus loss on title is a no-op")
	_key(stage, KEY_LEFT)
	_check(stage.get("_encounter") == "prism", "Prism can be selected from title")
	_check(Settings.load_settings(SETTINGS).encounter == "prism", "Prism choice persists")
	_key(stage, KEY_ENTER)
	_check(stage.get("_battle").boss_hp == 72 and stage.get("_battle").max_boss_hp == 72, "Prism starts with seventy-two health")
	_check(stage.call("_is_prism") and stage.call("_teaching_skill").is_empty(), "Prism uses its own boss presentation without lessons")
	_check(stage.call("_result_overlay_data").boss_max_hp == 72, "results use encounter maximum")
	# A FLARE begun during armor but finished as the next open bar begins uses
	# the finishing bar; it also preserves boundary-attack-before-input ordering.
	stage.set("_song_time_ms", 3500)
	stage.set("_bar_index", 1)
	stage.call("_register_action", "charge")
	stage.set("_song_time_ms", 4000)
	stage.call("_register_action", "cast")
	_check(stage.get("_battle").boss_hp == 69 and stage.get("_battle").total_damage == 3, "finishing in open stance adds one damage")
	_check(stage.get("_battle").player_hp == 3, "Prism boundary attack resolves before finishing spell")
	stage.call("_start_run")
	stage.set("_song_time_ms", 500)
	stage.set("_bar_index", 0)
	stage.call("_cast_skill", "fireball", "good")
	_check(stage.get("_battle").total_damage == 1, "armored Good FLARE cannot deal zero")
	stage.get("_battle").exposed = true
	stage.get("_battle").resonance_ready = true
	stage.call("_cast_skill", "fireball", "good")
	_check(stage.get("_battle").total_damage == 4, "armor applies after combining existing damage bonuses")
	# Audio and drawing consume the same pattern. Offbeat starts with a real
	# 250ms rest; Echo's first two cues are only one eighth-note apart.
	var director = stage.get("_director")
	stage.set("_bar_index", 1)
	_check(stage.call("_practice_pattern") == "echo", "first Prism attack uses Echo")
	_check(director.attack_cue_steps(1, 1, stage.call("_practice_pattern")) == [0, 1, 4, 5], "Echo visual positions use the shared pattern")
	_check(stage.call("_attack_cue_index", 2000) == 0 and stage.call("_attack_cue_index", 2250) == 1, "Echo audio indices follow eighth-note pair")
	var echo_color: Color = stage.call("_attack_pattern_color")
	stage.set("_bar_index", 3)
	_check(stage.call("_practice_pattern") == "offbeat", "second Prism attack uses Offbeat")
	_check(director.attack_cue_steps(3, 1, stage.call("_practice_pattern")) == [1, 3, 5, 7], "Offbeat visual positions preserve opening rest")
	_check(stage.call("_attack_pattern_color") != echo_color, "new patterns have distinct warning colors")
	stage.get("_attack_cue_audio").reset()
	stage.get("_sfx_players").prism_warning.stop()
	stage.get("_sfx_players").warning.stop()
	stage.call("_update_attack_cue", 6000)
	_check(stage.call("_attack_cue_index", 6249) == -1 and not stage.get("_sfx_players").prism_warning.playing, "Offbeat first 250ms remain silent")
	stage.call("_update_attack_cue", 6250)
	_check(stage.get("_sfx_players").prism_warning.playing and not stage.get("_sfx_players").warning.playing, "Offbeat routes the new cue to its dedicated sound")
	stage.call("_start_run", true)
	_check(stage.get("_battle").boss_hp == 60 and stage.get("_battle").max_boss_hp == 60 and not stage.call("_is_prism"), "practice stays the original sixty-health target")
	stage.set("_bar_index", 0)
	stage.set("_song_time_ms", 500)
	stage.call("_cast_skill", "fireball", "perfect")
	_check(stage.get("_battle").total_damage == 2 and stage.get("_battle").boss_hp == 60, "practice excludes Prism armor modifier")
	# Resume keeps the music paused, the command intact and the original visual
	# freeze time until the complete three-beat preparation finishes.
	stage.call("_start_run")
	stage.call("_start_music")
	stage.set("_song_time_ms", 2250)
	stage.set("_bar_index", 1)
	stage.get("_command").register_step(2000)
	var command: Array = stage.get("_command").events.duplicate(true)
	stage.call("_handle_focus_lost")
	var pause_start: int = stage.get("_pause_started_ticks")
	stage.call("_handle_focus_lost")
	_check(stage.get("_paused") and stage.get("_pause_started_ticks") == pause_start, "duplicate focus loss leaves original pause origin intact")
	_key(stage, KEY_P)
	var resume_start: int = stage.get("_resume_started_ticks")
	_check(stage.get("_resume").active and stage.get_node("BattleOverlay").mode == "resume", "P opens resume count-in while paused")
	stage.call("_update_resume", resume_start + 249)
	_check(stage.get("_resume_click_index") == -1, "resume click respects frozen quarter-beat phase before next beat")
	stage.call("_update_resume", resume_start + 250)
	_check(stage.get("_resume_click_index") == 0, "first resume click occurs on aligned future beat")
	stage.call("_update_resume", resume_start + 1499)
	_key(stage, KEY_D)
	_check(stage.get("_paused") and stage.get("_song_time_ms") == 2250 and stage.get("_command").events == command, "music position and active command stay frozen through count-in")
	for player in stage.get("_music_players").values():
		_check(player.stream_paused, "each stem stays paused until count-in completes")
	stage.call("_update_resume", resume_start + 1500)
	_check(not stage.get("_paused") and not stage.get("_resume").active, "resume completes at exactly three beats")
	_check(stage.get("_song_time_ms") == 2250 and stage.get("_command").events == command, "resume preserves ring phase and input history")
	for player in stage.get("_music_players").values():
		_check(not player.stream_paused, "all stems resume together")
	# Both cancellation keys return to pause, without letting an old deadline
	# resume in the background. Focus loss and modal opening do the same.
	for cancel_key in [KEY_P, KEY_ESCAPE]:
		if not stage.get("_paused"):
			stage.call("_toggle_pause")
		_key(stage, KEY_P)
		var cancelled_start: int = stage.get("_resume_started_ticks")
		_key(stage, cancel_key)
		stage.call("_update_resume", cancelled_start + 2000)
		_check(stage.get("_paused") and not stage.get("_resume").active and stage.get_node("BattleOverlay").mode == "pause", "cancelled count-in stays paused: " + str(cancel_key))
	_key(stage, KEY_P)
	stage.call("_handle_focus_lost")
	_check(stage.get("_paused") and not stage.get("_resume").active, "focus loss cancels pending resume")
	for modal_key in [KEY_O, KEY_H]:
		_key(stage, KEY_P)
		_key(stage, modal_key)
		_check(stage.get("_paused") and not stage.get("_resume").active and stage.get_node("BattleOverlay").mode == ("options" if modal_key == KEY_O else "guide"), "modal cancels count-in and retains pause")
		_key(stage, KEY_ESCAPE)
		_check(stage.get("_paused") and stage.get_node("BattleOverlay").mode == "pause", "closing modal never auto-resumes")
	_key(stage, KEY_P)
	_key(stage, KEY_R)
	_check(not stage.get("_paused") and not stage.get("_resume").active and stage.get("_song_time_ms") == -2000, "restart clears pending resume")
	stage.call("_toggle_pause")
	_key(stage, KEY_P)
	stage.call("_show_title")
	_check(not stage.get("_resume").active and stage.get_node("BattleOverlay").mode == "title", "returning to title clears pending resume")
	stage.call("_start_run")
	stage.call("_finish_battle", "RITUAL EXPIRED", false)
	stage.call("_handle_focus_lost")
	_check(not stage.get("_paused") and stage.get_node("BattleOverlay").mode == "result", "focus loss on result is a no-op")
	for player in stage.get("_sfx_players").values():
		player.stop()
	for player in stage.get("_music_players").values():
		player.stop()
	stage.queue_free()
	await create_timer(0.5).timeout
	for path in [SETTINGS, RECORDS]:
		DirAccess.remove_absolute(path)
	if failures.is_empty():
		print("PASS: prism_flow (stance, warnings, health, practice, focus, resume, cancellation)")
		quit(0)
	else:
		for failure in failures:
			printerr("FAIL: prism_flow: " + failure)
		quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
