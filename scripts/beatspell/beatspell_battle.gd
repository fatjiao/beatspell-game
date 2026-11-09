extends Control

const BattleModelScript = preload("res://scripts/beatspell/battle_model.gd")
const BattleDirectorScript = preload("res://scripts/beatspell/battle_director.gd")
const AttackCueAudioScript = preload("res://scripts/beatspell/attack_cue_audio.gd")
const PerformanceTrackerScript = preload("res://scripts/beatspell/performance_tracker.gd")
const SfxProfileScript = preload("res://scripts/beatspell/sfx_profile.gd")
const SpellCommandBufferScript = preload("res://scripts/beatspell/spell_command_buffer.gd")
const TimingProfileScript = preload("res://scripts/beatspell/timing_profile.gd")
const InputTraceFade = preload("res://scripts/beatspell/input_trace_fade.gd")
const SettingsStore = preload("res://scripts/settings/settings_store.gd")
const SpritePose = preload("res://scripts/beatspell/sprite_pose.gd")
const PracticeDirector = preload("res://scripts/beatspell/practice_director.gd")
const Effects = preload("res://scripts/beatspell/pixel_effects.gd")
const Art = preload("res://scripts/beatspell/art_direction.gd")
const ARENA_ART = preload("res://assets/art/beatspell/pixel/observatory.png")
const CASTER_ART = preload("res://assets/art/beatspell/pixel/caster.png")
const BOSS_ART = preload("res://assets/art/beatspell/pixel/warden.png")

const BPM := TimingProfileScript.DEFAULT_BPM
const BEAT_MS := TimingProfileScript.DEFAULT_BEAT_MS
const BAR_MS := TimingProfileScript.DEFAULT_BAR_MS
const ATTACK_SUBDIVISION_MS := BattleDirectorScript.SUBDIVISION_MS
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

@onready var _overlay = $BattleOverlay

var _battle = BattleModelScript.new()
var _director = BattleDirectorScript.new()
var _attack_cue_audio = AttackCueAudioScript.new()
var _performance = PerformanceTrackerScript.new()
var _sfx_profile = SfxProfileScript.new()
var _timing = TimingProfileScript.new()
var _command = SpellCommandBufferScript.new(_timing)
var _music_players: Dictionary = {}
var _sfx_players: Dictionary = {}
var _options: Dictionary = {}
var _settings_path := SettingsStore.SETTINGS_PATH
var _options_open := false
var _guide_open := false
var _options_index := 0
var _practice_mode := false
var _practice_defense := false
var _break_flash_until := 0
var _empowered_flare := false
var _practice = PracticeDirector.new()
var _tutorial_casts := {"fireball": 0, "heal": 0, "shield": 0}
var _audio_ready := false
var _waiting_to_start := true
var _song_start_ticks := 0
var _song_time_ms := -2000
var _music_started := false
var _music_loop_offset_ms := 0
var _last_raw_clock_ms := 0
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
var _error_text := ""
var _stage_shake_until := 0
var _stage_shake_strength := 0.0


func _ready() -> void:
	_options = SettingsStore.load_settings(_settings_path)
	_timing.input_offset_ms = int(_options.audio_offset_ms)
	_audio_ready = _setup_music()
	_setup_sfx()
	_apply_options()
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_show_title()
	queue_redraw()


