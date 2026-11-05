class_name LandmarksIsT1
extends RefCounted
## Icelandic landmarks of the towns between the map cities, drawn with LandmarkPainter's helpers (metres from the
## base point, y up).

const GRASS := Color("6f8a3a")
const MOSS := Color("7d8a5e")
const WOOD := Color("7a5634")
const SEA := Color("3f6f8f")
const SEA_L := Color("8fb6c8")
const BASALT := Color("4a4d52")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"fridheimar_tomato": _fridheimar_tomato()
		"icelandic_horse": _icelandic_horse()
		"kirkjugolf": _kirkjugolf()
		"eggin_gledivik": _eggin_gledivik()
		"grabrok_crater": _grabrok_crater()
		"alafoss_lopapeysa": _alafoss_lopapeysa()
		_: return false
	return true

static func _r(x0: float, y0: float, x1: float, y1: float, col: Color) -> void:
	LandmarkPainter._r(x0, y0, x1, y1, col)

static func _poly(xy: Array, col: Color) -> void:
	LandmarkPainter._poly(xy, col)

static func _c(x: float, y: float, r: float, col: Color) -> void:
	LandmarkPainter._c(x, y, r, col)

static func _l(x0: float, y0: float, x1: float, y1: float, col: Color, w: float) -> void:
	LandmarkPainter._l(x0, y0, x1, y1, col, w)

static func _ell(cx: float, cy: float, rx: float, ry: float, rot: float, col: Color) -> void:
	LandmarkPainter._ell(cx, cy, rx, ry, rot, col)

static func _arc(cx: float, cy: float, rx: float, ry: float, a0: float, a1: float, n: int) -> Array:
	return LandmarkPainter._arc_pts(cx, cy, rx, ry, a0, a1, n)

static func _detail(min_pm: float) -> bool:
	return LandmarkPainter._pm > min_pm

## Friðheimar (Reykholt): a long glasshouse of four ridges glowing warm under its grow lights, rows of tomato plants
## hung with red tomatoes inside, and a big red tomato in front.
static func _fridheimar_tomato() -> void:
	_r(-12, 0, 12, 0.6, GRASS.darkened(0.1))
	var glass := Color("dfeef0")
	var frame := Color("f6f6f2")
	var x0 := -11.0
	var x1 := 7.0
	_r(x0, 0.6, x1, 5.6, glass)
	# the four ridges of the roof
	var n := 4
	var step := (x1 - x0) / n
	for k in n:
		var a := x0 + k * step
		_poly([a, 5.6, a + step * 0.5, 8.0, a + step, 5.6], glass.darkened(0.06))
		_poly([a, 5.6, a + step * 0.5, 8.0, a + step * 0.5, 5.6], glass.lightened(0.3))
		_l(a, 5.6, a + step * 0.5, 8.0, frame, 0.12)
		_l(a + step * 0.5, 8.0, a + step, 5.6, frame, 0.12)
	# the warm glow of the lamps, the tomato plants and their fruit
	_r(x0 + 0.3, 3.8, x1 - 0.3, 5.3, Color("f4d98a"))
	for k in 9:
		var px := x0 + 1.0 + k * 2.0
		_r(px - 0.55, 0.6, px + 0.55, 4.6, Color("4f8a3a"))
		_r(px - 0.2, 0.6, px + 0.2, 4.6, Color("3f7430"))
		if _detail(0.8):
			for j in 3:
				_c(px + (0.25 if j % 2 == 0 else -0.25), 1.4 + j * 1.1, 0.32, Color("d6332a"))
	if _detail(1.0):
		for k in n * 3 + 1:
			var fx := x0 + k * step / 3.0
			_l(fx, 0.6, fx, 5.6, frame, 0.1)
	_l(x0, 5.6, x1, 5.6, frame, 0.15)
	_l(x0, 0.6, x0, 5.6, frame, 0.15)
	_l(x1, 0.6, x1, 5.6, frame, 0.15)
	# the big tomato
	_c(9.4, 2.9, 2.4, Color("d6332a"))
	_c(8.6, 3.7, 0.8, Color("ee6a58"))
	_poly([9.4, 5.1, 8.2, 5.6, 9.0, 5.0, 8.4, 4.6, 9.4, 4.9, 10.4, 4.6, 9.8, 5.0, 10.6, 5.6], Color("3f7a30"))
	_l(9.4, 5.0, 9.6, 6.0, Color("3f7a30"), 0.25)

