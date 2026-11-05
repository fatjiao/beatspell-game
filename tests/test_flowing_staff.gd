extends RefCounted

const FlowingStaff = preload("res://scripts/presentation/flowing_staff.gd")


func run() -> Array[String]:
	var failures: Array[String] = []
	var staff = FlowingStaff.new()
	_expect_float(failures, staff.note_x(2000, 2000), 70.0, "note reaches hit line on beat")
	_expect_float(failures, staff.note_x(2000, 3000), 130.0, "note moves sixty pixels per second")
	_expect(failures, staff.is_note_visible(-200), "recent note remains briefly visible")
	_expect(failures, staff.is_note_visible(4000), "four-second lookahead is visible")
	_expect(failures, not staff.is_note_visible(-201), "old note is hidden")
	_expect(failures, not staff.is_note_visible(4001), "distant note is hidden")
	_expect(failures, staff.PANEL_BOTTOM - staff.PANEL_TOP <= 34.0, "score panel stays compact")
	_expect_float(failures, staff.note_y("drums"), 143.0, "drums position")
	_expect_float(failures, staff.note_y("bass"), 147.0, "bass position")
	_expect_float(failures, staff.note_y("synth"), 153.0, "synth position")
	_expect_float(failures, staff.note_y("lead"), 159.0, "lead position")
	return failures


func _expect(failures: Array[String], condition: bool, label: String) -> void:
	if not condition:
		failures.append(label)


func _expect_float(failures: Array[String], actual: float, expected: float, label: String) -> void:
	if not is_equal_approx(actual, expected):
		failures.append("%s: expected %.2f, got %.2f" % [label, expected, actual])
