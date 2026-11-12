extends Control

const Art = preload("res://scripts/beatspell/art_direction.gd")
const Lang = preload("res://scripts/beatspell/localization.gd")
const Encounters = preload("res://scripts/beatspell/encounter_rules.gd")
const Records = preload("res://scripts/beatspell/run_records.gd")
const PRISM_ART = preload("res://assets/art/beatspell/pixel/prism_warden.png")
const ARENA_ART = preload("res://assets/art/beatspell/pixel/observatory.png")
const CASTER_ART = preload("res://assets/art/beatspell/pixel/caster.png")
const BOSS_ART = preload("res://assets/art/beatspell/pixel/warden.png")

var mode := ""
var count_value := 4
var phase_number := 0
var phase_name := ""
var phase_color := Art.GOLD
var result_data: Dictionary = {}
var options_data: Dictionary = {}
var selected_option := 0
var drill_data: Dictionary = {}
var selected_encounter := "ritual"
var title_save_failed := false
var records_data: Dictionary = {}

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


func show_options(data: Dictionary, selected: int) -> void:
	mode = "options"
	options_data = data.duplicate(true)
	selected_option = selected
	_request_redraw()


func show_records(data: Dictionary, selected: String) -> void:
	mode = "records"
	records_data = data.duplicate(true)
	selected_encounter = selected
	_request_redraw()


func show_guide() -> void:
	mode = "guide"
	_request_redraw()


func show_drill_report(data: Dictionary) -> void:
	mode = "drill_report"
	drill_data = data.duplicate(true)
	_request_redraw()


func show_title() -> void:
	reset_effects()
	mode = "title"
	_request_redraw()


func reset_effects() -> void:
	_phase_started_ticks = 0
	_phase_until_ticks = 0
	_request_redraw()


func show_count_in(value: int) -> void:
	mode = "count_in"
	count_value = clampi(value, 1, 4)
	_request_redraw()


func show_pause() -> void:
	mode = "pause"
	_request_redraw()


func show_resume(value: int) -> void:
	mode = "resume"
	count_value = clampi(value, 1, 3)
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
		"resume":
			_draw_resume()
		"options":
			_draw_options()
		"guide":
			_draw_guide()
		"result":
			_draw_result()
		"drill_report":
			_draw_drill_report()
		"records":
			_draw_records()
	if _phase_until_ticks > Time.get_ticks_msec() and mode.is_empty():
		_draw_phase_flash()


func _draw_title() -> void:
	draw_texture_rect(ARENA_ART, Rect2(0, 0, 320, 180), false)
	draw_rect(Rect2(0, 0, 320, 180), Color(0.01, 0.035, 0.04, 0.64))
	draw_texture_rect(CASTER_ART, Rect2(1, 39, 98, 126), false, Color(0.75, 0.88, 0.85))
	draw_texture_rect(PRISM_ART if selected_encounter == "prism" else BOSS_ART, Rect2(225, 35, 95, 122), false, Color.WHITE if selected_encounter == "prism" else Color(0.90, 0.82, 0.68))
	Art.pixel_text(self, Vector2(90, 28), "A RITUAL IN THREE MOVEMENTS", HORIZONTAL_ALIGNMENT_CENTER, 140, 4, Art.GOLD)
	Art.pixel_wordmark(self, Vector2(81, 40), 3, Art.IVORY)
	draw_line(Vector2(112, 73), Vector2(149, 73), Color(Art.GOLD, 0.7), 0.5)
	draw_circle(Vector2(160, 73), 1.5, Art.GOLD)
	draw_line(Vector2(171, 73), Vector2(208, 73), Color(Art.GOLD, 0.7), 0.5)
	Art.pixel_text(self, Vector2(80, 85), Lang.text("< %s >", [Encounters.label(selected_encounter)]), HORIZONTAL_ALIGNMENT_CENTER, 160, 7, Art.GOLD)
	var description: String = {"ritual": "GUIDED / 90S", "duel": "NO LESSONS / 90S", "gauntlet": "ROTATING CUES / 90S", "prism": "SECOND BOSS / 72HP"}.get(selected_encounter, "GUIDED / 90S")
	Art.pixel_text(self, Vector2(80, 98), "SETTINGS SAVE FAILED" if title_save_failed else description, HORIZONTAL_ALIGNMENT_CENTER, 160, 5, Art.MUTED)
	for index in 3:
		var skill: String = ["fireball", "shield", "heal"][index]
		Art.sigil(self, Vector2(133 + index * 27, 111), skill, 5, Art.GOLD)
	Art.panel(self, Rect2(114, 123, 92, 23), Art.GOLD, true)
	Art.pixel_text(self, Vector2(122, 138), "BEGIN BATTLE", HORIZONTAL_ALIGNMENT_CENTER, 76, 7, Art.IVORY)
	Art.pixel_text(self, Vector2(60, 155), "ARROWS MODE / ENTER START / V RECORDS", HORIZONTAL_ALIGNMENT_CENTER, 200, 4, Art.GOLD)
	Art.pixel_text(self, Vector2(60, 167), "T PRACTICE / O OPTIONS / C CALIBRATE", HORIZONTAL_ALIGNMENT_CENTER, 200, 5, Art.MUTED)
	Art.pixel_text(self, Vector2(100, 177), "H SPELLBOOK / ESC LEAVE", HORIZONTAL_ALIGNMENT_CENTER, 120, 4, Art.MUTED)


