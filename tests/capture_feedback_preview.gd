extends SceneTree


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	root.size = Vector2i(1280, 720)
	var stage = load("res://scenes/prototype/prototype_stage.tscn").instantiate()
	root.add_child(stage)
	await create_timer(3.1).timeout
	if not _save_view("res://build/single-focus-preview.png"):
		quit(1)
		return

	stage.set_process(false)
	stage.set("_song_time_ms", 12050)
	stage.set("_current_section_id", "ensemble")
	stage.set("_section_transition_until", 0)
	for chart_event in stage.get("_events"):
		if chart_event.time_ms < 12000:
			chart_event.consumed = true
	stage.queue_redraw()
	await process_frame
	await process_frame
	if not _save_view("res://build/ensemble-focus-preview.png"):
		quit(1)
		return

	stage.set("_finished", true)
	stage.set("_song_time_ms", 16000)
	stage.set("_score", 2180)
	stage.set("_perfect_count", 16)
	stage.set("_good_count", 3)
	stage.set("_miss_count", 1)
	stage.set("_bad_tap_count", 1)
	stage.queue_redraw()
	await process_frame
	await process_frame
	if not _save_view("res://build/result-card-preview.png"):
		quit(1)
		return
	print("Saved gameplay feedback previews.")
	quit(0)


func _save_view(path: String) -> bool:
	var image := root.get_texture().get_image()
	var error := image.save_png(path)
	if error != OK:
		printerr("Unable to save preview: %s" % error_string(error))
		return false
	return true
