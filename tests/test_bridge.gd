extends RefCounted
## A suspension bridge (roads.json `bridge`: the Dardanelles, the Bosporus): a stretch of road over the water between
## two tall pylons, carried by cables. A fixture of three cities: a bridge mid-road, and one right after a city.
const CODE := "zz_bridge"

class Pen:
	var n := 0
	func draw_line(_a, _b, _c, _w := 1.0) -> void: n += 1
	func draw_circle(_p, _r, _c) -> void: n += 1
	func draw_rect(_r, _c, _f := true, _w := 1.0) -> void: n += 1
	func draw_colored_polygon(_p, _c) -> void: n += 1
	func draw_string(_f, _p, _t, _a = 0, _w = -1, _s = 16, _c = Color.WHITE) -> void: n += 1
	func draw_set_transform(_p, _r := 0.0, _s := Vector2.ONE) -> void: pass

static func fixture() -> Dictionary:
	var c: Dictionary = GameData.localize(GameData.load_json(GameData.DIR + "countries/pl/country.json"))
	c.code = CODE
	c["cities"] = {
		"aa": {"name": "Alfa", "lat": 40.0, "lon": 26.0, "pop": 150, "region": "R1"},
		"bb": {"name": "Beta", "lat": 40.4, "lon": 27.0, "pop": 150, "region": "R2"},
		"cc": {"name": "Gamma", "lat": 40.6, "lon": 27.3, "pop": 150, "region": "R2"},
		"dd": {"name": "Delta", "lat": 40.7, "lon": 27.5, "pop": 150, "region": "R2"},
		"ee": {"name": "Epsilon", "lat": 41.2, "lon": 28.3, "pop": 150, "region": "R2"},
		"ff": {"name": "Zeta", "lat": 41.7, "lon": 29.1, "pop": 150, "region": "R2"},
	}
	c["roads"] = [
		{"a": "aa", "b": "bb", "km": 100, "road": "O5", "towns": [["Westtown", 20], ["Easttown", 70]],
			"zones": [[50, "fields", "R1"], [100, "upland", "R2"]],
			"bridge": {"from_km": 40, "to_km": 45, "name": {"pl": "Most", "en": "Bridge"}}},
		# the bridge begins at the city's edge: it is moved out past the streets
		{"a": "bb", "b": "cc", "km": 80, "road": "D100", "towns": [], "zones": [[80, "fields", "R2"]],
			"bridge": {"from_km": 0.5, "to_km": 2, "name": "Short"}},
		# towns crowd the bridge: too short to draw, it is left out
		{"a": "cc", "b": "dd", "km": 20, "road": "D110", "towns": [["Left", 8], ["Right", 12]], "zones": [[20, "fields", "R2"]],
			"bridge": {"from_km": 9.5, "to_km": 10.5, "name": "Squeezed"}},
		# a cable-stayed bridge, and a long low beam bridge
		{"a": "dd", "b": "ee", "km": 80, "road": "D120", "towns": [], "zones": [[80, "fields", "R2"]],
			"bridge": {"from_km": 30, "to_km": 38, "name": "Stayed", "kind": "stayed"}},
		{"a": "ee", "b": "ff", "km": 80, "road": "D130", "towns": [], "zones": [[80, "fields", "R2"]],
			"bridge": {"from_km": 30, "to_km": 40, "name": "Causeway", "kind": "beam"}},
	]
	c["facts"] = {}
	c["landmarks"] = {}
	return GameData.localize(c)

