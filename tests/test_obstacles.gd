extends RefCounted
## Roadside obstacles (the car stops dead and loses fuel), fuel stations at the road, the tunnel near Lubień.
const GAS := {"accel": true, "brake": false, "steer": 0.0}

func fresh(from := "krakow", to := "rzeszow") -> Race:
	var r := Race.new("xc60", Route.build(from, to), 1)
	r.traffic.cars = []
	return r

## First obstacle on the right side within reach of a car at x = 1.8, past z.
func _right_obstacle(r: Race, z: float) -> Array:
	var best := []
	for idx in r.obstacles:
		for ob in r.obstacles[idx]:
			if ob[0] > z and ob[1] > 0.0 and ob[1] < 8.0 and (best.is_empty() or ob[0] < best[0]):
				best = ob
	return best

func run(t) -> void:
	var r := fresh()
	# every speed limit sign is solid by its post
	var sign_ok := true
	for idx in r.scenery:
		for it in r.scenery[idx]:
			if it.type == "limit":
				var found := false
				for ob in r.obstacles.get(idx, []):
					if is_equal_approx(ob[0], it.z) and ob[1] < it.lat and ob[2] > it.lat: found = true
				var near_station: bool = r.stage.stations.any(func(s): return absf(it.z - s) < Race.STATION_HALF_LEN + 6.0)
				if not found and not near_station: sign_ok = false
	t.check(sign_ok, "speed limit sign posts are obstacles")
	# driving into a post: stop dead, -3 l, moved clear towards the road
	var ob := _right_obstacle(r, 500.0)
	t.check(not ob.is_empty(), "there is an obstacle by the right edge")
	r.z = ob[0] - Race.CRASH_FRONT - 6.0
	r.x = ((ob[1] + ob[2]) * 0.5) / Track.ROAD_HALF_WIDTH
	r.speed = Race.OFFROAD_SPEED
	var fuel0 := r.fuel.level
	for i in 60:
		r.step(1.0 / 60.0, {"accel": true, "brake": false, "steer": 0.0})
		if r.last_crash > 0.0: break
	var hit := r.last_crash > 0.0
	t.check(hit and r.speed == 0.0, "hitting a roadside obstacle stops the car at once")
	t.check(absf(fuel0 - r.fuel.level - Race.CRASH_FUEL) < 0.05, "the crash costs 3 litres")
	t.check(r.z + Race.CRASH_FRONT <= ob[0] + 0.01, "the car stops before the obstacle")
	var hw: float = r.stats.halfwidth * Track.ROAD_HALF_WIDTH
	t.check(r.x * Track.ROAD_HALF_WIDTH + hw < ob[1], "the car is put back beside it, towards the road")
	var crash_at := r.last_crash
	for i in 120: r.step(1.0 / 60.0, GAS)
	t.check(r.last_crash == crash_at and r.z > ob[0], "and can drive on past it")
	# no obstacles on the road itself
	var road_clear := true
	for idx in r.obstacles:
		for o in r.obstacles[idx]:
			if o[1] < Track.ROAD_HALF_WIDTH * 1.09 and o[2] > -Track.ROAD_HALF_WIDTH * 1.09: road_clear = false
	t.check(road_clear, "nothing solid stands on the road or the rumble strips")
	# stations: no obstacles there, pumps right beside the pit lane, a D-23 sign before
	var st: float = r.stage.stations[0]
	var st_clear := true
	for idx in r.obstacles:
		for o in r.obstacles[idx]:
			if absf(o[0] - st) < Race.STATION_HALF_LEN: st_clear = false
	t.check(st_clear, "a fuel station is a safe zone")
	var pumps := 0
	var d23 := false
	for idx in r.scenery:
		for it in r.scenery[idx]:
			if it.type == "pump" and absf(it.z - st) < Race.STATION_HALF_LEN and it.lat < 8.0: pumps += 1
			if it.type == "station_sign" and absf(it.z - (st - Scenery.STATION_SIGN_BEFORE)) < 1.0: d23 = true
	t.check(pumps >= 2 and d23, "pumps stand at the road, a D-23 sign warns before the station")
	r.z = st
	r.x = 1.8
	r.speed = 3.0
	r.step(0.1, {"accel": false, "brake": false, "steer": 1.0})
	t.check(r.x <= Race.STATION_MAX_X and r.state == "running", "the kerb keeps the car off the pumps")
	# the tunnel under Luboń Mały on the S7
	var zr := fresh("krakow", "zakopane")
	var tns: Array = zr.stage.tunnels
	t.check(tns.size() == 1 and tns[0].z1 - tns[0].z0 >= 120.0, "Kraków - Zakopane goes through a tunnel")
	var tn: Dictionary = tns[0]
	var lub: Dictionary = zr.stage.towns.filter(func(x): return x.name == "Lubień")[0]
	var rab: Dictionary = zr.stage.towns.filter(func(x): return x.name == "Rabka-Zdrój")[0]
	t.check(lub.z + lub.half < tn.z0 and rab.z - rab.half > tn.z1, "the tunnel lies between Lubień and Rabka")
	t.check(zr.stage.stations.all(func(s): return s < tn.z0 - 100.0 or s > tn.z1 + 100.0), "no station in the tunnel")
	var steep := 0.0
	var z: float = tn.z0
	while z < tn.z1:
		steep = maxf(steep, absf(zr.track.grade_at(z)))
		z += 5.0
	t.check(steep < 0.06, "the tunnel is nearly level (%.0f%%)" % (steep * 100.0))
	var items_in := 0
	for idx in zr.scenery:
		for it in zr.scenery[idx]:
			if it.z > tn.z0 and it.z < tn.z1: items_in += 1
	t.check(items_in == 0, "no trees or signs inside the tunnel")
	zr.z = (tn.z0 + tn.z1) * 0.5
	zr.x = 1.6
	zr.speed = 10.0
	for i in 30: zr.step(1.0 / 60.0, GAS)
	t.check(zr.last_crash > 0.0 and zr.x < 1.4, "the tunnel wall is solid")
	var back := Route.build("zakopane", "krakow")
	t.check(back.tunnels.size() == 1 and back.tunnels[0].z1 < back.length, "the tunnel is there on the way back too")
	# the other tunnels: S1 Laliki, S3 in the Sudetes, S52 Zielonki and S2 Ursynów (the last two under city districts)
	for tc in [["bielsko", "zwardon", false], ["wroclaw", "kamienna_gora", false], ["krakow", "katowice", true], ["warszawa", "lublin", true]]:
		var ts := Route.build(tc[0], tc[1])
		var ok: bool = ts.tunnels.size() == 1 and ts.tunnels[0].city == tc[2] and ts.tunnels[0].z1 - ts.tunnels[0].z0 >= 100.0
		for tw in ts.towns:
			if tw.z + tw.half > ts.tunnels[0].z0 and tw.z - tw.half < ts.tunnels[0].z1: ok = false
		t.check(ok, "%s - %s goes through a tunnel clear of the towns" % [tc[0], tc[1]])
	t.check(not Route.build("bielsko", "zwardon").towns[-1].big, "a village at the finish gets houses, not city blocks")
