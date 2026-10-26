extends RefCounted
const NONE := {"accel": false, "brake": false, "steer": 0.0}
const GAS := {"accel": true, "brake": false, "steer": 0.0}
const BRAKE := {"accel": false, "brake": true, "steer": 0.0}
const BOTH := {"accel": true, "brake": true, "steer": 0.0}

func fresh(car := "yaris") -> Race:
	var r := Race.new(car, Route.build("krakow", "rzeszow"), 1)
	r.traffic.cars = []
	return r

func run(t) -> void:
	var r := fresh()
	t.check(r.state == "running" and r.speed == 0.0 and is_equal_approx(r.time_left, r.stage.duration), "initial state")
	# coasting never goes negative, never reverses
	r.speed = 30.0
	r.step(1.0, NONE)
	t.check(r.speed < 30.0 and r.speed > 0.0, "coasting slows")
	for i in 700: r.step(0.5, NONE)
	t.check(r.speed == 0.0, "coasting stops at zero, no reverse")
	r = fresh()
	for i in 20: r.step(0.1, BRAKE)
	t.check(r.speed == 0.0 and r.z == 0.0, "braking at standstill does not reverse")
	r = fresh()
	r.speed = 20.0
	r.step(0.5, BOTH)
	t.check(r.speed < 20.0, "brake wins over accelerator")
	r = fresh()
	for i in 100: r.step(0.1, GAS)
	t.check(r.speed > 20.0 and r.speed <= 47.0 + 0.001, "accelerates up to vmax")
	t.check(r.gear >= 1 and r.gear <= 6, "gear in 1..6")
	# end conditions
	r = fresh()
	r.z = r.stage.length - 1.0
	r.speed = 10.0
	r.step(0.5, GAS)
	t.check(r.state == "won", "reaching the finish wins")
	var tl := r.time_left
	r.step(1.0, GAS)
	t.check(r.time_left == tl, "no updates after the race ended")
	r = fresh()
	r.time_left = 0.05
	r.step(0.1, GAS)
	t.check(r.state == "out_of_time", "out of time")
	r = fresh()
	r.fuel.level = 0.01
	r.speed = 10.0
	r.step(0.5, GAS)
	t.check(r.state == "out_of_fuel", "running out of fuel ends the game at once")
	# fuel station
	r = fresh()
	r.z = r.stage.stations[0]
	r.x = 1.1 # on the shoulder next to the station
	r.fuel.level = 5.0
	t.check(r.station_in_range(), "in station zone")
	r.step(1.0, NONE)
	t.check(r.refueling and r.fuel.level > 5.0, "stopped in zone refuels")
	t.check(is_equal_approx(r.time_left, r.stage.duration - 1.0), "refuelling costs time")
	r = fresh()
	t.check(is_equal_approx(r.km_left(), 165.0), "km left at the start")
	r.z = r.stage.length * 0.5
	t.check(absf(r.km_left() - 82.5) < 0.01, "km left halfway")
	for i in 100: r.step(0.5, NONE)
	t.check(r.fuel.level <= r.fuel.capacity + 0.0001, "refuel capped at capacity")
	r = fresh()
	r.z = r.stage.stations[0]
	r.x = 1.1
	r.fuel.level = 5.0
	r.speed = 15.0
	r.step(0.1, NONE)
	t.check(not r.refueling and r.fuel.level < 5.0, "driving through station does not refuel")
	r = fresh()
	r.z = r.stage.stations[0] + 200.0
	r.fuel.level = 5.0
	r.step(1.0, NONE)
	t.check(not r.refueling and not r.station_in_range(), "no refuel away from station")
	# collision, Atari style
	r = fresh()
	r.speed = 30.0
	r.traffic.cars = [{"z": r.z + 1.0, "lane_x": r.x, "speed": 0.0, "kind": "car", "color_idx": 0, "active": true}]
	var before := r.time_left
	r.step(0.016, GAS)
	t.check(r.speed < 30.0 * 0.45, "collision cuts speed hard")
	t.check(before - r.time_left >= 5.0, "collision costs time")
	t.check(r.state == "running", "collision is not game over")
	# a car stopped at a fuel station is not run over by passing traffic
	r = fresh()
	r.z = r.stage.stations[0]
	r.fuel.level = 5.0
	r.traffic.cars = [{"z": r.z, "lane_x": r.x, "speed": 15.0, "kind": "car", "color_idx": 0, "active": true}]
	var tl2 := r.time_left
	r.step(0.1, NONE)
	t.check(tl2 - r.time_left < 1.0 and r.state == "running", "no collision penalty while stopped at a station")
	# review fix 1: a faster car catching up from behind must not punish a slow/stopped player
	r = fresh()
	r.z = 1000.0
	r.speed = 0.0
	r.traffic.cars = [{"z": 1000.0, "lane_x": r.x, "speed": 12.0, "kind": "truck", "color_idx": 0, "active": true}]
	var tl3 := r.time_left
	for i in 120: r.step(1.0 / 60.0, BRAKE)
	t.check(tl3 - r.time_left < 2.5, "no penalty when a faster car runs into a stopped player (lost %.1fs)" % (tl3 - r.time_left))
	# overtaking slowly and cutting in just in front of a car: it must never hit the player from behind
	r = fresh()
	r.z = 1000.0
	r.speed = 20.0
	r.traffic.cars = [{"z": 997.0, "lane_x": r.x, "speed": 19.0, "pace": 0.9, "kind": "truck", "color_idx": 0, "active": true}]
	var tl4 := r.time_left
	var bumped := [0]
	r.collided.connect(func(_i): bumped[0] += 1)
	for i in 60 * 5: r.step(1.0 / 60.0, NONE)
	t.check(bumped[0] == 0 and tl4 - r.time_left < 5.5, "a car just behind the player never counts as a bump")
	t.check(r.traffic.cars[0].z < r.z, "traffic behind the player queues up instead of driving through it")
	# review fix 2: after a bump the player is clear of the car, so the same car cannot hit again and again
	r = fresh()
	r.z = 500.0
	r.speed = 30.0
	r.traffic.cars = [{"z": 520.0, "lane_x": r.x, "speed": 15.0, "kind": "car", "color_idx": 0, "active": true}]
	var hits := [0]
	r.collided.connect(func(_i): hits[0] += 1)
	for i in 60 * 20: r.step(1.0 / 60.0, GAS)
	t.check(hits[0] <= 1, "holding the throttle behind a slower car hits it at most once (hits=%d)" % hits[0])
	# hills: uphill slows, downhill speeds up, a weak car loses more on a climb, climbing burns more fuel
	# accel: true = gas held, false = off the gas, null = holding v0 with the gas (like a player tapping it)
	var on_grade := func(car: String, g: float, accel, secs: float, v0: float) -> Race:
		var rr: Race = fresh(car)
		for sg in rr.track.segments: sg.grade = g
		rr.z = 500.0
		rr.speed = v0
		for i in int(secs * 60):
			var on: bool = rr.speed < v0 if accel == null else accel
			rr.step(1.0 / 60.0, GAS if on else NONE)
			rr.speeding = 0.0 # only the slope is under test, no police stops
			rr.x = 0.0
		return rr
	t.check(on_grade.call("yaris", 0.2, false, 2.0, 20.0).speed < on_grade.call("yaris", 0.0, false, 2.0, 20.0).speed - 2.0, "uphill off the gas slows down")
	t.check(on_grade.call("yaris", -0.2, false, 2.0, 10.0).speed > 11.0, "downhill off the gas speeds up")
	var ya: Race = on_grade.call("yaris", 0.4, true, 20.0, 20.0)
	var rv: Race = on_grade.call("rangerover", 0.4, true, 20.0, 20.0)
	t.check(ya.speed_ratio() < 0.8 and ya.speed_ratio() < rv.speed_ratio() - 0.1, "a steep climb holds the Yaris back more than the Range Rover (%.2f vs %.2f)" % [ya.speed_ratio(), rv.speed_ratio()])
	var fu: Race = on_grade.call("xc60", 0.3, null, 5.0, 25.0)
	var ff: Race = on_grade.call("xc60", 0.0, null, 5.0, 25.0)
	var fd: Race = on_grade.call("xc60", -0.3, false, 5.0, 25.0)
	t.check(fu.fuel.level < ff.fuel.level and fd.fuel.level > ff.fuel.level, "climbing burns more fuel, rolling downhill less")
	# bends push outwards with the real speed: the same at the same km/h, a sharp bend needs a weak car to brake
	var yr := fresh("yaris")
	var rv2 := fresh("rangerover")
	t.check(yr.corner_speed(Track.SHARP_AMOUNT) < 25.0 and rv2.corner_speed(Track.SHARP_AMOUNT) > 25.0, "a sharp bend: the Yaris brakes below 90 km/h, the Range Rover holds it (%.0f / %.0f km/h)" % [yr.corner_speed(Track.SHARP_AMOUNT) * 3.6, rv2.corner_speed(Track.SHARP_AMOUNT) * 3.6])
	var pushed := func(car: String, kmh: float) -> float:
		var rr: Race = fresh(car)
		for sg in rr.track.segments: sg.curve = 10.0
		rr.z = 500.0
		rr.speed = kmh / 3.6
		rr.step(0.1, NONE)
		return rr.x
	t.check(is_equal_approx(pushed.call("yaris", 80.0), pushed.call("rangerover", 80.0)), "the same bend pushes every car alike at the same speed")
	# far too fast for a sharp bend: the car slides wide gently, it is not flung across the road
	var bm := fresh("bmw530")
	for sg in bm.track.segments: sg.curve = Track.SHARP_AMOUNT * 1.15
	bm.z = 500.0
	bm.speed = bm.stats.max_speed
	for i in 30: bm.step(1.0 / 60.0, {"accel": true, "brake": false, "steer": 1.0})
	t.check(bm.x > -Race.SLIDE_MAX * 0.5 - 0.01 and bm.x < -0.2, "flat out into a sharp bend, steering against it: the BMW drifts wide slowly (x=%.2f after 0.5 s)" % bm.x)
	# every bump costs time and fuel
	r = fresh()
	r.z = 500.0
	r.speed = 30.0
	r.fuel.level = 20.0
	r.traffic.cars = [{"z": 500.3, "lane_x": r.x, "speed": 15.0, "kind": "car", "color_idx": 0, "active": true}]
	var tl5 := r.time_left
	r.step(1.0 / 60.0, NONE)
	t.check(tl5 - r.time_left > Race.COLLISION_TIME_PENALTY - 0.1, "a bump costs %.0f s" % Race.COLLISION_TIME_PENALTY)
	t.check(is_equal_approx(r.last_hit, r.elapsed), "the bump time is kept for the HUD")
	t.check(absf(20.0 - r.fuel.level - Race.COLLISION_FUEL) < 0.05, "a bump costs %.0f l of fuel (lost %.2f)" % [Race.COLLISION_FUEL, 20.0 - r.fuel.level])
	# review fix 3: the HUD needs to know how far the next station is
	r = fresh()
	r.z = 100.0
	t.check(is_equal_approx(r.next_station_distance(), r.stage.stations[0] - 100.0), "distance to next station")
	r.z = r.stage.stations[0] + 100.0
	t.check(r.next_station_distance() < 0.0, "no station ahead after the last one")
	# review fix 4: after the finish the car keeps rolling and slows down, time and fuel no longer matter
	r = fresh()
	r.z = r.stage.length - 1.0
	r.speed = 40.0
	r.step(0.1, GAS)
	t.check(r.state == "won", "finished")
	var z_end := r.z
	r.coast_after_finish(0.5)
	t.check(r.z > z_end and r.speed < 40.0 and r.speed >= 0.0, "keeps rolling after the finish and slows down")
	# review fix 6: a bump on the finish frame does not change the win or push time below zero
	r = fresh()
	r.z = r.stage.length - 0.2
	r.speed = 30.0
	r.time_left = 2.0
	r.traffic.cars = [{"z": r.z + 0.5, "lane_x": r.x, "speed": 0.0, "kind": "car", "color_idx": 0, "active": true}]
	r.step(0.05, GAS)
	t.check(r.state == "won" and r.time_left > 0.0, "crossing the finish wins and time_left stays positive")
	# refuelling flag must drop once the tank is full
	r = fresh()
	r.z = r.stage.stations[0]
	r.x = 1.1
	for i in 60 * 10: r.step(1.0 / 60.0, NONE)
	t.check(not r.refueling, "not 'refuelling' when the tank is full")
	# refuelling needs the car at least 50% off the road, on the station's (right) shoulder
	for case in [[0.0, false, "in the lane"], [0.9, false, "mostly on the road"], [0.97, false, "just under half outside"],
			[1.0, true, "exactly half outside"], [1.2, true, "well on the shoulder"], [-1.2, false, "wrong (left) shoulder"]]:
		r = fresh()
		r.z = r.stage.stations[0]
		r.x = case[0]
		r.fuel.level = 5.0
		r.step(0.5, NONE)
		t.check(r.refueling == case[1] and (r.fuel.level > 5.0) == case[1], "refuel at x=%.2f (%s) -> %s" % [case[0], case[2], case[1]])
	r = fresh()
	r.x = 1.0
	t.check(is_equal_approx(r.shoulder_fraction(), 0.5), "shoulder_fraction is 0.5 with the centre on the road edge")
	r.x = 0.0
	t.check(r.shoulder_fraction() == 0.0, "shoulder_fraction 0 in the lane")
	r.x = 1.8
	t.check(r.shoulder_fraction() == 1.0, "shoulder_fraction capped at 1")
	r = fresh()
	r.z = r.stage.stations[0]
	r.x = 1.1
	r.fuel.level = 5.0
	r.speed = 0.0
	r.step(0.2, NONE)
	t.check(r.can_refuel_here(), "can_refuel_here when parked on the shoulder")
	r.x = 0.0
	t.check(not r.can_refuel_here(), "cannot refuel from the lane")
	# off road
	r = fresh()
	r.x = 1.5
	r.speed = 40.0
	for i in 30: r.step(0.1, GAS)
	t.check(r.speed <= Race.OFFROAD_SPEED + 0.01, "off road holds the car at 40 km/h")
	r = fresh("rangerover")
	r.speed = 140.0 / 3.6
	r.x = 1.2
	for i in 90: r.step(1.0 / 60.0, GAS)
	t.check(r.speed <= Race.OFFROAD_SPEED + 0.01, "off road slows even a fast car to 40 km/h within 1.5 s")
	# straight start, no steering
	r = fresh()
	r.speed = 20.0
	r.step(1.0, NONE)
	t.check(absf(r.x) < 0.01, "no drift on a straight")
	# steering moves sideways, stationary car does not
	r = fresh()
	r.speed = 20.0
	r.step(0.5, {"accel": false, "brake": false, "steer": 1.0})
	t.check(r.x > 0.1, "steer right moves right")
	r = fresh()
	r.step(0.5, {"accel": false, "brake": false, "steer": 1.0})
	t.check(r.x == 0.0, "no sideways motion at standstill")
