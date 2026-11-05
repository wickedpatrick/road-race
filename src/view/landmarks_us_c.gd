class_name LandmarksUsC
extends RefCounted
## American landmarks, drawn with LandmarkPainter's helpers (metres from the base point, y up).

const WHITE := Color("f4f2ec")
const SAND := Color("e9d6a6")
const SAND_D := Color("d6bf88")
const WATER := Color("4f8fc0")
const WATER_L := Color("9cc8e6")
const GRASS := Color("5d8f42")
const TREE := Color("3f6f34")
const WIN := Color("3a4048")
const DARK := Color("2a2d33")
const WOOD := Color("7a5634")
const GOLD := Color("d8b14a")
const CONCRETE := Color("c9c5bc")
const US_RED := Color("b22234")
const US_BLUE := Color("3c3b6e")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"miami_art_deco": _miami_art_deco()
		"lifeguard_tower": _lifeguard_tower()
		"kennedy_rocket": _kennedy_rocket()
		"florida_alligator": _florida_alligator()
		"steamboat_natchez": _steamboat_natchez()
		"st_louis_cathedral": _st_louis_cathedral()
		"shuttle_747": _shuttle_747()
		"the_alamo": _the_alamo()
		"reunion_tower": _reunion_tower()
		"longhorn": _longhorn()
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

static func _windows(x0: float, x1: float, y0: float, y1: float, n: int, col: Color) -> void:
	LandmarkPainter._windows(x0, x1, y0, y1, n, col)

static func _arc(cx: float, cy: float, rx: float, ry: float, a0: float, a1: float, n: int) -> Array:
	return LandmarkPainter._arc_pts(cx, cy, rx, ry, a0, a1, n)

static func _detail(min_pm: float) -> bool:
	return LandmarkPainter._pm > min_pm

## A palm tree: a slightly bent trunk from (x, y) up `h` metres and a crown of drooping fronds.
static func _palm(x: float, y: float, h: float, lean: float) -> void:
	var tr := Color("8a6a48")
	var tx := x + lean
	var ty := y + h
	_poly([x - 0.35, y, x + 0.35, y, tx + 0.22, ty, tx - 0.22, ty], tr)
	if _detail(1.5):
		for k in 6:
			var f := (k + 0.5) / 6.0
			var px := lerpf(x, tx, f)
			_l(px - 0.3, y + h * f, px + 0.3, y + h * f + 0.2, tr.darkened(0.2), 0.08)
	var leaf := Color("3f8a3a")
	for a in [-2.5, -1.7, -0.9, 0.0, 0.9, 1.7, 2.5]:
		var dx: float = sin(a) * h * 0.42
		var tip_y: float = ty + cos(a) * h * 0.14 - absf(sin(a)) * h * 0.16
		var mx: float = tx + dx * 0.5
		var my: float = ty + cos(a) * h * 0.1 + h * 0.03
		_poly([tx, ty + 0.35, mx, my + h * 0.05, tx + dx, tip_y, mx, my - h * 0.04, tx, ty - 0.35],
			leaf if a <= 0.0 else leaf.darkened(0.12))
	_c(tx, ty, 0.35, Color("6b4a2a"))

## A bald cypress of the swamp: a flared trunk standing in water, a flat-topped crown and grey moss hanging down.
static func _cypress(x: float, y: float, h: float) -> void:
	var tr := Color("6d5a48")
	_poly([x - h * 0.12, y, x + h * 0.12, y, x + h * 0.04, y + h * 0.3, x + h * 0.03, y + h * 0.8,
		x - h * 0.03, y + h * 0.8, x - h * 0.04, y + h * 0.3], tr)
	var cr := Color("4f6e3a")
	_poly([x - h * 0.3, y + h * 0.72, x + h * 0.3, y + h * 0.72, x + h * 0.22, y + h * 0.95, x - h * 0.24, y + h],
		cr)
	_poly([x - h * 0.2, y + h * 0.6, x + h * 0.2, y + h * 0.6, x + h * 0.26, y + h * 0.76, x - h * 0.26, y + h * 0.76],
		cr.darkened(0.1))
	if _detail(1.0):
		var moss := Color("a7ab98")
		for k in 5:
			var mx := x - h * 0.22 + k * h * 0.11
			_poly([mx - h * 0.03, y + h * 0.66, mx + h * 0.03, y + h * 0.66, mx, y + h * (0.44 + 0.04 * (k % 2))], moss)

