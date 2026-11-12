extends RefCounted

const Countdown = preload("res://scripts/beatspell/resume_countdown.gd")


func run() -> Array[String]:
	var failures: Array[String] = []
	var countdown := Countdown.new()
	_check(failures, not countdown.active and countdown.remaining(0) == 0, "inactive countdown has no visible beat")
	_check(failures, not countdown.finished(999999) and not countdown.consume(999999), "inactive countdown never finishes or resumes")
	countdown.begin(1000)
	_check(failures, countdown.active and countdown.remaining(1000) == 3, "begin shows three immediately")
	for sample in [[1000, 3], [1499, 3], [1500, 2], [1999, 2], [2000, 1], [2499, 1], [2500, 0], [9000, 0]]:
		_check(failures, countdown.remaining(sample[0]) == sample[1], "exact 500ms boundary at %d" % sample[0])
	_check(failures, not countdown.finished(2499) and countdown.finished(2500), "completion includes exact 1500ms deadline")
	_check(failures, not countdown.consume(2499) and countdown.active, "early consume retains countdown")
	_check(failures, countdown.consume(2500) and not countdown.active, "deadline consumes one resume")
	_check(failures, not countdown.consume(2500) and not countdown.consume(9000), "completed countdown cannot resume twice")
	countdown.begin(10000)
	_check(failures, countdown.remaining(9500) == 3 and not countdown.finished(9500), "backward supplied clock does not overflow beat count")
	countdown.cancel()
	_check(failures, not countdown.active and countdown.remaining(11000) == 0 and not countdown.finished(999999), "cancelled countdown never resumes later")
	countdown.cancel()
	_check(failures, not countdown.active, "repeated cancellation is harmless")
	countdown.begin(20000)
	countdown.begin(21000)
	_check(failures, countdown.remaining(21000) == 3 and not countdown.finished(21500), "begin replaces the prior deadline")
	_check(failures, countdown.finished(22500) and countdown.consume(23000), "late frame consumes replacement countdown exactly once")
	countdown.begin(30000)
	_check(failures, countdown.remaining(30000) == 3 and countdown.consume(31500), "consumed helper can serve the next pause")
	return failures


func _check(failures: Array[String], condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
