extends SceneTree

const ROOT := "res://assets/art/beatspell/pixel/"
const OUT := ROOT + "poses/"
var _failed := false


func _init() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	DirAccess.make_dir_recursive_absolute("res://build")
	var mage := Image.load_from_file(ProjectSettings.globalize_path(ROOT + "caster.png"))
	var boss := Image.load_from_file(ProjectSettings.globalize_path(ROOT + "warden.png"))
	if mage == null or boss == null:
		push_error("Missing source sprites; restore caster.png and warden.png before rebuilding poses.")
		quit(1)
		return
	mage.convert(Image.FORMAT_RGBA8)
	mage.resize(48, 64, Image.INTERPOLATE_NEAREST)
	boss.convert(Image.FORMAT_RGBA8)
	boss.resize(64, 64, Image.INTERPOLATE_NEAREST)
	_save(mage, "caster_idle")
	var charge := _mage_pose(mage, false)
	var cast := _mage_pose(mage, true)
	_save(charge, "caster_charge")
	_save(cast, "caster_cast")
	var boss_idle := _boss_pose(boss, 0.0)
	var boss_windup := _boss_pose(boss, -0.28)
	var boss_strike := _boss_pose(boss, 0.38)
	_save(boss_idle, "warden_idle")
	_save(boss_windup, "warden_windup")
	_save(boss_strike, "warden_strike")
	var sheet := Image.create(240, 144, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("10272d"))
	for index in 3:
		sheet.blend_rect([mage, charge, cast][index], Rect2i(0, 0, 48, 64), Vector2i(index * 80 + 16, 4))
		sheet.blend_rect([boss_idle, boss_windup, boss_strike][index], Rect2i(0, 0, 72, 72), Vector2i(index * 80 + 4, 72))
	sheet.resize(960, 576, Image.INTERPOLATE_NEAREST)
	sheet.save_png("res://build/beatspell-pose-sheet.png")
	var preview := mage.duplicate()
	preview.resize(384, 512, Image.INTERPOLATE_NEAREST)
	preview.save_png("res://build/caster-pixel-source.png")
	var boss_preview := boss.duplicate()
	boss_preview.resize(512, 512, Image.INTERPOLATE_NEAREST)
	boss_preview.save_png("res://build/warden-pixel-source.png")
	quit(1 if _failed else 0)


func _save(image: Image, name: String) -> void:
	var error := image.save_png(OUT + name + ".png")
	if error != OK:
		push_error("Unable to save pose: " + name)
		_failed = true


func _mage_pose(source: Image, release: bool) -> Image:
	var result := source.duplicate()
	# Remove only the leading arm and its existing orb. Rebuild the bent/extended
	# sleeve, forearm and hand on the original pixel grid, preserving feet and face.
	var arm := PackedVector2Array([Vector2(28, 25), Vector2(37, 23), Vector2(48, 17), Vector2(48, 35), Vector2(32, 36), Vector2(29, 31)])
	_polygon(result, arm, Color(0,0,0,0))
	result.fill_rect(Rect2i(37,15,11,12), Color(0,0,0,0))
	var outline := Color("092c30")
	var dark := Color("075654")
	var teal := Color("0a8d7b")
	var light := Color("5dd9b5")
	var skin := Color("f2cba5")
	var shade := Color("c39983")
	if release:
		_polygon(result, PackedVector2Array([Vector2(27,26),Vector2(33,25),Vector2(40,26),Vector2(42,30),Vector2(37,33),Vector2(30,32)]), outline)
		_polygon(result, PackedVector2Array([Vector2(29,27),Vector2(34,26),Vector2(39,27),Vector2(40,30),Vector2(36,32),Vector2(31,30)]), dark)
		result.fill_rect(Rect2i(32, 26, 6, 1), light)
		result.fill_rect(Rect2i(37, 27, 7, 3), shade)
		result.fill_rect(Rect2i(38, 27, 7, 2), skin)
		result.fill_rect(Rect2i(43, 26, 3, 4), skin)
		result.fill_rect(Rect2i(44, 25, 2, 2), skin)
		result.fill_rect(Rect2i(45, 27, 2, 1), Color("fff0c2"))
		# Cape tip blows backwards without resampling the rest of the silhouette.
		var cape := PackedVector2Array([Vector2(3,40),Vector2(9,35),Vector2(14,34),Vector2(11,42),Vector2(7,48),Vector2(3,49)])
		_move_part(source, result, cape, Vector2(9,41), 0.0, Vector2(-2,-2))
		_pixel_orb(result, Vector2i(43, 24), true)
	else:
		_polygon(result, PackedVector2Array([Vector2(27,26),Vector2(32,25),Vector2(39,30),Vector2(39,35),Vector2(34,37),Vector2(29,32)]), outline)
		_polygon(result, PackedVector2Array([Vector2(28,27),Vector2(32,27),Vector2(37,31),Vector2(37,35),Vector2(34,35),Vector2(30,31)]), dark)
		result.fill_rect(Rect2i(32, 28, 2, 3), teal)
		_polygon(result, PackedVector2Array([Vector2(34,32),Vector2(30,29),Vector2(28,27),Vector2(26,29),Vector2(29,33),Vector2(34,35)]), shade)
		result.fill_rect(Rect2i(28, 28, 3, 2), skin)
		result.fill_rect(Rect2i(27, 26, 3, 3), skin)
		result.fill_rect(Rect2i(31, 33, 4, 1), light)
		_pixel_orb(result, Vector2i(29, 23), false)
	return result


