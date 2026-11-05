extends SceneTree


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	root.size = Vector2i(1280, 720)
	var screen = load("res://scenes/settings/calibration.tscn").instantiate()
	root.add_child(screen)
	await create_timer(1.7).timeout
	var image := root.get_texture().get_image()
	if image == null:
		printerr("Unable to read rendered calibration frame.")
		quit(1)
		return
	var error := image.save_png("res://build/calibration-preview.png")
	if error == OK:
		print("Saved calibration preview.")
		quit(0)
	else:
		printerr("Unable to save calibration preview: %s" % error_string(error))
		quit(1)

