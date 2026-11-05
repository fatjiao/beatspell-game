extends Control

const BattleModelScript = preload("res://scripts/beatspell/battle_model.gd")
const BattleDirectorScript = preload("res://scripts/beatspell/battle_director.gd")
const SpellCommandBufferScript = preload("res://scripts/beatspell/spell_command_buffer.gd")
const InputTraceFade = preload("res://scripts/beatspell/input_trace_fade.gd")
const SettingsStore = preload("res://scripts/settings/settings_store.gd")

const BPM := 120.0
const BEAT_MS := 500.0
const BAR_MS := 2000
const BATTLE_DURATION_MS := 90_000
const MUSIC_FILES := {
	"drums": "res://assets/music/chapter1/drums.ogg",
	"bass": "res://assets/music/chapter1/bass.ogg",
	"synth": "res://assets/music/chapter1/synth.ogg",
	"lead": "res://assets/music/chapter1/lead.ogg",
}
const MUSIC_VOLUMES := {"drums": -11.0, "bass": -17.0, "synth": -18.0, "lead": -17.0}
const SKILL_NAMES := {"fireball": "FLARE", "shield": "AEGIS", "heal": "MEND"}
const SKILL_COLORS := {
	"fireball": Color("ff6b5e"),
	"shield": Color("45e6ff"),
	"heal": Color("69f0a5"),
}
const SKILL_EFFECTS := {"fireball": "DAMAGE", "shield": "BLOCK", "heal": "RECOVER"}
const DISPLAY_PATTERNS := {
	"fireball": [{"tick": 0, "action": "step"}, {"tick": 1, "action": "finish"}],
	"shield": [{"tick": 0, "action": "step"}, {"tick": 2, "action": "finish"}],
	"heal": [
		{"tick": 0, "action": "step"},
		{"tick": 1, "action": "step"},
		{"tick": 2, "action": "finish"},
	],
}

var _battle = BattleModelScript.new()
var _director = BattleDirectorScript.new()
var _command = SpellCommandBufferScript.new()
var _music_players: Dictionary = {}
var _sfx_players: Dictionary = {}
var _audio_ready := false
var _audio_offset_ms := 0
var _song_start_ticks := 0
var _song_time_ms := -2000
var _music_started := false
var _bar_index := -1
var _active_phase := 1
var _recent_command: Array = []
var _feedback := "LISTEN TO THE PULSE"
var _feedback_color := Color("dad7ff")
var _feedback_until := 0
var _last_action := ""
var _action_flash_until := 0
var _last_skill := ""
var _skill_flash_until := 0
var _boss_hit_until := 0
var _boss_attack_until := 0
var _shield_flash_until := 0
var _finished := false
var _result_text := ""
var _paused := false
var _pause_started_ticks := 0
var _count_click_index := -1
var _last_attack_cue_key := -1
var _error_text := ""


func _ready() -> void:
	_audio_offset_ms = int(SettingsStore.load_settings().audio_offset_ms)
	_audio_ready = _setup_music()
	_setup_sfx()
	_start_run()
	queue_redraw()


func _process(_delta: float) -> void:
	if _paused:
		queue_redraw()
		return
	if not _music_started:
		_song_time_ms = Time.get_ticks_msec() - _song_start_ticks
		_update_count_in_audio()
		if _song_time_ms >= 0 and _audio_ready:
			_start_music()
	else:
		var clock: AudioStreamPlayer = _music_players["drums"]
		_song_time_ms = int(maxf(0.0, (
			clock.get_playback_position()
			+ AudioServer.get_time_since_last_mix()
			- AudioServer.get_output_latency()
		) * 1000.0))
		_update_command()
		_update_bar()
		_update_attack_cue(maxi(0, _song_time_ms - _audio_offset_ms))
		if _song_time_ms >= BATTLE_DURATION_MS and not _finished:
			_finish_battle("RITUAL EXPIRED", false)
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if event.physical_keycode == KEY_R:
		_start_run()
		get_viewport().set_input_as_handled()
		return
	if event.physical_keycode == KEY_P:
		_toggle_pause()
		get_viewport().set_input_as_handled()
		return
	if event.physical_keycode == KEY_C:
		get_tree().change_scene_to_file("res://scenes/settings/calibration.tscn")
		return
	if _finished or _paused or _song_time_ms < 0 or not _music_started:
		return
	if event.is_action_pressed("battle_charge"):
		_register_action("charge")
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("battle_cast"):
		_register_action("cast")
		get_viewport().set_input_as_handled()


