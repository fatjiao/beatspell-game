extends SceneTree


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	root.size = Vector2i(1280, 720)
	var stage = load("res://scenes/beatspell/beatspell_battle.tscn").instantiate()
	root.add_child(stage)
	await create_timer(2.4).timeout
	stage.set_process(false)
	stage.set("_song_time_ms", 1050)
	stage.set("_bar_index", 0)
	stage.set("_last_skill", "fireball")
	stage.set("_skill_flash_until", Time.get_ticks_msec() + 420)
	var phrase = stage.get("_phrase")
	phrase.reset()
	phrase.register_input(510, "charge", 500.0)
	phrase.register_input(990, "cast", 500.0)
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
	phrase.reset()
	phrase.register_input(16_000, "charge", 500.0)
	phrase.register_input(16_500, "charge", 500.0)
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
