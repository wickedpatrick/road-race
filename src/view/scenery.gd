class_name Scenery
extends RefCounted
## Roadside world. build() places objects per 5 m segment following the route's regions and towns, ground() paints
## flat strips beside the road (fields, lakes, canals), draw_item() paints one object at a ground point.
const BUILDING_COLORS := [Color("d9b26b"), Color("e7dcc0"), Color("d98a6c"), Color("a85a45"), Color("8fa3b5"), Color("c9a24a")]
const WALL_DARK := Color(0, 0, 0, 0.18)
const SIGN_GREEN := Color("0f7a43")
const SIGN_BLUE := Color("1d4f9e")
static var flip := 1.0 ## -1 with left-hand traffic: the world is mirrored, so bend arrows and lamp arms turn round
static var _sign_cols := {} ## country code -> {town, board, board_motorway} colours (the country's "signs")

## Colour of a road sign in the current country: "town" / "town_text" (place-name signs and their lettering),
## "board" / "board_motorway" (direction boards with distances), "board_text" (lettering on the ordinary boards,
## white unless given, e.g. black on Germany's yellow ones).
## `p`: the part of a multi-country map (Geo.part), "" for the map's own.
static func sign_color(kind: String, p := "") -> Color:
	var code := GameData.current + "/" + p
	if not _sign_cols.has(code):
		var cols := {}
		var signs: Dictionary = Geo.part(p).signs
		for k in signs:
			cols[k] = Color(signs[k])
		_sign_cols[code] = cols
	return _sign_cols[code].get(kind, Color.WHITE)
const SIGN_BROWN := Color("7b4a26")
const SIGN_RED := Color("d0202a")
const SIGN_YELLOW := Color("f2c21b")

## Road number plate (E-15): red with white for A, S and national roads (DK shows just the number),
## yellow with black for regional roads (DW). Returns [label, plate colour, text colour].
## A country can give its own plates in data ("plates": [[prefix, plate colour, text colour], ...], first match).
static func plate(road: String, p := "") -> Array:
	for pl in Geo.part(p).get("plates", []):
		if road.begins_with(pl[0]):
			return [road, Color(pl[1]), Color(pl[2])]
	if road.begins_with("DW"):
		return [road.trim_prefix("DW"), SIGN_YELLOW, Color.BLACK]
	return [road.trim_prefix("DK"), SIGN_RED, Color.WHITE]
const HERD_CHANCE := 0.18 ## chance of a herd of cows per step of open farmland (other regions scale it)
const SIGN_EDGE := 5.0 ## signs start just past the rumble strip on the right shoulder
const STATION_SIGN_BEFORE := 150.0 ## the blue fuel station sign (D-23) stands this far before the station
const PUMP_LAT := 7.4 ## the nearer pumps stand right past the station's pit lane
const TUNNEL_WALL := 5.8 ## tunnel walls, metres from the road centre
const TOWN_SIGN_W := 6.4
const BOARD_W := 10.0
const REGION_W := 8.6
## ground strip colour ids, looked up in the season palette
const GROUND_KEYS := ["crop_a", "crop_b", "crop_c", "water", "sand", "pave", "dark", "redsand"]
enum {G_CROP_A, G_CROP_B, G_CROP_C, G_WATER, G_SAND, G_PAVE, G_DARK, G_REDSAND}

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
	for lm in Landmarks.place(stage):
		_clear_around(items, lm)
		var it := _add(items, "landmark", lm.z, lm.lat, lm.w, lm.h, rng)
		it.kind = lm.kind
		_add(items, "poi", lm.z - 22.0, SIGN_EDGE + REGION_W * 0.5, REGION_W, 5.0, rng).text = lm.local
	for tn in stage.get("tunnels", []):
		_clear_range(items, tn.z0 - 6.0, tn.z1 + 6.0, -1000.0, 1000.0)
	for s in stage.stations:
		_station_items(items, s, rng)
	for bd in stage.get("borders", []):
		_crossing(items, stage, bd, rng)
	for f in stage.get("ferries", []):
		_port(items, f, rng)
	_add(items, "finish", length, 0.0, 0.0, 7.0, rng)
	# on a map spanning several countries the signs and stations follow the part of the map they stand in
	if not stage.get("borders", []).is_empty() or stage.get("part0", "") != "":
		for idx in items:
			for it in items[idx]:
				if it.type in PART_ITEMS: it.p = Geo.part_at(stage, it.z)
	# on a dual carriageway the left roadside stands beyond the median and the oncoming carriageway
	for idx in items:
		for it in items[idx]:
			if it.lat < 0.0:
				it.lat -= Track.left_shift(Route.dual_f(stage, it.z))
	return items

## A fuel station on the right: the blue D-23 sign before it, a tall price pylon, pumps right beside the pit lane under
## a canopy, the shop further back. Whatever grew there before is cleared away.
static func _station_items(items: Dictionary, s: float, rng: RandomNumberGenerator) -> void:
	var half := Race.STATION_HALF_LEN
	_clear_range(items, s - half - 30.0, s + half + 25.0, 0.0, 40.0)
	_clear_range(items, s - STATION_SIGN_BEFORE - 6.0, s - STATION_SIGN_BEFORE + 6.0, 0.0, 9.0)
	_add(items, "station_sign", s - STATION_SIGN_BEFORE, SIGN_EDGE + 1.4, 2.4, 4.6, rng)
	_add(items, "pylon", s - half - 8.0, 9.6, 3.2, 17.0, rng)
	_add(items, "shop", s + 12.0, 24.0, 14.0, 5.0, rng)
	for dz in [16.0, -6.0]:
		for lat in [PUMP_LAT, PUMP_LAT + 4.6]:
			_add(items, "pump", s + dz, lat, 1.0, 2.0, rng)
	_add(items, "canopy", s - 14.0, PUMP_LAT + 2.3, 12.0, 6.8, rng)

const PART_ITEMS := ["town_sign", "town_end", "board", "region", "pylon", "canopy"]

## A border crossing (Route borders): limit signs (40, then 20) and a radar before it, open red-white barriers on both
## sides of the road, a guard booth beside it, a canopy over the lanes, and the board with the name and flag of the
## country entered.
static func _crossing(items: Dictionary, stage: Dictionary, bd: Dictionary, rng: RandomNumberGenerator) -> void:
	var z: float = bd.z
	_clear_range(items, z - Route.CROSS_40 - 8.0, z + Route.CROSS_AFTER + 12.0, -1000.0, 1000.0)
	_limit_sign(items, z - Route.CROSS_40 + 2.0, Route.CROSS_LIMITS[0], rng)
	_limit_sign(items, z - Route.CROSS_20 + 2.0, Route.CROSS_LIMITS[1], rng)
	_limit_sign(items, z + Route.CROSS_AFTER + 4.0, Route.sign_limit_at(stage, z + Route.CROSS_AFTER + 6.0), rng)
	_add(items, "radar", z - Route.RADAR_BEFORE, SIGN_EDGE + 0.6, 1.0, 3.6, rng)
	var bb := _add(items, "border_board", z - 70.0, SIGN_EDGE + REGION_W * 0.5, REGION_W, 5.0, rng)
	bb.text = bd.name
	bb.flag = bd.to
	bb.country = Geo.part(bd.to).name
	_add(items, "border_canopy", z + 8.0, 0.0, 0.0, 6.5, rng)
	for sd in [1.0, -1.0]:
		_add(items, "barrier", z, sd * (Track.ROAD_HALF_WIDTH + 0.9), 1.0, 5.0, rng).dir = sd
	_add(items, "booth", z + 10.0, Track.ROAD_HALF_WIDTH + 4.5, 3.0, 3.2, rng)
	_add(items, "booth", z + 6.0, -(Track.ROAD_HALF_WIDTH + 4.5), 3.0, 3.2, rng)

## A ferry port (Route ferries): the blue ferry sign before the quay, a concrete pier with bollards, lamps, the
## terminal, containers and a crane, closed barriers at its end and the ship behind them with its stern ramp down;
## the far quay past the sea the same, without the ship. Whatever grew there before is cleared away.
const QUAY_EDGE := 30.0 ## the pier's edges, metres from the road centre (water beyond)
const FERRY_SIGN_BEFORE := 30.0 ## the ferry sign stands this far before the quay
static func _port(items: Dictionary, f: Dictionary, rng: RandomNumberGenerator) -> void:
	var q0: float = f.z - Route.FERRY_QUAY
	_clear_range(items, q0 - FERRY_SIGN_BEFORE - 8.0, f.z_out + 70.0, -1000.0, 1000.0)
	_add(items, "ferry_sign", q0 - FERRY_SIGN_BEFORE, SIGN_EDGE + REGION_W * 0.5, REGION_W, 5.0, rng).text = f.name
	for side in [[q0, f.z - 2.0], [f.z_out - 30.0, f.z_out + 64.0]]:
		var z: float = side[0] + 6.0
		while z < side[1]:
			for sd in [-1.0, 1.0]:
				_quay(items, "bollard", z, sd * (QUAY_EDGE - 0.8), 0.6, 0.8, rng)
			if int(z) % 40 < 15:
				_add(items, "lamp", z, 9.0, 0.4, 8.0, rng)
				_add(items, "lamp", z, -9.0, 0.4, 8.0, rng)
			z += 15.0
	_quay(items, "terminal", q0 + 25.0, 19.0, 14.0, 7.0, rng)
	for k in 3:
		_quay(items, "containers", q0 + 50.0 + k * 16.0, -(16.5 + 3.0 * (k % 2)), 12.0, 2.6 * (1 + (k + 1) % 2), rng)
	_quay(items, "crane", f.z - 25.0, -22.0, 12.0, 30.0, rng)
	_quay(items, "terminal", f.z_out + 30.0, -19.0, 12.0, 6.0, rng)
	_add(items, "ferry_ship", f.z + Route.FERRY_STERN, 0.0, 24.0, 19.0, rng).text = f.name # before the barriers: drawn behind them
	for sd in [1.0, -1.0]:
		var bar := _add(items, "barrier", f.z - 1.5, sd * (Track.ROAD_HALF_WIDTH + 0.9), 1.0, 2.0, rng)
		bar.dir = sd
		bar.closed = true

