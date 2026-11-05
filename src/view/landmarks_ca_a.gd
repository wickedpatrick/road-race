class_name LandmarksCaA
extends RefCounted
## Canadian landmarks, drawn with LandmarkPainter's helpers (metres from the base point, y up).

const WHITE := Color("f4f2ea")
const WATER := Color("3f7fb5")
const WATER_L := Color("9cc8e6")
const GRASS := Color("6f9a48")
const PINE := Color("2f5a36")
const SPRUCE := Color("24452e")
const WOOD := Color("7a5634")
const DARK := Color("2e3238")
const WIN := Color("3a4048")
const SNOW := Color("f4f7fa")
const SNOW_S := Color("c9d6e4")
const ROCK := Color("8a8f96")
const FAR := Color("8fa3b8")
const RED := Color("d0312d")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"canada_place": _canada_place()
		"lions_gate_bridge": _lions_gate_bridge()
		"totem_pole": _totem_pole()
		"inukshuk": _inukshuk()
		"peak2peak_gondola": _peak2peak_gondola()
		"bighorn_sheep": _bighorn_sheep()
		"ogopogo": _ogopogo()
		"okanagan_vineyard": _okanagan_vineyard()
		"mr_pg": _mr_pg()
		"mile_zero_post": _mile_zero_post()
		"ss_klondike": _ss_klondike()
		"northern_lights": _northern_lights()
		"sign_post_forest": _sign_post_forest()
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

## A dark spruce: a narrow stem and four stacked triangles, `h` tall.
static func _spruce(x: float, y: float, h: float, col: Color) -> void:
	_r(x - h * 0.03, y, x + h * 0.03, y + h * 0.15, WOOD)
	for k in 4:
		var y0 := y + h * (0.1 + k * 0.2)
		var w := h * (0.22 - k * 0.04)
		_poly([x - w, y0, x + w, y0, x, y0 + h * 0.35], col)
		_poly([x - w, y0, x, y0, x, y0 + h * 0.35], col.lightened(0.08))

## Strokes of one capital letter or digit in a unit box (x right, y up), as polylines.
static func _letter(ch: String) -> Array:
	match ch:
		"M": return [[0, 0, 0, 1, 0.5, 0.45, 1, 1, 1, 0]]
		"I": return [[0.5, 0, 0.5, 1]]
		"L": return [[0, 1, 0, 0, 0.9, 0]]
		"E": return [[0.9, 1, 0, 1, 0, 0, 0.9, 0], [0, 0.5, 0.7, 0.5]]
		"A": return [[0, 0, 0.5, 1, 1, 0], [0.22, 0.4, 0.78, 0.4]]
		"S": return [[1, 0.9, 0.7, 1, 0.3, 1, 0, 0.8, 0.1, 0.55, 0.9, 0.45, 1, 0.2, 0.7, 0, 0.3, 0, 0, 0.1]]
		"K": return [[0, 0, 0, 1], [1, 1, 0, 0.45], [0.3, 0.6, 1, 0]]
		"H": return [[0, 0, 0, 1], [1, 0, 1, 1], [0, 0.5, 1, 0.5]]
		"W": return [[0, 1, 0.25, 0, 0.5, 0.65, 0.75, 0, 1, 1]]
		"Y": return [[0, 1, 0.5, 0.5, 1, 1], [0.5, 0.5, 0.5, 0]]
		"G": return [[1, 0.85, 0.7, 1, 0.3, 1, 0, 0.75, 0, 0.25, 0.3, 0, 0.7, 0, 1, 0.25, 1, 0.5, 0.55, 0.5]]
		"P": return [[0, 0, 0, 1, 0.8, 1, 1, 0.85, 1, 0.65, 0.8, 0.5, 0, 0.5]]
		"R": return [[0, 0, 0, 1, 0.8, 1, 1, 0.85, 1, 0.65, 0.8, 0.5, 0, 0.5], [0.45, 0.5, 1, 0]]
		"0": return [_arc(0.5, 0.5, 0.5, 0.5, 0, TAU, 14)]
	return []

## A word written with _letter strokes, letters `lw` wide and `lh` tall, its lower left corner at (x, y).
static func _word(s: String, x: float, y: float, lw: float, lh: float, col: Color, w: float) -> void:
	for k in s.length():
		var x0 := x + k * lw * 1.45
		for st in _letter(s[k]):
			var pts := []
			for j in range(0, st.size(), 2):
				pts.append_array([x0 + st[j] * lw, y + st[j + 1] * lh])
			_pl(pts, col, w)

## Ripples on a strip of water.
static func _ripples(pts: Array, ln: float, y: float) -> void:
	if not _detail(1.0):
		return
	for x in pts:
		_r(x, y, x + ln, y + 0.3, WATER_L)

