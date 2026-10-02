class_name Race
extends RefCounted
## Whole race state. Pure logic, no scene dependencies.
signal collided(car_index: int)
const STATION_HALF_LEN := 40.0
const STOP_SPEED := 3.0
const COLLISION_TIME_PENALTY := 5.0
const COLLISION_SPEED_KEEP := 0.3
const OFFROAD_SPEED_RATIO := 0.4
const ROLL_DECEL := 4.0

var car_id: String
var stats: Dictionary
var stage: Dictionary
var stage_index: int
var track: Track
var traffic: Traffic
var gearbox: Gearbox
var fuel: Fuel

var speed := 0.0
var z := 0.0
var x := 0.0
var time_left: float
var elapsed := 0.0
var gear := 1
var state := "running" ## running | won | out_of_time | out_of_fuel
var refueling := false
var braking := false
var steer_visual := 0.0
var hit_cooldown := 0.0
var hit_flash := 0.0

func _init(p_car_id: String, p_stage_index: int, seed_value: int) -> void:
	car_id = p_car_id
	stage_index = p_stage_index
	stats = CarStats.by_id(car_id)
	stage = StageData.at(stage_index)
	track = Track.build(stage, seed_value)
	traffic = Traffic.build(stage, seed_value)
	gearbox = Gearbox.new(stats.max_speed)
	fuel = Fuel.new(stats.tank, stats.burn)
	time_left = stage.duration

func speed_ratio() -> float:
	return clampf(speed / stats.max_speed, 0.0, 1.0)

func progress() -> float:
	return clampf(z / stage.length, 0.0, 1.0)

## Distance to the next station ahead (or still inside the zone), -1 when there is none left.
func next_station_distance() -> float:
	for s in stage.stations:
		if s - z > -STATION_HALF_LEN:
			return s - z
	return -1.0

## After the race ended: the car rolls out and slows down; time and fuel no longer matter.
func coast_after_finish(dt: float) -> void:
	speed = maxf(0.0, speed - stats.brake * 0.5 * dt)
	z += speed * dt
	hit_flash = maxf(0.0, hit_flash - dt)
	traffic.update(dt)

func station_in_range() -> bool:
	for s in stage.stations:
		if absf(z - s) < STATION_HALF_LEN:
			return true
	return false

func step(dt: float, input: Dictionary) -> void:
	if state != "running":
		return
	elapsed += dt
	time_left -= dt
	hit_cooldown = maxf(0.0, hit_cooldown - dt)
	hit_flash = maxf(0.0, hit_flash - dt)
	braking = input.brake
	var vmax: float = stats.max_speed
	# longitudinal
	if input.brake:
		speed -= stats.brake * dt
	elif input.accel and not fuel.is_empty():
		speed += stats.accel * (1.15 - speed_ratio()) * dt
	else:
		speed -= ROLL_DECEL * dt
	if absf(x) > 1.0:
		var cap := vmax * OFFROAD_SPEED_RATIO
		if speed > cap:
			speed = maxf(cap, speed - 35.0 * dt)
	speed = clampf(speed, 0.0, vmax)
	# lateral
	var steer: float = clampf(input.steer, -1.0, 1.0)
	steer_visual = lerpf(steer_visual, steer, minf(1.0, dt * 10.0))
	var sr := speed_ratio()
	x += steer * stats.handling * 2.2 * clampf(speed / 12.0, 0.0, 1.0) * dt
	x -= track.segment_at(z).curve * 0.35 * sr * sr * dt
	x = clampf(x, -1.8, 1.8)
	z += speed * dt
	# fuel and stations
	fuel.burn(dt, sr)
	refueling = station_in_range() and speed < STOP_SPEED and fuel.ratio() < 0.995
	if refueling:
		fuel.refuel(dt, fuel.capacity / 6.0)
	gear = gearbox.gear_for(speed)
	# traffic
	traffic.update(dt)
	var parked_at_station := station_in_range() and speed < STOP_SPEED
	if hit_cooldown <= 0.0 and not parked_at_station and z < stage.length:
		var idx := traffic.check_collision(z, x, stats.halfwidth, speed)
		if idx >= 0:
			var car: Dictionary = traffic.cars[idx]
			speed *= COLLISION_SPEED_KEEP
			time_left -= COLLISION_TIME_PENALTY
			hit_cooldown = 1.0
			hit_flash = 0.6
			# slide fully clear of the car so the same bump cannot repeat
			var clear: float = Traffic.KINDS[car.kind].half + stats.halfwidth + 0.08
			x = clampf(car.lane_x + (clear if x >= car.lane_x else -clear), -1.8, 1.8)
			collided.emit(idx)
	# end of race
	if z >= stage.length:
		state = "won"
		time_left = maxf(time_left, 0.0)
	elif time_left <= 0.0:
		time_left = 0.0
		state = "out_of_time"
	elif fuel.is_empty() and speed <= 0.0:
		state = "out_of_fuel"