## The Icelandic horse (Hella, the horse country of Rangárvellir): small and stocky, a chestnut coat, short legs and
## a thick blond mane and tail.
static func _icelandic_horse() -> void:
	_r(-2.5, 0, 2.5, 0.15, GRASS)
	var coat := Color("9a5a2e")
	var dark := coat.darkened(0.25)
	var blond := Color("ead9a6")
	# the legs, the far ones darker
	for p in [[-1.0, dark], [0.9, dark], [-0.7, coat], [1.2, coat]]:
		_r(p[0] - 0.18, 0.12, p[0] + 0.18, 1.4, p[1])
		_r(p[0] - 0.2, 0, p[0] + 0.22, 0.2, Color("2e2620"))
	# the tail
	_poly([-1.4, 2.4, -1.8, 2.3, -2.2, 1.2, -2.0, 0.5, -1.7, 1.1, -1.5, 1.8], blond)
	_poly([-1.4, 2.4, -1.65, 2.3, -1.95, 1.2, -1.85, 0.7, -1.6, 1.4], blond.darkened(0.12))
	# the body, the neck and the head
	_ell(0, 1.85, 1.55, 0.75, 0, coat)
	_ell(-0.1, 2.15, 1.2, 0.35, 0, coat.lightened(0.08))
	_poly([0.8, 1.7, 1.55, 1.9, 2.05, 3.0, 1.75, 3.4, 1.2, 3.2, 0.7, 2.5], coat)
	_ell(2.05, 3.0, 0.55, 0.3, -0.75, coat)
	_ell(2.3, 2.7, 0.25, 0.2, 0, coat.darkened(0.12))
	_c(1.95, 3.15, 0.07, Color("1e1a18"))
	_poly([1.62, 3.35, 1.72, 3.75, 1.85, 3.38], coat.darkened(0.1))
	# the thick blond mane and forelock
	_poly([1.75, 3.45, 1.25, 3.35, 0.8, 2.85, 0.55, 2.35, 0.75, 2.25, 1.1, 2.75, 1.55, 3.1, 1.95, 3.35], blond)
	_poly([1.75, 3.45, 2.05, 3.4, 2.15, 3.15, 1.9, 3.2], blond)

## Kirkjugólf ("the church floor", Kirkjubæjarklaustur): the flat tops of basalt columns in a green meadow, worn so
## smooth they look like a tiled floor, the columns' sides showing at the front.
static func _kirkjugolf() -> void:
	_poly([-10, 0, 10, 0, 9, 1.6, 6, 3.4, -6, 3.4, -9, 1.6], GRASS)
	_poly([-10, 0, -9, 1.6, -6, 3.4, -4, 3.4, -7, 1.4, -8, 0], GRASS.lightened(0.1))
	# the column sides at the front
	_r(-7, 0.4, 7, 2.0, BASALT)
	var r := 0.9
	var col_w := r * 1.5
	var k := 0
	var x := -7.0
	while x < 7.0:
		var x2 := minf(x + col_w, 7.0)
		_r(x, 0.4, x2, 2.0, BASALT.lightened(0.12 if k % 2 == 0 else 0.0))
		_l(x, 0.4, x, 2.0, BASALT.darkened(0.3), 0.06)
		x += col_w
		k += 1
	# the floor: flattened hexagons with dark joints
	_poly([-7, 2.0, 7, 2.0, 6, 4.2, -6, 4.2], BASALT.darkened(0.25))
	var s := 0.32
	var h := sqrt(3.0) * r * s
	for i in range(-5, 6):
		var cx := i * col_w
		var off := h * 0.5 if i % 2 != 0 else 0.0
		var cy := 2.0 + h * 0.5 + off
		while cy < 4.2 - h * 0.45:
			var lim := 7.0 - (cy - 2.0) / 2.2
			if absf(cx) + r * 0.9 <= lim:
				var pts := []
				for j in 6:
					var a := j * PI / 3.0
					pts.append_array([cx + cos(a) * r * 0.9, cy + sin(a) * r * 0.9 * s])
				_poly(pts, Color("8a8d8c") if (i + int(cy * 10)) % 3 != 0 else Color("7a7e7e"))
			cy += h
	# grass growing at the edges
	_l(-7, 2.0, -6, 4.2, GRASS.darkened(0.1), 0.2)
	_l(7, 2.0, 6, 4.2, GRASS.darkened(0.1), 0.2)

