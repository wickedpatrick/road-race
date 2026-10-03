class_name Fuel
extends RefCounted
## Fuel use per metre is lowest at 90 km/h (ECO_SPEED). Going faster costs more per kilometre, rising to twice the
## 90 km/h amount at the car's top speed; crawling slowly costs a little more too (low gears). Standing still idles.
## Accelerating costs a lot on top (`load`: the share of the car's full acceleration being used), and a low gear at
## high revs costs more than a high gear at low revs (`rpm`: speed / top speed of the gear).
const IDLE_BURN := 0.05 ## share of `burn_at_max` used every second just idling
const ECO_SPEED := 25.0 ## m/s (90 km/h)
const ACCEL_BURN := 4.0 ## full acceleration adds this many times the 90 km/h consumption
var capacity: float
var burn_at_max: float ## litres per second at top speed
var max_speed: float
var level: float

func _init(p_capacity: float, p_burn_at_max: float, p_max_speed: float) -> void:
	capacity = p_capacity
	burn_at_max = p_burn_at_max
	max_speed = p_max_speed
	level = capacity

## Litres per metre at `speed` (without idling).
func per_metre(speed: float, load := 0.0, rpm := -1.0) -> float:
	var v := maxf(speed, 0.0)
	var eco := burn_at_max / (2.0 * max_speed)
	var base: float
	if v > ECO_SPEED:
		base = eco * (1.0 + pow((v - ECO_SPEED) / maxf(max_speed - ECO_SPEED, 1.0), 2.0))
	else:
		base = eco * (1.0 + 0.3 * pow((ECO_SPEED - v) / ECO_SPEED, 2.0))
	if rpm >= 0.0:
		base *= 0.8 + 0.4 * clampf(rpm, 0.0, 1.0)
	return base + eco * ACCEL_BURN * clampf(load, 0.0, 1.2)

## Litres per second at `speed`.
func rate(speed: float, load := 0.0, rpm := -1.0) -> float:
	return burn_at_max * IDLE_BURN + per_metre(speed, load, rpm) * maxf(speed, 0.0)

## Consumption shown to the player, in litres per 100 real kilometres (game metres per km given).
func litres_per_100km(speed: float, m_per_km: float, load := 0.0, rpm := -1.0) -> float:
	return per_metre(speed, load, rpm) * m_per_km * 100.0

func burn(dt: float, speed: float, load := 0.0, rpm := -1.0) -> void:
	level = maxf(0.0, level - rate(speed, load, rpm) * dt)

func refuel(dt: float, rate_lps: float) -> float:
	var added := minf(rate_lps * dt, capacity - level)
	level += added
	return added

func is_empty() -> bool:
	return level <= 0.0

func ratio() -> float:
	return level / capacity