## Canada Place on Vancouver's harbour: the long white pier building with its five white fabric sails, the glassy
## hotel tower behind and the North Shore mountains far away over the water.
static func _canada_place() -> void:
	# the North Shore mountains
	_poly([-40, 6, -40, 16, -30, 22, -20, 19, -8, 25, 4, 21, 16, 26, 28, 20, 40, 23, 40, 6], FAR)
	_poly([-8, 25, -5, 23, -9, 22.5, -11, 23.6], SNOW)
	_poly([16, 26, 19, 24, 14, 23.6, 12.5, 24.4], SNOW)
	_r(-40, 0, 40, 4, WATER)
	_ripples([-36, -16, 6, 26], 6, 1.2)
	# the hotel tower at the land end
	var glass := Color("6f93ad")
	_r(14, 4, 34, 24, glass)
	_r(14, 24, 34, 25, Color("e8e6e0"))
	if _detail(1.0):
		for k in 9:
			_l(14, 6 + k * 2.0, 34, 6 + k * 2.0, glass.lightened(0.25), 0.15)
	# the pier: a long white hull-like building over the water
	_poly([-38, 3, 36, 3, 36, 9.5, -34, 9.5], Color("e4e4de"))
	_r(-34, 9.5, 36, 10.5, Color("c7ccd0"))
	_windows(-32, 34, 5, 8, 22, Color("5d7f99"))
	_r(-38, 2.5, 36, 3.2, Color("8b8f92"))
	# the five sails, each a tall tent with curved sides, white on the sunny face
	var sail_x := [-30.0, -22.0, -14.0, -6.0, 2.0]
	var sail_h := [21.0, 25.0, 27.0, 25.0, 21.0]
	for k in 5:
		var x: float = sail_x[k]
		var top: float = sail_h[k]
		var lft := [x - 5, 10.5]
		lft.append_array(_arc(x - 5, top, 5, top - 10.5, -PI * 0.5, 0, 6).slice(2))
		lft.append_array([x, 10.5])
		var rgt := [x, 10.5, x, top]
		rgt.append_array(_arc(x + 5, top, 5, top - 10.5, PI, PI * 1.5, 6).slice(2))
		_poly(lft, WHITE)
		_poly(rgt, Color("d6dde3"))
		_l(x, 10.5, x, top + 1.2, Color("9aa3aa"), 0.25)

## Lions Gate Bridge: the slim green suspension towers and their sweeping cables high over the First Narrows,
## Stanley Park's dark forest on one side and the North Shore mountains behind.
static func _lions_gate_bridge() -> void:
	_poly([-45, 6, -45, 22, -34, 30, -22, 26, -10, 34, 2, 30, 14, 37, 28, 30, 45, 33, 45, 6], FAR)
	_poly([-10, 34, -7, 32, -11, 31.2, -13, 32.2], SNOW)
	_poly([14, 37, 17.5, 34.5, 12.5, 34, 10.5, 35], SNOW)
	_r(-45, 0, 45, 5, WATER)
	_ripples([-12, 6, 22], 6, 2)
	# Stanley Park on the left, the North Shore bank on the right
	_poly([-45, 0, -45, 20, -40, 21, -34, 18, -28, 12, -25, 4, -23, 0], PINE)
	if _detail(0.8):
		for p in [[-43, 17, 7], [-38, 15, 7], [-33, 11, 6], [-29, 6, 5]]:
			_spruce(p[0], p[1], p[2], SPRUCE)
	_poly([45, 0, 45, 14, 38, 13, 33, 8, 30, 0], PINE.lightened(0.08))
	var g := Color("3d7a58")
	var gd := g.darkened(0.25)
	var deck_y := 15.0
	_r(-45, deck_y - 1.2, 45, deck_y, gd)
	_r(-45, deck_y, 45, deck_y + 0.4, g.lightened(0.2))
	var tx := [-17.0, 17.0]
	var top := 38.0
	# the main cables: one span between the towers, the side spans down to the banks
	var cab := []
	for k in 21:
		var t := float(k) / 20.0
		var s := (t - 0.5) * 2.0
		cab.append_array([lerpf(tx[0], tx[1], t), deck_y + 1.0 + (top - 1.5 - deck_y - 1.0) * s * s])
	_pl(cab, g.lightened(0.1), 0.45)
	_pl([-45, deck_y + 6, -32, deck_y + 12, -17, top - 1.5], g.lightened(0.1), 0.45)
	_pl([17, top - 1.5, 32, deck_y + 12, 45, deck_y + 6], g.lightened(0.1), 0.45)
	if _detail(0.8):
		for j in range(2, cab.size() - 2, 2):
			_l(cab[j], deck_y + 0.4, cab[j], cab[j + 1], g, 0.1)
	# the towers: two slim legs with a cross of braces between them
	for x in tx:
		_r(x - 2.6, 0, x + 2.6, 2, Color("9a9a94"))
		for d in [-1.8, 1.8]:
			_poly([x + d - 0.6, 2, x + d + 0.6, 2, x + d + 0.45, top, x + d - 0.45, top], g)
		_l(x - 1.5, deck_y + 2, x + 1.5, top - 4, g, 0.35)
		_l(x + 1.5, deck_y + 2, x - 1.5, top - 4, g, 0.35)
		_r(x - 2.2, deck_y + 1, x + 2.2, deck_y + 2, g)
		_r(x - 2.4, top - 1, x + 2.4, top, gd)
		_r(x - 1.8, deck_y - 6, x + 1.8, deck_y - 5, g)

