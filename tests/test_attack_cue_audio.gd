extends RefCounted

const AttackCueAudioScript = preload("res://scripts/beatspell/attack_cue_audio.gd")
const BattleDirectorScript = preload("res://scripts/beatspell/battle_director.gd")
const SfxProfileScript = preload("res://scripts/beatspell/sfx_profile.gd")


func run() -> Array[String]:
	var failures: Array[String] = []
	var scheduler = AttackCueAudioScript.new()
	var safe: Dictionary = scheduler.next_cue(7, -1)
	_expect(failures, not safe.should_play, "safe bars never schedule warning audio")

	var first: Dictionary = scheduler.next_cue(8, 0)
	_expect(failures, first.should_play, "first attack beat schedules warning audio")
	var repeated: Dictionary = scheduler.next_cue(8, 0)
	_expect(failures, not repeated.should_play, "same beat is not replayed after a pause or extra frame")

	var second: Dictionary = scheduler.next_cue(8, 1)
	var third: Dictionary = scheduler.next_cue(8, 2)
	var final: Dictionary = scheduler.next_cue(8, 3)
	_expect(failures, second.should_play and third.should_play and final.should_play, "each new attack beat plays exactly once")
	_expect(failures, final.pitch_scale > third.pitch_scale, "final warning beat has a distinct higher pitch")

	var new_bar: Dictionary = scheduler.next_cue(12, 0)
	_expect(failures, new_bar.should_play, "the same cue index can play in a later attack bar")
	scheduler.reset()
	var after_reset: Dictionary = scheduler.next_cue(12, 0)
	_expect(failures, after_reset.should_play, "new runs reset warning deduplication")

	var director = BattleDirectorScript.new()
	scheduler.reset()
	var sync_first: Dictionary = scheduler.next_cue(14, director.attack_cue_index(28_000, 14, 2))
	var sync_rest: Dictionary = scheduler.next_cue(14, director.attack_cue_index(28_500, 14, 2))
	var sync_second: Dictionary = scheduler.next_cue(14, director.attack_cue_index(28_750, 14, 2))
	_expect(failures, sync_first.should_play, "syncopated first cue plays")
	_expect(failures, not sync_rest.should_play, "syncopated rest subdivisions do not replay the previous cue")
	_expect(failures, sync_second.should_play, "syncopated cue after a rest plays once")

	var profile = SfxProfileScript.new()
	_expect(failures, profile.volume_db("charge") < profile.volume_db("cast"), "step input is quieter than finish input")
	_expect(failures, profile.volume_db("cast") < profile.volume_db("fireball"), "successful spells stand above raw inputs")
	_expect(failures, profile.volume_db("warning") < profile.volume_db("boss"), "boss impact stands above warning pulses")
	_expect(failures, profile.duration("charge") < profile.duration("fireball"), "raw input is shorter than a skill sound")
	return failures


func _expect(failures: Array[String], condition: bool, label: String) -> void:
	if not condition:
		failures.append(label)
