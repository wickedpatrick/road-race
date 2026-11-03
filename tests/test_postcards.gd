extends RefCounted
## Postcards: one per map city, its landmarks, stamps for a result, the best result kept.

func run(t) -> void:
	var sizes := {"pl": 30, "cz": 20, "is": 13, "gb": 30}
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
	var cases := [[10.0, 2], [0.0, 1], [4.9, 1], [15.0, 3], [25.0, 4], [35.0, 5], [90.0, 5]]
	t.check(cases.all(func(c): return Postcards.stamps_for(c[0], 100.0) == c[1]), "stamps by the time left: 1 to 5")
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
