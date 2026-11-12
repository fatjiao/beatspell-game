extends RefCounted

const Records = preload("res://scripts/beatspell/run_records.gd")
const TEST_PATH := "res://build/run-records-unit-test.json"


func run() -> Array[String]:
	var failures: Array[String] = []
	if DirAccess.make_dir_recursive_absolute("res://build") != OK:
		failures.append("cannot create isolated record test directory")
		return failures
	_cleanup()
	var data := Records.empty_records()
	var another := Records.empty_records()
	data.modes.ritual.best_combo = 7
	_check(failures, another.modes.ritual.best_combo == 0, "new records do not share nested dictionaries")
	data = Records.load_records(TEST_PATH)
	_check(failures, data == Records.empty_records(), "missing file starts empty")
	var flags := Records.record_run(data, "ritual", {"rank": "B", "victory": false, "duration_ms": 18000, "max_combo": 3})
	_check(failures, flags.new_rank and flags.new_combo and not flags.new_clear, "first loss earns rank and combo but no clear")
	_check(failures, data.modes.ritual.attempts == 1 and data.modes.ritual.wins == 0 and data.modes.ritual.best_clear_ms == -1, "loss counts as completed attempt only")
	Records.record_run(data, "ritual", {"rank": "A", "victory": true, "duration_ms": 65000, "max_combo": 8})
	flags = Records.record_run(data, "ritual", {"rank": "B", "victory": true, "duration_ms": 60000, "max_combo": 8})
	_check(failures, not flags.new_rank and not flags.new_combo and flags.new_clear, "faster lower-rank clear improves time independently")
	_check(failures, data.modes.ritual.best_rank == "A" and data.modes.ritual.best_clear_ms == 60000, "best rank and clear can come from different runs")
	flags = Records.record_run(data, "ritual", {"rank": "S", "victory": false, "duration_ms": 2000, "max_combo": 12})
	_check(failures, flags.new_rank and flags.new_combo and not flags.new_clear, "excellent lost run never changes clear time")
	flags = Records.record_run(data, "ritual", {"rank": "S", "victory": true, "duration_ms": 60000, "max_combo": 12})
	_check(failures, not flags.new_rank and not flags.new_combo and not flags.new_clear, "ties are not new records")
	Records.record_run(data, "duel", {"rank": "C", "victory": true, "duration_ms": 74000, "max_combo": 1})
	_check(failures, data.modes.duel.attempts == 1 and data.modes.ritual.attempts == 5 and data.modes.gauntlet.attempts == 0, "modes retain independent totals")
	var before := data.duplicate(true)
	flags = Records.record_run(data, "unknown", {"rank": "S", "victory": true})
	_check(failures, data == before and not flags.new_rank and not flags.new_clear and not flags.new_combo, "unknown mode cannot contaminate ritual records")
	_check(failures, Records.save_records(data, TEST_PATH) == OK, "first complete snapshot saves")
	_check(failures, Records.load_records(TEST_PATH) == data and data == before, "save/load round trip and nonmutating save")
	Records.record_run(data, "duel", {"rank": "A", "victory": true, "duration_ms": 70000, "max_combo": 2})
	_check(failures, Records.save_records(data, TEST_PATH) == OK and Records.load_records(TEST_PATH) == data, "rename replaces existing snapshot on Windows")
	_check(failures, not FileAccess.file_exists(TEST_PATH + ".tmp"), "successful save leaves no temporary snapshot")
	for text in ["{", "[]", '{"version":2,"modes":{"ritual":{"attempts":3}}}', '{"version":"1","modes":{}}', '{"modes":[]}']:
		_write(text)
		_check(failures, Records.load_records(TEST_PATH) == Records.empty_records(), "malformed or unsupported snapshot falls back safely")
	_write('{"modes":{"ritual":{"attempts":5,"wins":20,"best_rank":"INVALID","best_combo":-20,"best_clear_ms":-1,"last_victory":"true"},"duel":{"attempts":-1,"wins":2,"best_rank":"S"},"gauntlet":{"attempts":1e20,"wins":1e20,"best_combo":1e20,"best_clear_ms":999999},"extra":{"attempts":5}}}')
	var sanitized := Records.load_records(TEST_PATH)
	_check(failures, sanitized.modes.ritual.wins == 5 and sanitized.modes.ritual.best_rank == "" and sanitized.modes.ritual.best_combo == 0 and not sanitized.modes.ritual.last_victory, "mistyped values and impossible totals normalize")
	_check(failures, sanitized.modes.duel == Records.empty_records().modes.duel, "zero attempts cannot contain earned results")
	_check(failures, sanitized.modes.gauntlet.attempts == Records.COUNTER_LIMIT and sanitized.modes.gauntlet.best_clear_ms == Records.DURATION_LIMIT_MS, "large finite values clamp before integer conversion")
	_check(failures, sanitized.modes.size() == 3, "unknown modes discarded and missing schema version migrates")
	_write('{"version":1,"modes":{"ritual":{"attempts":1,"wins":0,"best_clear_ms":20000,"last_victory":true}}}')
	_check(failures, Records.load_records(TEST_PATH).modes.ritual.best_clear_ms == -1 and not Records.load_records(TEST_PATH).modes.ritual.last_victory, "no wins cannot claim clear time or latest victory")
	# A leftover temp file never substitutes for an incomplete primary file.
	var temporary := FileAccess.open(TEST_PATH + ".tmp", FileAccess.WRITE)
	temporary.store_string(JSON.stringify(data))
	temporary.close()
	_write("{")
	_check(failures, Records.load_records(TEST_PATH) == Records.empty_records(), "uncommitted temporary file is ignored")
	_check(failures, Records.save_records(data, TEST_PATH + "/records.json") != OK, "write failure is returned to caller instead of claiming success")
	_cleanup()
	return failures


func _write(text: String) -> void:
	var file := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	file.store_string(text)
	file.close()


func _cleanup() -> void:
	for path in [TEST_PATH, TEST_PATH + ".tmp"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)


func _check(failures: Array[String], condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
