extends RefCounted
func run(t) -> void:
	var routes := [["krakow", "rzeszow"], ["gdansk", "gdynia"], ["olsztyn", "bialystok"]]
	for i in routes.size():
		var s := Route.build(routes[i][0], routes[i][1])
		var tf: Traffic = Traffic.build(s, 5)
		t.check(tf.cars.size() > 5, "stage %d has traffic" % i)
		var ok_speed := true
		var ok_start := true
		var lane_ok := true
		var oncoming := 0
		for c in tf.cars:
			if c.speed >= 47.0 * 0.6: ok_speed = false
			var d := Route.dual_f(s, c.z)
			if c.dir > 0:
				if c.z < 100.0: ok_start = false
				if not Traffic.own_lanes(d).has(c.lane_x): lane_ok = false
			else:
				oncoming += 1
				if not Traffic.oncoming_lanes(d).has(c.lane_x): lane_ok = false
		t.check(ok_speed, "stage %d traffic slower than slowest player" % i)
		t.check(ok_start, "stage %d no traffic near start going the player's way" % i)
		t.check(lane_ok, "stage %d traffic keeps to its lanes (oncoming on the left / far carriageway)" % i)
		t.check(oncoming > 3, "stage %d has oncoming traffic" % i)
		for k in 4000:
			tf.update(0.1)
		var inside := true
		for c in tf.cars:
			if c.active and c.z > Track.build(s, 5).total_length: inside = false
		t.check(inside, "stage %d traffic never leaves the track" % i)
	# road layout and limits: dual carriageway on the A4 and in big cities, a single road elsewhere
	var kr := Route.build("krakow", "rzeszow")
	var kb := Route.build("krakow", "bielsko")
	var wad: Dictionary = kb.towns.filter(func(x): return x.name == "Wadowice")[0]
	t.check(Route.dual_at(kr, 1225.0) and not Route.dual_at(kb, 440.0), "A4 is a dual carriageway, the DK52 a single road")
	t.check(Route.dual_at(kb, 10.0) and Route.speed_limit_at(kb, 10.0) == 70, "a big city: dual carriageway, 70 km/h")
	t.check(not Route.dual_at(kb, wad.z) and Route.speed_limit_at(kb, wad.z) == 50, "a small town on an ordinary road: single, 50 km/h")
	var boch: Dictionary = kr.towns.filter(func(x): return x.name == "Bochnia")[0]
	t.check(Route.speed_limit_at(kr, boch.z) == 70, "a small town on an expressway or motorway: 70 km/h")
	# oncoming cars keep coming from far ahead of the player
	var tf3: Traffic = Traffic.build(kb, 3)
	var pz := 200.0
	for k in 600:
		pz += 25.0 * 0.05
		tf3.update(0.05, pz, 0.5, 25.0)
	var ahead := 0
	for c in tf3.cars:
		if c.active and c.dir < 0 and c.z > pz and c.z < pz + 1500.0: ahead += 1
	t.check(ahead >= 3, "oncoming traffic keeps coming (%d ahead)" % ahead)
	var tf2: Traffic = Traffic.build(Route.build("krakow", "rzeszow"), 9)
	tf2.cars = [{"z": 100.0, "lane_x": 0.5, "speed": 10.0, "kind": "car", "color_idx": 0, "active": true},
		{"z": 160.0, "lane_x": -0.5, "speed": 10.0, "kind": "truck", "color_idx": 1, "active": true}]
	t.check(tf2.check_collision(100.0, 0.5, 0.18) == 0, "hit same lane same z")
	t.check(tf2.check_collision(100.0, -0.5, 0.18) == -1, "no hit other lane")
	t.check(tf2.check_collision(115.0, 0.5, 0.18) == -1, "no hit when far in z")
	t.check(tf2.nearest_ahead(110.0) == 1, "nearest ahead skips passed car")
	t.check(tf2.nearest_ahead(200.0) == -1, "nothing ahead")
