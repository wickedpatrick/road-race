class_name Race
extends RefCounted
## Whole race state. Pure logic, no scene dependencies.
signal collided(car_index: int)
signal fined
const STATION_HALF_LEN := 40.0
const STOP_SPEED := 3.0
const COLLISION_TIME_PENALTY := 5.0
const COLLISION_SPEED_KEEP := 0.3
const OFFROAD_SPEED_RATIO := 0.4
const ROLL_DECEL := 0.33 ## off the throttle the car rolls on for a long time
## speeding: the radar detector warns first; keep speeding past the grace time and the police pull you over
const GRACE := 5.0
const GRACE_EXPRESS := 10.0 ## on motorways / expressways
const TOLERANCE := 10.0 ## km/h over the posted limit before the radar detector warns and the police care
const FINE_FUEL := 10.0
const TICKET_TIME := 3.0
const PULL_OVER_DECEL := 9.0

var car_id: String
var stats: Dictionary
var stage: Dictionary
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
var speeding := 0.0 ## seconds over the limit (radar detector beeping while > 0)
var fines := 0
## police car, empty when none: {z, x, speed, phase: chase | pull_over | ticket | leave, t}
var police := {}

func _init(p_car_id: String, p_stage: Dictionary, seed_value: int) -> void:
	car_id = p_car_id
	stats = CarStats.by_id(car_id)
	stage = p_stage
	track = Track.build(stage, seed_value)
	traffic = Traffic.build(stage, seed_value)
	gearbox = Gearbox.new(stats.max_speed)
	fuel = Fuel.new(stats.tank, stats.burn, stats.max_speed)
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

## Real kilometres left to the destination.
func km_left() -> float:
	return maxf(0.0, Route.km_between(stage, z, stage.length))

func speed_limit() -> int:
	return Route.speed_limit_at(stage, z)

func _express() -> bool:
	return speed_limit() == 140

func speeding_grace() -> float:
	return GRACE_EXPRESS if _express() else GRACE

## True while the police are stopping the player or writing the ticket (the player has no control).
func held_by_police() -> bool:
	return police.get("phase", "") in ["pull_over", "ticket"]

func _update_speeding(dt: float) -> void:
	if not police.is_empty():
		return
	var kmh := speed * 3.6
	# warn above limit + 10; on motorways only slowing to the posted limit clears the warning
	var reset_kmh := float(speed_limit()) + (0.0 if _express() else TOLERANCE)
	if kmh > speed_limit() + TOLERANCE or (speeding > 0.0 and kmh > reset_kmh):
		speeding += dt
		if speeding >= speeding_grace():
			speeding = 0.0
			# the patrol car comes from behind in the next lane
			var side := 0.6 if x < 0.4 else -0.6
			police = {"z": z - 45.0, "x": clampf(x + side, -0.9, 0.9), "speed": speed + 10.0, "phase": "chase", "t": 0.0}
	else:
		speeding = 0.0

func _update_police(dt: float) -> void:
	if police.is_empty():
		return
	var p := police
	p.t += dt
	match p.phase:
		"chase":
			p.speed = maxf(speed + 12.0, 25.0)
			if p.z > z + 16.0:
				p.phase = "pull_over"
		"pull_over":
			# cut in ahead of the player and brake together with them
			p.x = move_toward(p.x, x, 0.8 * dt)
			p.speed = maxf(0.0, speed + (z + 11.0 - p.z) * 1.5)
			if speed <= 0.0 and p.speed < 0.5:
				p.speed = 0.0
				p.phase = "ticket"
				p.t = 0.0
				fines += 1
				fuel.level = maxf(0.0, fuel.level - FINE_FUEL)
				fined.emit()
		"ticket":
			if p.t >= TICKET_TIME:
				p.phase = "leave"
				p.t = 0.0
		"leave":
			p.speed = minf(p.speed + 6.0 * dt, 45.0)
			p.x = move_toward(p.x, 0.5, 0.3 * dt)
			# gone once out of sight, after a while, or when overtaken: the next offence brings it back
			if p.z > z + 400.0 or p.t > 6.0 or p.z < z - 30.0:
				police = {}
				return
	p.z += p.speed * dt

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
	var held := held_by_police()
	if held:
		input = {"accel": false, "brake": false, "steer": 0.0}
		braking = speed > 0.0
	# longitudinal
	if held:
		speed -= PULL_OVER_DECEL * dt
	elif input.brake:
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
	fuel.burn(dt, speed)
	refueling = station_in_range() and speed < STOP_SPEED and fuel.ratio() < 0.995
	if refueling:
		fuel.refuel(dt, fuel.capacity / 6.0)
	gear = gearbox.gear_for(speed)
	_update_speeding(dt)
	_update_police(dt)
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
	elif fuel.is_empty():
		state = "out_of_fuel"
