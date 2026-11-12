extends RefCounted


func run() -> Array[String]:
	var failures: Array[String] = []
	var script = load("res://scripts/beatspell/defense_drill.gd")
	if script == null:
		failures.append("defense drill model is missing")
		return failures
	var drill = script.new()
	_check(failures, drill.pattern() == "standard", "default pattern is standard")
	_check(failures, drill.report().rows.size() == 5, "training report includes all five patterns")
	drill.request_selection(1)
	_check(failures, drill.pattern() == "standard" and drill.pending_pattern() == "syncopated", "request does not alter active warning")
	_check(failures, drill.commit_selection() and drill.pattern() == "syncopated", "new bar commits requested pattern")
	_check(failures, not drill.commit_selection(), "unchanged request is a no-op")
	for count in 3:
		drill.record_attack({"blocked": true, "perfect_guard": true, "guard_age_ms": 500, "guard_reason": "perfect"})
	var rows: Array = drill.report().rows
	_check(failures, rows[1].attempts == 3 and rows[1].perfect == 3, "each pattern has separate attempts and guard counts")
	_check(failures, rows[1].best == 3 and rows[1].clear, "three consecutive precise guards clear a pattern")
	drill.record_attack({"blocked": true, "perfect_guard": false, "guard_age_ms": 850, "guard_reason": "early"})
	rows = drill.report().rows
	_check(failures, rows[1].streak == 0 and rows[1].best == 3 and rows[1].clear, "early block resets streak but preserves mastery")
	_check(failures, drill.report().last_outcome == "EARLY SHIELD" and drill.report().last_age_ms == 850, "report explains early shield")
	drill.request_selection(-2)
	drill.commit_selection()
	_check(failures, drill.pattern() == "offbeat", "negative selection wraps across all five patterns")
	drill.record_attack({"blocked": false, "perfect_guard": false, "guard_reason": "unprotected"})
	_check(failures, drill.report().rows[4].attempts == 1 and drill.report().last_outcome == "NO SHIELD", "unprotected offbeat strike is counted without a guard")
	_check(failures, drill.report().rows[1].perfect == 3, "switching preserves other pattern results")
	drill.request_selection(-1)
	drill.commit_selection()
	_check(failures, drill.pattern() == "echo" and drill.report().rows[3].label == "ECHO", "echo is individually selectable and labeled")
	for count in 3:
		drill.record_attack({"blocked": true, "perfect_guard": true, "guard_age_ms": 500, "guard_reason": "perfect"})
	_check(failures, drill.report().rows[3].clear and drill.report().rows[4].attempts == 1, "echo clears independently of offbeat")
	drill.request_selection(1)
	drill.commit_selection()
	_check(failures, drill.report().rows[4].label == "OFFBEAT", "offbeat report uses its stable label")
	for count in 3:
		drill.record_attack({"blocked": true, "perfect_guard": true, "guard_age_ms": 500, "guard_reason": "perfect"})
	_check(failures, drill.report().rows[4].clear and drill.report().rows[4].streak == 3, "three consecutive precise offbeat guards clear that drill")
	var snapshot: Dictionary = drill.report()
	snapshot.rows[1].perfect = 999
	_check(failures, drill.report().rows[1].perfect == 3, "report is an isolated snapshot")
	drill.reset()
	_check(failures, drill.pattern() == "standard" and drill.report().rows[1].attempts == 0, "new round resets all training data")
	for row in drill.report().rows:
		_check(failures, row.attempts == 0 and not row.clear, "all five patterns reset together")
	return failures


func _check(failures: Array[String], condition: bool, label: String) -> void:
	if not condition:
		failures.append(label)
