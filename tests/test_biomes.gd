extends RefCounted
## The steppe (Ukraine's south, the Volga, Anatolia) and the taiga (Siberia): each landscape has its own things by the
## road and none of the other's. A Polish trip with its zones swapped for one landscape.
class Pen:
	var n := 0
	func draw_line(_a, _b, _c, _w := 1.0) -> void: n += 1
	func draw_circle(_p, _r, _c) -> void: n += 1
	func draw_rect(_r, _c, _f := true, _w := 1.0) -> void: n += 1
	func draw_colored_polygon(_p, _c) -> void: n += 1
	func draw_string(_f, _p, _t, _a = 0, _w = -1, _s = 16, _c = Color.WHITE) -> void: n += 1
	func draw_set_transform(_p, _r := 0.0, _s := Vector2.ONE) -> void: pass

## Item counts by type along a trip all in one landscape.
static func counts(biome: String) -> Dictionary:
	var st := Route.build("krakow", "warszawa")
	st["zones"] = [{"z0": 0.0, "z1": st.length + 1000.0, "biome": biome, "region": "Test"}]
	var items := Scenery.build(st, 1)
	var out := {"_stage": st, "_items": items}
	for idx in items:
		for it in items[idx]: out[it.type] = out.get(it.type, 0) + 1
	return out

func run(t) -> void:
	var was := GameData.current
	GameData.current = "pl"
	for b in ["steppe", "taiga"]:
		t.check(Biome.all().has(b), "the %s biome exists" % b)
		for season in SeasonPalette.SEASONS:
			var g := Weather.grass({"summer": "sun", "autumn": "autumn", "winter": "snow"}[season], b, Weather.palette("sun"))
			t.check(g.size() == 2, "%s grass in %s" % [b, season])
	t.check(Biome.get_data("steppe").wood < 0.2 and Biome.get_data("taiga").wood >= 0.9, "a bare steppe, a wooded taiga on the horizon")
	var steppe := counts("steppe")
	var taiga := counts("taiga")
	# the steppe: open grass, kurgans and haystacks, poplar shelter belts, a lone tree now and then
	t.check(steppe.get("kurgan", 0) > 0 and steppe.get("haystack", 0) > 0 and steppe.get("poplar", 0) > 0, "kurgans, haystacks and poplars on the steppe (%s)" % _str(steppe))
	var steppe_trees: int = steppe.get("tree", 0) + steppe.get("poplar", 0)
	t.check(steppe_trees < taiga.get("spruce", 0) / 4, "few trees on the steppe (%d)" % steppe_trees)
	t.check(steppe.get("spruce", 0) == 0 and steppe.get("larch", 0) == 0 and steppe.get("pine", 0) == 0 and steppe.get("birch", 0) == 0,
		"no forest on the steppe")
	# the taiga: dense spruce, pine and larch, birches at the edges, log houses, no fields
	t.check(taiga.get("spruce", 0) > 0 and taiga.get("larch", 0) > 0 and taiga.get("pine", 0) > 0 and taiga.get("birch", 0) > 0,
		"spruce, pine, larch and birch in the taiga (%s)" % _str(taiga))
	t.check(taiga.get("kurgan", 0) == 0 and taiga.get("haystack", 0) == 0 and taiga.get("haybale", 0) == 0 and taiga.get("farm", 0) == 0
		and taiga.get("turbine", 0) == 0 and taiga.get("cow", 0) == 0, "no fields in the taiga")
	t.check(taiga.get("woodhouse", 0) > 0 and taiga.get("woodhouse", 0) > taiga.get("house", 0), "log houses in the taiga's settlements (%s)" % _str(taiga))
	var edge := []
	for idx in taiga._items:
		for it in taiga._items[idx]:
			if it.type in ["birch", "spruce", "pine", "larch"] and Route.town_at(taiga._stage, it.z).is_empty(): edge.append(it)
	var near_birch := edge.filter(func(it): return it.type == "birch" and absf(it.lat) < 12.0).size()
	var far_birch := edge.filter(func(it): return it.type == "birch" and absf(it.lat) >= 12.0).size()
	t.check(near_birch > far_birch, "birches at the forest's edge (%d near, %d deeper)" % [near_birch, far_birch])
	# the ground: wind-swept streaks of feather grass on the steppe, coloured by season; none in the taiga
	var gs: Array = Scenery.ground(steppe._stage, 400)
	var streaks := gs.filter(func(s): return range(0, s.size(), 3).any(func(g): return int(s[g + 2]) == Scenery.G_FEATHER)).size()
	t.check(streaks > 40, "feather grass streaks on the steppe (%d)" % streaks)
	t.check(not Scenery.ground(taiga._stage, 400).any(func(s): return range(0, s.size(), 3).any(func(g): return int(s[g + 2]) == Scenery.G_FEATHER)),
		"no feather grass in the taiga")
	t.check(Weather.palette("sun").feather != Weather.palette("autumn").feather and Weather.palette("snow").has("feather"), "feather grass by season")
	for kind in ["kurgan", "haystack", "larch"]:
		for season in SeasonPalette.SEASONS:
			var pen := Pen.new()
			Scenery.draw_item(pen, {"type": kind, "v": 0.3, "c": 1, "w": 6.0, "h": 6.0, "lat": 10.0}, Vector2(400, 400), 6.0, Weather.palette("sun"), season, null)
			t.check(pen.n > 0, "%s is drawn in %s" % [kind, season])
	# solid where they stand: kurgans and haystacks by their width, larches by their trunk
	t.check(not Scenery._solid({"type": "kurgan", "w": 30.0}).is_empty() and not Scenery._solid({"type": "haystack", "w": 4.0}).is_empty()
		and not Scenery._solid({"type": "larch", "w": 3.0}).is_empty(), "the new things are solid")
	GameData.current = was

static func _str(c: Dictionary) -> String:
	var d := c.duplicate()
	d.erase("_stage")
	d.erase("_items")
	return str(d)
