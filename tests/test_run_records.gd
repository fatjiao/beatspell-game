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
	_check(failures, flags.new_rank and flags.new_combo and not flags.new_clear and not flags.new_mastery, "first loss earns rank and combo but no clear or mastery")
	_check(failures, data.modes.ritual.attempts == 1 and data.modes.ritual.wins == 0 and data.modes.ritual.best_clear_ms == -1, "loss counts as completed attempt only")
	flags = Records.record_run(data, "ritual", {"rank": "A", "victory": true, "duration_ms": 65000, "max_combo": 8})
	_check(failures, flags.new_mastery and Records.mastery(data.modes.ritual) == 2 and data.modes.ritual.best_victory_rank == "A", "first A victory directly earns mastery tier two")
	flags = Records.record_run(data, "ritual", {"rank": "B", "victory": true, "duration_ms": 60000, "max_combo": 8})
	_check(failures, not flags.new_rank and not flags.new_combo and flags.new_clear, "faster lower-rank clear improves time independently")
	_check(failures, data.modes.ritual.best_rank == "A" and data.modes.ritual.best_clear_ms == 60000, "best rank and clear can come from different runs")
	flags = Records.record_run(data, "ritual", {"rank": "S", "victory": false, "duration_ms": 2000, "max_combo": 12})
	_check(failures, flags.new_rank and flags.new_combo and not flags.new_clear and not flags.new_mastery and Records.mastery(data.modes.ritual) == 2, "excellent lost run never changes clear time or winning mastery")
	flags = Records.record_run(data, "ritual", {"rank": "S", "victory": true, "duration_ms": 60000, "max_combo": 12})
	_check(failures, not flags.new_rank and not flags.new_combo and not flags.new_clear and flags.new_mastery and Records.mastery(data.modes.ritual) == 3, "matching a lost S rank can still earn winning mastery tier three")
	Records.record_run(data, "duel", {"rank": "C", "victory": true, "duration_ms": 74000, "max_combo": 1})
	_check(failures, data.modes.duel.attempts == 1 and data.modes.ritual.attempts == 5 and data.modes.gauntlet.attempts == 0 and data.modes.prism.attempts == 0, "four modes retain independent totals")
	var before := data.duplicate(true)
	flags = Records.record_run(data, "unknown", {"rank": "S", "victory": true})
	_check(failures, data == before and not flags.new_rank and not flags.new_clear and not flags.new_combo and not flags.new_mastery, "unknown mode cannot contaminate ritual records")
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
	_check(failures, sanitized.modes.size() == 4, "unknown modes discarded and missing schema version migrates")
	_write('{"version":1,"modes":{"ritual":{"attempts":1,"wins":0,"best_clear_ms":20000,"last_victory":true}}}')
	_check(failures, Records.load_records(TEST_PATH).modes.ritual.best_clear_ms == -1 and not Records.load_records(TEST_PATH).modes.ritual.last_victory, "no wins cannot claim clear time or latest victory")
	_test_mastery_migration(failures)
	# A leftover temp file never substitutes for an incomplete primary file.
	var temporary := FileAccess.open(TEST_PATH + ".tmp", FileAccess.WRITE)
	temporary.store_string(JSON.stringify(data))
	temporary.close()
	_write("{")
	_check(failures, Records.load_records(TEST_PATH) == Records.empty_records(), "uncommitted temporary file is ignored")
	_check(failures, Records.save_records(data, TEST_PATH + "/records.json") != OK, "write failure is returned to caller instead of claiming success")
	_cleanup()
	return failures


