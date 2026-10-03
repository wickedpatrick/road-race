extends RefCounted
## Map data sanity and route building.
func run(t) -> void:
	t.check(Geo.CITIES.size() == 28, "25 biggest cities plus Zakopane, Zamość, Łomża")
	t.check(Geo.CITIES.has("zakopane") and Geo.CITIES.has("zamosc") and Geo.CITIES.has("lomza"), "required towns on the map")
	var data_ok := true
	for r in Geo.ROADS:
		if not Geo.CITIES.has(r.a) or not Geo.CITIES.has(r.b): data_ok = false
		var prev := 0.0
		for tw in r.towns:
			if tw[1] <= prev or tw[1] >= r.km: data_ok = false
			prev = tw[1]
		prev = 0.0
		for zn in r.zones:
			if zn[0] <= prev or not Biome.DATA.has(zn[1]): data_ok = false
			prev = zn[0]
		if prev != r.km: data_ok = false
	t.check(data_ok, "roads: known cities, towns and zones ordered inside the road, zones cover it")
	# every city reaches every other one
	var ids := Geo.city_ids()
	var all_ok := true
	for a in ids:
		for b in ids:
			if a != b and Route.find(a, b).is_empty(): all_ok = false
	t.check(all_ok, "road network connects all cities")
	# Kraków - Rzeszów: the A4 through Bochnia, Tarnów, Dębica in that order
	var s := Route.build("krakow", "rzeszow")
	var names := []
	for tw in s.towns: names.append(tw.name)
	t.check(names[0] == "Kraków" and names[-1] == "Rzeszów", "route starts and ends in the chosen cities")
	t.check(names.find("Bochnia") < names.find("Tarnów") and names.find("Tarnów") < names.find("Dębica"), "towns in driving order")
	t.check(s.km == 165 and Route.road_at(s, 100.0) == "A4", "distance and road number")
	# reversed direction mirrors the towns
	var back := Route.build("rzeszow", "krakow")
	var bn := []
	for tw in back.towns: bn.append(tw.name)
	t.check(bn.find("Dębica") < bn.find("Tarnów"), "reverse route lists towns in reverse")
	var tar: Dictionary = s.towns[names.find("Tarnów")]
	t.check(absf(Route.km_between(s, 0.0, tar.z) - 80.0) < 0.5, "town placed at its real kilometre")
	# multi-leg: Gdańsk - Kraków passes big cities on the way
	var long := Route.build("gdansk", "krakow")
	var bigs := 0
	for tw in long.towns:
		if tw.big and not tw.get("start", false) and not tw.get("finish", false): bigs += 1
	t.check(bigs >= 2 and long.path.size() == bigs + 2, "big cities on the way are listed as waypoints")
	var zones_ok := true
	var z := 0.0
	for zn in long.zones:
		if absf(zn.z0 - z) > 0.01: zones_ok = false
		z = zn.z1
	t.check(zones_ok and z > long.length, "zones are contiguous and run past the finish")
	t.check(Route.zone_at(s, 10.0).biome == "foothills" and Route.zone_at(s, s.length - 10.0).biome == "foothills", "zone lookup")
	t.check(not Route.town_at(s, tar.z).is_empty() and Route.town_at(s, tar.z + 300.0).is_empty(), "town lookup")
	# signs: every town gets a name board, and distance boards list the destination last
	var items := Scenery.build(s, 1)
	var signs := 0
	var boards_ok := true
	var boards := 0
	for k in items:
		for it in items[k]:
			if it.type == "town_sign": signs += 1
			if it.type == "board":
				boards += 1
				if it.lines[-1][0] != "Rzeszów" or it.lines[-1][1] < 1: boards_ok = false
	t.check(signs == s.towns.size() - 1, "entry sign for every town after the start")
	t.check(boards >= 3 and boards_ok, "distance boards end with the destination")
	# cities reached for the "visited" map: start, cities passed, the destination only at the end
	var cr := Route.build("krakow", "gdansk")
	var mid := Route.cities_reached(cr, cr.length * 0.5)
	t.check(mid.has("krakow") and not mid.has("gdansk"), "halfway: start reached, destination not yet")
	var all := Route.cities_reached(cr, cr.length + 1.0)
	t.check(all.has("gdansk") and all.size() >= 3, "at the finish: destination and the cities on the way (%s)" % str(all))
