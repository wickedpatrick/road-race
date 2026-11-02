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
		if code == "pl": t.check(kinds.size() >= 4 and kinds.has("snow"), "Poland: the weather differs by region, snow in the mountains")
		if code == "is": t.check(kinds.keys() == ["snow"], "Iceland: snow everywhere")
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
	# snow: moving sideways takes 1.6x as long, and let go the car keeps turning a moment (sideways moves measured
	# against the same drive without steering, so the bend's own push cancels out)
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
	t.check(absf(dry_turn / snow_turn - Weather.turn_time("snow")) < 0.01, "on snow a turn takes 1.6x as long (%.3f / %.3f)" % [dry_turn, snow_turn])
	t.check(is_equal_approx(side_move.call("sun", 15, 30), dry_turn), "dry: let go, the car goes straight at once")
	var drift: float = side_move.call("snow", 15, 30) - snow_turn
	var per_s := snow_turn / 0.25
	t.check(absf(drift - per_s * Weather.drift("snow")) < 0.005, "snow: let go, the car turns on for %.1f s (%.3f)" % [Weather.drift("snow"), drift])
	t.check(Weather.time_factor("snow") > 1.0 and Weather.time_factor("sun") == 1.0, "slippery or foggy trips get more time")
	# fog: the view fades to white close ahead
	var v := WorldView.new()
	var fr := Race.new("xc60", Route.build("krakow", "rzeszow"), 1)
	v.bind(fr, "fog")
	var near_fog := v._thick_fog(40)
	v.bind(fr, "sun")
	t.check(near_fog > 0.8 and v._thick_fog(40) == 0.0, "in thick fog 200 m ahead is almost white")
	v.free()
