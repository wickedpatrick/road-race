extends RefCounted
## Speed limits, the radar detector warning, and the police stop with its fine.
const GAS := {"accel": true, "brake": false, "steer": 0.0}
const NONE := {"accel": false, "brake": false, "steer": 0.0}

func fresh() -> Race:
	var r := Race.new("xc60", Route.build("krakow", "rzeszow"), 1)
	r.traffic.cars = []
	return r

func run(t) -> void:
	var r := fresh()
	t.check(r.speed_limit() == 50, "50 km/h in the start city")
	r.z = 600.0
	t.check(r.speed_limit() == 140, "140 km/h on the A4")
	t.check(Route.speed_limit_at(Route.build("krakow", "bielsko"), 600.0) == 90, "90 km/h on a two-lane national road")
	# 10 km/h over the posted limit is tolerated
	r.speed = 148.0 / 3.6
	r.step(0.1, NONE)
	t.check(r.speeding == 0.0, "148 km/h under a 140 limit is tolerated")
	# a short burst over the limit only warns
	r = fresh()
	r.z = 420.0 # open A4 between Kraków and Bochnia
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
		r.step(1.0 / 60.0, NONE if r.held_by_police() else GAS)
		n2 += 1
	t.check(r.fines == 2, "the police catch a repeat offender again (fines: %d)" % r.fines)
	# in town the grace is 5 s
	r = fresh()
	r.speed = 80.0 / 3.6
	t.check(is_equal_approx(r.speeding_grace(), Race.GRACE), "5 s warning in town")