static func _quay(items: Dictionary, kind: String, z: float, lat: float, w: float, h: float, rng: RandomNumberGenerator) -> void:
	_add(items, "quay", z, lat, w, h, rng).kind = kind

## Port objects on a quay (type "quay", by kind).
static func _quay_item(cv, it: Dictionary, b: Vector2, pm: float) -> void:
	var w: float = it.w * pm
	var h: float = it.h * pm
	match it.kind:
		"bollard":
			cv.draw_rect(Rect2(b + Vector2(-w * 0.35, -h), Vector2(w * 0.7, h)), Color("2b2d31"))
			cv.draw_rect(Rect2(b + Vector2(-w * 0.5, -h - 0.15 * pm), Vector2(w, 0.25 * pm)), Color("3b3e44"))
		"terminal":
			cv.draw_rect(Rect2(b + Vector2(-w * 0.5, -h), Vector2(w, h)), Color("eef1f3"))
			cv.draw_rect(Rect2(b + Vector2(-w * 0.45, -h * 0.75), Vector2(w * 0.9, h * 0.4)), Color("6f97b8"))
			cv.draw_rect(Rect2(b + Vector2(-w * 0.5, -h - 0.6 * pm), Vector2(w, 0.6 * pm)), SIGN_BLUE)
		"containers":
			var cols := [Color("b5452f"), Color("2f6f9e"), Color("d9a331"), Color("3f8a55")]
			var rows := maxi(1, roundi(it.h / 2.6))
			for r in rows:
				for k in 2:
					var col: Color = cols[(it.c + r * 2 + k) % cols.size()]
					var cr := Rect2(b + Vector2(-w * 0.5 + k * w * 0.5, -(r + 1) * 2.6 * pm), Vector2(w * 0.5 - 0.1 * pm, 2.5 * pm))
					cv.draw_rect(cr, col)
					if pm > 1.5:
						for v in 4:
							cv.draw_line(cr.position + Vector2(cr.size.x * (v + 0.5) / 4.0, 0.2 * pm), cr.position + Vector2(cr.size.x * (v + 0.5) / 4.0, cr.size.y - 0.2 * pm), col.darkened(0.25), maxf(1.0, 0.08 * pm))
		"crane":
			# a harbour crane: two legs, the machine house, the boom out over the water
			var c := Color("d9a331")
			var lw := maxf(1.0, 0.5 * pm)
			var top := b + Vector2(0, -h * 0.62)
			cv.draw_line(b + Vector2(-w * 0.4, 0), top + Vector2(-w * 0.12, 0), c, lw)
			cv.draw_line(b + Vector2(w * 0.4, 0), top + Vector2(w * 0.12, 0), c, lw)
			cv.draw_line(b + Vector2(-w * 0.32, -h * 0.2), b + Vector2(w * 0.32, -h * 0.2), c, lw)
			cv.draw_rect(Rect2(top + Vector2(-w * 0.2, -h * 0.12), Vector2(w * 0.4, h * 0.12)), Color("e9e4d6"))
			var out := signf(it.lat) * flip # the boom reaches away from the road (drawn unmirrored)
			cv.draw_line(top + Vector2(0, -h * 0.06), top + Vector2(out * w * 1.6, -h * 0.38), c, lw)
			cv.draw_line(top + Vector2(0, -h * 0.12), top + Vector2(0, -h * 0.38), c, lw * 0.7)
			cv.draw_line(top + Vector2(0, -h * 0.38), top + Vector2(out * w * 1.6, -h * 0.38), c, lw * 0.5)

## The ferry's stern at the end of the quay: the hull, the open car deck with its ramp down onto the quay, decks of
## white superstructure, a funnel, and the ferry's name on the stern.
static func _ferry_ship(cv, it: Dictionary, b: Vector2, pm: float, font: Font) -> void:
	var hw: float = it.w * 0.5 * pm
	var hull := Color("1f3f73")
	var white := Color("f3f4f2")
	# hull: dark blue below the car deck, a red waterline stripe
	cv.draw_colored_polygon(PackedVector2Array([b + Vector2(-hw, -7.0 * pm), b + Vector2(hw, -7.0 * pm), b + Vector2(hw * 0.94, 0.4 * pm), b + Vector2(-hw * 0.94, 0.4 * pm)]), hull)
	cv.draw_rect(Rect2(b + Vector2(-hw * 0.94, -0.4 * pm), Vector2(hw * 1.88, 0.8 * pm)), Color("b8322a"))
	# superstructure: two white decks with window rows, the bridge on top
	cv.draw_rect(Rect2(b + Vector2(-hw, -12.0 * pm), Vector2(hw * 2.0, 5.0 * pm)), white)
	cv.draw_rect(Rect2(b + Vector2(-hw * 0.8, -15.0 * pm), Vector2(hw * 1.6, 3.0 * pm)), white)
	if pm > 1.0:
		for row in [-11.0, -9.2, -14.0]:
			var span := hw * (0.92 if row > -12.0 else 0.72)
			var n := 14
			for k in n:
				var x := -span + (k + 0.2) * span * 2.0 / n
				cv.draw_rect(Rect2(b + Vector2(x, row * pm), Vector2(span * 2.0 / n * 0.6, 0.8 * pm)), Color("2a3a4a"))
	# lifeboats along the upper deck, the funnel
	for sd in [-1.0, 1.0]:
		cv.draw_rect(Rect2(b + Vector2(sd * hw * 0.92 - 1.2 * pm, -12.9 * pm), Vector2(2.4 * pm, 0.9 * pm)), Color("f08a1c"))
	cv.draw_rect(Rect2(b + Vector2(-1.6 * pm, -19.0 * pm), Vector2(3.2 * pm, 4.0 * pm)), white)
	cv.draw_rect(Rect2(b + Vector2(-1.6 * pm, -18.2 * pm), Vector2(3.2 * pm, 1.0 * pm)), SIGN_BLUE)
	cv.draw_rect(Rect2(b + Vector2(-1.6 * pm, -19.0 * pm), Vector2(3.2 * pm, 0.5 * pm)), Color("26272b"))
	# the open stern door: the lit car deck inside, the ramp down onto the quay towards the car
	var dw := 5.2 * pm
	cv.draw_rect(Rect2(b + Vector2(-dw, -5.6 * pm), Vector2(dw * 2.0, 5.6 * pm)), Color("2b2f36"))
	cv.draw_rect(Rect2(b + Vector2(-dw * 0.8, -4.6 * pm), Vector2(dw * 1.6, 3.6 * pm)), Color("4a4f57"))
	cv.draw_rect(Rect2(b + Vector2(-dw * 0.8, -4.6 * pm), Vector2(dw * 1.6, 0.4 * pm)), Color("f2e6b0"))
	cv.draw_colored_polygon(PackedVector2Array([b + Vector2(-dw, -0.9 * pm), b + Vector2(dw, -0.9 * pm), b + Vector2(dw * 1.1, 0.9 * pm), b + Vector2(-dw * 1.1, 0.9 * pm)]), Color("6d7178"))
	for k in 4:
		var y := lerpf(-0.6, 0.7, k / 3.0) * pm
		cv.draw_line(b + Vector2(-dw * 1.02, y), b + Vector2(dw * 1.02, y), Color("575b61"), maxf(1.0, 0.1 * pm))
	# the name on the stern
	_fit_text(cv, font, Rect2(b + Vector2(-hw * 0.9, -6.9 * pm), Vector2(hw * 1.8, 1.2 * pm)), it.text, Color.WHITE, 1.0 * pm)

## The ferry sign before the port: a blue board with a white ship and the ferry's name.
static func _ferry_sign(cv, it: Dictionary, b: Vector2, pm: float, font: Font) -> void:
	var post := 2.8 * pm
	var w := REGION_W * pm
	var hh := 2.4 * pm
	_posts(cv, b, pm, post, [-3.0, 3.0])
	var r := Rect2(b + Vector2(-w * 0.5, -post - hh), Vector2(w, hh))
	cv.draw_rect(r, SIGN_BLUE)
	cv.draw_rect(r.grow(-0.14 * pm), Color.WHITE, false, maxf(1.0, 0.1 * pm))
	ship_icon(cv, r.position + Vector2(1.2 * pm, hh * 0.62), 0.55 * pm, Color.WHITE)
	_fit_text(cv, font, Rect2(r.position + Vector2(2.4 * pm, 0.2 * pm), Vector2(w - 2.7 * pm, hh - 0.4 * pm)), it.text, Color.WHITE, 0.75 * pm)

## A ship pictogram centred at c on its waterline, `s` pixels per unit (about 3.4 units long).
static func ship_icon(cv, c: Vector2, s: float, col: Color) -> void:
	cv.draw_colored_polygon(PackedVector2Array([c + Vector2(-1.7, -0.6) * s, c + Vector2(1.7, -0.6) * s, c + Vector2(1.2, 0.3) * s, c + Vector2(-1.3, 0.3) * s]), col)
	cv.draw_rect(Rect2(c + Vector2(-1.0, -1.25) * s, Vector2(1.8, 0.55) * s), col)
	cv.draw_rect(Rect2(c + Vector2(-0.2, -1.8) * s, Vector2(0.45, 0.5) * s), col)
	for k in 3:
		var x := (-1.6 + k * 1.1) * s
		cv.draw_line(c + Vector2(x, 0.6 * s), c + Vector2(x + 0.5 * s, 0.6 * s), col, maxf(1.0, 0.15 * s))