## A Haida-style totem pole: carved animals stacked up a cedar pole (a bear at the foot, a frog-faced figure in
## the middle) and a thunderbird with outspread wings at the top, in black, red and turquoise.
static func _totem_pole() -> void:
	var cedar := Color("a86a42")
	var blk := Color("1f1d1c")
	var teal := Color("2f9a96")
	_r(-7, 0, 7, 0.6, GRASS)
	_r(-1.7, 0.4, 1.7, 26, cedar)
	_r(0.9, 0.4, 1.7, 26, cedar.darkened(0.15))
	# three carved faces, one above the other
	for k in 3:
		var y0 := 1.0 + k * 7.6
		var cy := y0 + 4.2
		# brow and eye shapes
		_r(-1.7, cy + 1.5, 1.7, cy + 2.1, blk)
		for sx in [-0.85, 0.85]:
			_ell(sx, cy + 0.6, 0.7, 0.45, 0, blk)
			_ell(sx, cy + 0.6, 0.45, 0.28, 0, WHITE)
			_c(sx, cy + 0.6, 0.18, blk)
		# the nose (or beak) and the mouth
		if k == 1:
			_poly([-0.5, cy + 0.2, 0.5, cy + 0.2, 0, cy - 1.6], RED)
		else:
			_ell(0, cy - 0.6, 0.55, 0.7, 0, RED)
		_r(-1.3, cy - 2.4, 1.3, cy - 1.7, blk)
		if _detail(2.0):
			for t in 4:
				_r(-1.0 + t * 0.6, cy - 2.3, -0.75 + t * 0.6, cy - 1.8, WHITE)
		# the ears or paws at the sides
		_poly([-1.7, cy + 2.1, -2.6, cy + 3.0, -2.2, cy + 1.6], teal if k != 1 else RED)
		_poly([1.7, cy + 2.1, 2.6, cy + 3.0, 2.2, cy + 1.6], teal if k != 1 else RED)
		if k == 0:
			_ell(-2.1, cy - 2.6, 0.6, 1.0, 0.3, blk)
			_ell(2.1, cy - 2.6, 0.6, 1.0, -0.3, blk)
		_r(-1.7, y0 - 0.2, 1.7, y0 + 0.3, blk)
	# the thunderbird on top: the head with its curved beak and the wide wings
	var wy := 24.5
	for sgn in [-1.0, 1.0]:
		_poly([sgn * 1.2, wy - 0.8, sgn * 1.2, wy + 3.0, sgn * 4.0, wy + 5.6, sgn * 7.0, wy + 6.4, sgn * 6.4, wy + 4.8,
			sgn * 7.0, wy + 3.8, sgn * 6.0, wy + 2.8, sgn * 6.4, wy + 1.6, sgn * 4.6, wy + 1.0, sgn * 3.0, wy - 0.6], blk)
		_poly([sgn * 1.8, wy + 2.4, sgn * 4.2, wy + 4.6, sgn * 5.6, wy + 5.0, sgn * 4.4, wy + 3.4, sgn * 1.8, wy + 1.0],
			teal)
		_poly([sgn * 2.2, wy + 0.4, sgn * 4.6, wy + 2.4, sgn * 5.4, wy + 2.0, sgn * 3.6, wy + 0.4], RED)
	_ell(0, wy + 2.6, 1.5, 2.6, 0, cedar)
	_c(-0.6, wy + 3.4, 0.35, blk)
	_c(0.6, wy + 3.4, 0.35, blk)
	_c(-0.6, wy + 3.4, 0.14, WHITE)
	_c(0.6, wy + 3.4, 0.14, WHITE)
	_poly([-0.7, wy + 2.6, 0.7, wy + 2.6, 0.6, wy + 1.0, 0, wy + 0.2], blk)
	_poly([-1.3, wy + 4.4, 0, wy + 6.2, 1.3, wy + 4.4], blk)

## One rough grey stone block of an inukshuk, a touch lighter on top.
static func _stone(x0: float, y0: float, x1: float, y1: float, col: Color) -> void:
	var j := (x1 - x0) * 0.08
	_poly([x0 + j, y0, x1, y0 + j * 0.5, x1 - j * 0.5, y1, x0, y1 - j * 0.6], col)
	var h := (y1 - y0) * 0.3
	_poly([x0 + j * 0.3, y1 - h, x1 - j * 0.6, y1 - h, x1 - j * 0.5, y1, x0 + j * 0.2, y1 - h * 0.2], col.lightened(0.15))

