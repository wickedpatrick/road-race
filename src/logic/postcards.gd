class_name Postcards
extends RefCounted
## The collection: every city on a country's map has a postcard of its landmark(s) (one or two, Landmarks.by_town()).
## A visit gives it with one stamp; arriving with time to spare gives up to five (rules.json "postcards"), and the
## best result is kept. The towns with a landmark on the roads between the map cities have postcards too, collected
## by driving through (no stamps for time); the album lists them under their routes. A country's postcards:
## {city_id or town name: {"stamps": 1..5, "year": first earned}} (town names and city ids never clash: "krakow",
## "Tarnów"; "year" missing on postcards from profiles older than the postcards).
const MAX_STAMPS := 5
static var _routes := {} ## code -> routes() (the album asks every frame; town names are data keys, the same in every language)

## The country's map cities, biggest first (the album's order).
static func cities(code: String) -> Array:
	var map: Dictionary = GameData.country(code).cities
	var ids := map.keys()
	ids.sort_custom(func(a, b): return map[a].pop > map[b].pop)
	return ids

## The landmarks on a postcard (a map city's id or a town's name): [{kind, name, desc, ...}], none, one or two.
static func landmarks(code: String, id: String) -> Array:
	var cn := GameData.country(code)
	var place: String = cn.cities[id].name if cn.cities.has(id) else id
	return (cn.landmarks.get(place, []) as Array).slice(0, 2)

## The roads between neighbouring map cities that pass towns with a landmark: [{a, b, towns}], `a` the bigger city,
## towns in order from it; biggest `a` first, then biggest `b`. A town on two roads is under both.
static func routes(code: String) -> Array:
	if _routes.has(code):
		return _routes[code]
	var cn := GameData.country(code)
	var out := []
	for r in cn.roads:
		var big: bool = cn.cities[r.a].pop >= cn.cities[r.b].pop
		var towns := (r.towns as Array).filter(func(t): return cn.landmarks.has(t[0]) and not landmarks(code, t[0]).is_empty())
		if towns.is_empty():
			continue
		var names := towns.map(func(t): return t[0])
		if not big:
			names.reverse()
		out.append({"a": r.a if big else r.b, "b": r.b if big else r.a, "towns": names})
	out.sort_custom(func(x, y): return cn.cities[x.a].pop > cn.cities[y.a].pop or (x.a == y.a and cn.cities[x.b].pop > cn.cities[y.b].pop))
	_routes[code] = out
	return out

## Every town with a postcard (each once).
static func towns(code: String) -> Array:
	var out := []
	for rt in routes(code):
		for tn in rt.towns:
			if not out.has(tn): out.append(tn)
	return out

## Stamps for arriving with `time_left` of `duration`: 1, and one more for each threshold of the share left reached.
## The last stamp needs a fast car too (rules.json postcards "top_stamp_car", its place in the car list from 1):
## with a slower one the result stops a stamp short (`car` "" counts as fast enough).
static func stamps_for(time_left: float, duration: float, car := "") -> int:
	var share := time_left / duration if duration > 0.0 else 0.0
	var n := 1
	for th in GameData.rules().postcards.stamps:
		if share >= th: n += 1
	n = mini(n, MAX_STAMPS)
	if n == MAX_STAMPS and car != "" and not top_stamp_car(car):
		n -= 1
	return n

## The car can earn the last stamp: it is the "top_stamp_car" in the car list or a later (faster) one.
static func top_stamp_car(car: String) -> bool:
	return CarStats.ids().find(car) + 1 >= int(GameData.rules().postcards.get("top_stamp_car", 1))

## The slowest car that can earn the last stamp.
static func first_top_stamp_car() -> String:
	var ids := CarStats.ids()
	return ids[clampi(int(GameData.rules().postcards.get("top_stamp_car", 1)) - 1, 0, ids.size() - 1)]

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

## A country's album in numbers: postcards earned of all (cities and towns), the cities' stamps of the most there are.
static func summary(code: String, cards: Dictionary) -> Dictionary:
	var ids := cities(code)
	var all := ids + towns(code)
	var stamps := 0
	for id in ids:
		if cards.has(id): stamps += int(cards[id].stamps)
	return {"earned": all.filter(func(id): return cards.has(id)).size(), "all": all.size(), "stamps": stamps, "max": ids.size() * MAX_STAMPS}

static func total(cards: Dictionary) -> int:
	var n := 0
	for id in cards:
		n += int(cards[id].stamps)
	return n
