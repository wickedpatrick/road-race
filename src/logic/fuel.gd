class_name Fuel
extends RefCounted
const IDLE_BURN := 0.1
var capacity: float
var burn_per_sec: float
var level: float
func _init(p_capacity: float, p_burn_per_sec_at_max: float) -> void:
	capacity = p_capacity
	burn_per_sec = p_burn_per_sec_at_max
	level = capacity
func burn(dt: float, speed_ratio: float) -> void:
	level = maxf(0.0, level - burn_per_sec * dt * (IDLE_BURN + (1.0 - IDLE_BURN) * clampf(speed_ratio, 0.0, 1.0)))
func refuel(dt: float, rate: float) -> float:
	var added := minf(rate * dt, capacity - level)
	level += added
	return added
func is_empty() -> bool:
	return level <= 0.0
func ratio() -> float:
	return level / capacity
