extends RefCounted

## Local completed-run records. Practice and abandoned runs are excluded by the caller.
const RECORDS_PATH := "user://run-records.json"
const MODES := ["ritual", "duel", "gauntlet", "prism"]
const RANKS := ["", "C", "B", "A", "S"]
const COUNTER_LIMIT := 999999
const DURATION_LIMIT_MS := 90000
const MAX_FILE_BYTES := 1048576


static func empty_records() -> Dictionary:
	var modes := {}
	for mode in MODES:
		modes[mode] = _empty_mode()
	return {"version": 1, "modes": modes}


static func load_records(path: String = RECORDS_PATH) -> Dictionary:
	if not FileAccess.file_exists(path):
		return empty_records()
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null or file.get_length() > MAX_FILE_BYTES:
		return empty_records()
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK:
		return empty_records()
	return _normalize(parser.data)


static func save_records(data: Dictionary, path: String = RECORDS_PATH) -> Error:
	var temporary := path + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(_normalize(data), "  "))
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		DirAccess.remove_absolute(temporary)
		return write_error
	# Rename on the same filesystem replaces the previous complete snapshot.
	var rename_error := DirAccess.rename_absolute(temporary, path)
	if rename_error != OK:
		DirAccess.remove_absolute(temporary)
	return rename_error


static func record_run(data: Dictionary, mode: String, result: Dictionary) -> Dictionary:
	var changes := {"new_rank": false, "new_clear": false, "new_combo": false, "new_mastery": false}
	if mode not in MODES:
		return changes
	var normalized := _normalize(data)
	data.clear()
	data.merge(normalized, true)
	var record: Dictionary = data.modes[mode]
	var previous_mastery := mastery(record)
	var rank := _rank(result.get("rank", "C"))
	if rank.is_empty():
		rank = "C"
	var victory: bool = result.get("victory", false) is bool and result.get("victory", false)
	var duration := _integer(result.get("duration_ms", DURATION_LIMIT_MS), DURATION_LIMIT_MS, 0, DURATION_LIMIT_MS)
	var combo := _integer(result.get("max_combo", 0), 0, 0, COUNTER_LIMIT)
	record.attempts = mini(record.attempts + 1, COUNTER_LIMIT)
	if victory:
		record.wins = mini(record.wins + 1, record.attempts)
		if RANKS.find(rank) > RANKS.find(record.best_victory_rank):
			record.best_victory_rank = rank
		if record.best_clear_ms < 0 or duration < record.best_clear_ms:
			record.best_clear_ms = duration
			changes.new_clear = true
	if RANKS.find(rank) > RANKS.find(record.best_rank):
		record.best_rank = rank
		changes.new_rank = true
	if combo > record.best_combo:
		record.best_combo = combo
		changes.new_combo = true
	record.last_rank = rank
	record.last_victory = victory
	changes.new_mastery = mastery(record) > previous_mastery
	return changes


## Mastery requires a victory; a high rhythm grade in a lost run cannot earn it.
## Older version-1 saves retain the clear tier without inventing a winning grade.
static func mastery(record: Dictionary) -> int:
	if _integer(record.get("wins", 0), 0, 0, COUNTER_LIMIT) <= 0:
		return 0
	match _rank(record.get("best_victory_rank", "")):
		"S": return 3
		"A": return 2
	return 1


static func _empty_mode() -> Dictionary:
	return {"attempts": 0, "wins": 0, "best_rank": "", "best_clear_ms": -1,
		"best_combo": 0, "last_rank": "", "last_victory": false, "best_victory_rank": ""}


static func _normalize(value: Variant) -> Dictionary:
	var normalized := empty_records()
	if not value is Dictionary:
		return normalized
	var version: Variant = value.get("version", 1)
	if not (version is int or version is float) or version != 1:
		return normalized
	var modes: Variant = value.get("modes", {})
	if not modes is Dictionary:
		return normalized
	for mode in MODES:
		var source: Variant = modes.get(mode, {})
		if not source is Dictionary:
			continue
		var target: Dictionary = normalized.modes[mode]
		target.attempts = _integer(source.get("attempts", 0), 0, 0, COUNTER_LIMIT)
		target.wins = _integer(source.get("wins", 0), 0, 0, target.attempts)
		if target.attempts == 0:
			continue
		target.best_rank = _rank(source.get("best_rank", ""))
		target.last_rank = _rank(source.get("last_rank", ""))
		target.best_combo = _integer(source.get("best_combo", 0), 0, 0, COUNTER_LIMIT)
		target.last_victory = source.get("last_victory", false) is bool and source.get("last_victory", false) and target.wins > 0
		if target.wins > 0:
			target.best_clear_ms = _integer(source.get("best_clear_ms", -1), -1, -1, DURATION_LIMIT_MS)
			target.best_victory_rank = _rank(source.get("best_victory_rank", ""))
			if RANKS.find(target.best_victory_rank) > RANKS.find(target.best_rank):
				target.best_rank = target.best_victory_rank
	return normalized


static func _rank(value: Variant) -> String:
	return value if value is String and value in RANKS else ""


static func _integer(value: Variant, fallback: int, minimum: int, maximum: int) -> int:
	if not (value is int or value is float) or not is_finite(float(value)):
		return fallback
	return int(clampf(float(value), float(minimum), float(maximum)))
