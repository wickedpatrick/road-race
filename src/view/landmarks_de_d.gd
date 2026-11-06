class_name LandmarksDeD
extends RefCounted
## German landmarks (D): Regensburg, drawn with LandmarkPainter's helpers (metres from the base point, y up).

const LIME := Color("a9a59a") # the Roman limestone blocks
const PLASTER := Color("e8dcb8")
const TILE := Color("b0553a")
const SLATE := Color("4a4f58")
const WATER := Color("4f8fc0")
const WATER_L := Color("9cc8e6")
const DOM := Color("d8d3c3") # the cathedral's pale stone
const HOLE := Color("4a5260") # shadowed openings and tracery
const WIN := Color("3a4048")
const RED := Color("b8282c")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"porta_praetoria": _porta_praetoria()
		"steinerne_bruecke": _steinerne_bruecke()
		"regensburg_dom": _regensburg_dom()
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

static func _pl(xy: Array, col: Color, w: float) -> void:
	LandmarkPainter._pl(xy, col, w)

static func _ell(cx: float, cy: float, rx: float, ry: float, rot: float, col: Color) -> void:
	LandmarkPainter._ell(cx, cy, rx, ry, rot, col)

static func _windows(x0: float, x1: float, y0: float, y1: float, n: int, col: Color) -> void:
	LandmarkPainter._windows(x0, x1, y0, y1, n, col)

static func _arc(cx: float, cy: float, rx: float, ry: float, a0: float, a1: float, n: int) -> Array:
	return LandmarkPainter._arc_pts(cx, cy, rx, ry, a0, a1, n)

static func _detail(min_pm: float) -> bool:
	return LandmarkPainter._pm > min_pm

## A fixed pseudo-random 0..1 for stone shades (the same every frame).
static func _hash(a: int, b: int) -> float:
	return float(((a * 73856093) ^ (b * 19349663)) & 1023) / 1023.0

## Rough stone courses over x0..x1, y0..y1: blocks of varied grey with dark joints, every other course offset.
static func _blocks(x0: float, y0: float, x1: float, y1: float, bw: float, bh: float, col: Color) -> void:
	_r(x0, y0, x1, y1, col)
	if not _detail(1.3):
		return
	var rows := int(round((y1 - y0) / bh))
	var h := (y1 - y0) / rows
	for j in rows:
		var y := y0 + j * h
		var x := x0 - (bw * 0.5 if j % 2 == 1 else 0.0)
		var k := 0
		while x < x1:
			var w := bw * (0.75 + 0.5 * _hash(j, k))
			var a := maxf(x, x0)
			var b := minf(x + w, x1)
			var t := _hash(k + 7, j * 3 + 1)
			var shade := col.darkened(0.12 * t) if t > 0.5 else col.lightened(0.1 * t)
			_r(a + 0.06, y + 0.06, b - 0.06, y + h - 0.06, shade)
			x += w
			k += 1
	var joint := col.darkened(0.35)
	for j in rows + 1:
		_l(x0, y0 + j * h, x1, y0 + j * h, joint, 0.1)

## A pointed Gothic arch from the left spring (x0, y0) over the apex (centre, y1) to the right spring (x1, y0).
static func _pointed(x0: float, x1: float, y0: float, y1: float) -> Array:
	var w := (x1 - x0) * 0.5
	var a := PI / 3.0
	var left := []
	for k in 7:
		var t := k / 6.0
		left.append_array([x0 + w * (1.0 - cos(t * a)) / (1.0 - cos(a)), y0 + (y1 - y0) * sin(t * a) / sin(a)])
	var pts := left.duplicate()
	for k in range(5, -1, -1):
		pts.append_array([x1 - (left[k * 2] - x0), left[k * 2 + 1]])
	return pts