## Open barrier: a striped post, the red-white arm raised almost upright. Closed (a ferry quay's end): the arm lies
## across the road, lifted (WorldView) while a car drives aboard.
static func _barrier(cv, it: Dictionary, b: Vector2, pm: float) -> void:
	var post := 1.1 * pm
	cv.draw_rect(Rect2(b + Vector2(-0.25 * pm, -post), Vector2(0.5 * pm, post)), Color("e9e9e9"))
	cv.draw_rect(Rect2(b + Vector2(-0.35 * pm, -post - 0.4 * pm), Vector2(0.7 * pm, 0.5 * pm)), SIGN_RED)
	var base := b + Vector2(0, -post - 0.15 * pm)
	var d: float = -it.dir * flip * 0.18 # leans over the road a little
	var tip := base + Vector2(d * 4.0 * pm, -4.0 * pm)
	if it.get("closed", false) and not it.get("lifted", false):
		tip = base + Vector2(-it.dir * flip * absf(it.lat) * pm, 0.0) # to the road's centre, over the median too
	var n := 6
	for k in n:
		var a := base.lerp(tip, float(k) / n)
		var c := base.lerp(tip, float(k + 1) / n)
		cv.draw_line(a, c, SIGN_RED if k % 2 == 0 else Color.WHITE, maxf(1.0, 0.28 * pm))

## The guards' booth: a small white hut with a window and a flat roof.
static func _booth(cv, it: Dictionary, b: Vector2, pm: float) -> void:
	var w: float = it.w * pm
	var h: float = it.h * pm
	cv.draw_rect(Rect2(b + Vector2(-w * 0.5, -h), Vector2(w, h)), Color("eef0f2"))
	cv.draw_rect(Rect2(b + Vector2(-w * 0.38, -h * 0.75), Vector2(w * 0.76, h * 0.35)), Color("7fa3bf"))
	cv.draw_rect(Rect2(b + Vector2(-w * 0.6, -h - 0.35 * pm), Vector2(w * 1.2, 0.4 * pm)), Color("4a4f57"))

## Fixed speed camera: a grey box on a post.
static func _radar(cv, b: Vector2, pm: float) -> void:
	var top := 2.4 * pm
	_posts(cv, b, pm, top, [0.0])
	cv.draw_rect(Rect2(b + Vector2(-0.45 * pm, -top - 1.1 * pm), Vector2(0.9 * pm, 1.2 * pm)), Color("6d737b"))
	cv.draw_rect(Rect2(b + Vector2(-0.45 * pm, -top - 1.1 * pm), Vector2(0.9 * pm, 0.3 * pm)), SIGN_YELLOW)
	if pm > 2.0:
		cv.draw_circle(b + Vector2(0, -top - 0.45 * pm), 0.22 * pm, Color("1d1d1f"))

## The board before a crossing: the flag and the name of the country entered, the crossing's name under them.
static func _border_board(cv, it: Dictionary, b: Vector2, pm: float, font: Font) -> void:
	var post := 2.8 * pm
	var w := REGION_W * pm
	var hh := 2.4 * pm
	_posts(cv, b, pm, post, [-3.0, 3.0])
	var r := Rect2(b + Vector2(-w * 0.5, -post - hh), Vector2(w, hh))
	cv.draw_rect(r, SIGN_BLUE)
	cv.draw_rect(r.grow(-0.14 * pm), Color.WHITE, false, maxf(1.0, 0.1 * pm))
	var fl := Vector2(1.5 * pm, 1.0 * pm)
	if fl.x >= 3.0:
		FlagPainter.draw(cv, it.flag, Rect2(r.position + Vector2(0.35 * pm, 0.25 * pm), fl))
	_fit_text(cv, font, Rect2(r.position + Vector2(0.55 * pm + fl.x, 0.15 * pm), Vector2(w - 0.9 * pm - fl.x, hh * 0.5)), it.country, Color.WHITE, 0.8 * pm)
	_fit_text(cv, font, Rect2(r.position + Vector2(0.35 * pm, hh * 0.55), Vector2(w - 0.7 * pm, hh * 0.4)), it.text, Color("dfe8f5"), 0.6 * pm)

static func _clear_range(items: Dictionary, z0: float, z1: float, lat0: float, lat1: float) -> void:
	for idx in range(int(z0 / Track.SEG_LEN), int(z1 / Track.SEG_LEN) + 1):
		if items.has(idx):
			items[idx] = items[idx].filter(func(it): return not (it.z >= z0 and it.z <= z1 and it.lat >= lat0 and it.lat <= lat1))

## Solid parts of the roadside objects the car can reach: segment -> [[z, lat0, lat1], ...]. Sign boards stand high
## on their posts (the car would pass under), so only the posts count; trees by their trunk, houses by their width.
## Fuel stations are a safe zone; tunnel walls are solid all along.
static func obstacles(items: Dictionary, stage: Dictionary) -> Dictionary:
	var out := {}
	var reach := 9.0 ## metres from the road centre: the car's edge never gets further
	for idx in items:
		for it in items[idx]:
			var spans: Array = _solid(it)
			if spans.is_empty():
				continue
			var near_station := false
			for st in stage.stations:
				if absf(it.z - st) < Race.STATION_HALF_LEN + 6.0:
					near_station = true
			if near_station:
				continue
			for sp in spans:
				var a: float = it.lat + sp[0]
				var b: float = it.lat + sp[1]
				if minf(absf(a), absf(b)) > reach and signf(a) == signf(b):
					continue
				_obstacle(out, it.z, a, b)
	for tn in stage.get("tunnels", []):
		var z: float = tn.z0
		while z <= tn.z1:
			_obstacle(out, z, -40.0, -TUNNEL_WALL)
			_obstacle(out, z, TUNNEL_WALL, 40.0)
			z += 2.0
	return out

static func _obstacle(out: Dictionary, z: float, a: float, b: float) -> void:
	var idx := int(z / Track.SEG_LEN)
	if not out.has(idx):
		out[idx] = []
	out[idx].append([z, minf(a, b), maxf(a, b)])

## Solid spans of one object, relative to its lat.
static func _solid(it: Dictionary) -> Array:
	var hw: float = it.w * 0.5
	match it.type:
		"limit", "bend", "chevron", "station_sign", "lamp", "stork", "cow", "sheep", "horse", "radar", "barrier":
			return [[-0.15, 0.15]]
		"town_sign", "town_end":
			return [[-1.75, -1.45], [1.45, 1.75]]
		"board":
			return [[-3.65, -3.35], [3.35, 3.65]]
		"region", "poi", "billboard", "border_board":
			return [[-3.15, -2.85], [2.85, 3.15]]
		"tree", "pine", "birch", "spruce", "poplar", "willow", "apple", "cactus", "olive", "cypress":
			return [[-0.3, 0.3]]
		"shrine":
			return [[-0.6, 0.6]]
		"bridge":
			var p := Track.ROAD_HALF_WIDTH + 2.5
			var m := (1.0 + Track.MEDIAN * 0.5) * Track.ROAD_HALF_WIDTH # the median pillar of a dual carriageway
			return [[-m - 0.4, -m + 0.4], [p - 0.9, p + 0.9]]
		"haybale", "lavarock", "redrock", "mesa", "stonewall", "whitehouse", "building", "house", "woodhouse", "farm", "church", "cerkiew", "block", "castle", "rock", "windmill", \
				"chimney", "headframe", "cooling", "lighthouse", "landmark", "heap", "turbine", "booth", "quay":
			return [[-hw, hw]]
	return []

const CLEARABLE := ["building", "house", "woodhouse", "tree", "church", "cerkiew", "block", "farm", "apple", "pine",
	"birch", "spruce", "poplar", "cow", "sheep", "horse", "moss", "lavarock",
	"cactus", "bush", "redrock", "mesa", "olive", "cypress", "maquis", "stonewall", "whitehouse"]

## Makes room for a landmark: removes houses and trees on its spot and on its side of the road before it, like a
## square in front of it, so it can be seen while driving up to it.
static func _clear_around(items: Dictionary, lm: Dictionary) -> void:
	var z0: float = lm.z - lm.w * 0.5 - 140.0
	var z1: float = lm.z + lm.w * 0.5 + 8.0
	var far: float = absf(lm.lat) + lm.w * 0.5 + 10.0
	for idx in range(int(z0 / Track.SEG_LEN), int(z1 / Track.SEG_LEN) + 1):
		if not items.has(idx):
			continue
		items[idx] = items[idx].filter(func(it): return not (it.type in CLEARABLE and signf(it.lat) == signf(lm.lat)
			and absf(it.lat) < far and it.z > z0 and it.z < z1))

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
			var type := "woodhouse" if wooden and rng.randf() < 0.7 else ("whitehouse" if biome == "mediterranean" else "house")
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
			if biome == "mountains" and rng.randf() < HERD_CHANCE * 0.3:
				_herd(items, z, rng, 3)
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
		"lava", "highland", "glacier", "fjords":
			return _iceland(items, biome, z, rng)
		"desert":
			return _desert(items, z, rng)
		"mediterranean":
			return _mediterranean(items, z, rng)
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
			elif r < 0.11 + HERD_CHANCE * 1.2: _herd(items, z, rng)
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
				elif r < 0.14 + HERD_CHANCE * 1.2: _herd(items, z, rng)
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

