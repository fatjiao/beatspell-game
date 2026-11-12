extends RefCounted

const PATTERNS := ["standard", "syncopated", "rush", "echo", "offbeat"]
const LABELS := ["STANDARD", "SYNCOPATED", "RUSH", "ECHO", "OFFBEAT"]
const SHORT_LABELS := ["STD", "SYNC", "RUSH", "ECHO", "OFFBEAT"]
const CLEAR_STREAK := 3

var selected := 0
var requested := 0
var _stats: Array = []
var _last_outcome := "NO ATTACKS YET"
var _last_age_ms := -1


func _init() -> void:
	reset()


func reset() -> void:
	selected = 0
	requested = 0
	_stats.clear()
	for _pattern in PATTERNS:
		_stats.append({"attempts": 0, "blocks": 0, "perfect": 0, "streak": 0, "best": 0, "clear": false})
	_last_outcome = "NO ATTACKS YET"
	_last_age_ms = -1


func pattern() -> String:
	return PATTERNS[selected]


func pending_pattern() -> String:
	return PATTERNS[requested]


func request_selection(direction: int) -> void:
	requested = posmod(requested + direction, PATTERNS.size())


func commit_selection() -> bool:
	if selected == requested:
		return false
	selected = requested
	return true


func record_attack(result: Dictionary) -> bool:
	var stats: Dictionary = _stats[selected]
	var was_clear: bool = stats.clear
	stats.attempts += 1
	if result.get("blocked", false):
		stats.blocks += 1
	if result.get("perfect_guard", false):
		stats.perfect += 1
		stats.streak += 1
		stats.best = maxi(stats.best, stats.streak)
		stats.clear = stats.best >= CLEAR_STREAK
		_last_outcome = "PERFECT GUARD"
	else:
		stats.streak = 0
		match String(result.get("guard_reason", "unprotected")):
			"early": _last_outcome = "EARLY SHIELD"
			"grade": _last_outcome = "GOOD SHIELD"
			"unprotected": _last_outcome = "NO SHIELD"
			_: _last_outcome = "CHECK TIMING"
	_last_age_ms = int(result.get("guard_age_ms", -1))
	return not was_clear and bool(stats.clear)


func report() -> Dictionary:
	var rows: Array = []
	for index in PATTERNS.size():
		var row: Dictionary = _stats[index].duplicate(true)
		row.label = LABELS[index]
		rows.append(row)
	return {"rows": rows, "selected": selected, "last_outcome": _last_outcome, "last_age_ms": _last_age_ms}


func status_text() -> String:
	var stats: Dictionary = _stats[selected]
	return "%s %s" % [SHORT_LABELS[selected], "CLEAR" if stats.clear else "P%d/%d" % [stats.streak, CLEAR_STREAK]]
