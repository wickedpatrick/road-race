extends RefCounted
## Data files (data/): every country in the index loads and is consistent, so a new country can be added by data alone.
func run(t) -> void:
	var rules := GameData.rules()
	t.check(rules.car_ids.size() >= 3 and rules.car_ids.all(func(id): return rules.cars[id].body_color is Color), "cars load in order, colours parsed")
	t.check(rules.biomes.has("fields"), "the default landscape exists")
	t.check(GameData.localize({"pl": "a", "en": "b"}) == "a" and GameData.localize({"en": "b"}) == "b", "texts by language")
	t.check(GameData.localize({"lat": 1.0, "name": {"pl": "x"}}) == {"lat": 1.0, "name": "x"}, "only text fields are localized")
	var codes := GameData.country_codes()
	t.check(codes.has("pl"), "Poland is in the country index")
	for code in codes:
		_check_country(t, code, rules)
		_check_trips(t, code)
	_check_gb(t)
	_check_gr(t)
	_check_world(t)
	GameData.current = "pl"

## Great Britain: motorways are M roads and the A roads built as motorways ("A1(M)"); Polish names on the map.
func _check_gb(t) -> void:
	GameData.current = "gb"
	t.check(Route.lanes_for("M6") == 3 and Route.lanes_for("A1(M)") == 3 and Route.lanes_for("A74(M)") == 3, "gb: M and A(M) roads are motorways")
	t.check(Route.lanes_for("A1") == 2 and Route.lanes_for("A38") == 2, "gb: other A roads are single carriageways")
	t.check(Geo.display_name("london") == "Londyn" and Geo.city("london").name == "London", "gb: Londyn on the map, London on the signs")
	GameData.current = "lt"
	t.check(Route.lanes_for("A1") == 3 and Route.lanes_for("A2") == 3, "lt: the A1 and A2 are motorways")
	t.check(Route.lanes_for("A12") == 2 and Route.lanes_for("A5") == 2 and Route.lanes_for("128") == 2, "lt: the A12, A5 and other roads are not")

## Greece: bilingual signs (every city, town and region has its Greek spelling), the Piraeus - Heraklion ferry,
## motorways A1, A2, A5, A7, A8.
func _check_gr(t) -> void:
	GameData.current = "gr"
	var c: Dictionary = GameData.country("gr")
	var missing := []
	for id in c.cities:
		for n in [c.cities[id].name, c.cities[id].region]:
			if Geo.native(n) == "": missing.append(n)
	for r in c.roads:
		for tw in r.towns:
			if Geo.native(tw[0]) == "": missing.append(tw[0])
		for zn in r.zones:
			if Geo.native(zn[2]) == "": missing.append(zn[2])
	t.check(missing.is_empty(), "gr: a Greek spelling of every city, town and region %s" % str(missing))
	var s := Route.build("peiraias", "irakleio")
	t.check(s.ferries.size() == 1 and absf(s.ferries[0].sea_km - 320.0) < 10.0, "gr: the ferry Peiraiás - Irákleio over ~320 km of sea")
	t.check(Route.build("irakleio", "peiraias").ferries.size() == 1, "gr: and back")
	t.check(["A1", "A2", "A5", "A7", "A8"].all(func(n): return Route.lanes_for(n) == 3), "gr: the A roads are motorways")
	t.check(Geo.city("athina").name == "Athína" and Geo.native("Athína") == "Αθήνα", "gr: Athína on the signs, Αθήνα above it")
	GameData.current = "pl"

## Every trip between neighbouring cities builds a playable stage (stations, limits, a track, scenery); a short trip
## over a ferry may go without a station.
func _check_trips(t, code: String) -> void:
	GameData.current = code
	var ok := true
	var trips := 0
	for a in Geo.city_ids():
		for b in Route.neighbours(a):
			var s := Route.build(a, b)
			trips += 1
			if (s.stations.is_empty() and s.ferries.is_empty()) or s.duration <= 0.0 or s.towns[0].id != a or s.towns[-1].id != b:
				ok = false; print("  %s: trip %s-%s broken" % [code, a, b])
			for zz in [10.0, s.length * 0.5, s.length - 10.0]:
				if Route.speed_limit_at(s, zz) <= 0 and not (Route.lanes_at(s, zz) == 3 and Geo.limits().has("unlimited_beyond_km")): ok = false
			for br in s.bridges:
				if br.z1 - br.z0 < Route.BRIDGE_MIN - 0.5: ok = false; print("  %s: trip %s-%s: %s squeezed (%.0f m)" % [code, a, b, br.name, br.z1 - br.z0])
			if Geo.roads().any(func(r): return r.has("bridge") and ((r.a == a and r.b == b) or (r.a == b and r.b == a))) and s.bridges.is_empty():
				ok = false; print("  %s: trip %s-%s lost its bridge" % [code, a, b])
			# a road part's own limit ([km, number, lanes, limit]) is posted on it away from the towns
			for rp in s.roads:
				var mid: float = (rp.z0 + rp.z1) * 0.5
				if rp.get("limit", 0) > 0 and Route.town_at(s, mid).is_empty() and Route.crossing_limit_at(s, mid) == 0 and Route.sign_limit_at(s, mid) != rp.limit:
					ok = false; print("  %s: trip %s-%s: %s not at its own %d" % [code, a, b, rp.road, rp.limit])
			for tn in s.tunnels:
				for tw in s.towns:
					if tw.z + tw.half > tn.z0 and tw.z - tw.half < tn.z1: ok = false; print("  %s: %s-%s tunnel in a town" % [code, a, b])
	var r := Race.new("xc60", Route.build(Geo.city_ids()[0], Route.neighbours(Geo.city_ids()[0])[0]), 1)
	for i in 120: r.step(1.0 / 60.0, {"accel": true, "brake": false, "steer": 0.0})
	t.check(ok and trips > 0 and r.z > 10.0, "%s: all %d trips build and drive" % [code, trips])

