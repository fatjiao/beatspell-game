extends RefCounted

const MAX_OFFSET_MS := 300
const OUTLIER_DISTANCE_MS := 120


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