func _draw_count_in() -> void:
	draw_circle(Vector2(160, 82), 30.0, Color(0.02, 0.05, 0.055, 0.94))
	draw_arc(Vector2(160, 82), 30.0, 0, TAU, 36, Art.GOLD, 2.0)
	Art.pixel_text(self, Vector2(143, 93), str(count_value), HORIZONTAL_ALIGNMENT_CENTER, 34, 28, Color("ffffff"))


func _draw_pause() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.01, 0.008, 0.03, 0.78))
	draw_rect(Rect2(0, 24, 320, 100), Color(0.02, 0.01, 0.06, 0.88))
	Art.pixel_text(self, Vector2(100, 68), "PAUSED", HORIZONTAL_ALIGNMENT_CENTER, 120, 18, Color("ffffff"))
	Art.pixel_text(self, Vector2(100, 88), "P  RESUME", HORIZONTAL_ALIGNMENT_CENTER, 120, 7, Art.IVORY)
	Art.pixel_text(self, Vector2(100, 103), "O OPTIONS / ESC TITLE", HORIZONTAL_ALIGNMENT_CENTER, 120, 6, Art.MUTED)
	Art.pixel_text(self, Vector2(66, 119), "RESUME WITH THREE COUNTS", HORIZONTAL_ALIGNMENT_CENTER, 188, 5, Art.GOLD)


func _draw_resume() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.01, 0.025, 0.03, 0.78))
	Art.panel(self, Rect2(75, 35, 170, 110), Art.TEAL, true)
	Art.pixel_text(self, Vector2(87, 55), "GET READY", HORIZONTAL_ALIGNMENT_CENTER, 146, 9, Art.IVORY)
	Art.pixel_text(self, Vector2(140, 92), str(count_value), HORIZONTAL_ALIGNMENT_CENTER, 40, 28, Art.GOLD)
	for index in 3:
		draw_rect(Rect2(141 + index * 15, 106, 8, 3), Art.TEAL if index < count_value else Art.MUTED)
	Art.pixel_text(self, Vector2(85, 130), "P / ESC KEEP PAUSED", HORIZONTAL_ALIGNMENT_CENTER, 150, 5, Art.MUTED)


