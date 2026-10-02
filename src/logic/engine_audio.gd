class_name EngineAudio
extends RefCounted
## Engine note for the automatic gearbox: pitch climbs inside a gear and drops when it shifts up.
const IDLE := 0.7
const MIN_PITCH := 0.6
const MAX_PITCH := 2.0
static func pitch(speed: float, max_speed: float, throttle: bool) -> float:
	var gb := Gearbox.new(max_speed)
	var s := maxf(speed, 0.0)
	var g := gb.gear_for(s)
	var lo := gb.top_speed_for_gear(g - 1) if g > 1 else 0.0
	var hi := gb.top_speed_for_gear(g)
	var r := clampf((s - lo) / maxf(hi - lo, 0.001), 0.0, 1.0)
	return clampf(IDLE + 0.85 * r + (0.12 if throttle else 0.0), MIN_PITCH, MAX_PITCH)