func _start_run() -> void:
	_battle = BattleModelScript.new()
	_song_start_ticks = Time.get_ticks_msec() + 2000
	_song_time_ms = -2000
	_music_started = false
	_bar_index = -1
	_active_phase = 1
	_command.reset()
	_recent_command.clear()
	_feedback = "LISTEN TO THE PULSE"
	_feedback_color = Color("dad7ff")
	_feedback_until = 0
	_last_action = ""
	_last_skill = ""
	_finished = false
	_result_text = ""
	_paused = false
	_count_click_index = -1
	_last_attack_cue_key = -1
	for player in _music_players.values():
		player.stop()
		player.stream_paused = false
	queue_redraw()


func _start_music() -> void:
	_music_started = true
	_song_time_ms = 0
	_bar_index = 0
	_command.reset()
	for player in _music_players.values():
		player.play(0.0)
	_show_feedback("FORM A SPELL", Color("dad7ff"), 900)


func _update_bar() -> void:
	if _finished:
		return
	var adjusted_time := maxi(0, _song_time_ms - _audio_offset_ms)
	var new_bar := int(floor(float(adjusted_time) / float(BAR_MS)))
	if new_bar == _bar_index:
		return
	if _bar_index >= 0:
		_resolve_bar(_bar_index)
		if _finished:
			return
	_bar_index = new_bar
	var next_phase: int = _director.phase_for_health(_battle.boss_hp, _battle.MAX_BOSS_HP)
	if next_phase != _active_phase:
		_active_phase = next_phase
		_show_feedback("PHASE %d · %s" % [_active_phase, _director.phase_name(_active_phase)], Color("ff9a6b"), 1050)


func _update_command() -> void:
	if _finished:
		return
	var adjusted_time := maxi(0, _song_time_ms - _audio_offset_ms)
	if _command.expire_if_needed(adjusted_time, BEAT_MS):
		_show_feedback("LOST THE PHRASE", Color("ff668e"), 620)
		_play_sfx("error")


func _register_action(action: String) -> void:
	var adjusted_time := maxi(0, _song_time_ms - _audio_offset_ms)
	_update_command()
	_update_bar()
	if _finished:
		return
	_last_action = action
	_action_flash_until = Time.get_ticks_msec() + 150
	_play_sfx(action)
	if action == "charge":
		_command.register_step(adjusted_time, BEAT_MS)
		return
	var result: Dictionary = _command.finish(adjusted_time, BEAT_MS)
	_recent_command = result.events.duplicate(true)
	if result.skill.is_empty():
		_battle.cast_spell("")
		_show_feedback("RHYTHM BROKE", Color("ff668e"), 620)
		_play_sfx("error")
		return
	_cast_skill(result.skill, result.grade)
	if _battle.is_victory():
		_finish_battle("BEAST DISPELLED", true)


func _resolve_bar(resolved_bar: int) -> void:
	if _finished:
		return
	if _is_attack_bar(resolved_bar):
		_resolve_boss_attack()


func _cast_skill(skill: String, grade: String) -> void:
	var result: Dictionary = _battle.cast_spell(skill, grade)
	_last_skill = skill
	_skill_flash_until = Time.get_ticks_msec() + 620
	_play_sfx(skill)
	match skill:
		"fireball":
			_boss_hit_until = Time.get_ticks_msec() + 420
			_show_feedback("%s  -%d" % [SKILL_NAMES[skill], result.amount], SKILL_COLORS[skill], 720)
		"shield":
			_shield_flash_until = Time.get_ticks_msec() + 850
			_show_feedback(SKILL_NAMES[skill], SKILL_COLORS[skill], 720)
		"heal":
			_show_feedback("%s  +%d" % [SKILL_NAMES[skill], result.amount], SKILL_COLORS[skill], 720)


