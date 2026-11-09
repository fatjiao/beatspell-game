extends SceneTree

const Effects = preload("res://scripts/beatspell/pixel_effects.gd")
const Art = preload("res://scripts/beatspell/art_direction.gd")

class Gallery extends Control:
	func _draw() -> void:
		draw_rect(Rect2(0, 0, 320, 180), Color("091317"))
		Art.pixel_text(self, Vector2(20, 19), "BEATSPELL / PIXEL EFFECTS", HORIZONTAL_ALIGNMENT_CENTER, 280, 12, Art.IVORY)
		for index in 3:
			Art.panel(self, Rect2(20 + index * 98, 35, 84, 52), Art.GOLD)
			Effects.sprite(self, Vector2(62 + index * 98, 56), Effects.FLAMES[index], 2)
			Art.pixel_text(self, Vector2(24 + index * 98, 78), "FLARE %d" % (index + 1), HORIZONTAL_ALIGNMENT_CENTER, 76, 6, Art.GOLD)
		Art.panel(self, Rect2(20, 98, 84, 60), Art.TEAL)
		Effects.sprite(self, Vector2(62, 119), Effects.ORB, 2)
		Art.pixel_text(self, Vector2(24, 149), "CHARGE", HORIZONTAL_ALIGNMENT_CENTER, 76, 6, Art.TEAL)
		Art.panel(self, Rect2(118, 98, 84, 60), Art.TEAL)
		Effects.sprite(self, Vector2(160, 119), Effects.BARRIER, 2)
		Art.pixel_text(self, Vector2(122, 149), "AEGIS", HORIZONTAL_ALIGNMENT_CENTER, 76, 6, Art.TEAL)
		Art.panel(self, Rect2(216, 98, 84, 60), Art.EMBER)
		Effects.burst(self, Vector2(258, 121), 0.40, Art.EMBER)
		Art.pixel_text(self, Vector2(220, 149), "IMPACT", HORIZONTAL_ALIGNMENT_CENTER, 76, 6, Art.EMBER)


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var gallery := Gallery.new()
	root.add_child(gallery)
	await process_frame
	await process_frame
	var result := root.get_texture().get_image().save_png("res://build/beatspell-fx-preview.png")
	gallery.queue_free()
	await process_frame
	quit(0 if result == OK else 1)