func _draw_result() -> void:
	var color: Color = result_data.get("color", Color("69f0a5"))
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.01, 0.025, 0.03, 0.72))
	Art.panel(self, Rect2(32, 24, 256, 132), Art.GOLD, true)
	Art.pixel_text(self, Vector2(48, 46), String(result_data.get("title", "RUN COMPLETE")), HORIZONTAL_ALIGNMENT_CENTER, 224, 14, color)
	Art.pixel_text(self, Vector2(48, 63), Lang.text("CAST %02d/%02d   P%02d G%02d X%02d", [
		int(result_data.get("successful_casts", 0)), int(result_data.get("attempts", 0)),
		int(result_data.get("perfect_casts", 0)), int(result_data.get("good_casts", 0)), int(result_data.get("failed_casts", 0)),
	]), HORIZONTAL_ALIGNMENT_CENTER, 224, 7, Art.IVORY)
	Art.pixel_text(self, Vector2(48, 78), Lang.text("AVG %03dMS %s / RANK %s", [
		int(result_data.get("average_offset_ms", 0)), String(result_data.get("timing_bias", "ON TIME")), String(result_data.get("rank", "C")),
	]), HORIZONTAL_ALIGNMENT_CENTER, 224, 6, Art.MUTED)
	draw_line(Vector2(55, 85), Vector2(265, 85), Color(Art.GOLD, 0.3), 1)
	Art.pixel_text(self, Vector2(48, 98), Lang.text("MAX COMBO %02d / DAMAGE %02d", [int(result_data.get("max_combo", 0)), int(result_data.get("damage", 0))]), HORIZONTAL_ALIGNMENT_CENTER, 224, 6, Art.GOLD)
	Art.pixel_text(self, Vector2(48, 112), Lang.text("BLOCK %02d / PERFECT %02d / BREAK %02d", [int(result_data.get("blocks", 0)), int(result_data.get("perfect_guards", 0)), int(result_data.get("breaks", 0))]), HORIZONTAL_ALIGNMENT_CENTER, 224, 6, Art.TEAL)
	Art.pixel_text(self, Vector2(48, 126), Lang.text("HEAL %02d / TIME %02dS / BOSS %02d", [int(result_data.get("healing", 0)), int(result_data.get("duration_seconds", 0)), int(result_data.get("boss_hp", 0))]), HORIZONTAL_ALIGNMENT_CENTER, 224, 6, Art.MUTED)
	var flags: Dictionary = result_data.get("record_flags", {})
	var badges: Array[String] = []
	for field in ["new_mastery", "new_rank", "new_clear", "new_combo"]:
		if flags.get(field, false):
			badges.append(Lang.text({"new_mastery": "MEDAL", "new_rank": "RANK", "new_clear": "TIME", "new_combo": "COMBO"}[field]))
	var record_text := Lang.text("NEW / %s", [" / ".join(badges)]) if not badges.is_empty() else Lang.text(String(result_data.get("encounter", "RITUAL")))
	if result_data.get("record_save_failed", false):
		record_text = Lang.text("RECORD SAVE FAILED")
	Art.pixel_text(self, Vector2(48, 137), record_text, HORIZONTAL_ALIGNMENT_CENTER, 224, 5, Art.GOLD)
	Art.pixel_text(self, Vector2(48, 148), "R AGAIN / V RECORDS / ESC TITLE", HORIZONTAL_ALIGNMENT_CENTER, 224, 6, Art.IVORY)


