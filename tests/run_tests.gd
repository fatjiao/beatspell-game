extends SceneTree


func _init() -> void:
	var suites := [
		{"name": "smoke", "script": preload("res://tests/test_smoke.gd")},
		{"name": "rhythm_judge", "script": preload("res://tests/test_rhythm_judge.gd")},
		{"name": "chart_loader", "script": preload("res://tests/test_chart_loader.gd")},
		{"name": "calibration", "script": preload("res://tests/test_calibration.gd")},
		{"name": "audio_assets", "script": preload("res://tests/test_audio_assets.gd")},
		{"name": "result_scoring", "script": preload("res://tests/test_result_scoring.gd")},
		{"name": "stage_director", "script": preload("res://tests/test_stage_director.gd")},
	]
	var failure_count := 0
	for suite in suites:
		var instance = suite.script.new()
		var failures: Array = instance.run()
		if failures.is_empty():
			print("PASS: %s" % suite.name)
		else:
			for message in failures:
				printerr("FAIL: %s: %s" % [suite.name, message])
			failure_count += failures.size()
	if failure_count == 0:
		print("All tests passed.")
		quit(0)
	else:
		printerr("%d test failure(s)." % failure_count)
		quit(1)
