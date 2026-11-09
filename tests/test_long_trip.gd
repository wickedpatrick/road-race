extends RefCounted
## A very long trip (Moscow - Vladivostok, ~9000 km): a fixture chain of six cities 1500 km apart. The track grows
## with the square root of the distance, so it stays near the longest trips across the USA or Canada, and the
## autopilot finishes it in the time limit.
const CODE := "zz_long"
const LEG := 1500

static func fixture() -> Dictionary:
	var c: Dictionary = GameData.localize(GameData.load_json(GameData.DIR + "countries/pl/country.json"))
	c.code = CODE
	c["cities"] = {}
	c["roads"] = []
	for i in 7:
		c.cities["c%d" % i] = {"name": "City%d" % i, "lat": 55.0, "lon": 40.0 + i * 20.0, "pop": 500, "region": "R%d" % i}
		if i == 0: continue
		c.roads.append({"a": "c%d" % (i - 1), "b": "c%d" % i, "km": LEG, "road": "R%d" % (250 + i),
			"towns": [["Town%da" % i, 300], ["Town%db" % i, 700], ["Town%dc" % i, 1100]],
			"zones": [[LEG / 2, "fields", "R%d" % (i - 1)], [LEG, "forest", "R%d" % i]]})
	c["facts"] = {}
	c["landmarks"] = {}
	return c

## The longest trip on the map now being played (its real km): every pair of cities.
static func longest_km() -> int:
	var best := 0
	var ids: Array = Geo.cities().keys()
	for i in ids.size():
		for j in range(i + 1, ids.size()):
			best = maxi(best, Route.total_km(Route.find(ids[i], ids[j])))
	return best

func run(t) -> void:
	var was := GameData.current
	var longest := 0.0
	for code in ["us", "ca"]:
		GameData.current = code
		var km := longest_km()
		longest = maxf(longest, Route.track_length(km))
		print("  longest trip in %s: %d km, %.0f m of track" % [code, km, Route.track_length(km)])
	GameData._countries[CODE] = fixture()
	GameData.current = CODE
	var s := Route.build("c0", "c6")
	print("  9000 km fixture: %.0f m of track, %.0f s limit, %d stations" % [s.length, s.duration, s.stations.size()])
	t.check(s.km == LEG * 6 and is_finite(s.length) and is_finite(s.duration) and s.duration > 0.0, "9000 km: a finite track and limit")
	t.check(s.length <= longest * 1.5, "9000 km: at most 1.5x the longest trip in the USA or Canada (%.0f, %.0f)" % [s.length, longest])
	t.check(s.towns.size() == 25 and s.stations.size() >= int(s.length / Route.STATION_EVERY) - 1, "9000 km: every town and enough stations")
	t.check(absf(Route.km_between(s, 0.0, s.length) - LEG * 6) < 1.0, "9000 km: real km on the boards")
	# Bot.run_race gives up after 15 minutes: this one takes longer
	var r := Race.new("xc60", s, 11)
	var b := Bot.new()
	var guard := 0
	while r.state == "running" and guard < 60 * 3600:
		r.step(1.0 / 60.0, b.decide(r))
		guard += 1
	t.check(r.state == "won" and r.time_left > 15.0, "9000 km: the autopilot finishes in the limit (%s, %.0f s left)" % [r.state, r.time_left])
	GameData._countries.erase(CODE)
	GameData.current = was
