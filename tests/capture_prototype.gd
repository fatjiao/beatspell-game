extends SceneTree


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	root.size = Vector2i(1280, 720)
	var stage = load("res://scenes/prototype/prototype_stage.tscn").instantiate()
	root.add_child(stage)
	await create_timer(1.4).timeout
	var image := root.get_texture().get_image()
	var error := image.save_png("res://build/prototype-preview.png")
	if error == OK:
		print("Saved prototype preview.")
		quit(0)
	else:
		printerr("Unable to save prototype preview: %s" % error_string(error))
		quit(1)

