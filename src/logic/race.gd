class_name Race
extends RefCounted
## Whole race state. Pure logic, no scene dependencies.
signal collided(car_index: int)
signal crashed ## hit a sign, a tree, a lamp post or a tunnel wall
signal fined
const STATION_HALF_LEN := 40.0
const STOP_SPEED := 3.0
const SHOULDER_MIN := 0.5 ## fraction of the car that must be off the road to refuel
const COLLISION_TIME_PENALTY := 5.0
const COLLISION_SPEED_KEEP := 0.3
const COLLISION_FUEL := 3.0 ## litres lost in every bump
const OFFROAD_SPEED := 40.0 / 3.6 ## off the road (on the shoulder or the grass) the car slows down to this
const OFFROAD_DECEL := 30.0 ## m/s^2 while slowing down to OFFROAD_SPEED: hard, like braking
const CRASH_FUEL := 3.0 ## litres lost when the car hits a roadside obstacle (it stops dead)
const CRASH_FRONT := 2.0 ## the car's front is this far ahead of z (an obstacle is hit when the front reaches it)
const STATION_MAX_X := 1.4 ## at a station the kerb past the pit lane keeps the car off the pumps
const MEDIAN_X := 1.3 ## on a dual carriageway the barrier in the median stops the car here (left of the road edge)
const ROLL_DECEL := 0.1 ## off the throttle the car rolls on for a long time
## hills: the slope pulls with this share of gravity. Track grades are drawn steeper than real (see Track.MAX_GRADE),
## the game's acceleration is arcade-strong; together a weak car loses speed on a climb. Downhill less, so the car
## does not run away off the gas.
const GRAVITY := 9.81
const GRADE_K := 0.7
const DOWNHILL_K := 0.5
const ENGINE_BRAKE := 0.5 ## m/s^2 at full revs, off the gas downhill (the gearbox holds the gear)
const STEER_RATE := 2.2 ## road half-widths per second at full lock, times stats.handling
const CORNER_K := 0.35 ## a bend pushes the car outwards by curve * CORNER_K * (speed / CORNER_REF)^2 per second
const CORNER_REF := 50.0 ## m/s; the push depends on the real speed, so every car feels a bend alike at the same km/h
## too fast for a bend: the push beyond what the steering can hold is softened (SLIDE_K) and capped (SLIDE_MAX road
## half-widths per second), so the car slides wide over a second or two instead of being flung off the road
const SLIDE_K := 0.3
const SLIDE_MAX := 1.2
const TUNNEL_SCRAPE := 0.1 ## metres the car may reach into a tunnel wall: enough to hit it, never to see past it
const DOWNHILL_BURN := 0.3 ## share of the usual fuel use while rolling downhill off the gas (fuel cut-off)
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
var scenery: Dictionary ## roadside objects per track segment (Scenery.build), drawn by WorldView
var obstacles: Dictionary ## segment -> [[z, lat0, lat1], ...]: solid parts of the roadside objects (Scenery.obstacles)
var gearbox: Gearbox
var fuel: Fuel

var speed := 0.0
var z := 0.0
var x := 0.0
var time_left: float
var elapsed := 0.0
var gear := 1
var load := 0.0 ## share of full acceleration used this step (extra fuel)
var state := "running" ## running | won | out_of_time | out_of_fuel
var refueling := false
var braking := false
var steer_visual := 0.0
var hit_cooldown := 0.0
var hit_flash := 0.0
var last_hit := -100.0 ## `elapsed` at the last bump (the HUD shows the penalty for a while)
var last_crash := -100.0 ## `elapsed` at the last hit of a roadside obstacle
var head_on := false ## the last bump was with an oncoming car
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
	scenery = Scenery.build(stage, 1)
	Scenery.bend_signs(scenery, track.sharp)
	obstacles = Scenery.obstacles(scenery, stage)
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
	traffic.update(dt, z, x, speed)

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

## How hard a bend of curve 1 pushes the car outwards at `v` (road half-widths per second); the steering can hold
## stats.handling * STEER_RATE against it.
static func corner_push(v: float) -> float:
	return CORNER_K * pow(v / CORNER_REF, 2.0)

## Outward push of a bend of `curve` at `v` (road half-widths per second, signed like the curve) for a car that
## holds `grip` with the steering: in full up to the grip, softened and capped beyond it.
static func bend_push(curve: float, v: float, grip: float) -> float:
	var p := absf(curve) * corner_push(v)
	if p > grip:
		p = grip + minf((p - grip) * SLIDE_K, SLIDE_MAX)
	return signf(curve) * p

## Highest speed the steering can hold a bend of this curve at (m/s).
func corner_speed(curve: float) -> float:
	if absf(curve) < 0.001:
		return stats.max_speed
	return CORNER_REF * sqrt(stats.handling * STEER_RATE / (CORNER_K * absf(curve)))

