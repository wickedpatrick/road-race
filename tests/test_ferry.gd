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
		"dd": {"name": "Delta", "lat": 38.0, "lon": 24.0, "pop": 150, "region": "R3"},
		"ee": {"name": "Epsilon", "lat": 37.8, "lon": 24.3, "pop": 10, "region": "R3"},
		"ff": {"name": "Zeta", "lat": 37.6, "lon": 24.6, "pop": 150, "region": "R3"},
	}
	c["roads"] = [
		{"a": "aa", "b": "bb", "km": 400, "road": "A1", "towns": [["Port", 60], ["Isle", 390]],
			"zones": [[200, "fields", "R1"], [400, "upland", "R2"]],
			"ferry": {"from_km": 100, "to_km": 380, "name": "Alfa – Beta", "fact": {"pl": "Prom", "en": "Ferry"}}},
		{"a": "bb", "b": "cc", "km": 60, "road": "A2", "towns": [], "zones": [[60, "upland", "R2"]]},
		# both ends ports: the quays right at the cities, and a road that is all sea
		{"a": "dd", "b": "ee", "km": 30, "road": "A3", "towns": [], "zones": [[30, "fields", "R3"]],
			"ferry": {"from_km": 0.5, "to_km": 29.5, "name": "Delta – Epsilon", "fact": ""}},
		{"a": "ee", "b": "ff", "km": 20, "road": "A4", "towns": [], "zones": [[20, "fields", "R3"]],
			"ferry": {"from_km": 0, "to_km": 20, "name": "Epsilon – Zeta", "fact": ""}},
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
	var f: Dictionary = s.ferries[0]
	# the sea is not driven: the track is the driven km's, plus FERRY_GAP from the barrier to the far ramp (no open road
	# put in before the quay, Alfa's streets are far enough; after the ramp Isle is kept past the far pier)
	var post: float = f.pad1 - f.z_out
	t.check(is_equal_approx(f.pad0, f.z), "no padding needed before the quay")
	t.check(post > 0.0 and absf(s.towns.filter(func(tn): return tn.name == "Isle")[0].z - Route.TOWN_HALF - f.z_out - Route.FAR_PIER - Route.FERRY_CLEAR) < 1.0,
		"Isle's streets begin FERRY_CLEAR past the far pier (post %.0f)" % post)
	t.check(absf(s.length - Route.track_length(400 - 280) - Route.FERRY_GAP - post) < 1.0, "track of the driven 120 km (%.0f)" % s.length)
	t.check(s.km == 400, "the real total stays in km")
	t.check(absf(f.z - 100.0 * s.m_per_km) < 1.0, "barrier at km 100 (%.0f)" % f.z)
	t.check(is_equal_approx(f.z_out - f.z, Route.FERRY_GAP) and f.name == "Alfa – Beta" and f.fact == "Prom"
		and is_equal_approx(f.sea_km, 280.0), "the far quay, name, fact, sea km")
	var isle: Dictionary = s.towns.filter(func(tn): return tn.name == "Isle")[0]
	t.check(absf(isle.z - (110.0 * s.m_per_km + Route.FERRY_GAP + post)) < 1.0, "a town past the sea moved back by its km")
	t.check(Route.ferry_at(s, f.z - 100.0) == f and Route.ferry_at(s, f.z_out) == f and Route.ferry_at(s, f.z - Route.FERRY_QUAY - 5.0).is_empty(),
		"ferry_at covers the quay and the crossing")
	t.check(not s.stations.any(func(z): return z > f.z - Route.FERRY_QUAY - 40.0 and z < f.z_out + 40.0), "no station on the quay")
	t.check(not s.boards.any(func(bd): return bd.z > f.z - Route.FERRY_QUAY - 40.0 and bd.z < f.z_out + 40.0), "no board on the quay")
	# real km: the sea counts in full everywhere (HUD, mini-map, km driven, boards)
	t.check(absf(Route.km_between(s, 0.0, s.length) - 400.0) < 0.5 and absf(Route.km_between(s, 0.0, f.z) - 100.0) < 0.5
		and absf(Route.km_between(s, 0.0, f.z_out) - 380.0) < 0.5, "real km across the ferry")
	t.check(absf(Route.km_between(s, f.z_out, s.length) - 20.0) < 0.5, "real km past the ferry")
	var before_quay: Array = s.boards.filter(func(bd): return bd.z < f.z)
	t.check(not before_quay.is_empty() and before_quay[0].lines.any(func(l): return l[0] == "Beta" and l[1] >= 330),
		"a board before the quay counts the sea %s" % str(before_quay.map(func(bd): return bd.lines)))
	var back := Route.build("bb", "aa")
	var bf: Dictionary = back.ferries[0]
	# from Beta the sea starts at km 20, inside Beta's streets: open road is put in before the quay
	t.check(back.ferries.size() == 1 and is_equal_approx(bf.km0, 20.0) and absf(bf.pad0 - 20.0 * back.m_per_km) < 1.0,
		"b->a: the ferry at km 20 (%.0f)" % bf.pad0)
	t.check(bf.z - Route.FERRY_QUAY >= back.towns[0].half + Route.FERRY_CLEAR - 0.5, "b->a: the quay past Beta's streets")
	t.check(absf(Route.km_between(back, 0.0, back.length) - 400.0) < 0.5, "b->a: 400 real km")
	var three := Route.build("cc", "aa")
	var beta: Dictionary = three.towns.filter(func(tn): return tn.get("id", "") == "bb")[0]
	t.check(three.ferries.size() == 1 and three.ferries[0].z > beta.z, "a 3-city trip: the ferry after Beta")
	var tf: Dictionary = three.ferries[0]
	t.check(absf(three.length - Route.track_length(180) - (tf.pad1 - tf.pad0)) < 1.0, "3-city track of 180 driven km")
	t.check(tf.z - Route.FERRY_QUAY >= beta.z + beta.half, "the quay past Beta's streets mid-trip")
	# ports at both ends: open road between the streets and the quays, the car does not board at the start
	for pair in [["dd", "ee"], ["ee", "dd"], ["ee", "ff"], ["ff", "ee"]]:
		var p := Route.build(pair[0], pair[1])
		var pf: Dictionary = p.ferries[0]
		var name: String = "%s->%s" % pair
		t.check(is_finite(p.length) and p.length > 0.0 and is_finite(p.m_per_km), "%s: a finite track (%.0f)" % [name, p.length])
		t.check(not p.towns.any(func(tn): return pf.z - Route.FERRY_QUAY < tn.z + tn.half and pf.z_out > tn.z - tn.half),
			"%s: the quay is not in any town's streets" % name)
		t.check(pf.z_out < p.length - p.towns[-1].half - Route.FERRY_CLEAR + 0.5, "%s: the far ramp before the finish streets" % name)
		var rp := Race.new("xc60", p, 1)
		rp.step(0.1, {"accel": false, "brake": false, "steer": 0.0})
		t.check(rp.ferry_left == 0.0 and rp.state == "running", "%s: no boarding at the start" % name)
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
	t.check(is_equal_approx(r.x, 0.5) and r.hit_cooldown == 0.0, "in the driving lane, the roadside counting at once")
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
	t.check(not Hud.hints_shown(r2), "on board no banner or card covers the ferry's name")
	while r2.ferry_left > 0.0:
		r2.step(0.1, idle)
	t.check(Hud.hints_shown(r2) and r2.elapsed - r2.last_crash >= Hud.BUMP_BANNER_TIME and r2.elapsed - r2.last_hit >= Hud.BUMP_BANNER_TIME,
		"the barrier's crash banner does not come back on the far quay")
	# the chase ends on boarding
	var r3 := Race.new("xc60", s, 1)
	r3.z = f.z - 10.0
	r3._call_police()
	r3.step(0.1, idle)
	t.check(r3.ferry_left > 0.0 and r3.police.is_empty(), "boarding ends the chase")
	# pulled over on the quay: the ticket first, then the ferry
	var r4 := Race.new("xc60", s, 1)
	r4.z = f.z - 50.0
	r4._call_police()
	r4.police.phase = "pull_over"
	r4.police.z = r4.z + 11.0
	r4.police.speed = 0.0
	r4.step(0.1, idle)
	t.check(r4.ferry_left == 0.0 and r4.held_by_police(), "held by the police: no boarding")
	var waited := 0.0
	while r4.ferry_left <= 0.0 and waited < 5.0:
		r4.step(0.1, idle)
		waited += 0.1
	t.check(r4.fines == 1 and r4.ferry_left > 0.0 and waited >= Race.TICKET_TIME - 0.15 and r4.police.is_empty(),
		"boards once the ticket is written (%.1f s)" % waited)
	# traffic: none set out on the quay or the crossing; the player's way rolls slowly up the quay into the ship and is
	# gone at the barrier, an oncoming car goes behind the camera of a car just off the ramp before it is gone
	var trf := Traffic.build(s, 3)
	t.check(not trf.cars.any(func(c): return c.z > f.z - Route.FERRY_QUAY and c.z < f.z_out), "no traffic set out on the quay")
	t.check(trf.target_at(f.z - 40.0) * 3.6 <= Traffic.QUAY_KMH + 0.1, "slow on the quay (%.0f km/h)" % (trf.target_at(f.z - 40.0) * 3.6))
	trf.cars = [{"z": f.z - 40.0, "lane_x": 0.5, "speed": 7.0, "kind": "car", "color_idx": 0, "active": true, "dir": 1},
		{"z": f.z_out - 1.0, "lane_x": -0.5, "speed": 10.0, "kind": "car", "color_idx": 0, "active": true, "dir": -1}]
	var seen_on_quay := false
	for i in 100:
		trf.update(0.1, f.z_out, 0.5, 0.0)
		seen_on_quay = seen_on_quay or (trf.cars[0].active and trf.cars[0].z > f.z + 1.0)
	t.check(seen_on_quay and not trf.cars.any(func(c): return c.active and c.dir > 0 and c.z >= f.z + Route.FERRY_STERN + 0.5 and c.z < f.z_out),
		"the player's way drives up the ramp and is gone in the ship's stern door")
	t.check(not trf.cars.any(func(c): return c.active and c.dir < 0 and c.z > f.z and c.z < f.z_out - WorldView.PLAYER_DZ - 1.0),
		"oncoming: gone only behind the camera")
	# the look: a port before the barrier, the ship with its ramp down at it (both ways, and on the left-hand side)
	for lh in [false, true]:
		var cl := fixture()
		if lh: cl["drive"] = "left"
		GameData._countries[CODE] = cl
		for pair in [["aa", "bb"], ["bb", "aa"]]:
			var ls := Route.build(pair[0], pair[1])
			var lf: Dictionary = ls.ferries[0]
			var name: String = "%s->%s%s" % [pair[0], pair[1], " (left)" if lh else ""]
			var sc := Scenery.build(ls, 1)
			var all := []
			for idx in sc: all.append_array(sc[idx])
			var ships := all.filter(func(it): return it.type == "ferry_ship")
			var fsigns := all.filter(func(it): return it.type == "ferry_sign")
			t.check(ships.size() == 1 and absf(ships[0].z - lf.z) < 20.0, "%s: one ship at the barrier" % name)
			t.check(fsigns.size() == 1 and fsigns[0].z < lf.z - Route.FERRY_QUAY + 1.0 and fsigns[0].z > lf.z - Route.FERRY_QUAY - 60.0
				and fsigns[0].lat > Scenery.SIGN_EDGE and fsigns[0].text == lf.name, "%s: the ferry sign before the quay, on the kerb side" % name)
			t.check(all.any(func(it): return it.type == "quay"), "%s: a port on the quay" % name)
			var stray := all.filter(func(it): return it.z > lf.z - Route.FERRY_QUAY and it.z < lf.z_out)
			t.check(not stray.any(func(it): return it.type in ["board", "region", "pylon", "limit", "tree", "house", "building"]),
				"%s: nothing else on the quay" % name)
			t.check(Scenery.sign_texts(ls).has(lf.name), "%s: the ferry's name warmed" % name)
			var tr := Track.build(ls, 1)
			t.check(absf(tr.segment_at(lf.z - 60.0).curve) < 0.001 and absf(tr.segment_at(lf.z - 60.0).grade) < 0.001,
				"%s: the quay is flat and straight" % name)
	GameData._countries.erase(CODE)
	# every real road with a ferry, both ways: no station on or near a quay or the far pier, every town's entry sign
	# kept, no station to pull into on the far ramp
	for code in GameData.country_codes():
		GameData.current = code
		for rd in Geo.roads():
			if not rd.has("ferry"): continue
			for pair in [[rd.a, rd.b], [rd.b, rd.a]]:
				var rs := Route.build(pair[0], pair[1])
				var name: String = "%s %s->%s" % [code, pair[0], pair[1]]
				for rf in rs.ferries:
					t.check(not rs.stations.any(func(z): return z > rf.z - Route.FERRY_QUAY - 40.0 and z < rf.z_out + Route.FAR_PIER + 40.0),
						"%s: no station on the quays %s" % [name, str(rs.stations)])
					var rr := Race.new("xc60", rs, 1)
					rr.z = rf.z_out
					t.check(not rr.station_in_range(), "%s: no station at the far ramp" % name)
				var sc := Scenery.build(rs, 1)
				var signs := []
				for idx in sc:
					for it in sc[idx]:
						if it.type == "town_sign": signs.append(it.text)
				for tn in rs.towns:
					if not tn.get("start", false):
						t.check(signs.has(tn.name), "%s: %s's entry sign" % [name, tn.name])
	GameData.current = was
