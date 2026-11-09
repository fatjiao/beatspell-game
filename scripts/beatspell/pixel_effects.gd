extends RefCounted

const FLAMES := [
	[".......o....", "....ooyyo...", "..ooyWWyyo..", "oyyWWWWWyyo.", "..ooyWWyyo..", "....ooyyo...", ".......o...."],
	["....o.......", "..ooyyooo...", ".oyyWWyyyo..", "yyWWWWWWyyo.", ".oyyWWyyyo..", "..ooyyooo...", "....o......."],
	["......oo....", "...oooyyo...", ".ooyyyWWyo..", "yyWWWWWWyyo.", ".ooyyyWWyo..", "...oooyyo...", "......oo...."],
]
const ORB := ["..ttt..", ".tTTTt.", "tTWWWTt", "tTWWWTt", "tTTTTTt", ".tTTTt.", "..ttt.."]
const BARRIER := [
	".....WWW.....", "...WWtttWW...", "..Wtt...ttW..", ".Wt.......tW.",
	"Wt....T....tW", "Wt...TTT...tW", "Wt..TTWTT..tW", "Wt...TTT...tW",
	".Wt...T...tW.", "..Wt.....tW..", "...WtttttW...", "....WWtWW....", "......W......",
]
const PALETTE := {"o": Color("b84e35"), "y": Color("ffbc57"), "W": Color("fff2c2"), "t": Color("238b86"), "T": Color("67e4bc")}


static func sprite(canvas: CanvasItem, center: Vector2, rows: Array, scale: int = 1) -> void:
	var origin := center.round() - Vector2(int(rows[0].length() / 2), int(rows.size() / 2)) * scale
	for row in rows.size():
		var line: String = rows[row]
		for column in line.length():
			var symbol := line[column]
			if PALETTE.has(symbol):
				canvas.draw_rect(Rect2(origin + Vector2(column, row) * scale, Vector2.ONE * scale), PALETTE[symbol])


static func fireball(canvas: CanvasItem, center: Vector2, tick: int, empowered: bool = false) -> void:
	var rows: Array = FLAMES[posmod(tick, FLAMES.size())]
	sprite(canvas, center, rows, 2 if empowered else 1)


static func burst(canvas: CanvasItem, center: Vector2, progress: float, color: Color, count: int = 12) -> void:
	for index in count:
		var angle := float(index) * TAU / count
		var point := center + Vector2(cos(angle), sin(angle)) * (4 + progress * 22)
		var fade := Color(color, 1.0 - progress)
		var extent := 3 if index % 3 == 0 else 2
		canvas.draw_rect(Rect2(point.round(), Vector2.ONE * extent), fade)
		if progress < 0.40:
			canvas.draw_line((center - Vector2(6, 0)).round(), (center + Vector2(6, 0)).round(), color, 1)
			canvas.draw_line((center - Vector2(0, 6)).round(), (center + Vector2(0, 6)).round(), color, 1)


static func heal_cross(canvas: CanvasItem, center: Vector2, alpha: float) -> void:
	var color := Color("9cdb8d")
	color.a = alpha
	canvas.draw_rect(Rect2(center.round() - Vector2(2, 0), Vector2(5, 1)), color)
	canvas.draw_rect(Rect2(center.round() - Vector2(0, 2), Vector2(1, 5)), color)