func _resolve_boss_attack() -> void:
	var result: Dictionary = _battle.boss_attack(_director.attack_damage(_active_phase))
	_boss_attack_until = Time.get_ticks_msec() + 520
	if result.blocked:
		_shield_flash_until = Time.get_ticks_msec() + 620
		_show_feedback("BLOCKED", Color("45e6ff"), 760)
		_play_sfx("shield_block")
	else:
		_show_feedback("BEAST STRIKE  -%d" % result.damage, Color("ff668e"), 820)
		_play_sfx("boss")
	if _battle.is_defeat():
		_finish_battle("RITUAL BROKEN", false)


func _is_attack_bar(bar: int) -> bool:
	return _director.is_attack_bar(bar, _active_phase)


func _update_attack_cue(adjusted_time_ms: int) -> void:
	var cue_index: int = _director.attack_cue_index(adjusted_time_ms, _bar_index, _active_phase)
	if cue_index < 0:
		_last_attack_cue_key = -1
		return
	var cue_key := _bar_index * 4 + cue_index
	if cue_key == _last_attack_cue_key:
		return
	_last_attack_cue_key = cue_key
	var player: AudioStreamPlayer = _sfx_players.get("warning")
	if player != null:
		player.pitch_scale = 1.28 if cue_index == 3 else 0.94 + float(cue_index) * 0.06
		player.play()


func _show_feedback(text: String, color: Color, duration_ms: int) -> void:
	_feedback = text
	_feedback_color = color
	_feedback_until = Time.get_ticks_msec() + duration_ms


func _finish_battle(text: String, victory: bool) -> void:
	_finished = true
	_result_text = text
	_feedback_color = Color("69f0a5") if victory else Color("ff668e")
	for player in _music_players.values():
		player.stream_paused = true


func _toggle_pause() -> void:
	if _finished:
		return
	_paused = not _paused
	if _paused:
		_pause_started_ticks = Time.get_ticks_msec()
	elif not _music_started:
		_song_start_ticks += Time.get_ticks_msec() - _pause_started_ticks
	for player in _music_players.values():
		player.stream_paused = _paused
	queue_redraw()


func _setup_music() -> bool:
	var ready := true
	for instrument in MUSIC_FILES:
		var stream = load(MUSIC_FILES[instrument])
		if stream == null:
			_error_text = "MISSING MUSIC: %s" % instrument
			ready = false
			continue
		var player := AudioStreamPlayer.new()
		player.stream = stream
		player.volume_db = MUSIC_VOLUMES[instrument]
		add_child(player)
		_music_players[instrument] = player
	return ready and _music_players.size() == MUSIC_FILES.size()


func _setup_sfx() -> void:
	for sound_name in ["charge", "cast", "fireball", "shield", "shield_block", "heal", "boss", "warning", "error", "count"]:
		var player := AudioStreamPlayer.new()
		player.stream = _make_sfx(sound_name)
		player.volume_db = -10.0 if sound_name in ["charge", "cast", "count"] else -7.0
		player.max_polyphony = 4
		add_child(player)
		_sfx_players[sound_name] = player


func _play_sfx(sound_name: String) -> void:
	if _sfx_players.has(sound_name):
		_sfx_players[sound_name].play()


func _update_count_in_audio() -> void:
	if _song_time_ms >= 0:
		return
	var click_index := int(floor(float(_song_time_ms + 2000) / BEAT_MS))
	if click_index != _count_click_index and click_index >= 0:
		_count_click_index = click_index
		var player: AudioStreamPlayer = _sfx_players.get("count")
		if player != null:
			player.pitch_scale = 1.35 if click_index == 3 else 1.0
			player.play()


