class_name CarStats
extends RefCounted
## The cars (data/rules.json "cars"). Speeds in m/s, accel/brake in m/s^2, tank in litres, burn in l/s at top speed
## (see Fuel), hp for show. Ordered from the weakest to the best; each one is faster, quicker and handles better than
## the last, and burns more.

## Car ids from the weakest to the best.
static func ids() -> Array:
	return GameData.rules().car_ids

static func has(id: String) -> bool:
	return GameData.rules().cars.has(id)

static func by_id(id: String) -> Dictionary:
	return GameData.rules().cars[id]
