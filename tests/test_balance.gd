extends RefCounted
## A steady autopilot (90% cruise, stops for fuel, avoids traffic) must be able to finish every car/stage
## combination with time to spare, and a careful one (70%) must still finish most of them.
func run(t) -> void:
	var careful_wins := 0
	for stage in StageData.COUNT:
		for car in CarStats.ALL_IDS:
			var r: Race = Bot.run_race(car, stage, 11, 0.9)
			t.check(r.state == "won" and r.time_left > 15.0, "autopilot wins %s stage %d with >15s spare (got %s, %.0fs)" % [car, stage, r.state, r.time_left])
			var c: Race = Bot.run_race(car, stage, 11, 0.7)
			if c.state == "won": careful_wins += 1
	t.check(careful_wins >= 8, "careful driving still wins most combinations (%d/9)" % careful_wins)
	# without ever stopping for fuel the longest stage cannot be finished
	var b := Bot.new()
	b.refuel_below = -1.0
	var r2 := Race.new("yaris", 1, 11)
	var n := 0
	while r2.state == "running" and n < 60 * 320:
		r2.step(1.0 / 60.0, b.decide(r2))
		n += 1
	t.check(r2.state == "out_of_fuel", "skipping fuel stops ends in out_of_fuel (got %s)" % r2.state)
