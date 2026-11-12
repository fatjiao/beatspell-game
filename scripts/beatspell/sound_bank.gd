extends RefCounted

const RATE := 22050
const SOUNDS := {
	"charge": 0.070, "cast": 0.095, "fireball": 0.38, "shield": 0.34,
	"shield_block": 0.24, "parry": 0.28, "heal": 0.48, "boss": 0.42,
	"warning": 0.10, "error": 0.16, "count": 0.045, "break": 0.45,
	"victory": 0.90, "defeat": 0.70,
	"prism_warning": 0.12, "prism_strike": 0.46, "prism_shift": 0.32,
}


static func generate(kind: String) -> AudioStreamWAV:
	var duration := float(SOUNDS.get(kind, 0.1))
	var count := int(RATE * duration)
	var bytes := PackedByteArray()
	bytes.resize(count * 2)
	var phase := 0.0
	var noise_state := 123456789
	var filtered_noise := 0.0
	var previous := 0.0
	var high_pass := 0.0
	for index in count:
		var t := float(index) / RATE
		var p := float(index) / count
		noise_state = (noise_state * 1103515245 + 12345) & 0x7fffffff
		var noise := float(noise_state) / 1073741824.0 - 1.0
		filtered_noise = lerpf(filtered_noise, noise, 0.14)
		var frequency := 440.0
		var sample := 0.0
		match kind:
			"prism_warning":
				sample = sin(TAU * 784.0 * t) * exp(-t * 20) * 0.60
				sample += sin(TAU * 2156.0 * t) * exp(-t * 36) * 0.20
			"prism_strike":
				phase += TAU * lerpf(220.0, 48.0, p) / RATE
				sample = sin(phase) * 0.46 + filtered_noise * exp(-t * 10) * 0.35
				sample += sin(TAU * 1174.0 * t) * exp(-t * 17) * 0.20
			"prism_shift":
				sample = sin(TAU * 587.33 * t) * exp(-t * 12) * 0.35
				sample += sin(TAU * 880.0 * t) * exp(-t * 9) * 0.30
				sample += sin(TAU * 1568.0 * t) * exp(-t * 18) * 0.15
			"charge":
				frequency = lerpf(200.0, 95.0, p)
				phase += TAU * frequency / RATE
				sample = sin(phase) * 0.6 + filtered_noise * 0.17
			"cast":
				phase += TAU * lerpf(880.0, 510.0, p) / RATE
				sample = sin(phase) * 0.47 + sin(phase * 2.0) * 0.15
			"fireball":
				phase += TAU * lerpf(520.0, 62.0, p * p) / RATE
				sample = sin(phase) * 0.40 + filtered_noise * (0.70 - p * 0.35)
				if t > 0.10:
					sample += sin(TAU * 72.0 * (t - 0.10)) * exp(-(t - 0.10) * 15) * 0.20
			"shield", "shield_block", "parry":
				var fundamental := 523.25 if kind == "shield" else 392.0 if kind == "shield_block" else 1046.5
				sample = sin(TAU * fundamental * t) * exp(-t * 9) * 0.43
				sample += sin(TAU * fundamental * 2.76 * t) * exp(-t * 19) * 0.20
				sample += sin(TAU * fundamental * 4.08 * t) * exp(-t * 31) * 0.12
				if kind != "shield":
					sample += filtered_noise * exp(-t * 45) * 0.35
			"heal", "victory", "defeat":
				var notes: Array = [523.25, 659.25, 783.99, 1046.5] if kind != "defeat" else [392.0, 349.23, 293.66, 196.0]
				var step_length := duration / 5.0
				for note in 4:
					var local_time := t - float(note) * step_length
					if local_time >= 0:
						var attack := minf(local_time / 0.008, 1.0)
						var tone := sin(TAU * float(notes[note]) * local_time) + sin(TAU * float(notes[note]) * 2.0 * local_time) * 0.15
						sample += tone * attack * exp(-local_time * 16) * 0.36
			"boss", "break":
				phase += TAU * lerpf(125.0, 40.0, p) / RATE
				sample = sin(phase) * 0.5 + filtered_noise * 0.5 * exp(-t * 6)
				if kind == "break":
					sample += sin(TAU * 1320 * t) * exp(-t * 16) * 0.25 + noise * exp(-t * 25) * 0.15
			"warning", "count":
				frequency = 660.0 if kind == "warning" else 1100.0
				sample = (sin(TAU * frequency * t) + sin(TAU * frequency * 2.0 * t) * 0.18) * 0.60
			"error":
				phase += TAU * lerpf(180.0, 100.0, p) / RATE
				sample = (sin(phase) + sin(phase * 1.12) * 0.4) * 0.40
		# Short ramps prevent discontinuities; a DC blocker keeps noise and mixed partials centered.
		var attack_envelope := minf(t / 0.003, 1.0)
		var release_envelope := minf((duration - t) / 0.018, 1.0)
		var envelope := pow(1.0 - p, 1.4) * attack_envelope * release_envelope
		sample *= envelope
		high_pass = sample - previous + 0.995 * high_pass
		previous = sample
		var encoded := int(clampf(high_pass * 0.74, -0.92, 0.92) * 32767)
		bytes.encode_s16(index * 2, encoded)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = RATE
	stream.stereo = false
	stream.data = bytes
	return stream
