class_name Gearbox
extends RefCounted
## Automatic gearbox, forward gears only (D1-D6). There is no reverse. Like a real automatic it changes up early
## to save fuel while cruising (eco_gear) and kicks down to a lower gear while accelerating (power_gear).
const GEARS := 6
const LUG := 0.5 ## cruising, a gear is used down to this share of its top speed
const SHIFT_TIME := 0.35 ## seconds between two up-shifts
const KICKDOWN_DELAY := 0.3 ## the gas has to be held this long before the box kicks down (taps keep the gear)
var max_speed: float
var gear := 1
var _wait := 0.0
var _gas := 0.0 ## how long the gas has been held

func _init(p_max_speed: float) -> void:
	max_speed = p_max_speed

## The gear for accelerating hard: each gear covers one sixth of the speed range.
func gear_for(speed: float) -> int:
	return clampi(1 + int(maxf(speed, 0.0) / max_speed * GEARS), 1, GEARS)

## The highest gear that can pull at this speed: low revs, low consumption.
func eco_gear(speed: float) -> int:
	var g := GEARS
	while g > 1 and maxf(speed, 0.0) < top_speed_for_gear(g) * LUG:
		g -= 1
	return g

func top_speed_for_gear(g: int) -> float:
	return max_speed * float(g) / GEARS

## Share of the full pulling power available in the current gear: a high cruising gear pulls weakly, so hard
## acceleration only comes after the kick-down.
func pull(speed: float) -> float:
	return 1.0 / (1.0 + 0.6 * maxi(0, gear - gear_for(speed)))

## Engine revs as a share of the gear's top speed.
func rpm(speed: float) -> float:
	return clampf(maxf(speed, 0.0) / top_speed_for_gear(gear), 0.0, 1.0)

## Picks the gear: up one at a time while cruising, straight down (kick-down) when accelerating hard, that is with
## the gas held for a while. Short taps to keep the speed do not change down.
func update(dt: float, speed: float, accelerating: bool) -> int:
	_wait = maxf(0.0, _wait - dt)
	_gas = _gas + dt if accelerating else 0.0
	var want := eco_gear(speed)
	if accelerating:
		want = gear_for(speed) if _gas >= KICKDOWN_DELAY else gear
	if gear < gear_for(speed):
		gear = gear_for(speed) # never over-rev a gear
		_wait = SHIFT_TIME
	elif want < gear:
		gear = want
		_wait = SHIFT_TIME
	elif want > gear and _wait <= 0.0:
		gear += 1
		_wait = SHIFT_TIME
	return gear