## Ocean Drive, Miami Beach: three pastel art-deco hotels with stepped tops, racing stripes, "eyebrow" ledges over
## the windows and a central fin, a palm tree on the sidewalk in front.
static func _miami_art_deco() -> void:
	_r(-30, 0, 30, 1, Color("bdb7aa"))
	_r(-30, 1, 30, 1.4, Color("e0dcd2"))
	var cols := [Color("f2a6b8"), Color("9fe0cf"), Color("f6e08c")]
	var trims := [Color("5bbfc9"), Color("e97a9a"), Color("6aa8d8")]
	var xs := [[-28, -10], [-9, 9], [10, 28]]
	var hs := [18.0, 21.0, 17.0]
	for k in 3:
		var x0: float = xs[k][0]
		var x1: float = xs[k][1]
		var h: float = hs[k]
		var c: Color = cols[k]
		var t: Color = trims[k]
		var mx := (x0 + x1) * 0.5
		_r(x0, 1.4, x1, h, c)
		_r(x0, 1.4, x0 + 0.8, h, c.darkened(0.08))
		# the stepped top
		_r(x0 + 2, h, x1 - 2, h + 1.2, c)
		_r(mx - 3, h + 1.2, mx + 3, h + 2.4, c)
		# the fin over the entrance
		_r(mx - 1.4, 4, mx + 1.4, h + 4.5, c.lightened(0.15))
		_r(mx - 1.4, 4, mx - 0.9, h + 4.5, c.darkened(0.05))
		_r(mx - 0.25, 4, mx + 0.25, h + 4.5, t)
		# racing stripes and eyebrow ledges over the window rows
		for row in 3:
			var y := 5.0 + row * 4.2
			_windows(x0 + 1, mx - 1.9, y, y + 2.2, 3, Color("3d6f8a"))
			_windows(mx + 1.9, x1 - 1, y, y + 2.2, 3, Color("3d6f8a"))
			_r(x0, y + 2.4, mx - 1.4, y + 2.8, c.lightened(0.3))
			_r(mx + 1.4, y + 2.4, x1, y + 2.8, c.lightened(0.3))
		_r(x0, h - 1.2, x1, h - 0.6, t)
		if _detail(1.2):
			_r(x0, h - 2.0, x1, h - 1.7, t)
		# the porch with its door
		_r(mx - 2.4, 1.4, mx + 2.4, 3.6, c.darkened(0.15))
		_r(mx - 1, 1.4, mx + 1, 3.2, WIN)
		_r(mx - 3, 3.6, mx + 3, 4.0, t)
		if _detail(1.5):
			_c(x0 + 2, h - 3.4, 0.6, Color("3d6f8a"))
			_c(x1 - 2, h - 3.4, 0.6, Color("3d6f8a"))
	_palm(-11, 1.4, 14, 1.5)
	_palm(9.5, 1.4, 12, -1.2)

## A South Beach lifeguard hut: a bright painted cabin on stilts, a ramp down to the sand, a little flag on top.
static func _lifeguard_tower() -> void:
	_r(-5, 0, 5, 0.8, SAND)
	if _detail(3.0):
		_r(-4, 0.5, -2.5, 0.6, SAND_D)
		_r(2, 0.3, 3.5, 0.4, SAND_D)
	var post := Color("d9d4c6")
	for x in [-2.0, -0.7, 0.7, 2.0]:
		_r(x - 0.15, 0.5, x + 0.15, 3.2, post)
	_l(-2, 0.8, 2, 3.0, post, 0.12)
	_l(2, 0.8, -2, 3.0, post, 0.12)
	# the ramp
	_poly([2.0, 3.1, 2.4, 3.1, 4.9, 0.6, 4.4, 0.6], Color("c8b28c"))
	# the deck and the cabin painted in rainbow stripes
	_r(-2.6, 3.0, 2.6, 3.3, Color("e85a8a"))
	var stripes := [Color("f2603a"), Color("f5a623"), Color("f7d83a"), Color("5cc46a"), Color("3aa6e0"), Color("8a5ad6")]
	for k in 6:
		var x := -2.2 + k * (4.4 / 6.0)
		_r(x, 3.3, x + 4.4 / 6.0, 5.8, stripes[k])
	_r(-1.2, 4.2, 1.2, 5.3, Color("2e5a78"))
	_r(-1.2, 4.2, 1.2, 4.35, WHITE)
	# the roof
	_poly([-2.8, 5.8, 2.8, 5.8, 2.2, 6.6, -2.2, 6.6], Color("3fbfc8"))
	_r(-2.2, 6.6, 2.2, 6.8, Color("2f9aa2"))
	# the flag on its pole
	_l(1.8, 6.8, 1.8, 7.9, DARK, 0.06)
	_poly([1.8, 7.9, 2.9, 7.65, 1.8, 7.4], Color("e83a3a"))
	if _detail(3.0):
		_c(-3.6, 1.4, 0.6, Color("e83a3a"))
		_c(-3.6, 1.4, 0.3, WHITE)

