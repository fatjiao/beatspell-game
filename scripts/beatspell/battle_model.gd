extends RefCounted

const MAX_PLAYER_HP := 5
const MAX_BOSS_HP := 36

var player_hp := MAX_PLAYER_HP
var boss_hp := MAX_BOSS_HP
var shield_active := false
var combo := 0


func cast_spell(skill: String, grade: String = "perfect") -> Dictionary:
	var result := {"skill": skill, "amount": 0}
	match skill:
		"fireball":
			var damage := 2 if grade == "perfect" else 1
			boss_hp = maxi(0, boss_hp - damage)
			combo += 1
			result.amount = damage
		"shield":
			shield_active = true
			combo += 1
			result.amount = 1
		"heal":
			var healing := 2 if grade == "perfect" else 1
			var previous_hp := player_hp
			player_hp = mini(MAX_PLAYER_HP, player_hp + healing)
			combo += 1
			result.amount = player_hp - previous_hp
		_:
			combo = 0
			result.skill = ""
	return result


func boss_attack(damage: int = 2) -> Dictionary:
	if shield_active:
		shield_active = false
		return {"blocked": true, "damage": 0}
	player_hp = maxi(0, player_hp - maxi(0, damage))
	combo = 0
	return {"blocked": false, "damage": damage}


func is_victory() -> bool:
	return boss_hp <= 0


func is_defeat() -> bool:
	return player_hp <= 0
