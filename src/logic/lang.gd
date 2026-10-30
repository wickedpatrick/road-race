class_name Lang
extends RefCounted
## Interface texts in the player's language (GameData.language), from data/ui.json: key -> {pl, en, cs, is}.
## A missing translation falls back to English, a missing key shows the key.
const NAMES := {"pl": "Polski", "en": "English", "cs": "Čeština", "is": "Íslenska"}
static var _ui := {}

static func t(key: String) -> String:
	if _ui.is_empty():
		_ui = GameData.load_json(GameData.DIR + "ui.json")
	var e = _ui.get(key)
	if e == null:
		push_error("ui text missing: " + key)
		return key
	return e.get(GameData.language, e.get(GameData.FALLBACK, key))

## Decimal comma everywhere but in English.
static func decimal(text: String) -> String:
	return text if GameData.language == "en" else text.replace(".", ",")