## A Saturn V moon rocket on its launch pad at the Kennedy Space Center: white stages with black bands and black
## roll patterns, the red umbilical tower with swing arms beside it, and the grey mobile launcher under it.
static func _kennedy_rocket() -> void:
	_r(-15, 0, 15, 1, Color("8a9a6a"))
	# the mobile launcher platform
	_r(-11, 1, 11, 5, Color("9a9890"))
	_r(-11, 4.4, 11, 5, Color("7d7b74"))
	_r(-3.5, 1, 3.5, 3.6, DARK)
	# the umbilical tower
	var red := Color("c4462e")
	var tx0 := 6.0
	var tx1 := 10.0
	_l(tx0, 5, tx0, 66, red, 0.5)
	_l(tx1, 5, tx1, 66, red, 0.5)
	for k in 16:
		var y := 5.0 + k * 3.8
		_l(tx0, y, tx1, y, red, 0.25)
		if _detail(0.9):
			_l(tx0, y, tx1, y + 3.8, red.darkened(0.15), 0.15)
	_r(tx0 - 0.3, 66, tx1 + 0.3, 67.5, red)
	_poly([tx0 + 1, 67.5, tx1 - 1, 67.5, (tx0 + tx1) * 0.5, 69.5], red.darkened(0.1))
	for y in [18.0, 36.0, 47.0, 55.0]:
		_r(2.6, y, tx0, y + 0.7, red.darkened(0.1))
	# the rocket
	var w := WHITE
	var b := DARK
	_r(-2.6, 5, 2.6, 30, w)
	_r(-2.6, 5, -1.9, 30, w.darkened(0.08))
	# the F-1 engines and fins
	_poly([-2.6, 7, -4.0, 5, -2.6, 5], b)
	_poly([2.6, 7, 4.0, 5, 2.6, 5], b)
	# black roll patterns of the first stage
	_r(-2.6, 5, 0, 9, b)
	_r(0, 9, 2.6, 13, b)
	_r(-2.6, 24, 0, 28, b)
	_r(-2.6, 30, 2.6, 31.2, b)
	# second stage
	_r(-2.6, 31.2, 2.6, 44, w)
	_r(-2.6, 31.2, -1.9, 44, w.darkened(0.08))
	_r(-2.6, 41, 2.6, 42.2, b)
	_poly([-2.6, 44, 2.6, 44, 1.8, 46.5, -1.8, 46.5], w)
	# third stage
	_r(-1.8, 46.5, 1.8, 54, w)
	_r(-1.8, 46.5, 0, 48.5, b)
	_r(-1.8, 52.6, 1.8, 53.4, b)
	# the Apollo spacecraft and its escape tower
	_poly([-1.8, 54, 1.8, 54, 1.4, 57, -1.4, 57], w)
	_poly([-1.4, 57, 1.4, 57, 0.4, 60, -0.4, 60], Color("dcdcd8"))
	_l(0, 60, 0, 64.5, Color("8a3a2a"), 0.35)
	_poly([-0.35, 64.5, 0.35, 64.5, 0, 66], Color("8a3a2a"))
	if _detail(1.2):
		_r(-0.7, 18, 0.7, 23, US_RED)
		_r(-0.7, 21.5, -0.05, 23, US_BLUE)
		_l(-0.7, 34, 0.7, 34, b, 0.1)