func _process(_delta: float) -> void:
	if _waiting_to_start or _finished:
		queue_redraw()
		return
	if _paused:
		queue_redraw()
		return
	if not _music_started:
		_song_time_ms = Time.get_ticks_msec() - _song_start_ticks
		_update_count_in_audio()
		_overlay.show_count_in(clampi(int(ceil(float(-_song_time_ms) / BEAT_MS)), 1, 4))
		if _song_time_ms >= 0 and _audio_ready:
			_start_music()
	else:
		_song_time_ms = _read_song_clock()
		_update_command()
		_update_bar()
		_update_attack_cue(_adjusted_song_time())
		if _song_time_ms >= BATTLE_DURATION_MS and not _finished and not _practice_mode:
			_finish_battle("RITUAL EXPIRED", false)
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	var is_key_press: bool = event is InputEventKey and event.pressed and not event.echo
	var is_button_press: bool = event is InputEventJoypadButton and event.pressed
	if not is_key_press and not is_button_press:
		return
	if _guide_open:
		if is_key_press and event.physical_keycode in [KEY_H, KEY_ESCAPE]:
			_guide_open = false
			_restore_menu_overlay()
		get_viewport().set_input_as_handled()
		return
	if _options_open:
		if is_key_press:
			_handle_options_input(event.physical_keycode)
		get_viewport().set_input_as_handled()
		return
	if is_key_press and event.physical_keycode == KEY_H:
		if not _waiting_to_start and not _paused and not _finished:
			_toggle_pause()
		_guide_open = true
		_overlay.show_guide()
		get_viewport().set_input_as_handled()
		return
	if is_key_press and event.physical_keycode == KEY_O:
		_open_options()
		get_viewport().set_input_as_handled()
		return
	if _practice_mode and is_key_press and event.physical_keycode == KEY_T and _practice.current_skill().is_empty():
		_practice_defense = not _practice_defense
		_battle.shield_active = false
		_show_feedback("DEFENSE DRILL" if _practice_defense else "FREE PRACTICE", Art.GOLD, 1500)
		get_viewport().set_input_as_handled()
		return
	if _waiting_to_start and is_key_press and event.physical_keycode == KEY_T:
		_start_run(true)
		get_viewport().set_input_as_handled()
		return
	if is_key_press and event.physical_keycode == KEY_C:
		get_tree().change_scene_to_file("res://scenes/settings/calibration.tscn")
		return
	if is_key_press and event.physical_keycode == KEY_ESCAPE:
		if _waiting_to_start:
			get_tree().quit()
		else:
			_show_title()
		get_viewport().set_input_as_handled()
		return
	if _waiting_to_start:
		if event.is_action_pressed("battle_cast") or (is_key_press and event.physical_keycode in [KEY_ENTER, KEY_SPACE]):
			_start_run()
			get_viewport().set_input_as_handled()
		return
	if is_key_press and event.physical_keycode == KEY_R:
		_start_run(_practice_mode)
		get_viewport().set_input_as_handled()
		return
	if is_key_press and event.physical_keycode == KEY_P:
		_toggle_pause()
		get_viewport().set_input_as_handled()
		return
	if _finished or _paused or _song_time_ms < 0 or not _music_started:
		return
	if event.is_action_pressed("battle_charge"):
		_register_action("charge")
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("battle_cast"):
		_register_action("cast")
		get_viewport().set_input_as_handled()


func _show_title() -> void:
	_guide_open = false
	_options_open = false
	_practice_mode = false
	_practice_defense = false
	_clear_visual_effects()
	for player in _sfx_players.values():
		player.stop()
	_waiting_to_start = true
	_finished = false
	_paused = false
	_music_started = false
	_song_time_ms = -2000
	_bar_index = -1
	_active_phase = 1
	_battle = BattleModelScript.new()
	_command.reset()
	_performance.reset()
	_recent_command.clear()
	_attack_cue_audio.reset()
	for player in _music_players.values():
		player.stop()
		player.stream_paused = false
	_overlay.show_title()
	queue_redraw()


func _start_run(practice: bool = false) -> void:
	_overlay.reset_effects()
	_practice_mode = practice
	_practice_defense = false
	_practice.reset()
	_tutorial_casts = {"fireball": 0, "heal": 0, "shield": 0}
	_clear_visual_effects()
	_waiting_to_start = false
	_battle = BattleModelScript.new()
	_song_start_ticks = Time.get_ticks_msec() + 2000
	_song_time_ms = -2000
	_music_loop_offset_ms = 0
	_last_raw_clock_ms = 0
	_music_started = false
	_bar_index = -1
	_active_phase = 1
	_command.reset()
	_performance.reset()
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
	_attack_cue_audio.reset()
	_stage_shake_until = 0
	_stage_shake_strength = 0.0
	for player in _music_players.values():
		player.stop()
		player.stream_paused = false
	_overlay.show_count_in(4)
	queue_redraw()


func _start_music() -> void:
	_music_started = true
	_song_time_ms = 0
	_bar_index = 0
	_command.reset()
	for player in _music_players.values():
		player.play(0.0)
	_overlay.hide_primary()
	_show_feedback("FORM A SPELL", Color("dad7ff"), 900)


func _update_bar() -> void:
	if _finished:
		return
	var adjusted_time := _adjusted_song_time()
	var new_bar := int(floor(float(adjusted_time) / float(BAR_MS)))
	if new_bar == _bar_index:
		return
	if _bar_index >= 0:
		_resolve_bar(_bar_index)
		if _finished:
			return
	_bar_index = new_bar
	if _practice_mode:
		return
	var next_phase: int = _director.phase_for_health(_battle.boss_hp, _battle.MAX_BOSS_HP)
	if _bar_index < 9:
		next_phase = 1
	if next_phase != _active_phase:
		_active_phase = next_phase
		var phase_color := Color("ff9a6b") if _active_phase == 2 else Color("ff4f70")
		_overlay.flash_phase(_active_phase, _director.phase_name(_active_phase), phase_color, 1050)
		_show_feedback("PHASE %d · %s" % [_active_phase, _director.phase_name(_active_phase)], Color("ff9a6b"), 1050)


func _update_command() -> void:
	if _finished:
		return
	var adjusted_time := _adjusted_song_time()
	if _command.expire_if_needed(adjusted_time):
		_battle.break_combo()
		_show_feedback("LOST THE PHRASE", Color("ff668e"), 620)
		_play_sfx("error")