## The Whistler inukshuk: a stone figure of stacked grey slabs (two legs, a hip slab, a body, wide arms and a
## head) standing on a snowy ridge with a white peak behind.
static func _inukshuk() -> void:
	_poly([-10, 3, -10, 8, -6, 11, -3, 15, 0, 17.5, 2, 16, 5, 13, 8, 10.5, 10, 11, 10, 3], FAR)
	_poly([-3, 15, 0, 17.5, 2, 16, 3.6, 14, 1.6, 14.4, 0, 13.6, -1.8, 14.6], SNOW)
	_poly([0, 17.5, 2, 16, 3.6, 14, 1.6, 14.4], SNOW_S)
	_poly([-10, 0, -10, 3.5, -4, 4, 4, 3.2, 10, 3.8, 10, 0], SNOW)
	_poly([-10, 0, -10, 1.6, 10, 1.3, 10, 0], SNOW_S)
	var s := Color("6c7077")
	_stone(-2.6, 2.5, -1.0, 6.2, s.darkened(0.1))
	_stone(1.0, 2.5, 2.6, 6.2, s)
	_stone(-3.2, 6.2, 3.2, 7.4, s.lightened(0.05))
	_stone(-1.8, 7.4, 1.8, 9.6, s)
	_stone(-5.6, 9.6, 5.6, 10.8, s.darkened(0.05))
	_stone(-1.4, 10.8, 1.4, 12.8, s.lightened(0.05))
	_stone(-1.0, 12.8, 1.0, 13.4, s)
	if _detail(1.0):
		for sp in [[-6, 2.5, 4], [6.5, 2.8, 5], [8.5, 2.8, 3.5]]:
			_spruce(sp[0], sp[1], sp[2], SPRUCE)

## One red Peak 2 Peak cabin hanging from the cable at (x, y).
static func _cabin(x: float, y: float, s: float) -> void:
	_l(x, y, x, y - 1.6 * s, DARK, 0.25 * s)
	_r(x - 0.8 * s, y - 1.8 * s, x + 0.8 * s, y - 1.5 * s, DARK)
	_poly([x - 2.0 * s, y - 1.8 * s, x + 2.0 * s, y - 1.8 * s, x + 2.2 * s, y - 4.8 * s, x - 2.2 * s,
		y - 4.8 * s], RED)
	_r(x - 1.7 * s, y - 3.4 * s, x + 1.7 * s, y - 2.2 * s, Color("bcd6e6"))
	_r(x - 2.2 * s, y - 4.8 * s, x + 2.2 * s, y - 4.3 * s, RED.darkened(0.25))

## The Peak 2 Peak Gondola: a red cabin riding the long sagging cable between the snowy summits of Whistler and
## Blackcomb, with a lattice tower on each side and dark forest in the valley.
static func _peak2peak_gondola() -> void:
	var rock := Color("7f8fa6")
	_poly([-45, 0, -45, 34, -38, 40, -33, 46, -29, 44, -20, 32, -10, 18, -4, 10, 4, 10, 12, 20, 22, 34, 30, 42,
		34, 45, 39, 39, 45, 34, 45, 0], rock)
	_poly([-45, 30, -45, 34, -38, 40, -33, 46, -29, 44, -24, 38, -27, 37, -30, 39, -34, 34, -38, 36, -42, 32], SNOW)
	_poly([22, 34, 30, 42, 34, 45, 39, 39, 45, 34, 45, 31, 41, 34, 37, 31, 33, 36, 29, 33, 25, 35], SNOW)
	_poly([-33, 46, -29, 44, -24, 38, -27, 37, -30, 39], SNOW_S)
	_poly([34, 45, 39, 39, 45, 34, 45, 31, 41, 34], SNOW_S)
	# the forested valley
	_poly([-45, 0, -45, 14, -30, 16, -16, 11, -4, 6, 6, 6, 18, 12, 32, 15, 45, 13, 45, 0], PINE)
	if _detail(0.7):
		for p in [[-40, 13, 7], [-33, 13, 8], [-25, 11, 6], [-14, 8, 6], [14, 9, 6], [24, 11, 7], [33, 12, 8],
				[40, 11, 6]]:
			_spruce(p[0], p[1], p[2], SPRUCE)
	_r(-45, 0, 45, 1.2, GRASS)
	# a lattice tower on each shoulder
	var tw := Color("9aa0a6")
	var ta := [-30.0, 36.0]
	for x in ta:
		var gy := 36.0 if x < 0 else 38.0
		_poly([x - 1.2, gy, x + 1.2, gy, x + 0.4, gy + 8, x - 0.4, gy + 8], tw)
		_r(x - 2.4, gy + 8, x + 2.4, gy + 8.6, tw.darkened(0.2))
	# the long cable, two strands sagging across the valley
	for off in [0.0, 0.6]:
		var cab := []
		for k in 25:
			var t := float(k) / 24.0
			cab.append_array([lerpf(ta[0], ta[1], t), lerpf(44.6, 46.6, t) - off - 18.0 * 4.0 * t * (1.0 - t)])
		_pl(cab, DARK, 0.15)
	# the cabins: the big one near the middle, a smaller one far along
	var t1 := 0.42
	_cabin(lerpf(ta[0], ta[1], t1), lerpf(44.6, 46.6, t1) - 18.0 * 4.0 * t1 * (1.0 - t1), 2.2)
	var t2 := 0.85
	_cabin(lerpf(ta[0], ta[1], t2), lerpf(44.6, 46.6, t2) - 18.0 * 4.0 * t2 * (1.0 - t2), 1.4)

