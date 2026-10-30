class_name GameData
extends RefCounted
## The game's data files (see data/README.md): shared rules (cars, landscapes, landmark sizes) and one country at a
## time (map, cities, roads, facts, landmarks, traffic rules). Read once and cached. Texts in the files are
## {"pl": "...", ...} by language; the loader turns them into plain strings in the game's language.
const DIR := "res://data/"
const LANGUAGES := ["pl", "en", "cs", "is"] ## the game's languages; any other player language gets English
const FALLBACK := "en"
static var language := "pl" ## the player's language (Session sets it; set_language() reloads the texts)
static var _rules := {}
static var _countries := {} ## code -> country, loaded on first use
static var _index := [] ## countries/index.json
static var current := "pl" ## the country the player drives in

static func rules() -> Dictionary:
	if _rules.is_empty():
		_rules = load_json(DIR + "rules.json")
		var cars := {}
		for c in _rules.cars:
			c.body_color = Color(c.body_color)
			cars[c.id] = c
		_rules["car_ids"] = _rules.cars.map(func(c): return c.id)
		_rules.cars = cars
	return _rules

## All countries in the game, from countries/index.json: [{code, name, neighbours, favorite_neighbour}].
static func countries() -> Array:
	if _index.is_empty():
		_index = localize(load_json(DIR + "countries/index.json").countries)
	return _index

static func country_codes() -> Array:
	return countries().map(func(c): return c.code)

## Everything about one country (the current one by default): country.json plus "cities", "roads", "facts" and
## "landmarks" from the files next to it.
static func country(code := "") -> Dictionary:
	if code == "":
		code = current
	if not _countries.has(code):
		var dir := DIR + "countries/%s/" % code
		var c: Dictionary = localize(load_json(dir + "country.json"))
		for part in ["cities", "roads", "facts", "landmarks"]:
			var raw = load_json(dir + part + ".json")
			if part == "landmarks": # the brown board by the road names it in the country's language
				for town in raw:
					for lm in raw[town]:
						if not lm.has("local"): lm["local"] = lm.name.get(c.language, lm.name.values()[0])
			c[part] = localize(raw)
		_countries[code] = c
	return _countries[code]

## Switches the language of every text read from the data (cached countries are read again).
static func set_language(code: String) -> void:
	language = code if LANGUAGES.has(code) else FALLBACK
	_countries.clear()
	_index = []

## The game's language for a locale like "cs_CZ" or "is-IS": its own when the game has it, else English.
static func language_for(locale: String) -> String:
	var code := locale.substr(0, 2).to_lower()
	return code if LANGUAGES.has(code) else FALLBACK

## Parsed JSON file; a broken or missing file stops the game with the file name (data errors must not go unnoticed).
static func load_json(path: String) -> Variant:
	var text := FileAccess.get_file_as_string(path)
	assert(text != "", "data file missing: " + path)
	var json := JSON.new()
	var err := json.parse(text)
	assert(err == OK, "%s line %d: %s" % [path, json.get_error_line(), json.get_error_message()])
	return json.data

## Names in the player's language that replace a place's own name only when that language has one (Praha is
## "Praga" in Polish, but stays "Praha" for a language with no name of its own): no fallback to another language.
const OWN_LANGUAGE_ONLY := ["exonym", "map_name"]

## Replaces every {"pl": ..., "en": ...} text with the string in the game's language (or the first one given).
static func localize(v: Variant) -> Variant:
	if v is Dictionary:
		if _is_text(v):
			return v.get(language, v.get(FALLBACK, v.values()[0]))
		var out := {}
		for k in v:
			if k in OWN_LANGUAGE_ONLY and v[k] is Dictionary:
				if v[k].has(language): out[k] = v[k][language]
				continue
			out[k] = localize(v[k])
		return out
	if v is Array:
		return v.map(func(x): return localize(x))
	return v

## A text by language: a non-empty dictionary whose keys are all two-letter language codes and values strings.
static func _is_text(d: Dictionary) -> bool:
	if d.is_empty():
		return false
	for k in d:
		if not (k is String and k.length() == 2 and k == k.to_lower() and d[k] is String):
			return false
	return true