func _register_action(action: String) -> void:
	if _music_started and not _paused:
		_song_time_ms = _read_song_clock()
	var adjusted_time := _adjusted_song_time()
	_update_command()
	_update_bar()
	if _finished:
		return
	_last_action = action
	_action_flash_until = Time.get_ticks_msec() + 150
	_play_sfx(action)
	if action == "charge":
		var step_result: Dictionary = _command.register_step(adjusted_time)
		_performance.record_input(step_result.event)
		return
	var result: Dictionary = _command.finish(adjusted_time)
	if not result.events.is_empty():
		_performance.record_input(result.events[-1])
	_performance.record_attempt(result.skill, result.grade)
	_recent_command = result.events.duplicate(true)
	if result.skill.is_empty():
		_battle.cast_spell("")
		_show_feedback("RHYTHM BROKE", Color("ff668e"), 620)
		_play_sfx("error")
		return
	_cast_skill(result.skill, result.grade)
	if _battle.is_victory() and not _practice_mode:
		_finish_battle("BEAST DISPELLED", true)


func _resolve_bar(resolved_bar: int) -> void:
	if _finished:
		return
	if _is_attack_bar(resolved_bar):
		_resolve_boss_attack((resolved_bar + 1) * BAR_MS)


func _cast_skill(skill: String, grade: String) -> void:
	_last_action = "cast"
	_action_flash_until = Time.get_ticks_msec() + 150
	var result: Dictionary = _battle.cast_spell(skill, grade, _adjusted_song_time())
	_tutorial_casts[skill] += 1
	if _practice_mode:
		_practice.record_cast(skill)
		_battle.player_hp = _battle.MAX_PLAYER_HP
		_battle.boss_hp = _battle.MAX_BOSS_HP
	_last_skill = skill
	_empowered_flare = skill == "fireball" and int(result.bonus) > 0
	_skill_flash_until = Time.get_ticks_msec() + 620
	_play_sfx(skill)
	match skill:
		"fireball":
			_boss_hit_until = Time.get_ticks_msec() + 420
			_trigger_stage_shake(2.8, 170)
			_show_feedback("%s -%d%s" % [SKILL_NAMES[skill], result.amount, " POWER" if result.bonus > 0 else ""], SKILL_COLORS[skill], 720)
		"shield":
			_shield_flash_until = Time.get_ticks_msec() + 850
			_show_feedback(SKILL_NAMES[skill], SKILL_COLORS[skill], 720)
		"heal":
			_show_feedback("%s  +%d" % [SKILL_NAMES[skill], result.amount], SKILL_COLORS[skill], 720)


func _resolve_boss_attack(impact_time_ms: int = -1) -> void:
	var impact := impact_time_ms if impact_time_ms >= 0 else _adjusted_song_time()
	var damage := 0 if _practice_mode else _director.attack_damage(_active_phase)
	var result: Dictionary = _battle.boss_attack(damage, impact)
	_boss_attack_until = Time.get_ticks_msec() + 520
	if result.blocked:
		_shield_flash_until = Time.get_ticks_msec() + 620
		_trigger_stage_shake(2.2, 180)
		_show_feedback("PERFECT GUARD" if result.perfect_guard else "BLOCKED", Art.TEAL, 760)
		_play_sfx("parry" if result.perfect_guard else "shield_block")
		if result.broke:
			_play_sfx("break")
			_break_flash_until = Time.get_ticks_msec() + 850
			_boss_hit_until = Time.get_ticks_msec() + 420
			_show_feedback("WARDEN EXPOSED", Art.GOLD, 1000)
	else:
		_trigger_stage_shake(4.5, 280)
		_show_feedback("BEAST STRIKE  -%d" % result.damage, Color("ff668e"), 820)
		_play_sfx("boss")
	if _battle.is_defeat():
		_finish_battle("RITUAL BROKEN", false)


func _is_attack_bar(bar: int) -> bool:
	if _practice_mode:
		return _practice_defense and bar >= 0 and (bar + 1) % 2 == 0
	return _director.is_attack_bar(bar, _active_phase)


func _adjusted_song_time() -> int:
	return _timing.adjusted_song_time(_song_time_ms)


func _trigger_stage_shake(strength: float, duration_ms: int) -> void:
	if not bool(_options.get("screen_shake", true)):
		return
	_stage_shake_strength = maxf(_stage_shake_strength, strength)
	_stage_shake_until = maxi(_stage_shake_until, Time.get_ticks_msec() + duration_ms)


func _stage_shake_offset() -> Vector2:
	if _paused or not bool(_options.get("screen_shake", true)):
		return Vector2.ZERO
	var remaining := _stage_shake_until - Time.get_ticks_msec()
	if remaining <= 0:
		_stage_shake_strength = 0.0
		return Vector2.ZERO
	var fade := clampf(float(remaining) / 280.0, 0.0, 1.0)
	var clock := float(Time.get_ticks_msec())
	return Vector2(sin(clock * 0.19), cos(clock * 0.23)) * _stage_shake_strength * fade