func _make_sfx(kind: String) -> AudioStreamWAV:
	var duration: float = float({
		"charge": 0.09, "cast": 0.08, "fireball": 0.30, "shield": 0.34,
		"shield_block": 0.22, "heal": 0.42, "boss": 0.28, "warning": 0.075,
		"error": 0.13, "count": 0.04,
	}.get(kind, 0.1))
	var mix_rate := 44100
	var sample_count := int(float(mix_rate) * duration)
	var bytes := PackedByteArray()
	bytes.resize(sample_count * 2)
	for sample_index in sample_count:
		var t := float(sample_index) / float(mix_rate)
		var progress := float(sample_index) / float(sample_count)
		var envelope := pow(1.0 - progress, 2.2)
		var sample := 0.0
		match kind:
			"charge":
				var frequency := lerpf(180.0, 95.0, progress)
				sample = sin(TAU * frequency * t) * envelope
			"cast":
				sample = (sin(TAU * 520.0 * t) + sin(TAU * 1040.0 * t) * 0.35) * envelope
			"fireball":
				var frequency := lerpf(720.0, 82.0, progress)
				sample = (sin(TAU * frequency * t) * 0.75 + sin(TAU * frequency * 0.51 * t) * 0.35) * envelope
			"shield", "shield_block":
				sample = (sin(TAU * 440.0 * t) + sin(TAU * 660.0 * t) * 0.55 + sin(TAU * 880.0 * t) * 0.25) * envelope
			"heal":
				var note: float = [330.0, 440.0, 550.0][mini(2, int(progress * 3.0))]
				sample = (sin(TAU * note * t) + sin(TAU * note * 2.0 * t) * 0.22) * envelope
			"boss":
				var growl := 62.0 + sin(t * 31.0) * 9.0
				sample = (sin(TAU * growl * t) + sin(TAU * growl * 1.48 * t) * 0.55) * envelope
			"warning":
				sample = (sin(TAU * 220.0 * t) + sin(TAU * 440.0 * t) * 0.42) * envelope
			"error":
				sample = (sin(TAU * 92.0 * t) + sin(TAU * 103.0 * t)) * envelope * 0.65
			"count":
				sample = sin(TAU * 880.0 * t) * envelope
		var encoded := int(clampf(sample * 0.30, -1.0, 1.0) * 32767.0)
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
	_draw_arena()
	_draw_health()
	_draw_player()
	_draw_boss()
	_draw_spell_effects()
	_draw_beat_ring()
	_draw_spell_cards()
	_draw_feedback()
	_draw_footer()
	if _song_time_ms < 0 and not _finished:
		_draw_count_in()
	if _paused:
		_draw_pause()
	if _finished:
		_draw_result()
	if not _error_text.is_empty():
		var font := ThemeDB.fallback_font
		draw_rect(Rect2(24, 72, 272, 34), Color(0.06, 0.03, 0.08, 0.95))
		draw_string(font, Vector2(32, 93), _error_text, HORIZONTAL_ALIGNMENT_CENTER, 256, 9, Color("ff668e"))


func _draw_arena() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("09091a"))
	for ring_index in range(5, 0, -1):
		var radius := 24.0 + float(ring_index) * 24.0
		var color := Color(0.17, 0.10, 0.32, 0.10 + float(5 - ring_index) * 0.015)
		draw_circle(Vector2(160, 88), radius, color)
	for line_x in range(0, 321, 20):
		draw_line(Vector2(160, 100), Vector2(line_x, 142), Color(0.25, 0.18, 0.42, 0.12), 1.0)
	draw_rect(Rect2(0, 124, 320, 56), Color(0.025, 0.02, 0.075, 0.88))
	draw_line(Vector2(0, 124), Vector2(320, 124), Color(0.50, 0.32, 0.76, 0.28), 1.0)
	var pulse := 0.0
	if _song_time_ms >= 0:
		pulse = 1.0 - fmod(float(_song_time_ms), BEAT_MS) / BEAT_MS
	for particle_index in 18:
		var x := fmod(float(particle_index * 53 + maxi(0, _song_time_ms) / 19), 340.0) - 10.0
		var y := 30.0 + fmod(float(particle_index * 37), 88.0)
		var color := Color("45e6ff") if particle_index % 2 == 0 else Color("ff5fba")
		color.a = 0.08 + pulse * 0.05
		draw_rect(Rect2(x, y, 1, 1), color)