## A pointed window: a dark lancet from y0 to apex y1 between x0..x1, mullions when there is room.
static func _lancet(x0: float, x1: float, y0: float, y1: float, col: Color) -> void:
	var spring := y1 - (x1 - x0) * 0.8
	_poly([x0, y0] + _pointed(x0, x1, spring, y1) + [x1, y0], col)
	if _detail(1.8) and x1 - x0 > 1.2:
		var m := (x0 + x1) * 0.5
		_l(m, y0, m, spring + (y1 - spring) * 0.3, DOM.darkened(0.05), 0.12)
		_l(x0, spring - 0.6, x1, spring - 0.6, DOM.darkened(0.05), 0.08)

## A little Roman legionary, `h` tall at x: red tunic, iron helmet with a red crest, a big curved red shield
## with a golden boss, a spear.
static func _legionary(x: float, h: float) -> void:
	var s := h / 2.0
	var skin := Color("e0b088")
	var iron := Color("8a9098")
	# legs and sandals
	_r(x - 0.22 * s, 0, x - 0.06 * s, 0.6 * s, skin)
	_r(x + 0.06 * s, 0, x + 0.22 * s, 0.6 * s, skin)
	_r(x - 0.26 * s, 0, x - 0.04 * s, 0.08 * s, Color("5a3a22"))
	_r(x + 0.04 * s, 0, x + 0.26 * s, 0.08 * s, Color("5a3a22"))
	# the tunic and the armour
	_poly([x - 0.34 * s, 0.6 * s, x + 0.34 * s, 0.6 * s, x + 0.28 * s, 1.0 * s, x - 0.28 * s, 1.0 * s], RED)
	_r(x - 0.3 * s, 0.95 * s, x + 0.3 * s, 1.45 * s, iron)
	if _detail(1.0):
		for k in 3:
			var y := (1.05 + k * 0.13) * s
			_l(x - 0.3 * s, y, x + 0.3 * s, y, iron.darkened(0.3), 0.04 * s)
	# the spear
	_l(x + 0.5 * s, 0.1 * s, x + 0.5 * s, 2.25 * s, Color("6a4a2a"), 0.06 * s)
	_poly([x + 0.44 * s, 2.2 * s, x + 0.56 * s, 2.2 * s, x + 0.5 * s, 2.45 * s], iron)
	_l(x + 0.28 * s, 1.35 * s, x + 0.5 * s, 1.3 * s, skin, 0.1 * s)
	# head, helmet and crest
	_c(x, 1.63 * s, 0.17 * s, skin)
	_poly(_arc(x, 1.68 * s, 0.22 * s, 0.2 * s, 0, PI, 8), iron)
	_r(x - 0.24 * s, 1.58 * s, x - 0.16 * s, 1.72 * s, iron) # cheek guard
	_poly([x - 0.2 * s, 1.86 * s, x + 0.2 * s, 1.86 * s, x + 0.16 * s, 2.02 * s, x - 0.16 * s, 2.02 * s], RED)
	# the scutum: a tall red rectangle, a gold edge and boss, held in front
	var sx := x - 0.42 * s
	_r(sx - 0.34 * s, 0.35 * s, sx + 0.34 * s, 1.5 * s, Color("d4a838"))
	_r(sx - 0.3 * s, 0.39 * s, sx + 0.3 * s, 1.46 * s, RED)
	_c(sx, 0.92 * s, 0.11 * s, Color("e0b43a"))
	if _detail(1.0):
		_l(sx, 0.45 * s, sx, 1.4 * s, Color("d4a838"), 0.04 * s)
		_l(sx - 0.26 * s, 0.92 * s, sx + 0.26 * s, 0.92 * s, Color("d4a838"), 0.04 * s)

