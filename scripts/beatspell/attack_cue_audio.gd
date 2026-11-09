extends RefCounted

const CUE_PITCHES := [0.94, 1.00, 1.06, 1.30]

var _last_cue_key := -1


func next_cue(bar_index: int, cue_index: int) -> Dictionary:
	if bar_index < 0 or cue_index < 0 or cue_index >= CUE_PITCHES.size():
		return {"should_play": false, "pitch_scale": 1.0}
	var cue_key := bar_index * CUE_PITCHES.size() + cue_index
	if cue_key == _last_cue_key:
		return {"should_play": false, "pitch_scale": CUE_PITCHES[cue_index]}
	_last_cue_key = cue_key
	return {"should_play": true, "pitch_scale": CUE_PITCHES[cue_index]}


func reset() -> void:
	_last_cue_key = -1