## A bighorn ram standing on a rock ledge above the Thompson valley, with its great curled horns, a white rump and
## a white muzzle.
static func _bighorn_sheep() -> void:
	var stone := Color("a08c74")
	_poly([-10, 0, -10, 4.5, -7, 6, -2, 6.3, 3, 5.8, 7, 4.5, 10, 2.5, 10, 0], stone)
	_poly([-10, 4.5, -7, 6, -2, 6.3, 3, 5.8, 7, 4.5, 4, 4.4, -1, 5.0, -6, 4.8], stone.lightened(0.18))
	if _detail(1.0):
		_l(-6, 4.2, -4, 1.0, stone.darkened(0.2), 0.2)
		_l(4, 4.0, 6, 0.8, stone.darkened(0.2), 0.2)
	var fur := Color("8a6440")
	var fd := fur.darkened(0.2)
	var by := 6.0
	# the legs (far ones darker), the body and the white rump
	for p in [[-3.6, fd], [1.8, fd], [-2.6, fur], [2.8, fur]]:
		_r(p[0] - 0.3, by, p[0] + 0.3, by + 3.0, p[1])
		_r(p[0] - 0.32, by, p[0] + 0.32, by + 0.4, DARK)
	_ell(-0.4, by + 4.0, 4.6, 1.9, 0, fur)
	_ell(-4.4, by + 3.8, 0.9, 1.4, 0, Color("efe6d6"))
	_r(-2.6, by + 2.2, 2.4, by + 2.7, Color("e6dccb"))
	# the neck and the head, facing right
	_poly([2.2, by + 3.4, 4.2, by + 3.8, 5.6, by + 6.4, 4.2, by + 6.8, 2.6, by + 5.4], fur)
	_ell(5.4, by + 6.6, 1.5, 0.85, -0.35, fur)
	_ell(6.5, by + 6.1, 0.55, 0.45, 0, Color("efe6d6"))
	_c(5.4, by + 7.0, 0.16, DARK)
	_poly([4.1, by + 7.3, 4.5, by + 7.6, 4.3, by + 7.0], fd)
	# the big curled horn: a thick spiral sweeping back and round below the ear
	var horn := Color("c7b48c")
	var sp := []
	for k in 15:
		var t := float(k) / 14.0
		var a := lerpf(PI * 0.35, PI * 2.1, t)
		var rr := lerpf(1.9, 0.6, t)
		sp.append_array([4.3 + cos(a) * rr, by + 6.3 + sin(a) * rr])
	_pl(sp, horn.darkened(0.15), 0.85)
	_pl(sp, horn, 0.55)

## Ogopogo, the lake monster of Okanagan Lake: a friendly green serpent swimming in humps through the blue water,
## head up with its little horns, the dry hills of the valley behind.
static func _ogopogo() -> void:
	_poly([-25, 4, -25, 9, -16, 12.5, -6, 10, 4, 13, 14, 10.5, 25, 12, 25, 4], Color("c9b38a"))
	_poly([-25, 4, -25, 7, -12, 8.5, 2, 7, 16, 8.5, 25, 7, 25, 4], Color("a99368"))
	_r(-25, 0, 25, 5, WATER)
	var green := Color("3f9a4a")
	var light := Color("9ccf6a")
	# three humps out of the water, the tail curling up at the end
	for h in [[-14.0, 3.0], [-6.0, 3.6], [1.5, 3.2]]:
		var arc := _arc(h[0], 3.0, h[1], h[1], PI, 0, 10)
		_pl(arc, green, 2.0)
		if _detail(1.0):
			for k in range(2, arc.size() - 2, 4):
				_poly([arc[k] - 0.4, arc[k + 1] + 0.6, arc[k] + 0.4, arc[k + 1] + 0.6, arc[k], arc[k + 1] + 1.5], light)
	_pl([-21, 3.0, -21.5, 5.0, -20.2, 6.2, -19.0, 5.6], green, 1.0)
	_poly([-19.0, 5.6, -18.0, 6.6, -18.4, 5.0], green)
	# the neck rising out of the water and the head facing right
	_pl([6.5, 3.0, 7.5, 6.5, 9.0, 9.0], green, 2.0)
	_ell(10.6, 9.8, 2.4, 1.4, 0.15, green)
	_ell(12.4, 9.8, 1.2, 0.8, 0.15, light)
	_c(10.6, 10.7, 0.5, WHITE)
	_c(10.8, 10.7, 0.25, DARK)
	_poly([9.0, 10.6, 8.6, 12.4, 9.6, 11.0], light)
	_poly([10.2, 11.0, 10.2, 12.8, 11.0, 11.2], light)
	_l(11.4, 9.2, 13.4, 9.3, DARK, 0.15)
	# the water line over the humps
	_r(-25, 0, 25, 3.1, WATER)
	_ripples([-23, -10, -2, 5, 16], 4, 1.4)

