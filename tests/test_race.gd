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
	for i in 60 * 10: r.step(1.0 / 60.0, NONE)
	t.check(not r.refueling, "not 'refuelling' when the tank is full")
	# off road
	r = fresh()
	r.x = 1.5
	r.speed = 40.0
	for i in 30: r.step(0.1, GAS)
	t.check(r.speed <= 47.0 * 0.4 + 0.5, "off road caps speed")
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
