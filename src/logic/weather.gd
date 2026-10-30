class_name Weather
extends RefCounted
## The weather of a trip. Every road has one, from the country's "weather" rules (data/README.md): a road's own
## "weather", else the region of either end city ("cities": Scotland -> rain), else its longest landscape (the
## country's "biomes", then rules.json biomes), else the country's default. The map shows it on every road.
## It sets the look (season of the ground, sky, rain or snow falling, fog) and the driving: grip and the time limit.
const KINDS := ["sun", "cloudy", "rain", "fog", "autumn", "snow"]
## the ground, trees and fields as in this season (SeasonPalette)
const SEASON := {"sun": "summer", "cloudy": "summer", "rain": "summer", "fog": "summer", "autumn": "autumn", "snow": "winter"}
## share of the car's grip: steering (and holding a bend), braking, pulling away
const GRIP := {
	"rain": {"steer": 0.92, "brake": 0.75, "accel": 1.0},
	"snow": {"steer": 0.72, "brake": 0.55, "accel": 0.8},
}
## more time for the trip where the weather slows the car down
const TIME := {"rain": 1.05, "fog": 1.08, "snow": 1.15}
## the look on top of the season's palette
const SKY := {
	"cloudy": {"sky_top": Color("8d9aa6"), "sky_bottom": Color("d3d9de"), "mountain": Color("8e9aa3"), "sun": false},
	"rain": {"sky_top": Color("5f6b76"), "sky_bottom": Color("a9b2ba"), "mountain": Color("6f7a82"), "sun": false,
		"road_a": Color("4f5257"), "road_b": Color("4c4f54"), "particle": "rain"},
	"fog": {"sky_top": Color("c3c9ce"), "sky_bottom": Color("dde1e4"), "mountain": Color("d5dadd"), "sun": false},
}

## The weather on a road between two cities (a road from Geo.roads()).
static func for_road(road: Dictionary) -> String:
	if KINDS.has(road.get("weather", "")):
		return road.weather
	var rules: Dictionary = GameData.country().get("weather", {})
	var by_city: Dictionary = rules.get("cities", {})
	for id in [road.a, road.b]:
		var region: String = Geo.city(id).region
		if by_city.has(region):
			return by_city[region]
	var fallback: String = rules.get("default", "sun")
	if not rules.get("landscape", true):
		return fallback
	var biome := ""
	var longest := -1.0
	var prev := 0.0
	for zn in road.zones:
		if zn[0] - prev > longest:
			longest = zn[0] - prev
			biome = zn[1]
		prev = zn[0]
	return rules.get("biomes", {}).get(biome, Biome.get_data(biome).get("weather", fallback))

## The weather of a trip (legs from Route.find()): its longest road's.
static func for_legs(legs: Array) -> String:
	var best: Dictionary = legs[0].road
	for leg in legs:
		if leg.road.km > best.km:
			best = leg.road
	return for_road(best)

static func season(kind: String) -> String:
	return SEASON.get(kind, "summer")

## The colours to draw with: the season's palette with this weather's sky (and wet road, rain).
static func palette(kind: String) -> Dictionary:
	var pal := SeasonPalette.by_name(season(kind)).duplicate()
	pal.merge(SKY.get(kind, {}), true)
	return pal

## Share of grip for "steer", "brake" or "accel" (1 in dry weather).
static func grip(kind: String, what: String) -> float:
	return GRIP.get(kind, {}).get(what, 1.0)

static func time_factor(kind: String) -> float:
	return TIME.get(kind, 1.0)

## Thick fog: the view fades to white within this share of the drawing distance (0 = clear).
static func fog_reach(kind: String) -> float:
	return 0.32 if kind == "fog" else 0.0

static func label(kind: String) -> String:
	return Lang.t("weather_" + kind)
