extends RefCounted

const SETTINGS_PATH := "user://settings.json"
const DEFAULTS := {
	"audio_offset_ms": 0,
	"assist_mode": false,
}


static func load_settings(path: String = SETTINGS_PATH) -> Dictionary:
	if not FileAccess.file_exists(path):
		return DEFAULTS.duplicate(true)
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return DEFAULTS.duplicate(true)
	return parse_settings_text(file.get_as_text())


static func save_settings(settings: Dictionary, path: String = SETTINGS_PATH) -> Error:
	var normalized := _normalize(settings)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(normalized, "  "))
	return OK


static func parse_settings_text(text: String) -> Dictionary:
	var parser := JSON.new()
	if parser.parse(text) != OK:
		return DEFAULTS.duplicate(true)
	var parsed: Variant = parser.data
	if not (parsed is Dictionary):
		return DEFAULTS.duplicate(true)
	return _normalize(parsed)


static func _normalize(settings: Dictionary) -> Dictionary:
	var offset: Variant = settings.get("audio_offset_ms", DEFAULTS.audio_offset_ms)
	if not (offset is int or offset is float):
		offset = DEFAULTS.audio_offset_ms
	var assist: Variant = settings.get("assist_mode", DEFAULTS.assist_mode)
	if not (assist is bool):
		assist = DEFAULTS.assist_mode
	return {
		"audio_offset_ms": clampi(int(offset), -300, 300),
		"assist_mode": assist,
	}
