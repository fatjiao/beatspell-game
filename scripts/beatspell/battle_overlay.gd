extends Control

var mode := ""
var count_value := 4
var phase_number := 0
var phase_name := ""
var phase_color := Color("8d7dff")
var result_data: Dictionary = {}

var _phase_started_ticks := 0
var _phase_until_ticks := 0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)


func _process(_delta: float) -> void:
	if _phase_until_ticks > Time.get_ticks_msec():
		queue_redraw()
	elif _phase_until_ticks != 0:
		_phase_until_ticks = 0
		queue_redraw()
	elif mode == "title":
		queue_redraw()


func show_title() -> void:
	mode = "title"
	_request_redraw()


func show_count_in(value: int) -> void:
	mode = "count_in"
	count_value = clampi(value, 1, 4)
	_request_redraw()


func show_pause() -> void:
	mode = "pause"
	_request_redraw()


func show_result(data: Dictionary) -> void:
	mode = "result"
	result_data = data.duplicate(true)
	_request_redraw()


func hide_primary() -> void:
	if mode.is_empty():
		return
	mode = ""
	_request_redraw()


func flash_phase(number: int, label: String, color: Color, duration_ms: int = 900) -> void:
	phase_number = number
	phase_name = label
	phase_color = color
	_phase_started_ticks = Time.get_ticks_msec()
	_phase_until_ticks = _phase_started_ticks + maxi(duration_ms, 1)
	_request_redraw()


func _request_redraw() -> void:
	if is_inside_tree():
		queue_redraw()


func _draw() -> void:
	match mode:
		"title":
			_draw_title()
		"count_in":
			_draw_count_in()
		"pause":
			_draw_pause()
		"result":
			_draw_result()
	if _phase_until_ticks > Time.get_ticks_msec() and mode.is_empty():
		_draw_phase_flash()


func _draw_title() -> void:
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.018, 0.012, 0.055, 1.0))
	var pulse := 0.5 + sin(float(Time.get_ticks_msec()) / 420.0) * 0.5
	for ring_index in 5:
		var radius := 28.0 + float(ring_index) * 17.0
		var color := Color("8d7dff") if ring_index % 2 == 0 else Color("ff5fba")
		color.a = 0.035 + pulse * 0.018
		draw_arc(Vector2(160, 73), radius, 0, TAU, 48, color, 1.0)
	draw_string(font, Vector2(42, 52), "BEATSPELL", HORIZONTAL_ALIGNMENT_CENTER, 236, 28, Color("f1efff"))
	draw_string(font, Vector2(72, 70), "RHYTHM SPELL BOSS BATTLE", HORIZONTAL_ALIGNMENT_CENTER, 176, 7, Color("aaa6cc"))
	var colors := [Color("ff6b5e"), Color("45e6ff"), Color("69f0a5")]
	var patterns := [[0, 1], [0, 2], [0, 1, 2]]
	for pattern_index in 3:
		var origin := Vector2(88 + pattern_index * 72, 92)
		var pattern: Array = patterns[pattern_index]
		draw_line(origin, origin + Vector2(float(pattern[-1]) * 12.0, 0), Color("514a72"), 1.0)
		for point_index in pattern.size():
			var point := origin + Vector2(float(pattern[point_index]) * 12.0, 0)
			if point_index == pattern.size() - 1:
				var diamond := PackedVector2Array([point + Vector2(0, -4), point + Vector2(4, 0), point + Vector2(0, 4), point + Vector2(-4, 0)])
				draw_colored_polygon(diamond, Color("45e6ff"))
			else:
				draw_circle(point, 3.0, Color("ffc45e"))
		draw_string(font, origin + Vector2(-18, 18), ["FLARE", "AEGIS", "MEND"][pattern_index], HORIZONTAL_ALIGNMENT_CENTER, 60, 6, colors[pattern_index])
	draw_rect(Rect2(104, 122, 112, 25), Color(0.12, 0.08, 0.23, 0.86))
	draw_rect(Rect2(104, 122, 112, 25), Color("8d7dff"), false, 1.0)
	draw_string(font, Vector2(116, 139), "J/K  BEGIN", HORIZONTAL_ALIGNMENT_CENTER, 88, 9, Color("ffffff"))
	draw_string(font, Vector2(65, 160), "ENTER / SPACE", HORIZONTAL_ALIGNMENT_CENTER, 90, 6, Color("777394"))
	draw_string(font, Vector2(168, 160), "C CALIBRATE   ESC QUIT", HORIZONTAL_ALIGNMENT_CENTER, 116, 6, Color("777394"))


