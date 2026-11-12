extends SceneTree

const Lang = preload("res://scripts/beatspell/localization.gd")


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	root.size = Vector2i(1280, 720)
	var screen = load("res://scenes/settings/calibration.tscn").instantiate()
	root.add_child(screen)
	var language := "zh_CN" if "zh_CN" in OS.get_cmdline_user_args() else "en"
	Lang.set_language(language)
	await create_timer(1.7).timeout
	var image := root.get_texture().get_image()
	if image == null:
		printerr("Unable to read rendered calibration frame.")
		quit(1)
		return
	var suffix := "-zh" if language == "zh_CN" else ""
	var error := image.save_png("res://build/calibration%s-preview.png" % suffix)
	screen.set("_finished", true)
	screen.set("_result_ms", -25)
	screen.queue_redraw()
	await process_frame
	await process_frame
	if error == OK:
		error = root.get_texture().get_image().save_png("res://build/calibration-result%s-preview.png" % suffix)
	if error == OK:
		print("Saved calibration preview.")
		quit(0)
	else:
		printerr("Unable to save calibration preview: %s" % error_string(error))
		quit(1)

