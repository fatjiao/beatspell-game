extends Control

const ChartLoaderScript = preload("res://scripts/rhythm/chart_loader.gd")
const RhythmJudgeScript = preload("res://scripts/rhythm/rhythm_judge.gd")
const SettingsStore = preload("res://scripts/settings/settings_store.gd")
const StageDirectorScript = preload("res://scripts/presentation/stage_director.gd")
const SUBWAY_BACKGROUND: Texture2D = preload("res://assets/art/subway/subway_background.png")
const LOOP_IDLE: Texture2D = preload("res://assets/art/loop/loop_idle.png")

const CHART_PATH := "res://data/charts/prototype.json"
const INSTRUMENTS := ["drums", "bass", "synth", "lead"]
const ACTIONS := {
	"instrument_drums": "drums",
	"instrument_bass": "bass",
	"instrument_synth": "synth",
	"instrument_lead": "lead",
}
const KEY_LABELS := {"drums": "D", "bass": "F", "synth": "J", "lead": "K"}
const DISPLAY_NAMES := {
	"drums": "DRUMS",
	"bass": "BASS",
	"synth": "SYNTH",
	"lead": "LEAD",
}
const COLORS := {
	"drums": Color("2de2e6"),
	"bass": Color("6dfc8e"),
	"synth": Color("f9f871"),
	"lead": Color("ff2a9d"),
}

var _chart: Dictionary = {}
var _judge
var _events: Array = []
var _song_start_ticks := 0
var _song_time_ms := -1000
var _last_beat := -1
var _combo := 0
var _score := 0
var _heat := 0
var _status := "GET READY"
var _status_color := Color.WHITE
var _pad_flash_until := {}
var _tone_players := {}
var _music_players := {}
var _metronome_player: AudioStreamPlayer
var _finished := false
var _audio_offset_ms := 0
var _music_started := false
var _debug_tracks := false
var _active_instrument := "drums"
var _character_react_until := 0
var _paused := false
var _pause_started_ticks := 0
var _status_before_pause := ""
var _feedback_text := ""
var _feedback_color := Color.WHITE
var _feedback_until := 0
var _perfect_count := 0
var _good_count := 0
var _miss_count := 0
var _bad_tap_count := 0
var _director = StageDirectorScript.new()
var _current_section_id := ""
var _glitch_until := 0
var _hit_burst_until := 0


func _ready() -> void:
	_audio_offset_ms = int(SettingsStore.load_settings().audio_offset_ms)
	_setup_tones()
	_setup_music()
	_start_run()
	queue_redraw()


func _process(_delta: float) -> void:
	if _paused:
		queue_redraw()
		return
	if not _music_started:
		_song_time_ms = Time.get_ticks_msec() - _song_start_ticks
		if _song_time_ms >= 0:
			_start_music()
		else:
			_status = "COUNT %d" % clampi(int(ceil(float(-_song_time_ms) / 500.0)), 1, 4)
			_status_color = Color.WHITE
	else:
		_song_time_ms = int(maxf(0.0, (
			_music_players.drums.get_playback_position()
			+ AudioServer.get_time_since_last_mix()
			- AudioServer.get_output_latency()
		) * 1000.0))
		_update_music_layers()
	_update_stage_direction()
	if not _finished:
		_update_metronome()
		_consume_expired_events()
		if _song_time_ms >= int(_chart.duration_ms):
			_finish_run()
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_C:
			get_tree().change_scene_to_file("res://scenes/settings/calibration.tscn")
			return
		if event.physical_keycode == KEY_TAB:
			_debug_tracks = not _debug_tracks
			get_viewport().set_input_as_handled()
			queue_redraw()
			return
		if event.physical_keycode == KEY_P:
			_toggle_pause()
			get_viewport().set_input_as_handled()
			return
		if event.physical_keycode == KEY_R:
			_start_run()
			get_viewport().set_input_as_handled()
			return
	if _finished:
		return
	for action in ACTIONS:
		if event.is_action_pressed(action):
			_play_instrument(ACTIONS[action])
			get_viewport().set_input_as_handled()
			return


