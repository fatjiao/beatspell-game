extends RefCounted

const INK := Color("091317")
const GOLD := Color("b9a474")
const IVORY := Color("e9e1ca")
const MUTED := Color("8b9f9c")
const TEAL := Color("75c7bb")
const EMBER := Color("e79c73")


static func panel(canvas: CanvasItem, rect: Rect2, accent: Color = GOLD, active: bool = false) -> void:
	canvas.draw_rect(rect, Color(0.025, 0.055, 0.065, 0.94))
	canvas.draw_rect(rect.grow(-0.5), Color(accent, 0.72 if active else 0.30), false, 0.5)
	canvas.draw_line(rect.position + Vector2(5, 2), rect.position + Vector2(rect.size.x - 5, 2), Color(accent, 0.18), 0.5)
	for corner in [rect.position, rect.position + Vector2(rect.size.x, 0), rect.end, rect.position + Vector2(0, rect.size.y)]:
		canvas.draw_circle(corner, 0.8, accent)
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
