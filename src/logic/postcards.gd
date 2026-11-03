class_name Postcards
extends RefCounted
## The collection: every city on a country's map has a postcard of its landmark(s) (one or two, Landmarks.by_town()).
## A visit gives it with one stamp; arriving with time to spare gives up to five (rules.json "postcards"), and the
## best result is kept. A country's postcards: {city_id: {"stamps": 1..5, "year": first earned}} ("year" missing on
## postcards from profiles older than the postcards).
const MAX_STAMPS := 5

## The country's map cities, biggest first (the album's order).
static func cities(code: String) -> Array:
	var map: Dictionary = GameData.country(code).cities
	var ids := map.keys()
	ids.sort_custom(func(a, b): return map[a].pop > map[b].pop)
	return ids

## The landmarks on a city's postcard: [{kind, name, desc, ...}], one or two.
static func landmarks(code: String, id: String) -> Array:
	var cn := GameData.country(code)
	return (cn.landmarks.get(cn.cities[id].name, []) as Array).slice(0, 2)

## Stamps for arriving with `time_left` of `duration`: 1, and one more for each threshold of the share left reached.
static func stamps_for(time_left: float, duration: float) -> int:
	var share := time_left / duration if duration > 0.0 else 0.0
	var n := 1
	for th in GameData.rules().postcards.stamps:
		if share >= th: n += 1
	return mini(n, MAX_STAMPS)

## Gives the postcards of the cities among `ids` not collected yet (one stamp); returns those ids.
static func grant(cards: Dictionary, ids: Array, year: int) -> Array:
	var new := []
	for id in ids:
		if not cards.has(id):
			cards[id] = {"stamps": 1, "year": year}
			new.append(id)
	return new

## Raises a postcard to `n` stamps (never lowers it), creating it if needed; returns the stamps it had (0: none).
static func stamp(cards: Dictionary, id: String, n: int, year: int) -> int:
	var before: int = cards.get(id, {}).get("stamps", 0)
	if before == 0:
		cards[id] = {"stamps": n, "year": year}
	elif n > before:
		cards[id].stamps = n
	return before

## Profiles from before the postcards: every visited map city gets its postcard with one stamp.
static func migrate(cards: Dictionary, visited: Array, map_ids: Array) -> void:
	for id in visited:
		if map_ids.has(id) and not cards.has(id):
			cards[id] = {"stamps": 1}

## migrate() for every country in a profile's `places` (code -> {visited, postcards, ...}).
static func migrate_places(places: Dictionary) -> void:
	for code in places:
		var p = places[code]
		if not p is Dictionary or not GameData.country_codes().has(code):
			continue
		if not p.get("postcards") is Dictionary:
			p["postcards"] = {}
		migrate(p.postcards, p.get("visited", []) if p.get("visited") is Array else [], GameData.country(code).cities.keys())

## A country's album in numbers: postcards earned of all, stamps of the most there are.
static func summary(code: String, cards: Dictionary) -> Dictionary:
	var ids := cities(code)
	var earned := ids.filter(func(id): return cards.has(id))
	var stamps := 0
	for id in earned:
		stamps += int(cards[id].stamps)
	return {"earned": earned.size(), "all": ids.size(), "stamps": stamps, "max": ids.size() * MAX_STAMPS}

static func total(cards: Dictionary) -> int:
	var n := 0
	for id in cards:
		n += int(cards[id].stamps)
	return n