## An American alligator on the bank of a Florida swamp: dark green still water, bald cypresses hung with moss,
## and the long armoured reptile with its broad snout, ridged back and heavy tail.
static func _florida_alligator() -> void:
	_r(-12, 0, 12, 3, Color("3e5e46"))
	if _detail(2.0):
		_r(-10, 1.2, -6, 1.35, Color("6e8f74"))
		_r(5, 2.2, 9, 2.35, Color("6e8f74"))
	_cypress(-8.4, 1.5, 11.5)
	_cypress(8.8, 2.0, 9.5)
	# the muddy bank with grass
	_poly([-9, 2.2, 9, 2.2, 8.4, 3.4, -8.4, 3.6], Color("8a7a50"))
	_poly([-8.4, 3.3, 8.4, 3.3, 8.4, 3.6, -8.4, 3.6], Color("7fa04a"))
	# the alligator, facing left, drawn 1.6 times its life size so it reads from the road
	var g := Color("4a5a36")
	var gl := Color("7a8a58")
	var o := Vector2(0.4, 3.5)
	var k := 1.55
	_gator_poly([-5.4, 0.25, -3.2, 0.15, -2.6, 0.3, -2.8, 0.8, -3.4, 0.85, -5.3, 0.55], o, k, g)
	_gator_poly([-2.8, 0.1, 1.6, 0.1, 2.0, 0.4, 1.6, 1.05, -2.2, 1.1, -2.9, 0.8], o, k, g)
	_gator_poly([1.6, 0.15, 4.6, 0.2, 4.9, 0.32, 1.8, 0.95], o, k, g)
	_gator_poly([-2.6, 0.1, 1.6, 0.1, 1.4, 0.3, -2.4, 0.3], o, k, Color("c8c49a"))
	_gator_poly([-5.3, 0.4, -3.3, 0.42, -3.3, 0.5, -5.3, 0.48], o, k, Color("d8d4aa"))
	for lx in [-2.1, 1.0]:
		_gator_poly([lx - 0.25, 0.3, lx + 0.35, 0.3, lx + 0.15, -0.05, lx - 0.45, -0.05], o, k, g.darkened(0.2))
	if _detail(1.0):
		for n in 11:
			var x := -2.4 + n * 0.62
			var top: float = lerpf(1.1, 0.35, clampf((x - 1.6) / 3.3, 0.0, 1.0)) if x > 1.6 else 1.1
			_gator_poly([x - 0.2, top - 0.08, x + 0.2, top - 0.08, x, top + 0.22], o, k, gl)
	_c(o.x - 3.3 * k, o.y + 0.92 * k, 0.22 * k, g)
	_c(o.x - 3.3 * k, o.y + 0.95 * k, 0.1 * k, Color("e8d84a"))
	_c(o.x - 5.2 * k, o.y + 0.6 * k, 0.1 * k, g)

static func _gator_poly(xy: Array, o: Vector2, k: float, col: Color) -> void:
	var out := []
	for i in range(0, xy.size(), 2):
		out.append_array([o.x + xy[i] * k, o.y + xy[i + 1] * k])
	_poly(out, col)

## The steamboat Natchez on the Mississippi: a white hull and two decks with railings, a pilot house on top, two
## tall black smokestacks with crowned tops and the big red paddle wheel at the stern.
static func _steamboat_natchez() -> void:
	_r(-28, 0, 28, 3, Color("7a7a5a"))
	if _detail(1.0):
		_r(-25, 1.2, -16, 1.4, Color("a8a888"))
		_r(10, 0.6, 22, 0.8, Color("a8a888"))
	var w := WHITE
	var red := Color("b8302a")
	# the hull
	_poly([-26, 4.5, -23, 1.8, 20, 1.8, 20, 4.5], w)
	_r(-23, 1.8, 20, 2.4, DARK)
	_r(-25, 4.2, 20, 4.6, red)
	# the lower decks
	for d in 2:
		var y0 := 4.6 + d * 3.6
		var x0 := -22.0 + d * 3.0
		var x1 := 19.0 - d * 2.0
		_r(x0, y0, x1, y0 + 3.2, w.darkened(0.04))
		_windows(x0 + 0.5, x1 - 0.5, y0 + 0.6, y0 + 2.2, 14 - d * 2, Color("4a4038"))
		_r(x0 - 0.6, y0 + 3.2, x1 + 0.6, y0 + 3.6, w)
		if _detail(1.0):
			for k in int((x1 - x0) / 1.2):
				var rx := x0 + 0.3 + k * 1.2
				_l(rx, y0 + 3.6, rx, y0 + 4.3, w, 0.08)
			_l(x0 - 0.6, y0 + 4.3, x1 + 0.6, y0 + 4.3, w, 0.12)
	# the texas deck and the pilot house
	_r(-14, 11.8, 6, 13.6, w)
	_windows(-13, 5, 12.2, 13.2, 9, Color("4a4038"))
	_r(-9, 13.6, -3, 16.2, w)
	_windows(-8.6, -3.4, 14.2, 15.6, 3, Color("4a4038"))
	_poly([-9.6, 16.2, -2.4, 16.2, -3.2, 16.9, -8.8, 16.9], red)
	# the two smokestacks, with feathered crowns
	for sx in [-17.0, -12.5]:
		_r(sx - 0.7, 11.8, sx + 0.7, 20, DARK)
		_poly([sx - 0.7, 20, sx + 0.7, 20, sx + 1.3, 21.4, sx - 1.3, 21.4], DARK)
		if _detail(1.5):
			for k in 4:
				var cx: float = sx - 1.1 + k * 0.73
				_poly([cx - 0.25, 21.4, cx + 0.25, 21.4, cx, 22.0], GOLD)
	_l(-17, 16, -12.5, 16, DARK, 0.15)
	# the red paddle wheel at the stern
	var pc := Vector2(23.2, 6.6)
	_c(pc.x, pc.y, 4.6, red.darkened(0.2))
	_c(pc.x, pc.y, 4.0, red)
	if _detail(0.8):
		for k in 10:
			var a := k * TAU / 10.0
			_l(pc.x, pc.y, pc.x + cos(a) * 4.4, pc.y + sin(a) * 4.4, red.darkened(0.35), 0.18)
	_c(pc.x, pc.y, 0.6, DARK)
	_r(18.5, 4.6, 20, 11.5, w)
	# the flag
	_l(-24, 4.6, -24, 9.5, DARK, 0.1)
	_r(-24, 8.2, -22.2, 9.4, US_RED)
	_r(-24, 8.8, -23.2, 9.4, US_BLUE)
	_r(-23.2, 8.6, -22.2, 8.8, WHITE)