## Treeless north (Iceland): mossy lava fields, bare highlands, glacier plains, fjord shores; sheep and horses graze,
## a farm now and then. Returns the step length.
static func _iceland(items: Dictionary, biome: String, z: float, rng: RandomNumberGenerator) -> float:
	for side in [-1, 1]:
		if biome == "lava" and rng.randf() < 0.65:
			var w := rng.randf_range(3.0, 7.0)
			_add(items, "moss", z + rng.randf_range(-4, 4), side * rng.randf_range(7.8, 30.0), w, w * 0.22, rng)
		var rocky := {"lava": 0.18, "highland": 0.22, "glacier": 0.12, "fjords": 0.1}[biome] as float
		if rng.randf() < rocky:
			var w := rng.randf_range(1.5, 4.5)
			_add(items, "lavarock" if biome == "lava" else "rock", z, side * rng.randf_range(8.5, 40.0), w, w * rng.randf_range(0.5, 0.9), rng)
	var r := rng.randf()
	if r < 0.07: _flock(items, z, rng, "sheep", 7)
	elif r < 0.11 and biome != "highland": _flock(items, z, rng, "horse", 4)
	elif r < 0.14 and biome != "highland": _add(items, "house", z, _side(rng) * rng.randf_range(24.0, 45.0), 8.0, 6.5, rng)
	return rng.randf_range(10.0, 18.0)

## The open desert of the American Southwest: saguaros and low grey-green sagebrush far apart, red rocks, now and
## then a flat-topped mesa far off the road. Returns the step length.
static func _desert(items: Dictionary, z: float, rng: RandomNumberGenerator) -> float:
	for side in [-1, 1]:
		var r := rng.randf()
		if r < 0.2:
			_add(items, "cactus", z + rng.randf_range(-4, 4), side * rng.randf_range(9.0, 38.0), 1.5, rng.randf_range(5.0, 10.0), rng)
		elif r < 0.55:
			var w := rng.randf_range(1.6, 3.0)
			_add(items, "bush", z + rng.randf_range(-4, 4), side * rng.randf_range(7.8, 40.0), w, w * rng.randf_range(0.45, 0.6), rng)
		if rng.randf() < 0.08:
			var w := rng.randf_range(1.5, 5.0)
			_add(items, "redrock", z, side * rng.randf_range(10.0, 45.0), w, w * rng.randf_range(0.5, 0.9), rng)
	if rng.randf() < 0.03:
		_add(items, "mesa", z, _side(rng) * rng.randf_range(60.0, 150.0), rng.randf_range(40.0, 90.0), rng.randf_range(16.0, 32.0), rng)
	return rng.randf_range(12.0, 20.0)

## The Mediterranean: olive groves, dark cypresses, low maquis, dry-stone walls along the fields, now and then a
## white house with a flat or tiled roof and some rock. Returns the step length.
static func _mediterranean(items: Dictionary, z: float, rng: RandomNumberGenerator) -> float:
	var grove := _h(int(z / 260.0), 41) < 0.4
	for side in [-1, 1]:
		var r := rng.randf()
		if r < (0.75 if grove else 0.32):
			_add(items, "olive", z + rng.randf_range(-4, 4), side * rng.randf_range(8.5, 26.0), 3.6, rng.randf_range(4.0, 5.6), rng)
		elif r < (0.83 if grove else 0.5):
			_add(items, "cypress", z + rng.randf_range(-3, 3), side * rng.randf_range(7.8, 22.0), 1.6, rng.randf_range(8.0, 13.0), rng)
		elif r < 0.7:
			var w := rng.randf_range(1.8, 3.4)
			_add(items, "maquis", z + rng.randf_range(-4, 4), side * rng.randf_range(7.8, 34.0), w, w * rng.randf_range(0.45, 0.7), rng)
		if rng.randf() < 0.12:
			_add(items, "stonewall", z, side * rng.randf_range(10.5, 13.0), rng.randf_range(4.0, 8.0), 1.0, rng)
		if rng.randf() < 0.05:
			var w := rng.randf_range(1.5, 4.0)
			_add(items, "rock", z, side * rng.randf_range(10.0, 35.0), w, w * rng.randf_range(0.5, 0.9), rng)
	if rng.randf() < 0.04:
		_add(items, "whitehouse", z, _side(rng) * rng.randf_range(18.0, 40.0), rng.randf_range(6.0, 8.0), rng.randf_range(5.0, 6.5), rng)
	return rng.randf_range(11.0, 18.0)

## A flock of sheep or a few horses beside the road.
static func _flock(items: Dictionary, z: float, rng: RandomNumberGenerator, kind: String, most: int) -> void:
	var side := _side(rng)
	var lat := rng.randf_range(10.0, 24.0)
	for k in rng.randi_range(2, most):
		var a := _add(items, kind, z + rng.randf_range(-9.0, 9.0), side * (lat + rng.randf_range(-2.0, 6.0)), 1.6 if kind == "sheep" else 2.2, 1.0 if kind == "sheep" else 1.5, rng)
		a.v = rng.randf()

## A few cows grazing on a pasture beside the road (fewest in the mountains, most on the farmland).
static func _herd(items: Dictionary, z: float, rng: RandomNumberGenerator, most := 5) -> void:
	var side := _side(rng)
	var lat := rng.randf_range(10.5, 26.0)
	for k in rng.randi_range(1, most):
		var cow := _add(items, "cow", z + rng.randf_range(-9.0, 9.0), side * (lat + rng.randf_range(-2.5, 6.0)), 2.4, 1.5, rng)
		cow.v = rng.randf() # facing and pose

## Spruce share `spruce`, birch share `birch`, rest split between pine and broadleaf.
static func _forest_tree(rng: RandomNumberGenerator, spruce: float, birch := 0.1) -> String:
	var r := rng.randf()
	if r < spruce: return "spruce"
	if r < spruce + birch: return "birch"
	return "pine" if r < spruce + birch + (1.0 - spruce - birch) * 0.65 else "tree"

## Open farmland: tree-lined stretches, farms, hay bales, wind turbines, a stork now and then.
static func _fields(items: Dictionary, z: float, rng: RandomNumberGenerator, busy: float) -> float:
	if rng.randf() < HERD_CHANCE * busy:
		_herd(items, z, rng)
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
			_limit_sign(items, t.z - t.half + 15.0, Route.sign_limit_at(stage, t.z - t.half + 16.0), rng)
		if not t.get("finish", false):
			_limit_sign(items, t.z + t.half + 25.0, Route.sign_limit_at(stage, t.z + t.half + 30.0), rng)
	for i in range(1, stage.roads.size()):
		var zr: float = stage.roads[i].z0 + 20.0
		if stage.roads[i].lanes != stage.roads[i - 1].lanes and Route.town_at(stage, zr).is_empty():
			_limit_sign(items, zr, Route.sign_limit_at(stage, zr), rng)
	# where an Autobahn's limit ends or starts again away from towns (Germany)
	var zl := 40.0
	while zl < stage.length:
		var here := Route.sign_limit_at(stage, zl)
		if (here == Route.NO_LIMIT) != (Route.sign_limit_at(stage, zl - 20.0) == Route.NO_LIMIT) and Route.town_at(stage, zl).is_empty():
			_limit_sign(items, zl + 10.0, here, rng)
		zl += 20.0
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

## Warning signs before sharp bends (A-1/A-2 one bend right/left, A-3/A-4 two bends, first right/left) and red-white
## chevron boards (U-3a) on the outside of every sharp bend.
static func bend_signs(items: Dictionary, sharp: Array) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 991
	for b in sharp:
		var it := _add(items, "bend", b.z - Track.SIGN_BEFORE, SIGN_EDGE + 1.4, 2.6, 4.6, rng)
		it.dir = b.dir
		it.double = b.double
		_chevrons(items, b.z_hold, b.dir, rng)
		if b.double:
			_chevrons(items, b.z_hold2, -b.dir, rng)

## Three chevron boards on the outer edge of a bend, pointing the way it turns.
static func _chevrons(items: Dictionary, z: float, dir: float, rng: RandomNumberGenerator) -> void:
	for k in 3:
		_add(items, "chevron", z + k * 18.0, -dir * (SIGN_EDGE + 0.4), 1.8, 2.4, rng).dir = dir

static func _limit_sign(items: Dictionary, z: float, posted: int, rng: RandomNumberGenerator) -> void:
	_add(items, "limit", z, SIGN_EDGE + 1.4, 2.4, 4.4, rng).limit = posted

## Bend warning sign (A-1..A-4): yellow triangle with a red border and a black arrow bending dir (+1 right).
static func _bend_sign(cv, it: Dictionary, b: Vector2, pm: float) -> void:
	var top := 3.0 * pm
	var r := 1.35 * pm
	_posts(cv, b, pm, top, [0.0])
	var c := b + Vector2(0, -top - r * 0.75)
	var tri := func(k: float) -> PackedVector2Array:
		return PackedVector2Array([c + Vector2(0, -r * k), c + Vector2(r * 0.95 * k, r * 0.62 * k), c + Vector2(-r * 0.95 * k, r * 0.62 * k)])
	cv.draw_colored_polygon(tri.call(1.0), SIGN_RED)
	cv.draw_colored_polygon(tri.call(0.72), SIGN_YELLOW)
	if pm < 2.0:
		return
	var d: float = it.dir * flip
	var w := maxf(1.0, 0.13 * pm)
	var p0 := c + Vector2(-d * 0.18 * r, 0.42 * r)
	var pts := PackedVector2Array([p0, p0 + Vector2(0, -0.35 * r)])
	if it.double:
		pts.append(p0 + Vector2(d * 0.3 * r, -0.55 * r))
		pts.append(p0 + Vector2(d * 0.3 * r, -0.75 * r))
		pts.append(p0 + Vector2(0, -0.95 * r))
	else:
		pts.append(p0 + Vector2(d * 0.4 * r, -0.62 * r))
	for k in pts.size() - 1:
		cv.draw_line(pts[k], pts[k + 1], Color.BLACK, w)
	var tip := pts[pts.size() - 1]
	var dirv := (tip - pts[pts.size() - 2]).normalized()
	var side := Vector2(-dirv.y, dirv.x)
	cv.draw_colored_polygon(PackedVector2Array([tip + dirv * 0.16 * r, tip + side * 0.13 * r, tip - side * 0.13 * r]), Color.BLACK)

