class_name Scenery
extends RefCounted
## Roadside objects. build() places them per 5 m segment, draw_item() paints one at a ground point.
const BUILDING_COLORS := [Color("d9b26b"), Color("e7dcc0"), Color("d98a6c"), Color("a85a45"), Color("8fa3b5"), Color("c9a24a")]
const WALL_DARK := Color(0, 0, 0, 0.18)

static func build(stage: Dictionary, seed_value: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value + 77
	var items := {}
	var length: float = stage.length
	var kind: String = stage.scenery
	var z := 20.0
	var next_lamp := 20.0
	var next_sign := 120.0
	var next_bridge := 600.0
	var next_board := 400.0
	var next_house := 300.0
	while z < length + 500.0:
		match kind:
			"city":
				for side in [-1, 1]:
					var w := rng.randf_range(9.0, 16.0)
					_add(items, "building", z + rng.randf_range(-4, 4), side * (7.5 + w * 0.5 + rng.randf_range(0.0, 1.5)), w, rng.randf_range(12.0, 26.0), rng)
				if rng.randf() < 0.4:
					_add(items, "tree", z, (-1 if rng.randf() < 0.5 else 1) * 8.0, 3.0, 5.0, rng)
				if z >= next_lamp:
					_add(items, "lamp", z, -7.6, 0.4, 7.0, rng)
					_add(items, "lamp", z, 7.6, 0.4, 7.0, rng)
					next_lamp += 45.0
				z += rng.randf_range(16.0, 26.0)
			"highway":
				for side in [-1, 1]:
					if rng.randf() < 0.5:
						_add(items, "tree", z, side * rng.randf_range(16.0, 50.0), 4.0, 6.0, rng)
				if z >= next_sign:
					_add(items, "sign", z, 8.0, 3.0, 5.5, rng)
					next_sign += 260.0
				if z >= next_bridge:
					_add(items, "bridge", z, 0.0, 0.0, 8.0, rng)
					next_bridge += 1100.0
				if z >= next_board:
					_add(items, "billboard", z, 14.0, 9.0, 8.0, rng)
					next_board += 800.0
				z += rng.randf_range(18.0, 40.0)
			_:
				for side in [-1, 1]:
					_add(items, "spruce" if rng.randf() < 0.65 else "tree", z + rng.randf_range(-3, 3), side * rng.randf_range(7.5, 12.0), 3.5, rng.randf_range(7.0, 13.0), rng)
					if rng.randf() < 0.7:
						_add(items, "spruce", z + rng.randf_range(-4, 4), side * rng.randf_range(13.0, 30.0), 4.0, rng.randf_range(9.0, 16.0), rng)
				if z >= next_house:
					_add(items, "house", z, (-1 if rng.randf() < 0.5 else 1) * 22.0, 9.0, 7.0, rng)
					next_house += 520.0
				z += rng.randf_range(7.0, 12.0)
	for s in stage.stations:
		_add(items, "station", s, 15.0, 14.0, 6.0, rng)
	_add(items, "finish", length, 0.0, 0.0, 7.0, rng)
	return items

static func _add(items: Dictionary, type: String, z: float, lat: float, w: float, h: float, rng: RandomNumberGenerator) -> void:
	var idx := int(z / Track.SEG_LEN)
	if not items.has(idx):
		items[idx] = []
	items[idx].append({"type": type, "z": z, "lat": lat, "w": w, "h": h, "v": rng.randf(), "c": rng.randi() % BUILDING_COLORS.size()})

## `b` is the ground point at the item's base, `pm` is pixels per metre at that depth.
static func draw_item(cv: CanvasItem, it: Dictionary, b: Vector2, pm: float, pal: Dictionary, season: String, font: Font, label: String) -> void:
	var h: float = it.h * pm
	if h < 1.5 and it.type != "bridge":
		return
	match it.type:
		"building": _building(cv, it, b, pm)
		"lamp":
			cv.draw_line(b, b + Vector2(0, -h), Color("3b3f45"), maxf(1.0, 0.25 * pm))
			cv.draw_rect(Rect2(b + Vector2(-0.4 * pm if it.lat > 0 else -0.1 * pm, -h), Vector2(0.9 * pm, 0.35 * pm)), Color("3b3f45"))
		"tree": _tree(cv, it, b, pm, pal, season)
		"spruce": _spruce(cv, it, b, pm, pal, season)
		"sign":
			cv.draw_line(b, b + Vector2(0, -h), Color("55595f"), maxf(1.0, 0.2 * pm))
			var r := Rect2(b + Vector2(-1.8 * pm, -h - 0.5 * pm), Vector2(3.6 * pm, 2.0 * pm))
			cv.draw_rect(r, Color("1c6b3a"))
			cv.draw_rect(r.grow(-0.15 * pm), Color("f2f2f2"), false, maxf(1.0, 0.1 * pm))
			if pm > 8.0:
				cv.draw_string(font, r.position + Vector2(0.2 * pm, 1.3 * pm), label, HORIZONTAL_ALIGNMENT_LEFT, 3.2 * pm, int(clampf(1.0 * pm, 6, 40)), Color("f2f2f2"))
		"billboard":
			cv.draw_line(b + Vector2(-3 * pm, 0), b + Vector2(-3 * pm, -h), Color("55595f"), maxf(1.0, 0.3 * pm))
			cv.draw_line(b + Vector2(3 * pm, 0), b + Vector2(3 * pm, -h), Color("55595f"), maxf(1.0, 0.3 * pm))
			var col: Color = BUILDING_COLORS[it.c]
			cv.draw_rect(Rect2(b + Vector2(-5 * pm, -h - 3 * pm), Vector2(10 * pm, 4.5 * pm)), col)
			cv.draw_rect(Rect2(b + Vector2(-4.2 * pm, -h - 2.2 * pm), Vector2(8.4 * pm, 1.2 * pm)), Color("ffffff", 0.8))
		"house": _house(cv, it, b, pm)
		"station": _station(cv, b, pm, font)
		"finish": pass # drawn across the road by WorldView
		"bridge": pass # drawn across the road by WorldView

static func _building(cv: CanvasItem, it: Dictionary, b: Vector2, pm: float) -> void:
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

static func _tree(cv: CanvasItem, it: Dictionary, b: Vector2, pm: float, pal: Dictionary, season: String) -> void:
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

static func _spruce(cv: CanvasItem, it: Dictionary, b: Vector2, pm: float, pal: Dictionary, season: String) -> void:
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

static func _house(cv: CanvasItem, it: Dictionary, b: Vector2, pm: float) -> void:
	var w: float = it.w * pm
	var h: float = it.h * pm
	cv.draw_rect(Rect2(b + Vector2(-w * 0.5, -h * 0.6), Vector2(w, h * 0.6)), Color("e8dcc0"))
	cv.draw_colored_polygon(PackedVector2Array([b + Vector2(-w * 0.6, -h * 0.6), b + Vector2(w * 0.6, -h * 0.6), b + Vector2(0, -h)]), Color("9a4a35"))
	cv.draw_rect(Rect2(b + Vector2(-w * 0.12, -h * 0.32), Vector2(w * 0.24, h * 0.32)), Color("5a3a28"))

static func _station(cv: CanvasItem, b: Vector2, pm: float, font: Font) -> void:
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