func _update_attack_cue(adjusted_time_ms: int) -> void:
	if _finished or not _is_attack_bar(_bar_index):
		return
	var cue_index: int = _attack_cue_index(adjusted_time_ms)
	var cue: Dictionary = _attack_cue_audio.next_cue(_bar_index, cue_index)
	if not cue.should_play:
		return
	var player: AudioStreamPlayer = _sfx_players.get("warning")
	if player != null:
		player.pitch_scale = cue.pitch_scale
		player.play()


func _show_feedback(text: String, color: Color, duration_ms: int) -> void:
	_feedback = text
	_feedback_color = color
	_feedback_until = Time.get_ticks_msec() + duration_ms


func _finish_battle(text: String, victory: bool) -> void:
	_finished = true
	_result_text = text
	_play_sfx("victory" if victory else "defeat")
	_feedback_color = Color("69f0a5") if victory else Color("ff668e")
	for player in _music_players.values():
		player.stream_paused = true
	_overlay.show_result(_result_overlay_data())


func _result_overlay_data() -> Dictionary:
	return {
		"title": _result_text,
		"color": _feedback_color,
		"rank": _performance.rank(),
		"successful_casts": _performance.successful_cast_count,
		"attempts": _performance.attempt_count,
		"perfect_casts": _performance.perfect_cast_count,
		"good_casts": _performance.good_cast_count,
		"failed_casts": _performance.failed_cast_count,
		"inputs": _performance.input_count,
		"average_offset_ms": _performance.average_absolute_offset_ms(),
		"timing_bias": _performance.timing_bias(),
		"boss_hp": _battle.boss_hp,
		"boss_max_hp": _battle.MAX_BOSS_HP,
		"max_combo": _battle.max_combo,
		"damage": _battle.total_damage,
		"healing": _battle.total_healing,
		"blocks": _battle.blocks,
		"perfect_guards": _battle.perfect_guards,
		"breaks": _battle.break_count,
		"duration_seconds": int(maxi(0, _song_time_ms) / 1000),
	}


func _toggle_pause() -> void:
	if _finished:
		return
	_paused = not _paused
	if _paused:
		_pause_started_ticks = Time.get_ticks_msec()
		_overlay.show_pause()
	else:
		var paused_duration := Time.get_ticks_msec() - _pause_started_ticks
		for field in ["_action_flash_until", "_skill_flash_until", "_boss_hit_until", "_boss_attack_until", "_shield_flash_until", "_feedback_until", "_stage_shake_until", "_break_flash_until"]:
			if int(get(field)) > _pause_started_ticks:
				set(field, int(get(field)) + paused_duration)
	if not _paused and not _music_started:
		_song_start_ticks += Time.get_ticks_msec() - _pause_started_ticks
		_overlay.show_count_in(clampi(int(ceil(float(-_song_time_ms) / BEAT_MS)), 1, 4))
	elif not _paused:
		_overlay.hide_primary()
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
		stream.loop = true
		var player := AudioStreamPlayer.new()
		player.stream = stream
		player.volume_db = MUSIC_VOLUMES[instrument]
		add_child(player)
		_music_players[instrument] = player
	return ready and _music_players.size() == MUSIC_FILES.size()


func _setup_sfx() -> void:
	for sound_name in ["charge", "cast", "fireball", "shield", "shield_block", "parry", "heal", "boss", "warning", "error", "count", "break", "victory", "defeat"]:
		var player := AudioStreamPlayer.new()
		player.stream = load("res://assets/sfx/beatspell/%s.wav" % sound_name)
		player.volume_db = _sfx_profile.volume_db(sound_name)
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


func _draw() -> void:
	var shake_offset := _stage_shake_offset()
	draw_set_transform(shake_offset)
	_draw_arena()
	_draw_player()
	_draw_boss()
	_draw_spell_effects()
	_draw_beat_ring()
	draw_set_transform(Vector2.ZERO)
	_draw_health()
	_draw_spell_cards()
	_draw_feedback()
	_draw_footer()
	if not _error_text.is_empty():
		draw_rect(Rect2(24, 72, 272, 34), Color(0.06, 0.03, 0.08, 0.95))
		Art.pixel_text(self, Vector2(32, 93), _error_text, HORIZONTAL_ALIGNMENT_CENTER, 256, 9, Color("ff668e"))


func _draw_arena() -> void:
	draw_texture_rect(ARENA_ART, Rect2(-5, -5, 330, 190), false)
	draw_rect(Rect2(0, 0, 320, 180), Color(0.015, 0.035, 0.045, 0.28))
	if _active_phase > 1:
		draw_rect(Rect2(0, 0, 320, 137), Color(0.25, 0.07, 0.015, 0.08 * float(_active_phase - 1)))
	draw_rect(Rect2(0, 0, 320, 27), Color(0.015, 0.035, 0.04, 0.89))
	draw_line(Vector2(12, 26), Vector2(308, 26), Color(Art.GOLD, 0.30), 0.5)
	draw_rect(Rect2(0, 137, 320, 43), Color(0.02, 0.045, 0.05, 0.95))
	draw_line(Vector2(12, 137), Vector2(308, 137), Color(Art.GOLD, 0.4), 0.5)
	for particle_index in 12:
		var clock := float(maxi(0, _song_time_ms))
		var point := Vector2(fmod(float(particle_index * 53) + clock / 130.0, 320.0), 35.0 + fmod(float(particle_index * 29) - clock / 270.0, 95.0))
		draw_circle(point, 0.35, Color(Art.GOLD, 0.28))

