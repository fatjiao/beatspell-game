extends RefCounted

const BattleModel = preload("res://scripts/beatspell/battle_model.gd")


func run() -> Array[String]:
	var failures: Array[String] = []
	var battle = BattleModel.new()
	_expect_equal(failures, battle.player_hp, 5, "player starts at full health")
	_expect_equal(failures, battle.boss_hp, 36, "boss starts with demo health")
	battle.cast_spell("fireball", "perfect")
	_expect_equal(failures, battle.boss_hp, 34, "perfect fireball deals two damage")
	battle.cast_spell("fireball", "good")
	_expect_equal(failures, battle.boss_hp, 33, "good fireball deals one damage")
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
	return failures


func _expect(failures: Array[String], condition: bool, label: String) -> void:
	if not condition:
		failures.append(label)


func _expect_equal(failures: Array[String], actual: Variant, expected: Variant, label: String) -> void:
	if actual != expected:
		failures.append("%s: expected %s, got %s" % [label, expected, actual])