## Regensburg's Porta Praetoria: the north gate of the Roman fortress Castra Regina - a great arch of rough grey
## limestone blocks and its squat square side tower, later house walls with a tiled roof built onto them, a
## Roman legionary standing guard.
static func _porta_praetoria() -> void:
	var stone := LIME
	var sd := stone.darkened(0.3)
	# the later houses built onto the gate: plaster walls and a tiled roof behind and to the right
	_r(-11, 0, 11.5, 10.4, PLASTER)
	_poly([-11.4, 10.4, 11.9, 10.4, 10.5, 13.4, -10, 13.4], TILE)
	_poly([-11.4, 10.4, -10, 13.4, -8.6, 13.4, -9.8, 10.4], TILE.lightened(0.12))
	if _detail(1.2):
		for x in [-6.0, -1.0]:
			_r(x - 0.5, 11.2, x + 0.5, 12.4, PLASTER.darkened(0.1)) # dormers
			_poly([x - 0.7, 12.4, x + 0.7, 12.4, x, 13.0], TILE.darkened(0.15))
	_windows(9.2, 11.0, 6.4, 8.4, 1, WIN)
	_windows(9.2, 11.0, 2.4, 4.4, 1, WIN)
	# the Roman gate wall with its arch
	_blocks(-9, 0, 1.6, 9.2, 1.6, 0.9, stone)
	# the arch: a dark opening ringed by big wedge stones
	var ax := -3.4
	var ar := 2.6
	var sy := 4.2
	_poly([ax - ar, 0, ax + ar, 0, ax + ar, sy] + _arc(ax, sy, ar, ar, 0, PI, 12) + [ax - ar, sy], Color("2e2a26"))
	var ro := ar + 1.15
	for k in 7:
		var a0 := PI * k / 7.0
		var a1 := PI * (k + 1) / 7.0
		var t := _hash(k, 3)
		var col := stone.lightened(0.08) if t > 0.5 else stone.darkened(0.06)
		_poly([ax + cos(a0) * ar, sy + sin(a0) * ar, ax + cos(a0) * ro, sy + sin(a0) * ro,
			ax + cos(a1) * ro, sy + sin(a1) * ro, ax + cos(a1) * ar, sy + sin(a1) * ar], col)
		_l(ax + cos(a0) * ar, sy + sin(a0) * ar, ax + cos(a0) * ro, sy + sin(a0) * ro, sd, 0.12)
	# the ground under the arch, light seen through
	if _detail(1.0):
		_r(ax - ar, 0, ax + ar, 0.5, Color("8f8a7e"))
	# a ragged broken top edge of the old wall
	_poly([-9, 9.2, -9, 9.8, -7.4, 10.1, -6.4, 9.7, -4.6, 10.0, -3.0, 9.6, -1.2, 9.9, 1.6, 9.6, 1.6, 9.2], stone.darkened(0.08))
	# the squat square side tower
	var tx0 := 1.6
	var tx1 := 8.6
	_blocks(tx0, 0, tx1, 12.6, 1.4, 0.9, stone.lightened(0.04))
	_r(tx1 - 0.9, 0, tx1, 12.6, Color(0, 0, 0, 0.12)) # the shaded side
	_r(tx0 - 0.3, 12.6, tx1 + 0.3, 13.2, stone.darkened(0.15))
	_poly([tx0 - 0.5, 13.2, tx1 + 0.5, 13.2, (tx0 + tx1) * 0.5, 16.0], SLATE)
	_poly([tx0 - 0.5, 13.2, (tx0 + tx1) * 0.5, 16.0, (tx0 + tx1) * 0.5 - 0.6, 13.2], SLATE.lightened(0.15))
	for wx in [3.6, 6.6]: # small round-arched Roman windows
		for wy in [6.0, 9.6]:
			_poly([wx - 0.45, wy, wx + 0.45, wy, wx + 0.45, wy + 0.9] + _arc(wx, wy + 0.9, 0.45, 0.45, 0, PI, 6), Color("2e2a26"))
	if _detail(1.4):
		_l(-9, 0, -9, 9.8, sd, 0.12)
	_legionary(-10.2, 3.6)