func _draw_health() -> void:
	Art.pixel_text(self, Vector2(16, 10), "THE CASTER", HORIZONTAL_ALIGNMENT_LEFT, 90, 5, Art.IVORY)
	Art.pixel_text(self, Vector2(214, 10), "RESONANT WARDEN", HORIZONTAL_ALIGNMENT_RIGHT, 90, 5, Art.IVORY)
	for side in 2:
		var x := 16.0 if side == 0 else 214.0
		var fraction := float(_battle.player_hp) / float(_battle.MAX_PLAYER_HP) if side == 0 else float(_battle.boss_hp) / float(_battle.MAX_BOSS_HP)
		var color := Art.TEAL if side == 0 else Art.EMBER
		draw_rect(Rect2(x, 14, 90, 3), Color("263739"))
		draw_rect(Rect2(x, 14, 90.0 * fraction, 3), color)
		draw_line(Vector2(x, 19), Vector2(x + 90, 19), Color(Art.GOLD, 0.35), 0.5)
		for tick in 6:
			draw_line(Vector2(x + tick * 18, 14), Vector2(x + tick * 18, 17), Color(Art.INK, 0.8), 0.5)
	var label := "AEGIS READY" if _battle.shield_active else "I  /  AWAKENING" if _active_phase == 1 else "II  /  FRACTURE" if _active_phase == 2 else "III  /  OVERDRIVE"
	if _practice_mode:
		label = "DEFENSE / NO DAMAGE" if _practice_defense else "PRACTICE / NO DAMAGE"
	Art.pixel_text(self, Vector2(111, 12), label, HORIZONTAL_ALIGNMENT_CENTER, 98, 5, Art.TEAL if _battle.shield_active else Art.GOLD)
	draw_circle(Vector2(160, 19), 1.1, Art.GOLD)
	for pip in 4:
		var ready: bool = _battle.resonance_ready or pip < _battle.combo % 4
		draw_rect(Rect2(16 + pip * 4, 21, 2, 2), Art.GOLD if ready else Color("263739"))
	Art.pixel_text(self, Vector2(37, 23), "COMBO %02d" % _battle.combo, HORIZONTAL_ALIGNMENT_LEFT, 65, 4, Art.GOLD if _battle.resonance_ready else Art.MUTED)
	for pip in 3:
		draw_rect(Rect2(214 + pip * 5, 21, 3, 2), Art.GOLD if _battle.exposed or pip < _battle.fracture else Color("263739"))
	Art.pixel_text(self, Vector2(237, 23), "EXPOSED" if _battle.exposed else "FRACTURE", HORIZONTAL_ALIGNMENT_RIGHT, 67, 4, Art.GOLD if _battle.exposed else Art.MUTED)


func _draw_player() -> void:
	var now := _visual_now()
	var breath := sin(float(now) / 550.0)
	var lift := -2.0 if now < _action_flash_until else breath * 0.7
	draw_ellipse_shadow(Vector2(58, 126), Vector2(24, 3))
	var tint := Color(1.3, 1.15, 1.0) if now < _action_flash_until else Color.WHITE
	var pose: Rect2 = SpritePose.caster(Rect2(24, roundf(39 + lift), 72, 96), now - (_action_flash_until - 150), _last_action)
	draw_texture_rect(CASTER_ART, pose, false, tint)
	if _battle.shield_active or now < _shield_flash_until:
		Effects.sprite(self, Vector2(85, 86), Effects.BARRIER)
		draw_arc(Vector2(60, 86), 32, -1.45, 1.45, 48, Color(Art.TEAL, 0.85), 1.0, true)
		draw_arc(Vector2(60, 86), 34, -1.3, 1.3, 48, Color(Art.TEAL, 0.2), 0.5, true)
		for rune in 3:
			var angle := -0.9 + float(rune) * 0.9
			var point := Vector2(60, 86) + Vector2(cos(angle), sin(angle)) * 32
			draw_circle(point, 1.2, Art.IVORY)
	if now < _action_flash_until:
		Effects.sprite(self, Vector2(83, 80), Effects.ORB)

func draw_ellipse_shadow(center: Vector2, extent: Vector2) -> void:
	var points := PackedVector2Array()
	for index in 32:
		var angle := float(index) * TAU / 32.0
		points.append(center + Vector2(cos(angle) * extent.x, sin(angle) * extent.y))
	draw_colored_polygon(points, Color(0.005, 0.015, 0.02, 0.50))