func _pixel_orb(image: Image, center: Vector2i, amber: bool) -> void:
	var colors := [Color("a44c2a"), Color("ffc65e"), Color("fff3b8")] if amber else [Color("126c68"), Color("4ddbb6"), Color("cbffe2")]
	for y in range(-3, 4):
		for x in range(-3, 4):
			var distance := absi(x) + absi(y)
			var point := center + Vector2i(x, y)
			if distance <= 3 and Rect2i(0,0,image.get_width(),image.get_height()).has_point(point):
				image.set_pixelv(point, colors[2 if distance <= 1 else 1 if distance <= 2 else 0])


func _boss_pose(source: Image, angle: float) -> Image:
	var result := Image.create(72, 72, false, Image.FORMAT_RGBA8)
	result.fill(Color(0,0,0,0))
	var padded := result.duplicate()
	padded.blit_rect(source, Rect2i(0,0,64,64), Vector2i(4,4))
	result.blit_rect(padded, Rect2i(0,0,72,72), Vector2i.ZERO)
	if not is_zero_approx(angle):
		var arm := PackedVector2Array([Vector2(4,30),Vector2(11,23),Vector2(21,23),Vector2(30,27),Vector2(28,35),Vector2(20,39),Vector2(12,47),Vector2(4,44)])
		_move_part(padded, result, arm, Vector2(27,30), angle, Vector2(-1,0) if angle > 0 else Vector2(1,0))
		# The bright core eye gives a readable release accent at battle scale.
		if angle > 0:
			result.fill_rect(Rect2i(26,19,2,2), Color("fff0b2"))
	return result


func _polygon(image: Image, points: PackedVector2Array, color: Color) -> void:
	for y in image.get_height():
		for x in image.get_width():
			if Geometry2D.is_point_in_polygon(Vector2(x+0.5,y+0.5), points):
				image.set_pixel(x,y,color)


func _move_part(source: Image, target: Image, polygon: PackedVector2Array, pivot: Vector2, angle: float, offset: Vector2) -> void:
	_polygon(target, polygon, Color(0,0,0,0))
	# Inverse mapping avoids holes and retains hard one-pixel edges.
	for y in target.get_height():
		for x in target.get_width():
			var from := (Vector2(x,y) - pivot - offset).rotated(-angle) + pivot
			var point := Vector2i(from.round())
			if not Rect2i(0,0,source.get_width(),source.get_height()).has_point(point):
				continue
			if Geometry2D.is_point_in_polygon(Vector2(point) + Vector2(0.5,0.5), polygon):
				var color := source.get_pixelv(point)
				if color.a > 0.0:
					target.set_pixel(x,y,color)
