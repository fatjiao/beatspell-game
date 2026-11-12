extends SceneTree

const Lang = preload("res://scripts/beatspell/localization.gd")
const Records = preload("res://scripts/beatspell/run_records.gd")
var _language := "en"


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	root.size = Vector2i(1280, 720)
	var stage = load("res://scenes/beatspell/beatspell_battle.tscn").instantiate()
	stage.set("_settings_path", "res://build/beatspell-preview-settings.json")
	stage.set("_records_path", "res://build/beatspell-preview-records.json")
	root.add_child(stage)
	_language = "zh_CN" if "zh_CN" in OS.get_cmdline_user_args() else "en"
	stage.get("_options").language = _language
	stage.call("_apply_options")
	stage.set("_encounter", "ritual")
	stage.get_node("BattleOverlay").selected_encounter = "ritual"
	await process_frame
	await process_frame
	if not _save_view("res://build/beatspell-title-preview.png"):
		quit(1)
		return
	stage.call("_start_run")
	await create_timer(2.4).timeout
	stage.set_process(false)
	stage.set("_song_time_ms", 1550)
	stage.set("_bar_index", 3)
	stage.set("_last_skill", "heal")
	stage.set("_skill_flash_until", Time.get_ticks_msec() + 420)
	var command = stage.get("_command")
	command.reset()
	command.register_step(590, 500.0)
	command.register_step(910, 500.0)
	var mend: Dictionary = command.finish(1590, 500.0)
	var missed_step: Dictionary = command.register_step(1750, 500.0)
	var preview_events: Array = mend.events.duplicate(true)
	preview_events.append(missed_step.event)
	command.reset()
	stage.set("_recent_command", preview_events)
	stage.queue_redraw()
	await process_frame
	await process_frame
	if not _save_view("res://build/beatspell-battle-preview.png"):
		quit(1)
		return
	stage.set("_song_time_ms", 2575)
	stage.queue_redraw()
	await process_frame
	await process_frame
	if not _save_view("res://build/beatspell-trace-fade-preview.png"):
		quit(1)
		return

	stage.set("_song_time_ms", 17_000)
	stage.set("_bar_index", 8)
	stage.set("_active_phase", 2)
	stage.get("_battle").boss_hp = 20
	stage.get("_battle").shield_active = true
	stage.set("_last_skill", "shield")
	stage.set("_skill_flash_until", Time.get_ticks_msec() + 420)
	command.reset()
	command.register_step(16_090, 500.0)
	var aegis: Dictionary = command.finish(17_000, 500.0)
	stage.set("_recent_command", aegis.events)
	stage.queue_redraw()
	await process_frame
	await process_frame
	if not _save_view("res://build/beatspell-warning-preview.png"):
		quit(1)
		return

	stage.set("_song_time_ms", 29_750)
	stage.set("_bar_index", 14)
	stage.set("_active_phase", 2)
	stage.get("_battle").shield_active = false
	stage.queue_redraw()
	await process_frame
	await process_frame
	if not _save_view("res://build/beatspell-syncopated-warning-preview.png"):
		quit(1)
		return

	stage.set("_song_time_ms", 23_750)
	stage.set("_bar_index", 11)
	stage.set("_active_phase", 3)
	stage.queue_redraw()
	await process_frame
	await process_frame
	if not _save_view("res://build/beatspell-rush-warning-preview.png"):
		quit(1)
		return

	stage.get_node("BattleOverlay").flash_phase(3, "OVERDRIVE", Color("ff4f70"), 2000)
	stage.queue_redraw()
	await create_timer(0.35).timeout
	await process_frame
	if not _save_view("res://build/beatspell-phase-preview.png"):
		quit(1)
		return

	stage.set("_paused", true)
	stage.get_node("BattleOverlay").show_pause()
	stage.queue_redraw()
	await process_frame
	await process_frame
	if not _save_view("res://build/beatspell-pause-preview.png"):
		quit(1)
		return
	stage.set("_paused", false)
	stage.get_node("BattleOverlay").hide_primary()

	stage.set("_finished", true)
	stage.set("_result_text", "BEAST DISPELLED")
	stage.set("_feedback_color", Color("69f0a5"))
	stage.get("_battle").boss_hp = 0
	stage.set("_active_phase", 3)
	var performance = stage.get("_performance")
	performance.reset()
	performance.record_input({"grade": "perfect", "offset_ms": -18})
	performance.record_input({"grade": "perfect", "offset_ms": 24})
	performance.record_input({"grade": "good", "offset_ms": 71})
	performance.record_input({"grade": "miss", "offset_ms": 158})
	performance.record_attempt("fireball", "perfect")
	performance.record_attempt("heal", "good")
	performance.record_attempt("", "miss")
	# Include one expired command as an additional failed attempt.
	performance.record_attempt("", "miss")
	stage.get_node("BattleOverlay").show_result(stage.call("_result_overlay_data"))
	stage.queue_redraw()
	await process_frame
	await process_frame
	if not _save_view("res://build/beatspell-result-preview.png"):
		quit(1)
		return

	stage.set("_result_text", "RITUAL BROKEN")
	stage.set("_feedback_color", Color("ff668e"))
	stage.get("_battle").player_hp = 0
	stage.get("_battle").boss_hp = 17
	stage.get_node("BattleOverlay").show_result(stage.call("_result_overlay_data"))
	stage.queue_redraw()
	await process_frame
	await process_frame
	if not _save_view("res://build/beatspell-defeat-preview.png"):
		quit(1)
		return
	stage.call("_start_run", true)
	stage.set("_song_time_ms", 2000)
	stage.set("_bar_index", 1)
	stage.get_node("BattleOverlay").hide_primary()
	stage.call("_cast_skill", "fireball", "perfect")
	stage.queue_redraw()
	await create_timer(0.12).timeout
	await process_frame
	if not _save_view("res://build/beatspell-practice-preview.png"):
		quit(1)
		return
	stage.call("_open_options")
	await process_frame
	await process_frame
	if not _save_view("res://build/beatspell-options-preview.png"):
		quit(1)
		return
	stage.call("_handle_options_input", KEY_ESCAPE)
	stage.set("_paused", false)
	stage.set("_practice_defense", true)
	stage.get_node("BattleOverlay").hide_primary()
	for bar in [1, 3]:
		stage.set("_bar_index", bar)
		stage.set("_song_time_ms", (bar + 1) * 2000 - 500)
		stage.call("_cast_skill", "shield", "perfect")
		stage.call("_resolve_bar", bar)
	stage.queue_redraw()
	await create_timer(0.15).timeout
	await process_frame
	if not _save_view("res://build/beatspell-break-preview.png"):
		quit(1)
		return
	stage.get_node("BattleOverlay").show_guide()
	await process_frame
	await process_frame
	if not _save_view("res://build/beatspell-spellbook-preview.png"):
		quit(1)
		return
	stage.call("_start_run", true)
	stage.set("_song_time_ms", 2000)
	stage.set("_bar_index", 1)
	stage.get_node("BattleOverlay").hide_primary()
	stage.set("_last_action", "charge")
	stage.set("_action_flash_until", Time.get_ticks_msec() + 150)
	stage.queue_redraw()
	await process_frame
	await process_frame
	if not _save_view("res://build/beatspell-charge-preview.png"):
		quit(1)
		return
	stage.get("_practice").step = 3
	stage.set("_practice_defense", true)
	var drill = stage.get("_drill")
	for index in 5:
		if index > 0:
			drill.request_selection(1)
			drill.commit_selection()
		stage.call("_clear_visual_effects")
		stage.set("_feedback_until", 0)
		stage.set("_song_time_ms", 3750)
		stage.set("_bar_index", 1)
		stage.get("_battle").shield_active = false
		stage.queue_redraw()
		await process_frame
		await process_frame
		if not _save_view("res://build/beatspell-drill-%s-preview.png" % drill.pattern()):
			quit(1)
			return
		for repetition in (2 if index == 2 else 3):
			stage.set("_song_time_ms", 3500)
			if index == 2 and repetition == 0:
				stage.get("_battle").shield_active = false
			else:
				stage.call("_cast_skill", "shield", "good" if index == 1 and repetition == 0 else "perfect")
			stage.call("_resolve_boss_attack", 4000)
	var report_key := InputEventKey.new()
	report_key.physical_keycode = KEY_TAB
	report_key.pressed = true
	stage.call("_unhandled_input", report_key)
	stage.queue_redraw()
	await process_frame
	await process_frame
	if not _save_view("res://build/beatspell-drill-report-preview.png"):
		quit(1)
		return
	stage.call("_start_run")
	stage.get_node("BattleOverlay").hide_primary()
	stage.set("_practice_mode", false)
	stage.set("_song_time_ms", 24000)
	stage.set("_bar_index", 12)
	stage.set("_active_phase", 3)
	stage.call("_resolve_boss_attack", 24000)
	stage.queue_redraw()
	await create_timer(0.10).timeout
	await process_frame
	if not _save_view("res://build/beatspell-strike-preview.png"):
		quit(1)
		return
	for encounter in ["duel", "gauntlet", "prism"]:
		stage.set("_encounter", encounter)
		stage.call("_show_title")
		await process_frame
		await process_frame
		_save_view("res://build/beatspell-title-%s-preview.png" % encounter)
	stage.call("_start_run")
	stage.get_node("BattleOverlay").hide_primary()
	for state in [[1, 3250, "armor"], [3, 7750, "open"]]:
		stage.set("_bar_index", state[0])
		stage.set("_song_time_ms", state[1])
		stage.get("_battle").boss_hp = 62 if state[2] == "armor" else 48
		stage.call("_clear_visual_effects")
		stage.queue_redraw()
		await process_frame
		await process_frame
		_save_view("res://build/beatspell-prism-%s-preview.png" % state[2])
	stage.call("_toggle_pause")
	stage.call("_toggle_pause")
	stage.queue_redraw()
	await process_frame
	await process_frame
	_save_view("res://build/beatspell-resume-preview.png")
	stage.call("_start_run")
	stage.set("_records", Records.empty_records())
	stage.set("_song_time_ms", 40000)
	stage.set("_bar_index", 19)
	stage.set("_active_phase", 3)
	stage.get("_battle").boss_hp = 0
	stage.get("_battle").total_damage = 72
	stage.get("_battle").max_combo = 18
	stage.get("_performance").record_input({"grade": "perfect", "offset_ms": 15})
	stage.get("_performance").record_attempt("fireball", "perfect")
	stage.call("_finish_battle", "BEAST DISPELLED", true)
	await process_frame
	await process_frame
	_save_view("res://build/beatspell-record-result-preview.png")
	stage.get_node("BattleOverlay").show_records(stage.get("_records"), "prism")
	await process_frame
	await process_frame
	_save_view("res://build/beatspell-records-preview.png")
	stage.queue_free()
	await process_frame
	print("Saved beatspell previews.")
	quit(0)


func _save_view(path: String) -> bool:
	if _language == "zh_CN":
		path = path.replace("-preview.png", "-zh-preview.png")
	var image := root.get_texture().get_image()
	var error := image.save_png(path)
	if error != OK:
		printerr("Unable to save preview: %s" % error_string(error))
		return false
	return true