func _draw_boss() -> void:
	var now := _visual_now()
	var warning := _is_attack_bar(_bar_index) and not _finished
	var bob := roundf(sin(float(maxi(0, _song_time_ms)) / 500.0 * PI) * 2.0)
	var center := Vector2(259, 77 + bob)
	if now < _boss_hit_until:
		center.x += -3.0 if now % 2 == 0 else 3.0
	if warning:
		var warning_color := _attack_pattern_color()
		var adjusted_time := _adjusted_song_time()
		var attack_progress := fmod(float(adjusted_time), float(BAR_MS)) / float(BAR_MS)
		var warning_aura := warning_color
		warning_aura.a = 0.06 + attack_progress * 0.12
		draw_circle(center, 39.0 + attack_progress * 8.0, warning_aura)
		draw_arc(center, 35.0, -PI / 2.0, -PI / 2.0 + TAU * attack_progress, 40, warning_color, 2.0)
	draw_ellipse_shadow(Vector2(260, 128), Vector2(27, 3))
	var tint := Color(1.5, 1.2, 1.0) if now < _boss_hit_until else Color.WHITE
	if _battle.exposed:
		draw_arc(center, 37, 0, TAU, 40, Color(Art.GOLD, 0.4), 1.0)
	if now < _break_flash_until:
		var progress := clampf(float(now - (_break_flash_until - 850)) / 850.0, 0, 1)
		for fragment in 8:
			var angle := float(fragment) * TAU / 8
			var location := center + Vector2(cos(angle), sin(angle)) * (25 + progress * 21)
			draw_line(location, location + Vector2(cos(angle + 0.8), sin(angle + 0.8)) * 5, Color(Art.GOLD, 1.0 - progress), 2.0)
	var pose: Rect2 = SpritePose.boss(Rect2(center.x - 49, center.y - 47, 98, 93), now - (_boss_attack_until - 520), now - (_boss_hit_until - 420))
	draw_texture_rect(BOSS_ART, pose, false, tint)
	if now < _boss_hit_until:
		var burst_progress := clampf(float(now - (_boss_hit_until - 420)) / 420.0, 0.0, 1.0)
		for spark in 9:
			var angle := float(spark) * TAU / 9.0
			var point := center + Vector2(cos(angle), sin(angle)) * (10.0 + burst_progress * 29.0)
			draw_rect(Rect2(point.round(), Vector2(2, 2)), Color(Art.GOLD, 1.0 - burst_progress))

	if warning:
		var warning_color := _attack_pattern_color()
		var adjusted_time := _adjusted_song_time()
		var cue_index: int = _attack_cue_index(adjusted_time)
		var cue_steps: Array = _director.attack_cue_steps(_bar_index, _active_phase)
		var time_in_bar := adjusted_time - _bar_index * BAR_MS
		var current_step := clampi(int(floor(float(time_in_bar) / float(ATTACK_SUBDIVISION_MS))), 0, 7)
		var subdivision_phase := fmod(float(time_in_bar), float(ATTACK_SUBDIVISION_MS)) / float(ATTACK_SUBDIVISION_MS)
		for subdivision in 8:
			var pip_position := Vector2(224 + subdivision * 10, 130)
			var cue_ordinal := cue_steps.find(subdivision)
			if cue_ordinal < 0:
				draw_circle(pip_position, 1.15, Color(0.30, 0.16, 0.27, 0.62))
				continue
			var lit: bool = cue_ordinal <= cue_index
			var is_current_cue: bool = subdivision == current_step and cue_ordinal == cue_index
			var pip_color := warning_color if lit else Color("4d2944")
			pip_color.a = 0.96 if lit else 0.58
			var pip_size := 3.0
			if is_current_cue:
				pip_size += (1.0 - subdivision_phase) * 1.5
			var pip := PackedVector2Array([
				pip_position + Vector2(0, -pip_size), pip_position + Vector2(pip_size, 0),
				pip_position + Vector2(0, pip_size), pip_position + Vector2(-pip_size, 0),
			])
			draw_colored_polygon(pip, pip_color)
		var playhead_x := 224.0 + float(current_step) * 10.0
		draw_line(Vector2(playhead_x - 3.0, 135), Vector2(playhead_x + 3.0, 135), warning_color.lightened(0.24), 1.0)


func _attack_pattern_color() -> Color:
	match _director.attack_pattern(_bar_index, _active_phase):
		"syncopated":
			return Color("ff7f66")
		"rush":
			return Color("ffc45e")
	return Color("ff668e")


