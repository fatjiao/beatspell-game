extends RefCounted

const INK := Color("091317")
const GOLD := Color("b9a474")
const IVORY := Color("e9e1ca")
const MUTED := Color("8b9f9c")
const TEAL := Color("75c7bb")
const EMBER := Color("e79c73")

const SMALL_GLYPHS := {
	"A": [2,5,7,5,5], "B": [6,5,6,5,6], "C": [3,4,4,4,3],
	"D": [6,5,5,5,6], "E": [7,4,6,4,7], "F": [7,4,6,4,4],
	"G": [3,4,5,5,3], "H": [5,5,7,5,5], "I": [7,2,2,2,7],
	"J": [1,1,1,5,2], "K": [5,5,6,5,5], "L": [4,4,4,4,7],
	"M": [5,7,7,5,5], "N": [5,7,7,7,5], "O": [2,5,5,5,2],
	"P": [6,5,6,4,4], "Q": [2,5,5,7,3], "R": [6,5,6,5,5],
	"S": [3,4,2,1,6], "T": [7,2,2,2,2], "U": [5,5,5,5,7],
	"V": [5,5,5,5,2], "W": [5,5,7,7,5], "X": [5,5,2,5,5],
	"Y": [5,5,2,2,2], "Z": [7,1,2,4,7],
	"0": [7,5,5,5,7], "1": [2,6,2,2,7], "2": [6,1,2,4,7],
	"3": [6,1,2,1,6], "4": [5,5,7,1,1], "5": [7,4,6,1,6],
	"6": [3,4,6,5,2], "7": [7,1,2,2,2], "8": [2,5,2,5,2],
	"9": [2,5,3,1,6], "/": [1,1,2,4,4], ".": [0,0,0,0,2],
	":": [0,2,0,2,0], "-": [0,0,7,0,0], "+": [0,2,7,2,0],
	"!": [2,2,2,0,2], " ": [0,0,0,0,0],
}


static func pixel_text(canvas: CanvasItem, baseline: Vector2, text: String, alignment: int = 0, width: float = -1, font_size: int = 6, color: Color = IVORY) -> void:
	var scale := maxi(1, int(font_size / 6.0))
	var label := text.to_upper().replace("·", ".")
	var text_width := (label.length() * 4 - 1) * scale
	var x := baseline.x
	if width > 0:
		if alignment == HORIZONTAL_ALIGNMENT_CENTER:
			x += (width - text_width) / 2.0
		elif alignment == HORIZONTAL_ALIGNMENT_RIGHT:
			x += width - text_width
	var origin := Vector2(roundf(x), roundf(baseline.y) - 5 * scale)
	for index in label.length():
		var rows: Array = SMALL_GLYPHS.get(label[index], SMALL_GLYPHS[" "])
		for row in 5:
			for column in 3:
				if (int(rows[row]) & (1 << (2 - column))) != 0:
					canvas.draw_rect(Rect2(origin + Vector2((index * 4 + column) * scale, row * scale), Vector2.ONE * scale), color)


static func panel(canvas: CanvasItem, rect: Rect2, accent: Color = GOLD, active: bool = false) -> void:
	canvas.draw_rect(rect, Color(0.025, 0.055, 0.065, 0.94))
	canvas.draw_rect(rect, Color(accent, 0.72 if active else 0.30), false, 1.0)
	canvas.draw_line(rect.position + Vector2(5, 2), rect.position + Vector2(rect.size.x - 5, 2), Color(accent, 0.18), 1.0)
	for corner in [rect.position, rect.position + Vector2(rect.size.x, 0), rect.end, rect.position + Vector2(0, rect.size.y)]:
		canvas.draw_rect(Rect2(corner - Vector2.ONE, Vector2(2, 2)), accent)
	if active:
		canvas.draw_line(rect.position + Vector2(4, rect.size.y), rect.end - Vector2(4, 0), accent, 1.0)


static func sigil(canvas: CanvasItem, center: Vector2, skill: String, radius: float, color: Color) -> void:
	canvas.draw_arc(center, radius, 0, TAU, 32, Color(color, 0.40), 0.5)
	match skill:
		"fireball":
			canvas.draw_colored_polygon(PackedVector2Array([center + Vector2(0, -radius * 0.8), center + Vector2(radius * 0.5, radius * 0.5), center + Vector2(0, radius * 0.8), center + Vector2(-radius * 0.45, radius * 0.25)]), color)
			canvas.draw_line(center + Vector2(0, -radius * 0.15), center + Vector2(0, radius * 0.5), INK, 1.0)
		"shield":
			canvas.draw_polyline(PackedVector2Array([center + Vector2(-radius * 0.6, -radius * 0.5), center + Vector2(radius * 0.6, -radius * 0.5), center + Vector2(radius * 0.5, radius * 0.25), center + Vector2(0, radius * 0.75), center + Vector2(-radius * 0.5, radius * 0.25), center + Vector2(-radius * 0.6, -radius * 0.5)]), color, 1.0, true)
		"heal":
			canvas.draw_line(center - Vector2(radius * 0.6, 0), center + Vector2(radius * 0.6, 0), color, 1.5)
			canvas.draw_line(center - Vector2(0, radius * 0.6), center + Vector2(0, radius * 0.6), color, 1.5)


static func pixel_wordmark(canvas: CanvasItem, origin: Vector2, pixel_size: int, color: Color) -> void:
	var glyphs := {
		"B": [30, 17, 17, 30, 17, 17, 30],
		"E": [31, 16, 16, 30, 16, 16, 31],
		"A": [14, 17, 17, 31, 17, 17, 17],
		"T": [31, 4, 4, 4, 4, 4, 4],
		"S": [15, 16, 16, 14, 1, 1, 30],
		"P": [30, 17, 17, 30, 16, 16, 16],
		"L": [16, 16, 16, 16, 16, 16, 31],
	}
	var word := "BEATSPELL"
	for index in word.length():
		var rows: Array = glyphs[word[index]]
		for row in 7:
			for column in 5:
				if (int(rows[row]) & (1 << (4 - column))) != 0:
					var position := origin + Vector2((index * 6 + column) * pixel_size, row * pixel_size)
					canvas.draw_rect(Rect2(position + Vector2(1, 1), Vector2.ONE * pixel_size), INK)
					canvas.draw_rect(Rect2(position, Vector2.ONE * pixel_size), color)
