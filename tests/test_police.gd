extends RefCounted
## Speed limits, the radar detector warning, and the police stop with its fine.
const GAS := {"accel": true, "brake": false, "steer": 0.0}
const NONE := {"accel": false, "brake": false, "steer": 0.0}

func fresh() -> Race:
	var r := Race.new("xc60", Route.build("krakow", "rzeszow"), 1)
	r.traffic.cars = []
	return r

func run(t) -> void:
	run_escape(t)
	var r := fresh()
	t.check(r.speed_limit() == 70, "70 km/h in the start city (a big city)")
	r.z = 430.0 # open A4 between Kraków and Bochnia
	t.check(r.speed_limit() == 140, "140 km/h on the A4")
	t.check(Route.speed_limit_at(Route.build("krakow", "bielsko"), 440.0) == 90, "90 km/h on a two-lane national road")
	# 10 km/h over the posted limit is tolerated
	r.speed = 148.0 / 3.6
	r.step(0.1, NONE)
	t.check(r.speeding == 0.0, "148 km/h under a 140 limit is tolerated")
	# a short burst over the limit only warns
	r = fresh()
	r.z = 1225.0 # open A4 between Tarnów and Dębica
	r.speed = 155.0 / 3.6
	for i in 30: r.step(0.1, GAS)
	t.check(r.speeding > 0.0 and r.police.is_empty(), "speeding starts the radar warning")
	# on the motorway slowing to 145 is not enough, 140 clears it
	r.speed = 145.0 / 3.6
	r.step(0.1, NONE)
	t.check(r.speeding > 0.0, "145 km/h on the motorway keeps the warning")
	r.speed = 139.0 / 3.6
	r.step(0.1, NONE)
	t.check(r.speeding == 0.0, "140 km/h on the motorway clears the warning")
	# keep speeding past the grace time: the police come, stop the car and fine it
	r = fresh()
	r.z = 600.0
	var held := false
	var n := 0
	var before := 0.0
	while r.fines == 0 and n < 60 * 60:
		before = r.fuel.level
		r.step(1.0 / 60.0, NONE if r.held_by_police() else {"accel": r.speed < 46.0, "brake": false, "steer": 0.0})
		if r.held_by_police(): held = true
		n += 1
	t.check(held and r.fines == 1, "police pull the speeding car over")
	t.check(r.speed == 0.0 and absf(before - r.fuel.level - Race.FINE_FUEL) < 0.1, "the fine costs 10 litres")
	for i in 60 * 30:
		r.step(1.0 / 60.0, NONE)
		if r.police.is_empty(): break
	t.check(r.police.is_empty() and not r.held_by_police(), "the police drive off and the player drives on")
	# speeding again (faster than the leaving patrol car) gets a second ticket
	var n2 := 0
	while r.fines == 1 and n2 < 60 * 90 and r.state == "running":
		# keep to the road: off it the car is held at 40 km/h and could never speed
		r.step(1.0 / 60.0, NONE if r.held_by_police() else {"accel": true, "brake": false, "steer": clampf(-r.x * 2.0, -1.0, 1.0)})
		n2 += 1
	t.check(r.fines == 2, "the police catch a repeat offender again (fines: %d)" % r.fines)
	# in town the grace is 5 s
	r = fresh()
	r.speed = 80.0 / 3.6
	t.check(is_equal_approx(r.speeding_grace(), Race.GRACE), "5 s warning in town")

## A patrol car already pulling the player over, right in front, on the open A4; the player at `kmh`.
func pulled_over(car: String, kmh: float, weak: bool, need: int) -> Race:
	var r := Race.new(car, Route.build("krakow", "rzeszow"), 1)
	r.traffic.cars = []
	r.z = 1225.0
	r.speed = kmh / 3.6
	r.police = {"z": r.z + 11.0, "x": 0.0, "speed": r.speed, "phase": "pull_over", "t": 0.0,
		"weak": weak, "need": need, "swerves": 0, "dir": 0.0, "swerve_t": -100.0}
	return r

var _lock := -1.0 ## the last full lock given by swerve()

## Full lock the other way than last time, `n` times, each held for 0.3 s.
func swerve(r: Race, n: int) -> void:
	for k in n:
		_lock = -_lock
		for i in 18:
			r.step(1.0 / 60.0, {"accel": false, "brake": false, "steer": _lock})

func run_escape(t) -> void:
	# who drives the patrol car is rolled once per chase
	var weak := 0
	var needs := {}
	for sd in 200:
		var st := Route.build("krakow", "rzeszow")
		var r := Race.new("bmw530", st, sd)
		r.z = 1225.0
		r.speed = 200.0 / 3.6
		r.speeding = r.speeding_grace()
		r.step(1.0 / 60.0, GAS)
		if r.police.weak: weak += 1
		needs[r.police.need] = true
	t.check(weak > 20 and weak < 60, "about one officer in five can be shaken off (%d of 200)" % weak)
	t.check(needs.keys().all(func(k): return k >= 3 and k <= 5) and needs.size() == 3, "3 to 5 swerves needed (%s)" % [needs.keys()])
	var st2 := Route.build("krakow", "rzeszow")
	st2["police_escape"] = 1.0 # the ?policja test mode
	var rt := Race.new("bmw530", st2, 1)
	rt.z = 1225.0
	rt.speed = 200.0 / 3.6
	rt.speeding = rt.speeding_grace()
	rt.step(1.0 / 60.0, GAS)
	t.check(rt.police.weak, "in the police test mode every officer can be shaken off")
	# a weak officer crashes on the last of the needed swerves, and the player drives on without a fine
	var r := pulled_over("bmw530", 220.0, true, 4)
	var crashes := [0]
	r.police_crashed.connect(func(): crashes[0] += 1)
	swerve(r, 3)
	t.check(r.police.phase == "pull_over", "three swerves are not enough when four are needed")
	swerve(r, 1)
	t.check(r.police.phase == "crashed" and crashes[0] == 1 and not r.held_by_police(), "the fourth swerve shakes the weak officer off")
	for i in 60 * 4: r.step(1.0 / 60.0, {"accel": true, "brake": false, "steer": clampf(-r.x * 2.0, -1.0, 1.0)})
	t.check(r.police.is_empty() or (r.police.speed == 0.0 and absf(r.police.x) > 1.0), "the patrol car ends up off the road, stopped")
	t.check(r.fines == 0, "no fine after an escape")
	# a sharp officer follows every swerve and stops the car anyway
	r = pulled_over("bmw530", 220.0, false, 3)
	swerve(r, 8)
	t.check(r.police.phase == "pull_over", "a sharp officer is never shaken off")
	# no escape below 180 km/h
	r = pulled_over("bmw530", 175.0, true, 3)
	swerve(r, 6)
	t.check(r.police.phase == "pull_over", "swerving at 175 km/h shakes nobody off")
	# too slow between the swerves: the count starts again
	r = pulled_over("rangerover", 250.0, true, 3)
	swerve(r, 2)
	for i in 120: r.step(1.0 / 60.0, NONE)
	swerve(r, 1)
	t.check(r.police.swerves == 1 and r.police.phase == "pull_over", "a pause of 2 s starts the swerve count again")
	# above the escape speed the pulled-over car rolls off gently: a few seconds for the swerves
	r = pulled_over("bmw530", 220.0, false, 3)
	var n := 0
	while r.speed * 3.6 >= 180.0 and n < 600:
		r.step(1.0 / 60.0, NONE)
		n += 1
	t.check(n / 60.0 > 3.0, "the BMW has %.1f s above 180 km/h to shake the officer off" % (n / 60.0))