## The arches of a stone bridge: low round arches over x0..x1 springing from boat-shaped piers, deck at `top`.
static func _bridge_arches(xs: Array, top: float, stone: Color) -> void:
	var sd := stone.darkened(0.25)
	var gap := Color("3a5a72")
	var spring := 2.8
	_r(xs[0], 1.2, xs[xs.size() - 1], top, stone)
	for k in xs.size() - 1:
		var a: float = xs[k] + 0.9
		var b: float = xs[k + 1] - 0.9
		var cx := (a + b) * 0.5
		var r := (b - a) * 0.5
		var rise := minf(r * 1.05, top - spring - 1.6)
		_poly([a, 0.9, b, 0.9, b, spring] + _arc(cx, spring, r, rise, 0, PI, 12) + [a, spring], gap)
		if _detail(1.0):
			_pl(_arc(cx, spring, r + 0.5, rise + 0.5, 0, PI, 12), sd, 0.18)
	# the boat-shaped piers: a pointed cutwater with a little sloped cap at the waterline
	for k in range(1, xs.size() - 1):
		var x: float = xs[k]
		_poly([x - 1.6, 0.4, x + 1.6, 0.4, x + 1.6, 1.9, x, 3.1, x - 1.6, 1.9], stone.lightened(0.08))
		_poly([x, 0.4, x + 1.6, 0.4, x + 1.6, 1.9, x, 3.1], stone.darkened(0.08))

## Regensburg's Stone Bridge: a long row of low round arches on boat-shaped piers over the Danube, the dark-roofed
## bridge tower gate at the old town end, the town roofs and the cathedral's two openwork spires rising behind.
static func _steinerne_bruecke() -> void:
	var stone := Color("b4a68a")
	var roofs := [TILE, TILE.darkened(0.12), Color("9a4a34"), TILE.lightened(0.08)]
	# the cathedral behind the town
	_dom_towers(2.0, 7.4, 50.0, DOM.darkened(0.04))
	_r(-2.0, 8, 6.0, 25, DOM.darkened(0.1))
	_poly([-2.0, 25, 6.0, 25, 2, 30], DOM.darkened(0.1))
	_lancet(0.6, 3.4, 17, 24, HOLE)
	# the old town: tall gabled houses with steep red roofs
	var hx := [-16.0, -12.0, -8.5, -4.0, 0.0, 4.5, 8.0, 12.0, 16.0, 20.0, 24.0, 28.0]
	var hh := [15.0, 17.5, 14.5, 18.0, 15.5, 17.0, 14.0, 18.5, 15.0, 17.0, 16.0]
	for k in hh.size():
		var x0: float = hx[k]
		var x1: float = hx[k + 1]
		var h: float = hh[k]
		var wall := PLASTER if k % 3 != 1 else Color("ecc49a")
		if k % 4 == 3:
			wall = Color("dfe0cf")
		_r(x0, 4, x1, h, wall)
		_poly([x0 - 0.2, h, x1 + 0.2, h, (x0 + x1) * 0.5, h + (x1 - x0) * 0.75], roofs[k % 4])
		if _detail(1.2):
			_windows(x0 + 0.6, x1 - 0.6, h - 3.4, h - 1.4, 2, WIN)
	# the great Salzstadel with its huge steep roof beside the tower
	_r(28, 4, 45, 13, PLASTER.darkened(0.05))
	_poly([27.6, 13, 45.4, 13, 43.0, 23, 30.0, 23], TILE.darkened(0.06))
	_poly([27.6, 13, 30.0, 23, 31.4, 23, 29.4, 13], TILE.lightened(0.08))
	_windows(29, 44, 7.5, 10.5, 6, WIN)
	if _detail(1.2):
		for k in 3:
			for x in [33.0, 36.5, 40.0]:
				_r(x - 0.4, 14.5 + k * 2.6, x + 0.4, 15.5 + k * 2.6, TILE.darkened(0.35))
	# the river
	_r(-45, 0, 45, 3.0, WATER)
	# the bridge: a long row of arches on boat-shaped piers
	var xs := [-45.0, -36.9, -28.8, -20.7, -12.6, -4.5, 3.6, 11.7, 21.0]
	var top := 9.6
	_bridge_arches(xs, top, stone)
	_r(-45, top, 21, top + 0.6, stone.darkened(0.12))
	_r(-45, top + 0.6, 21, top + 1.8, stone.lightened(0.06)) # the parapet
	if _detail(1.6):
		for k in 33:
			var x := -44.0 + k * 2.0
			_l(x, top + 0.7, x, top + 1.7, stone.darkened(0.12), 0.08)
	# the Brückturm: a tall square gate tower, a big gate arch, a dark hipped roof with a lantern
	var t0 := 19.0
	var t1 := 28.0
	var tm := (t0 + t1) * 0.5
	var ts := Color("c9b994")
	_r(t0, 0.4, t1, 27, ts)
	_r(t1 - 1.6, 0.4, t1, 27, ts.darkened(0.12))
	_r(t0, 0.4, t1, 2.4, ts.darkened(0.2)) # the footing in the water
	_poly([t0 + 2.0, top + 0.6, t1 - 2.0, top + 0.6, t1 - 2.0, top + 4.0] + _arc(tm, top + 4.0, tm - t0 - 2.0, 2.2, 0, PI, 8) + [t0 + 2.0, top + 4.0], Color("2e2a26"))
	_windows(t0 + 1.2, t1 - 1.2, 22.4, 25.0, 2, WIN)
	_c(tm, 19.0, 1.5, Color("f2efe6")) # the clock
	if _detail(1.2):
		_l(tm, 19.0, tm, 20.1, LandmarkPainter.DARK, 0.18)
		_l(tm, 19.0, tm + 0.8, 19.0, LandmarkPainter.DARK, 0.18)
	_r(t0 - 0.4, 27, t1 + 0.4, 27.7, ts.darkened(0.15))
	_poly([t0 - 0.6, 27.7, t1 + 0.6, 27.7, t1 - 1.6, 34, t0 + 1.6, 34], SLATE)
	_poly([t0 - 0.6, 27.7, t0 + 1.6, 34, t0 + 3.0, 34, t0 + 1.2, 27.7], SLATE.lightened(0.15))
	_r(tm - 1.0, 34, tm + 1.0, 35.6, SLATE.darkened(0.1))
	_poly([tm - 1.3, 35.6, tm + 1.3, 35.6, tm, 39.0], SLATE.darkened(0.1))
	if _detail(1.0):
		_poly([tm - 0.8, 30.0, tm + 0.8, 30.0, tm + 0.8, 31.6, tm, 32.4, tm - 0.8, 31.6], Color("e8dcb8")) # dormer
	# glints on the water
	if _detail(0.8):
		for p in [[-40.0, 1.2], [-24.0, 0.8], [-8.0, 1.4], [8.0, 0.9], [34.0, 1.6], [40.0, 0.7]]:
			_l(p[0], p[1], p[0] + 4.0, p[1], WATER_L, 0.25)