## St. Louis Cathedral on Jackson Square, New Orleans: the white facade with arched doors and a clock, three
## black slate spires (the middle one tallest), the iron fence and a magnolia of the square in front.
static func _st_louis_cathedral() -> void:
	_r(-20, 0, 20, 1, GRASS)
	var w := Color("f2efe6")
	var wd := w.darkened(0.1)
	var sl := Color("2e3238")
	# the nave body
	_r(-14, 1, 14, 20, w)
	_r(-14, 12, 14, 12.6, wd)
	# the two side towers
	for sx in [-11.0, 11.0]:
		_r(sx - 3.5, 1, sx + 3.5, 26, w)
		_r(sx - 3.5, 1, sx - 2.8, 26, wd)
		_r(sx - 3.8, 26, sx + 3.8, 27, wd)
		_r(sx - 2.6, 27, sx + 2.6, 30, w)
		_poly([sx - 1.1, 21, sx + 1.1, 21, sx + 1.1, 23.5] + _arc(sx, 23.5, 1.1, 1.1, 0, PI, 6), WIN)
		_poly([sx - 2.9, 30, sx + 2.9, 30, sx, 38], sl)
		_poly([sx - 2.9, 30, sx - 0.6, 30, sx, 38], sl.lightened(0.12))
		_l(sx, 38, sx, 39.5, GOLD, 0.15)
		_l(sx - 0.5, 39, sx + 0.5, 39, GOLD, 0.15)
	# the central tower
	_r(-4.5, 1, 4.5, 30, w)
	_r(-4.5, 1, -3.7, 30, wd)
	_r(-5, 20, 5, 21, wd)
	_c(0, 25, 1.9, wd)
	_c(0, 25, 1.6, Color("f8f6ee"))
	_l(0, 25, 0, 26.2, DARK, 0.15)
	_l(0, 25, 0.9, 25, DARK, 0.15)
	_r(-5, 30, 5, 31, wd)
	_r(-3.5, 31, 3.5, 34, w)
	_poly([-1, 31.4, 1, 31.4, 1, 32.8] + _arc(0, 32.8, 1, 1, 0, PI, 6), WIN)
	_poly([-3.8, 34, 3.8, 34, 0, 44], sl)
	_poly([-3.8, 34, -0.8, 34, 0, 44], sl.lightened(0.12))
	_l(0, 44, 0, 45.8, GOLD, 0.18)
	_l(-0.7, 45.1, 0.7, 45.1, GOLD, 0.18)
	# the doors and the upper windows, the columns
	for dx in [-8.0, 0.0, 8.0]:
		var dw := 1.6 if dx == 0.0 else 1.2
		_poly([dx - dw, 1, dx + dw, 1, dx + dw, 6] + _arc(dx, 6, dw, dw, 0, PI, 8), Color("5a4030"))
		_poly([dx - dw * 0.6, 14, dx + dw * 0.6, 14, dx + dw * 0.6, 16.5] + _arc(dx, 16.5, dw * 0.6, dw * 0.6, 0, PI, 6),
			WIN)
	if _detail(1.0):
		for cx in [-5.2, -2.6, 2.6, 5.2, -12.4, -9.6, 9.6, 12.4]:
			_r(cx - 0.25, 1, cx + 0.25, 11.8, wd)
	# the iron fence of the square
	_r(-20, 2.6, 20, 2.8, DARK)
	if _detail(1.2):
		for k in 41:
			_l(-20 + k, 1, -20 + k, 2.9, DARK, 0.08)
	_c(-17, 6, 3, Color("3f6f34"))
	_c(17.2, 5.5, 2.6, Color("3f6f34"))
	_r(-17.3, 1, -16.7, 3.5, WOOD)
	_r(16.9, 1, 17.5, 3.5, WOOD)