func run(t) -> void:
	var was := GameData.current
	GameData._countries[CODE] = fixture()
	GameData.current = CODE
	var s := Route.build("aa", "bb")
	t.check(s.bridges.size() == 1 and s.bridges[0].name == "Most", "one bridge on the way, its name in the player's language")
	var br: Dictionary = s.bridges[0]
	t.check(br.kind == "suspension", "a bridge without a kind is a suspension bridge")
	t.check(absf((br.z0 + br.z1) * 0.5 - 42.5 * s.m_per_km) < 1.0 and br.z1 - br.z0 >= Route.BRIDGE_MIN - 0.5,
		"a->b: around km 42.5, at least BRIDGE_MIN long (%.0f..%.0f)" % [br.z0, br.z1])
	t.check(Route.bridge_at(s, (br.z0 + br.z1) * 0.5) == br and Route.bridge_at(s, br.z0 - 5.0).is_empty(), "bridge_at")
	var back := Route.build("bb", "aa")
	var bb: Dictionary = back.bridges[0]
	t.check(absf((bb.z0 + bb.z1) * 0.5 - 57.5 * back.m_per_km) < 1.0, "b->a: mirrored to km 57.5 (%.0f..%.0f)" % [bb.z0, bb.z1])
	for pair in [["aa", "bb"], ["bb", "aa"], ["bb", "cc"], ["cc", "bb"], ["aa", "cc"], ["cc", "aa"]]:
		var p := Route.build(pair[0], pair[1])
		var name: String = "%s->%s" % pair
		t.check(not p.bridges.is_empty() and not p.stations.is_empty(), "%s: bridges on the way, a station still" % name)
		for b in p.bridges:
			var lo: float = b.z0 - 40.0
			var hi: float = b.z1 + 40.0
			var inside := func(z: float) -> bool: return z > lo and z < hi
			t.check(b.z1 - b.z0 >= Route.BRIDGE_MIN - 0.5, "%s: %s at least BRIDGE_MIN long (%.0f)" % [name, b.name, b.z1 - b.z0])
			t.check(not p.stations.any(inside), "%s: no station by %s %s" % [name, b.name, str(p.stations)])
			t.check(not p.boards.any(func(bd): return inside.call(bd.z)), "%s: no board by %s" % [name, b.name])
			t.check(not p.radars.any(inside), "%s: no radar by %s" % [name, b.name])
			t.check(not p.towns.any(func(tn): return tn.z + tn.half > lo and tn.z - tn.half < hi),
				"%s: no town's streets or signs by %s %s" % [name, b.name, str(p.towns.map(func(tn): return [tn.name, tn.z - tn.half, tn.z + tn.half]))])
			# the scenery: two pylons near the ends, water on both sides, nothing growing or standing on the deck
			var sc := Scenery.build(p, 1)
			var all := []
			for idx in sc: all.append_array(sc[idx])
			var towers := all.filter(func(it): return it.type == "bridge_tower" and it.z >= b.z0 and it.z <= b.z1)
			var span: float = b.z1 - b.z0
			t.check(towers.size() == 2 and towers.any(func(it): return it.z < b.z0 + span * 0.3) and towers.any(func(it): return it.z > b.z1 - span * 0.3),
				"%s: a pylon at both ends of %s" % [name, b.name])
			var stray := all.filter(func(it): return inside.call(it.z) and it.type in ["town_sign", "town_end", "board", "radar", "pylon", "station_sign"])
			t.check(stray.is_empty(), "%s: no sign or station by %s %s" % [name, b.name, str(stray.map(func(it): return [it.type, it.z]))])
			t.check(not all.any(func(it): return it.type == "region" and it.z > b.z0 - Scenery.BRIDGE_SIGN_BEFORE - 10.0 and it.z < b.z1),
				"%s: no region board by %s's sign or on it" % [name, b.name])
			var on_deck := all.filter(func(it): return it.z > b.z0 and it.z < b.z1 and not it.type in ["bridge_tower"])
			t.check(on_deck.is_empty(), "%s: nothing else on %s %s" % [name, b.name, str(on_deck.map(func(it): return it.type))])
			var sign := all.filter(func(it): return it.type == "bridge_sign" and it.text == b.name)
			t.check(sign.size() == 1 and sign[0].z < b.z0 and sign[0].z > b.z0 - 100.0 and sign[0].lat > Scenery.SIGN_EDGE,
				"%s: the bridge's sign before %s" % [name, b.name])
			var ground := Scenery.ground(p, int(p.length / Track.SEG_LEN) + 10)
			var gs: PackedFloat32Array = ground[int((b.z0 + b.z1) * 0.5 / Track.SEG_LEN)]
			var water := []
			for g in range(0, gs.size(), 3):
				if int(gs[g + 2]) == Scenery.G_WATER: water.append(signf(gs[g]))
			t.check(water.has(-1.0) and water.has(1.0), "%s: water on both sides of %s" % [name, b.name])
			t.check(Scenery.on_bridge(p, (b.z0 + b.z1) * 0.5) and not Scenery.on_bridge(p, b.z0 - 10.0), "%s: on_bridge" % name)
			# railings: the car hits them, as tunnel walls
			var obs := Scenery.obstacles(sc, p)
			var mid := int((b.z0 + b.z1) * 0.5 / Track.SEG_LEN)
			t.check(obs.get(mid, []).any(func(ob): return ob[1] > 0.0 and ob[1] <= Scenery.BRIDGE_RAIL + 0.01)
				and obs.get(mid, []).any(func(ob): return ob[2] < 0.0), "%s: railings on both sides of %s" % [name, b.name])
			# flat and straight
			var tr := Track.build(p, 1)
			t.check(absf(tr.segment_at((b.z0 + b.z1) * 0.5).curve) < 0.001 and absf(tr.segment_at((b.z0 + b.z1) * 0.5).grade) < 0.001,
				"%s: %s is flat and straight" % [name, b.name])
			t.check(Scenery.sign_texts(p).has(b.name), "%s: %s's name warmed" % [name, b.name])
	var pen := Pen.new()
	Scenery.draw_item(pen, {"type": "bridge_sign", "text": "Most", "w": Scenery.REGION_W, "h": 5.0, "lat": 9.0}, Vector2(400, 400), 12.0,
		SeasonPalette.by_name("summer"), "summer", ThemeDB.fallback_font)
	t.check(pen.n > 10, "the bridge's sign is drawn (%d)" % pen.n)
	# the cable: down to the deck at the ends, up at the pylons, sagging between them
	var mid_z: float = (br.z0 + br.z1) * 0.5
	var t0: float = br.z0 + (br.z1 - br.z0) * Scenery.BRIDGE_SIDE
	t.check(Scenery.cable_h(br, br.z0) < 2.0 and absf(Scenery.cable_h(br, t0) - Scenery.BRIDGE_TOWER_H + 2.0) < 0.1
		and Scenery.cable_h(br, mid_z) < 4.0 and Scenery.cable_h(br, br.z1) < 2.0, "the cable's sag")
	var r: Race = Bot.run_race("xc60", s, 11, 0.9)
	t.check(r.state == "won" and r.fines == 0, "the autopilot drives over the bridge (%s, %.0f s left)" % [r.state, r.time_left])
	for pair in [["cc", "dd"], ["dd", "cc"]]:
		var q := Route.build(pair[0], pair[1])
		var qs := Scenery.build(q, 1)
		var towers := 0
		for idx in qs: towers += qs[idx].filter(func(it): return it.type == "bridge_tower").size()
		t.check(q.bridges.is_empty() and towers == 0, "%s->%s: a bridge squeezed by the towns is left out" % pair)
	_kinds(t)
	# right after a city: the bridge starts past the start's streets
	var short := Route.build("bb", "cc")
	t.check(short.bridges[0].z0 - 40.0 >= short.towns[0].z + short.towns[0].half, "the bridge past the start city's streets")
	GameData._countries.erase(CODE)
	GameData.current = was

