extends SceneTree
## Dev-only benchmark: which way of driving is fastest. Three cars (the weakest, an SUV, the best) and three
## strategies ("legal", "dodge", "flat", see Bot.strategy) on a sample of roads per country; prints wins, the share of
## time left, fines, shaken-off officers and the stamps it would earn. Env RR_CODES (pl,de,us,ca), RR_PER (roads per
## country), RR_CARS.
## Run: Godot --headless --path . --script tests/strategy_bench.gd
func _init() -> void:
	var codes: Array = Array((OS.get_environment("RR_CODES") if OS.get_environment("RR_CODES") != "" else "pl,de,us,ca").split(","))
	var per := int(OS.get_environment("RR_PER")) if OS.get_environment("RR_PER") != "" else 5
	var cars: Array = Array((OS.get_environment("RR_CARS") if OS.get_environment("RR_CARS") != "" else "yaris,xc60,supercar").split(","))
	var strategies := ["legal", "dodge", "flat"]
	var stages := []
	for code in codes:
		GameData.current = code
		var roads: Array = GameData.country().roads.duplicate()
		var rng := RandomNumberGenerator.new()
		rng.seed = 7
		for i in per:
			var r: Dictionary = roads.pop_at(rng.randi() % roads.size())
			stages.append([code, r.a, r.b])
	var sums := {}
	for st_def in stages:
		GameData.current = st_def[0]
		var st := Route.build(st_def[1], st_def[2])
		var line := "%s %-28s %4d km %4ds" % [st_def[0], st.name.substr(0, 28), st.km, st.duration]
		for car in cars:
			for strat in strategies:
				var r := Race.new(car, st, 11)
				var b := Bot.new()
				b.strategy = strat
				b.cruise = 0.9 if strat == "legal" else 1.0
				var escapes := [0]
				r.police_crashed.connect(func(): escapes[0] += 1)
				var guard := 0
				while r.state == "running" and guard < 60 * 1200:
					r.step(1.0 / 60.0, b.decide(r))
					guard += 1
				var share: float = r.time_left / st.duration if r.state == "won" else 0.0
				var stamps := Postcards.stamps_for(r.time_left, st.duration, car) if r.state == "won" else 0
				var key: String = car + " " + strat
				if not sums.has(key): sums[key] = {"n": 0, "won": 0, "share": 0.0, "fines": 0, "esc": 0, "stamps": [0, 0, 0, 0, 0, 0]}
				var sm: Dictionary = sums[key]
				sm.n += 1
				sm.won += int(r.state == "won")
				sm.share += share
				sm.fines += r.fines
				sm.esc += escapes[0]
				sm.stamps[stamps] += 1
				line += "  %s/%s %s %3.0f%% f%d e%d" % [car.substr(0, 4), strat.substr(0, 1), r.state.substr(0, 3), share * 100.0, r.fines, escapes[0]]
		print(line)
	print("")
	print("car       strategy  won    time left  fines/trip  escapes  stamps 0-5")
	for key in sums:
		var sm: Dictionary = sums[key]
		print("%-19s %2d/%-2d  %5.1f%%   %5.2f     %3d     %s" % [key, sm.won, sm.n, sm.share / sm.n * 100.0, float(sm.fines) / sm.n, sm.esc, str(sm.stamps)])
	quit()