## Chevron board (U-3a): red with a white arrow pointing the way the road turns.
static func _chevron(cv, it: Dictionary, b: Vector2, pm: float) -> void:
	var post := 0.9 * pm
	var w := 1.4 * pm
	var h := 1.7 * pm
	_posts(cv, b, pm, post, [0.0])
	var r := Rect2(b + Vector2(-w * 0.5, -post - h), Vector2(w, h))
	cv.draw_rect(r, SIGN_RED)
	if pm < 1.5:
		return
	var d: float = it.dir * flip
	var c := r.get_center()
	var tip := c + Vector2(d * 0.22 * w, 0)
	var lw := maxf(1.0, 0.16 * w)
	cv.draw_line(c + Vector2(-d * 0.22 * w, -0.3 * h), tip, Color.WHITE, lw)
	cv.draw_line(tip, c + Vector2(-d * 0.22 * w, 0.3 * h), Color.WHITE, lw)

## Speed limit sign B-33: white disc, red ring, black number.
static func _limit(cv, it: Dictionary, b: Vector2, pm: float, font: Font) -> void:
	var r := 1.2 * pm
	var top := 3.0 * pm
	_posts(cv, b, pm, top, [0.0])
	var c := b + Vector2(0, -top - r)
	if it.limit == Route.NO_LIMIT:
		no_limit_disc(cv, c, r)
		return
	cv.draw_circle(c, r, SIGN_RED)
	cv.draw_circle(c, r * 0.78, Color.WHITE)
	_fit_text(cv, font, Rect2(c - Vector2(r * 0.7, r * 0.5), Vector2(r * 1.4, r)), str(it.limit), Color.BLACK, 0.9 * pm)

## End of all restrictions (German Zeichen 282): a white disc with a thin grey rim and black diagonal stripes.
static func no_limit_disc(cv, c: Vector2, r: float) -> void:
	cv.draw_circle(c, r, Color("8a8d92"))
	cv.draw_circle(c, r * 0.93, Color.WHITE)
	var d := Vector2(1, -1).normalized() # stripes from bottom-left to top-right
	var n := Vector2(d.y, -d.x)
	for k in 5:
		var off := (k - 2) * 0.16 * r
		var half := sqrt(maxf(0.0, (r * 0.86) * (r * 0.86) - off * off))
		cv.draw_line(c + n * off - d * half, c + n * off + d * half, Color.BLACK, maxf(1.0, r * 0.07))

## Flat strips beside the road for every track segment: [lat0, lat1, colour id, ...] (negative lat = left).
static func ground(stage: Dictionary, nseg: int) -> Array:
	var out := []
	out.resize(nseg)
	for i in nseg:
		var z := i * Track.SEG_LEN
		var s := PackedFloat32Array()
		var ls := Track.left_shift(Route.dual_f(stage, z))
		if on_pier(stage, z):
			s.append_array([-400.0 - ls, -QUAY_EDGE - ls, G_WATER, -QUAY_EDGE - ls, -4.8 - ls, G_PAVE, 4.8, QUAY_EDGE, G_PAVE, QUAY_EDGE, 400.0, G_WATER])
			out[i] = s
			continue
		if not Route.town_at(stage, z).is_empty():
			s.append_array([-7.4 - ls, -4.8 - ls, G_PAVE, 4.8, 7.4, G_PAVE])
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
				"lava", "glacier":
					# dark lava and black sand between the moss
					if _h(int(z / 70.0), side * 13) < 0.5:
						s.append_array([side * 9.0, side * 60.0, G_DARK])
				"desert":
					# patches of redder sand among the tan
					var blk := int(z / 80.0)
					if _h(blk, side * 19) < 0.4:
						var a := 8.5 + 25.0 * _h(blk, side * 23)
						s.append_array([side * a, side * (a + 25.0 + 90.0 * _h(blk, side * 29)), G_REDSAND])
				"fjords":
					if side == -1 and _h(int(z / 300.0), 17) < 0.65:
						s.append_array([side * 13.0, side * 400.0, G_WATER])
		if ls > 0.0:
			for g in range(0, s.size(), 3):
				if s[g] < 0.0:
					s[g] -= ls
					s[g + 1] -= ls
		out[i] = s
	return out

## True on a ferry port's pier: the quay up to the barrier, and the far quay around the ramp.
static func on_pier(stage: Dictionary, z: float) -> bool:
	for f in stage.get("ferries", []):
		if (z >= f.z - Route.FERRY_QUAY and z < f.z) or (z >= f.z_out - 30.0 and z < f.z_out + 70.0):
			return true
	return false

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
			cv.draw_rect(Rect2(b + Vector2(-0.4 * pm if it.lat * flip > 0 else -0.1 * pm, -h), Vector2(0.9 * pm, 0.35 * pm)), Color("3b3f45"))
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
		"cow": _cow(cv, it, b, pm, season)
		"sheep": _sheep(cv, it, b, pm, season)
		"horse": _horse(cv, it, b, pm, season)
		"moss": _moss(cv, it, b, pm, season)
		"lavarock": _lavarock(cv, it, b, h, pm)
		"cactus": _cactus(cv, it, b, h, pm)
		"bush": _bush(cv, it, b, h, pm, season)
		"redrock": _redrock(cv, it, b, h, pm)
		"mesa": _mesa(cv, it, b, h, pm, season)
		"olive": _olive(cv, it, b, h, pm)
		"cypress": _cypress(cv, it, b, h, pm)
		"maquis": _maquis(cv, it, b, h, pm)
		"stonewall": _stonewall(cv, it, b, h, pm)
		"whitehouse": _whitehouse(cv, it, b, pm)
		"town_sign", "town_end": _town_sign(cv, it, b, pm, font, it.type == "town_end")
		"board": _board(cv, it, b, pm, font)
		"limit": _limit(cv, it, b, pm, font)
		"bend": _bend_sign(cv, it, b, pm)
		"chevron": _chevron(cv, it, b, pm)
		"region": _region(cv, it, b, pm, font)
		"landmark": LandmarkPainter.draw(cv, it, b, pm)
		"poi": _poi(cv, it, b, pm, font)
		"station_sign": _station_sign(cv, b, pm)
		"pylon": _pylon(cv, it, b, pm, font)
		"pump": _pump(cv, b, pm)
		"canopy": _canopy(cv, it, b, pm, font)
		"barrier": _barrier(cv, it, b, pm)
		"booth": _booth(cv, it, b, pm)
		"radar": _radar(cv, b, pm)
		"border_board": _border_board(cv, it, b, pm, font)
		"ferry_sign": _ferry_sign(cv, it, b, pm, font)
		"ferry_ship": _ferry_ship(cv, it, b, pm, font)
		"quay": _quay_item(cv, it, b, pm)
		"border_canopy": pass # drawn across the road by WorldView
		"shop": _shop(cv, it, b, pm)
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
	var out := ["0123456789"]
	var parts := [stage.get("part0", "")]
	for bd in stage.get("borders", []):
		if not parts.has(bd.to): parts.append(bd.to)
		out.append(bd.name)
		out.append(Geo.part(bd.to).name)
	for p in parts:
		var stn := Geo.station(p)
		out.append_array([stn.region_sign, stn.board, stn.sign])
		out.append_array(price_rows(p))
		for k in Geo.limits(p): out.append(str(Geo.limits(p)[k]))
	for t in stage.towns: out.append(t.name)
	for f in stage.get("ferries", []): out.append(f.name)
	for zn in stage.zones:
		if not out.has(zn.region): out.append(zn.region)
	for r in stage.roads: out.append(plate(r.road)[0])
	for n in out.duplicate():
		if n is String and Geo.native(n) != "": out.append(Geo.native(n)) # bilingual signs: the native spelling beside each name
	for lm in Landmarks.place(stage): out.append(lm.local)
	return out

## Draws texts at every sign size far off-screen, so glyph rasterisation happens during the countdown
## instead of as a stutter when a sign comes close.
static func warm_text(cv: CanvasItem, font: Font, texts: Array) -> void:
	for text in texts:
		for fs in TEXT_SIZES:
			font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
			cv.draw_string(font, Vector2(-5000, -5000), text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)

static func _posts(cv, b: Vector2, pm: float, top: float, xs: Array) -> void:
	for x in xs:
		cv.draw_line(b + Vector2(x * pm, 0), b + Vector2(x * pm, -top), Color("8a8d92"), maxf(1.0, 0.14 * pm))

## A name in a rectangle: with a native spelling (Geo.native) that on top and the Latin one below it, smaller (~70%),
## the same colour; without one the Latin name alone.
static func _name_lines(cv, font: Font, r: Rect2, text: String, col: Color, size: float, align := HORIZONTAL_ALIGNMENT_CENTER) -> void:
	var nat := Geo.native(text)
	if nat == "":
		_fit_text(cv, font, r, text, col, size, align)
		return
	_fit_text(cv, font, Rect2(r.position, Vector2(r.size.x, r.size.y * 0.55)), nat, col, size * 0.8, align)
	_fit_text(cv, font, Rect2(r.position + Vector2(0, r.size.y * 0.52), Vector2(r.size.x, r.size.y * 0.46)), text, col, size * 0.56, align)

## E-17a (entering) and E-18a (leaving, red diagonal bar): green board, white border and name.
static func _town_sign(cv, it: Dictionary, b: Vector2, pm: float, font: Font, ending: bool) -> void:
	var post := 3.0 * pm
	var w := TOWN_SIGN_W * pm
	var hh := (2.4 if Geo.native(it.text) != "" else 1.8) * pm # two lines of name: a taller board
	_posts(cv, b, pm, post, [-1.6, 1.6])
	var r := Rect2(b + Vector2(-w * 0.5, -post - hh), Vector2(w, hh))
	var p: String = it.get("p", "")
	var ink := sign_color("town_text", p)
	cv.draw_rect(r, sign_color("town", p))
	cv.draw_rect(r.grow(-0.14 * pm), ink, false, maxf(1.0, 0.1 * pm))
	_name_lines(cv, font, r.grow_individual(-0.35 * pm, -0.3 * pm, -0.35 * pm, -0.3 * pm), it.text, ink, 0.95 * pm)
	if ending:
		cv.draw_line(r.position + Vector2(w * 0.08, hh * 0.85), r.position + Vector2(w * 0.92, hh * 0.15), SIGN_RED, maxf(1.0, 0.24 * pm))

