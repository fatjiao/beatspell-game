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
	stage.set("_phrase_inputs", [
		{"slot": 0, "action": "charge", "grade": "perfect", "offset_ms": 8},
		{"slot": 1, "action": "cast", "grade": "perfect", "offset_ms": -11},
	])
	stage.queue_redraw()
	await process_frame
	await process_frame
	if not _save_view("res://build/beatspell-battle-preview.png"):
		quit(1)
		return

	stage.set("_song_time_ms", 6500)
	stage.set("_bar_index", 3)
	stage.set("_phrase_inputs", [
		{"slot": 0, "action": "charge", "grade": "perfect", "offset_ms": 4},
		{"slot": 1, "action": "charge", "grade": "perfect", "offset_ms": 19},
	])
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
