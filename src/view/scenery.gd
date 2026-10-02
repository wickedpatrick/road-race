class_name Scenery
extends RefCounted
## Roadside world. build() places objects per 5 m segment following the route's regions and towns, ground() paints
## flat strips beside the road (fields, lakes, canals), draw_item() paints one object at a ground point.
const BUILDING_COLORS := [Color("d9b26b"), Color("e7dcc0"), Color("d98a6c"), Color("a85a45"), Color("8fa3b5"), Color("c9a24a")]
const WALL_DARK := Color(0, 0, 0, 0.18)
const SIGN_GREEN := Color("0f7a43")
const SIGN_BLUE := Color("1d4f9e")
const SIGN_BROWN := Color("7b4a26")
const SIGN_RED := Color("d0202a")
const SIGN_YELLOW := Color("f2c21b")

## Road number plate (E-15): red with white for A, S and national roads (DK shows just the number),
## yellow with black for regional roads (DW). Returns [label, plate colour, text colour].
static func plate(road: String) -> Array:
	if road.begins_with("DW"):
		return [road.trim_prefix("DW"), SIGN_YELLOW, Color.BLACK]
	return [road.trim_prefix("DK"), SIGN_RED, Color.WHITE]
const SIGN_EDGE := 5.0 ## signs start just past the rumble strip on the right shoulder
const TOWN_SIGN_W := 6.4
const BOARD_W := 10.0
const REGION_W := 8.6
## ground strip colour ids, looked up in the season palette
const GROUND_KEYS := ["crop_a", "crop_b", "crop_c", "water", "sand", "pave", "dark"]
enum {G_CROP_A, G_CROP_B, G_CROP_C, G_WATER, G_SAND, G_PAVE, G_DARK}

## Deterministic 0..1 noise for (a, b).
static func _h(a: int, b: int) -> float:
	return fposmod(sin(a * 12.9898 + b * 78.233) * 43758.5453, 1.0)

static func _lake(z: float, side: int) -> bool:
	return _h(int(z / 180.0), side * 31 + 7) < 0.35