func _test_mastery_migration(failures: Array[String]) -> void:
	# Version 1 predates Prism and never distinguished winning vs losing grades.
	_write('{"version":1,"modes":{"ritual":{"attempts":7,"wins":2,"best_rank":"S","best_clear_ms":45321,"best_combo":13,"last_rank":"A","last_victory":true},"duel":{"attempts":4,"wins":0,"best_rank":"S","best_combo":10},"gauntlet":{"attempts":2,"wins":1,"best_rank":"A","best_clear_ms":76000}}}')
	var migrated := Records.load_records(TEST_PATH)
	_check(failures, migrated.version == 1 and migrated.modes.size() == 4, "existing schema one gains Prism without resetting history")
	_check(failures, migrated.modes.ritual.attempts == 7 and migrated.modes.ritual.wins == 2 and migrated.modes.ritual.best_rank == "S" and migrated.modes.ritual.best_clear_ms == 45321 and migrated.modes.ritual.best_combo == 13, "all previous ritual counters and records survive migration")
	_check(failures, migrated.modes.duel.attempts == 4 and migrated.modes.gauntlet.best_clear_ms == 76000, "other previous modes survive migration")
	_check(failures, migrated.modes.prism == Records.empty_records().modes.prism, "new Prism record starts independently empty")
	_check(failures, Records.mastery(migrated.modes.ritual) == 1 and migrated.modes.ritual.best_victory_rank == "" and Records.mastery(migrated.modes.duel) == 0 and Records.mastery(migrated.modes.gauntlet) == 1, "legacy wins earn only clear tier regardless of historic best rhythm rank")
	var flags := Records.record_run(migrated, "ritual", {"rank": "A", "victory": true, "duration_ms": 70000, "max_combo": 6})
	_check(failures, flags.new_mastery and not flags.new_rank and not flags.new_clear and Records.mastery(migrated.modes.ritual) == 2, "winning A after migration upgrades mastery independently of existing S rhythm rank")
	flags = Records.record_run(migrated, "ritual", {"rank": "B", "victory": true, "duration_ms": 68000, "max_combo": 6})
	_check(failures, not flags.new_mastery and migrated.modes.ritual.best_victory_rank == "A", "a lower winning grade cannot regress mastery")
	flags = Records.record_run(migrated, "prism", {"rank": "S", "victory": false, "duration_ms": 25000, "max_combo": 15})
	_check(failures, not flags.new_mastery and Records.mastery(migrated.modes.prism) == 0 and migrated.modes.prism.best_victory_rank == "", "Prism loss cannot earn a victory badge")
	flags = Records.record_run(migrated, "prism", {"rank": "C", "victory": true, "duration_ms": 75000, "max_combo": 2})
	_check(failures, flags.new_mastery and Records.mastery(migrated.modes.prism) == 1, "first Prism victory earns the clear tier")
	flags = Records.record_run(migrated, "prism", {"rank": "A", "victory": true, "duration_ms": 70000, "max_combo": 7})
	_check(failures, flags.new_mastery and Records.mastery(migrated.modes.prism) == 2, "Prism A victory earns tier two")
	flags = Records.record_run(migrated, "prism", {"rank": "S", "victory": true, "duration_ms": 65000, "max_combo": 11})
	_check(failures, flags.new_mastery and Records.mastery(migrated.modes.prism) == 3, "Prism S victory earns tier three")
	flags = Records.record_run(migrated, "prism", {"rank": "S", "victory": true, "duration_ms": 65000, "max_combo": 11})
	_check(failures, not flags.new_mastery and Records.mastery(migrated.modes.ritual) == 2, "repeated S victory is no upgrade and modes keep independent tiers")
	_check(failures, Records.save_records(migrated, TEST_PATH) == OK, "expanded version-one schema saves")
	var restored := Records.load_records(TEST_PATH)
	_check(failures, restored == migrated and Records.mastery(restored.modes.prism) == 3, "winning grades and tiers survive restart")
	_write('{"version":1,"modes":{"ritual":{"attempts":2,"wins":0,"best_rank":"S","best_victory_rank":"S"},"duel":{"attempts":2,"wins":1,"best_victory_rank":true},"gauntlet":{"attempts":2,"wins":1,"best_victory_rank":"Z"},"prism":{"attempts":-1,"wins":3,"best_victory_rank":"S"}}}')
	var corrupt := Records.load_records(TEST_PATH)
	_check(failures, Records.mastery(corrupt.modes.ritual) == 0 and corrupt.modes.ritual.best_victory_rank == "" and Records.mastery(corrupt.modes.prism) == 0, "impossible wins cannot preserve a victory grade")
	_check(failures, Records.mastery(corrupt.modes.duel) == 1 and Records.mastery(corrupt.modes.gauntlet) == 1, "malformed victory grades retain only known clear status")
	_write('{"version":1,"modes":{"prism":{"attempts":2,"wins":1,"best_rank":"C","best_victory_rank":"S"}}}')
	var inconsistent := Records.load_records(TEST_PATH)
	_check(failures, inconsistent.modes.prism.best_rank == "S" and Records.mastery(inconsistent.modes.prism) == 3, "known winning grade also sets the overall grade floor")
	for value in [null, true, "1", -3, INF, NAN]:
		_check(failures, Records.mastery({"wins": value, "best_victory_rank": "S"}) == 0, "mastery handles invalid counters safely")


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
