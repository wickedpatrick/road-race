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
	var stage_keys := ["name", "duration", "lanes", "length", "traffic_density", "stations", "finish_label", "zones", "towns", "roads", "km"]
	var ids := Geo.city_ids()
	var keys_ok := true
	var st_ok := true
	var reach_ok := true
	var long_needs_fuel := true
	for a in ids:
		for b in ids:
			if a == b: continue
			var s: Dictionary = Route.build(a, b)
			for k in stage_keys:
				if not s.has(k): keys_ok = false
			var prev := 0.0
			if s.stations.size() < 1: st_ok = false
			for z in s.stations:
				if z <= prev or z >= s.length - 300.0: st_ok = false
				prev = z
			for id in CarStats.ALL_IDS:
				var c: Dictionary = CarStats.by_id(id)
				var fm := Fuel.new(c.tank, c.burn, c.max_speed)
				var empty_in: float = c.tank / fm.rate(c.max_speed * 0.8)
				if s.length >= 9000.0 and empty_in >= s.duration: long_needs_fuel = false
				# range between stations (and start/end) must be reachable on a full tank at 80% vmax
				var range_m: float = empty_in * c.max_speed * 0.8
				var last := 0.0
				for z in s.stations:
					if z - last > range_m: reach_ok = false
					last = z
				if s.length - last > range_m: reach_ok = false
	t.check(keys_ok, "every route stage has all keys")
	t.check(st_ok, "stations ordered inside every track")
	t.check(reach_ok, "every car can reach every station on every route")
	t.check(long_needs_fuel, "long routes need a fuel stop")
