class_name Units
extends RefCounted
## Units for the interface (speedometer, distances, fuel use): the country's, like its road signs (Geo.miles):
## miles, mph and mpg in Britain, kilometres elsewhere. The game itself counts in km and km/h.
const KM_PER_MILE := 1.609344
const L100_MPG := 282.481 ## litres per 100 km -> miles per (imperial) gallon
const L100_MPG_US := 235.215 ## the same for the smaller US gallon (a country with "gallon": "us")
static func imperial() -> bool:
	return Geo.miles()

static func speed(kmh: float) -> int:
	return roundi(kmh / KM_PER_MILE) if imperial() else roundi(kmh)

static func speed_unit() -> String:
	return "mph" if imperial() else "km/h"

## "130 km/h" / "81 mph"
static func speed_text(kmh: float) -> String:
	return "%d %s" % [speed(kmh), speed_unit()]

static func dist(km: float) -> float:
	return km / KM_PER_MILE if imperial() else km

static func dist_unit() -> String:
	return "mi" if imperial() else "km"

## Whole kilometres or miles: "45 km" / "28 mi"
static func dist_text(km: float, round_up := false) -> String:
	var d := dist(km)
	return "%d %s" % [int(ceil(d)) if round_up else int(d), dist_unit()]

## Fuel use: "6,4 l/100 km" / "44 mpg"
static func consumption_text(l100: float) -> String:
	if imperial():
		var k := L100_MPG_US if GameData.country().get("gallon", "") == "us" else L100_MPG
		return "%d mpg" % roundi(k / maxf(l100, 0.1))
	return Lang.decimal("%.1f l/100 km" % l100)
