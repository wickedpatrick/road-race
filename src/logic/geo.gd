class_name Geo
extends RefCounted
## The current country's map: cities, the main roads between neighbouring cities (with the towns passed, regions and
## tunnels), facts, the outline and the traffic rules. Read from data/countries/<code>/ (see GameData; the file
## formats are described in data/README.md).

## Cities by id: {name, lat, lon, pop (thousands), region, optional short (map label), label ("left"/"above"), note}.
static func cities() -> Dictionary:
	return GameData.country().cities

## Roads between neighbouring cities: {a, b, km, road, towns, zones, tunnels} (see data/README.md).
static func roads() -> Array:
	return GameData.country().roads

static func city(id: String) -> Dictionary:
	return cities()[id]

## A city's name for the player (the exonym in the game's language, e.g. "Praga"); road signs show `name`, the local one.
static func display_name(id: String) -> String:
	var c := city(id)
	return c.get("exonym", c.name)

static func city_ids() -> Array:
	return cities().keys()

static func fact(name: String) -> String:
	return GameData.country().facts.get(name, "")

## The country's outline as [lon, lat] points, and extra lines drawn with it (e.g. the Hel peninsula).
static func outline() -> Array:
	return GameData.country().outline

static func outline_lines() -> Array:
	return GameData.country().outline_lines

## Land apart from the outline, as [lon, lat] polygons (e.g. the Curonian Spit with Nida).
static func islands() -> Array:
	return GameData.country().get("islands", [])

## Speed limits as posted on the signs (km/h, or mph where the country's `units` are imperial): express
## (motorway/expressway), road, city (big city), town_on_express, town.
## `part`: the part of a map spanning several countries (see part()), "" for the map's own.
static func limits(p := "") -> Dictionary:
	return part(p).limits

## Traffic drives on the left (Great Britain): the world is drawn mirrored, the logic stays the same.
static func left_hand() -> bool:
	return GameData.country().get("drive", "right") == "left"

## The road signs give speeds in mph and distances in miles.
static func miles() -> bool:
	return GameData.country().get("units", "metric") == "imperial"

## A posted limit in km/h, for the game's logic.
static func limit_kmh(posted: int) -> int:
	return roundi(posted * Units.KM_PER_MILE) if miles() else posted

## Kilometres as the road signs give them (miles where the country uses them).
static func sign_distance(km: float) -> int:
	return roundi(km / Units.KM_PER_MILE) if miles() else roundi(km)

## The fuel station's texts in the country's language: sign (by the road), board (over the price list), prices
## [[fuel, price], ...], region_sign (the word on the region boards). See data/README.md.
## `p`: the part of a multi-country map (see part()), "" for the map's own.
static func station(p := "") -> Dictionary:
	return part(p).station

## One part of a map spanning several countries (the Southern Balkans: Montenegro, Kosovo, Albania, North Macedonia):
## country.json's `parts[p]` over the map's own settings (dictionaries such as `limits`, `station`, `signs` merged key
## by key, anything else replaced). "" or a code the map has no part for: the map's own settings.
static func part(p := "") -> Dictionary:
	var c := GameData.country()
	var parts: Dictionary = c.get("parts", {})
	if p == "" or not parts.has(p):
		return c
	if not c.has("_merged"):
		c["_merged"] = {}
	if not c._merged.has(p):
		var m := {}
		for k in c:
			if k != "_merged": m[k] = c[k]
		for k in parts[p]:
			var v = parts[p][k]
			m[k] = c[k].merged(v, true) if v is Dictionary and c.get(k) is Dictionary else v
		c._merged[p] = m
	return c._merged[p]

## The part of the map a city lies in (its `country` in cities.json), "" on a single-country map.
static func city_part(id: String) -> String:
	return city(id).get("country", "")

## The part of the map the track position z lies in: the start city's, changed at every border crossing passed.
static func part_at(stage: Dictionary, z: float) -> String:
	var p: String = stage.get("part0", "")
	for b in stage.get("borders", []):
		if z >= b.z: p = b.to
	return p