func _start_run() -> void:
	var result: Dictionary = ChartLoaderScript.new().load_chart(CHART_PATH)
	if not result.ok:
		_status = "CHART ERROR: %s" % result.error
		_status_color = Color.RED
		set_process(false)
		return
	_chart = result.data
	_events = _chart.events
	_judge = RhythmJudgeScript.new(_events)
	_song_start_ticks = Time.get_ticks_msec() + 2000
	_song_time_ms = -2000
	_last_beat = -1
	_combo = 0
	_score = 0
	_heat = 0
	_status = "GET READY"
	_status_color = Color.WHITE
	_finished = false
	_music_started = false
	_paused = false
	_feedback_text = ""
	_perfect_count = 0
	_good_count = 0
	_miss_count = 0
	_bad_tap_count = 0
	_current_section_id = ""
	_glitch_until = 0
	_hit_burst_until = 0
	for player in _music_players.values():
		player.stop()
		player.stream_paused = false


func _play_instrument(instrument: String) -> void:
	_pad_flash_until[instrument] = Time.get_ticks_msec() + 120
	_active_instrument = instrument
	_character_react_until = Time.get_ticks_msec() + 180
	_tone_players[instrument].play()
	var result: Dictionary = _judge.judge(_song_time_ms, instrument, _audio_offset_ms)
	_apply_judgement(result.grade, result.offset_ms)


func _apply_judgement(grade: String, offset_ms: int) -> void:
	match grade:
		"perfect":
			_combo += 1
			_perfect_count += 1
			_score += 100 + (_combo * 5)
			_heat = mini(100, _heat + 5)
			_status = "PERFECT  %+d ms" % offset_ms
			_status_color = Color("2de2e6")
			_show_feedback("PERFECT", Color("2de2e6"))
		"good":
			_combo += 1
			_good_count += 1
			_score += 60 + (_combo * 2)
			_heat = mini(100, _heat + 2)
			_status = "GOOD  %+d ms" % offset_ms
			_status_color = Color("f9f871")
			_show_feedback("GOOD", Color("f9f871"))
		_:
			_combo = 0
			_bad_tap_count += 1
			_heat = maxi(0, _heat - 4)
			_status = "OFF BEAT"
			_status_color = Color("ff5c8a")
			_show_feedback("OFF BEAT", Color("ff5c8a"))
	if _combo > 0 and _combo % 5 == 0:
		_show_feedback("%d HIT STREAK" % _combo, Color("ffffff"), 700)


func _consume_expired_events() -> void:
	for chart_event in _events:
		if chart_event.consumed:
			continue
		if _song_time_ms > chart_event.time_ms + RhythmJudgeScript.GOOD_WINDOW_MS:
			chart_event.consumed = true
			_combo = 0
			_miss_count += 1
			_heat = maxi(0, _heat - 3)
			_status = "MISS — KEEP PLAYING"
			_status_color = Color("ff5c8a")
			_show_feedback("MISS", Color("ff5c8a"))


func _show_feedback(text: String, color: Color, duration_ms: int = 420) -> void:
	_feedback_text = text
	_feedback_color = color
	_feedback_until = Time.get_ticks_msec() + duration_ms
	if text in ["MISS", "OFF BEAT"]:
		_glitch_until = Time.get_ticks_msec() + 180
	else:
		_hit_burst_until = Time.get_ticks_msec() + 260


func _update_stage_direction() -> void:
	if _song_time_ms < 0:
		return
	var section: Dictionary = _director.section_at(_song_time_ms)
	if section.id == _current_section_id:
		return
	_current_section_id = section.id
	if section.instrument != "ensemble":
		_active_instrument = section.instrument