## The space shuttle Independence riding piggyback on the NASA 747 carrier at Space Center Houston: the white jumbo
## jet with its blue stripe and the hump of its upper deck, the extra fins on its tail, and the white shuttle with
## its black nose and belly on the struts on top, the plane held up on display supports.
static func _shuttle_747() -> void:
	_r(-35, 0, 35, 1, Color("a8a49a"))
	var w := WHITE
	var blue := Color("2c5aa0")
	# the display stands
	for sx in [-18.0, 6.0, 22.0]:
		_r(sx - 0.8, 1, sx + 0.8, 7.5, Color("8a8c90"))
		_r(sx - 2.0, 1, sx + 2.0, 1.6, Color("8a8c90"))
	# the 747 fuselage, nose to the left
	var y0 := 7.0
	var y1 := 13.0
	_poly([-33, y0 + 2.2, -31, y0 + 0.4, -27, y0, 26, y0, 33, y0 + 3.5, 33, y1 - 1.2, 26, y1, -22, y1,
		-25, y1 + 2.2, -29, y1 + 2.2, -31.5, y1 - 0.5, -33, y0 + 4], w)
	_r(-30, y0 + 2.6, 30, y0 + 3.4, blue)
	_poly([30, y0 + 2.6, 33, y0 + 3.6, 33, y0 + 4.2, 30, y0 + 3.4], blue)
	_r(-31.5, y0 + 0.5, 25, y0 + 1.0, w.darkened(0.08))
	if _detail(1.2):
		_windows(-28, 22, y0 + 3.8, y0 + 4.4, 34, Color("4a5260"))
		_windows(-28.4, -23, y1 + 0.6, y1 + 1.2, 4, Color("4a5260"))
	_poly([-32.6, y1 - 1.6, -31.2, y1 - 0.6, -30.4, y1 - 1.6], Color("3a4048"))
	# the wing and the engines (the near side)
	_poly([-8, y0 + 1.6, 4, y0 + 1.6, 14, y0 - 1.0, 10, y0 - 1.0], w.darkened(0.12))
	for ex in [-4.0, 5.0]:
		_r(ex - 2.4, y0 - 2.0, ex + 2.4, y0 - 0.2, Color("c8ccd2"))
		_r(ex - 2.6, y0 - 2.0, ex - 2.0, y0 - 0.2, Color("3a4048"))
	# the tail: the big fin and the two end-plate fins on the stabiliser
	_poly([24, y1, 31, y1, 34.6, y1 + 9, 31.6, y1 + 9], w)
	_poly([27, y1 + 2.4, 32, y1 + 2.4, 33.2, y1 + 5.6, 29.4, y1 + 5.6], blue)
	_poly([27.4, y0 + 4.5, 34, y0 + 4.5, 34.6, y0 + 5.4, 28.4, y0 + 5.4], w.darkened(0.1))
	_r(32.4, y0 + 3.4, 34.4, y0 + 7.4, w.darkened(0.06))
	# the struts and the shuttle
	_l(-8, y1, -9, y1 + 2.6, Color("8a8c90"), 0.5)
	_l(10, y1, 10, y1 + 2.4, Color("8a8c90"), 0.5)
	_l(13, y1, 13, y1 + 2.4, Color("8a8c90"), 0.5)
	var s0 := y1 + 2.4
	_poly([-16, s0 + 1.2, -14, s0 + 0.2, 12, s0, 18, s0, 18, s0 + 4.2, -12, s0 + 4.2, -15, s0 + 3.4, -16.3, s0 + 2.2],
		w)
	# black belly and nose
	_poly([-16, s0 + 1.2, -14, s0 + 0.2, 18, s0, 18, s0 + 0.7, -13.4, s0 + 0.9], DARK)
	_poly([-16.3, s0 + 2.2, -16, s0 + 1.2, -13.6, s0 + 0.8, -13.8, s0 + 2.8, -15, s0 + 3.4], DARK)
	_poly([-11.6, s0 + 3.2, -9.6, s0 + 3.2, -9.6, s0 + 3.8, -11, s0 + 3.8], Color("3a4048"))
	# the wing and the tail fin
	_poly([-2, s0 + 0.9, 15, s0 + 0.9, 17.5, s0 + 1.6, 12, s0 + 2.0], Color("dcdcd6"))
	_poly([12, s0 + 4.2, 18, s0 + 4.2, 19.5, s0 + 9.5, 16.5, s0 + 9.5], w)
	_poly([18, s0 + 1.2, 19.8, s0 + 1.6, 19.8, s0 + 3.4, 18, s0 + 3.8], Color("9a9ca0"))
	if _detail(1.5):
		_r(-4, s0 + 2.0, -1.5, s0 + 3.4, US_BLUE)
		_r(-1.5, s0 + 2.0, 2.5, s0 + 3.4, US_RED)
		_r(-1.5, s0 + 2.5, 2.5, s0 + 2.9, WHITE)
		_r(-1.5, s0 + 3.0, 2.5, s0 + 3.4, US_RED)