## Distance board: road number on a red plate, then towns with kilometres (nearest first, destination last).
## Colours from the country (in Poland blue on motorways, green on other roads).
static func _board(cv, it: Dictionary, b: Vector2, pm: float, font: Font) -> void:
	var lines: Array = it.lines
	var two := false # a native name on the board: taller rows, the native name over the Latin one
	var nats: Array = []
	for l in lines:
		nats.append(Geo.native(l[0]))
		if nats[-1] != "": two = true
	var lh := (2.1 if two else 1.45) * pm
	var w := BOARD_W * pm
	var head := 1.5 * pm if it.road != "" else 0.25 * pm
	var hh := head + lh * lines.size() + 0.3 * pm
	var post := 3.0 * pm
	_posts(cv, b, pm, post, [-3.5, 3.5])
	var r := Rect2(b + Vector2(-w * 0.5, -post - hh), Vector2(w, hh))
	var p: String = it.get("p", "")
	cv.draw_rect(r, sign_color("board_motorway" if it.blue else "board", p))
	var ink := Color.WHITE if it.blue else sign_color("board_text", p)
	cv.draw_rect(r.grow(-0.14 * pm), ink, false, maxf(1.0, 0.1 * pm))
	if it.road != "":
		var pl := plate(it.road, p)
		var pr := Rect2(r.position + Vector2(w * 0.5 - 1.2 * pm, 0.3 * pm), Vector2(2.4 * pm, 1.0 * pm))
		cv.draw_rect(pr, pl[1])
		_fit_text(cv, font, pr, pl[0], pl[2], 0.8 * pm)
	for i in lines.size():
		var row := Rect2(r.position + Vector2(0.5 * pm, head + lh * i), Vector2(w - 1.0 * pm, lh))
		if nats[i] != "":
			var nat: String = nats[i]
			_fit_text(cv, font, Rect2(row.position, Vector2(row.size.x * 0.78, lh * 0.55)), nat, ink, 0.72 * pm, HORIZONTAL_ALIGNMENT_LEFT)
			_fit_text(cv, font, Rect2(row.position + Vector2(0, lh * 0.52), Vector2(row.size.x * 0.78, lh * 0.46)), lines[i][0], ink, 0.52 * pm, HORIZONTAL_ALIGNMENT_LEFT)
		else:
			_fit_text(cv, font, Rect2(row.position, Vector2(row.size.x * 0.78, lh)), lines[i][0], ink, 0.85 * pm, HORIZONTAL_ALIGNMENT_LEFT)
		_fit_text(cv, font, row, str(lines[i][1]), ink, 0.85 * pm, HORIZONTAL_ALIGNMENT_RIGHT)

## Brown tourist board with the name of the region being entered, the country's flag in its corner.
static func _region(cv, it: Dictionary, b: Vector2, pm: float, font: Font) -> void:
	var post := 2.8 * pm
	var w := REGION_W * pm
	var nat := Geo.native(it.text) != ""
	var hh := (3.0 if nat else 2.2) * pm # taller with a native name: two lines of name
	_posts(cv, b, pm, post, [-3.0, 3.0])
	var r := Rect2(b + Vector2(-w * 0.5, -post - hh), Vector2(w, hh))
	cv.draw_rect(r, SIGN_BROWN)
	cv.draw_rect(r.grow(-0.14 * pm), Color.WHITE, false, maxf(1.0, 0.1 * pm))
	var fl := Vector2(1.05 * pm, 0.7 * pm) # the country's flag before "WELCOME TO"
	if fl.x >= 3.0:
		var code: String = it.get("p", "")
		FlagPainter.draw(cv, code if code != "" else GameData.current, Rect2(r.position + Vector2(0.35 * pm, 0.18 * pm), fl))
	_fit_text(cv, font, Rect2(r.position + Vector2(0.55 * pm + fl.x, (0.3 if nat else 0.1) * pm), Vector2(w - 0.9 * pm - fl.x, (0.7 * pm if nat else hh * 0.42))), Geo.station(it.get("p", "")).region_sign, Color("f1d9b5"), 0.55 * pm)
	_name_lines(cv, font, Rect2(r.position + Vector2(0.35 * pm, 1.0 * pm if nat else hh * 0.42), Vector2(w - 0.7 * pm, 1.8 * pm if nat else hh * 0.52)), it.text, Color.WHITE, 0.8 * pm)

## Brown tourist board (E-22c style) naming the landmark next to it.
static func _poi(cv, it: Dictionary, b: Vector2, pm: float, font: Font) -> void:
	var post := 2.8 * pm
	var w := REGION_W * pm
	var hh := 1.7 * pm
	_posts(cv, b, pm, post, [-3.0, 3.0])
	var r := Rect2(b + Vector2(-w * 0.5, -post - hh), Vector2(w, hh))
	cv.draw_rect(r, SIGN_BROWN)
	cv.draw_rect(r.grow(-0.14 * pm), Color.WHITE, false, maxf(1.0, 0.1 * pm))
	_fit_text(cv, font, r.grow_individual(-0.35 * pm, 0, -0.35 * pm, 0), it.text, Color.WHITE, 0.8 * pm)

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
## Cow seen from the side, black-and-white or brown, grazing (head down) or looking up. Kept in the barn in winter.
static func _cow(cv, it: Dictionary, b: Vector2, pm: float, season: String) -> void:
	if season == "winter" or pm < 1.0:
		return
	var f := 1.0 if it.v < 0.5 else -1.0 # facing right or left
	var brown: bool = it.c % 3 == 0
	var body := Color("8a5a3a") if brown else Color("f4f2ee")
	var patch := Color("5e3a24") if brown else Color("1f1f22")
	var leg := Color("3a2a20") if brown else Color("2a2a2c")
	var p := func(x: float, y: float) -> Vector2: return b + Vector2(f * x * pm, -y * pm)
	for lx in [-0.85, -0.6, 0.55, 0.8]:
		cv.draw_line(p.call(lx, 0.0), p.call(lx, 0.8), leg, maxf(1.0, 0.16 * pm))
	cv.draw_rect(Rect2(b + Vector2(minf(f * -1.0, f * 1.0) * pm, -1.45 * pm), Vector2(2.0 * pm, 0.75 * pm)), body)
	if pm > 2.0:
		cv.draw_circle(p.call(-0.35, 1.15), 0.28 * pm, patch)
		cv.draw_circle(p.call(0.4, 1.05), 0.22 * pm, patch)
		cv.draw_circle(b + Vector2(0, -0.7 * pm), 0.14 * pm, Color("f0a8a8")) # udder
	var grazing: bool = it.v < 0.25 or it.v > 0.75
	var head: Vector2 = p.call(1.25, 0.55 if grazing else 1.45)
	cv.draw_line(p.call(0.95, 1.25), head, body, maxf(1.0, 0.35 * pm))
	cv.draw_circle(head, 0.26 * pm, patch if not brown else body.darkened(0.15))
	if pm > 3.0:
		cv.draw_line(head + Vector2(-f * 0.1 * pm, -0.2 * pm), head + Vector2(-f * 0.25 * pm, -0.4 * pm), Color("e8e0c8"), maxf(1.0, 0.06 * pm))
		cv.draw_line(p.call(-1.0, 1.35), p.call(-1.15, 0.75), patch, maxf(1.0, 0.06 * pm)) # tail

## Icelandic sheep: a woolly white (or dark) body on short legs. Indoors in winter.
static func _sheep(cv, it: Dictionary, b: Vector2, pm: float, season: String) -> void:
	if season == "winter" or pm < 1.2:
		return
	var f := 1.0 if it.v < 0.5 else -1.0
	var wool := Color("3a3330") if it.c == 0 else (Color("8a7a68") if it.c == 1 else Color("efece4"))
	for lx in [-0.45, 0.4]:
		cv.draw_line(b + Vector2(f * lx * pm, 0), b + Vector2(f * lx * pm, -0.45 * pm), Color("2a2624"), maxf(1.0, 0.12 * pm))
	cv.draw_set_transform(b + Vector2(0, -0.75 * pm), 0.0, Vector2(1.0, 0.62))
	cv.draw_circle(Vector2.ZERO, 0.62 * pm, wool)
	cv.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	cv.draw_circle(b + Vector2(f * 0.72 * pm, -(0.6 if it.v < 0.3 or it.v > 0.7 else 0.95) * pm), 0.2 * pm, Color("2a2624"))

## Icelandic horse: small and stocky, with a long mane. In the stable on a snowy day.
static func _horse(cv, it: Dictionary, b: Vector2, pm: float, season: String) -> void:
	if season == "winter" or pm < 1.0:
		return
	var f := 1.0 if it.v < 0.5 else -1.0
	var coat: Color = [Color("8a4b2a"), Color("5a3a24"), Color("e8e2d4"), Color("b8864a"), Color("3a302a")][it.c % 5]
	var mane := coat.darkened(0.45) if it.c % 5 != 2 else Color("cfc8b8")
	var p := func(x: float, y: float) -> Vector2: return b + Vector2(f * x * pm, -y * pm)
	for lx in [-0.75, -0.5, 0.5, 0.75]:
		cv.draw_line(p.call(lx, 0.0), p.call(lx, 0.75), coat.darkened(0.2), maxf(1.0, 0.13 * pm))
	cv.draw_rect(Rect2(b + Vector2(-0.95 * pm, -1.35 * pm), Vector2(1.9 * pm, 0.65 * pm)), coat)
	var grazing: bool = it.v < 0.25 or it.v > 0.75
	var head: Vector2 = p.call(1.25, 0.45 if grazing else 1.65)
	cv.draw_line(p.call(0.85, 1.2), head, coat, maxf(1.0, 0.32 * pm))
	cv.draw_circle(head, 0.22 * pm, coat)
	if pm > 2.5:
		cv.draw_line(p.call(0.8, 1.4), head + Vector2(-f * 0.1 * pm, -0.15 * pm), mane, maxf(1.0, 0.12 * pm))
		cv.draw_line(p.call(-0.95, 1.25), p.call(-1.15, 0.5), mane, maxf(1.0, 0.14 * pm)) # tail