func _toggle_pause() -> void:
	if _finished:
		return
	_paused = not _paused
	if _paused:
		_pause_started_ticks = Time.get_ticks_msec()
		_status_before_pause = _status
		_status = "PAUSED"
		_status_color = Color.WHITE
	else:
		if not _music_started:
			_song_start_ticks += Time.get_ticks_msec() - _pause_started_ticks
		_status = _status_before_pause
	for player in _music_players.values():
		player.stream_paused = _paused
	queue_redraw()


func _finish_run() -> void:
	_finished = true
	_status = "REHEARSAL COMPLETE"
	_status_color = Color("f9f871")
	for player in _music_players.values():
		player.stream_paused = true


func _result_accuracy() -> float:
	var total: int = maxi(1, _events.size())
	return (float(_perfect_count) + float(_good_count) * 0.7) / float(total)


func _result_rank() -> String:
	var accuracy := _result_accuracy()
	if accuracy >= 0.95:
		return "S"
	if accuracy >= 0.85:
		return "A"
	if accuracy >= 0.70:
		return "B"
	return "C"


func _update_metronome() -> void:
	if _song_time_ms < 0:
		return
	var beat_length_ms: float = 60000.0 / float(_chart.bpm)
	var beat := int(floor(_song_time_ms / beat_length_ms))
	if beat != _last_beat:
		_last_beat = beat
		_metronome_player.pitch_scale = 1.35 if beat % 4 == 0 else 1.0
		_metronome_player.play()


func _setup_music() -> void:
	var files := {
		"drums": "res://assets/music/chapter1/drums.ogg",
		"bass": "res://assets/music/chapter1/bass.ogg",
		"synth": "res://assets/music/chapter1/synth.ogg",
		"lead": "res://assets/music/chapter1/lead.ogg",
	}
	for instrument in INSTRUMENTS:
		var stream = load(files[instrument])
		if stream == null:
			_status = "MISSING MUSIC: %s" % files[instrument]
			_status_color = Color.RED
			continue
		var player := AudioStreamPlayer.new()
		player.stream = stream
		player.volume_db = -80.0
		add_child(player)
		_music_players[instrument] = player


func _start_music() -> void:
	if _music_players.size() != INSTRUMENTS.size():
		return
	_song_start_ticks = Time.get_ticks_msec()
	_song_time_ms = 0
	_music_started = true
	_status = "FOLLOW THE BEAT"
	_status_color = Color("d8d5ff")
	for instrument in INSTRUMENTS:
		_music_players[instrument].play(0.0)
	_update_music_layers()


func _update_music_layers() -> void:
	_music_players.drums.volume_db = -7.0
	_music_players.bass.volume_db = -9.0 if _song_time_ms >= 4000 else -80.0
	_music_players.synth.volume_db = -11.0 if _song_time_ms >= 6500 else -80.0
	_music_players.lead.volume_db = -9.0 if _song_time_ms >= 9000 else -80.0


func _setup_tones() -> void:
	var frequencies := {"drums": 120.0, "bass": 196.0, "synth": 392.0, "lead": 659.0}
	for instrument in INSTRUMENTS:
		var player := AudioStreamPlayer.new()
		player.stream = _make_tone(frequencies[instrument], 0.09)
		player.volume_db = -8.0
		add_child(player)
		_tone_players[instrument] = player
	_metronome_player = AudioStreamPlayer.new()
	_metronome_player.stream = _make_tone(880.0, 0.025)
	_metronome_player.volume_db = -15.0
	add_child(_metronome_player)


