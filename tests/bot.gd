class_name Bot
extends RefCounted
## Simple autopilot used by balance tests: keeps a lane, avoids slower traffic, stops at stations when fuel is low.
var cruise := 0.9
var refuel_below := 0.55
var obey_limits := true
var _stopping := false

func decide(r: Race) -> Dictionary:
	var sr := r.speed_ratio()
	var target_x := 0.0
	var brake := false
	var accel := true
	var idx := r.traffic.nearest_ahead(r.z)
	var lanes: Array = Traffic.LANES[Route.lanes_at(r.stage, r.z + 30.0)]
	var best := 0.0
	var best_gap := -1.0
	for lx in lanes:
		var gap := 400.0
		for c in r.traffic.cars:
			if c.active and c.z > r.z - 12.0 and c.z - r.z < gap and absf(c.lane_x - lx) < 0.3:
				gap = c.z - r.z
		if gap > best_gap + 1.0 or (absf(gap - best_gap) <= 1.0 and absf(lx - r.x) < absf(best - r.x)):
			best_gap = gap
			best = lx
	target_x = best
	if idx >= 0:
		var c: Dictionary = r.traffic.cars[idx]
		var gap: float = c.z - r.z
		if absf(c.lane_x - r.x) < 0.38 and gap < 10.0 + r.speed * 0.9 and r.speed > c.speed:
			brake = r.speed > c.speed + 3.0
			accel = false
	# station logic
	for s in r.stage.stations:
		var d: float = s - r.z
		if d > -20.0 and d < 400.0 and (r.fuel.ratio() < refuel_below or _stopping) and r.fuel.ratio() < 0.97:
			_stopping = true
			if d < Race.STATION_HALF_LEN - 10.0:
				accel = false
				brake = r.speed > 2.0
			elif d < Race.STATION_HALF_LEN - 10.0 + r.speed * r.speed / (2.0 * r.stats.brake * 0.6):
				brake = true
				accel = false
	if _stopping and r.fuel.ratio() >= 0.97:
		_stopping = false
	elif _stopping and r.station_in_range() and r.speed < 3.5:
		accel = false
		brake = r.speed > 0.5
	if sr > cruise:
		accel = false
	if obey_limits:
		# slow down in time for a lower limit ahead (towns), stay just under the limit
		var look: float = 40.0 + r.speed * r.speed / (2.0 * r.stats.brake * 0.5)
		var lim: float = minf(r.speed_limit(), Route.speed_limit_at(r.stage, r.z + look)) / 3.6 - 1.0
		if r.speed > lim:
			accel = false
			brake = brake or r.speed > lim + 1.5
	var curve: float = r.track.segment_at(r.z + 20.0).curve
	var steer := clampf((target_x - r.x) * 2.5 + curve * 0.35 * sr * sr / (r.stats.handling * 2.2), -1.0, 1.0)
	return {"accel": accel, "brake": brake, "steer": steer}

static func run_race(car: String, stage: Dictionary, seed_value: int, cruise_ratio := 0.9) -> Race:
	var r := Race.new(car, stage, seed_value)
	var b := Bot.new()
	b.cruise = cruise_ratio
	var guard := 0
	while r.state == "running" and guard < 60 * 900:
		r.step(1.0 / 60.0, b.decide(r))
		guard += 1
	return r
