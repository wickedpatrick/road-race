class_name Bot
extends RefCounted
## Simple autopilot used by balance tests: keeps a lane, avoids slower traffic, stops at stations when fuel is low.
var cruise := 0.9
var refuel_below := 0.55
var obey_limits := true
var limit_factor := 1.0 ## keeps to the limits times this (1.2: 20% over them)
var corner_margin := 0.84 ## the share of the steering's top bend speed it takes sharp bends at (some kept for the lane)
## "legal": keeps to the limits (obey_limits); "dodge": flat out, but back to the limit while the radar detector
## beeps or the police are around; "flat": flat out always, and swerving to shake off the patrol car pulling it over
var strategy := "legal"
var _swerve := 1.0
var _swerve_t := 0.0
var _stopping := false
var _overtaking := false
const SHOULDER_X := 1.12 ## right shoulder, where the stations stand

func decide(r: Race) -> Dictionary:
	var sr := r.speed_ratio()
	var target_x := 0.0
	var brake := false
	var accel := true
	var lanes: Array = Traffic.own_lanes(Route.dual_f(r.stage, r.z + 5.0))
	var best := 0.0
	var best_gap := -1.0
	for lx in lanes:
		if absf(lx - r.x) > 0.8 and _busy_between(r, lx): continue # never cut across a car alongside
		var gap := 400.0
		for c in r.traffic.cars:
			if c.active and c.z > r.z - 12.0 and c.z - r.z < gap and absf(c.lane_x - lx) < 0.3:
				gap = c.z - r.z
		if gap > best_gap + 1.0 or (absf(gap - best_gap) <= 1.0 and absf(lx - r.x) < absf(best - r.x)):
			best_gap = gap
			best = lx
	target_x = best
	# single road: overtake a slower car in the oncoming lane when it is clear far enough ahead
	if lanes.size() == 1:
		var slow := _slow_ahead(r)
		if _overtaking and (slow.is_empty() or not _clear_oncoming(r, 2.5)):
			_overtaking = false
		if not _overtaking and not slow.is_empty() and (r.speed_limit() >= 90 or r.speed_limit() == Route.NO_LIMIT) and _clear_oncoming(r, 5.0):
			_overtaking = true
		if _overtaking:
			target_x = -0.5
	else:
		_overtaking = false
	# follow the closest slower car in the player's own lane (or the lane being moved into)
	for c in r.traffic.cars:
		if not c.active or c.get("dir", 1) < 0: continue
		var gap: float = c.z - r.z
		if gap > -2.0 and gap < 10.0 + r.speed * 0.9 and r.speed > c.speed \
				and (absf(c.lane_x - r.x) < 0.45 or absf(c.lane_x - target_x) < 0.3 and gap < 25.0):
			accel = false
			brake = brake or r.speed > c.speed + 3.0 or (gap < 8.0 + r.speed * 0.4 and r.speed > c.speed + 0.5)
	# station logic: pull over onto the right shoulder, stop there, refuel, rejoin the road
	var on_shoulder := r.shoulder_fraction() >= 0.6
	for s in r.stage.stations:
		var d: float = s - r.z
		if d > -20.0 and d < 400.0 and (r.fuel.ratio() < refuel_below or _stopping) and r.fuel.ratio() < 0.97:
			_stopping = true
			if d < 150.0:
				target_x = SHOULDER_X
			if d < Race.STATION_HALF_LEN - 10.0:
				if on_shoulder:
					accel = false
					brake = r.speed > 2.0
				else:
					accel = r.speed < 6.0
					brake = r.speed > 9.0
			elif d < Race.STATION_HALF_LEN - 10.0 + r.speed * r.speed / (2.0 * r.stats.brake * 0.6):
				brake = true
				accel = false
	if _stopping and r.fuel.ratio() >= 0.97:
		_stopping = false
	elif _stopping and r.station_in_range() and r.speed < 3.5:
		if on_shoulder:
			accel = false
			brake = r.speed > 0.5
		else:
			target_x = SHOULDER_X
			accel = r.speed < 6.0
			brake = r.speed > 9.0
	if sr > cruise:
		accel = false
	var obey := obey_limits
	if strategy == "dodge": obey = r.speeding > 0.0 or not r.police.is_empty()
	elif strategy == "flat": obey = false
	if obey:
		# slow down in time for a lower limit ahead (towns), stay just under the limit
		var look: float = 40.0 + r.speed * r.speed / (2.0 * r.stats.brake * 0.5)
		var lim: float = minf(_limit(r.stage, r.z), _limit(r.stage, r.z + look)) * limit_factor / 3.6 - 1.0
		if r.speed > lim:
			accel = false
			brake = brake or r.speed > lim + 1.5
	# sharp bends: slow down in time to a speed the steering can hold the bend at
	var look_c: float = 30.0 + r.speed * r.speed / (2.0 * r.stats.brake * 0.5)
	var worst := 0.0
	for d in range(0, int(look_c), 10):
		worst = maxf(worst, absf(r.track.segment_at(r.z + d).curve))
	if worst > 0.0:
		var safe := r.corner_speed(worst) * corner_margin
		if r.speed > safe:
			accel = false
			brake = brake or r.speed > safe + 1.5
	var curve: float = r.track.segment_at(r.z + 20.0).curve
	var steer := clampf((target_x - r.x) * 2.5 + curve * Race.corner_push(r.speed) / (r.stats.handling * Race.STEER_RATE), -1.0, 1.0)
	if strategy == "flat" and r.police.get("phase", "") == "pull_over" and r.speed * 3.6 >= r.police_rules.escape_kmh:
		# sharp changes of direction, quicker than Race.SWERVE_GAP, kept on the carriageway
		if r.elapsed - _swerve_t > 0.3 or absf(r.x - 0.2) > 0.5 and signf(_swerve) == signf(r.x - 0.2):
			_swerve = -signf(r.x - 0.2) if absf(r.x - 0.2) > 0.5 else -_swerve
			_swerve_t = r.elapsed
		steer = _swerve
	return {"accel": accel, "brake": brake, "steer": steer * r.side} # the steering is mirrored with left-hand traffic