func _make_tone(frequency: float, duration_seconds: float) -> AudioStreamWAV:
	var mix_rate := 44100
	var sample_count := int(mix_rate * duration_seconds)
	var bytes := PackedByteArray()
	bytes.resize(sample_count * 2)
	for sample_index in sample_count:
		var progress := float(sample_index) / float(sample_count)
		var envelope := pow(1.0 - progress, 2.0)
		var sample := sin(TAU * frequency * float(sample_index) / float(mix_rate)) * envelope * 0.35
		var encoded := int(sample * 32767.0)
		if encoded < 0:
			encoded += 65536
		bytes[sample_index * 2] = encoded & 0xff
		bytes[sample_index * 2 + 1] = (encoded >> 8) & 0xff
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = mix_rate
	stream.stereo = false
	stream.data = bytes
	return stream


func _draw() -> void:
	var background_rect := Rect2(Vector2.ZERO, size)
	if Time.get_ticks_msec() < _glitch_until:
		draw_texture_rect(SUBWAY_BACKGROUND, Rect2(-2, 0, size.x, size.y), false, Color(1.0, 0.15, 0.35, 0.45))
		draw_texture_rect(SUBWAY_BACKGROUND, Rect2(2, 0, size.x, size.y), false, Color(0.10, 0.90, 1.0, 0.45))
	draw_texture_rect(SUBWAY_BACKGROUND, background_rect, false)
	_draw_environment_reactions()
	_draw_loop_character()
	if _finished:
		_draw_result_overlay()
		return
	if _debug_tracks:
		_draw_debug_tracks()
	else:
		_draw_cinematic_stage()
	_draw_feedback()
	if _song_time_ms < 0 and not _paused:
		_draw_count_in()
	if _paused:
		_draw_pause_overlay()


func _draw_environment_reactions() -> void:
	var layer_count := _active_layer_count()
	var section: Dictionary = _director.section_at(_song_time_ms)
	if layer_count <= 1:
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.02, 0.03, 0.10, 0.24))
	elif layer_count == 2:
		draw_circle(Vector2(50, 93), 52.0, Color(0.30, 1.00, 0.55, 0.06))
	elif layer_count == 3:
		for beam_x in [84.0, 160.0, 236.0]:
			var beam := PackedVector2Array([Vector2(beam_x - 15, 24), Vector2(beam_x + 15, 24), Vector2(beam_x + 34, 145), Vector2(beam_x - 34, 145)])
			draw_colored_polygon(beam, Color(0.95, 0.95, 0.45, 0.035))
	else:
		draw_circle(Vector2(178, 72), 110.0, Color(1.00, 0.16, 0.62, 0.06))
		draw_circle(Vector2(178, 72), 76.0, Color(0.18, 0.90, 0.95, 0.07))
		_draw_passersby()
	if section.id == "drums" and _song_time_ms >= 0:
		var ripple := fmod(float(_song_time_ms), 500.0) / 500.0
		draw_arc(Vector2(160, 133), 10.0 + ripple * 38.0, PI, TAU, 36, Color(0.18, 0.89, 0.90, (1.0 - ripple) * 0.24), 1.0)
	if layer_count >= 3 and _song_time_ms >= 0:
		for particle_index in 8:
			var particle_x := fmod(float(particle_index * 47 + int(_song_time_ms / 28)), 336.0) - 8.0
			var particle_y := 35.0 + fmod(float(particle_index * 29), 82.0)
			var color := Color("2de2e6") if particle_index % 2 == 0 else Color("ff2a9d")
			color.a = 0.20
			draw_rect(Rect2(particle_x, particle_y, 1, 1), color)


func _draw_passersby() -> void:
	var beat_bob := 0.0
	if _song_time_ms >= 0:
		beat_bob = sin(float(_song_time_ms) / 250.0 * PI) * 1.0
	for x in [44.0, 271.0]:
		var mirror := -1.0 if x < 160.0 else 1.0
		var body_color := Color(0.04, 0.04, 0.12, 0.76)
		draw_circle(Vector2(x, 91 + beat_bob), 4.0, body_color)
		draw_rect(Rect2(x - 4, 95 + beat_bob, 8, 18), body_color)
		draw_line(Vector2(x - 2, 112 + beat_bob), Vector2(x - 5 + mirror, 122), body_color, 3.0)
		draw_line(Vector2(x + 2, 112 + beat_bob), Vector2(x + 5 + mirror, 122), body_color, 3.0)