func _draw_spell_effects() -> void:
	var now := _visual_now()
	if now < _skill_flash_until:
		var age := 620 - (_skill_flash_until - now)
		match _last_skill:
			"fireball":
				var start := Vector2(82, 87)
				var target := Vector2(243, 76)
				if age < 180:
					var progress := clampf(float(age) / 180.0, 0.0, 1.0)
					var projectile := start.lerp(target, progress)
					for trail in 6:
						var point := projectile - Vector2(4 + trail * 4, 0)
						draw_rect(Rect2(point.round(), Vector2(2, 1)), Color(Art.EMBER, 0.65 - trail * 0.08))
					Effects.fireball(self, projectile, int(age / 45), _empowered_flare)
				else:
					var progress := clampf(float(age - 180) / 440.0, 0, 1)
					Effects.burst(self, target, progress, Art.GOLD if _empowered_flare else Art.EMBER, 16 if _empowered_flare else 10)
			"heal":
				for particle in 7:
					var phase := fmod(float(age) / 620.0 + float(particle) * 0.17, 1.0)
					var point := Vector2(61 + sin(float(particle) * 2.3) * 18, 115 - phase * 55)
					Effects.heal_cross(self, point, sin(phase * PI) * 0.8)
			"shield":
				if age < 220:
					for point in 8:
						var angle := float(point) * TAU / 8
						Effects.heal_cross(self, Vector2(61, 86) + Vector2(cos(angle), sin(angle)) * (16 + float(age) / 22), 1.0 - float(age) / 220)
	if now < _boss_attack_until:
		var progress := clampf(1.0 - float(_boss_attack_until - now) / 520.0, 0, 1)
		var head := Vector2(238, 74).lerp(Vector2(84, 91), minf(progress * 2, 1))
		var color := Art.TEAL if now < _shield_flash_until else Art.EMBER
		for fragment in 8:
			var point := head.lerp(Vector2(238, 74), float(fragment) * 0.10)
			draw_rect(Rect2(point.round(), Vector2(4 - fragment % 3, 2)), Color(color, 0.8 - fragment * 0.08))
		if progress > 0.35:
			Effects.burst(self, Vector2(84, 91), (progress - 0.35) / 0.65, color)


func _draw_beat_ring() -> void:
	var center := Vector2(160, 82)
	var beat_phase := 0.0
	var current_ring_tick := -1
	var cycle_progress := 0.0
	var adjusted_time := _adjusted_song_time()
	if _song_time_ms >= 0:
		beat_phase = fmod(float(adjusted_time), BEAT_MS) / BEAT_MS
		cycle_progress = fmod(float(adjusted_time), float(BAR_MS)) / float(BAR_MS)
		current_ring_tick = int(floor(cycle_progress * 4.0))
	var radius := 25.0 + (1.0 - beat_phase) * 1.3
	draw_arc(center, 30, 0, TAU, 80, Color(Art.GOLD, 0.25), 0.5, true)
	for tick in 48:
		var angle := float(tick) * TAU / 48.0
		var outer := center + Vector2(cos(angle), sin(angle)) * 30.0
		var inner := center + Vector2(cos(angle), sin(angle)) * (28.0 if tick % 12 == 0 else 29.0)
		draw_line(inner, outer, Color(Art.GOLD, 0.50), 0.5, true)
	draw_circle(center, radius, Color(0.02, 0.05, 0.06, 0.86))
	draw_arc(center, radius, 0, TAU, 40, Color(Art.GOLD, 0.55), 0.5)
	var beat_start_angle := -PI / 2.0 + float(current_ring_tick) * TAU / 4.0
	var head_angle := -PI / 2.0 + TAU * cycle_progress
	draw_arc(center, radius, beat_start_angle, head_angle, 10, Art.GOLD, 1.0)
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
	var skills := ["fireball", "shield", "heal"]
	var colors := [Art.EMBER, Art.TEAL, Color("b3c68f")]
	for index in 3:
		var skill: String = skills[index]
		var rect := Rect2(15 + index * 98, 141, 94, 27)
		var active := _last_skill == skill and Time.get_ticks_msec() < _skill_flash_until
		var teaching := _teaching_skill() == skill and not _finished
		var color: Color = colors[index]
		Art.panel(self, rect, color, active or teaching)
		Art.sigil(self, rect.position + Vector2(12, 13), skill, 7, color)
		Art.pixel_text(self, rect.position + Vector2(24, 10), SKILL_NAMES[skill], HORIZONTAL_ALIGNMENT_LEFT, 65, 6, Art.IVORY)
		var pattern: Array = DISPLAY_PATTERNS[skill]
		for tick in 3:
			draw_circle(rect.position + Vector2(27 + tick * 12, 19), 0.7, Color(Art.GOLD, 0.35))
		for entry in pattern:
			var point := rect.position + Vector2(27 + float(entry.tick) * 12, 19)
			if entry.action == "step":
				draw_circle(point, 1.7, Art.GOLD)
			else:
				draw_colored_polygon(PackedVector2Array([point + Vector2(0, -2.4), point + Vector2(2.4, 0), point + Vector2(0, 2.4), point + Vector2(-2.4, 0)]), Art.TEAL)
		Art.pixel_text(self, rect.position + Vector2(64, 20), SKILL_EFFECTS[skill], HORIZONTAL_ALIGNMENT_RIGHT, 25, 4, color)

