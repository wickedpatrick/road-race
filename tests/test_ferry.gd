extends RefCounted
## Ferries (roads.json `ferry`): the sea between two quays is not driven; the car stops at the quay's barrier, the
## crossing takes Race.FERRY_TIME off the clock and the trip goes on from the far quay. A fixture of three cities.
const CODE := "zz_ferry"

static func fixture() -> Dictionary:
	var c: Dictionary = GameData.localize(GameData.load_json(GameData.DIR + "countries/pl/country.json"))
	c.code = CODE
	c["cities"] = {
		"aa": {"name": "Alfa", "lat": 40.0, "lon": 20.0, "pop": 150, "region": "R1"},
		"bb": {"name": "Beta", "lat": 37.0, "lon": 22.0, "pop": 150, "region": "R2"},
		"cc": {"name": "Gamma", "lat": 36.6, "lon": 22.4, "pop": 150, "region": "R2"},
	}
	c["roads"] = [
		{"a": "aa", "b": "bb", "km": 400, "road": "A1", "towns": [["Port", 60], ["Isle", 390]],
			"zones": [[200, "fields", "R1"], [400, "upland", "R2"]],
			"ferry": {"from_km": 100, "to_km": 380, "name": "Alfa – Beta", "fact": {"pl": "Prom", "en": "Ferry"}}},
		{"a": "bb", "b": "cc", "km": 60, "road": "A2", "towns": [], "zones": [[60, "upland", "R2"]]},
	]
	c["facts"] = {}
	c["landmarks"] = {}
	return GameData.localize(c)

func run(t) -> void:
	var was := GameData.current
	GameData._countries[CODE] = fixture()
	GameData.current = CODE
	var s := Route.build("aa", "bb")
	t.check(s.ferries.size() == 1, "one ferry on the way")
	# the sea is not driven: the track is the driven km's, plus FERRY_GAP from the barrier to the far ramp
	t.check(absf(s.length - Route.track_length(400 - 280) - Route.FERRY_GAP) < 1.0, "track of the driven 120 km (%.0f)" % s.length)
	t.check(s.km == 400, "the real total stays in km")
	var f: Dictionary = s.ferries[0]
	t.check(absf(f.z - 100.0 * s.m_per_km) < 1.0, "barrier at km 100 (%.0f)" % f.z)
	t.check(is_equal_approx(f.z_out - f.z, Route.FERRY_GAP) and f.name == "Alfa – Beta" and f.fact == "Prom"
		and is_equal_approx(f.sea_km, 280.0), "the far quay, name, fact, sea km")
	var isle: Dictionary = s.towns.filter(func(tn): return tn.name == "Isle")[0]
	t.check(absf(isle.z - (110.0 * s.m_per_km + Route.FERRY_GAP)) < 1.0, "a town past the sea moved back by its km")
	t.check(Route.ferry_at(s, f.z - 100.0) == f and Route.ferry_at(s, f.z_out) == f and Route.ferry_at(s, f.z - Route.FERRY_QUAY - 5.0).is_empty(),
		"ferry_at covers the quay and the crossing")
	t.check(not s.stations.any(func(z): return z > f.z - Route.FERRY_QUAY - 40.0 and z < f.z_out + 40.0), "no station on the quay")
	t.check(not s.boards.any(func(bd): return bd.z > f.z - Route.FERRY_QUAY - 40.0 and bd.z < f.z_out + 40.0), "no board on the quay")
	var back := Route.build("bb", "aa")
	t.check(back.ferries.size() == 1 and absf(back.ferries[0].z - 20.0 * back.m_per_km) < 1.0, "b->a: the ferry at km 20 (%.0f)" % back.ferries[0].z)
	var three := Route.build("cc", "aa")
	var beta: Dictionary = three.towns.filter(func(tn): return tn.get("id", "") == "bb")[0]
	t.check(three.ferries.size() == 1 and three.ferries[0].z > beta.z, "a 3-city trip: the ferry after Beta")
	t.check(absf(three.length - Route.track_length(180) - Route.FERRY_GAP) < 1.0, "3-city track of 180 driven km")
	# the race: stopped on the quay, the ferry takes the car over; time and fuel do not move meanwhile
	var r := Race.new("xc60", s, 1)
	var started := []
	var ended := []
	r.ferry_started.connect(func(fr): started.append(fr))
	r.ferry_ended.connect(func(): ended.append(true))
	r.z = f.z - 50.0
	r.speed = 0.0
	var idle := {"accel": false, "brake": false, "steer": 0.0}
	r.step(0.1, idle)
	t.check(is_equal_approx(r.ferry_left, Race.FERRY_TIME) and started.size() == 1 and started[0] == f, "stopped on the quay: the ferry starts")
	var time0 := r.time_left
	var fuel0: float = r.fuel.level
	r.time_left = 0.1
	r.step(0.1, idle)
	t.check(r.state == "running", "on board the clock does not run out")
	r.time_left = time0
	var left := r.ferry_left
	t.check(is_equal_approx(left, Race.FERRY_TIME - 0.1), "on board the crossing counts down")
	var on_board := 0.1
	while r.ferry_left > 0.0 and on_board < 3.5:
		r.step(0.1, {"accel": true, "brake": false, "steer": 1.0})
		on_board += 0.1
	t.check(absf(on_board - Race.FERRY_TIME) < 0.15, "the crossing takes FERRY_TIME (%.1f)" % on_board)
	t.check(r.time_left == time0 and r.fuel.level == fuel0, "no time, no fuel on board")
	t.check(r.ferry_left <= 0.0 and r.z == f.z_out and r.speed == 0.0 and ended.size() == 1, "off the ramp on the far quay (z %.0f)" % r.z)
	t.check(is_equal_approx(r.x, 0.5), "in the driving lane")
	# driving into the barrier: a crash, then (stopped) the ferry
	var r2 := Race.new("xc60", s, 1)
	r2.z = f.z - 30.0
	r2.speed = 25.0
	var hit := false
	var furthest := 0.0
	var fuel2: float = r2.fuel.level
	for i in 20:
		r2.step(0.1, {"accel": true, "brake": false, "steer": 0.0})
		hit = hit or r2.last_crash > 0.0
		furthest = maxf(furthest, r2.z)
		if r2.ferry_left > 0.0: break
	t.check(hit and furthest <= f.z and r2.fuel.level < fuel2 - Race.CRASH_FUEL + 0.5, "hit the barrier (furthest %.1f)" % furthest)
	t.check(r2.ferry_left > 0.0 and r2.speed == 0.0, "stopped dead, then boarded")
	# the chase ends on boarding; pausing (no step) changes nothing
	var r3 := Race.new("xc60", s, 1)
	r3.z = f.z - 10.0
	r3._call_police()
	r3.step(0.1, idle)
	t.check(r3.ferry_left > 0.0 and r3.police.is_empty(), "boarding ends the chase")
	var paused := r3.ferry_left
	t.check(r3.ferry_left == paused, "no step, no change")
	# traffic keeps off the quay and the crossing
	t.check(not r.traffic.cars.any(func(c): return c.active and c.z > f.z - Route.FERRY_QUAY and c.z < f.z_out), "no traffic on the quay")
	GameData._countries.erase(CODE)
	GameData.current = was