## The Alamo in San Antonio: the old mission church of pale limestone, its famous curved hump parapet on top, the
## arched door between pairs of carved columns and niches, and the empty window holes.
static func _the_alamo() -> void:
	_r(-17, 0, 17, 1, Color("9aa46a"))
	var st := Color("ddd0b0")
	var sd := st.darkened(0.14)
	_r(-14, 1, 14, 11, st)
	_r(-14, 1, -13, 11, sd)
	_r(13, 1, 14, 11, sd)
	_r(-14.4, 10.6, 14.4, 11.2, sd)
	# the curved parapet ("the hump")
	_poly([-7.5, 11.2, 7.5, 11.2, 7.5, 12.0, 6.0, 12.1, 4.8, 12.4, 3.8, 12.9, 3.0, 13.5] + _arc(0, 13.5, 3.0, 2.3, 0, PI, 12)
		+ [-3.8, 12.9, -4.8, 12.4, -6.0, 12.1, -7.5, 12.0], st)
	_r(-7.5, 11.9, -6.7, 12.6, st)
	_r(6.7, 11.9, 7.5, 12.6, st)
	_r(-7, 11.2, 7, 11.5, sd)
	# the arched door
	_poly([-2, 1, 2, 1, 2, 5] + _arc(0, 5, 2, 2, 0, PI, 10), Color("4a3a2a"))
	_poly(_arc(0, 5, 2.6, 2.6, 0, PI, 10) + _arc(0, 5, 2.0, 2.0, PI, 0, 10), sd)
	# the columns and niches
	for side in [-1.0, 1.0]:
		for cx in [3.2, 6.6]:
			var x: float = side * cx
			_r(x - 0.35, 1, x + 0.35, 9.6, sd)
			_r(x - 0.5, 9.6, x + 0.5, 10, sd)
		var nx: float = side * 4.9
		_poly([nx - 0.7, 2.4, nx + 0.7, 2.4, nx + 0.7, 4.0] + _arc(nx, 4.0, 0.7, 0.7, 0, PI, 6), Color("8a7a5a"))
		_poly([nx - 0.7, 6.4, nx + 0.7, 6.4, nx + 0.7, 7.8] + _arc(nx, 7.8, 0.7, 0.7, 0, PI, 6), Color("8a7a5a"))
		_r(side * 10.5 - 0.9, 6, side * 10.5 + 0.9, 8.6, Color("5a4a3a"))
	_r(-0.9, 7.6, 0.9, 9.6, Color("5a4a3a"))
	if _detail(1.5):
		for k in 6:
			_r(-12 + k * 0.4, 2 + k * 1.5, -11 + k * 0.4, 2.3 + k * 1.5, sd)
			_r(11.5 - k * 0.3, 1.6 + k * 1.4, 12.5 - k * 0.3, 1.9 + k * 1.4, sd)
	# live oaks by the walls
	_r(-15.8, 1, -15.2, 4, WOOD)
	_c(-15.5, 5.5, 2.2, Color("4f7a3a"))
	_r(15.2, 1, 15.8, 4, WOOD)
	_c(15.5, 5.2, 2.0, Color("4f7a3a"))

