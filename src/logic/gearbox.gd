class_name Gearbox
extends RefCounted
## Automatic gearbox, forward gears only (D1-D6). There is no reverse.
const GEARS := 6
var max_speed: float
func _init(p_max_speed: float) -> void:
	max_speed = p_max_speed
func gear_for(speed: float) -> int:
	return clampi(1 + int(maxf(speed, 0.0) / max_speed * GEARS), 1, GEARS)
func top_speed_for_gear(g: int) -> float:
	return max_speed * float(g) / GEARS