## Woolly moss on old lava: a low green-grey mound (snow-covered in winter).
static func _moss(cv, it: Dictionary, b: Vector2, pm: float, season: String) -> void:
	var w: float = it.w * pm
	var h: float = maxf(it.h * pm, 1.0)
	var col := Color("eef1f3") if season == "winter" else (Color("8a8a52") if season == "autumn" else Color("7d9a5a"))
	cv.draw_colored_polygon(PackedVector2Array([b + Vector2(-w * 0.5, 0), b + Vector2(-w * 0.3, -h * 0.8), b + Vector2(0, -h),
		b + Vector2(w * 0.3, -h * 0.75), b + Vector2(w * 0.5, 0)]), col)

## Jagged black lava rock.
static func _lavarock(cv, it: Dictionary, b: Vector2, h: float, pm: float) -> void:
	var w: float = it.w * pm
	cv.draw_colored_polygon(PackedVector2Array([b + Vector2(-w * 0.5, 0), b + Vector2(-w * 0.35, -h * 0.7), b + Vector2(-w * 0.1, -h),
		b + Vector2(w * 0.15, -h * 0.65), b + Vector2(w * 0.35, -h * 0.9), b + Vector2(w * 0.5, 0)]), Color("37322f"))
	cv.draw_colored_polygon(PackedVector2Array([b + Vector2(w * 0.15, 0), b + Vector2(w * 0.15, -h * 0.65), b + Vector2(w * 0.35, -h * 0.9),
		b + Vector2(w * 0.5, 0)]), Color("27231f"))

## Saguaro: a ribbed green column with one to three arms turned up, rounded at the tops.
static func _cactus(cv, it: Dictionary, b: Vector2, h: float, pm: float) -> void:
	var w: float = it.w * pm
	var tw := maxf(1.0, w * 0.36)
	var aw := maxf(1.0, tw * 0.72)
	var col := Color("4f8a3c")
	var dark := Color("3c6e2e")
	var arms := 1 + mini(int(it.v * 3.0), 2)
	var first := 1.0 if fmod(it.v * 7.0, 1.0) < 0.5 else -1.0
	for k in arms:
		var s := first if k % 2 == 0 else -first
		var ya := h * (0.36 + 0.13 * k)
		var top := ya + h * (0.24 - 0.05 * k)
		var ax := s * (w * 0.5 - aw * 0.5)
		cv.draw_line(b + Vector2(0, -ya), b + Vector2(ax, -ya), col, aw)
		cv.draw_circle(b + Vector2(ax, -ya), aw * 0.5, col)
		cv.draw_line(b + Vector2(ax, -ya), b + Vector2(ax, -top), col, aw)
		cv.draw_circle(b + Vector2(ax, -top), aw * 0.5, col)
		if pm > 4.0:
			cv.draw_line(b + Vector2(ax + aw * 0.2, -ya), b + Vector2(ax + aw * 0.2, -top), dark, maxf(1.0, aw * 0.2))
	cv.draw_rect(Rect2(b + Vector2(-tw * 0.5, -h + tw * 0.5), Vector2(tw, h - tw * 0.5)), col)
	cv.draw_circle(b + Vector2(0, -h + tw * 0.5), tw * 0.5, col)
	cv.draw_rect(Rect2(b + Vector2(tw * 0.18, -h + tw * 0.5), Vector2(tw * 0.32, h - tw * 0.5)), dark)
	if pm > 3.0:
		cv.draw_line(b + Vector2(-tw * 0.12, -h + tw * 0.4), b + Vector2(-tw * 0.12, 0), dark, maxf(1.0, tw * 0.08))

## Sagebrush or creosote: a low grey-green tuft.
static func _bush(cv, it: Dictionary, b: Vector2, h: float, pm: float, season: String) -> void:
	var w: float = it.w * pm
	var col := Color("9aa088") if season == "winter" else Color("8c9a6c")
	var dark := col.darkened(0.2)
	var r := maxf(1.0, minf(w * 0.3, h * 0.6))
	cv.draw_circle(b + Vector2(-w * 0.22, -r * 0.8), r * 0.85, dark)
	cv.draw_circle(b + Vector2(w * 0.22, -r * 0.8), r * 0.85, dark)
	cv.draw_circle(b + Vector2(0, -r * 1.05), r, col)
	cv.draw_rect(Rect2(b + Vector2(-w * 0.4, -r * 0.6), Vector2(w * 0.8, r * 0.6)), dark)

## Red sandstone boulder.
static func _redrock(cv, it: Dictionary, b: Vector2, h: float, pm: float) -> void:
	var w: float = it.w * pm
	cv.draw_colored_polygon(PackedVector2Array([b + Vector2(-w * 0.5, 0), b + Vector2(-w * 0.45, -h * 0.55), b + Vector2(-w * 0.2, -h),
		b + Vector2(w * 0.2, -h * 0.95), b + Vector2(w * 0.42, -h * 0.6), b + Vector2(w * 0.5, 0)]), Color("c0683f"))
	cv.draw_colored_polygon(PackedVector2Array([b + Vector2(w * 0.1, 0), b + Vector2(w * 0.2, -h * 0.95), b + Vector2(w * 0.42, -h * 0.6),
		b + Vector2(w * 0.5, 0)]), Color("98492c"))

## Mesa or butte far off the road: red cliffs under a flat cap rock, a scree slope at the foot, banded rock.
static func _mesa(cv, it: Dictionary, b: Vector2, h: float, pm: float, season: String) -> void:
	var w: float = it.w * pm
	var rock := Color("b4623c")
	var shade := Color("8f4a2e")
	var cap := Color("eef1f3") if season == "winter" else Color("c97d50")
	var base := PackedVector2Array([b + Vector2(-w * 0.5, 0), b + Vector2(-w * 0.36, -h * 0.4), b + Vector2(-w * 0.32, -h),
		b + Vector2(w * 0.3, -h), b + Vector2(w * 0.35, -h * 0.4), b + Vector2(w * 0.5, 0)])
	cv.draw_colored_polygon(base, rock)
	cv.draw_colored_polygon(PackedVector2Array([b + Vector2(w * 0.18, 0), b + Vector2(w * 0.2, -h), b + Vector2(w * 0.3, -h),
		b + Vector2(w * 0.35, -h * 0.4), b + Vector2(w * 0.5, 0)]), shade)
	for k in 2:
		var y := h * (0.55 + 0.17 * k)
		cv.draw_line(b + Vector2(-w * 0.33, -y), b + Vector2(w * 0.18, -y), rock.darkened(0.12), maxf(1.0, h * 0.03))
	cv.draw_rect(Rect2(b + Vector2(-w * 0.32, -h), Vector2(w * 0.62, maxf(1.0, h * 0.08))), cap)

## Olive tree: a short gnarled trunk under a wide, silvery grey-green crown (evergreen, in every season).
static func _olive(cv, it: Dictionary, b: Vector2, h: float, pm: float) -> void:
	var w: float = it.w * pm
	var tw := maxf(1.0, w * 0.1)
	var bark := Color("6b5a48")
	cv.draw_line(b, b + Vector2(-tw * 0.4, -h * 0.5), bark, tw)
	cv.draw_line(b + Vector2(-tw * 0.2, -h * 0.35), b + Vector2(w * 0.12, -h * 0.62), bark, maxf(1.0, tw * 0.7))
	var col := Color("7f9170")
	var r := minf(w * 0.3, h * 0.36)
	cv.draw_circle(b + Vector2(-w * 0.2, -h * 0.66), r * 0.85, col.darkened(0.15))
	cv.draw_circle(b + Vector2(w * 0.22, -h * 0.64), r * 0.85, col.darkened(0.08))
	cv.draw_circle(b + Vector2(0, -h * 0.8), r, col)
	cv.draw_circle(b + Vector2(w * 0.05, -h * 0.86), r * 0.55, col.lightened(0.18))

## Cypress: a tall, narrow, dark flame.
static func _cypress(cv, it: Dictionary, b: Vector2, h: float, pm: float) -> void:
	var w: float = it.w * pm
	var col := Color("2f4a34")
	cv.draw_rect(Rect2(b + Vector2(-w * 0.04, -h * 0.1), Vector2(w * 0.08, h * 0.1)), Color("4f3a2a"))
	cv.draw_colored_polygon(PackedVector2Array([b + Vector2(-w * 0.3, -h * 0.1), b + Vector2(-w * 0.5, -h * 0.4), b + Vector2(-w * 0.32, -h * 0.75),
		b + Vector2(0, -h), b + Vector2(w * 0.32, -h * 0.75), b + Vector2(w * 0.5, -h * 0.4), b + Vector2(w * 0.3, -h * 0.1)]), col)
	cv.draw_colored_polygon(PackedVector2Array([b + Vector2(w * 0.05, -h * 0.12), b + Vector2(w * 0.3, -h * 0.4), b + Vector2(w * 0.2, -h * 0.75),
		b + Vector2(0, -h), b + Vector2(w * 0.32, -h * 0.75), b + Vector2(w * 0.5, -h * 0.4), b + Vector2(w * 0.3, -h * 0.1)]), col.lightened(0.1))