func _draw_count_in() -> void:
	var font := ThemeDB.fallback_font
	draw_circle(Vector2(160, 82), 30.0, Color(0.03, 0.02, 0.08, 0.94))
	draw_arc(Vector2(160, 82), 30.0, 0, TAU, 36, Color("8d7dff"), 2.0)
	draw_string(font, Vector2(143, 93), str(count_value), HORIZONTAL_ALIGNMENT_CENTER, 34, 28, Color("ffffff"))


func _draw_pause() -> void:
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.01, 0.008, 0.03, 0.78))
	draw_rect(Rect2(0, 24, 320, 100), Color(0.02, 0.01, 0.06, 0.88))
	draw_string(font, Vector2(100, 68), "PAUSED", HORIZONTAL_ALIGNMENT_CENTER, 120, 18, Color("ffffff"))
	draw_string(font, Vector2(100, 88), "P  RESUME", HORIZONTAL_ALIGNMENT_CENTER, 120, 7, Color("dad7ff"))
	draw_string(font, Vector2(100, 103), "ESC  TITLE", HORIZONTAL_ALIGNMENT_CENTER, 120, 6, Color("777394"))


func _draw_result() -> void:
	var font := ThemeDB.fallback_font
	var color: Color = result_data.get("color", Color("69f0a5"))
	var panel := Rect2(32, 31, 256, 96)
	draw_rect(panel, Color(0.025, 0.02, 0.075, 0.97))
	draw_rect(panel, color, false, 1.0)
	draw_string(font, Vector2(48, 53), String(result_data.get("title", "RUN COMPLETE")), HORIZONTAL_ALIGNMENT_CENTER, 224, 14, color)
	draw_string(font, Vector2(48, 72), "CAST %02d/%02d   P%02d G%02d X%02d" % [
		int(result_data.get("successful_casts", 0)), int(result_data.get("attempts", 0)),
		int(result_data.get("perfect_casts", 0)), int(result_data.get("good_casts", 0)),
		int(result_data.get("failed_casts", 0)),
	], HORIZONTAL_ALIGNMENT_CENTER, 224, 7, Color("dad7ff"))
	draw_string(font, Vector2(48, 89), "INPUT %02d   AVG %03dMS  %s" % [
		int(result_data.get("inputs", 0)), int(result_data.get("average_offset_ms", 0)),
		String(result_data.get("timing_bias", "ON TIME")),
	], HORIZONTAL_ALIGNMENT_CENTER, 224, 7, Color("aaa6cc"))
	draw_string(font, Vector2(48, 105), "RANK %s   BOSS %02d/%02d" % [
		String(result_data.get("rank", "C")), int(result_data.get("boss_hp", 0)),
		int(result_data.get("boss_max_hp", 36)),
	], HORIZONTAL_ALIGNMENT_CENTER, 224, 7, Color("8d7dff"))
	draw_string(font, Vector2(48, 121), "R  AGAIN   ESC  TITLE", HORIZONTAL_ALIGNMENT_CENTER, 224, 7, Color("ffc45e"))


func _draw_phase_flash() -> void:
	var font := ThemeDB.fallback_font
	var total := maxf(1.0, float(_phase_until_ticks - _phase_started_ticks))
	var remaining := clampf(float(_phase_until_ticks - Time.get_ticks_msec()) / total, 0.0, 1.0)
	var alpha := sin((1.0 - remaining) * PI)
	var band_color := phase_color
	band_color.a = alpha * 0.18
	draw_rect(Rect2(0, 52, 320, 47), band_color)
	var text_color := phase_color
	text_color.a = alpha
	draw_string(font, Vector2(64, 81), "PHASE %d · %s" % [phase_number, phase_name], HORIZONTAL_ALIGNMENT_CENTER, 192, 13, text_color)