func _draw_loop_character() -> void:
	var beat_phase := 0.0
	if _song_time_ms >= 0:
		beat_phase = fmod(float(_song_time_ms), 500.0) / 500.0
	var bounce: float = -absf(sin(beat_phase * PI)) * 1.4
	var reacting := Time.get_ticks_msec() < _character_react_until
	var tilt := 0.0
	if reacting:
		tilt = -0.035 if _active_instrument in ["drums", "synth"] else 0.035
	var glow: Color = COLORS[_active_instrument]
	glow.a = 0.10 + float(_heat) / 1000.0
	var character_center := Vector2(160, 91 + bounce)
	if Time.get_ticks_msec() < _glitch_until:
		character_center.x += -2.0 if Time.get_ticks_msec() % 2 == 0 else 2.0
	draw_ellipse_shadow(Vector2(160, 133), 27.0, 6.0, glow)
	draw_set_transform(character_center, tilt, Vector2.ONE)
	draw_texture_rect(LOOP_IDLE, Rect2(-28, -42, 56, 84), false)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_draw_active_instrument(reacting, character_center)


func draw_ellipse_shadow(center: Vector2, radius_x: float, radius_y: float, color: Color) -> void:
	var points := PackedVector2Array()
	for point_index in 24:
		var angle := TAU * float(point_index) / 24.0
		points.append(center + Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
	draw_colored_polygon(points, color)


func _draw_active_instrument(reacting: bool, center: Vector2) -> void:
	var color: Color = COLORS[_active_instrument]
	match _active_instrument:
		"drums":
			draw_circle(center + Vector2(-9, 17), 6.0, Color(0.05, 0.06, 0.13, 0.92))
			draw_circle(center + Vector2(9, 17), 6.0, Color(0.05, 0.06, 0.13, 0.92))
			draw_arc(center + Vector2(-9, 17), 6.0, 0, TAU, 20, color, 1.0)
			draw_arc(center + Vector2(9, 17), 6.0, 0, TAU, 20, color, 1.0)
			if reacting:
				draw_line(center + Vector2(-10, 8), center + Vector2(-14, -1), color, 1.0)
				draw_line(center + Vector2(10, 8), center + Vector2(14, -1), color, 1.0)
		"bass":
			draw_line(center + Vector2(-9, 25), center + Vector2(14, -1), color, 3.0)
			draw_circle(center + Vector2(-9, 24), 7.0, Color(0.05, 0.06, 0.13, 0.94))
			draw_arc(center + Vector2(-9, 24), 7.0, 0, TAU, 20, color, 1.0)
		"synth":
			var keyboard_rect := Rect2(center + Vector2(-17, 15), Vector2(34, 10))
			draw_rect(keyboard_rect, Color(0.05, 0.06, 0.13, 0.94))
			draw_rect(keyboard_rect, color, false, 1.0)
			for key_x in range(-13, 16, 5):
				draw_line(center + Vector2(key_x, 19), center + Vector2(key_x, 24), Color("d8d5ff"), 1.0)
		"lead":
			draw_line(center + Vector2(8, 2), center + Vector2(8, 36), color, 1.0)
			draw_circle(center + Vector2(8, 0), 3.0, color)
			draw_line(center + Vector2(2, 36), center + Vector2(14, 36), color, 1.0)


func _draw_cinematic_stage() -> void:
	var font := ThemeDB.fallback_font
	var section: Dictionary = _director.section_at(_song_time_ms)
	var focus_instrument := _focus_instrument(section)
	var focus_color: Color = COLORS[focus_instrument]

	draw_rect(Rect2(0, 0, 320, 27), Color(0.03, 0.03, 0.10, 0.72))
	draw_string(font, Vector2(8, 12), "01 / UNDERPASS", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("d8d5ff"))
	draw_string(font, Vector2(148, 12), section.title, HORIZONTAL_ALIGNMENT_RIGHT, 164, 8, focus_color)
	var progress := clampf(float(maxi(0, _song_time_ms)) / float(maxi(1, int(_chart.get("duration_ms", 1)))), 0.0, 1.0)
	draw_rect(Rect2(8, 20, 304, 2), Color(1, 1, 1, 0.10))
	draw_rect(Rect2(8, 20, 304.0 * progress, 2), focus_color)

	_draw_fixed_key_anchors(font, section)
	draw_rect(Rect2(0, 168, 320, 12), Color(0.03, 0.03, 0.10, 0.68))
	draw_string(font, Vector2(8, 177), "P PAUSE   R RETRY   TAB ANALYSIS", HORIZONTAL_ALIGNMENT_LEFT, -1, 6, Color("aaa6cc"))
	draw_string(font, Vector2(268, 177), "C CAL %+d" % _audio_offset_ms, HORIZONTAL_ALIGNMENT_LEFT, -1, 6, Color("aaa6cc"))


func _draw_fixed_key_anchors(font: Font, section: Dictionary) -> void:
	var next_event = _next_pending_event()
	var next_instrument := ""
	var next_delta_ms := 2_147_483_647
	if next_event != null:
		next_instrument = next_event.instrument
		next_delta_ms = next_event.time_ms - _song_time_ms
	var now := Time.get_ticks_msec()

	for instrument in INSTRUMENTS:
		var center := _instrument_anchor(instrument)
		var color: Color = COLORS[instrument]
		var target_imminent: bool = instrument == next_instrument and next_delta_ms <= 1000
		var ensemble_available: bool = section.instrument == "ensemble"
		var section_active: bool = section.instrument == instrument or target_imminent
		var pressed: bool = int(_pad_flash_until.get(instrument, 0)) > now
		var lamp_alpha := 0.66 if section_active else (0.34 if ensemble_available else 0.16)
		if pressed:
			lamp_alpha = 1.0
		var lamp_color := color
		lamp_color.a = lamp_alpha
		draw_rect(Rect2(center + Vector2(-13, -2), Vector2(26, 4)), Color(0.02, 0.02, 0.08, 0.76))
		draw_rect(Rect2(center + Vector2(-12, -1), Vector2(24, 2)), lamp_color)
		var inactive_text := Color("9995ad") if ensemble_available else Color("69667c")
		draw_string(font, center + Vector2(-4, 11), KEY_LABELS[instrument], HORIZONTAL_ALIGNMENT_CENTER, 8, 6, Color("d8d5ff") if section_active else inactive_text)

		if target_imminent:
			var cue_progress: float = _director.cue_progress(next_delta_ms)
			_draw_floor_cue(center, color, cue_progress)

		if instrument == _active_instrument and now < _hit_burst_until:
			_draw_floor_hit_burst(center, color, now)


func _draw_floor_cue(center: Vector2, color: Color, progress: float) -> void:
	var glow := color
	glow.a = 0.035 + progress * 0.10
	var half_width := lerpf(15.0, 7.0, progress)
	var beam := PackedVector2Array([
		center + Vector2(-half_width, -1),
		center + Vector2(half_width, -1),
		center + Vector2(5, -68),
		center + Vector2(-5, -68),
	])
	draw_colored_polygon(beam, glow)
	var floor_glow := color
	floor_glow.a = 0.08 + progress * 0.18
	draw_ellipse_shadow(center, 18.0 + progress * 5.0, 3.0 + progress * 2.0, floor_glow)
	draw_rect(Rect2(center + Vector2(-14, -2), Vector2(28, 4)), Color(color, 0.45 + progress * 0.45))


func _draw_floor_hit_burst(center: Vector2, color: Color, now: int) -> void:
	var life := clampf(float(_hit_burst_until - now) / 260.0, 0.0, 1.0)
	var burst_color := color
	burst_color.a = life * 0.42
	draw_ellipse_shadow(center, 20.0 + (1.0 - life) * 24.0, 4.0 + (1.0 - life) * 4.0, burst_color)
	draw_line(center + Vector2(-4, -4), center + Vector2(-9, -10 - (1.0 - life) * 6.0), burst_color, 1.0)
	draw_line(center + Vector2(4, -4), center + Vector2(9, -10 - (1.0 - life) * 6.0), burst_color, 1.0)


func _instrument_anchor(instrument: String) -> Vector2:
	var index := INSTRUMENTS.find(instrument)
	return Vector2(55.0 + float(maxi(0, index)) * 70.0, 151.0)


func _focus_instrument(section: Dictionary) -> String:
	var next_event = _next_pending_event()
	if next_event != null:
		return next_event.instrument
	if section.instrument != "ensemble":
		return section.instrument
	return _active_instrument


func _next_pending_event():
	for chart_event in _events:
		if not chart_event.consumed:
			return chart_event
	return null


func _draw_feedback() -> void:
	if _feedback_text.is_empty() or Time.get_ticks_msec() >= _feedback_until:
		return
	var font := ThemeDB.fallback_font
	var remaining := float(_feedback_until - Time.get_ticks_msec()) / 420.0
	var pop_y := 44.0 - minf(1.0, remaining) * 4.0
	var shadow := Color(0.02, 0.02, 0.08, 0.85)
	draw_string(font, Vector2(106, pop_y + 1), _feedback_text, HORIZONTAL_ALIGNMENT_CENTER, 108, 12, shadow)
	draw_string(font, Vector2(105, pop_y), _feedback_text, HORIZONTAL_ALIGNMENT_CENTER, 108, 12, _feedback_color)
	var border_color := _feedback_color
	border_color.a = clampf(remaining * 0.25, 0.0, 0.25)
	draw_rect(Rect2(2, 27, 316, 138), border_color, false, 2.0)


func _draw_count_in() -> void:
	var font := ThemeDB.fallback_font
	var count := clampi(int(ceil(float(-_song_time_ms) / 500.0)), 1, 4)
	var center := Vector2(160, 77)
	draw_circle(center, 28.0, Color(0.03, 0.03, 0.10, 0.94))
	draw_arc(center, 28.0, -PI / 2.0, -PI / 2.0 + TAU * (1.0 - fmod(float(-_song_time_ms), 500.0) / 500.0), 32, Color("2de2e6"), 3.0)
	draw_string(font, center + Vector2(-19, 10), str(count), HORIZONTAL_ALIGNMENT_CENTER, 38, 28, Color.WHITE)


func _draw_pause_overlay() -> void:
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(0, 25, 320, 124), Color(0.02, 0.02, 0.08, 0.76))
	draw_string(font, Vector2(95, 77), "PAUSED", HORIZONTAL_ALIGNMENT_CENTER, 130, 18, Color.WHITE)
	draw_string(font, Vector2(95, 96), "P  RESUME     R  RESTART", HORIZONTAL_ALIGNMENT_CENTER, 130, 7, Color("d8d5ff"))