func _draw_records() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.01, 0.025, 0.03, 0.96))
	Art.panel(self, Rect2(24, 18, 272, 144), Art.GOLD, true)
	Art.pixel_text(self, Vector2(42, 39), "RECORD BOOK", HORIZONTAL_ALIGNMENT_CENTER, 236, 12, Art.IVORY)
	var columns := [42, 132, 191, 235]
	for index in 4:
		Art.pixel_text(self, Vector2(columns[index], 55), ["MODE", "WIN/RUN", "RANK", "BEST"][index], HORIZONTAL_ALIGNMENT_LEFT, -1, 5, Art.MUTED)
	var modes := Encounters.MODES
	for index in modes.size():
		var id: String = modes[index]
		var row: Dictionary = records_data.get("modes", {}).get(id, {})
		var y := 70 + index * 15
		if id == selected_encounter:
			draw_rect(Rect2(35, y - 9, 250, 14), Color(Art.TEAL, 0.12))
		for pip in 3:
			draw_rect(Rect2(42 + pip * 4, y + 3, 2, 2), Art.GOLD if pip < Records.mastery(row) else Color("35414d"))
		Art.pixel_text(self, Vector2(columns[0], y), Encounters.label(id), HORIZONTAL_ALIGNMENT_LEFT, 84, 6, Art.IVORY)
		Art.pixel_text(self, Vector2(columns[1], y), "%s/%s" % [_compact_count(int(row.get("wins", 0))), _compact_count(int(row.get("attempts", 0)))], HORIZONTAL_ALIGNMENT_LEFT, 55, 6, Art.TEAL)
		var rank_text: String = row.get("best_rank", "")
		Art.pixel_text(self, Vector2(columns[2], y), "-" if rank_text.is_empty() else rank_text, HORIZONTAL_ALIGNMENT_LEFT, 32, 6, Art.GOLD)
		var time_ms := int(row.get("best_clear_ms", -1))
		Art.pixel_text(self, Vector2(columns[3], y), "-" if time_ms < 0 else "%.1fS" % (time_ms / 1000.0), HORIZONTAL_ALIGNMENT_LEFT, 44, 6, Art.TEAL)
	var selected: Dictionary = records_data.get("modes", {}).get(selected_encounter, {})
	var medal: String = ["UNCLEARED", "CLEAR MEDAL", "A CLEAR", "S CLEAR"][Records.mastery(selected)]
	Art.pixel_text(self, Vector2(40, 133), Lang.text("%s / COMBO %s", [medal, _compact_count(int(selected.get("best_combo", 0)))]), HORIZONTAL_ALIGNMENT_CENTER, 240, 6, Art.GOLD)
	Art.pixel_text(self, Vector2(40, 150), "V / ESC BACK", HORIZONTAL_ALIGNMENT_CENTER, 240, 6, Art.MUTED)


func _compact_count(value: int) -> String:
	return "999+" if value > 999 else str(value)


func _draw_phase_flash() -> void:
	var total := maxf(1.0, float(_phase_until_ticks - _phase_started_ticks))
	var remaining := clampf(float(_phase_until_ticks - Time.get_ticks_msec()) / total, 0.0, 1.0)
	var alpha := sin((1.0 - remaining) * PI)
	var band_color := phase_color
	band_color.a = alpha * 0.18
	draw_rect(Rect2(0, 52, 320, 47), band_color)
	var text_color := phase_color
	text_color.a = alpha
	Art.pixel_text(self, Vector2(64, 81), Lang.text("PHASE %d · %s", [phase_number, phase_name]), HORIZONTAL_ALIGNMENT_CENTER, 192, 13, text_color)


func _draw_drill_report() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.01, 0.025, 0.03, 0.92))
	Art.panel(self, Rect2(24, 18, 272, 144), Art.GOLD, true)
	Art.pixel_text(self, Vector2(43, 39), "DEFENSE REPORT", HORIZONTAL_ALIGNMENT_CENTER, 234, 12, Art.IVORY)
	var columns := [44, 158, 186, 214, 249]
	for index in columns.size():
		Art.pixel_text(self, Vector2(columns[index], 57), ["PATTERN", "TRY", "BLK", "PRF", "RUN"][index], HORIZONTAL_ALIGNMENT_LEFT, -1, 6, Art.MUTED)
	var rows: Array = drill_data.get("rows", [])
	for index in rows.size():
		var row: Dictionary = rows[index]
		var y := 72 + index * 12
		if index == int(drill_data.get("selected", -1)):
			draw_rect(Rect2(35, y - 8, 250, 11), Color(Art.TEAL, 0.12))
		Art.pixel_text(self, Vector2(columns[0], y), Lang.text("%s OK", [row.label]) if row.clear else Lang.text(row.label), HORIZONTAL_ALIGNMENT_LEFT, -1, 6, Art.GOLD if row.clear else Art.IVORY)
		var values := [row.attempts, row.blocks, row.perfect, row.best]
		for column in values.size():
			Art.pixel_text(self, Vector2(columns[column + 1], y), "%02d" % int(values[column]), HORIZONTAL_ALIGNMENT_LEFT, -1, 6, Art.TEAL)
	var last: String = drill_data.get("last_outcome", "NO ATTACKS YET")
	var age := int(drill_data.get("last_age_ms", -1))
	if age >= 0:
		last = Lang.text("%s %dMS", [last, age])
	Art.pixel_text(self, Vector2(40, 138), last, HORIZONTAL_ALIGNMENT_CENTER, 240, 6, Art.GOLD)
	Art.pixel_text(self, Vector2(40, 151), "TAB / ESC BACK . P RESUME", HORIZONTAL_ALIGNMENT_CENTER, 240, 5, Art.MUTED)

