extends RefCounted

const MAX_PLAYER_HP := 5
const MAX_BOSS_HP := 60
const PARRY_WINDOW_MS := 600
const BREAK_THRESHOLD := 3
const RESONANCE_INTERVAL := 4

var player_hp := MAX_PLAYER_HP
var boss_hp := MAX_BOSS_HP
var shield_active := false
var combo := 0
var max_combo := 0
var fracture := 0
var exposed := false
var resonance_ready := false
var total_damage := 0
var total_healing := 0
var damage_taken := 0
var blocks := 0
var perfect_guards := 0
var break_count := 0
var _shield_cast_ms := -1
var _shield_perfect := false


func cast_spell(skill: String, grade: String = "perfect", song_time_ms: int = -1) -> Dictionary:
	var result := {"skill": skill, "amount": 0, "bonus": 0}
	if skill not in ["fireball", "shield", "heal"] or grade not in ["perfect", "good"]:
		break_combo()
		result.skill = ""
		return result
	match skill:
		"fireball":
			var bonus := (2 if exposed else 0) + (1 if resonance_ready else 0)
			var damage := (2 if grade == "perfect" else 1) + bonus
			var previous_hp := boss_hp
			boss_hp = maxi(0, boss_hp - damage)
			result.amount = previous_hp - boss_hp
			result.bonus = bonus
			total_damage += int(result.amount)
			exposed = false
			resonance_ready = false
		"shield":
			shield_active = true
			_shield_cast_ms = song_time_ms
			_shield_perfect = grade == "perfect"
			result.amount = 1
		"heal":
			var healing := 2 if grade == "perfect" else 1
			var previous_hp := player_hp
			player_hp = mini(MAX_PLAYER_HP, player_hp + healing)
			result.amount = player_hp - previous_hp
			total_healing += int(result.amount)
	combo += 1
	max_combo = maxi(max_combo, combo)
	if combo % RESONANCE_INTERVAL == 0:
		resonance_ready = true
	return result


func boss_attack(damage: int = 2, impact_time_ms: int = -1) -> Dictionary:
	var result := {"blocked": false, "damage": 0, "perfect_guard": false, "broke": false}
	if shield_active:
		shield_active = false
		blocks += 1
		var age := impact_time_ms - _shield_cast_ms
		var precise := _shield_perfect and _shield_cast_ms >= 0 and impact_time_ms >= 0 and age >= 0 and age <= PARRY_WINDOW_MS
		result.blocked = true
		result.perfect_guard = precise
		if precise:
			perfect_guards += 1
		if not exposed:
			fracture += 2 if precise else 1
			if fracture >= BREAK_THRESHOLD:
				fracture = 0
				exposed = true
				break_count += 1
				result.broke = true
		return result
	var previous_hp := player_hp
	player_hp = maxi(0, player_hp - maxi(0, damage))
	result.damage = previous_hp - player_hp
	damage_taken += int(result.damage)
	break_combo()
	return result


func break_combo() -> void:
	combo = 0
	resonance_ready = false


func is_victory() -> bool:
	return boss_hp <= 0


func is_defeat() -> bool:
	return player_hp <= 0
