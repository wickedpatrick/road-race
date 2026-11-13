extends RefCounted
## Weather by country and region: what each road gets, and how it changes the driving.
const GAS := {"accel": true, "brake": false, "steer": 0.0}
const BRAKE := {"accel": false, "brake": true, "steer": 0.0}

func run(t) -> void:
	for code in GameData.country_codes():
		GameData.current = code
		var kinds := {}
		var ok := true
		for r in Geo.roads():
			var w := Weather.for_road(r)
			if not Weather.KINDS.has(w): ok = false
			kinds[w] = kinds.get(w, 0) + 1
		t.check(ok, "%s: every road has a weather (%s)" % [code, kinds])
		var n := Geo.roads().size()
		var want := maxi(1, roundi(n * Weather.SHARE))
		var night := Route.night_roads()
		var by := func(w: String, at_night: bool) -> int:
			return Geo.roads().filter(func(r): return Weather.for_road(r) == w and night.has("%s|%s" % [r.a, r.b]) == at_night).size()
		t.check(by.call("rain", false) >= want and by.call("fog", false) >= want, "%s: a tenth of its roads in rain and in fog (%d, %d of %d)" % [code, by.call("rain", false), by.call("fog", false), n])
		var snow_ok: bool = GameData.country().get("weather", {}).get("snow", true)
		if night.size() >= 2:
			t.check(by.call("rain", true) == 1 and (by.call("snow", true) >= 1) == snow_ok, "%s: the hardest roads, rain and snow at night" % code)
		if not snow_ok: t.check(not kinds.has("snow"), "%s: never snow" % code)
		if code == "pl": t.check(kinds.size() >= 4 and kinds.has("snow"), "Poland: the weather differs by region, snow in the mountains")
		if code == "is": t.check(kinds.has("snow") and kinds.has("sun"), "Iceland: snow in the north, none in the south")
		if code == "gb":
			var scot := Geo.roads().filter(func(r): return Geo.city(r.a).region == "Scotland" and Geo.city(r.b).region == "Scotland")
			t.check(not scot.is_empty() and scot.all(func(r): return Weather.for_road(r) == "rain"), "Scotland: rain")
	GameData.current = "pl"
	var zak := Route.build("krakow", "zakopane")
	t.check(zak.weather == "snow", "Kraków - Zakopane: snow in the Tatras (%s)" % zak.weather)
	# snow: a longer way to stop, a slower bend, more time for the trip
	var stop := func(w: String) -> float:
		var st := Route.build("krakow", "rzeszow")
		st.weather = w
		var r := Race.new("xc60", st, 1)
		r.traffic.cars = []
		r.z = 600.0
		r.speed = 25.0
		var z0 := r.z
		while r.speed > 0.0: r.step(1.0 / 60.0, BRAKE)
		return r.z - z0
	t.check(stop.call("snow") > stop.call("sun") * 1.5 and stop.call("rain") > stop.call("sun"), "braking on snow takes much longer, on a wet road longer (%.0f / %.0f / %.0f m)" % [stop.call("sun"), stop.call("rain"), stop.call("snow")])
	var dry := Race.new("xc60", Route.build("krakow", "rzeszow"), 1)
	var sn := Route.build("krakow", "rzeszow")
	sn.weather = "snow"
	t.check(Race.new("xc60", sn, 1).corner_speed(10.0) < dry.corner_speed(10.0) * 0.9, "a bend must be taken slower on snow")
	# snow: the car turns in late and, let go, keeps turning a moment; held, it turns as hard as on a dry road
	# (sideways moves measured against the same drive without steering, so the bend's own push cancels out)
	var side_move := func(w: String, steer_frames: int, frames: int) -> float:
		var moved := 0.0
		for steering in [true, false]:
			var st := Route.build("krakow", "rzeszow")
			st.weather = w
			var r := Race.new("xc60", st, 1)
			r.traffic.cars = []
			r.z = 600.0
			r.speed = 20.0
			for i in frames:
				r.step(1.0 / 60.0, {"accel": false, "brake": false, "steer": 1.0 if steering and i < steer_frames else 0.0})
			moved += r.x if steering else -r.x
		return moved
	var dry_turn: float = side_move.call("sun", 15, 15)
	var snow_turn: float = side_move.call("snow", 15, 15)
	t.check(snow_turn < dry_turn * 0.75, "on snow the car turns in late (%.3f / %.3f in 0.25 s)" % [snow_turn, dry_turn])
	t.check(is_equal_approx(side_move.call("sun", 15, 30), dry_turn), "dry: let go, the car goes straight at once")
	var drift: float = side_move.call("snow", 15, 60) - snow_turn
	t.check(drift > 0.05, "snow: let go, the car keeps turning a moment (%.3f)" % drift)
	var dry_late: float = side_move.call("sun", 150, 150) - side_move.call("sun", 120, 120)
	var snow_late: float = side_move.call("snow", 150, 150) - side_move.call("snow", 120, 120)
	t.check(snow_late > dry_late * 0.97, "snow: steering held, the car turns as hard as on a dry road (%.3f / %.3f)" % [snow_late, dry_late])
	# snow at 180 km/h in a bend just within the grip: holding the steering keeps the car on the road
	var sb := Route.build("krakow", "rzeszow")
	sb.weather = "snow"
	var br := Race.new("xc60", sb, 1)
	br.traffic.cars = []
	var v180 := 50.0
	var bend: float = 0.9 * br.stats.handling * Race.STEER_RATE * Weather.grip("snow", "steer") / Race.corner_push(v180)
	for sg in br.track.segments: sg.curve = bend
	br.z = 500.0
	br.speed = v180
	var lowest := 0.0
	for i in 180:
		br.step(1.0 / 60.0, {"accel": true, "brake": false, "steer": 1.0})
		lowest = minf(lowest, br.x)
	t.check(lowest > -0.5 and br.x > lowest + 0.2, "snow, 180 km/h, a bend within the grip: held, the car comes back in (lowest x=%.2f, end x=%.2f)" % [lowest, br.x])
	t.check(Weather.time_factor("snow") > 1.0 and Weather.time_factor("sun") == 1.0, "slippery or foggy trips get more time")
	# fog: the view fades to white close ahead
	var v := WorldView.new()
	var fr := Race.new("xc60", Route.build("krakow", "rzeszow"), 1)
	v.bind(fr, "fog")
	var near_fog := v._thick_fog(40)
	v.bind(fr, "sun")
	t.check(near_fog > 0.8 and v._thick_fog(40) == 0.0, "in thick fog 200 m ahead is almost white")
	v.free()
