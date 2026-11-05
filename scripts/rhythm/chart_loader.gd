extends RefCounted

const ChartEventScript = preload("res://scripts/rhythm/chart_event.gd")
const VALID_INSTRUMENTS := ["drums", "bass", "synth", "lead"]
const VALID_INPUT_TYPES := ["tap", "hold_start", "hold_end"]


func load_chart(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return _failure("chart file not found: %s" % path)

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _failure("unable to open chart: %s" % path)
	var parsed = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return _failure("chart root must be a JSON object")

	if not parsed.has("bpm") or not (parsed.bpm is float or parsed.bpm is int) or parsed.bpm <= 0:
		return _failure("bpm must be a positive number")
	if not parsed.has("duration_ms") or not (parsed.duration_ms is float or parsed.duration_ms is int):
		return _failure("duration_ms must be a number")
	if parsed.duration_ms <= 0:
		return _failure("duration_ms must be positive")
	if not parsed.has("events") or not (parsed.events is Array):
		return _failure("events must be an array")

	var events: Array = []
	var previous_time := -1
	for index in parsed.events.size():
		var raw_event = parsed.events[index]
		if not (raw_event is Dictionary):
			return _event_failure(index, "must be an object")
		if not raw_event.has("time_ms") or not (raw_event.time_ms is float or raw_event.time_ms is int):
			return _event_failure(index, "time_ms must be a number")
		var time_ms := int(raw_event.time_ms)
		if time_ms < 0:
			return _event_failure(index, "time_ms cannot be negative")
		if time_ms < previous_time:
			return _event_failure(index, "events must be sorted by time_ms")
		if not raw_event.has("instrument") or raw_event.instrument not in VALID_INSTRUMENTS:
			return _event_failure(index, "unknown instrument")
		if not raw_event.has("type") or raw_event.type not in VALID_INPUT_TYPES:
			return _event_failure(index, "unknown input type")
		events.append(ChartEventScript.new(time_ms, raw_event.instrument, raw_event.type))
		previous_time = time_ms

	return {
		"ok": true,
		"error": "",
		"data": {
			"title": str(parsed.get("title", "Untitled")),
			"bpm": float(parsed.bpm),
			"duration_ms": int(parsed.duration_ms),
			"events": events,
		},
	}


func _event_failure(index: int, message: String) -> Dictionary:
	return _failure("event %d: %s" % [index, message])


func _failure(message: String) -> Dictionary:
	return {"ok": false, "error": message, "data": {}}

