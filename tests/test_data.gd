extends RefCounted
func run(t) -> void:
	var car_keys := ["name", "max_speed", "accel", "brake", "tank", "burn", "handling", "body_color", "halfwidth"]
	for id in CarStats.ALL_IDS:
		var c: Dictionary = CarStats.by_id(id)
		var ok := true
		for k in car_keys:
			if not c.has(k): ok = false
		t.check(ok, "car %s has all keys" % id)
	t.check(CarStats.ALL_IDS.size() == 3, "three cars")
	var stage_keys := ["name", "duration", "lanes", "length", "traffic_density", "stations", "scenery", "curve_amount", "hill_amount", "finish_label"]
	var durations := [180.0, 300.0, 180.0]
	t.check(StageData.COUNT == 3, "three stages")
	for i in StageData.COUNT:
		var s: Dictionary = StageData.at(i)
		var ok := true
		for k in stage_keys:
			if not s.has(k): ok = false
		t.check(ok, "stage %d has all keys" % i)
		t.check(is_equal_approx(s.duration, durations[i]), "stage %d duration" % i)
		var prev := 0.0
		var st_ok: bool = s.stations.size() >= 1
		for z in s.stations:
			if z <= prev or z >= s.length - 300.0: st_ok = false
			prev = z
		t.check(st_ok, "stage %d stations ordered inside track" % i)
		for id in CarStats.ALL_IDS:
			var c: Dictionary = CarStats.by_id(id)
			var empty_in: float = c.tank / (c.burn * (0.1 + 0.9 * 0.8))
			t.check(empty_in < s.duration, "%s needs a fuel stop on stage %d" % [id, i])
			# range between stations (and start/end) must be reachable on a full tank at 80% vmax
			var range_m: float = empty_in * c.max_speed * 0.8
			var last := 0.0
			var gaps_ok := true
			for z in s.stations:
				if z - last > range_m: gaps_ok = false
				last = z
			if s.length - last > range_m: gaps_ok = false
			t.check(gaps_ok, "%s can reach every station on stage %d" % [id, i])