## Maquis: a low dark-green tangle of shrubs.
static func _maquis(cv, it: Dictionary, b: Vector2, h: float, pm: float) -> void:
	var w: float = it.w * pm
	var col := Color("55703f")
	var r := maxf(1.0, minf(w * 0.3, h * 0.65))
	cv.draw_circle(b + Vector2(-w * 0.24, -r * 0.7), r * 0.8, col.darkened(0.2))
	cv.draw_circle(b + Vector2(w * 0.24, -r * 0.7), r * 0.8, col.darkened(0.1))
	cv.draw_circle(b + Vector2(0, -r), r, col)
	cv.draw_circle(b + Vector2(w * 0.08, -r * 1.2), r * 0.45, Color("a58aa0") if it.v < 0.25 else col.lightened(0.15))
	cv.draw_rect(Rect2(b + Vector2(-w * 0.42, -r * 0.5), Vector2(w * 0.84, r * 0.5)), col.darkened(0.2))

## Dry-stone wall: a low run of loose pale stones, seen side-on.
static func _stonewall(cv, it: Dictionary, b: Vector2, h: float, pm: float) -> void:
	var w: float = it.w * pm
	var hh := maxf(1.0, h * 0.9)
	var stone := Color("b9ad93")
	cv.draw_rect(Rect2(b + Vector2(-w * 0.5, -hh), Vector2(w, hh)), stone)
	cv.draw_rect(Rect2(b + Vector2(-w * 0.5, -hh), Vector2(w, maxf(1.0, hh * 0.18))), stone.lightened(0.15))
	if pm > 3.0:
		var n := int(w / (pm * 0.9))
		for k in n:
			var x := -w * 0.5 + (k + 0.5) * w / n
			cv.draw_line(b + Vector2(x, -hh * 0.82), b + Vector2(x, -hh * 0.5), stone.darkened(0.25), maxf(1.0, pm * 0.06))
			cv.draw_line(b + Vector2(x + w / n * 0.5, -hh * 0.5), b + Vector2(x + w / n * 0.5, 0), stone.darkened(0.25), maxf(1.0, pm * 0.06))
		cv.draw_line(b + Vector2(-w * 0.5, -hh * 0.5), b + Vector2(w * 0.5, -hh * 0.5), stone.darkened(0.25), maxf(1.0, pm * 0.06))

## White house: whitewashed walls, a low terracotta roof or a flat one with a parapet, blue shutters.
static func _whitehouse(cv, it: Dictionary, b: Vector2, pm: float) -> void:
	var w: float = it.w * pm
	var h: float = it.h * pm
	var wall := Color("f4f1ea")
	cv.draw_rect(Rect2(b + Vector2(-w * 0.5, -h * 0.7), Vector2(w, h * 0.7)), wall)
	cv.draw_rect(Rect2(b + Vector2(w * 0.2, -h * 0.7), Vector2(w * 0.3, h * 0.7)), wall.darkened(0.1))
	if it.v < 0.5:
		cv.draw_colored_polygon(PackedVector2Array([b + Vector2(-w * 0.58, -h * 0.7), b + Vector2(w * 0.58, -h * 0.7), b + Vector2(w * 0.3, -h * 0.95), b + Vector2(-w * 0.3, -h * 0.95)]), Color("b8553a"))
	else:
		cv.draw_rect(Rect2(b + Vector2(-w * 0.54, -h * 0.78), Vector2(w * 1.08, h * 0.08)), wall.darkened(0.04))
	cv.draw_rect(Rect2(b + Vector2(-w * 0.34, -h * 0.5), Vector2(w * 0.2, h * 0.24)), Color("3f6fa0"))
	cv.draw_rect(Rect2(b + Vector2(-w * 0.08, -h * 0.34), Vector2(w * 0.2, h * 0.34)), Color("3f6fa0"))

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

const STATION_COLOR := Color("1f9d55") ## station brand colour (canopy stripe, pylon)

## D-23 "stacja paliw": blue board, white panel with a black fuel pump.
static func _station_sign(cv, b: Vector2, pm: float) -> void:
	var top := 2.8 * pm
	var w := 1.8 * pm
	var h := 2.3 * pm
	_posts(cv, b, pm, top, [0.0])
	var r := Rect2(b + Vector2(-w * 0.5, -top - h), Vector2(w, h))
	cv.draw_rect(r, SIGN_BLUE)
	var wr := Rect2(r.position + Vector2(0.22 * pm, 0.22 * pm), Vector2(w - 0.44 * pm, h * 0.62))
	cv.draw_rect(wr, Color.WHITE)
	if pm < 2.0:
		return
	var c := wr.get_center()
	var pw := wr.size.x * 0.34
	var ph := wr.size.y * 0.66
	cv.draw_rect(Rect2(c + Vector2(-pw * 0.7, -ph * 0.5), Vector2(pw, ph)), Color.BLACK)
	cv.draw_rect(Rect2(c + Vector2(-pw * 0.55, -ph * 0.38), Vector2(pw * 0.7, ph * 0.25)), Color.WHITE)
	var lw := maxf(1.0, 0.08 * pm)
	cv.draw_line(c + Vector2(pw * 0.3, -ph * 0.3), c + Vector2(pw * 0.75, -ph * 0.1), Color.BLACK, lw)
	cv.draw_line(c + Vector2(pw * 0.75, -ph * 0.1), c + Vector2(pw * 0.75, ph * 0.3), Color.BLACK, lw)

## Tall price pylon, seen from far away.
static func _pylon(cv, it: Dictionary, b: Vector2, pm: float, font: Font) -> void:
	var h := 13.0 * pm
	var w := 3.2 * pm
	cv.draw_rect(Rect2(b + Vector2(-0.3 * pm, -h), Vector2(0.6 * pm, h)), Color("55595f"))
	var r := Rect2(b + Vector2(-w * 0.5, -h - 4.2 * pm), Vector2(w, 5.4 * pm))
	cv.draw_rect(r, STATION_COLOR)
	cv.draw_rect(Rect2(r.position + Vector2(0.2 * pm, 0.2 * pm), Vector2(w - 0.4 * pm, 1.4 * pm)), SIGN_YELLOW)
	_fit_text(cv, font, Rect2(r.position + Vector2(0.25 * pm, 0.2 * pm), Vector2(w - 0.5 * pm, 1.4 * pm)), Geo.station(it.get("p", "")).board, Color("1d1d1f"), 0.75 * pm)
	var prices: Array = price_rows(it.get("p", ""))
	for k in mini(prices.size(), 3):
		var row := Rect2(r.position + Vector2(0.25 * pm, (1.95 + k * 1.1) * pm), Vector2(w - 0.5 * pm, 0.85 * pm))
		cv.draw_rect(row, Color("10161c"))
		_fit_text(cv, font, row, prices[k], Color("ffd24a"), 0.6 * pm)

## The station's price list rows, "95  6,49".
static func price_rows(p := "") -> Array:
	return Geo.station(p).prices.map(func(p): return "%s  %s" % [p[0], p[1]])

## Fuel dispenser on its island.
static func _pump(cv, b: Vector2, pm: float) -> void:
	var w := 1.1 * pm
	var h := 2.2 * pm
	cv.draw_rect(Rect2(b + Vector2(-w * 0.8, -0.2 * pm), Vector2(w * 1.6, 0.2 * pm)), Color("b7bbc0"))
	cv.draw_rect(Rect2(b + Vector2(-w * 0.5, -h), Vector2(w, h)), Color("f4f5f6"))
	cv.draw_rect(Rect2(b + Vector2(-w * 0.5, -h), Vector2(w, h * 0.18)), STATION_COLOR)
	cv.draw_rect(Rect2(b + Vector2(-w * 0.32, -h * 0.72), Vector2(w * 0.64, h * 0.2)), Color("10161c"))
	if pm > 3.0:
		cv.draw_line(b + Vector2(-w * 0.5, -h * 0.45), b + Vector2(-w * 0.85, -h * 0.2), Color("1d1d1f"), maxf(1.0, 0.08 * pm))

## Canopy over the pumps: a white roof with the brand stripe and lights underneath, on two pillars.
static func _canopy(cv, it: Dictionary, b: Vector2, pm: float, font: Font) -> void:
	var w := 12.0 * pm
	var top := 6.8 * pm
	var th := 1.5 * pm
	for px in [-3.6, 3.6]:
		cv.draw_rect(Rect2(b + Vector2(px * pm - 0.25 * pm, -top + th), Vector2(0.5 * pm, top - th)), Color("d6d9dd"))
	var r := Rect2(b + Vector2(-w * 0.5, -top), Vector2(w, th))
	cv.draw_rect(r, Color("f7f8f9"))
	cv.draw_rect(Rect2(r.position + Vector2(0, th * 0.55), Vector2(w, th * 0.3)), STATION_COLOR)
	cv.draw_rect(Rect2(r.position + Vector2(0, th), Vector2(w, 0.12 * pm)), Color("fff6c8"))
	_fit_text(cv, font, Rect2(r.position, Vector2(w, th * 0.55)), Geo.station(it.get("p", "")).sign, STATION_COLOR, 0.7 * pm)

## Station shop behind the pumps.
static func _shop(cv, it: Dictionary, b: Vector2, pm: float) -> void:
	var w: float = it.w * pm
	var h: float = it.h * pm
	cv.draw_rect(Rect2(b + Vector2(-w * 0.5, -h), Vector2(w, h)), Color("eceef0"))
	cv.draw_rect(Rect2(b + Vector2(-w * 0.5, -h), Vector2(w, h * 0.16)), STATION_COLOR)
	cv.draw_rect(Rect2(b + Vector2(-w * 0.42, -h * 0.72), Vector2(w * 0.55, h * 0.5)), Color("8fb4cf"))
	cv.draw_rect(Rect2(b + Vector2(w * 0.2, -h * 0.72), Vector2(w * 0.16, h * 0.72)), Color("6f8ea6"))