## The cathedral's two west towers centred on cx, each `tw` wide at its base, the openwork spire tips at `top`.
static func _dom_towers(cx: float, tw: float, top: float, stone: Color) -> void:
	var gap := tw * 0.55
	var body := top * 0.52 # square tower body, then the octagon, then the spire
	var oct := top * 0.66
	for side in [-1.0, 1.0]:
		var x: float = cx + side * (gap + tw * 0.5)
		_r(x - tw * 0.5, 0, x + tw * 0.5, body, stone)
		_r(x - tw * 0.5, 0, x - tw * 0.5 + tw * 0.14, body, stone.darkened(0.1)) # buttress
		_r(x + tw * 0.5 - tw * 0.14, 0, x + tw * 0.5, body, stone.darkened(0.1))
		_lancet(x - tw * 0.24, x + tw * 0.24, body * 0.62, body * 0.92, HOLE)
		# the octagon storey with tall open lancets
		var ow := tw * 0.4
		_r(x - ow, body, x + ow, oct, stone)
		_lancet(x - ow * 0.62, x - ow * 0.08, body + 0.6, oct - 0.4, HOLE)
		_lancet(x + ow * 0.08, x + ow * 0.62, body + 0.6, oct - 0.4, HOLE)
		for px in [x - ow - tw * 0.06, x + ow + tw * 0.06]: # corner pinnacles
			_r(px - tw * 0.05, body - 0.2, px + tw * 0.05, oct, stone)
			_poly([px - tw * 0.07, oct, px + tw * 0.07, oct, px, oct + tw * 0.5], stone)
		# the openwork spire: a slender stone pyramid pierced by rows of tracery holes, crockets on its edges
		var sb := ow * 0.95
		_poly([x - sb, oct, x + sb, oct, x, top], stone)
		_poly([x - sb, oct, x - sb * 0.5, oct, x, top], stone.lightened(0.08))
		var rows := 6
		for k in rows:
			var y0 := oct + (top - oct) * (k + 0.15) / (rows + 0.6)
			var y1 := oct + (top - oct) * (k + 0.85) / (rows + 0.6)
			var hw := sb * (1.0 - (y1 - oct) / (top - oct)) * 0.7
			if hw < 0.15:
				break
			_poly([x - hw, y0, x - hw * 0.2, y0, x - hw * 0.2, y1 - (y1 - y0) * 0.25, x - hw * 0.6, y1], HOLE)
			_poly([x + hw * 0.2, y0, x + hw, y0, x + hw * 0.6, y1, x + hw * 0.2, y1 - (y1 - y0) * 0.25], HOLE)
		if _detail(1.2):
			for k in 7:
				var t := (k + 0.5) / 7.5
				var y := oct + (top - oct) * t
				var hw := sb * (1.0 - t)
				_c(x - hw - 0.12, y, 0.22 + hw * 0.06, stone)
				_c(x + hw + 0.12, y, 0.22 + hw * 0.06, stone)
		# the finial cross-flower
		_l(x, top - 0.4, x, top + 1.2, stone, 0.25)
		_l(x - 0.6, top + 0.5, x + 0.6, top + 0.5, stone, 0.22)

