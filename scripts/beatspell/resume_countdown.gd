extends RefCounted

## A wall-clock countdown; the caller keeps music and gameplay paused until consumed.
## All times are supplied by the caller so tests never depend on real clock/sleep.
const BEAT_MS := 500
const BEATS := 3
const DURATION_MS := BEAT_MS * BEATS

var active := false
var _deadline_ms := 0


func begin(now_ms: int) -> void:
	active = true
	_deadline_ms = now_ms + DURATION_MS


func cancel() -> void:
	active = false
	_deadline_ms = 0


func remaining(now_ms: int) -> int:
	if not active or finished(now_ms):
		return 0
	return clampi(int(ceil(float(_deadline_ms - now_ms) / float(BEAT_MS))), 1, BEATS)


func finished(now_ms: int) -> bool:
	return active and now_ms >= _deadline_ms


func consume(now_ms: int) -> bool:
	if not finished(now_ms):
		return false
	cancel()
	return true
