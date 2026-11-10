extends RefCounted

const MAX_OFFSET_MS := 300
const OUTLIER_DISTANCE_MS := 120


static func sample_for_tap(elapsed_ms: int, last_beat: int, beat_length_ms: int = 600) -> Dictionary:
	if elapsed_ms < 0 or beat_length_ms <= 0:
		return {"accepted": false}
	var beat := int(round(float(elapsed_ms) / float(beat_length_ms)))
	var offset := elapsed_ms - beat * beat_length_ms
	if beat <= last_beat or absi(offset) > MAX_OFFSET_MS:
		return {"accepted": false}
	return {"accepted": true, "beat": beat, "offset_ms": offset}


static func stable_offset(samples: Array) -> int:
	if samples.is_empty():
		return 0
	var sorted_samples := samples.duplicate()
	sorted_samples.sort()
	var first_median := _lower_median(sorted_samples)
	var filtered: Array = []
	for sample in sorted_samples:
		if absi(int(sample) - first_median) <= OUTLIER_DISTANCE_MS:
			filtered.append(int(sample))
	if filtered.is_empty():
		filtered = sorted_samples
	var result := _lower_median(filtered)
	return clampi(result, -MAX_OFFSET_MS, MAX_OFFSET_MS)


static func _lower_median(sorted_values: Array) -> int:
	var index := int((sorted_values.size() - 1) / 2.0)
	return int(sorted_values[index])