func _draw_result_overlay() -> void:
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(39, 31, 242, 112), Color(0.03, 0.03, 0.10, 0.95))
	draw_rect(Rect2(39, 31, 242, 112), Color("2de2e6"), false, 1.0)
	draw_string(font, Vector2(58, 48), "REHEARSAL COMPLETE", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("d8d5ff"))
	var rank_color := Color("f9f871") if _result_rank() in ["S", "A"] else Color("2de2e6")
	draw_string(font, Vector2(57, 105), _result_rank(), HORIZONTAL_ALIGNMENT_CENTER, 50, 44, rank_color)
	draw_string(font, Vector2(126, 68), "SCORE   %06d" % _score, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color.WHITE)
	draw_string(font, Vector2(126, 83), "ACCURACY  %3d%%" % int(round(_result_accuracy() * 100.0)), HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("d8d5ff"))
	draw_string(font, Vector2(126, 98), "PERFECT %02d   GOOD %02d" % [_perfect_count, _good_count], HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("d8d5ff"))
	draw_string(font, Vector2(126, 111), "MISS %02d   EXTRA %02d" % [_miss_count, _bad_tap_count], HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("d8d5ff"))
	draw_string(font, Vector2(93, 132), "R  PLAY AGAIN", HORIZONTAL_ALIGNMENT_CENTER, 134, 8, Color("f9f871"))


