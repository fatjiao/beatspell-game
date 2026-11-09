extends Control

const Art = preload("res://scripts/beatspell/art_direction.gd")
const ARENA_ART = preload("res://assets/art/beatspell/pixel/observatory.png")
const CASTER_ART = preload("res://assets/art/beatspell/pixel/caster.png")
const BOSS_ART = preload("res://assets/art/beatspell/pixel/warden.png")

var mode := ""
var count_value := 4
var phase_number := 0
var phase_name := ""
var phase_color := Art.GOLD
var result_data: Dictionary = {}

var _phase_started_ticks := 0
var _phase_until_ticks := 0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
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
	draw_texture_rect(ARENA_ART, Rect2(0, 0, 320, 180), false)
	draw_rect(Rect2(0, 0, 320, 180), Color(0.01, 0.035, 0.04, 0.64))
	draw_texture_rect(CASTER_ART, Rect2(1, 39, 98, 126), false, Color(0.75, 0.88, 0.85))
	draw_texture_rect(BOSS_ART, Rect2(225, 35, 95, 122), false, Color(0.90, 0.82, 0.68))
	Art.pixel_text(self, Vector2(90, 28), "A RITUAL IN THREE MOVEMENTS", HORIZONTAL_ALIGNMENT_CENTER, 140, 4, Art.GOLD)
	Art.pixel_wordmark(self, Vector2(81, 40), 3, Art.IVORY)
	draw_line(Vector2(112, 73), Vector2(149, 73), Color(Art.GOLD, 0.7), 0.5)
	draw_circle(Vector2(160, 73), 1.5, Art.GOLD)
	draw_line(Vector2(171, 73), Vector2(208, 73), Color(Art.GOLD, 0.7), 0.5)
	Art.pixel_text(self, Vector2(102, 85), "LISTEN. WEAVE. SURVIVE.", HORIZONTAL_ALIGNMENT_CENTER, 116, 5, Art.MUTED)
	for index in 3:
		var skill: String = ["fireball", "shield", "heal"][index]
		Art.sigil(self, Vector2(133 + index * 27, 103), skill, 7, Art.GOLD)
	Art.panel(self, Rect2(114, 123, 92, 23), Art.GOLD, true)
	Art.pixel_text(self, Vector2(122, 138), "BEGIN RITUAL", HORIZONTAL_ALIGNMENT_CENTER, 76, 7, Art.IVORY)
	Art.pixel_text(self, Vector2(117, 155), "J / K   ·   ENTER", HORIZONTAL_ALIGNMENT_CENTER, 86, 4, Art.GOLD)
	Art.pixel_text(self, Vector2(80, 174), "C  AUDIO CALIBRATION     /     ESC  LEAVE", HORIZONTAL_ALIGNMENT_CENTER, 160, 4, Art.MUTED)


func _draw_count_in() -> void:
	draw_circle(Vector2(160, 82), 30.0, Color(0.02, 0.05, 0.055, 0.94))
	draw_arc(Vector2(160, 82), 30.0, 0, TAU, 36, Art.GOLD, 2.0)
	Art.pixel_text(self, Vector2(143, 93), str(count_value), HORIZONTAL_ALIGNMENT_CENTER, 34, 28, Color("ffffff"))


func _draw_pause() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.01, 0.008, 0.03, 0.78))
	draw_rect(Rect2(0, 24, 320, 100), Color(0.02, 0.01, 0.06, 0.88))
	Art.pixel_text(self, Vector2(100, 68), "PAUSED", HORIZONTAL_ALIGNMENT_CENTER, 120, 18, Color("ffffff"))
	Art.pixel_text(self, Vector2(100, 88), "P  RESUME", HORIZONTAL_ALIGNMENT_CENTER, 120, 7, Art.IVORY)
	Art.pixel_text(self, Vector2(100, 103), "ESC  TITLE", HORIZONTAL_ALIGNMENT_CENTER, 120, 6, Art.MUTED)


func _draw_result() -> void:
	var color: Color = result_data.get("color", Color("69f0a5"))
	var panel := Rect2(32, 31, 256, 96)
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.01, 0.025, 0.03, 0.62))
	Art.panel(self, panel, Art.GOLD, true)
	Art.pixel_text(self, Vector2(48, 53), String(result_data.get("title", "RUN COMPLETE")), HORIZONTAL_ALIGNMENT_CENTER, 224, 14, color)
	Art.pixel_text(self, Vector2(48, 72), "CAST %02d/%02d   P%02d G%02d X%02d" % [
		int(result_data.get("successful_casts", 0)), int(result_data.get("attempts", 0)),
		int(result_data.get("perfect_casts", 0)), int(result_data.get("good_casts", 0)),
		int(result_data.get("failed_casts", 0)),
	], HORIZONTAL_ALIGNMENT_CENTER, 224, 7, Art.IVORY)
	Art.pixel_text(self, Vector2(48, 89), "INPUT %02d   AVG %03dMS  %s" % [
		int(result_data.get("inputs", 0)), int(result_data.get("average_offset_ms", 0)),
		String(result_data.get("timing_bias", "ON TIME")),
	], HORIZONTAL_ALIGNMENT_CENTER, 224, 7, Art.MUTED)
	Art.pixel_text(self, Vector2(48, 105), "RANK %s   BOSS %02d/%02d" % [
		String(result_data.get("rank", "C")), int(result_data.get("boss_hp", 0)),
		int(result_data.get("boss_max_hp", 36)),
	], HORIZONTAL_ALIGNMENT_CENTER, 224, 7, Art.GOLD)
	Art.pixel_text(self, Vector2(48, 121), "R  AGAIN   ESC  TITLE", HORIZONTAL_ALIGNMENT_CENTER, 224, 7, Art.GOLD)


func _draw_phase_flash() -> void:
	var total := maxf(1.0, float(_phase_until_ticks - _phase_started_ticks))
	var remaining := clampf(float(_phase_until_ticks - Time.get_ticks_msec()) / total, 0.0, 1.0)
	var alpha := sin((1.0 - remaining) * PI)
	var band_color := phase_color
	band_color.a = alpha * 0.18
	draw_rect(Rect2(0, 52, 320, 47), band_color)
	var text_color := phase_color
	text_color.a = alpha
	Art.pixel_text(self, Vector2(64, 81), "PHASE %d · %s" % [phase_number, phase_name], HORIZONTAL_ALIGNMENT_CENTER, 192, 13, text_color)
