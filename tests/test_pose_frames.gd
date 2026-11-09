extends RefCounted

const SpritePose = preload("res://scripts/beatspell/sprite_pose.gd")
const ROOT := "res://assets/art/beatspell/pixel/poses/"


func run() -> Array[String]:
	var failures: Array[String] = []
	_expect(failures, SpritePose.caster_frame(-1, "cast") == "idle", "future action stays idle")
	_expect(failures, SpritePose.caster_frame(0, "charge") == "charge", "charge starts immediately")
	_expect(failures, SpritePose.caster_frame(319, "cast") == "cast", "cast holds through its duration")
	_expect(failures, SpritePose.caster_frame(320, "cast") == "idle", "cast returns to idle at boundary")
	_expect(failures, SpritePose.boss_frame(0, true) == "strike", "strike overrides windup")
	_expect(failures, SpritePose.boss_frame(339, false) == "strike", "strike holds through its duration")
	_expect(failures, SpritePose.boss_frame(340, true) == "windup", "warning resumes after strike")
	_expect(failures, SpritePose.boss_frame(340, false) == "idle", "boss returns to idle")
	for family in [{"names": ["caster_idle", "caster_charge", "caster_cast"], "size": Vector2i(48, 64)}, {"names": ["warden_idle", "warden_windup", "warden_strike"], "size": Vector2i(72, 72)}]:
		var fingerprints: Array[int] = []
		for name in family.names:
			var texture := load(ROOT + name + ".png") as Texture2D
			if texture == null:
				failures.append("missing pose texture: " + name)
				continue
			var frame := texture.get_image()
			_expect(failures, frame.get_size() == family.size, name + " uses the shared canvas")
			_expect(failures, frame.get_pixel(0, 0).a == 0.0, name + " retains transparent margin")
			var fingerprint := hash(frame.get_data())
			_expect(failures, fingerprint not in fingerprints, name + " has distinct pose pixels")
			fingerprints.append(fingerprint)
	return failures


func _expect(failures: Array[String], condition: bool, label: String) -> void:
	if not condition:
		failures.append(label)