## An Okanagan vineyard: neat green rows of vines with purple grapes running up a slope to a winery with a bell
## tower, over the blue lake and the dry brown hills across it.
static func _okanagan_vineyard() -> void:
	_poly([-35, 8, -35, 18, -24, 22, -12, 19, 0, 23, 12, 20, 24, 23, 35, 19, 35, 8], Color("bfa57c"))
	_r(-35, 6, 35, 11, WATER)
	_ripples([-28, -6, 14], 5, 8.5)
	# the slope of the vineyard
	_poly([-35, 0, -35, 9, -20, 11, -4, 10.5, 8, 9, 35, 7, 35, 0], Color("b9a26e"))
	# the winery and its bell tower
	var stucco := Color("efe3c6")
	var roof := Color("b4563a")
	_r(14, 7.5, 28, 12, stucco)
	_poly([13.4, 12, 28.6, 12, 26.5, 14, 15.5, 14], roof)
	_windows(15, 27, 8.8, 10.8, 5, Color("6a4a30"))
	_r(22, 12, 25, 20, stucco)
	_r(22.5, 17, 24.5, 19, DARK)
	_poly([21.6, 20, 25.4, 20, 23.5, 22.5], roof)
	# rows of vines, each a green hedge on a post line with bunches of grapes
	var vine := Color("4f8a3a")
	var grape := Color("6a2f6e")
	for k in 6:
		var y := 8.0 - k * 1.45
		var x1 := 8.0 + k * 3.0
		_l(-35, y, x1, y - 0.5, Color("8a7454"), 0.25)
		_l(-35, y + 0.55, x1, y + 0.05, vine, 0.9 + k * 0.08)
		if _detail(0.9):
			var n := 9 + k
			for j in n:
				var gx := -33.0 + j * (x1 + 33.0) / n
				_c(gx, y + 0.1 - (gx + 35.0) / (x1 + 35.0) * 0.5, 0.3 + k * 0.03, grape)

## Mr. PG, Prince George's giant wooden-log man: log legs, a log body and arms, a round log-end head with a
## smiling face, and a yellow hard hat, standing on his plinth.
static func _mr_pg() -> void:
	var log_c := Color("b07a46")
	var bark := Color("6e4a2a")
	var ring := Color("e2bf86")
	# the plinth
	_r(-6, 0, 6, 2.2, Color("c8c2b4"))
	_r(-6, 2.2, 6, 2.6, Color("a8a294"))
	if _detail(1.0):
		_word("MR PG", -4.3, 0.6, 1.2, 1.1, Color("2f5a8a"), 0.25)
	# the legs: two upright logs
	for x in [-1.6, 1.6]:
		_r(x - 1.0, 2.6, x + 1.0, 9.5, log_c)
		_r(x + 0.5, 2.6, x + 1.0, 9.5, bark)
		_ell(x, 2.9, 1.4, 0.5, 0, bark)
	# the body: one big log
	_r(-3.2, 9.0, 3.2, 17.0, log_c)
	_r(2.2, 9.0, 3.2, 17.0, bark)
	if _detail(1.2):
		for y in [10.5, 12.5, 14.5]:
			_l(-2.8, y, 1.8, y + 0.3, bark, 0.15)
	# a blue belt band
	_r(-3.2, 10.8, 3.2, 11.5, Color("2f5a8a"))
	# the arms: logs held out and down, ending in log-end hands
	_poly([-3.2, 16.4, -3.2, 15.0, -6.4, 11.4, -7.4, 12.4], log_c)
	_poly([3.2, 16.4, 3.2, 15.0, 6.4, 11.4, 7.4, 12.4], log_c)
	_c(-6.9, 11.9, 0.8, ring)
	_c(6.9, 11.9, 0.8, ring)
	# the neck and the round log-end head with rings and a face
	_r(-0.8, 17.0, 0.8, 17.8, bark)
	_c(0, 20.0, 2.6, bark)
	_c(0, 20.0, 2.3, ring)
	if _detail(1.4):
		_pl(_arc(0, 20.0, 1.5, 1.5, 0, TAU, 14), ring.darkened(0.12), 0.1)
	_c(-0.8, 20.6, 0.28, DARK)
	_c(0.8, 20.6, 0.28, DARK)
	_pl(_arc(0, 19.9, 1.2, 0.9, PI * 1.15, PI * 1.85, 6), DARK, 0.2)
	# the yellow hard hat
	_poly(_arc(0, 21.6, 2.6, 2.2, 0, PI, 10), Color("f2c230"))
	_r(-3.4, 21.4, 3.4, 22.0, Color("e0a820"))
	_r(-0.3, 21.9, 0.3, 23.8, Color("e0a820"))

