extends SceneTree


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	root.size = Vector2i(1280, 720)
	var stage = load("res://scenes/beatspell/beatspell_battle.tscn").instantiate()
	root.add_child(stage)
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
	stage.set("_recent_command", mend.events)
	stage.set("_recent_command_until", Time.get_ticks_msec() + 900)
	stage.queue_redraw()
	await process_frame
	await process_frame
	if not _save_view("res://build/beatspell-battle-preview.png"):
		quit(1)
		return

	stage.set("_song_time_ms", 17_000)
	stage.set("_bar_index", 8)
	stage.set("_active_phase", 2)
	stage.get("_battle").boss_hp = 20
	stage.set("_last_skill", "")
	stage.set("_skill_flash_until", 0)
	command.reset()
	command.register_step(16_090, 500.0)
	var flare: Dictionary = command.finish(16_410, 500.0)
	stage.set("_recent_command", flare.events)
	stage.set("_recent_command_until", Time.get_ticks_msec() + 900)
	stage.queue_redraw()
	await process_frame
	await process_frame
	if not _save_view("res://build/beatspell-warning-preview.png"):
		quit(1)
		return

	stage.set("_finished", true)
	stage.set("_result_text", "BEAST DISPELLED")
	stage.set("_feedback_color", Color("69f0a5"))
	stage.get("_battle").boss_hp = 0
	stage.set("_active_phase", 3)
	stage.queue_redraw()
	await process_frame
	await process_frame
	if not _save_view("res://build/beatspell-result-preview.png"):
		quit(1)
		return
	stage.queue_free()
	await process_frame
	print("Saved beatspell previews.")
	quit(0)


func _save_view(path: String) -> bool:
	var image := root.get_texture().get_image()
	var error := image.save_png(path)
	if error != OK:
		printerr("Unable to save preview: %s" % error_string(error))
		return false
	return true
