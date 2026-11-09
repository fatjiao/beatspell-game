extends RefCounted


static func caster_frame(age_ms: int, action: String) -> String:
	if age_ms < 0 or age_ms >= 320 or action not in ["charge", "cast"]:
		return "idle"
	return action


static func boss_frame(strike_age_ms: int, winding_up: bool) -> String:
	if strike_age_ms >= 0 and strike_age_ms < 340:
		return "strike"
	return "windup" if winding_up else "idle"


static func caster(base: Rect2, age_ms: int, action: String) -> Rect2:
	if age_ms < 0 or age_ms >= 320:
		return base
	var offset := Vector2.ZERO
	var stretch := Vector2.ZERO
	if action == "charge":
		var weight := 1.0 - float(age_ms) / 320.0
		offset = Vector2(-2, 2) * weight
		stretch = Vector2(2, -3) * weight
	else:
		var weight := sin(clampf(float(age_ms) / 320.0, 0, 1) * PI)
		offset = Vector2(6, -2) * weight
		stretch = Vector2(-2, 3) * weight
	return Rect2((base.position + offset - stretch * 0.5).round(), (base.size + stretch).round())


static func boss(base: Rect2, strike_age_ms: int, hit_age_ms: int) -> Rect2:
	var offset := Vector2.ZERO
	var stretch := Vector2.ZERO
	if strike_age_ms >= 0 and strike_age_ms < 520:
		var progress := float(strike_age_ms) / 520.0
		var attack := sin(progress * PI)
		offset.x -= 12.0 * attack
		stretch = Vector2(5, -3) * attack
	if hit_age_ms >= 0 and hit_age_ms < 420:
		offset.x += 5.0 * (1.0 - float(hit_age_ms) / 420.0)
	return Rect2((base.position + offset - stretch * 0.5).round(), (base.size + stretch).round())