## The Mile 0 post of the Alaska Highway in Dawson Creek: a white wooden sign post with the "MILE 0 ALASKA HWY"
## board, flags flying on poles each side and flowers at its foot.
static func _mile_zero_post() -> void:
	_r(-8, 0, 8, 0.8, GRASS)
	_r(-8, 0, 8, 0.3, Color("6b6a66"))
	# the flagpoles with the maple leaf flag and the BC flag
	for p in [[-6.5, 0], [6.5, 1]]:
		var x: float = p[0]
		_l(x, 0.8, x, 12.5, Color("d8dde2"), 0.18)
		if p[1] == 0:
			_r(x, 10.3, x + 3, 12.2, Color("e8352f"))
			_r(x + 0.75, 10.3, x + 2.25, 12.2, WHITE)
			_poly([x + 1.5, 10.6, x + 1.95, 11.3, x + 1.75, 11.35, x + 1.95, 11.8, x + 1.5, 11.55, x + 1.05, 11.8,
				x + 1.25, 11.35, x + 1.05, 11.3], Color("e8352f"))
		else:
			_r(x - 3, 10.3, x, 12.2, Color("2a4a9a"))
			_r(x - 3, 11.6, x, 12.2, Color("e8352f"))
			_c(x - 1.5, 10.6, 0.7, Color("f2c230"))
	# the post itself: a white tapering column on a stone base
	_r(-1.6, 0.8, 1.6, 1.8, Color("9a948a"))
	_poly([-0.9, 1.8, 0.9, 1.8, 0.7, 7.0, -0.7, 7.0], WHITE)
	_r(0.3, 1.8, 0.7, 7.0, Color("d6d6d0"))
	# the board: white with a dark blue frame, MILE and a big 0, ALASKA HWY under
	var blue := Color("1f3f7a")
	_r(-4.6, 6.6, 4.6, 12.6, blue)
	_r(-4.2, 7.0, 4.2, 12.2, WHITE)
	_word("MILE", -3.7, 10.2, 0.8, 1.4, blue, 0.28)
	_pl(_arc(2.9, 10.9, 0.9, 1.4, 0, TAU, 16), blue, 0.45)
	if _detail(1.2):
		_word("ALASKA", -3.6, 7.6, 0.75, 1.0, RED, 0.2)
	else:
		_r(-3.6, 7.8, 3.6, 8.6, RED)
	_poly([-4.6, 12.6, 4.6, 12.6, 0, 13.8], blue)
	# flowers in the bed around the foot
	if _detail(0.9):
		for k in 9:
			var fx := -3.6 + k * 0.9
			_c(fx, 1.1 + (k % 2) * 0.3, 0.35, [Color("e8352f"), Color("f2c230"), Color("e57ac0")][k % 3])

## The SS Klondike: the big white sternwheeler resting on her timber cradle on the bank of the Yukon River, with
## her tall black funnel, the pilot house on top and the red paddle wheel at the stern.
static func _ss_klondike() -> void:
	_r(-30, 0, 30, 3, WATER)
	_ripples([-26, 10], 6, 1.2)
	_poly([-30, 2, -30, 4, 30, 4.5, 30, 2], GRASS)
	# the timber cradle
	if _detail(0.8):
		for k in 9:
			var x := -20.0 + k * 5.0
			_r(x - 0.8, 3.8, x + 0.8, 5.2, WOOD)
	else:
		_r(-21, 3.8, 21, 5.2, WOOD)
	var hull := Color("f2f0ea")
	var shade := Color("c9ccd0")
	var trim := Color("2f4f6e")
	# the long low hull, the bow raked up at the right
	_poly([-22, 5.2, 21, 5.2, 26, 7.6, 26, 8.4, -22, 8.4], hull)
	_r(-22, 7.8, 26, 8.4, trim)
	# the main deck with its open posts, the boiler deck above, the texas deck and the pilot house
	_r(-21, 8.4, 22, 11.4, hull)
	_r(-21, 11.4, 22.6, 11.9, shade)
	_r(-17, 11.9, 18, 14.6, hull)
	_r(-17.5, 14.6, 18.6, 15.1, shade)
	_r(-6, 15.1, 8, 16.9, hull)
	_r(-6.4, 16.9, 8.4, 17.3, shade)
	_r(1, 17.3, 6, 19.2, hull)
	_poly([0.4, 19.2, 6.6, 19.2, 5.8, 19.8, 1.2, 19.8], DARK)
	if _detail(1.0):
		for k in 22:
			_l(-20.5 + k * 2.0, 8.4, -20.5 + k * 2.0, 11.4, shade, 0.15)
		_windows(-16, 17, 12.6, 14.0, 14, WIN)
		_windows(-5.5, 7.5, 15.5, 16.5, 6, WIN)
		_windows(1.4, 5.6, 17.9, 18.8, 3, WIN)
	else:
		_r(-16, 12.6, 17, 14.0, WIN.lightened(0.3))
	# the tall black funnel in front of the pilot house
	_r(9.6, 14.6, 11.0, 20.0, DARK)
	_r(9.3, 20.0, 11.3, 20.6, DARK)
	# the red stern wheel at the back
	var wheel := Color("b8322a")
	_r(-28, 6.0, -21, 13.0, wheel)
	if _detail(0.9):
		for k in 6:
			_r(-28, 6.6 + k * 1.15, -21, 7.0 + k * 1.15, wheel.darkened(0.35))
	_r(-28, 12.6, -21, 13.4, hull)
	_l(-28, 6.0, -28, 13.0, DARK, 0.2)
	# the name on the bow
	_r(8, 9.4, 18, 10.6, trim)

