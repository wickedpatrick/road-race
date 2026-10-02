class_name Fuel
extends RefCounted
## Fuel use per metre is lowest at 90 km/h (ECO_SPEED). Going faster costs more per kilometre, rising to twice the
## 90 km/h amount at the car's top speed; crawling slowly costs a little more too (low gears). Standing still idles.
const IDLE_BURN := 0.05 ## share of `burn_at_max` used every second just idling
const ECO_SPEED := 25.0 ## m/s (90 km/h)
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
func per_metre(speed: float) -> float:
	var v := maxf(speed, 0.0)
	var eco := burn_at_max / (2.0 * max_speed)
	if v > ECO_SPEED:
		return eco * (1.0 + pow((v - ECO_SPEED) / maxf(max_speed - ECO_SPEED, 1.0), 2.0))
	return eco * (1.0 + 0.3 * pow((ECO_SPEED - v) / ECO_SPEED, 2.0))

## Litres per second at `speed`.
func rate(speed: float) -> float:
	return burn_at_max * IDLE_BURN + per_metre(speed) * maxf(speed, 0.0)

## Consumption shown to the player, in litres per 100 real kilometres (game metres per km given).
func litres_per_100km(speed: float, m_per_km: float) -> float:
	return per_metre(speed) * m_per_km * 100.0

func burn(dt: float, speed: float) -> void:
	level = maxf(0.0, level - rate(speed) * dt)

func refuel(dt: float, rate_lps: float) -> float:
	var added := minf(rate_lps * dt, capacity - level)
	level += added
	return added

func is_empty() -> bool:
	return level <= 0.0

func ratio() -> float:
	return level / capacity