## Reunion Tower in Dallas: three concrete shafts rising together to the big geodesic ball covered with little
## lights, the city's lit-up landmark at dusk.
static func _reunion_tower() -> void:
	_r(-12, 0, 12, 1, GRASS)
	_r(-8, 1, 8, 3, CONCRETE.darkened(0.1))
	var c := Color("d8d4cc")
	_poly([-2.6, 1, 2.6, 1, 1.8, 62, -1.8, 62], c)
	_poly([-2.6, 1, -1.4, 1, -1.0, 62, -1.8, 62], c.darkened(0.12))
	_poly([1.4, 1, 2.6, 1, 1.8, 62, 1.0, 62], c.darkened(0.06))
	_l(-0.6, 1, -0.4, 62, c.darkened(0.2), 0.15)
	_l(0.6, 1, 0.4, 62, c.darkened(0.2), 0.15)
	if _detail(1.0):
		_r(-0.45, 10, 0.45, 58, Color("6a7a8a"))
	# the restaurant decks under the ball
	_r(-5.5, 60, 5.5, 63, Color("4a4e58"))
	_r(-5.5, 62.4, 5.5, 63, Color("3a3e48"))
	# the geodesic ball with its lights
	var bc := Vector2(0, 70)
	_c(bc.x, bc.y, 8.6, Color("3e4454"))
	_c(bc.x - 1.6, bc.y + 1.6, 6.0, Color("566070"))
	if _detail(0.6):
		var lc := Color("fff2b8")
		for row in 8:
			var ry := -7.0 + row * 2.0
			var half := sqrt(maxf(0.0, 8.0 * 8.0 - ry * ry))
			var n := int(half / 1.1)
			for k in range(-n, n + 1):
				var px := k * 1.1 + (0.55 if row % 2 == 1 else 0.0)
				if absf(px) < half - 0.3:
					_c(bc.x + px, bc.y + ry, 0.22, lc)
	_l(0, 78.4, 0, 79.8, Color("8a8c90"), 0.15)

## A Texas longhorn steer of the Fort Worth Stockyards: a lean spotted red-and-white body and the famous horns,
## sweeping out far to both sides, the wooden fence of the cattle pens behind.
static func _longhorn() -> void:
	_r(-4, 0, 4, 0.3, Color("b89a68"))
	# the fence of the pens
	var fw := Color("8a6a48")
	for x in [-3.8, -1.2, 1.4, 3.8]:
		_r(x - 0.1, 0.2, x + 0.1, 2.2, fw)
	_r(-4, 1.2, 4, 1.35, fw)
	_r(-4, 1.9, 4, 2.05, fw)
	var red := Color("9a4a2a")
	var cream := Color("eadfc8")
	# legs
	for lx in [-0.8, -0.3, 2.2, 2.7]:
		_r(lx - 0.13, 0.2, lx + 0.13, 1.3, red.darkened(0.15))
		_r(lx - 0.14, 0.2, lx + 0.14, 0.34, DARK)
	# the body, white with red patches, head to the left
	_poly([-1.2, 1.2, 3.1, 1.2, 3.4, 1.6, 3.2, 2.4, 2.4, 2.6, -0.4, 2.7, -1.1, 2.5], cream)
	_poly([0.2, 1.4, 1.6, 1.3, 1.8, 2.0, 1.2, 2.6, 0.1, 2.6], red)
	_poly([2.4, 1.3, 3.2, 1.4, 3.3, 2.3, 2.6, 2.5], red)
	_l(3.3, 2.2, 3.7, 1.2, cream, 0.08)
	_c(3.72, 1.15, 0.1, DARK)
	# the head, facing out a little, and the horns
	_poly([-1.0, 2.6, -0.5, 2.5, -1.2, 1.6, -1.6, 1.6, -1.6, 2.5], red)
	_poly([-1.55, 1.7, -1.25, 1.7, -1.3, 1.5, -1.5, 1.5], DARK)
	var hn := Color("e6dcc0")
	var ht := Color("3a3a32")
	_poly([-1.3, 2.62, -1.6, 2.78, -2.8, 2.98, -3.9, 3.62, -3.95, 3.5, -2.8, 2.82, -1.5, 2.48], hn)
	_poly([-3.6, 3.36, -3.95, 3.6, -3.95, 3.45, -3.7, 3.3], ht)
	_poly([-0.9, 2.62, -0.6, 2.78, 0.6, 2.98, 1.7, 3.62, 1.75, 3.5, 0.6, 2.82, -0.8, 2.48], hn)
	_poly([1.4, 3.36, 1.75, 3.6, 1.75, 3.45, 1.5, 3.3], ht)
	_c(-1.1, 2.6, 0.28, red.darkened(0.1))
	_c(-1.35, 2.2, 0.06, DARK)
	_c(-0.9, 2.2, 0.06, DARK)