func _draw_options() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.01, 0.025, 0.03, 0.92))
	Art.panel(self, Rect2(49, 24, 222, 132), Art.GOLD, true)
	Art.pixel_text(self, Vector2(68, 43), "OPTIONS", HORIZONTAL_ALIGNMENT_CENTER, 184, 12, Art.IVORY)
	var labels := ["MUSIC", "SOUND FX", "SCREEN SHAKE", "FULLSCREEN", "LANGUAGE"]
	for index in labels.size():
		var y := 61 + index * 17
		if index == selected_option:
			draw_rect(Rect2(59, y - 8, 202, 15), Color(Art.TEAL, 0.12))
			Art.pixel_text(self, Vector2(62, y), ">", HORIZONTAL_ALIGNMENT_LEFT, 8, 6, Art.GOLD)
		Art.pixel_text(self, Vector2(74, y), labels[index], HORIZONTAL_ALIGNMENT_LEFT, 112, 6, Art.IVORY)
		var value := ""
		if index < 2:
			var setting: String = ["music_volume", "sfx_volume"][index]
			value = "%d/10" % int(round(float(options_data.get(setting, 0.8)) * 10))
		elif index < 4:
			var setting: String = ["screen_shake", "fullscreen"][index - 2]
			value = "ON" if options_data.get(setting, index == 2) else "OFF"
		else:
			value = Lang.language_label(options_data.get("language", "auto"))
		Art.pixel_text(self, Vector2(201, y), value, HORIZONTAL_ALIGNMENT_CENTER, 42, 6, Art.TEAL)
	Art.pixel_text(self, Vector2(65, 147), "ARROWS ADJUST / ESC BACK", HORIZONTAL_ALIGNMENT_CENTER, 190, 5, Art.MUTED)

func _draw_guide() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.01, 0.025, 0.03, 0.95))
	Art.panel(self, Rect2(26, 17, 268, 145), Art.GOLD, true)
	Art.pixel_text(self, Vector2(48, 37), "SPELLBOOK", HORIZONTAL_ALIGNMENT_CENTER, 224, 12, Art.IVORY)
	var lines := [
		"FLARE: STEP / CAST",
		"MEND:  STEP / STEP / CAST",
		"AEGIS: STEP / REST / CAST",
		"ONE SYMBOL PER WHOLE BEAT",
		"PERFECT AEGIS ON LAST BEAT: GUARD",
		"BLOCK 1 / GUARD 2 / BREAK AT 3",
		"BREAK: NEXT FLARE +2 DAMAGE",
		"4 CAST COMBO: NEXT FLARE +1",
		"DRILL: ARROWS MODE / TAB REPORT",
	]
	for index in lines.size():
		Art.pixel_text(self, Vector2(48, 53 + index * 11), lines[index], HORIZONTAL_ALIGNMENT_LEFT, 224, 6, Art.TEAL if index < 3 else Art.MUTED)
	Art.pixel_text(self, Vector2(48, 153), "H / ESC BACK", HORIZONTAL_ALIGNMENT_CENTER, 224, 5, Art.GOLD)
