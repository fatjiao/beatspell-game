extends RefCounted

const Lang = preload("res://scripts/beatspell/localization.gd")
const Settings = preload("res://scripts/settings/settings_store.gd")
const Art = preload("res://scripts/beatspell/art_direction.gd")


func run() -> Array[String]:
	var failures: Array[String] = []
	var previous := Lang.preference
	var previous_language := Lang.language
	for locale in ["zh_CN", "zh-TW", "zh-Hans-CN", "ZH_hk"]:
		_check(failures, Lang.resolve("auto", locale) == "zh_CN", "Chinese system locale: " + locale)
	for locale in ["en_US", "ja_JP", "", "fr-FR"]:
		_check(failures, Lang.resolve("auto", locale) == "en", "English fallback: " + locale)
	_check(failures, Lang.resolve("en", "zh_CN") == "en", "explicit language overrides OS")
	_check(failures, Lang.resolve("zh_CN", "en_US") == "zh_CN", "Chinese overrides English OS")
	_check(failures, Settings.parse_settings_text('{"audio_offset_ms":85}').language == "auto", "legacy settings migrate to automatic language")
	for invalid in [null, 1, true, "fr", [], {}]:
		_check(failures, Lang.normalize(invalid) == "auto", "invalid language falls back safely")
	_check(failures, Settings.parse_settings_text('{"language":"en"}').language == "en", "saved language parses")
	var format := RegEx.new()
	format.compile("%[+0-9.]*[dsf]")
	for source: String in Lang.ZH:
		var translated: String = Lang.ZH[source]
		var original_tokens: Array[String] = []
		var translated_tokens: Array[String] = []
		for token in format.search_all(source):
			original_tokens.append(token.get_string())
		for token in format.search_all(translated):
			translated_tokens.append(token.get_string())
		_check(failures, original_tokens == translated_tokens, "format parity: " + source)
		for character in translated:
			if character.unicode_at(0) > 255:
				_check(failures, Art.CJK_SMALL.has_char(character.unicode_at(0)), "8px glyph: " + character)
				_check(failures, Art.CJK_LARGE.has_char(character.unicode_at(0)), "10px glyph: " + character)
	Lang.set_language("zh_CN")
	_check(failures, Lang.text("PHASE %d · %s", [3, "OVERDRIVE"]) == "阶段 3 / 狂涌", "nested parameters translate without touching models")
	_check(failures, Lang.text("unknown") == "unknown", "unknown strings remain visible")
	_check(failures, Lang.text("%s -%d%s", ["FLARE", 5, " POWER"]) == "炎击 -5 强化", "combat feedback parameters")
	_check(failures, Lang.language_label("en") == "English" and Lang.language_label("zh_CN") == "中文", "language names remain recognizable")
	Lang.set_language("en")
	_check(failures, Lang.text("NEXT %s", ["RUSH"]) == "NEXT RUSH", "English restores original text")
	Lang.preference = previous
	Lang.language = previous_language
	return failures


func _check(failures: Array[String], condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
