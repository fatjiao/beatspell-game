extends Control

const ChartLoaderScript = preload("res://scripts/rhythm/chart_loader.gd")
const RhythmJudgeScript = preload("res://scripts/rhythm/rhythm_judge.gd")
const SettingsStore = preload("res://scripts/settings/settings_store.gd")

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


func _ready() -> void:
	_audio_offset_ms = int(SettingsStore.load_settings().audio_offset_ms)
	_setup_tones()
	_setup_music()
	_start_run()
	queue_redraw()


func _process(_delta: float) -> void:
	if not _music_started:
		_song_time_ms = Time.get_ticks_msec() - _song_start_ticks
		if _song_time_ms >= 0:
			_start_music()
	else:
		_song_time_ms = int(maxf(0.0, (
			_music_players.drums.get_playback_position()
			+ AudioServer.get_time_since_last_mix()
			- AudioServer.get_output_latency()
		) * 1000.0))
		_update_music_layers()
	if not _finished:
		_update_metronome()
		_consume_expired_events()
		if _song_time_ms >= int(_chart.duration_ms):
			_finished = true
			_status = "REHEARSAL COMPLETE"
			_status_color = Color("f9f871")
	else:
		if _song_time_ms >= int(_chart.duration_ms) + 2500:
			_start_run()
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_C:
			get_tree().change_scene_to_file("res://scenes/settings/calibration.tscn")
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
	_song_start_ticks = Time.get_ticks_msec() + 1000
	_song_time_ms = -1000
	_last_beat = -1
	_combo = 0
	_score = 0
	_heat = 0
	_status = "GET READY"
	_status_color = Color.WHITE
	_finished = false
	_music_started = false
	for player in _music_players.values():
		player.stop()


func _play_instrument(instrument: String) -> void:
	_pad_flash_until[instrument] = Time.get_ticks_msec() + 120
	_tone_players[instrument].play()
	var result: Dictionary = _judge.judge(_song_time_ms, instrument, _audio_offset_ms)
	_apply_judgement(result.grade, result.offset_ms)


func _apply_judgement(grade: String, offset_ms: int) -> void:
	match grade:
		"perfect":
			_combo += 1
			_score += 100 + (_combo * 5)
			_heat = mini(100, _heat + 5)
			_status = "PERFECT  %+d ms" % offset_ms
			_status_color = Color("2de2e6")
		"good":
			_combo += 1
			_score += 60 + (_combo * 2)
			_heat = mini(100, _heat + 2)
			_status = "GOOD  %+d ms" % offset_ms
			_status_color = Color("f9f871")
		_:
			_combo = 0
			_heat = maxi(0, _heat - 4)
			_status = "MISS"
			_status_color = Color("ff5c8a")


func _consume_expired_events() -> void:
	for chart_event in _events:
		if chart_event.consumed:
			continue
		if _song_time_ms > chart_event.time_ms + RhythmJudgeScript.GOOD_WINDOW_MS:
			chart_event.consumed = true
			_combo = 0
			_heat = maxi(0, _heat - 3)
			_status = "MISS — KEEP PLAYING"
			_status_color = Color("ff5c8a")


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
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(Vector2.ZERO, size), Color("111025"))
	draw_rect(Rect2(0, 0, size.x, 27), Color("1d1938"))
	draw_string(font, Vector2(10, 18), "ONE PERSON BAND — TECH PROTOTYPE", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("d8d5ff"))
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