func _draw_health() -> void:
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(10, 13), "CASTER", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("dad7ff"))
	draw_rect(Rect2(10, 17, 92, 5), Color("211c38"))
	draw_rect(Rect2(11, 18, 90.0 * float(_battle.player_hp) / float(_battle.MAX_PLAYER_HP), 3), Color("69f0a5"))
	draw_string(font, Vector2(218, 13), "PULSE BEAST", HORIZONTAL_ALIGNMENT_RIGHT, 92, 7, Color("dad7ff"))
	draw_rect(Rect2(218, 17, 92, 5), Color("211c38"))
	draw_rect(Rect2(219, 18, 90.0 * float(_battle.boss_hp) / float(_battle.MAX_BOSS_HP), 3), Color("ff668e"))
	if _battle.shield_active:
		draw_string(font, Vector2(109, 20), "AEGIS READY", HORIZONTAL_ALIGNMENT_CENTER, 102, 6, Color("45e6ff"))
	else:
		var phase_color := Color("8d7dff") if _active_phase == 1 else Color("ff9a6b") if _active_phase == 2 else Color("ff4f70")
		draw_string(font, Vector2(109, 13), "PHASE %d · %s" % [_active_phase, _director.phase_name(_active_phase)], HORIZONTAL_ALIGNMENT_CENTER, 102, 6, phase_color)


func _draw_player() -> void:
	var now := Time.get_ticks_msec()
	var center := Vector2(61, 87)
	if now < _action_flash_until:
		center.y -= 2.0
	if now < _boss_attack_until and not _battle.shield_active:
		center.x += -2.0 if now % 2 == 0 else 2.0
	var aura := Color("ffc45e") if _last_action == "charge" else Color("45e6ff")
	if now < _action_flash_until:
		aura.a = 0.18
		draw_circle(center, 27.0, aura)
	if _battle.shield_active or now < _shield_flash_until:
		draw_arc(center, 29.0, -2.2, 2.2, 32, Color("45e6ff"), 2.0)
		draw_arc(center, 25.0, -2.2, 2.2, 32, Color(0.27, 0.90, 1.0, 0.25), 1.0)
		for rune_index in 3:
			var rune_angle := float(now) / 340.0 + float(rune_index) * TAU / 3.0
			var rune_position := center + Vector2(cos(rune_angle), sin(rune_angle)) * 27.0
			draw_circle(rune_position, 2.0, Color("b9f7ff"))
	draw_circle(center + Vector2(0, -13), 9.0, Color("17152c"))
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-15, 27), center + Vector2(-10, -6), center + Vector2(0, -18),
		center + Vector2(10, -6), center + Vector2(15, 27),
	]), Color("29234b"))
	draw_arc(center + Vector2(0, -13), 9.0, 0, TAU, 24, Color("8d7dff"), 1.0)
	draw_circle(center + Vector2(-3, -13), 1.5, Color("45e6ff"))
	draw_circle(center + Vector2(3, -13), 1.5, Color("ff5fba"))
	draw_line(center + Vector2(-9, 3), center + Vector2(-20, 13), Color("8d7dff"), 3.0)
	draw_line(center + Vector2(9, 3), center + Vector2(20, 13), Color("8d7dff"), 3.0)
	if now < _action_flash_until:
		var hand_x := -21.0 if _last_action == "charge" else 21.0
		draw_circle(center + Vector2(hand_x, 13), 5.0, Color(aura, 0.72))


func _draw_boss() -> void:
	var now := Time.get_ticks_msec()
	var warning := _is_attack_bar(_bar_index) and not _finished
	var bob := sin(float(maxi(0, _song_time_ms)) / 500.0 * PI) * 2.0
	var center := Vector2(259, 77 + bob)
	if now < _boss_hit_until:
		center.x += -3.0 if now % 2 == 0 else 3.0
	if warning:
		var adjusted_time := maxi(0, _song_time_ms - _audio_offset_ms)
		var attack_progress := fmod(float(adjusted_time), float(BAR_MS)) / float(BAR_MS)
		draw_circle(center, 39.0 + attack_progress * 8.0, Color(1.0, 0.18, 0.35, 0.06 + attack_progress * 0.12))
		draw_arc(center, 35.0, -PI / 2.0, -PI / 2.0 + TAU * attack_progress, 40, Color("ff4f70"), 2.0)
	var phase_colors := [Color("4a215d"), Color("692851"), Color("7d203f")]
	var body_color: Color = phase_colors[_active_phase - 1] if now >= _boss_hit_until else Color("ff6b5e")
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-24, -8), center + Vector2(-13, -27), center + Vector2(0, -18),
		center + Vector2(14, -29), center + Vector2(25, -7), center + Vector2(19, 20),
		center + Vector2(0, 29), center + Vector2(-20, 18),
	]), body_color)
	draw_arc(center, 25.0, 0, TAU, 32, Color("ff5fba"), 2.0)
	draw_circle(center + Vector2(0, -5), 8.0, Color("100b22"))
	draw_circle(center + Vector2(0, -5), 4.0, Color("ff668e"))
	draw_line(center + Vector2(0, 18), center + Vector2(0, 34), Color("ffb65e"), 2.0)
	draw_circle(center + Vector2(0, 36), 4.0, Color("ffb65e"))
	if warning:
		var adjusted_time := maxi(0, _song_time_ms - _audio_offset_ms)
		var cue_index: int = _director.attack_cue_index(adjusted_time, _bar_index, _active_phase)
		var beat_phase := fmod(float(adjusted_time), BEAT_MS) / BEAT_MS
		for pip_index in 4:
			var pip_position := Vector2(241 + pip_index * 12, 117)
			var lit := pip_index <= cue_index
			var pip_color := Color("ff668e") if lit else Color("4d2944")
			pip_color.a = 0.94 if lit else 0.55
			var pip_size := 3.5 + (1.0 - beat_phase) * 1.2 if pip_index == cue_index else 3.0
			var pip := PackedVector2Array([
				pip_position + Vector2(0, -pip_size), pip_position + Vector2(pip_size, 0),
				pip_position + Vector2(0, pip_size), pip_position + Vector2(-pip_size, 0),
			])
			draw_colored_polygon(pip, pip_color)


