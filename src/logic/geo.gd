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

## Speed limits as posted on the signs (km/h, or mph where the country's `units` are imperial): express
## (motorway/expressway), road, city (big city), town_on_express, town.
static func limits() -> Dictionary:
	return GameData.country().limits

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
static func station() -> Dictionary:
	return GameData.country().station
