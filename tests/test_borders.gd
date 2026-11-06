extends RefCounted
## A map spanning several countries (the Southern Balkans' format: index `members`, country.json `parts`, a city's
## `country`, roads.json `borders`), on a tiny fixture of two cities across one border (not in index.json).
const CODE := "zz_test"

static func fixture() -> Dictionary:
	var c: Dictionary = GameData.localize(GameData.load_json(GameData.DIR + "countries/pl/country.json"))
	c.code = CODE
	c["parts"] = GameData.localize({
		"me": {"limits": {"road": 80}, "station": {"sign": "BENZINSKA PUMPA", "prices": [["95", "1,55"]]},
			"signs": {"town": "#ffffff"}, "plates": [["E", "#00aa00", "#ffffff"]]},
		"al": {"name": {"pl": "Albania", "en": "Albania"}, "limits": {"road": 70}, "station": {"sign": "KARBURANT"}},
	})
	c["cities"] = {
		"aa": {"name": "Alfa", "lat": 42.4, "lon": 19.3, "pop": 150, "region": "R1", "country": "me"},
		"bb": {"name": "Beta", "lat": 41.3, "lon": 19.8, "pop": 400, "region": "R2", "country": "al"},
	}
	c["roads"] = [{"a": "aa", "b": "bb", "km": 120, "road": "E762", "towns": [["Midtown", 30]],
		"zones": [[60, "fields", "R1"], [120, "upland", "R2"]], "borders": [[70, "me", "al", "Hani i Hotit"]]}]
	c["facts"] = {}
	c["landmarks"] = {}
	return c

func run(t) -> void:
	var was := GameData.current
	GameData._countries[CODE] = fixture()
	GameData.current = CODE
	t.check(Geo.city_part("aa") == "me" and Geo.city_part("bb") == "al", "cities know their part of the map")
	# part settings over the map's own, dictionaries merged key by key
	t.check(Geo.station("me").sign == "BENZINSKA PUMPA" and Geo.station("me").board == "PALIWO", "a part's station texts, the rest from the map")
	t.check(Geo.station("al").sign == "KARBURANT" and Geo.station("").sign == "STACJA PALIW", "each part its own sign, \"\" the map's")
	t.check(int(Geo.limits("me").road) == 80 and int(Geo.limits("me").express) == 140, "a part's limits over the map's")
	t.check(Geo.part("al").name == "Albania" and Geo.part("xx") == GameData.country(), "a part's name; an unknown part is the map")
	t.check(Scenery.plate("E762", "me")[1] == Color("#00aa00") and Scenery.plate("E762", "al")[1] == Scenery.SIGN_RED, "plates by part")
	# along the route: the start city's part, changed at the border
	var s := Route.build("aa", "bb")
	t.check(s.borders.size() == 1 and s.part0 == "me", "one border on the way, starting in Montenegro")
	var b: Dictionary = s.borders[0]
	t.check(b.from == "me" and b.to == "al" and b.name == "Hani i Hotit", "border a->b as in the data")
	t.check(absf(b.z - 70.0 * s.m_per_km) < 1.0, "border at its real kilometre (%.0f)" % b.z)
	t.check(Geo.part_at(s, 10.0) == "me" and Geo.part_at(s, b.z - 1.0) == "me" and Geo.part_at(s, b.z + 1.0) == "al"
		and Geo.part_at(s, s.length) == "al", "part lookup along the route")
	var back := Route.build("bb", "aa")
	var bb: Dictionary = back.borders[0]
	t.check(back.part0 == "al" and bb.from == "al" and bb.to == "me", "b->a mirrors the border")
	t.check(absf(bb.z - 50.0 * back.m_per_km) < 1.0, "mirrored border at km 50 from b (%.0f)" % bb.z)
	t.check(Geo.part_at(back, bb.z + 5.0) == "me", "after the mirrored border: Montenegro")
	# the crossing's limits and radar
	t.check(Route.sign_limit_at(s, b.z - Route.CROSS_40 + 5.0) == 40 and Route.sign_limit_at(s, b.z - Route.CROSS_20 + 5.0) == 20
		and Route.sign_limit_at(s, b.z + 5.0) == 20, "40, then 20 at the crossing")
	t.check(Route.sign_limit_at(s, b.z - Route.CROSS_40 - 30.0) == 80 and Route.sign_limit_at(s, b.z + Route.CROSS_AFTER + 30.0) == 70,
		"open road limit of the part before (80) and after (70) the border")
	t.check(s.radars.size() == 1 and s.radars[0] < b.z and s.radars[0] > b.z - Route.CROSS_20, "a radar right before the barriers, in the 20 zone")
	t.check(not s.stations.any(func(z): return z > b.z - Route.CROSS_40 - 100.0 and z < b.z + Route.CROSS_AFTER + 100.0), "no station at the crossing")
	# scenery: barriers on both sides, booths, the canopy, the board with the flag, the radar; signs by part
	var items := Scenery.build(s, 1)
	var kinds := {}
	var limits := []
	var town_parts := {}
	for idx in items:
		for it in items[idx]:
			kinds[it.type] = kinds.get(it.type, 0) + 1
			if it.type == "limit" and absf(it.z - b.z) < Route.CROSS_40 + 10.0: limits.append(it.limit)
			if it.type == "town_sign": town_parts[it.text] = it.get("p", "")
			if it.type == "border_board": t.check(it.flag == "al" and it.country == "Albania", "the board names the country entered")
	t.check(kinds.get("barrier", 0) == 2 and kinds.get("booth", 0) >= 1 and kinds.get("border_canopy", 0) == 1
		and kinds.get("radar", 0) == 1 and kinds.get("border_board", 0) == 1, "crossing scenery %s" % str(kinds))
	t.check(limits.has(40) and limits.has(20), "40 and 20 signs before the crossing %s" % str(limits))
	t.check(town_parts.get("Midtown", "") == "me" and town_parts.get("Beta", "") == "al", "place-name signs in their part %s" % str(town_parts))
	# the radar: too fast past it brings the police at once, slow enough nothing
	var r := Race.new("xc60", s, 1)
	r.z = s.radars[0] + 1.0
	r.speed = 60.0 / 3.6
	r._check_radar(s.radars[0] - 1.0)
	t.check(not r.police.is_empty(), "the radar catches 60 km/h in the 20 zone")
	var r2 := Race.new("xc60", s, 1)
	r2.z = s.radars[0] + 1.0
	r2.speed = 25.0 / 3.6
	r2._check_radar(s.radars[0] - 1.0)
	t.check(r2.police.is_empty(), "25 km/h passes the radar")
	GameData._countries.erase(CODE)
	GameData.current = was
