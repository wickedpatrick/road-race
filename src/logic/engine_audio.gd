class_name EngineAudio
extends RefCounted
## Engine note for the automatic gearbox: pitch follows the revs in the current gear, so it drops on every up-shift,
## stays low while cruising in a high gear and rises on a kick-down.
const IDLE := 0.7
const MIN_PITCH := 0.6
const MAX_PITCH := 2.0
const IDLE_REVS := 0.3 ## below this share of the gear's top speed the engine sounds like idling
static func pitch(speed: float, max_speed: float, throttle: bool, gear := -1) -> float:
	var gb := Gearbox.new(max_speed)
	var s := maxf(speed, 0.0)
	gb.gear = gear if gear > 0 else gb.gear_for(s)
	var r := clampf((gb.rpm(s) - IDLE_REVS) / (1.0 - IDLE_REVS), 0.0, 1.0)
	return clampf(IDLE + 0.85 * r + (0.12 if throttle else 0.0), MIN_PITCH, MAX_PITCH)