## One egg standing upright: w wide, h tall, its bottom at (x, y).
static func _egg(x: float, y: float, w: float, h: float, col: Color) -> void:
	var cy := y + h * 0.42
	_poly(_arc(x, cy, w * 0.5, h * 0.42, PI, TAU, 8) + _arc(x, cy, w * 0.5, h * 0.58, 0, PI, 10), col)
	_ell(x - w * 0.2, cy + h * 0.15, w * 0.12, h * 0.18, 0.2, col.lightened(0.35))

## Eggin í Gleðivík (Djúpivogur): a row of big stone eggs, one for each bird nesting by the town, every one in its
## own colours, standing on concrete pillars along the bay.
static func _eggin_gledivik() -> void:
	_r(-8, 0.8, 8, 2.0, SEA)
	if _detail(1.5):
		_l(-7, 1.6, -3, 1.6, SEA_L, 0.08)
		_l(1, 1.3, 6, 1.3, SEA_L, 0.08)
	_r(-8, 0, 8, 0.9, Color("6e6a62"))
	var cols := [Color("f2ede0"), Color("a9cfd8"), Color("c99a6a"), Color("e9e2c4"), Color("7da88a"),
		Color("d8c7a3"), Color("b7c6cc")]
	for k in 7:
		var x := -6.6 + k * 2.2
		_r(x - 0.35, 0, x + 0.35, 1.5, Color("9c9a94"))
		_r(x - 0.35, 0, x - 0.1, 1.5, Color("b2b0aa"))
		var c: Color = cols[k]
		_egg(x, 1.5, 1.6 if k % 3 != 1 else 1.35, 2.4 if k % 3 != 1 else 2.0, c)
		if _detail(1.2) and k % 2 == 0:
			for j in 4:
				_c(x - 0.3 + (j % 2) * 0.55, 2.0 + j * 0.35, 0.09, c.darkened(0.45))