## A slower car in the right lane just ahead (or alongside, while overtaking it), or {}.
func _slow_ahead(r: Race) -> Dictionary:
	for c in r.traffic.cars:
		if c.active and c.get("dir", 1) > 0 and c.z - r.z > -8.0 and c.z - r.z < 45.0 and absf(c.lane_x - 0.5) < 0.3 \
				and c.speed < r.stats.max_speed * cruise - 2.0:
			return c
	return {}

## No oncoming car in the left lane for `secs` seconds of closing distance.
func _clear_oncoming(r: Race, secs: float) -> bool:
	for c in r.traffic.cars:
		if c.active and c.get("dir", 1) < 0 and absf(c.lane_x + 0.5) < 0.4:
			var gap: float = c.z - r.z
			if gap > -6.0 and gap < (r.speed + c.speed) * secs + 30.0:
				return false
	return true

## A car next to the player in a lane between the player and lane lx.
func _busy_between(r: Race, lx: float) -> bool:
	for c in r.traffic.cars:
		if c.active and absf(c.z - r.z) < 10.0 and (c.lane_x - r.x) * (c.lane_x - lx) < 0.0:
			return true
	return false

static func run_race(car: String, stage: Dictionary, seed_value: int, cruise_ratio := 0.9) -> Race:
	var r := Race.new(car, stage, seed_value)
	var b := Bot.new()
	b.cruise = cruise_ratio
	var guard := 0
	while r.state == "running" and guard < 60 * 900:
		r.step(1.0 / 60.0, b.decide(r))
		guard += 1
	return r

## A run on an empty road (no traffic, no radars, no police) for the rankings' anchors (tools/calibrate_rankings.gd):
## "flat" out in the fastest car taking the sharp bends at the steering's very limit and stopping for fuel, or
## "legal" keeping the limits on a tank that never empties. The road's own time (Rankings.road_times), -1 if lost.
static func run_clean(car: String, stage: Dictionary, strategy: String, free_fuel: bool, seed_value := 1) -> float:
	stage.radars = []
	var r := Race.new(car, stage, seed_value)
	var b := Bot.new()
	b.cruise = 1.0
	b.strategy = strategy
	b.corner_margin = 1.0 if strategy == "flat" else b.corner_margin
	var guard := 0
	while r.state == "running" and guard < 60 * 900:
		for c in r.traffic.cars: c.active = false
		r.speeding = 0.0
		if free_fuel: r.fuel.level = r.fuel.capacity
		r.step(1.0 / 60.0, b.decide(r))
		guard += 1
	if r.state != "won":
		return -1.0
	var cc := GameData.current
	return Rankings.road_times(cc, stage, r.splits)[0].t

## The limit the autopilot keeps, km/h: none (its own cruise) on an Autobahn without one.
static func _limit(stage: Dictionary, z: float) -> float:
	var lim := Route.speed_limit_at(stage, z)
	return INF if lim == Route.NO_LIMIT else float(lim)
