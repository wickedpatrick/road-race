extends RefCounted
## Road rankings (Rankings): the made-up drivers, the shared ranking of both ways, split times on a longer trip,
## saving on a win only, and profiles from before the rankings. The profile tests use a file of their own.
const TMP := "res://.godot/rr_test_profile.json"

func run(t) -> void:
	var was := GameData.current
	GameData.current = "pl"
	var k := Rankings.key("krakow", "rzeszow")
	t.check(k == Rankings.key("rzeszow", "krakow"), "A - B and B - A share one ranking")
	var f1 := Rankings.fake("pl", k)
	var f2 := Rankings.fake("pl", k)
	t.check(f1.size() == Rankings.DRIVERS and str(f1) == str(f2), "100 made-up drivers, the same every time")
	t.check(f1.all(func(r): return CarStats.has(r.car) and r.nick != ""), "every made-up driver has a nick and a car")
	var sorted := true
	for i in range(1, f1.size()): sorted = sorted and f1[i - 1].t <= f1[i].t
	t.check(sorted and f1[-1].t > f1[0].t * 1.35, "fastest first, spread from very good to slow (%.1f .. %.1f)" % [f1[0].t, f1[-1].t])
	# every road of every map has its anchors: the 1st place the empty road's flat-out run, the 70th the weakest car
	# keeping the limits
	var missing := []
	var off := []
	for c in GameData.countries():
		var cc: String = c.code
		var data: Dictionary = GameData.load_json(Rankings.DIR + cc + ".json")
		for rk in Rankings.keys(cc):
			if not (data.get("top", {}).has(rk) and data.get("slow", {}).has(rk) and data.get("roads", {}).has(rk)):
				missing.append(cc + ":" + rk)
				continue
			var fk := Rankings.fake(cc, rk)
			var at: Dictionary = Rankings.anchors(cc, rk)
			if fk[0].t != snappedf(at[1], 0.1) or absf(fk[69].t / at[70] - 1.0) > 0.03 or fk[1].t <= fk[0].t:
				off.append("%s:%s %.1f/%.1f %.1f/%.1f" % [cc, rk, fk[0].t, at[1], fk[69].t, at[70]])
		var nicks := {}
		for d in Rankings.roster(cc): nicks[d.nick] = true
		if nicks.size() != Rankings.DRIVERS: off.append(cc + ": nicks repeat")
	t.check(missing.is_empty(), "data/rankings covers every road of every map (%s)" % ", ".join(missing.slice(0, 5)))
	t.check(off.is_empty(), "the 1st place on its anchor, the 70th near the slow one (%s)" % ", ".join(off.slice(0, 5)))
	t.check(Rankings.position("pl", k, 1.0) == 1 and Rankings.position("pl", k, 1.0e6) == 101, "a position among 100 + the player")
	# the table shows the podium and the rows around a player further down
	var many := range(101).map(func(i): return {"me": i == 60})
	var shown := Rankings.shown(many, 21)
	t.check(shown.size() == 21 and shown.slice(0, 4) == [0, 1, 2, -1] and shown.has(60), "rows around the player (%s)" % str(shown))
	t.check(Rankings.shown(range(101).map(func(i): return {"me": i == 5}), 21) == range(21), "a player near the top: the first rows")
	# a trip over two roads: a split time at the city passed, each road's time for its own ranking
	var st := Route.build("krakow", "zamosc")
	st.weather = "sun"
	var r := Bot.run_race("supercar", st, 5, 1.0)
	t.check(r.state == "won" and r.splits.size() == 3 and r.splits[1][0] == "rzeszow", "split times at the start, Rzeszów and the finish (%s)" % str(r.splits))
	var times := Rankings.road_times("pl", st, r.splits)
	t.check(times.size() == 2 and times[0].key == k and times[1].key == Rankings.key("rzeszow", "zamosc"), "Kraków - Zamość counts for both its roads")
	var b0 := Rankings.best("pl", times[0].key)
	t.check(times.all(func(x): return x.t > 0.0) and times[0].t > b0 * 0.85 and times[0].t < b0 * 1.4,
		"a split scaled to the road's own stage is near its best (%.1f vs %.1f)" % [times[0].t, b0])
	# the profile: a win saves, a loss does not; the other way round shares the entry; the best one is kept
	var store := {}
	Rankings.record(store, "pl", [{"key": k, "from": "krakow", "to": "rzeszow", "t": 200.0}], "yaris", "rain", "2026-11-10")
	var rows := Rankings.record(store, "pl", [{"key": k, "from": "rzeszow", "to": "krakow", "t": 190.0}], "octavia", "sun", "2026-11-10")
	t.check(store.pl.size() == 1 and store.pl[k].t == 190.0 and store.pl[k].car == "octavia" and rows[0].new_best, "B - A improves the A - B entry")
	Rankings.record(store, "pl", [{"key": k, "from": "krakow", "to": "rzeszow", "t": 250.0}], "yaris", "sun", "2026-11-10")
	t.check(store.pl[k].t == 190.0, "a slower time keeps the best")
	var s = load("res://src/autoload/session.gd").new()
	s.save_path = TMP
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TMP))
	var single := Route.build("krakow", "rzeszow")
	var lost := Race.new("yaris", single, 1)
	lost.state = "out_of_time"
	lost.splits = [["krakow", 0.0]]
	t.check(s.record_trip(lost).is_empty() and s.rankings.is_empty(), "a lost trip saves nothing")
	var won := Race.new("yaris", single, 1)
	won.state = "won"
	won.splits = [["krakow", 0.0], ["rzeszow", 180.0]]
	var res: Array = s.record_trip(won)
	t.check(res.size() == 1 and s.rankings.pl[k].t == 180.0 and s.rankings.pl[k].car == "yaris", "a won trip saves its time")
	var saved = JSON.parse_string(FileAccess.get_file_as_string(TMP))
	t.check(saved is Dictionary and saved.rankings.pl[k].t == 180.0, "the time is in the saved profile")
	s.free()
	# a profile from before the rankings loads with all its data, and saves them back with the rankings added
	var old := {"total_km": 1234.5, "car_id": "yaris", "quality": "low", "language": "pl", "country": "pl",
		"places": {"pl": {"home_city": "krakow", "from_city": "rzeszow", "to_city": "lublin", "visited": ["krakow", "rzeszow"]}}}
	var fw := FileAccess.open(TMP, FileAccess.WRITE)
	fw.store_string(JSON.stringify(old))
	fw.close()
	var s2 = load("res://src/autoload/session.gd").new()
	s2.save_path = TMP
	s2.load_profile()
	t.check(s2.total_km == 1234.5 and s2.quality == "low" and s2.from_city == "rzeszow" and s2.visited.has("rzeszow") and s2.rankings.is_empty(),
		"an old profile without rankings loads with its data")
	s2.save_profile()
	var back = JSON.parse_string(FileAccess.get_file_as_string(TMP))
	t.check(back.total_km == 1234.5 and back.places.pl.home_city == "krakow" and back.rankings is Dictionary, "and saves it back with rankings")
	s2.free()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TMP))
	GameData.set_language("pl")
	GameData.current = was