## The northern lights over the Yukon: green curtains of aurora rippling across a starry night sky above a row of
## black spruces and the snow.
static func _northern_lights() -> void:
	var sky := Color("142446")
	_poly(_arc(0, 0, 35, 40, PI, 0, 20), sky)
	_poly(_arc(0, 0, 35, 22, PI, 0, 16), Color("1d3460"))
	if _detail(0.6):
		for p in [[-20, 33], [-8, 37], [6, 35], [18, 32], [25, 22], [-27, 20], [-14, 27], [12, 28], [0, 31], [28, 12],
				[-29, 10], [-4, 25]]:
			_c(p[0], p[1], 0.25, Color("f4f2d0"))
	# two aurora curtains: many thin rays standing on a wavy line, bright at the foot and fading up
	for band in [[11.0, 15.0, 3.0, 0.0, Color("4fe08a")], [17.0, 12.0, 2.4, 1.7, Color("7ff0b0")]]:
		var base: float = band[0]
		var tall: float = band[1]
		var amp: float = band[2]
		var ph: float = band[3]
		var col: Color = band[4]
		var n := 70
		for k in n:
			var x := -31.0 + k * 62.0 / (n - 1)
			var y := base + sin(x * 0.17 + ph) * amp + sin(x * 0.41 + ph) * amp * 0.35
			var lim := sqrt(maxf(0.0, 1.0 - (x / 35.0) * (x / 35.0))) * 39.0
			var top := minf(y + tall * (0.7 + 0.3 * sin(x * 0.9 + ph)), lim)
			_l(x, y, x, y + (top - y) * 0.45, Color(col, 0.55), 0.95)
			_l(x, y + (top - y) * 0.45, x, top, Color(col, 0.22), 0.95)
			_l(x, y, x, y + 1.0, Color(col.lightened(0.3), 0.7), 0.95)
		if _detail(1.0):
			for k in n:
				var x := -31.0 + k * 62.0 / (n - 1)
				var y := base + sin(x * 0.17 + ph) * amp + sin(x * 0.41 + ph) * amp * 0.35
				_l(x, y - 0.4, x, y, Color(1.0, 0.4, 0.6, 0.3), 0.95)
	# the snow and a row of black spruces
	_poly([-35, 0, -35, 4, -20, 5, 0, 4, 20, 5.2, 35, 4, 35, 0], Color("d8e0ea"))
	for p in [[-31, 3.6, 9], [-27, 4, 12], [-23, 4.4, 8], [-12, 4.2, 10], [-8.5, 4, 7], [5, 4.2, 9], [9, 4.6, 13],
			[13, 4.8, 8], [24, 4.8, 11], [28, 4.4, 8.5], [31.5, 4, 10]]:
		_spruce(p[0], p[1], p[2], Color("0c1418"))

## The Sign Post Forest at Watson Lake: rows of wooden posts crowded with colourful signs and licence plates
## left by travellers, spruces behind.
static func _sign_post_forest() -> void:
	for p in [[-17, 1, 11], [-9, 1, 12.5], [2, 1, 11.5], [12, 1, 13], [18, 1, 10]]:
		_spruce(p[0], p[1], p[2], PINE)
	_r(-20, 0, 20, 1.2, Color("8a7a5a"))
	var cols := [Color("d23b33"), Color("f2c230"), Color("2f6fb5"), Color("f4f2ea"), Color("3f9a4a"), Color("e57a2a"),
		Color("2e3238"), Color("8fc4e6"), Color("b04a9a")]
	var post := Color("8a6440")
	for k in 7:
		var x := -16.5 + k * 5.5
		var ph := 7.5 + float((k * 3) % 4)
		_r(x - 0.35, 0.5, x + 0.35, ph + 2.2, post)
		_poly([x - 0.45, ph + 2.2, x + 0.45, ph + 2.2, x, ph + 2.7], post.darkened(0.2))
		# signs of all sizes stacked up the post, sticking out either side, a little crooked
		var y := 1.6
		var j := k * 5
		while y < ph:
			var c: Color = cols[j % cols.size()]
			var w := 1.8 + float((j * 7) % 5) * 0.35
			var hh := 1.0 + float((j * 3) % 3) * 0.3
			var off := float((j * 5) % 7 - 3) * 0.3
			var tilt := float((j * 11) % 5 - 2) * 0.08
			_poly([x - w + off, y, x + w + off, y + tilt, x + w + off, y + hh + tilt, x - w + off, y + hh], c)
			if _detail(1.0):
				var tc := DARK if c.get_luminance() > 0.5 else WHITE
				_l(x - w * 0.6 + off, y + hh * 0.5, x + w * 0.5 + off, y + hh * 0.5 + tilt, tc, 0.16)
			y += hh + 0.4
			j += 1
