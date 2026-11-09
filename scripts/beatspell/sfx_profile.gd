extends RefCounted

const VOLUME_DB := {
	"parry": -4.0,
	"charge": -17.0,
	"cast": -13.0,
	"count": -14.0,
	"warning": -11.0,
	"error": -9.0,
	"shield": -6.0,
	"heal": -6.0,
	"fireball": -5.0,
	"shield_block": -4.0,
	"boss": -3.0,
}

const DURATION_SECONDS := {
	"parry": 0.18,
	"charge": 0.055,
	"cast": 0.075,
	"count": 0.035,
	"warning": 0.085,
	"error": 0.13,
	"shield": 0.32,
	"heal": 0.40,
	"fireball": 0.30,
	"shield_block": 0.20,
	"boss": 0.30,
}

const SAMPLE_GAIN := {
	"parry": 0.32,
	"charge": 0.20,
	"cast": 0.24,
	"count": 0.23,
	"warning": 0.26,
	"error": 0.27,
	"shield": 0.32,
	"heal": 0.32,
	"fireball": 0.34,
	"shield_block": 0.35,
	"boss": 0.36,
}


func volume_db(kind: String) -> float:
	return float(VOLUME_DB.get(kind, -10.0))


func duration(kind: String) -> float:
	return float(DURATION_SECONDS.get(kind, 0.10))


func sample_gain(kind: String) -> float:
	return float(SAMPLE_GAIN.get(kind, 0.28))
