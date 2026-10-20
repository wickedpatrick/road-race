class_name Gearbox
extends RefCounted
## Automatic gearbox, forward gears only (D1-D6). There is no reverse. Works like a real automatic:
## - accelerating hard it holds every gear up to the red line (gear_for: the gear with the most power),
## - off the gas or holding the speed it changes up early to keep the revs low, two gears at once when the engine
##   keeps enough revs and pull in the higher gear (D3 -> D5),
## - pressing the gas for a moment kicks down two gears (D5 -> D3), keeping it pressed goes down to the most
##   powerful gear; short taps to keep the speed do not change down,
## - slowing down it changes down as the revs fall, one gear at a time, or straight to the right gear when braking
##   hard (the gap between LUG_UP and LUG_DOWN keeps the gear from hunting at a steady speed),
## - uphill (`need` > 0) it changes up only when the higher gear can still hold the speed, downhill it keeps the
##   gear for engine braking.
const GEARS := 6
const LUG_UP := 0.5 ## a higher gear is chosen only when the revs stay at least at this share of its top speed
const LUG_DOWN := 0.38 ## below this the engine labours and the box changes down
const STALL := 0.2 ## revs this low (after hard braking) drop straight to the right gear
const TORQUE_FALL := 0.35 ## below these revs the engine loses torque
const MIN_PULL := 0.25
const SHIFT_TIME := 0.35 ## seconds after an up-shift before the next shift
const DOWN_SHIFT_TIME := 0.15 ## after a down-shift (quicker, so the box keeps up when braking)
const KICKDOWN_DELAY := 0.3 ## the gas has to be held this long before the box kicks down (taps keep the gear)
const FULL_POWER_DELAY := 1.0 ## gas held this long: down to the most powerful gear
const KICKDOWN_STEP := 2
const SKIP_STEP := 2
const KICKDOWN_BELOW := 0.9 ## no kick-down when the gear already pulls at least this share of the full power
const RESERVE := 1.25 ## a higher gear has to pull this many times what holding the speed needs
const ENGINE_BRAKE := -0.15 ## `need` below this (downhill) keeps the gear
var max_speed: float
var gear := 1
var _wait := 0.0
var _gas := 0.0 ## how long the gas has been held
var _kicked := false ## the kick-down for this press of the gas has happened

func _init(p_max_speed: float) -> void:
	max_speed = p_max_speed

## The gear for accelerating hard: each gear covers one sixth of the speed range.
func gear_for(speed: float) -> int:
	return clampi(1 + int(maxf(speed, 0.0) / max_speed * GEARS), 1, GEARS)

func top_speed_for_gear(g: int) -> float:
	return max_speed * float(g) / GEARS

## Engine revs in gear g as a share of the gear's top speed (1.0 = red line).
func rpm_in(speed: float, g: int) -> float:
	return clampf(maxf(speed, 0.0) / top_speed_for_gear(g), 0.0, 1.0)

## Engine revs in the current gear.
func rpm(speed: float) -> float:
	return rpm_in(speed, gear)

## Engine power at revs r: constant torque (power grows with the revs), less torque at very low revs.
static func _power(r: float) -> float:
	return r * (1.0 if r >= TORQUE_FALL else lerpf(0.5, 1.0, r / TORQUE_FALL))

## Share of the full pulling power available in gear g: a higher gear runs at lower revs and pulls weaker.
func pull_in(speed: float, g: int) -> float:
	var best := gear_for(speed)
	if g <= best:
		return 1.0
	return clampf(_power(rpm_in(speed, g)) / maxf(_power(rpm_in(speed, best)), 0.0001), MIN_PULL, 1.0)

## Share of the full pulling power in the current gear.
func pull(speed: float) -> float:
	return pull_in(speed, gear)

## The highest gear that keeps the revs up and can hold the speed (`need`: share of the full power that holding
## the speed takes, more uphill): low revs, low consumption.
func eco_gear(speed: float, need := 0.0) -> int:
	var best := gear_for(speed)
	for g in range(GEARS, best, -1):
		if rpm_in(speed, g) >= LUG_UP and pull_in(speed, g) >= need * RESERVE:
			return g
	return best

## Picks the gear for this step. `accelerating`: the gas is down; `need`: see eco_gear (negative downhill).
func update(dt: float, speed: float, accelerating: bool, need := 0.0) -> int:
	_wait = maxf(0.0, _wait - dt)
	if accelerating:
		_gas += dt
	else:
		_gas = 0.0
		_kicked = false
	var best := gear_for(speed)
	if gear < best:
		_shift(best) # never over-rev a gear
	elif gear > 1 and rpm(speed) < STALL:
		_shift(best if accelerating else eco_gear(speed, need))
	elif _wait > 0.0:
		pass
	elif gear > best and (rpm(speed) < LUG_DOWN or pull(speed) < need):
		var g := gear - 1
		while g > best and (rpm_in(speed, g) < LUG_DOWN or pull_in(speed, g) < need):
			g -= 1 # braking hard: one gear down is not enough
		_shift(g)
	elif accelerating:
		if _gas >= FULL_POWER_DELAY and gear > best and pull(speed) < KICKDOWN_BELOW:
			_shift(best)
		elif _gas >= KICKDOWN_DELAY and not _kicked:
			_kicked = true
			if pull(speed) < KICKDOWN_BELOW:
				_shift(maxi(best, gear - KICKDOWN_STEP))
	else:
		var want := eco_gear(speed, need)
		if need <= ENGINE_BRAKE:
			want = mini(want, gear)
		if want > gear:
			_shift(gear + (SKIP_STEP if want >= gear + SKIP_STEP else 1))
	return gear

func _shift(g: int) -> void:
	if g != gear:
		_wait = SHIFT_TIME if g > gear else DOWN_SHIFT_TIME
		gear = g
