extends RefCounted

const Model = preload("res://scripts/beatspell/battle_model.gd")


func run() -> Array[String]:
	var failures: Array[String] = []
	for age in [0, 445, 555, 600, 601, -1]:
		var model = Model.new()
		model.cast_spell("shield", "perfect", 2000 - age)
		var result: Dictionary = model.boss_attack(2, 2000)
		_check(failures, result.blocked, "AEGIS blocks at age %d" % age)
		_check(failures, result.perfect_guard == (age >= 0 and age <= 600), "precise boundary at age %d" % age)
	var legacy = Model.new()
	legacy.cast_spell("shield")
	_check(failures, not legacy.boss_attack(2).perfect_guard, "untimed legacy shield cannot parry")
	var good = Model.new()
	good.cast_spell("shield", "good", 1500)
	_check(failures, not good.boss_attack(2, 2000).perfect_guard, "Good shield remains a normal block")
	var battle = Model.new()
	battle.cast_spell("shield", "perfect", 1500)
	battle.boss_attack(2, 2000)
	_check(failures, battle.fracture == 2, "precise guard earns two fracture segments")
	battle.cast_spell("shield", "good", 3000)
	var broken: Dictionary = battle.boss_attack(2, 4000)
	_check(failures, broken.broke and battle.exposed and battle.break_count == 1, "third segment exposes boss")
	var empowered: Dictionary = battle.cast_spell("fireball")
	_check(failures, empowered.amount == 4 and not battle.exposed, "exposure grants one +2 fireball")
	_check(failures, battle.cast_spell("fireball").amount == 2, "exposure cannot apply twice")
	_check(failures, battle.resonance_ready, "fourth successful cast primes resonance after effect")
	_check(failures, battle.cast_spell("fireball").amount == 3, "primed resonance adds one damage")
	battle.cast_spell("")
	_check(failures, battle.combo == 0 and not battle.resonance_ready and battle.max_combo == 5, "failure clears reward but preserves max combo")
	var capped = Model.new()
	capped.boss_hp = 1
	_check(failures, capped.cast_spell("fireball").amount == 1 and capped.total_damage == 1, "damage report matches remaining boss HP")
	capped.player_hp = 1
	_check(failures, capped.boss_attack(9).damage == 1 and capped.damage_taken == 1, "incoming damage matches remaining HP")
	capped.cast_spell("heal")
	_check(failures, capped.total_healing == 2, "healing ledger records effective healing")
	var stacked = Model.new()
	stacked.exposed = true
	stacked.resonance_ready = true
	_check(failures, stacked.cast_spell("fireball").amount == 5, "exposure and resonance stack on one fireball")
	_check(failures, not stacked.exposed and not stacked.resonance_ready, "both bonuses are consumed")
	stacked.resonance_ready = true
	stacked.boss_attack(1)
	_check(failures, not stacked.resonance_ready, "unblocked hit clears pending resonance")
	return failures


func _check(failures: Array[String], condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