## Grábrók (by Bifröst): a round red-brown crater cone standing over a mossy lava field, wooden stairs climbing to a
## railing on its rim, and its little sister cone behind.
static func _grabrok_crater() -> void:
	var red := Color("8a3f2a")
	# the little sister cone behind
	_poly([-25, 1, -24, 2, -19, 9, -13, 9.5, -10, 6, -8, 1], red.darkened(0.25))
	# the big cone
	_poly([-20, 1.2, -8, 15, -3, 16, 0, 15.2, 3, 16, 8, 15, 20, 1.2], red)
	_poly([-20, 1.2, -8, 15, -3, 16, -6, 14, -12, 1.2], red.lightened(0.12))
	_poly([8, 15, 20, 1.2, 14, 1.2, 6, 14.2], red.darkened(0.12))
	if _detail(0.8):
		for p in [[-14, 5, 2.0], [-6, 3, 1.6], [11, 6, 1.4], [3, 9, 1.0], [-9, 10, 0.9]]:
			_ell(p[0], p[1], p[2], p[2] * 0.45, 0, MOSS.darkened(0.1))
	# the mossy lava field
	_poly([-25, 0, 25, 0, 25, 1.6, 19, 2.2, 12, 1.4, 0, 1.8, -10, 1.3, -18, 2.0, -25, 1.4], MOSS)
	for x in [-21.0, -12.0, -4.0, 6.0, 16.0, 22.0]:
		_c(x, 1.5, 1.1, MOSS.lightened(0.08))
	# the wooden stairs zigzagging up the side, the railing round the rim
	var pts := [14.0, 1.5, 9.0, 4.5, 12.0, 6.5, 7.5, 10.0, 9.0, 12.0, 6.0, 15.3]
	for k in range(0, pts.size() - 2, 2):
		_l(pts[k], pts[k + 1], pts[k + 2], pts[k + 3], Color("c9a46a"), 0.45)
	_l(-8, 15.0, -8, 16.2, Color("c9a46a"), 0.2)
	_l(8, 15.0, 8, 16.2, Color("c9a46a"), 0.2)
	_l(-8, 16.2, -3, 17.2, Color("c9a46a"), 0.15)
	_l(3, 17.2, 8, 16.2, Color("c9a46a"), 0.15)
	_l(-3, 16, -3, 17.2, Color("c9a46a"), 0.2)
	_l(3, 16, 3, 17.2, Color("c9a46a"), 0.2)
	_l(-3, 17.2, 3, 17.2, Color("c9a46a"), 0.15)

## Álafoss (Mosfellsbær), the old wool mill: a big lopapeysa, the Icelandic wool sweater with its round patterned
## yoke, drying on a wooden frame.
static func _alafoss_lopapeysa() -> void:
	_r(-3, 0, 3, 0.2, GRASS)
	_r(-2.85, 0, -2.6, 6.8, WOOD)
	_r(2.6, 0, 2.85, 6.8, WOOD)
	_r(-3.0, 6.5, 3.0, 6.8, WOOD.darkened(0.1))
	var wool := Color("c9bfae")
	var brown := Color("4a3a2e")
	var white := Color("f4f0e6")
	# sleeves, body and the ribbing
	_poly([-1.5, 5.9, -2.45, 2.4, -1.75, 2.2, -1.2, 4.0], wool.darkened(0.06))
	_poly([1.5, 5.9, 2.45, 2.4, 1.75, 2.2, 1.2, 4.0], wool.darkened(0.06))
	_poly([-2.45, 2.4, -1.75, 2.2, -1.65, 1.8, -2.4, 2.0], brown)
	_poly([2.45, 2.4, 1.75, 2.2, 1.65, 1.8, 2.4, 2.0], brown)
	_r(-1.5, 1.2, 1.5, 6.0, wool)
	_r(-1.5, 1.0, 1.5, 1.5, brown)
	# the round yoke, ring by ring from the outside in
	_poly(_arc(0, 6.0, 2.1, 1.75, PI, TAU, 14), brown)
	_poly(_arc(0, 6.0, 1.75, 1.4, PI, TAU, 14), white)
	if _detail(1.2):
		for k in 9:
			var a := PI + (k + 0.5) * PI / 9.0
			var cx := cos(a) * 1.58
			var cy := 6.0 + sin(a) * 1.25
			_c(cx, cy, 0.14, brown)
	_poly(_arc(0, 6.0, 1.35, 1.05, PI, TAU, 12), brown)
	_poly(_arc(0, 6.0, 1.05, 0.8, PI, TAU, 12), Color("8a6a4a"))
	_poly(_arc(0, 6.0, 0.55, 0.35, PI, TAU, 10), brown)
	_poly(_arc(0, 6.0, 0.4, 0.22, PI, TAU, 10), Color("2e2620"))
	# the clothes pegs
	_r(-1.3, 5.8, -1.05, 6.7, Color("e2d3a8"))
	_r(1.05, 5.8, 1.3, 6.7, Color("e2d3a8"))
