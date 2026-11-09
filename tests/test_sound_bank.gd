extends RefCounted

const Bank = preload("res://scripts/beatspell/sound_bank.gd")


func run() -> Array[String]:
	var failures: Array[String] = []
	for kind in Bank.SOUNDS:
		var stream: AudioStreamWAV = Bank.generate(kind)
		var bytes := stream.data
		var sample_count := int(bytes.size() / 2)
		var peak := 0.0
		var sum := 0.0
		var energy := 0.0
		for index in sample_count:
			var value := float(bytes.decode_s16(index * 2)) / 32768.0
			peak = maxf(peak, absf(value))
			sum += value
			energy += value * value
		if peak > 0.925: failures.append(kind + ": clipped peak")
		if sqrt(energy / sample_count) < 0.015: failures.append(kind + ": silent or inaudible content")
		if absf(sum / sample_count) > 0.025: failures.append(kind + ": DC offset")
		if absi(bytes.decode_s16(0)) > 100 or absi(bytes.decode_s16(bytes.size() - 2)) > 100:
			failures.append(kind + ": edge ramp may click")
		var path := "res://assets/sfx/beatspell/%s.wav" % kind
		if not ResourceLoader.exists(path):
			failures.append(kind + ": exported effect missing")
		else:
			var asset = load(path)
			if absf(asset.get_length() - stream.get_length()) > 0.002:
				failures.append(kind + ": exported duration differs")
	return failures
