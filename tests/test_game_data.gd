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
	GameData.current = "pl"

## Every trip between neighbouring cities builds a playable stage (stations, limits, a track, scenery).
func _check_trips(t, code: String) -> void:
	GameData.current = code
	var ok := true
	var trips := 0
	for a in Geo.city_ids():
		for b in Route.neighbours(a):
			var s := Route.build(a, b)
			trips += 1
			if s.stations.is_empty() or s.duration <= 0.0 or s.towns[0].id != a or s.towns[-1].id != b:
				ok = false; print("  %s: trip %s-%s broken" % [code, a, b])
			for zz in [10.0, s.length * 0.5, s.length - 10.0]:
				if Route.speed_limit_at(s, zz) <= 0: ok = false
			for tn in s.tunnels:
				for tw in s.towns:
					if tw.z + tw.half > tn.z0 and tw.z - tw.half < tn.z1: ok = false; print("  %s: %s-%s tunnel in a town" % [code, a, b])
	var r := Race.new("xc60", Route.build(Geo.city_ids()[0], Route.neighbours(Geo.city_ids()[0])[0]), 1)
	for i in 120: r.step(1.0 / 60.0, {"accel": true, "brake": false, "steer": 0.0})
	t.check(ok and trips > 0 and r.z > 10.0, "%s: all %d trips build and drive" % [code, trips])

func _check_country(t, code: String, rules: Dictionary) -> void:
	var c := GameData.country(code)
	for key in ["code", "name", "drive", "region_label", "limits", "signs", "map", "outline", "cities", "roads", "facts", "landmarks"]:
		t.check(c.has(key), "%s: country has %s" % [code, key])
	t.check(c.code == code, "%s: code matches its folder" % code)
	for k in ["express", "road", "city", "town_on_express", "town"]:
		t.check(c.limits.get(k, 0.0) > 0.0, "%s: speed limit %s" % [code, k])
	for k in ["town", "board", "board_motorway"]:
		t.check(c.signs.get(k, "") is String and Color.html_is_valid(c.signs.get(k, "")), "%s: sign colour %s" % [code, k])
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
			if not (tn.from_km > 0.0 and tn.from_km < tn.to_km and tn.to_km < r.km) or not (tn.name is String and tn.fact is String):
				roads_ok = false; print("  %s: road %s: bad tunnel" % [code, tag])
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