func _check_country(t, code: String, rules: Dictionary) -> void:
	var c := GameData.country(code)
	for key in ["code", "name", "drive", "region_label", "limits", "signs", "map", "outline", "outline_lines", "cities", "roads", "facts", "landmarks"]:
		t.check(c.has(key), "%s: country has %s" % [code, key])
	t.check(c.code == code, "%s: code matches its folder" % code)
	for k in ["express", "road", "city", "town_on_express", "town"]:
		t.check(c.limits.get(k, 0.0) > 0.0, "%s: speed limit %s" % [code, k])
	for k in ["town", "board", "board_motorway"]:
		t.check(c.signs.get(k, "") is String and Color.html_is_valid(c.signs.get(k, "")), "%s: sign colour %s" % [code, k])
	t.check(c.drive in ["right", "left"] and c.get("units", "") in ["metric", "imperial"], "%s: drive side and sign units" % code)
	var stn: Dictionary = c.get("station", {})
	t.check(stn.get("sign", "") != "" and stn.get("board", "") != "" and stn.get("region_sign", "") != ""
		and stn.get("prices", []).size() >= 2 and stn.prices.all(func(p): return p.size() == 2), "%s: fuel station texts in the country's language" % code)
	if true: # landmark boards by the road show the local name, not the player's
		var locals := true
		for town in c.landmarks:
			for lm in c.landmarks[town]:
				if not (lm.get("local", "") is String and lm.get("local", "") != ""): locals = false; print("  %s: %s %s has no local name" % [code, town, lm.kind])
		t.check(locals, "%s: every landmark has its local name for the sign" % code)
	# colours: palette keys known, every colour valid; landscape grass in pairs
	var pal_ok := true
	var pal: Dictionary = c.get("palette", {})
	for season in pal:
		if season == "biomes": continue
		for k in pal[season]:
			if not SeasonPalette.SEASONS.has(season) or not SeasonPalette.by_name("summer").has(k) or not Color.html_is_valid(pal[season][k]):
				pal_ok = false; print("  %s: bad palette %s %s" % [code, season, k])
	var grass: Array = pal.get("biomes", {}).values()
	for b in rules.biomes:
		grass.append(rules.biomes[b].get("grass", {}))
	for g in grass:
		for season in g:
			if not SeasonPalette.SEASONS.has(season) or g[season].size() != 2 or not g[season].all(func(h): return Color.html_is_valid(h)):
				pal_ok = false; print("  %s: bad grass %s" % [code, str(g)])
	t.check(pal_ok, "%s: palette and grass colours valid" % code)
	var box: Dictionary = c.map
	var cities_ok := true
	for id in c.cities:
		var city: Dictionary = c.cities[id]
		for k in ["name", "lat", "lon", "pop", "region"]:
			if not city.has(k): cities_ok = false; print("  %s: city %s has no %s" % [code, id, k])
		if city.lat < box.lat0 or city.lat > box.lat1 or city.lon < box.lon0 or city.lon > box.lon1:
			cities_ok = false; print("  %s: city %s outside the map box" % [code, id])
	t.check(cities_ok, "%s: cities complete and on the map" % code)
	# roads: known cities, towns and zones in order within the road, known landscapes, tunnels inside the road
	var roads_ok := true
	var names := {}
	for id in c.cities: names[c.cities[id].name] = true
	for r in c.roads:
		var tag := "%s-%s" % [r.a, r.b]
		if not c.cities.has(r.a) or not c.cities.has(r.b): roads_ok = false; print("  %s: road %s: unknown city" % [code, tag])
		var prev := 0.0
		for tw in r.towns:
			names[tw[0]] = true
			if tw[1] <= prev or tw[1] >= r.km: roads_ok = false; print("  %s: road %s: town %s out of order" % [code, tag, tw[0]])
			prev = tw[1]
		prev = 0.0
		for zn in r.zones:
			if zn[0] <= prev or not rules.biomes.has(zn[1]): roads_ok = false; print("  %s: road %s: bad zone %s" % [code, tag, str(zn)])
			prev = zn[0]
		if prev != r.km: roads_ok = false; print("  %s: road %s: zones do not reach the end" % [code, tag])
		for tn in r.get("tunnels", []):
			if not (tn.from_km > 0.0 and tn.from_km < tn.to_km and tn.to_km < r.km) or not (tn.name is String and tn.fact is String) \
					or not tn.get("under", "") in Scenery.TUNNEL_UNDER or not (int(tn.get("limit", 0)) >= 0 and int(tn.get("limit", 0)) <= 130):
				roads_ok = false; print("  %s: road %s: bad tunnel" % [code, tag])
		if r.has("bridge"):
			var br: Dictionary = r.bridge
			if not (br.from_km >= 0.0 and br.from_km < br.to_km and br.to_km <= r.km) or not br.get("name") is String \
					or not (br.get("color", "") == "" or (br.color is String and Color.html_is_valid(br.color))) \
					or not br.get("kind", "suspension") in Scenery.BRIDGE_KINDS \
					or not br.get("over", "water") in Scenery.BRIDGE_OVER:
				roads_ok = false; print("  %s: road %s: bad bridge" % [code, tag])
	t.check(roads_ok, "%s: roads consistent" % code)
	# every city reachable from every other one
	var seen := {}
	var todo: Array = [c.cities.keys()[0]]
	while not todo.is_empty():
		var cur: String = todo.pop_back()
		if seen.has(cur): continue
		seen[cur] = true
		for r in c.roads:
			if r.a == cur: todo.append(r.b)
			elif r.b == cur: todo.append(r.a)
	t.check(seen.size() == c.cities.size(), "%s: road network connects all cities" % code)
	# landmarks and facts name known places; landmark kinds have a painter size
	var lm_ok := true
	for town in c.landmarks:
		if not names.has(town): lm_ok = false; print("  %s: landmark in unknown town %s" % [code, town])
		for lm in c.landmarks[town]:
			if not rules.landmark_sizes.has(lm.kind) or not (lm.name is String and lm.desc is String):
				lm_ok = false; print("  %s: bad landmark in %s" % [code, town])
	t.check(lm_ok, "%s: landmarks in known towns, known kinds" % code)
	var facts_ok := true
	for town in c.facts:
		if not names.has(town) or not c.facts[town] is String: facts_ok = false; print("  %s: fact for unknown town %s" % [code, town])
	t.check(facts_ok, "%s: facts name known places" % code)

