extends RefCounted

const ON_TIME_THRESHOLD_MS := 8

var input_count := 0
var perfect_input_count := 0
var good_input_count := 0
var missed_input_count := 0
var attempt_count := 0
var successful_cast_count := 0
var perfect_cast_count := 0
var good_cast_count := 0
var failed_cast_count := 0

var _absolute_offset_total_ms := 0
var _signed_offset_total_ms := 0


func record_input(event: Dictionary) -> void:
	input_count += 1
	var offset_ms := int(event.get("offset_ms", 0))
	_absolute_offset_total_ms += absi(offset_ms)
	_signed_offset_total_ms += offset_ms
	match String(event.get("grade", "miss")):
		"perfect":
			perfect_input_count += 1
		"good":
			good_input_count += 1
		_:
			missed_input_count += 1


func record_attempt(skill: String, grade: String) -> void:
	attempt_count += 1
	if skill.is_empty():
		failed_cast_count += 1
		return
	successful_cast_count += 1
	if grade == "perfect":
		perfect_cast_count += 1
	else:
		good_cast_count += 1


func average_absolute_offset_ms() -> int:
	if input_count == 0:
		return 0
	return int(round(float(_absolute_offset_total_ms) / float(input_count)))


func average_signed_offset_ms() -> int:
	if input_count == 0:
		return 0
	return int(round(float(_signed_offset_total_ms) / float(input_count)))


func timing_bias() -> String:
	var average := average_signed_offset_ms()
	if average < -ON_TIME_THRESHOLD_MS:
		return "EARLY"
	if average > ON_TIME_THRESHOLD_MS:
		return "LATE"
	return "ON TIME"


func rank() -> String:
	if attempt_count == 0:
		return "C"
	var success_rate := float(successful_cast_count) / float(attempt_count)
	var average_error := average_absolute_offset_ms()
	if success_rate >= 0.90 and missed_input_count == 0 and average_error <= 45:
		return "S"
	if success_rate >= 0.75 and average_error <= 80:
		return "A"
	if success_rate >= 0.50 and average_error <= 120:
		return "B"
	return "C"


func reset() -> void:
	input_count = 0
	perfect_input_count = 0
	good_input_count = 0
	missed_input_count = 0
	attempt_count = 0
	successful_cast_count = 0
	perfect_cast_count = 0
	good_cast_count = 0
	failed_cast_count = 0
	_absolute_offset_total_ms = 0
	_signed_offset_total_ms = 0