func _draw_feedback() -> void:
	if _finished:
		return
	if Time.get_ticks_msec() >= _feedback_until and _song_time_ms >= 0:
		return
	var text := _feedback
	draw_rect(Rect2(107, 29, 106, 12), Color(0.02, 0.045, 0.05, 0.8))
	Art.pixel_text(self, Vector2(109, 37), text, HORIZONTAL_ALIGNMENT_CENTER, 102, 6, Art.IVORY)


func _draw_footer() -> void:
	Art.pixel_text(self, Vector2(16, 177), "D/F  STEP    J/K  CAST", HORIZONTAL_ALIGNMENT_LEFT, 120, 4, Art.MUTED)
	if _practice_mode:
		var focus: String = _practice.current_skill()
		var hint := ("T FREE / GUARD THE PULSE" if _practice_defense else "T DEFENSE / ESC TITLE") if focus.is_empty() else "%s %d/2 / ESC TITLE" % [SKILL_NAMES[focus], _practice.counts[focus]]
		Art.pixel_text(self, Vector2(183, 177), hint, HORIZONTAL_ALIGNMENT_RIGHT, 121, 4, Art.GOLD)
	else:
		var focus: String = _teaching_skill()
		var hint := "P PAUSE  O OPTIONS  R RETRY" if focus.is_empty() else "PRACTICE %s / CAST %d" % [SKILL_NAMES[focus], _tutorial_casts[focus]]
		Art.pixel_text(self, Vector2(177, 177), hint, HORIZONTAL_ALIGNMENT_RIGHT, 127, 4, Art.MUTED)

func _teaching_skill() -> String:
	return _practice.current_skill() if _practice_mode else _director.tutorial_skill(_bar_index)


func _read_song_clock() -> int:
	var clock: AudioStreamPlayer = _music_players.get("drums")
	if clock == null:
		return _song_time_ms
	var raw_time := int(maxf(0.0, (clock.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()) * 1000.0))
	if raw_time < _last_raw_clock_ms - 1000:
		_music_loop_offset_ms += int(round(clock.stream.get_length() * 1000.0))
	_last_raw_clock_ms = raw_time
	return _music_loop_offset_ms + raw_time


func _clear_visual_effects() -> void:
	_action_flash_until = 0
	_skill_flash_until = 0
	_boss_hit_until = 0
	_boss_attack_until = 0
	_shield_flash_until = 0
	_stage_shake_until = 0
	_empowered_flare = false
	_break_flash_until = 0
	_last_action = ""
	_last_skill = ""


func _apply_options() -> void:
	for instrument in _music_players:
		_music_players[instrument].volume_db = MUSIC_VOLUMES[instrument] + _volume_gain(float(_options.music_volume))
	for sound_name in _sfx_players:
		_sfx_players[sound_name].volume_db = _sfx_profile.volume_db(sound_name) + _volume_gain(float(_options.sfx_volume))
	if DisplayServer.get_name() != "headless":
		var target_mode := DisplayServer.WINDOW_MODE_FULLSCREEN if _options.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
		if DisplayServer.window_get_mode() != target_mode:
			DisplayServer.window_set_mode(target_mode)


func _volume_gain(value: float) -> float:
	return linear_to_db(value) if value > 0.0 else -80.0


func _open_options() -> void:
	if not _waiting_to_start and not _paused and not _finished:
		_toggle_pause()
	_options_open = true
	_overlay.show_options(_options, _options_index)


func _handle_options_input(key: int) -> void:
	if key in [KEY_ESCAPE, KEY_O]:
		_options_open = false
		if _waiting_to_start:
			_overlay.show_title()
		elif _finished:
			_overlay.show_result(_result_overlay_data())
		else:
			_overlay.show_pause()
		return
	if key == KEY_UP:
		_options_index = posmod(_options_index - 1, 4)
	elif key == KEY_DOWN:
		_options_index = posmod(_options_index + 1, 4)
	elif key in [KEY_LEFT, KEY_RIGHT, KEY_ENTER, KEY_SPACE]:
		var direction := -1.0 if key == KEY_LEFT else 1.0
		var option: String = ["music_volume", "sfx_volume", "screen_shake", "fullscreen"][_options_index]
		if _options_index < 2:
			_options[option] = snappedf(clampf(float(_options[option]) + direction * 0.1, 0.0, 1.0), 0.1)
		else:
			_options[option] = not bool(_options[option])
		_apply_options()
		var save_error := SettingsStore.save_settings(_options, _settings_path)
		if save_error != OK:
			_show_feedback("SETTINGS SAVE FAILED", Art.EMBER, 2000)
	_overlay.show_options(_options, _options_index)


func _visual_now() -> int:
	return _pause_started_ticks if _paused else Time.get_ticks_msec()

func _attack_cue_index(time_ms: int) -> int:
	return _director.attack_cue_index(time_ms, _bar_index, _active_phase, _practice_mode and _practice_defense)


func _restore_menu_overlay() -> void:
	if _waiting_to_start:
		_overlay.show_title()
	elif _finished:
		_overlay.show_result(_result_overlay_data())
	else:
		_overlay.show_pause()