func _draw_debug_tracks() -> void:
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.04, 0.03, 0.10, 0.88))
	draw_rect(Rect2(0, 0, size.x, 27), Color("1d1938"))
	draw_string(font, Vector2(10, 18), "TRACK DEBUG — TAB TO RETURN", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("d8d5ff"))
	draw_string(font, Vector2(240, 18), "%06d" % _score, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color.WHITE)

	var hit_x := 74.0
	draw_line(Vector2(hit_x, 35), Vector2(hit_x, 139), Color("ffffff"), 1.0)
	for lane_index in INSTRUMENTS.size():
		var instrument: String = INSTRUMENTS[lane_index]
		var lane_y := 47.0 + lane_index * 25.0
		draw_rect(Rect2(8, lane_y - 9, 304, 18), Color(0.10, 0.09, 0.20, 1.0))
		draw_string(font, Vector2(12, lane_y + 4), KEY_LABELS[instrument], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, COLORS[instrument])
		draw_string(font, Vector2(28, lane_y + 4), DISPLAY_NAMES[instrument], HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("9d98c7"))

	for chart_event in _events:
		if chart_event.consumed:
			continue
		var delta_ms: int = chart_event.time_ms - _song_time_ms
		if delta_ms < -200 or delta_ms > 4800:
			continue
		var event_lane := INSTRUMENTS.find(chart_event.instrument)
		var event_y := 47.0 + event_lane * 25.0
		var event_x := hit_x + (float(delta_ms) / 1000.0) * 48.0
		draw_circle(Vector2(event_x, event_y), 5.0, COLORS[chart_event.instrument])
		draw_circle(Vector2(event_x, event_y), 2.0, Color("111025"))

	var now := Time.get_ticks_msec()
	for pad_index in INSTRUMENTS.size():
		var pad_instrument: String = INSTRUMENTS[pad_index]
		var pad_rect := Rect2(8 + pad_index * 78, 148, 70, 24)
		var active := int(_pad_flash_until.get(pad_instrument, 0)) > now
		var pad_color: Color = COLORS[pad_instrument]
		pad_color.a = 0.75 if active else 0.20
		draw_rect(pad_rect, pad_color)
		draw_rect(pad_rect, COLORS[pad_instrument], false, 1.0)
		draw_string(font, Vector2(pad_rect.position.x + 7, 164), "%s  %s" % [KEY_LABELS[pad_instrument], DISPLAY_NAMES[pad_instrument]], HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color.WHITE)

	draw_string(font, Vector2(8, 143), _status, HORIZONTAL_ALIGNMENT_LEFT, 170, 9, _status_color)
	draw_string(font, Vector2(205, 143), "COMBO %02d  HEAT %03d" % [_combo, _heat], HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("d8d5ff"))
	draw_string(font, Vector2(248, 176), "C CAL %+dms" % _audio_offset_ms, HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("7d789f"))


func _active_layer_count() -> int:
	if _song_time_ms >= 9000:
		return 4
	if _song_time_ms >= 6500:
		return 3
	if _song_time_ms >= 4000:
		return 2
	return 1