func _draw_spell_effects() -> void:
	var now := Time.get_ticks_msec()
	if now < _skill_flash_until:
		var progress := clampf(1.0 - float(_skill_flash_until - now) / 620.0, 0.0, 1.0)
		match _last_skill:
			"fireball":
				var eased := 1.0 - pow(1.0 - progress, 2.0)
				var start := Vector2(82, 87)
				var target := Vector2(234, 77)
				var projectile := start.lerp(target, eased)
				for trail_index in 4:
					var trail_position := projectile.lerp(start, 0.05 + float(trail_index) * 0.055)
					var trail_color := Color("ff6b5e")
					trail_color.a = 0.34 - float(trail_index) * 0.065
					draw_circle(trail_position, 7.0 - float(trail_index), trail_color)
				draw_circle(projectile, 8.0, Color(1.0, 0.25, 0.18, 0.16))
				draw_circle(projectile, 4.0, Color("ffc45e"))
			"heal":
				for particle_index in 7:
					var phase := fmod(progress + float(particle_index) * 0.17, 1.0)
					var particle_position := Vector2(61 + sin(float(particle_index) * 2.3) * 18.0, 108 - phase * 54.0)
					var particle_color := Color("69f0a5")
					particle_color.a = sin(phase * PI) * 0.75
					draw_circle(particle_position, 2.0 + phase, particle_color)
	if now < _boss_attack_until:
		var strike_progress := clampf(1.0 - float(_boss_attack_until - now) / 520.0, 0.0, 1.0)
		var strike_head := Vector2(238, 74).lerp(Vector2(84, 91), strike_progress)
		var strike_color := Color("45e6ff") if now < _shield_flash_until else Color("ff4f70")
		strike_color.a = 0.78 * (1.0 - strike_progress * 0.55)
		draw_line(Vector2(238, 74), strike_head, strike_color, 3.0)
		draw_circle(strike_head, 5.0, Color(strike_color, 0.22))