## Roadside obstacle (sign post, tree, lamp, tunnel wall...) hit by the car's front between z_prev and z: the car
## stops dead, loses fuel and is put back beside the obstacle, towards the road, so it can drive on.
func _check_obstacles(z_prev: float) -> void:
	var hw: float = stats.halfwidth * Track.ROAD_HALF_WIDTH
	var cx := x * Track.ROAD_HALF_WIDTH
	var a := z_prev + CRASH_FRONT - 0.5
	var b := z + CRASH_FRONT
	for idx in range(int(a / Track.SEG_LEN), int(b / Track.SEG_LEN) + 1):
		for ob in obstacles.get(idx, []):
			if ob[0] < a or ob[0] > b or cx + hw <= ob[1] or cx - hw >= ob[2]:
				continue
			speed = 0.0
			z = maxf(z_prev, ob[0] - CRASH_FRONT - 0.3)
			fuel.level = maxf(0.0, fuel.level - CRASH_FUEL)
			# step clear of the obstacle on the road side
			var mid: float = (ob[1] + ob[2]) * 0.5
			var nx: float = (ob[1] - hw - 0.1) if mid > 0.0 else (ob[2] + hw + 0.1)
			x = clampf(nx / Track.ROAD_HALF_WIDTH, -1.8, 1.8)
			hit_cooldown = 1.0
			hit_flash = 0.6
			last_crash = elapsed
			crashed.emit()
			return

## Share of the car's width beyond the right road edge (x = 1.0 is the edge, the stations stand on that side).
func shoulder_fraction() -> float:
	var hw: float = stats.halfwidth
	return clampf((x + hw - 1.0) / (2.0 * hw), 0.0, 1.0)

## Refuelling needs the car stopped by the station with at least half of it off the road, on the shoulder.
func can_refuel_here() -> bool:
	return station_in_range() and speed < STOP_SPEED and shoulder_fraction() >= SHOULDER_MIN - 0.0001

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
	# longitudinal: engine or brakes, plus the slope (uphill slows, downhill speeds up)
	var v0 := speed
	var grade := track.grade_at(z)
	var slope := GRAVITY * (GRADE_K if grade > 0.0 else DOWNHILL_K) * grade
	var gas: bool = input.accel and not held and not input.brake and not fuel.is_empty()
	if held:
		speed -= PULL_OVER_DECEL * dt
	elif input.brake:
		speed -= (stats.brake + slope) * dt
	elif gas:
		speed += (stats.accel * (1.15 - speed_ratio()) * gearbox.pull(speed) - slope) * dt
	else:
		speed -= (ROLL_DECEL + slope) * dt
		if grade < 0.0:
			speed -= ENGINE_BRAKE * gearbox.rpm(speed) * dt
	if absf(x) > 1.0 and speed > OFFROAD_SPEED:
		speed = maxf(OFFROAD_SPEED, speed - OFFROAD_DECEL * dt)
	speed = clampf(speed, 0.0, vmax)
	# lateral
	var steer: float = clampf(input.steer, -1.0, 1.0)
	steer_visual = lerpf(steer_visual, steer, minf(1.0, dt * 10.0))
	var sr := speed_ratio()
	x += steer * stats.handling * STEER_RATE * clampf(speed / 12.0, 0.0, 1.0) * dt
	x -= bend_push(track.segment_at(z).curve, speed, stats.handling * STEER_RATE) * dt
	x = clampf(x, -MEDIAN_X if Route.dual_f(stage, z) >= 0.5 else -1.8, STATION_MAX_X if station_in_range() else 1.8)
	if not Route.tunnel_at(stage, z).is_empty():
		var wall: float = (Scenery.TUNNEL_WALL + TUNNEL_SCRAPE) / Track.ROAD_HALF_WIDTH - stats.halfwidth
		x = clampf(x, -wall, wall)
	var z_prev := z
	z += speed * dt
	if hit_cooldown <= 0.0 and z < stage.length:
		_check_obstacles(z_prev)
	# gearbox and fuel: accelerating and climbing burn a lot, cruising in a high gear saves, rolling downhill
	# off the gas almost nothing
	var accelerating: bool = gas and speed < vmax * 0.98
	var need := (ROLL_DECEL + slope) / maxf(stats.accel * (1.15 - speed_ratio()), 0.1)
	gear = gearbox.update(dt, speed, accelerating, need)
	load = clampf(((speed - v0) / dt + slope) / stats.accel, 0.0, 1.2) if gas and dt > 0.0 else 0.0
	fuel.burn(dt * (DOWNHILL_BURN if not gas and grade < -0.025 else 1.0), speed, load, gearbox.rpm(speed))
	refueling = can_refuel_here() and fuel.ratio() < 0.995
	if refueling:
		fuel.refuel(dt, fuel.capacity / 6.0)
	_update_speeding(dt)
	_update_police(dt)
	# traffic
	traffic.update(dt, z, x, speed)
	var parked_at_station := station_in_range() and speed < STOP_SPEED
	if hit_cooldown <= 0.0 and not parked_at_station and z < stage.length:
		var idx := traffic.check_collision(z, x, stats.halfwidth, speed)
		if idx >= 0:
			var car: Dictionary = traffic.cars[idx]
			head_on = car.get("dir", 1) < 0
			speed = 0.0 if head_on else speed * COLLISION_SPEED_KEEP
			time_left -= COLLISION_TIME_PENALTY
			fuel.level = maxf(0.0, fuel.level - COLLISION_FUEL)
			hit_cooldown = 1.0
			hit_flash = 0.6
			last_hit = elapsed
			# slide fully clear of the car so the same bump cannot repeat
			var clear: float = Traffic.KINDS[car.kind].half + stats.halfwidth + 0.08
			# after a head-on crash the car is put back towards its own lane
			x = clampf(car.lane_x + (clear if head_on or x >= car.lane_x else -clear), -1.8, 1.8)
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