static func build(stage: Dictionary, seed_value: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value + 77
	var items := {}
	var length: float = stage.length
	var st := {"lamp": 0.0, "bridge": 700.0, "billboard": 500.0, "castle": 300.0, "lighthouse": 200.0, "churches": {}}
	var z := 20.0
	while z < length + 500.0:
		var t := Route.town_at(stage, z)
		var biome: String = Route.zone_at(stage, z).biome
		if not t.is_empty():
			z += _settlement(items, t, biome, z, rng, st)
			continue
		z += _nature(items, biome, z, rng, st)
		if Route.lanes_at(stage, z) == 3 and z < length - 200.0:
			if z >= st.bridge:
				_add(items, "bridge", z, 0.0, 0.0, 8.0, rng)
				st.bridge = z + rng.randf_range(900.0, 1500.0)
			elif z >= st.billboard and biome != "forest" and biome != "mountains":
				_add(items, "billboard", z, 14.0, 9.0, 8.0, rng)
				st.billboard = z + rng.randf_range(1100.0, 1800.0)
	_signs(items, stage, rng)
	for s in stage.stations:
		_add(items, "station", s, 15.0, 14.0, 6.0, rng)
	_add(items, "finish", length, 0.0, 0.0, 7.0, rng)
	return items

static func _add(items: Dictionary, type: String, z: float, lat: float, w: float, h: float, rng: RandomNumberGenerator) -> Dictionary:
	var idx := int(z / Track.SEG_LEN)
	if not items.has(idx):
		items[idx] = []
	var it := {"type": type, "z": z, "lat": lat, "w": w, "h": h, "v": rng.randf(), "c": rng.randi() % BUILDING_COLORS.size()}
	items[idx].append(it)
	return it

static func _side(rng: RandomNumberGenerator) -> int:
	return -1 if rng.randf() < 0.5 else 1

## Streets of a town or a big city. Returns the step to the next row.
static func _settlement(items: Dictionary, t: Dictionary, biome: String, z: float, rng: RandomNumberGenerator, st: Dictionary) -> float:
	if z >= st.lamp:
		_add(items, "lamp", z, -7.4, 0.4, 7.0, rng)
		_add(items, "lamp", z, 7.4, 0.4, 7.0, rng)
		st.lamp = z + (45.0 if t.big else 40.0)
	if not st.churches.has(t.name) and z > t.z - 30.0:
		st.churches[t.name] = true
		var ct := "cerkiew" if biome == "podlasie" and rng.randf() < 0.5 else "church"
		_add(items, ct, z, _side(rng) * rng.randf_range(20.0, 26.0), 10.0, 22.0 if t.big else 18.0, rng)
	if t.big:
		for side in [-1, 1]:
			var w := rng.randf_range(9.0, 16.0)
			_add(items, "building", z + rng.randf_range(-4, 4), side * (7.6 + w * 0.5 + rng.randf_range(0.0, 1.5)), w, rng.randf_range(12.0, 26.0), rng)
		if rng.randf() < 0.4:
			_add(items, "tree", z, _side(rng) * 8.0, 3.0, 5.0, rng)
		return rng.randf_range(16.0, 26.0)
	var wooden := biome == "podlasie" or biome == "mountains"
	for side in [-1, 1]:
		if rng.randf() < 0.8:
			var w := rng.randf_range(7.0, 10.0)
			var type := "woodhouse" if wooden and rng.randf() < 0.7 else "house"
			_add(items, type, z + rng.randf_range(-3, 3), side * (8.2 + w * 0.5 + rng.randf_range(0.0, 3.0)), w, rng.randf_range(6.0, 8.0), rng)
		elif rng.randf() < 0.6:
			_add(items, "tree", z, side * rng.randf_range(8.0, 11.0), 3.0, 5.5, rng)
	return rng.randf_range(13.0, 20.0)

## Open-road landscape for one step of the given biome. Returns the step length.
static func _nature(items: Dictionary, biome: String, z: float, rng: RandomNumberGenerator, st: Dictionary) -> float:
	match biome:
		"orchard":
			for side in [-1, 1]:
				_add(items, "apple", z + rng.randf_range(-1, 1), side * 9.0, 3.0, 3.6, rng)
				_add(items, "apple", z + rng.randf_range(-1, 1), side * 14.0, 3.0, 3.6, rng)
				if rng.randf() < 0.4:
					_add(items, "apple", z, side * 19.0, 3.0, 3.6, rng)
			if rng.randf() < 0.03:
				_add(items, "farm", z, _side(rng) * rng.randf_range(26.0, 34.0), 9.0, 7.0, rng)
			return rng.randf_range(9.0, 11.0)
		"forest", "mountains":
			var spruce := 0.75 if biome == "mountains" else 0.3
			for side in [-1, 1]:
				_add(items, _forest_tree(rng, spruce), z + rng.randf_range(-3, 3), side * rng.randf_range(7.6, 12.0), 3.5, rng.randf_range(8.0, 14.0), rng)
				if rng.randf() < 0.7:
					_add(items, _forest_tree(rng, spruce), z + rng.randf_range(-4, 4), side * rng.randf_range(13.0, 30.0), 4.0, rng.randf_range(10.0, 17.0), rng)
			if biome == "mountains" and rng.randf() < 0.04:
				_add(items, "woodhouse", z, _side(rng) * rng.randf_range(16.0, 24.0), 8.0, 7.0, rng)
			elif rng.randf() < 0.01:
				_add(items, "shrine", z, _side(rng) * 7.8, 1.2, 3.0, rng)
			return rng.randf_range(7.0, 12.0)
		"lakes":
			for side in [-1, 1]:
				if _lake(z, side):
					if rng.randf() < 0.5:
						_add(items, "reeds", z, side * rng.randf_range(12.2, 13.5), 2.0, 2.0, rng)
					if rng.randf() < 0.35:
						_add(items, "birch" if rng.randf() < 0.6 else "pine", z, side * rng.randf_range(7.6, 10.5), 3.0, rng.randf_range(8.0, 12.0), rng)
				else:
					_add(items, _forest_tree(rng, 0.25, 0.3), z + rng.randf_range(-3, 3), side * rng.randf_range(7.6, 13.0), 3.5, rng.randf_range(8.0, 13.0), rng)
					if rng.randf() < 0.6:
						_add(items, _forest_tree(rng, 0.25, 0.3), z, side * rng.randf_range(14.0, 30.0), 4.0, rng.randf_range(10.0, 15.0), rng)
			return rng.randf_range(9.0, 14.0)
		"jura":
			for side in [-1, 1]:
				if rng.randf() < 0.22:
					_add(items, "rock", z, side * rng.randf_range(10.0, 35.0), rng.randf_range(3.0, 6.0), rng.randf_range(6.0, 14.0), rng)
				if rng.randf() < 0.45:
					_add(items, "pine", z + rng.randf_range(-4, 4), side * rng.randf_range(8.0, 26.0), 3.5, rng.randf_range(9.0, 14.0), rng)
			if z >= st.castle:
				_add(items, "castle", z, _side(rng) * rng.randf_range(45.0, 70.0), 22.0, 18.0, rng)
				st.castle = z + rng.randf_range(1200.0, 2000.0)
			return rng.randf_range(12.0, 20.0)
		"industrial":
			var r := rng.randf()
			var side := _side(rng)
			if r < 0.12: _add(items, "chimney", z, side * rng.randf_range(30.0, 90.0), 4.0, rng.randf_range(35.0, 60.0), rng)
			elif r < 0.2: _add(items, "headframe", z, side * rng.randf_range(25.0, 60.0), 10.0, 30.0, rng)
			elif r < 0.25: _add(items, "heap", z, side * rng.randf_range(45.0, 100.0), 40.0, 18.0, rng)
			elif r < 0.28: _add(items, "cooling", z, side * rng.randf_range(60.0, 120.0), 18.0, 35.0, rng)
			elif r < 0.42: _add(items, "block", z, side * rng.randf_range(16.0, 30.0), rng.randf_range(14.0, 24.0), rng.randf_range(15.0, 30.0), rng)
			if rng.randf() < 0.35:
				_add(items, "tree", z, -side * rng.randf_range(8.0, 14.0), 3.0, 5.0, rng)
			return rng.randf_range(16.0, 26.0)
		"coast":
			for side in [-1, 1]:
				if rng.randf() < 0.5:
					_add(items, "pine", z + rng.randf_range(-3, 3), side * rng.randf_range(7.8, 18.0), 3.5, rng.randf_range(7.0, 11.0), rng)
				if rng.randf() < 0.15:
					_add(items, "dune", z, side * rng.randf_range(11.0, 22.0), rng.randf_range(8.0, 14.0), 3.0, rng)
			if z >= st.lighthouse:
				_add(items, "lighthouse", z, -rng.randf_range(35.0, 55.0), 3.0, 24.0, rng)
				st.lighthouse = z + rng.randf_range(1800.0, 2600.0)
			return rng.randf_range(10.0, 16.0)
		"zulawy":
			for side in [-1, 1]:
				if rng.randf() < 0.5:
					_add(items, "willow", z, side * 18.6, 4.0, 6.0, rng)
			var r := rng.randf()
			if r < 0.04: _add(items, "windmill", z, _side(rng) * rng.randf_range(26.0, 60.0), 6.0, 14.0, rng)
			elif r < 0.08: _add(items, "farm", z, _side(rng) * rng.randf_range(24.0, 40.0), 9.0, 7.0, rng)
			elif r < 0.11: _add(items, "turbine", z, _side(rng) * rng.randf_range(70.0, 150.0), 2.0, 70.0, rng)
			return rng.randf_range(14.0, 22.0)
		"podlasie":
			var village := _h(int(z / 260.0), 5) < 0.35
			if village:
				for side in [-1, 1]:
					if rng.randf() < 0.6:
						var w := rng.randf_range(7.0, 9.0)
						_add(items, "woodhouse", z, side * (10.0 + w * 0.5 + rng.randf_range(0.0, 3.0)), w, 6.5, rng)
				var r := rng.randf()
				if r < 0.1: _add(items, "stork", z, _side(rng) * rng.randf_range(9.0, 16.0), 1.6, 7.0, rng)
				elif r < 0.14: _add(items, "cerkiew", z, _side(rng) * rng.randf_range(20.0, 26.0), 10.0, 16.0, rng)
				return rng.randf_range(16.0, 24.0)
			for side in [-1, 1]:
				_add(items, _forest_tree(rng, 0.35, 0.3), z + rng.randf_range(-3, 3), side * rng.randf_range(7.6, 14.0), 3.5, rng.randf_range(8.0, 14.0), rng)
				if rng.randf() < 0.5:
					_add(items, _forest_tree(rng, 0.35, 0.3), z, side * rng.randf_range(15.0, 30.0), 4.0, rng.randf_range(10.0, 15.0), rng)
			return rng.randf_range(9.0, 14.0)
		"upland", "foothills":
			if _h(int(z / 200.0), 3) < 0.4:
				for side in [-1, 1]:
					if rng.randf() < 0.8:
						_add(items, _forest_tree(rng, 0.5, 0.1), z + rng.randf_range(-3, 3), side * rng.randf_range(8.0, 26.0), 3.5, rng.randf_range(9.0, 14.0), rng)
				return rng.randf_range(8.0, 12.0)
			return _fields(items, z, rng, 0.6)
		_:
			return _fields(items, z, rng, 1.0)

## Spruce share `spruce`, birch share `birch`, rest split between pine and broadleaf.
static func _forest_tree(rng: RandomNumberGenerator, spruce: float, birch := 0.1) -> String:
	var r := rng.randf()
	if r < spruce: return "spruce"
	if r < spruce + birch: return "birch"
	return "pine" if r < spruce + birch + (1.0 - spruce - birch) * 0.65 else "tree"

## Open farmland: tree-lined stretches, farms, hay bales, wind turbines, a stork now and then.
static func _fields(items: Dictionary, z: float, rng: RandomNumberGenerator, busy: float) -> float:
	if _h(int(z / 300.0), 1) < 0.3:
		var type := "poplar" if _h(int(z / 300.0), 2) < 0.5 else "tree"
		for side in [-1, 1]:
			_add(items, type, z, side * 7.8, 3.0, 9.0 if type == "poplar" else 6.0, rng)
		return 12.0
	var r := rng.randf() / busy
	var side := _side(rng)
	if r < 0.07: _add(items, "farm", z, side * rng.randf_range(20.0, 36.0), 9.0, 7.0, rng)
	elif r < 0.17:
		var lat := side * rng.randf_range(14.0, 40.0)
		_add(items, "haybale", z, lat, 1.5, 1.5, rng)
		_add(items, "haybale", z + 3.0, lat + side * 2.5, 1.5, 1.5, rng)
	elif r < 0.22: _add(items, "turbine", z, side * rng.randf_range(60.0, 150.0), 2.0, 70.0, rng)
	elif r < 0.245: _add(items, "stork", z, side * rng.randf_range(12.0, 20.0), 1.6, 7.0, rng)
	elif r < 0.265: _add(items, "shrine", z, side * 7.8, 1.2, 3.0, rng)
	elif r < 0.42: _add(items, "tree", z, side * rng.randf_range(12.0, 60.0), 3.0, 6.0, rng)
	return rng.randf_range(18.0, 30.0)

## Road signs: town name boards (E-17a / E-18a), distance boards (Route.boards), brown region boards.
static func _signs(items: Dictionary, stage: Dictionary, rng: RandomNumberGenerator) -> void:
	for t in stage.towns:
		if not t.get("start", false):
			_add(items, "town_sign", t.z - t.half, SIGN_EDGE + TOWN_SIGN_W * 0.5, TOWN_SIGN_W, 5.5, rng).text = t.name
		if not t.get("finish", false):
			_add(items, "town_end", t.z + t.half, SIGN_EDGE + TOWN_SIGN_W * 0.5, TOWN_SIGN_W, 5.5, rng).text = t.name
	# speed limit signs (B-33): 50 entering a town, the open-road limit leaving it and where the road type changes
	for t in stage.towns:
		if not t.get("start", false):
			_limit_sign(items, t.z - t.half + 15.0, 50, rng)
		if not t.get("finish", false):
			_limit_sign(items, t.z + t.half + 25.0, Route.speed_limit_at(stage, t.z + t.half + 30.0), rng)
	for i in range(1, stage.roads.size()):
		var zr: float = stage.roads[i].z0 + 20.0
		if stage.roads[i].lanes != stage.roads[i - 1].lanes and Route.town_at(stage, zr).is_empty():
			_limit_sign(items, zr, Route.speed_limit_at(stage, zr), rng)
	for bd in stage.boards:
		var it := _add(items, "board", bd.z, SIGN_EDGE + BOARD_W * 0.5, BOARD_W, 6.0, rng)
		it.lines = bd.lines
		it.road = bd.road
		it.blue = bd.blue
	var prev := ""
	var last_region := -1000.0
	for zn in stage.zones:
		if zn.region == prev or zn.z0 > stage.length - 300.0:
			continue
		prev = zn.region
		var z: float = zn.z0 + 40.0
		var t := Route.town_at(stage, z)
		while not t.is_empty():
			z = t.z + t.half + 140.0
			t = Route.town_at(stage, z)
		if z > zn.z1 - 150.0 or z - last_region < 300.0:
			continue # the region is crossed inside a town, or right after another region board
		last_region = z
		_add(items, "region", z, SIGN_EDGE + REGION_W * 0.5, REGION_W, 5.0, rng).text = zn.region

static func _limit_sign(items: Dictionary, z: float, kmh: int, rng: RandomNumberGenerator) -> void:
	_add(items, "limit", z, SIGN_EDGE + 1.4, 2.4, 4.4, rng).limit = kmh

## Speed limit sign B-33: white disc, red ring, black number.
static func _limit(cv, it: Dictionary, b: Vector2, pm: float, font: Font) -> void:
	var r := 1.2 * pm
	var top := 3.0 * pm
	_posts(cv, b, pm, top, [0.0])
	var c := b + Vector2(0, -top - r)
	cv.draw_circle(c, r, SIGN_RED)
	cv.draw_circle(c, r * 0.78, Color.WHITE)
	_fit_text(cv, font, Rect2(c - Vector2(r * 0.7, r * 0.5), Vector2(r * 1.4, r)), str(it.limit), Color.BLACK, 0.9 * pm)

## Flat strips beside the road for every track segment: [lat0, lat1, colour id, ...] (negative lat = left).
static func ground(stage: Dictionary, nseg: int) -> Array:
	var out := []
	out.resize(nseg)
	for i in nseg:
		var z := i * Track.SEG_LEN
		var s := PackedFloat32Array()
		if not Route.town_at(stage, z).is_empty():
			s.append_array([-7.4, -4.8, G_PAVE, 4.8, 7.4, G_PAVE])
			out[i] = s
			continue
		var biome: String = Route.zone_at(stage, z).biome
		for side in [-1, 1]:
			match biome:
				"fields", "upland", "foothills", "jura", "podlasie":
					var busy := 1.0 if biome == "fields" else 0.6
					_patchwork(s, z, side, 9.0, busy)
				"zulawy":
					s.append_array([side * 17.0, side * 15.0, G_WATER])
					_patchwork(s, z, side, 21.0, 1.0)
				"lakes":
					if _lake(z, side):
						s.append_array([side * 12.0, side * 220.0, G_WATER])
				"coast":
					if _h(int(z / 120.0), side * 3) < 0.5:
						s.append_array([side * 7.6, side * 30.0, G_SAND])
				"industrial":
					if _h(int(z / 90.0), side * 5) < 0.45:
						s.append_array([side * 12.0, side * 80.0, G_DARK])
		out[i] = s
	return out

## Field strips laid across the road direction, like a Polish farm checkerboard.
static func _patchwork(s: PackedFloat32Array, z: float, side: int, start: float, busy: float) -> void:
	var block := int(z / 35.0)
	var bands := [start, start + 22.0, start + 60.0, start + 150.0]
	for b in 3:
		var r := _h(block * 3 + b, side * 11 + 3) / busy
		if r < 0.3: s.append_array([side * bands[b], side * bands[b + 1], G_CROP_A])
		elif r < 0.55: s.append_array([side * bands[b], side * bands[b + 1], G_CROP_B])
		elif r < 0.75: s.append_array([side * bands[b], side * bands[b + 1], G_CROP_C])

## `b` is the ground point at the item's base, `pm` is pixels per metre at that depth.
static func draw_item(cv, it: Dictionary, b: Vector2, pm: float, pal: Dictionary, season: String, font: Font) -> void:
	var h: float = it.h * pm
	if h < 1.5:
		return
	match it.type:
		"building": _building(cv, it, b, pm)
		"block": _block(cv, it, b, pm)
		"lamp":
			cv.draw_line(b, b + Vector2(0, -h), Color("3b3f45"), maxf(1.0, 0.25 * pm))
			cv.draw_rect(Rect2(b + Vector2(-0.4 * pm if it.lat > 0 else -0.1 * pm, -h), Vector2(0.9 * pm, 0.35 * pm)), Color("3b3f45"))
		"tree": _tree(cv, it, b, pm, pal, season)
		"spruce": _spruce(cv, it, b, pm, pal, season)
		"pine": _pine(cv, b, h, pm, season)
		"birch": _birch(cv, b, h, pm, season)
		"poplar": _poplar(cv, b, h, pm, pal, season)
		"willow": _willow(cv, b, h, pm, season)
		"apple": _apple(cv, it, b, h, pm, pal, season)
		"billboard":
			cv.draw_line(b + Vector2(-3 * pm, 0), b + Vector2(-3 * pm, -h), Color("55595f"), maxf(1.0, 0.3 * pm))
			cv.draw_line(b + Vector2(3 * pm, 0), b + Vector2(3 * pm, -h), Color("55595f"), maxf(1.0, 0.3 * pm))
			var col: Color = BUILDING_COLORS[it.c]
			cv.draw_rect(Rect2(b + Vector2(-5 * pm, -h - 3 * pm), Vector2(10 * pm, 4.5 * pm)), col)
			cv.draw_rect(Rect2(b + Vector2(-4.2 * pm, -h - 2.2 * pm), Vector2(8.4 * pm, 1.2 * pm)), Color("ffffff", 0.8))
		"house": _house(cv, it, b, pm)
		"farm":
			_house(cv, it, b, pm)
			var w: float = it.w * pm
			cv.draw_rect(Rect2(b + Vector2(w * 0.65, -h * 0.7), Vector2(w * 0.8, h * 0.7)), Color("8a3a2a"))
			cv.draw_colored_polygon(PackedVector2Array([b + Vector2(w * 0.6, -h * 0.7), b + Vector2(w * 1.5, -h * 0.7), b + Vector2(w * 1.05, -h * 1.05)]), Color("5a4a3e"))
		"woodhouse": _woodhouse(cv, it, b, pm)
		"church": _church(cv, it, b, pm)
		"cerkiew": _cerkiew(cv, it, b, pm)
		"shrine": _shrine(cv, b, h, pm)
		"haybale":
			if season != "winter" and season != "spring":
				cv.draw_circle(b + Vector2(0, -h * 0.5), h * 0.5, Color("d9b65c"))
				cv.draw_circle(b + Vector2(0, -h * 0.5), h * 0.3, Color("c49b45"))
		"turbine": _turbine(cv, it, b, h, pm)
		"windmill": _windmill(cv, it, b, h, pm)
		"chimney": _chimney(cv, b, h)
		"headframe": _headframe(cv, b, h)
		"heap":
			var w: float = it.w * pm
			cv.draw_colored_polygon(PackedVector2Array([b + Vector2(-w * 0.5, 0), b + Vector2(-w * 0.12, -h), b + Vector2(w * 0.2, -h * 0.92), b + Vector2(w * 0.5, 0)]), Color("3e3a36") if season != "winter" else Color("c9ced3"))
		"cooling": _cooling(cv, it, b, h, pm)
		"rock": _rock(cv, it, b, h, pm)
		"castle": _castle(cv, it, b, h, pm)
		"reeds":
			var rc := Color("c8bf98") if season == "winter" else (Color("b59a52") if season == "autumn" else Color("7d8f45"))
			for k in 5:
				var x := (k - 2) * 0.35 * pm
				cv.draw_line(b + Vector2(x, 0), b + Vector2(x + (k - 2) * 0.15 * pm, -h * (0.7 + 0.08 * k)), rc, maxf(1.0, 0.1 * pm))
		"dune":
			var w: float = it.w * pm
			cv.draw_colored_polygon(PackedVector2Array([b + Vector2(-w * 0.5, 0), b + Vector2(-w * 0.15, -h), b + Vector2(w * 0.2, -h * 0.9), b + Vector2(w * 0.5, 0)]), Color("e3d3a3") if season != "winter" else Color("eef1f3"))
			for k in 3:
				cv.draw_line(b + Vector2((k - 1) * w * 0.2, -h * 0.85), b + Vector2((k - 1) * w * 0.2 + 0.3 * pm, -h * 1.3), Color("8a9a50"), maxf(1.0, 0.1 * pm))
		"lighthouse": _lighthouse(cv, b, h, pm)
		"stork": _stork(cv, b, h, pm, season)
		"town_sign", "town_end": _town_sign(cv, it, b, pm, font, it.type == "town_end")
		"board": _board(cv, it, b, pm, font)
		"limit": _limit(cv, it, b, pm, font)
		"region": _region(cv, it, b, pm, font)
		"station": _station(cv, b, pm, font)
		"finish": pass # drawn across the road by WorldView
		"bridge": pass # drawn across the road by WorldView

## Text centred in a rectangle, shrunk to fit; a pale bar stands in for text too small to read.
## Text sizes used on signs. A sign's text grows as it approaches; snapping to these few sizes means each glyph is
## rasterised (and each name shaped) once per size, ahead of time in warm_text(), instead of on every frame.
const TEXT_SIZES := [6, 7, 8, 10, 12, 14, 16, 19, 22, 26, 30, 36, 42, 50, 60]

static func _snap(size: float) -> int:
	var out := 0
	for s in TEXT_SIZES:
		if s <= size: out = s
	return out

## Text centred in a rectangle, shrunk to fit; a pale bar stands in for text too small to read.
static func _fit_text(cv, font: Font, r: Rect2, text: String, col: Color, size: float, align := HORIZONTAL_ALIGNMENT_CENTER) -> void:
	var fs := _snap(size)
	if fs > 0:
		var tw := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		if tw > r.size.x:
			fs = _snap(fs * r.size.x / tw)
	if fs == 0:
		var bw: float = r.size.x * (0.8 if align == HORIZONTAL_ALIGNMENT_CENTER else 0.6)
		var bx: float = r.position.x + (r.size.x - bw) * 0.5 if align == HORIZONTAL_ALIGNMENT_CENTER else r.position.x
		cv.draw_rect(Rect2(bx, r.position.y + r.size.y * 0.4, bw, maxf(1.0, r.size.y * 0.2)), Color(col, 0.6))
		return
	cv.draw_string(font, Vector2(r.position.x, r.position.y + r.size.y * 0.5 + fs * 0.36), text, align, r.size.x, fs, col)

## Every text the signs of this stage can show, for warming the font cache.
static func sign_texts(stage: Dictionary) -> Array:
	var out := ["KRAINA", "PALIWO", "0123456789", "50", "90", "140"]
	for t in stage.towns: out.append(t.name)
	for zn in stage.zones:
		if not out.has(zn.region): out.append(zn.region)
	for r in stage.roads: out.append(plate(r.road)[0])
	return out

## Draws all sign texts at every size far off-screen once, so glyph rasterisation happens before the race
## instead of as a stutter when a sign comes close.
static func warm_text(cv: CanvasItem, font: Font, stage: Dictionary) -> void:
	for text in sign_texts(stage):
		for fs in TEXT_SIZES:
			font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
			cv.draw_string(font, Vector2(-5000, -5000), text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)

static func _posts(cv, b: Vector2, pm: float, top: float, xs: Array) -> void:
	for x in xs:
		cv.draw_line(b + Vector2(x * pm, 0), b + Vector2(x * pm, -top), Color("8a8d92"), maxf(1.0, 0.14 * pm))

## E-17a (entering) and E-18a (leaving, red diagonal bar): green board, white border and name.
static func _town_sign(cv, it: Dictionary, b: Vector2, pm: float, font: Font, ending: bool) -> void:
	var post := 3.0 * pm
	var w := TOWN_SIGN_W * pm
	var hh := 1.8 * pm
	_posts(cv, b, pm, post, [-1.6, 1.6])
	var r := Rect2(b + Vector2(-w * 0.5, -post - hh), Vector2(w, hh))
	cv.draw_rect(r, SIGN_GREEN)
	cv.draw_rect(r.grow(-0.14 * pm), Color.WHITE, false, maxf(1.0, 0.1 * pm))
	_fit_text(cv, font, r.grow_individual(-0.35 * pm, 0, -0.35 * pm, 0), it.text, Color.WHITE, 0.95 * pm)
	if ending:
		cv.draw_line(r.position + Vector2(w * 0.08, hh * 0.85), r.position + Vector2(w * 0.92, hh * 0.15), SIGN_RED, maxf(1.0, 0.24 * pm))

## Distance board: road number on a red plate, then towns with kilometres (nearest first, destination last).
## Blue on motorways, green on other roads.
static func _board(cv, it: Dictionary, b: Vector2, pm: float, font: Font) -> void:
	var lines: Array = it.lines
	var lh := 1.45 * pm
	var w := BOARD_W * pm
	var head := 1.5 * pm if it.road != "" else 0.25 * pm
	var hh := head + lh * lines.size() + 0.3 * pm
	var post := 3.0 * pm
	_posts(cv, b, pm, post, [-3.5, 3.5])
	var r := Rect2(b + Vector2(-w * 0.5, -post - hh), Vector2(w, hh))
	cv.draw_rect(r, SIGN_BLUE if it.blue else SIGN_GREEN)
	cv.draw_rect(r.grow(-0.14 * pm), Color.WHITE, false, maxf(1.0, 0.1 * pm))
	if it.road != "":
		var pl := plate(it.road)
		var pr := Rect2(r.position + Vector2(w * 0.5 - 1.2 * pm, 0.3 * pm), Vector2(2.4 * pm, 1.0 * pm))
		cv.draw_rect(pr, pl[1])
		_fit_text(cv, font, pr, pl[0], pl[2], 0.8 * pm)
	for i in lines.size():
		var row := Rect2(r.position + Vector2(0.5 * pm, head + lh * i), Vector2(w - 1.0 * pm, lh))
		_fit_text(cv, font, Rect2(row.position, Vector2(row.size.x * 0.78, lh)), lines[i][0], Color.WHITE, 0.85 * pm, HORIZONTAL_ALIGNMENT_LEFT)
		_fit_text(cv, font, row, str(lines[i][1]), Color.WHITE, 0.85 * pm, HORIZONTAL_ALIGNMENT_RIGHT)

## Brown tourist board with the name of the region being entered.
static func _region(cv, it: Dictionary, b: Vector2, pm: float, font: Font) -> void:
	var post := 2.8 * pm
	var w := REGION_W * pm
	var hh := 2.2 * pm
	_posts(cv, b, pm, post, [-3.0, 3.0])
	var r := Rect2(b + Vector2(-w * 0.5, -post - hh), Vector2(w, hh))
	cv.draw_rect(r, SIGN_BROWN)
	cv.draw_rect(r.grow(-0.14 * pm), Color.WHITE, false, maxf(1.0, 0.1 * pm))
	_fit_text(cv, font, Rect2(r.position + Vector2(0.35 * pm, 0.1 * pm), Vector2(w - 0.7 * pm, hh * 0.42)), "KRAINA", Color("f1d9b5"), 0.55 * pm)
	_fit_text(cv, font, Rect2(r.position + Vector2(0.35 * pm, hh * 0.42), Vector2(w - 0.7 * pm, hh * 0.52)), it.text, Color.WHITE, 0.8 * pm)

static func _block(cv, it: Dictionary, b: Vector2, pm: float) -> void:
	var w: float = it.w * pm
	var h: float = it.h * pm
	var col := Color("b9b8b2").lerp(BUILDING_COLORS[it.c], 0.25)
	cv.draw_rect(Rect2(b + Vector2(-w * 0.5, -h), Vector2(w, h)), col)
	if pm < 1.5:
		return
	var floors := maxi(3, int(it.h / 3.0))
	var cols := maxi(3, int(it.w / 2.5))
	var fh := h / floors
	for f in floors - 1:
		cv.draw_rect(Rect2(b + Vector2(-w * 0.46, -h + (f + 0.3) * fh), Vector2(w * 0.92, fh * 0.35)), Color("4a5560") if (f + cols) % 2 == 0 else Color("56616c"))

static func _pine(cv, b: Vector2, h: float, pm: float, season: String) -> void:
	var tw := maxf(1.0, 0.35 * pm)
	cv.draw_rect(Rect2(b + Vector2(-tw * 0.5, -h * 0.72), Vector2(tw, h * 0.72)), Color("9a5a38"))
	var col := Color("2f5c46") if season == "winter" else Color("2e5b35")
	cv.draw_circle(b + Vector2(0, -h * 0.8), h * 0.19, col)
	cv.draw_circle(b + Vector2(-h * 0.13, -h * 0.72), h * 0.13, col.lightened(0.05))
	cv.draw_circle(b + Vector2(h * 0.13, -h * 0.74), h * 0.14, col.darkened(0.08))
	if season == "winter":
		cv.draw_circle(b + Vector2(0, -h * 0.9), h * 0.08, Color("f4f7f9"))

static func _birch(cv, b: Vector2, h: float, pm: float, season: String) -> void:
	var tw := maxf(1.0, 0.3 * pm)
	cv.draw_rect(Rect2(b + Vector2(-tw * 0.5, -h * 0.8), Vector2(tw, h * 0.8)), Color("efefe6"))
	if pm > 2.0:
		cv.draw_rect(Rect2(b + Vector2(-tw * 0.5, -h * 0.35), Vector2(tw * 0.6, h * 0.03)), Color("2b2b2b"))
		cv.draw_rect(Rect2(b + Vector2(0, -h * 0.55), Vector2(tw * 0.5, h * 0.03)), Color("2b2b2b"))
	if season == "winter":
		cv.draw_line(b + Vector2(0, -h * 0.6), b + Vector2(-h * 0.2, -h * 0.9), Color("8a7a6a"), maxf(1.0, tw * 0.4))
		cv.draw_line(b + Vector2(0, -h * 0.65), b + Vector2(h * 0.2, -h * 0.95), Color("8a7a6a"), maxf(1.0, tw * 0.4))
		return
	var col := {"spring": Color("9ccc5a"), "summer": Color("6fae45"), "autumn": Color("e3b93c")}.get(season, Color("6fae45")) as Color
	cv.draw_circle(b + Vector2(0, -h * 0.78), h * 0.2, col)
	cv.draw_circle(b + Vector2(-h * 0.1, -h * 0.65), h * 0.14, col.darkened(0.08))
	cv.draw_circle(b + Vector2(h * 0.1, -h * 0.68), h * 0.15, col.lightened(0.06))

static func _poplar(cv, b: Vector2, h: float, pm: float, pal: Dictionary, season: String) -> void:
	cv.draw_rect(Rect2(b + Vector2(-maxf(1.0, 0.3 * pm) * 0.5, -h * 0.2), Vector2(maxf(1.0, 0.3 * pm), h * 0.2)), Color("5b3d27"))
	var col: Color = Color("7d6a55") if season == "winter" else (Color("c9a43a") if season == "autumn" else (pal.tree as Color).darkened(0.1))
	cv.draw_set_transform(b + Vector2(0, -h * 0.58), 0.0, Vector2(0.28 if season != "winter" else 0.16, 1.0))
	cv.draw_circle(Vector2.ZERO, h * 0.43, col)
	cv.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

static func _willow(cv, b: Vector2, h: float, pm: float, season: String) -> void:
	var tw := maxf(1.0, 0.12 * h)
	cv.draw_rect(Rect2(b + Vector2(-tw * 0.5, -h * 0.55), Vector2(tw, h * 0.55)), Color("6a5a45"))
	if season == "winter":
		for k in 5:
			cv.draw_line(b + Vector2(0, -h * 0.55), b + Vector2((k - 2) * h * 0.12, -h * 0.95), Color("8a6d4a"), maxf(1.0, 0.08 * pm))
		return
	var col := Color("c2b25a") if season == "autumn" else Color("8fae6a")
	cv.draw_circle(b + Vector2(0, -h * 0.72), h * 0.28, col)
	cv.draw_circle(b + Vector2(-h * 0.18, -h * 0.66), h * 0.18, col.darkened(0.08))
	cv.draw_circle(b + Vector2(h * 0.18, -h * 0.66), h * 0.18, col.lightened(0.05))

static func _apple(cv, it: Dictionary, b: Vector2, h: float, pm: float, pal: Dictionary, season: String) -> void:
	var tw := maxf(1.0, 0.25 * pm)
	cv.draw_rect(Rect2(b + Vector2(-tw * 0.5, -h * 0.45), Vector2(tw, h * 0.45)), Color("6b4a32"))
	if season == "winter":
		cv.draw_line(b + Vector2(0, -h * 0.45), b + Vector2(-h * 0.25, -h * 0.85), Color("6b4a32"), tw * 0.6)
		cv.draw_line(b + Vector2(0, -h * 0.45), b + Vector2(h * 0.25, -h * 0.85), Color("6b4a32"), tw * 0.6)
		return
	var crown := Color("7fae4a") if season == "spring" else (Color("9aa040") if season == "autumn" else (pal.tree as Color))
	cv.draw_circle(b + Vector2(0, -h * 0.68), h * 0.36, crown)
	if pm < 2.0:
		return
	var dot := Color("f6dbe6") if season == "spring" else Color("d0302a")
	for k in 4:
		var a: float = it.v * TAU + k * 1.7
		cv.draw_circle(b + Vector2(cos(a) * h * 0.22, -h * 0.68 + sin(a) * h * 0.2), maxf(1.0, h * 0.05), dot)

static func _woodhouse(cv, it: Dictionary, b: Vector2, pm: float) -> void:
	var w: float = it.w * pm
	var h: float = it.h * pm
	cv.draw_rect(Rect2(b + Vector2(-w * 0.5, -h * 0.55), Vector2(w, h * 0.55)), Color("7a5233"))
	if pm > 1.5:
		for k in 3:
			cv.draw_rect(Rect2(b + Vector2(-w * 0.5, -h * (0.14 + k * 0.15)), Vector2(w, maxf(1.0, h * 0.015))), Color("5e3e26"))
	cv.draw_colored_polygon(PackedVector2Array([b + Vector2(-w * 0.62, -h * 0.55), b + Vector2(w * 0.62, -h * 0.55), b + Vector2(0, -h)]), Color("4a3a30"))
	for x in [-0.3, 0.15]:
		cv.draw_rect(Rect2(b + Vector2(w * x, -h * 0.42), Vector2(w * 0.16, h * 0.18)), Color("3f6fb5"))
		cv.draw_rect(Rect2(b + Vector2(w * (x + 0.03), -h * 0.39), Vector2(w * 0.1, h * 0.12)), Color("e9eef2"))

static func _church(cv, it: Dictionary, b: Vector2, pm: float) -> void:
	var w: float = it.w * pm
	var h: float = it.h * pm
	var wall := Color("a9533d") if it.c % 2 == 0 else Color("ece6d8")
	cv.draw_rect(Rect2(b + Vector2(-w * 0.3, -h * 0.4), Vector2(w * 0.9, h * 0.4)), wall)
	cv.draw_colored_polygon(PackedVector2Array([b + Vector2(-w * 0.32, -h * 0.4), b + Vector2(w * 0.62, -h * 0.4), b + Vector2(w * 0.15, -h * 0.6)]), Color("8b3a2b"))
	cv.draw_rect(Rect2(b + Vector2(-w * 0.55, -h * 0.75), Vector2(w * 0.3, h * 0.75)), wall.darkened(0.08))
	cv.draw_colored_polygon(PackedVector2Array([b + Vector2(-w * 0.58, -h * 0.75), b + Vector2(-w * 0.22, -h * 0.75), b + Vector2(-w * 0.4, -h)]), Color("3d4a3f"))
	cv.draw_line(b + Vector2(-w * 0.4, -h), b + Vector2(-w * 0.4, -h * 1.08), Color("d8b84a"), maxf(1.0, 0.1 * pm))

static func _cerkiew(cv, it: Dictionary, b: Vector2, pm: float) -> void:
	var w: float = it.w * pm
	var h: float = it.h * pm
	var wall := Color("8a6a4a") if it.c % 2 == 0 else Color("efece4")
	var dome := Color("3f6aa8") if it.c % 3 == 0 else Color("3f7a52")
	cv.draw_rect(Rect2(b + Vector2(-w * 0.45, -h * 0.45), Vector2(w * 0.9, h * 0.45)), wall)
	cv.draw_rect(Rect2(b + Vector2(-w * 0.15, -h * 0.65), Vector2(w * 0.3, h * 0.2)), wall.darkened(0.1))
	cv.draw_circle(b + Vector2(0, -h * 0.72), w * 0.14, dome)
	cv.draw_circle(b + Vector2(-w * 0.32, -h * 0.5), w * 0.09, dome)
	cv.draw_circle(b + Vector2(w * 0.32, -h * 0.5), w * 0.09, dome)
	cv.draw_line(b + Vector2(0, -h * 0.84), b + Vector2(0, -h), Color("d8b84a"), maxf(1.0, 0.1 * pm))
	cv.draw_line(b + Vector2(-w * 0.04, -h * 0.94), b + Vector2(w * 0.04, -h * 0.94), Color("d8b84a"), maxf(1.0, 0.08 * pm))

## Roadside shrine (kapliczka).
static func _shrine(cv, b: Vector2, h: float, pm: float) -> void:
	var w := 1.0 * pm
	cv.draw_rect(Rect2(b + Vector2(-w * 0.5, -h * 0.75), Vector2(w, h * 0.75)), Color("ecebe4"))
	cv.draw_rect(Rect2(b + Vector2(-w * 0.25, -h * 0.65), Vector2(w * 0.5, h * 0.22)), Color("4f7fc0"))
	cv.draw_colored_polygon(PackedVector2Array([b + Vector2(-w * 0.7, -h * 0.75), b + Vector2(w * 0.7, -h * 0.75), b + Vector2(0, -h * 0.92)]), Color("5a4a3e"))
	cv.draw_line(b + Vector2(0, -h * 0.92), b + Vector2(0, -h), Color("3a3a3a"), maxf(1.0, 0.08 * pm))

static func _turbine(cv, it: Dictionary, b: Vector2, h: float, pm: float) -> void:
	var col := Color("eef1f3")
	cv.draw_line(b, b + Vector2(0, -h), col, maxf(1.0, 0.035 * h))
	var hub := b + Vector2(0, -h)
	var a0: float = it.v * TAU + Time.get_ticks_msec() * 0.0012
	for k in 3:
		var a := a0 + k * TAU / 3.0
		cv.draw_line(hub, hub + Vector2(cos(a), sin(a)) * h * 0.42, col, maxf(1.0, 0.02 * h))
	cv.draw_circle(hub, maxf(1.0, 0.03 * h), Color("d5d9dc"))

static func _windmill(cv, it: Dictionary, b: Vector2, h: float, pm: float) -> void:
	var w: float = it.w * pm
	cv.draw_colored_polygon(PackedVector2Array([b + Vector2(-w * 0.5, 0), b + Vector2(w * 0.5, 0), b + Vector2(w * 0.3, -h * 0.7), b + Vector2(-w * 0.3, -h * 0.7)]), Color("6a4a32"))
	cv.draw_colored_polygon(PackedVector2Array([b + Vector2(-w * 0.38, -h * 0.7), b + Vector2(w * 0.38, -h * 0.7), b + Vector2(0, -h * 0.85)]), Color("4a3a30"))
	var hub := b + Vector2(0, -h * 0.72)
	var a0: float = it.v * TAU + Time.get_ticks_msec() * 0.0006
	for k in 4:
		var a := a0 + k * TAU / 4.0
		var tip := hub + Vector2(cos(a), sin(a)) * h * 0.42
		cv.draw_line(hub, tip, Color("4a3a30"), maxf(1.0, 0.03 * h))
		cv.draw_line(hub.lerp(tip, 0.35), tip, Color("e8e0cc"), maxf(1.0, 0.07 * h))

static func _chimney(cv, b: Vector2, h: float) -> void:
	var bw := h * 0.06
	var tw := h * 0.035
	cv.draw_colored_polygon(PackedVector2Array([b + Vector2(-bw, 0), b + Vector2(bw, 0), b + Vector2(tw, -h), b + Vector2(-tw, -h)]), Color("8e5a48"))
	cv.draw_rect(Rect2(b + Vector2(-tw * 1.05, -h), Vector2(tw * 2.1, h * 0.05)), Color("d8d8d8"))
	cv.draw_rect(Rect2(b + Vector2(-tw * 1.08, -h * 0.95), Vector2(tw * 2.16, h * 0.05)), Color("c0392b"))
	var t := Time.get_ticks_msec() * 0.0004
	for k in 3:
		var f := fposmod(t + k / 3.0, 1.0)
		cv.draw_circle(b + Vector2(h * 0.15 * f, -h * (1.04 + 0.25 * f)), h * (0.04 + 0.06 * f), Color(0.85, 0.85, 0.85, 0.55 * (1.0 - f)))

## Mine shaft headframe (szyb) of the Silesian coal mines.
static func _headframe(cv, b: Vector2, h: float) -> void:
	var col := Color("7a2f28")
	var lw := maxf(1.0, h * 0.025)
	cv.draw_line(b + Vector2(-h * 0.08, 0), b + Vector2(-h * 0.08, -h * 0.9), col, lw)
	cv.draw_line(b + Vector2(h * 0.08, 0), b + Vector2(h * 0.08, -h * 0.9), col, lw)
	cv.draw_line(b + Vector2(h * 0.35, 0), b + Vector2(h * 0.06, -h * 0.85), col, lw)
	for k in 4:
		cv.draw_line(b + Vector2(-h * 0.08, -h * (0.2 + k * 0.2)), b + Vector2(h * 0.08, -h * (0.2 + k * 0.2)), col, lw * 0.7)
	cv.draw_rect(Rect2(b + Vector2(-h * 0.14, -h * 0.94), Vector2(h * 0.28, h * 0.06)), col.darkened(0.2))
	cv.draw_circle(b + Vector2(-h * 0.06, -h), h * 0.07, col.darkened(0.3))
	cv.draw_circle(b + Vector2(h * 0.06, -h), h * 0.07, col.darkened(0.3))

static func _cooling(cv, it: Dictionary, b: Vector2, h: float, pm: float) -> void:
	var w: float = it.w * pm
	cv.draw_colored_polygon(PackedVector2Array([b + Vector2(-w * 0.5, 0), b + Vector2(-w * 0.38, -h * 0.35), b + Vector2(-w * 0.31, -h * 0.68),
		b + Vector2(-w * 0.35, -h), b + Vector2(w * 0.35, -h), b + Vector2(w * 0.31, -h * 0.68), b + Vector2(w * 0.38, -h * 0.35), b + Vector2(w * 0.5, 0)]), Color("c9c9c4"))
	var t := Time.get_ticks_msec() * 0.0003
	for k in 3:
		var f := fposmod(t + k / 3.0, 1.0)
		cv.draw_circle(b + Vector2(w * 0.1 * (k - 1), -h * (1.05 + 0.3 * f)), w * (0.2 + 0.15 * f), Color(1, 1, 1, 0.6 * (1.0 - f)))

## Limestone rock (ostaniec) of the Kraków-Częstochowa Jura.
static func _rock(cv, it: Dictionary, b: Vector2, h: float, pm: float) -> void:
	var w: float = it.w * pm
	cv.draw_colored_polygon(PackedVector2Array([b + Vector2(-w * 0.5, 0), b + Vector2(-w * 0.45, -h * 0.6), b + Vector2(-w * 0.25, -h), b + Vector2(w * 0.1, -h * 0.95), b + Vector2(w * 0.4, -h * 0.7), b + Vector2(w * 0.5, 0)]), Color("d9d6ca"))
	cv.draw_colored_polygon(PackedVector2Array([b + Vector2(w * 0.05, 0), b + Vector2(w * 0.1, -h * 0.95), b + Vector2(w * 0.4, -h * 0.7), b + Vector2(w * 0.5, 0)]), Color("b9b5a8"))

## Castle ruin on a hill (Szlak Orlich Gniazd).
static func _castle(cv, it: Dictionary, b: Vector2, h: float, pm: float) -> void:
	var w: float = it.w * pm
	cv.draw_colored_polygon(PackedVector2Array([b + Vector2(-w * 0.9, 0), b + Vector2(-w * 0.4, -h * 0.3), b + Vector2(w * 0.4, -h * 0.32), b + Vector2(w * 0.9, 0)]), Color("7c8f4f"))
	var wall := Color("c4bcaa")
	cv.draw_rect(Rect2(b + Vector2(-w * 0.4, -h * 0.65), Vector2(w * 0.8, h * 0.36)), wall)
	for k in 5:
		cv.draw_rect(Rect2(b + Vector2(-w * 0.4 + k * w * 0.18, -h * 0.71), Vector2(w * 0.08, h * 0.07)), wall)
	cv.draw_rect(Rect2(b + Vector2(-w * 0.15, -h), Vector2(w * 0.2, h * 0.7)), wall.darkened(0.08))
	cv.draw_rect(Rect2(b + Vector2(-w * 0.09, -h * 0.85), Vector2(w * 0.06, h * 0.1)), Color("3a3a3a"))

static func _lighthouse(cv, b: Vector2, h: float, pm: float) -> void:
	var bw := h * 0.1
	var tw := h * 0.065
	cv.draw_colored_polygon(PackedVector2Array([b + Vector2(-bw, 0), b + Vector2(bw, 0), b + Vector2(tw, -h * 0.85), b + Vector2(-tw, -h * 0.85)]), Color("f0efe8"))
	for k in 2:
		var y := -h * (0.25 + k * 0.3)
		cv.draw_rect(Rect2(b + Vector2(-bw * 0.9, y), Vector2(bw * 1.8, h * 0.1)), Color("c0392b"))
	cv.draw_rect(Rect2(b + Vector2(-tw, -h * 0.97), Vector2(tw * 2.0, h * 0.12)), Color("f2d36b"))
	cv.draw_colored_polygon(PackedVector2Array([b + Vector2(-tw * 1.2, -h * 0.97), b + Vector2(tw * 1.2, -h * 0.97), b + Vector2(0, -h * 1.05)]), Color("3a3a3a"))

## Stork nest on a pole; the storks are away in autumn and winter.
static func _stork(cv, b: Vector2, h: float, pm: float, season: String) -> void:
	cv.draw_line(b, b + Vector2(0, -h), Color("8a8d92"), maxf(1.0, 0.15 * pm))
	var top := b + Vector2(0, -h)
	cv.draw_set_transform(top, 0.0, Vector2(1.0, 0.4))
	cv.draw_circle(Vector2.ZERO, 0.8 * pm, Color("6b5232"))
	cv.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if season == "autumn" or season == "winter":
		return
	cv.draw_line(top + Vector2(0.1 * pm, -0.2 * pm), top + Vector2(0.1 * pm, -1.1 * pm), Color.WHITE, maxf(1.0, 0.35 * pm))
	cv.draw_line(top + Vector2(0.3 * pm, -0.4 * pm), top + Vector2(0.3 * pm, -0.9 * pm), Color("1e1e1e"), maxf(1.0, 0.15 * pm))
	cv.draw_line(top + Vector2(0.1 * pm, -1.1 * pm), top + Vector2(0.6 * pm, -1.0 * pm), Color("d8402a"), maxf(1.0, 0.08 * pm))

static func _building(cv, it: Dictionary, b: Vector2, pm: float) -> void:
	var w: float = it.w * pm
	var h: float = it.h * pm
	var col: Color = BUILDING_COLORS[it.c]
	cv.draw_rect(Rect2(b + Vector2(-w * 0.5, -h), Vector2(w, h)), col)
	cv.draw_rect(Rect2(b + Vector2(-w * 0.5, -h), Vector2(w, h * 0.05)), col.darkened(0.3))      # cornice
	cv.draw_rect(Rect2(b + Vector2(-w * 0.5, -h * 0.06), Vector2(w, h * 0.06)), col.darkened(0.2))
	if pm < 2.0:
		return
	var floors := maxi(2, int(it.h / 4.0))
	var cols := maxi(2, int(it.w / 3.0))
	var fh := h * 0.9 / floors
	for f in range(1, floors):
		for c in cols:
			var wx := -w * 0.5 + w * (c + 0.5) / cols - 0.55 * pm
			cv.draw_rect(Rect2(b + Vector2(wx, -h + f * fh * 1.0), Vector2(1.1 * pm, fh * 0.55)), Color("2b3a4a"))

static func _tree(cv, it: Dictionary, b: Vector2, pm: float, pal: Dictionary, season: String) -> void:
	var h: float = it.h * pm
	var tw := maxf(1.0, 0.45 * pm)
	cv.draw_rect(Rect2(b + Vector2(-tw * 0.5, -h * 0.55), Vector2(tw, h * 0.55)), Color("5b3d27"))
	if season == "winter":
		cv.draw_line(b + Vector2(0, -h * 0.5), b + Vector2(-h * 0.25, -h * 0.85), Color("5b3d27"), tw * 0.6)
		cv.draw_line(b + Vector2(0, -h * 0.5), b + Vector2(h * 0.25, -h * 0.9), Color("5b3d27"), tw * 0.6)
		cv.draw_line(b + Vector2(0, -h * 0.6), b + Vector2(0, -h), Color("5b3d27"), tw * 0.6)
		cv.draw_circle(b + Vector2(0, -h * 0.55), h * 0.07, Color.WHITE)
		return
	var r := h * 0.32
	var c1: Color = pal.tree
	cv.draw_circle(b + Vector2(0, -h * 0.72), r, c1.darkened(0.15))
	cv.draw_circle(b + Vector2(-r * 0.45, -h * 0.65), r * 0.7, c1)
	cv.draw_circle(b + Vector2(r * 0.5, -h * 0.68), r * 0.7, c1.lightened(0.08))
	if season == "spring" or season == "autumn":
		cv.draw_circle(b + Vector2(r * 0.2, -h * 0.82), r * 0.4, pal.tree2)
		cv.draw_circle(b + Vector2(-r * 0.5, -h * 0.55), r * 0.3, pal.tree2)

static func _spruce(cv, it: Dictionary, b: Vector2, pm: float, pal: Dictionary, season: String) -> void:
	var h: float = it.h * pm
	var w: float = h * 0.38
	var col: Color = Color("2c6a3a") if season != "autumn" else Color("4b6a2e")
	if season == "winter": col = Color("2f5c46")
	cv.draw_rect(Rect2(b + Vector2(-w * 0.07, -h * 0.15), Vector2(w * 0.14, h * 0.15)), Color("4f3a2a"))
	for k in 3:
		var y0 := -h * (0.12 + k * 0.24)
		var ww := w * (1.0 - k * 0.28)
		cv.draw_colored_polygon(PackedVector2Array([b + Vector2(-ww, y0), b + Vector2(ww, y0), b + Vector2(0, y0 - h * 0.36)]), col.lightened(k * 0.05))
		if season == "winter":
			cv.draw_colored_polygon(PackedVector2Array([b + Vector2(-ww * 0.55, y0 - h * 0.16), b + Vector2(ww * 0.55, y0 - h * 0.16), b + Vector2(0, y0 - h * 0.36)]), Color("f4f7f9"))

static func _house(cv, it: Dictionary, b: Vector2, pm: float) -> void:
	var w: float = it.w * pm
	var h: float = it.h * pm
	cv.draw_rect(Rect2(b + Vector2(-w * 0.5, -h * 0.6), Vector2(w, h * 0.6)), Color("e8dcc0"))
	cv.draw_colored_polygon(PackedVector2Array([b + Vector2(-w * 0.6, -h * 0.6), b + Vector2(w * 0.6, -h * 0.6), b + Vector2(0, -h)]), Color("9a4a35"))
	cv.draw_rect(Rect2(b + Vector2(-w * 0.12, -h * 0.32), Vector2(w * 0.24, h * 0.32)), Color("5a3a28"))

static func _station(cv, b: Vector2, pm: float, font: Font) -> void:
	var w := 14.0 * pm
	var h := 6.0 * pm
	cv.draw_rect(Rect2(b + Vector2(-w * 0.5, -h * 0.55), Vector2(w * 0.4, h * 0.55)), Color("e8e8ea"))
	cv.draw_rect(Rect2(b + Vector2(-w * 0.55, -h), Vector2(w * 1.1, h * 0.18)), Color("f2b01e"))      # canopy
	cv.draw_line(b + Vector2(-w * 0.35, -h * 0.82), b + Vector2(-w * 0.35, 0), Color("55595f"), maxf(1.0, 0.25 * pm))
	cv.draw_line(b + Vector2(w * 0.4, -h * 0.82), b + Vector2(w * 0.4, 0), Color("55595f"), maxf(1.0, 0.25 * pm))
	cv.draw_rect(Rect2(b + Vector2(w * 0.05, -h * 0.28), Vector2(0.9 * pm, h * 0.28)), Color("c0392b"))  # pump
	cv.draw_rect(Rect2(b + Vector2(w * 0.25, -h * 0.28), Vector2(0.9 * pm, h * 0.28)), Color("c0392b"))
	# tall price pylon, readable from afar
	cv.draw_line(b + Vector2(-w * 0.62, 0), b + Vector2(-w * 0.62, -h * 2.2), Color("55595f"), maxf(1.0, 0.3 * pm))
	cv.draw_rect(Rect2(b + Vector2(-w * 0.62 - 1.6 * pm, -h * 2.2 - 3.0 * pm), Vector2(3.2 * pm, 3.0 * pm)), Color("f2b01e"))
	if pm > 6.0:
		cv.draw_string(font, b + Vector2(-w * 0.62 - 1.4 * pm, -h * 2.2 - 0.9 * pm), "PALIWO", HORIZONTAL_ALIGNMENT_LEFT, 2.8 * pm, int(clampf(0.9 * pm, 6, 36)), Color("1d1d1f"))