## The other kinds: a cable-stayed bridge (pylons, stays, no main cable) and a beam bridge (no pylons, no cables), both
## with the water, the railings and the sign of any bridge.
func _kinds(t) -> void:
	for pair in [["dd", "ee"], ["ee", "dd"], ["ee", "ff"], ["ff", "ee"]]:
		var p := Route.build(pair[0], pair[1])
		var name: String = "%s->%s" % pair
		var kind := "stayed" if "dd" in pair else "beam"
		t.check(p.bridges.size() == 1 and p.bridges[0].kind == kind, "%s: one %s bridge" % [name, kind])
		if p.bridges.is_empty(): continue
		var b: Dictionary = p.bridges[0]
		var span: float = b.z1 - b.z0
		var mid: float = (b.z0 + b.z1) * 0.5
		var sc := Scenery.build(p, 1)
		var all := []
		for idx in sc: all.append_array(sc[idx])
		var towers := all.filter(func(it): return it.type == "bridge_tower")
		var steps := range(0, 41).map(func(k): return b.z0 + span * k / 40.0)
		t.check(steps.all(func(z): return Scenery.cable_h(b, z) < 0.0), "%s: no main cable or hangers on the %s bridge" % [name, kind])
		var sign := all.filter(func(it): return it.type == "bridge_sign")
		t.check(sign.size() == 1 and sign[0].get("kind", "") == kind and sign[0].z < b.z0, "%s: the %s bridge's sign" % [name, kind])
		if sign.size() == 1:
			var pen := Pen.new()
			Scenery.draw_item(pen, sign[0], Vector2(400, 400), 12.0, SeasonPalette.by_name("summer"), "summer", ThemeDB.fallback_font)
			t.check(pen.n > 6, "%s: the %s bridge's sign is drawn (%d)" % [name, kind, pen.n])
		if kind == "stayed":
			var lower := func(it): return it.get("kind", "") == "stayed" and absf(it.h - Scenery.BRIDGE_TOWER_H * Scenery.BRIDGE_STAYED_H) < 0.01
			t.check(towers.size() == 2 and towers.all(lower)
				and towers.any(func(it): return it.z < b.z0 + span * 0.3) and towers.any(func(it): return it.z > b.z1 - span * 0.3),
				"%s: two lower pylons near the ends" % name)
			# stays on both sides of each pylon, the longest from the top, the shorter ones landing nearer
			for tw in towers:
				var tz: float = tw.z
				var inward: float = signf(mid - tz)
				var top_k := Scenery.BRIDGE_STAYS - 1
				var ok := true
				for z in [tz + inward * span * 0.1, tz - inward * span * 0.1]:
					ok = ok and Scenery.stay_pylon(b, z) == tz and Scenery.stay_h(b, tz, top_k, z) > 3.0
				ok = ok and absf(Scenery.stay_h(b, tz, top_k, tz + 0.01) - Scenery.tower_h(b) * 0.98) < 0.1
				ok = ok and Scenery.stay_h(b, tz, 0, tz + inward * span * 0.1) < 0.0
				t.check(ok, "%s: stays fan from the pylon at %.0f to both sides" % [name, tz])
			t.check(is_nan(Scenery.stay_pylon(b, mid)) and is_nan(Scenery.stay_pylon(b, b.z0 + 1.0)),
				"%s: the stays land before mid-span and the bridge's end" % name)
		else:
			t.check(towers.is_empty() and steps.all(func(z): return is_nan(Scenery.stay_pylon(b, z))),
				"%s: no pylons, no stays on the beam bridge" % name)
		var on_deck := all.filter(func(it): return it.z > b.z0 and it.z < b.z1 and not it.type in ["bridge_tower"])
		t.check(on_deck.is_empty(), "%s: nothing else on %s %s" % [name, b.name, str(on_deck.map(func(it): return it.type))])
		var ground := Scenery.ground(p, int(p.length / Track.SEG_LEN) + 10)
		var gs: PackedFloat32Array = ground[int(mid / Track.SEG_LEN)]
		var water := []
		for g in range(0, gs.size(), 3):
			if int(gs[g + 2]) == Scenery.G_WATER: water.append(signf(gs[g]))
		t.check(water.has(-1.0) and water.has(1.0) and Scenery.on_bridge(p, mid), "%s: water on both sides of %s" % [name, b.name])
		var obs := Scenery.obstacles(sc, p)
		var m := int(mid / Track.SEG_LEN)
		t.check(obs.get(m, []).any(func(ob): return ob[1] > 0.0 and ob[1] <= Scenery.BRIDGE_RAIL + 0.01)
			and obs.get(m, []).any(func(ob): return ob[2] < 0.0), "%s: railings on both sides of %s" % [name, b.name])
		t.check(not p.stations.any(func(z): return z > b.z0 - 40.0 and z < b.z1 + 40.0), "%s: no station by %s" % [name, b.name])