func _draw_beat_ring() -> void:
	var center := Vector2(160, 82)
	var beat_phase := 0.0
	var current_ring_tick := -1
	var cycle_progress := 0.0
	var adjusted_time := maxi(0, _song_time_ms - _audio_offset_ms)
	if _song_time_ms >= 0:
		beat_phase = fmod(float(adjusted_time), BEAT_MS) / BEAT_MS
		cycle_progress = fmod(float(adjusted_time), float(BAR_MS)) / float(BAR_MS)
		current_ring_tick = int(floor(cycle_progress * 4.0))
	var radius := 22.0 + (1.0 - beat_phase) * 4.0
	draw_circle(center, radius, Color(0.06, 0.05, 0.14, 0.92))
	draw_arc(center, radius, 0, TAU, 40, Color(0.55, 0.49, 1.0, 0.34), 1.0)
	var beat_start_angle := -PI / 2.0 + float(current_ring_tick) * TAU / 4.0
	var head_angle := -PI / 2.0 + TAU * cycle_progress
	draw_arc(center, radius, beat_start_angle, head_angle, 10, Color("8d7dff"), 2.0)
	draw_circle(center + Vector2(cos(head_angle), sin(head_angle)) * radius, 2.4, Color("ffffff"))
	for marker_index in 4:
		var angle := -PI / 2.0 + float(marker_index) * TAU / 4.0
		var marker_position := center + Vector2(cos(angle), sin(angle)) * 16.0
		var marker_color := Color("dad7ff") if marker_index == current_ring_tick else Color("514a72")
		var marker_radius := 2.0 if marker_index == current_ring_tick else 1.5
		draw_circle(marker_position, marker_radius, marker_color)
	var displayed_events: Array = _command.display_events
	var active_trace := not displayed_events.is_empty() and _command.is_active()
	if displayed_events.is_empty():
		displayed_events = _recent_command
	var trace_alpha := InputTraceFade.alpha_for(displayed_events, adjusted_time, active_trace)
	for entry in displayed_events:
		var angle := -PI / 2.0 + float(entry.ring_phase) * TAU
		var input_position := center + Vector2(cos(angle), sin(angle)) * 10.0
		var target_angle := -PI / 2.0 + float(entry.ring_tick) * TAU / 4.0
		var target_position := center + Vector2(cos(target_angle), sin(target_angle)) * 10.0
		var missed: bool = entry.grade == "miss"
		var trace_color := Color("ff668e") if missed else Color("ffc45e") if entry.action == "step" else Color("45e6ff")
		trace_color.a = 0.32 * trace_alpha
		draw_line(target_position, input_position, trace_color, 1.0)
		if entry.action == "step":
			var step_color := Color("ff668e") if missed else Color("ffc45e")
			step_color.a = trace_alpha
			draw_circle(input_position, 3.0, step_color)
			if missed:
				var miss_outline := Color("ffb0c1")
				miss_outline.a = trace_alpha
				draw_arc(input_position, 4.5, 0, TAU, 12, miss_outline, 1.0)
		else:
			var diamond := PackedVector2Array([
				input_position + Vector2(0, -4), input_position + Vector2(4, 0),
				input_position + Vector2(0, 4), input_position + Vector2(-4, 0),
			])
			var finish_color := Color("ff668e") if missed else Color("45e6ff")
			finish_color.a = trace_alpha
			draw_colored_polygon(diamond, finish_color)
	if _command.broken:
		draw_line(center + Vector2(-7, -7), center + Vector2(7, 7), Color("ff668e"), 2.0)
		draw_line(center + Vector2(-7, 7), center + Vector2(7, -7), Color("ff668e"), 2.0)


func _draw_spell_cards() -> void:
	var font := ThemeDB.fallback_font
	var cards := ["fireball", "shield", "heal"]
	for card_index in cards.size():
		var skill: String = cards[card_index]
		var card_rect := Rect2(5 + card_index * 104, 130, 102, 32)
		var active := _last_skill == skill and Time.get_ticks_msec() < _skill_flash_until
		var teaching := _director.tutorial_skill(_bar_index) == skill and not _finished
		var color: Color = SKILL_COLORS[skill]
		draw_rect(card_rect, Color(0.05, 0.04, 0.12, 0.94))
		if teaching:
			draw_rect(card_rect.grow(2.0), Color(color, 0.13), true)
		draw_rect(card_rect, Color(color, 0.85 if active or teaching else 0.30), false, 2.0 if teaching else 1.0)
		draw_string(font, card_rect.position + Vector2(5, 11), SKILL_NAMES[skill], HORIZONTAL_ALIGNMENT_LEFT, 48, 7, color)
		var pattern: Array = DISPLAY_PATTERNS[skill]
		var pattern_end_x := 57.0 + float(pattern[-1].tick) * 14.0
		draw_line(card_rect.position + Vector2(57, 9), card_rect.position + Vector2(pattern_end_x, 9), Color("514a72"), 1.0)
		for pattern_tick in int(pattern[-1].tick) + 1:
			draw_circle(card_rect.position + Vector2(57 + float(pattern_tick) * 14.0, 9), 1.25, Color("514a72"))
		for pattern_event in pattern:
			var symbol_position := card_rect.position + Vector2(57 + float(pattern_event.tick) * 14.0, 9)
			if pattern_event.action == "step":
				draw_circle(symbol_position, 3.0, Color("ffc45e"))
			else:
				var diamond := PackedVector2Array([
					symbol_position + Vector2(0, -4), symbol_position + Vector2(4, 0),
					symbol_position + Vector2(0, 4), symbol_position + Vector2(-4, 0),
				])
				draw_colored_polygon(diamond, Color("45e6ff"))
		draw_string(font, card_rect.position + Vector2(5, 25), SKILL_EFFECTS[skill], HORIZONTAL_ALIGNMENT_LEFT, 48, 5, Color(color, 0.74))
		draw_string(font, card_rect.position + Vector2(55, 25), "D/F  ·  J/K", HORIZONTAL_ALIGNMENT_LEFT, 43, 5, Color("aaa6cc"))
	var tutorial_skill: String = _director.tutorial_skill(_bar_index)
	if not tutorial_skill.is_empty() and not _finished:
		draw_string(font, Vector2(111, 119), "PRACTICE · %s" % SKILL_NAMES[tutorial_skill], HORIZONTAL_ALIGNMENT_CENTER, 98, 6, SKILL_COLORS[tutorial_skill])


