extends RefCounted

const BattleModel = preload("res://scripts/beatspell/battle_model.gd")


func run() -> Array[String]:
	var failures: Array[String] = []
	var battle = BattleModel.new()
	_expect_equal(failures, battle.player_hp, 5, "player starts at full health")
	_expect_equal(failures, battle.boss_hp, 60, "boss starts with balanced health")
	battle.cast_spell("fireball", "perfect")
	_expect_equal(failures, battle.boss_hp, 58, "perfect fireball deals two damage")
	battle.cast_spell("fireball", "good")
	_expect_equal(failures, battle.boss_hp, 57, "good fireball deals one damage")
	battle.cast_spell("shield")
	var blocked: Dictionary = battle.boss_attack(2)
	_expect(failures, blocked.blocked and battle.player_hp == 5 and not battle.shield_active, "shield blocks one attack")
	battle.boss_attack(2)
	_expect_equal(failures, battle.player_hp, 3, "unblocked attack damages player")
	battle.cast_spell("heal", "perfect")
	_expect_equal(failures, battle.player_hp, 5, "healing restores up to maximum")
	while not battle.is_victory():
		battle.cast_spell("fireball", "perfect")
	_expect(failures, battle.boss_hp == 0, "boss health clamps at zero")
	var defeated = BattleModel.new()
	defeated.boss_attack(9)
	_expect(failures, defeated.is_defeat() and defeated.player_hp == 0, "player health clamps at zero")
	var prism := BattleModel.new(72)
	_expect_equal(failures, prism.boss_hp, 72, "custom boss starts with configured health")
	_expect_equal(failures, prism.max_boss_hp, 72, "custom maximum remains available to health bar and phase logic")
	_expect_equal(failures, BattleModel.new().max_boss_hp, 60, "old encounters retain sixty maximum health")
	_expect_equal(failures, BattleModel.new(0).max_boss_hp, 1, "invalid maximum clamps above zero")
	var armored_good: Dictionary = prism.cast_spell("fireball", "good", 0, -1)
	_expect_equal(failures, armored_good.amount, 1, "armored Good FLARE retains minimum one damage")
	var armored_perfect: Dictionary = prism.cast_spell("fireball", "perfect", 500, -1)
	_expect_equal(failures, armored_perfect.amount, 1, "armored Perfect FLARE loses one damage")
	var vulnerable: Dictionary = prism.cast_spell("fireball", "perfect", 1000, 1)
	_expect_equal(failures, vulnerable.amount, 3, "open stance grants one damage")
	prism = BattleModel.new(72)
	prism.exposed = true
	prism.resonance_ready = true
	var empowered: Dictionary = prism.cast_spell("fireball", "good", 0, -1)
	_expect_equal(failures, empowered.amount, 3, "stance modifier follows combined base and exposure/resonance before minimum floor")
	_expect_equal(failures, empowered.bonus, 3, "exposure and resonance bonuses remain separate from stance")
	_expect(failures, not prism.exposed and not prism.resonance_ready, "empowered FLARE consumes both existing bonuses")
	prism = BattleModel.new(2)
	prism.exposed = true
	prism.resonance_ready = true
	var overkill: Dictionary = prism.cast_spell("fireball", "perfect", 0, 1)
	_expect_equal(failures, overkill.amount, 2, "overkill reports only actual health removed")
	_expect_equal(failures, prism.total_damage, 2, "damage ledger caps damage at remaining health")
	prism.player_hp = 3
	prism.cast_spell("heal", "perfect", 0, -100)
	_expect_equal(failures, prism.player_hp, 5, "FLARE-only modifier never changes healing")
	return failures


func _expect(failures: Array[String], condition: bool, label: String) -> void:
	if not condition:
		failures.append(label)


func _expect_equal(failures: Array[String], actual: Variant, expected: Variant, label: String) -> void:
	if actual != expected:
		failures.append("%s: expected %s, got %s" % [label, expected, actual])
