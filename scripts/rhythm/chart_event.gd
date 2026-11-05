extends RefCounted

var time_ms: int
var instrument: String
var input_type: String
var consumed: bool = false


func _init(
		p_time_ms: int = 0,
		p_instrument: String = "drums",
		p_input_type: String = "tap"
) -> void:
	time_ms = p_time_ms
	instrument = p_instrument
	input_type = p_input_type

