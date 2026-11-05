extends RefCounted

const FILES := {
	"drums": "res://assets/music/chapter1/drums.ogg",
	"bass": "res://assets/music/chapter1/bass.ogg",
	"synth": "res://assets/music/chapter1/synth.ogg",
	"lead": "res://assets/music/chapter1/lead.ogg",
}


func run() -> Array[String]:
	var failures: Array[String] = []
	var reference_length := -1.0
	for instrument in FILES:
		var stream = load(FILES[instrument])
		if stream == null:
			failures.append("missing %s stem" % instrument)
			continue
		var length: float = stream.get_length()
		if length < 16.0:
			failures.append("%s stem is shorter than the prototype chart" % instrument)
		if reference_length < 0.0:
			reference_length = length
		elif absf(length - reference_length) > 0.05:
			failures.append("%s stem length differs by more than 50 ms" % instrument)
	return failures

