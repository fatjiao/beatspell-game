extends RefCounted

const PERFECT_WINDOW_MS := 45
const GOOD_WINDOW_MS := 110

var _events: Array = []


func _init(events: Array = []) -> void:
	_events = events


func judge(input_time_ms: int, instrument: String, calibration_offset_ms: int = 0) -> Dictionary:
	var adjusted_time_ms := input_time_ms - calibration_offset_ms
	var nearest_index := -1
	var nearest_distance := 2_147_483_647
	var nearest_offset := 0

	for index in _events.size():
		var chart_event = _events[index]
		if chart_event.consumed or chart_event.instrument != instrument:
			continue
		var offset: int = adjusted_time_ms - chart_event.time_ms
		var distance := absi(offset)
		if distance < nearest_distance:
			nearest_index = index
			nearest_distance = distance
			nearest_offset = offset

	if nearest_index == -1 or nearest_distance > GOOD_WINDOW_MS:
		return {
			"grade": "miss",
			"offset_ms": nearest_offset,
			"event_index": -1,
		}

	_events[nearest_index].consumed = true
	var grade := "perfect" if nearest_distance <= PERFECT_WINDOW_MS else "good"
	return {
		"grade": grade,
		"offset_ms": nearest_offset,
		"event_index": nearest_index,
	}

