extends Control

const CalibrationMath = preload("res://scripts/settings/calibration.gd")
const SettingsStore = preload("res://scripts/settings/settings_store.gd")
const MAIN_SCENE := "res://scenes/beatspell/beatspell_battle.tscn"

const BPM := 100.0
const BEAT_LENGTH_MS := int(60000.0 / BPM)
const TARGET_SAMPLES := 8

var _start_ticks := 0
var _last_beat := -1
var _samples: Array = []
var _result_ms := 0
var _finished := false
var _flash_until := 0
var _metronome: AudioStreamPlayer


func _ready() -> void:
	_metronome = AudioStreamPlayer.new()
	_metronome.stream = _make_tone(880.0, 0.035)
	_metronome.volume_db = -8.0
	add_child(_metronome)
	_restart()


func _process(_delta: float) -> void:
	var elapsed := Time.get_ticks_msec() - _start_ticks
	if elapsed >= 0 and not _finished:
		var beat := int(floor(float(elapsed) / BEAT_LENGTH_MS))
		if beat != _last_beat:
			_last_beat = beat
			_metronome.pitch_scale = 1.25 if beat % 4 == 0 else 1.0
			_metronome.play()
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file(MAIN_SCENE)
		return
	if _finished and event.is_action_pressed("ui_accept"):
		var settings := SettingsStore.load_settings()
		settings.audio_offset_ms = _result_ms
		SettingsStore.save_settings(settings)
		get_tree().change_scene_to_file(MAIN_SCENE)
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_R:
			_restart()
			return
	if not _finished and event.is_action_pressed("instrument_drums"):
		_capture_tap()


func _capture_tap() -> void:
	var elapsed := Time.get_ticks_msec() - _start_ticks
	if elapsed < 0:
		return
	var nearest_beat := int(round(float(elapsed) / BEAT_LENGTH_MS))
	var offset := elapsed - nearest_beat * BEAT_LENGTH_MS
	if absi(offset) > CalibrationMath.MAX_OFFSET_MS:
		return
	_samples.append(offset)
	_flash_until = Time.get_ticks_msec() + 130
	if _samples.size() >= TARGET_SAMPLES:
		_result_ms = CalibrationMath.stable_offset(_samples)
		_finished = true
	queue_redraw()


func _restart() -> void:
	_start_ticks = Time.get_ticks_msec() + 1200
	_last_beat = -1
	_samples.clear()
	_result_ms = 0
	_finished = false
	_flash_until = 0


func _draw() -> void:
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(Vector2.ZERO, size), Color("111025"))
	draw_rect(Rect2(0, 0, size.x, 29), Color("1d1938"))
	draw_string(font, Vector2(10, 19), "AUDIO CALIBRATION", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("d8d5ff"))

	var elapsed := Time.get_ticks_msec() - _start_ticks
	var phase := 0.0
	if elapsed >= 0:
		phase = fmod(float(elapsed), BEAT_LENGTH_MS) / BEAT_LENGTH_MS
	var pulse := 1.0 - phase
	var radius := 16.0 + pulse * 14.0
	var center := Vector2(size.x * 0.5, 82)
	draw_circle(center, radius, Color(0.18, 0.89, 0.90, 0.12 + pulse * 0.25))
	draw_circle(center, 13.0, Color("2de2e6") if Time.get_ticks_msec() < _flash_until else Color("3f3a6b"))
	draw_string(font, center + Vector2(-4, 4), "D", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("111025"))

	if _finished:
		draw_string(font, Vector2(52, 126), "CALIBRATION  %+d ms" % _result_ms, HORIZONTAL_ALIGNMENT_CENTER, 216, 14, Color("f9f871"))
		draw_string(font, Vector2(50, 148), "ENTER  SAVE     R  RETRY", HORIZONTAL_ALIGNMENT_CENTER, 220, 8, Color("d8d5ff"))
	else:
		draw_string(font, Vector2(45, 124), "PRESS D WITH EACH CLICK", HORIZONTAL_ALIGNMENT_CENTER, 230, 10, Color.WHITE)
		draw_string(font, Vector2(80, 145), "%d / %d TAPS" % [_samples.size(), TARGET_SAMPLES], HORIZONTAL_ALIGNMENT_CENTER, 160, 9, Color("9d98c7"))
	draw_string(font, Vector2(10, 171), "ESC  BACK", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("7d789f"))


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