func _draw_feedback() -> void:
	if _finished:
		return
	if Time.get_ticks_msec() >= _feedback_until and _song_time_ms >= 0:
		return
	var font := ThemeDB.fallback_font
	var text := _feedback
	draw_string(font, Vector2(98, 36), text, HORIZONTAL_ALIGNMENT_CENTER, 124, 10, Color(0.02, 0.01, 0.06, 0.85))
	draw_string(font, Vector2(97, 35), text, HORIZONTAL_ALIGNMENT_CENTER, 124, 10, _feedback_color)


func _draw_footer() -> void:
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(0, 166, 320, 14), Color(0.02, 0.015, 0.055, 0.96))
	draw_string(font, Vector2(8, 176), "D/F STEP   J/K FINISH", HORIZONTAL_ALIGNMENT_LEFT, -1, 6, Color("aaa6cc"))
	draw_string(font, Vector2(203, 176), "P PAUSE  R RETRY  C CAL", HORIZONTAL_ALIGNMENT_LEFT, -1, 6, Color("777394"))


func _draw_count_in() -> void:
	var font := ThemeDB.fallback_font
	var count := clampi(int(ceil(float(-_song_time_ms) / BEAT_MS)), 1, 4)
	draw_circle(Vector2(160, 82), 30.0, Color(0.03, 0.02, 0.08, 0.94))
	draw_arc(Vector2(160, 82), 30.0, 0, TAU, 36, Color("8d7dff"), 2.0)
	draw_string(font, Vector2(143, 93), str(count), HORIZONTAL_ALIGNMENT_CENTER, 34, 28, Color("ffffff"))


func _draw_pause() -> void:
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(0, 24, 320, 100), Color(0.02, 0.01, 0.06, 0.82))
	draw_string(font, Vector2(100, 73), "PAUSED", HORIZONTAL_ALIGNMENT_CENTER, 120, 18, Color("ffffff"))
	draw_string(font, Vector2(100, 91), "P  RESUME", HORIZONTAL_ALIGNMENT_CENTER, 120, 7, Color("dad7ff"))


func _draw_result() -> void:
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(40, 43, 240, 76), Color(0.025, 0.02, 0.075, 0.96))
	draw_rect(Rect2(40, 43, 240, 76), _feedback_color, false, 1.0)
	draw_string(font, Vector2(56, 66), _result_text, HORIZONTAL_ALIGNMENT_CENTER, 208, 15, _feedback_color)
	draw_string(font, Vector2(75, 86), "COMBO %02d   BOSS %02d/%02d" % [_battle.combo, _battle.boss_hp, _battle.MAX_BOSS_HP], HORIZONTAL_ALIGNMENT_CENTER, 170, 8, Color("dad7ff"))
	draw_string(font, Vector2(93, 106), "R  BEGIN AGAIN", HORIZONTAL_ALIGNMENT_CENTER, 134, 8, Color("ffc45e"))
