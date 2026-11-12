extends RefCounted

const Bank = preload("res://scripts/beatspell/sound_bank.gd")

const VOLUME_DB := {
	"prism_warning": -10.0, "prism_strike": -5.0, "prism_shift": -14.0,
	"break": -5.0,
	"victory": -9.0,
	"defeat": -10.0,
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

func volume_db(kind: String) -> float:
	return float(VOLUME_DB.get(kind, -10.0))


func duration(kind: String) -> float:
	return float(Bank.SOUNDS.get(kind, 0.10))