## The country picker's map (data/world.json): every country in the game has its shape there, its name inside it,
## and is one of the planned ones.
func _check_world(t) -> void:
	var w: Dictionary = GameData.load_json(GameData.DIR + "world.json")
	var ok := true
	var codes := []
	for code in GameData.country_codes():
		# a map spanning several countries is checked through its members' shapes
		var ms: Array = GameData.members(code)
		codes.append_array(ms if not ms.is_empty() else [code])
	for code in codes:
		var c: Dictionary = w.countries.get(code, {})
		var inside := false
		for f in c.get("polys", []):
			var pts := PackedVector2Array()
			for i in range(0, f.size(), 2): pts.append(Vector2(f[i], f[i + 1]))
			if Geometry2D.is_point_in_polygon(Vector2(c.label[0], c.label[1]), pts): inside = true
		if not inside or not w.planned.has(code): ok = false; print("  world.json: %s missing or its name outside it" % code)
	t.check(ok, "every country in the game is on the picker's map, named inside its borders")
	# Crimea is Ukraine's on the picker (Simferopol's point in Europe's view), never Russia's
	var simferopol := _world_point(w.views[0], 34.10, 44.95)
	t.check(_in_country(w, "ua", simferopol) and not _in_country(w, "ru", simferopol), "Crimea is Ukraine's on the picker (%s)" % simferopol)
	t.check(_in_country(w, "ru", _world_point(w.views[0], 37.62, 55.75)) and _in_country(w, "ua", _world_point(w.views[0], 30.52, 50.45)),
		"Moscow in Russia, Kyiv in Ukraine")

## A lon/lat point on the picker's screen in one of world.json's views (as tools/make_world.py projects it).
static func _world_point(view: Dictionary, lon: float, lat: float) -> Vector2:
	var ll: Array = view.lonlat
	var r: Array = view.rect
	var k := cos(deg_to_rad((ll[2] + ll[3]) * 0.5))
	var s: float = r[3] / (ll[3] - ll[2])
	return Vector2(r[0] + (lon - ll[0]) * k * s, r[1] + (ll[3] - lat) * s)

static func _in_country(w: Dictionary, code: String, p: Vector2) -> bool:
	for f in w.countries.get(code, {}).get("polys", []):
		var pts := PackedVector2Array()
		for i in range(0, f.size(), 2): pts.append(Vector2(f[i], f[i + 1]))
		if Geometry2D.is_point_in_polygon(p, pts): return true
	return false