## St. Peter's Cathedral, Regensburg: the pale Gothic west front, two towers carrying tall openwork spires, the
## great pointed window over the triangular porch, a small rose in the gable.
static func _regensburg_dom() -> void:
	var s := DOM
	var sd := s.darkened(0.14)
	_dom_towers(0.0, 12.0, 59.0, s)
	# the middle between the towers: the gable with its big window and rose
	_r(-6.6, 0, 6.6, 27, s.darkened(0.03))
	_poly([-6.6, 27, 6.6, 27, 0, 34], s.darkened(0.03))
	_lancet(-3.6, 3.6, 12.5, 25.5, HOLE)
	if _detail(1.0):
		_l(-1.2, 12.5, -1.2, 21.5, s, 0.18)
		_l(1.2, 12.5, 1.2, 21.5, s, 0.18)
		_c(0, 23.0, 1.3, s)
		_c(0, 23.0, 0.8, HOLE)
	_c(0, 29.8, 1.9, s.lightened(0.05)) # the rose in the gable
	_c(0, 29.8, 1.5, HOLE)
	if _detail(1.1):
		for k in 8:
			var a := k * PI / 4.0
			_l(0, 29.8, cos(a) * 1.5, 29.8 + sin(a) * 1.5, s, 0.14)
		_c(0, 29.8, 0.35, s)
	# the gallery of statues across the front
	_r(-18, 10.2, 18, 11.2, sd)
	if _detail(1.3):
		for k in 17:
			var x := -16.0 + k * 2.0
			_r(x - 0.25, 11.2, x + 0.25, 12.2, sd)
			_c(x, 12.4, 0.25, sd)
	# the triangular porch in front of the main portal
	_poly([-5.4, 0, 5.4, 0, 5.4, 6.4, 0, 10.0, -5.4, 6.4], s.lightened(0.05))
	_poly(_pointed(-2.4, 2.4, 4.2, 7.6) + [2.4, 0, -2.4, 0], HOLE)
	_poly([-4.6, 6.4, -4.0, 6.4, -4.3, 9.0], s)
	_poly([4.0, 6.4, 4.6, 6.4, 4.3, 9.0], s)
	_l(0, 10.0, 0, 11.4, s, 0.25)
	# side portals in the towers
	for x in [-13.0, 13.0]:
		_poly([x - 2.4, 0, x + 2.4, 0, x + 2.4, 8.2, x, 9.4, x - 2.4, 8.2], s.darkened(0.06))
		_poly(_pointed(x - 1.5, x + 1.5, 3.6, 6.8) + [x + 1.5, 0, x - 1.5, 0], HOLE)
