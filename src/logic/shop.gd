class_name Shop
extends RefCounted
## The shop's products (prices in euros) and what the bought ones do. Nothing is paid yet: buying always succeeds
## (Session.buy, a fake store until the App Store and Google Play payments come). The upgrades work on every car;
## a product of a higher `level` in a `group` takes the lower one's place (+10% top speed instead of +5%).
## `country_one` is bought for a country picked on the map of countries (Session.unlocked_countries).
const PRODUCTS := [
	{"id": "tank_10", "price": 1},
	{"id": "speed_5", "price": 1, "group": "speed", "level": 1},
	{"id": "speed_10", "price": 2, "group": "speed", "level": 2},
	{"id": "brakes_10", "price": 1, "group": "brakes", "level": 1},
	{"id": "brakes_20", "price": 2, "group": "brakes", "level": 2},
	{"id": "lights", "price": 1},
	{"id": "police_chance", "price": 1},
	{"id": "police_150", "price": 1},
	{"id": "cars_all", "price": 2},
	{"id": "country_one", "price": 1},
	{"id": "countries_all", "price": 10},
]
const SPEED := [1.0, 1.05, 1.1] ## top speed by the "speed" level
const BRAKES := [1.0, 1.1, 1.2]
const TANK_EXTRA := 10.0 ## litres
const LIGHTS := 3.4 ## the headlights' reach, times the car's own
const POLICE_ESCAPE := 0.5 ## added to the chance an officer can be shaken off (rules police.escape_chance)
const ESCAPE_KMH := 150.0 ## instead of rules police.escape_kmh

static func product(id: String) -> Dictionary:
	for p in PRODUCTS:
		if p.id == id: return p
	return {}

static func owns(bought: Array, id: String) -> bool:
	return bought.has(id)

## The level bought in a group (0: none).
static func level(bought: Array, group: String) -> int:
	var l := 0
	for p in PRODUCTS:
		if p.get("group", "") == group and bought.has(p.id):
			l = maxi(l, p.level)
	return l

## Whether a product can still be bought: not owned, nor a higher level of its group.
static func can_buy(bought: Array, id: String) -> bool:
	var p := product(id)
	if p.is_empty() or bought.has(id):
		return false
	if p.has("group"):
		return level(bought, p.group) < p.level
	return true

static func price_text(id: String) -> String:
	return "%d €" % product(id).price

## The car's figures with the upgrades bought (a copy; the rules' own stay as they are).
static func tuned(stats: Dictionary, bought: Array) -> Dictionary:
	var s := stats.duplicate()
	s.max_speed = stats.max_speed * SPEED[level(bought, "speed")]
	s.brake = stats.brake * BRAKES[level(bought, "brakes")]
	if bought.has("tank_10"):
		s.tank = stats.tank + TANK_EXTRA
	return s

## The stage's settings the upgrades change (Session.stage): the police. (The headlights: game.gd, by `lights`.)
static func stage_mods(bought: Array) -> Dictionary:
	var m := {}
	if bought.has("police_chance"):
		m["police_escape"] = minf(1.0, GameData.rules().police.escape_chance + POLICE_ESCAPE)
	if bought.has("police_150"):
		m["escape_kmh"] = ESCAPE_KMH
	return m
