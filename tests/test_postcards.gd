extends RefCounted
## Postcards: one per map city, its landmarks, stamps for a result, the best result kept.

func run(t) -> void:
	var sizes := {"pl": 30, "cz": 20, "is": 13, "gb": 30, "de": 32, "sk": 16, "lt": 13, "at": 19, "hr": 18}
	for code in sizes:
		var ids := Postcards.cities(code)
		var map: Dictionary = GameData.country(code).cities
		var sorted := true
		for i in range(1, ids.size()):
			if map[ids[i]].pop > map[ids[i - 1]].pop: sorted = false
		t.check(ids.size() == sizes[code] and ids.all(func(id): return map.has(id)) and sorted, "%s: a postcard for each of the %d map cities, biggest first" % [code, sizes[code]])
		t.check(ids.all(func(id): return Postcards.landmarks(code, id).size() in [1, 2]), "%s: every postcard shows one or two landmarks" % code)
	t.check(Postcards.landmarks("pl", "krakow").map(func(lm): return lm.kind) == ["wawel", "dragon"], "Kraków: Wawel and the dragon")
	t.check(Postcards.landmarks("pl", "poznan").size() == 1, "Poznań: one landmark")
	# stamps: 1 for arriving, up to 5 with lots of time left
	var cases := [[0.0, 1], [14.9, 1], [15.0, 2], [30.0, 3], [45.0, 4], [60.0, 5], [90.0, 5]]
	t.check(cases.all(func(c): return Postcards.stamps_for(c[0], 100.0) == c[1]), "stamps by the time left: 1 to 5")
	var ids := CarStats.ids()
	t.check(Postcards.stamps_for(90.0, 100.0, ids[0]) == 2 and Postcards.stamps_for(90.0, 100.0, ids[1]) == 3 and Postcards.stamps_for(90.0, 100.0, ids[3]) == 4 and Postcards.stamps_for(90.0, 100.0, ids[4]) == 5 and Postcards.stamps_for(90.0, 100.0, ids[-1]) == 5, "each car earns only so many stamps: the weakest two, from the fifth car all five")
	t.check(Postcards.stamps_for(0.0, 100.0, ids[0]) == 1 and Postcards.car_for_stamps(3) == ids[1] and Postcards.car_for_stamps(5) == ids[4], "arriving still gives one; the slowest car for more stamps")
	var cards := {}
	t.check(Postcards.grant(cards, ["krakow"], 2026) == ["krakow"] and cards.krakow == {"stamps": 1, "year": 2026}, "a visit gives the postcard with one stamp")
	t.check(Postcards.grant(cards, ["krakow"], 2027).is_empty(), "visiting again gives nothing new")
	t.check(Postcards.stamp(cards, "krakow", 4, 2026) == 1 and cards.krakow.stamps == 4, "a fast arrival adds stamps")
	t.check(Postcards.stamp(cards, "krakow", 2, 2027) == 4 and cards.krakow.stamps == 4 and cards.krakow.year == 2026, "a slower one takes none away")
	Postcards.grant(cards, ["krakow"], 2028)
	t.check(cards.krakow.stamps == 4, "passing through again keeps the best")
	var fresh := {}
	t.check(Postcards.stamp(fresh, "gdansk", 3, 2026) == 0 and fresh.gdansk == {"stamps": 3, "year": 2026}, "first arrival creates the postcard")
	var old := {}
	Postcards.migrate(old, ["krakow", "wieliczka"], Postcards.cities("pl"))
	t.check(old.keys() == ["krakow"] and old.krakow == {"stamps": 1}, "old profiles: visited map cities get their postcard, without a year")
	t.check(Postcards.total({"a": {"stamps": 3}, "b": {"stamps": 2}}) == 5, "stamps add up")
	# old profiles: every country's visited cities get their postcards, not only the country being played
	var places := {"cz": {"visited": ["praha", "brno"]}, "pl": {"visited": ["krakow"], "postcards": {"krakow": {"stamps": 3}}}}
	Postcards.migrate_places(places)
	t.check(places.cz.postcards.keys() == ["praha", "brno"] and places.pl.postcards.krakow.stamps == 3, "old profiles: postcards in every country played")
	# routes: towns between the map cities that have a landmark, under the pair of cities (bigger first)
	var counts := {"pl": [38, 62], "cz": [16, 24], "is": [9, 12], "gb": [42, 63], "de": [44, 58], "at": [22, 34], "sk": [11, 15],
		"lt": [11, 16], "us": [34, 47], "ca": [8, 7]}
	for code in counts:
		var rs := Postcards.routes(code)
		var map: Dictionary = GameData.country(code).cities
		var uniq := {}
		var ok := true
		for rt in rs:
			if map[rt.a].pop < map[rt.b].pop or rt.towns.is_empty(): ok = false
			for tn in rt.towns:
				uniq[tn] = true
				if Postcards.landmarks(code, tn).is_empty(): ok = false
		t.check(ok and rs.size() == counts[code][0] and uniq.size() == counts[code][1], "%s: %d routes with %d town postcards, bigger city first" % [code, rs.size(), uniq.size()])
		t.check(Postcards.summary(code, {}).all == Postcards.cities(code).size() + counts[code][1], "%s: the album counts the towns too" % code)
	var kr: Array = Postcards.routes("pl").filter(func(rt): return rt.a == "krakow" and rt.b == "rzeszow")
	t.check(kr.size() == 1 and kr[0].towns == ["Bochnia", "Tarnów"], "Kraków - Rzeszów: its towns in order from Kraków (%s)" % [kr])
	t.check(Postcards.routes("pl").filter(func(rt): return rt.a == "krakow" and rt.b == "katowice").is_empty(), "a route without landmark towns is left out")
	t.check(Postcards.routes("pl").filter(func(rt): return rt.towns.has("Włocławek")).size() == 2, "Włocławek under both of its routes")
	var pl_routes := Postcards.routes("pl")
	t.check(Postcards.cities("pl").find(pl_routes[0].a) <= Postcards.cities("pl").find(pl_routes[-1].a), "routes from the biggest city")
	t.check(Postcards.landmarks("pl", "Tarnów").size() > 0 and Postcards.landmarks("pl", "Nowhere").is_empty(), "a town's landmarks by its name")
	var with_town := {"Tarnów": {"stamps": 1}, "krakow": {"stamps": 2}}
	t.check(Postcards.summary("pl", with_town).earned == 2 and Postcards.summary("pl", with_town).stamps == 2, "town postcards count as earned, stamps only for cities")
