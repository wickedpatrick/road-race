class_name LandmarksUsT3
extends RefCounted
## American town landmarks (3): the Gulf, Texas and the Southwest (Lafayette to Camp Verde), drawn with
## LandmarkPainter's helpers (metres from the base point, y up).

const WHITE := Color("f4f2ea")
const WATER := Color("3f7fb5")
const GRASS := Color("6f9a48")
const PINE := Color("2f5a36")
const WOOD := Color("7a5634")
const DARK := Color("2e3238")
const WIN := Color("3a4048")
const RED := Color("c8282c")
const CHILI := Color("c42a1e")
const TURQ := Color("3aa6a0")
const ADOBE := Color("c98f5e")
const IRON := Color("3a3a40")
const SAND := Color("d9c08a")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"cajun_swamp": _cajun_swamp()
		"vulcan_statue": _vulcan_statue()
		"texas_capitol_bats": _texas_capitol_bats()
		"sam_houston_statue": _sam_houston_statue()
		"cadillac_ranch": _cadillac_ranch()
		"santa_fe_adobe": _santa_fe_adobe()
		"garden_of_the_gods": _garden_of_the_gods()
		"wigwam_motel": _wigwam_motel()
		"lowell_observatory": _lowell_observatory()
		"montezuma_castle": _montezuma_castle()
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

## A tall, narrow pine: a brown stem and stacked dark triangles, `h` tall.
static func _pine(x: float, y: float, h: float, col: Color) -> void:
	_r(x - h * 0.035, y, x + h * 0.035, y + h * 0.3, WOOD)
	for k in 3:
		var y0 := y + h * (0.22 + k * 0.22)
		var w := h * (0.2 - k * 0.045)
		_poly([x - w, y0, x + w, y0, x, y0 + h * 0.38], col)
		_poly([x - w, y0, x, y0, x, y0 + h * 0.38], col.lightened(0.1))

## A round bushy tree: a trunk and three blobs of leaves.
static func _bush_tree(x: float, y: float, h: float, col: Color, trunk: Color) -> void:
	_r(x - h * 0.05, y, x + h * 0.05, y + h * 0.55, trunk)
	_c(x - h * 0.18, y + h * 0.6, h * 0.24, col)
	_c(x + h * 0.18, y + h * 0.62, h * 0.24, col)
	_c(x, y + h * 0.78, h * 0.26, col.lightened(0.08))

## A 1950s car side-on, nose to the left, `col` body, from x to x + 5 on the ground at y.
static func _old_car(x: float, y: float, col: Color) -> void:
	var chrome := Color("dfe3e6")
	_poly([x, y + 0.45, x + 0.2, y + 1.15, x + 1.3, y + 1.3, x + 1.8, y + 2.05, x + 3.4, y + 2.05, x + 4.0, y + 1.3,
		x + 4.9, y + 1.25, x + 5.0, y + 0.45], col)
	_poly([x + 1.95, y + 1.35, x + 2.15, y + 1.9, x + 2.6, y + 1.9, x + 2.6, y + 1.35], Color("a8c8dc"))
	_poly([x + 2.8, y + 1.35, x + 2.8, y + 1.9, x + 3.25, y + 1.9, x + 3.7, y + 1.35], Color("a8c8dc"))
	_r(x - 0.05, y + 0.4, x + 0.5, y + 0.65, chrome)
	_r(x + 4.55, y + 0.4, x + 5.05, y + 0.65, chrome)
	if _detail(1.0):
		_l(x + 0.6, y + 0.95, x + 4.4, y + 0.95, col.lightened(0.35), 0.12)
	for wx in [x + 1.1, x + 3.9]:
		_c(wx, y + 0.42, 0.45, DARK)
		_c(wx, y + 0.42, 0.25, WHITE)

# --- Lafayette: the Cajun bayou ----------------------------------------------------------------------------

## A bald cypress standing in the water: a flared, buttressed foot, a tall grey trunk, flat sprays of needles on
## crooked branches and Spanish moss hanging in grey-green beards.
static func _cypress(x: float, h: float) -> void:
	var bark := Color("6e6253")
	var leaf := Color("4c6a34")
	var moss := Color("a3ad92")
	_poly([x - 1.6, 1.4, x + 1.6, 1.4, x + 0.6, 3.2, x + 0.38, h * 0.82, x - 0.38, h * 0.82, x - 0.6, 3.2], bark)
	_poly([x + 0.1, 1.4, x + 1.6, 1.4, x + 0.6, 3.2, x + 0.38, h * 0.82, x + 0.1, h * 0.82], bark.darkened(0.15))
	var pads := [[0.0, 0.9, 0.34, 0.09], [-0.24, 0.74, 0.22, 0.07], [0.26, 0.7, 0.24, 0.07], [-0.1, 0.58, 0.18, 0.06],
		[0.2, 0.52, 0.15, 0.05]]
	for p in pads:
		_l(x, h * (p[1] - 0.12), x + h * p[0], h * p[1], bark, 0.35)
	for p in pads:
		_ell(x + h * p[0], h * p[1], h * p[2], h * p[3], 0, leaf)
		_ell(x + h * p[0] - h * p[2] * 0.15, h * p[1] + h * p[3] * 0.35, h * p[2] * 0.75, h * p[3] * 0.6, 0, leaf.lightened(0.15))
	# Spanish moss: tapering beards under each spray
	for p in pads:
		var cx: float = x + h * p[0]
		var cy: float = h * p[1]
		var w: float = h * p[2]
		for k in 4:
			var mx := cx - w * 0.75 + w * 0.5 * k
			var ml := h * (0.1 + 0.05 * ((k * 7 + int(cx * 3.0)) % 3))
			_poly([mx - 0.45, cy - h * 0.03, mx + 0.45, cy - h * 0.03, mx + 0.1, cy - ml, mx - 0.05, cy - ml * 0.9], moss)
			if _detail(1.2):
				_l(mx, cy - h * 0.04, mx + 0.15, cy - ml - 0.6, moss.lightened(0.15), 0.12)

static func _cajun_swamp() -> void:
	var water := Color("4f5e3c")
	# the misty far shore: a row of soft trees
	for p in [[-19, 9.0], [-11, 10.0], [-3, 8.5], [5, 9.5], [13, 8.0], [19, 9.0]]:
		_ell(p[0], 3.0 + p[1] * 0.12, 6.0, 1.6 + p[1] * 0.12, 0, Color("8a9a76"))
	_r(-25, 0, 25, 2.6, water)
	if _detail(0.7):
		for p in [[-18, 1.2, 4], [-6, 2.0, 3], [3, 0.6, 5], [16, 1.6, 4], [21, 0.5, 3]]:
			_l(p[0], p[1], p[0] + p[2], p[1], Color("6f7f58"), 0.15)
	# the cypresses, and their knees poking out of the water
	_cypress(-17, 20)
	_cypress(-6, 15)
	_cypress(17, 21)
	for p in [[-14, 0.9], [-12.5, 1.1], [-3.5, 1.0], [13.5, 0.8], [22.5, 1.2], [16, 1.0]]:
		_poly([p[0] - 0.4, 1.0, p[0] + 0.4, 1.0, p[0] + 0.1, 1.0 + p[1], p[0] - 0.1, 1.0 + p[1]], Color("6e6253"))
	# lily pads
	for p in [[-9, 0.8], [-7.5, 1.6], [5, 1.9], [12, 0.6], [24, 1.6], [-23, 1.9]]:
		_ell(p[0], p[1], 0.8, 0.25, 0, Color("7aa04a"))
	# the alligator on a muddy bank: long ridged body, a tail tapering right, the long snout and a bumpy eye
	_ell(4, 2.4, 12.5, 1.3, 0, Color("8a7650"))
	var gat := Color("3f6a2e")
	var gat_l := Color("6a9a46")
	var belly := Color("c8c488")
	_poly(_gp([7, 2.6, 10, 3.7, 13, 3.5, 16.5, 3.0, 18.5, 2.6, 13, 2.6]), gat)
	_poly(_gp([1.8, 3.0, 2.6, 4.1, 6, 4.4, 9.6, 4.0, 10.2, 3.0, 9.6, 2.5, 2.4, 2.5]), gat)
	_poly(_gp([2.4, 2.5, 9.6, 2.5, 9.2, 2.9, 2.8, 2.95]), belly)
	_poly(_gp([2.4, 2.9, -2.2, 2.6, -2.6, 3.05, -2.2, 3.4, 0.5, 3.7, 2.6, 4.3]), gat)
	_poly(_gp([2.4, 2.65, -2.2, 2.5, -2.2, 2.7, 2.4, 2.95]), belly)
	var e := _gp([1.9, 4.25])
	_c(e[0], e[1], 0.62, gat)
	_c(e[0], e[1] + 0.1, 0.36, Color("e8d23a"))
	_c(e[0] + 0.05, e[1] + 0.1, 0.13, DARK)
	var nose := _gp([-2.2, 3.35])
	_c(nose[0], nose[1], 0.22, DARK)
	# teeth along the jaw
	if _detail(0.9):
		for k in 7:
			var tx := -1.8 + k * 0.6
			_poly(_gp([tx, 2.95, tx + 0.28, 2.95, tx + 0.14, 2.68]), WHITE)
	# legs
	for lx in [3.6, 8.6]:
		_poly(_gp([lx - 0.6, 3.0, lx + 0.5, 3.0, lx + 0.8, 1.9, lx - 0.8, 1.9]), gat.darkened(0.15))
	# the ridged back
	for k in 11:
		var bx := 2.6 + k * 1.4
		var by := 4.25 - absf(bx - 6.0) * 0.1 if bx > 6.0 else 4.3
		_poly(_gp([bx - 0.45, by - 0.25, bx + 0.45, by - 0.25, bx, by + 0.3]), gat_l)
	# the flat boat: a low green jon boat, a Cajun fisherman poling it along in a straw hat
	var hull := Color("2f7a6a")
	_poly([-24.5, 1.9, -11.5, 1.9, -9.8, 3.8, -25.0, 3.8], hull)
	_r(-25.0, 3.4, -9.8, 3.8, hull.lightened(0.35))
	_r(-23.5, 3.8, -21, 4.6, Color("8a6440"))
	_l(-22.3, 4.6, -22.3, 5.2, DARK, 0.15)
	var px := -14.0
	_r(px - 0.7, 3.8, px - 0.2, 6.6, Color("3a4a6a"))
	_r(px + 0.2, 3.8, px + 0.7, 6.6, Color("3a4a6a"))
	_poly([px - 0.85, 6.5, px + 0.85, 6.5, px + 0.75, 9.4, px - 0.75, 9.4], Color("d84a3a"))
	_c(px, 10.1, 0.65, Color("e0b08a"))
	_ell(px, 10.6, 1.4, 0.28, 0, Color("e6cf8a"))
	_r(px - 0.6, 10.6, px + 0.6, 11.2, Color("e6cf8a"))
	_l(px + 3.0, 13.0, px + 0.6, 0.4, Color("a08058"), 0.22)
	_l(px + 0.6, 9.0, px + 2.4, 8.9, Color("d84a3a"), 0.4)
	_l(px + 0.6, 8.2, px + 1.4, 6.0, Color("d84a3a"), 0.4)
	# ripples round the boat
	if _detail(0.9):
		_l(-25.5, 1.8, -9.5, 1.8, Color("8a9a70"), 0.12)
		_l(px + 0.7, 0.4, px + 2.0, 0.4, Color("8a9a70"), 0.12)

## The alligator's points, drawn about a third larger than given, its middle at x 4.
static func _gp(xy: Array) -> Array:
	var out := []
	for k in range(0, xy.size(), 2):
		out.append_array([4.0 + (xy[k] - 6.0) * 1.35, 2.4 + (xy[k + 1] - 2.4) * 1.35])
	return out

# --- Birmingham: Vulcan on Red Mountain --------------------------------------------------------------------

## Vulcan of Birmingham: the giant cast-iron god of the forge on his tall sandstone pillar with the viewing balcony,
## raising a spear point high in his right hand, his hammer resting on the anvil by his left, in a leather apron,
## on the wooded top of Red Mountain.
static func _vulcan_statue() -> void:
	# Red Mountain: a wooded hilltop
	_poly([-10, 0, -10, 4, -6, 6.0, -2, 6.8, 2, 6.8, 6, 6.0, 10, 4, 10, 0], Color("5f8a40"))
	_poly([-10, 0, -10, 1.5, -4, 2.2, 4, 2.2, 10, 1.5, 10, 0], Color("4f7a36"))
	for p in [[-8.5, 2.5, 6], [-6.0, 3.5, 7], [6.0, 3.5, 7], [8.5, 2.5, 6]]:
		_bush_tree(p[0], p[1], p[2], Color("3f6a32"), WOOD)
	# the pillar: sandstone blocks, a wider foot and the balcony with railings under the statue
	var stone := Color("c9a476")
	var stone_d := Color("a8845a")
	var top := 28.0
	_poly([-4.2, 6.0, 4.2, 6.0, 3.4, 9, -3.4, 9], stone_d)
	_r(-3.0, 9, 3.0, top, stone)
	_r(1.4, 9, 3.0, top, stone_d)
	if _detail(0.9):
		for y in range(10, int(top), 2):
			_l(-3.0, y, 3.0, y, stone_d.darkened(0.1), 0.1)
		_r(-0.6, 6.0, 0.6, 8.5, DARK)
		for y in [13.0, 19.0]:
			_r(-0.35, y, 0.35, y + 1.5, DARK)
	_r(-4.4, top, 4.4, top + 1, stone_d)
	_r(-4.4, top + 1, 4.4, top + 1.2, DARK)
	_l(-4.4, top + 2.2, 4.4, top + 2.2, DARK, 0.15)
	if _detail(0.9):
		for k in 9:
			_l(-4.2 + k * 1.05, top + 1.2, -4.2 + k * 1.05, top + 2.2, DARK, 0.1)
	_r(-2.6, top + 1, 2.6, top + 1.6, stone)
	# Vulcan, cast iron, drawn from his feet up: legs apart, the anvil and hammer, the apron, a bare chest
	var hi := IRON.lightened(0.25)
	_poly(_vp([-1.7, 0, -0.6, 0, -0.3, 7.5, -1.5, 7.5]), IRON)
	_poly(_vp([0.6, 0, 1.7, 0, 1.5, 7.5, 0.3, 7.5]), IRON)
	_poly(_vp([-2.2, 0, -0.3, 0, -0.3, 0.6, -2.2, 0.6]), IRON)
	_poly(_vp([0.3, 0, 2.4, 0, 2.4, 0.6, 0.3, 0.6]), IRON)
	_poly(_vp([-5.0, 0, -3.2, 0, -3.5, 1.6, -4.7, 1.6]), IRON)
	_poly(_vp([-5.6, 1.6, -2.6, 1.6, -2.6, 2.4, -6.3, 2.4]), IRON)
	_poly(_vp([-3.15, 2.4, -2.8, 2.4, -2.2, 6.5, -2.55, 6.5]), IRON)
	_poly(_vp([-3.9, 2.4, -2.1, 2.4, -2.1, 3.3, -3.9, 3.3]), IRON)
	_poly(_vp([-1.8, 7.0, 1.8, 7.0, 2.1, 12.5, -2.1, 12.5]), IRON)
	_poly(_vp([-1.9, 4.0, 1.9, 4.0, 1.7, 9.5, -1.7, 9.5]), Color("5a4a3e"))
	_poly(_vp([-1.8, 9.3, 1.8, 9.3, 1.8, 9.6, -1.8, 9.6]), Color("2a2420"))
	_poly(_vp([0.6, 9.6, 2.0, 9.6, 2.1, 12.5, 1.0, 12.5]), hi)
	# the left arm hanging to the hammer handle
	_poly(_vp([-2.1, 12.3, -1.4, 11.8, -2.0, 6.8, -2.8, 7.0]), IRON)
	var h := _vp([-2.4, 6.6])
	_c(h[0], h[1], 0.7, IRON)
	# the right arm raised high with the spear point
	_poly(_vp([1.6, 12.5, 2.3, 11.6, 3.6, 15.0, 2.8, 15.5]), IRON)
	_poly(_vp([2.8, 15.5, 3.6, 15.0, 4.1, 17.2, 3.3, 17.4]), hi)
	h = _vp([3.7, 17.5])
	_c(h[0], h[1], 0.65, IRON)
	_poly(_vp([3.55, 15.0, 3.85, 15.0, 3.85, 19.0, 3.55, 19.0]), IRON)
	_poly(_vp([3.3, 18.8, 4.1, 18.8, 3.7, 20.4]), Color("d84a2a"))
	# head with the beard and a blacksmith's cap
	_poly(_vp([-0.4, 12.4, 0.4, 12.4, 0.4, 13.0, -0.4, 13.0]), IRON)
	h = _vp([0, 13.8])
	_c(h[0], h[1], 1.3, IRON)
	_poly(_vp([-0.8, 13.4, 0.8, 13.4, 0.4, 12.5, -0.4, 12.5]), IRON.darkened(0.2))
	_poly(_vp([-0.95, 14.1, 0.95, 14.1, 0.6, 15.2, -0.6, 15.0]), IRON.lightened(0.12))

## Vulcan's points: 1.35 times as big as given, standing on the pillar's balcony.
static func _vp(xy: Array) -> Array:
	var out := []
	for k in range(0, xy.size(), 2):
		out.append_array([xy[k] * 1.35, 29.0 + xy[k + 1] * 1.35])
	return out

# --- Austin: the Congress Avenue Bridge bats and the Capitol -----------------------------------------------

static func _texas_capitol_bats() -> void:
	# the dusk sky: purple above, orange glow low down
	_poly(_arc(0, 0, 35, 40, PI, 0, 24), Color("5a4a8a"))
	_poly(_arc(0, 0, 35, 26, PI, 0, 22), Color("b0628a"))
	_poly(_arc(0, 0, 35, 14, PI, 0, 20), Color("ef9a5a"))
	_poly(_arc(0, 0, 33, 8, PI, 0, 18), Color("f8c070"))
	# downtown towers in silhouette
	var town := Color("4a3e5a")
	for t in [[-33, -28, 13], [-27, -23, 17], [16, 19.5, 13], [24, 28, 18], [29, 33, 11]]:
		_r(t[0], 5, t[1], t[2], town)
		if _detail(1.0):
			_windows(t[0] + 0.4, t[1] - 0.4, t[2] - 3.0, t[2] - 2.2, 3, Color("f2d27a"))
			_windows(t[0] + 0.4, t[1] - 0.4, t[2] - 6.0, t[2] - 5.2, 3, Color("f2d27a"))
	# the Texas Capitol in pink granite: wings, the portico, the drum, the dome and the Goddess of Liberty
	var gran := Color("d79a86")
	var gran_d := Color("b07a6a")
	var cx := -9.0
	_r(cx - 14, 5, cx + 14, 13, gran)
	_r(cx - 14, 13, cx + 14, 14, gran_d)
	_r(cx - 4.5, 5, cx + 4.5, 15.5, gran.lightened(0.08))
	_poly([cx - 5, 15.5, cx + 5, 15.5, cx, 18], gran_d)
	_windows(cx - 13.5, cx - 5, 9, 11, 6, Color("f6d48a"))
	_windows(cx + 5, cx + 13.5, 9, 11, 6, Color("f6d48a"))
	if _detail(0.9):
		_windows(cx - 13.5, cx - 5, 6.0, 7.6, 6, Color("f6d48a"))
		_windows(cx + 5, cx + 13.5, 6.0, 7.6, 6, Color("f6d48a"))
		for k in 6:
			var x := cx - 3.8 + k * 1.52
			_r(x - 0.2, 7, x + 0.2, 15, gran_d)
	# the drum with its ring of columns
	_r(cx - 5.5, 17, cx + 5.5, 22, gran)
	_r(cx - 6, 21.6, cx + 6, 22.6, gran_d)
	if _detail(0.8):
		for k in 9:
			var x := cx - 4.8 + k * 1.2
			_r(x - 0.18, 17.3, x + 0.18, 21.6, gran_d)
	# the dome, ribbed, a lantern and the statue on top
	_poly(_arc(cx, 22.6, 5.6, 8.0, 0, PI, 18), gran)
	_poly([cx + 2.0, 22.6] + _arc(cx, 22.6, 5.6, 8.0, 0, 1.2, 6), gran_d)
	if _detail(0.9):
		for a in [0.55, 1.05, 1.57, 2.09, 2.59]:
			_l(cx + cos(a) * 5.6, 22.6 + sin(a) * 1.0, cx + cos(a) * 1.2, 30.2, gran_d, 0.12)
	_r(cx - 1.0, 30.2, cx + 1.0, 32.4, gran)
	_poly(_arc(cx, 32.4, 1.2, 1.2, 0, PI, 8), gran_d)
	_r(cx - 0.12, 33.5, cx + 0.12, 35.2, DARK)
	_c(cx, 35.4, 0.3, DARK)
	_l(cx, 35.0, cx + 0.6, 36.0, DARK, 0.15)
	# Lady Bird Lake, reflecting the sunset
	_r(-35, 0, 35, 5, Color("6a5a8a"))
	if _detail(0.7):
		for p in [[-28, 1.2, 6], [-12, 3.0, 8], [4, 1.8, 5], [18, 3.5, 7], [26, 0.8, 5]]:
			_l(p[0], p[1], p[0] + p[2], p[1], Color("f2b070"), 0.2)
	# the Congress Avenue Bridge: a long deck on low concrete arches
	var conc := Color("b8aca6")
	var conc_d := Color("8a7f7a")
	_r(-35, 6.0, 35, 7.4, conc)
	_r(-35, 7.4, 35, 8.0, conc_d)
	for k in 7:
		var ax := -30.0 + k * 10.0
		var arch := [ax - 5, 6.0]
		arch.append_array(_arc(ax, 1.0, 4.2, 4.4, PI, 0, 12))
		arch.append_array([ax + 5, 6.0])
		_poly(arch, conc_d)
		_poly([ax + 4.2, 1.0, ax + 5.8, 1.0, ax + 5.8, 6.0, ax + 4.2, 6.0], conc)
	_r(-35, 5.8, 35, 6.2, conc_d.darkened(0.2))
	# watchers along the railing
	if _detail(0.8):
		var coats := [Color("d23b33"), Color("2f6fa6"), Color("f2c230"), Color("49a85a"), Color("f4f2ea")]
		for k in 14:
			var x := -32.0 + k * 4.6 + float(k % 3) * 0.7
			_r(x - 0.3, 8.0, x + 0.3, 9.4, coats[k % coats.size()])
			_c(x, 9.7, 0.3, Color("6a4a3a"))
	# the cloud of bats pouring out from under the bridge and streaming up into the sky in a long ribbon
	var path := [[4, 4], [6, 8], [8, 12], [9.5, 16], [11, 20], [13, 24], [16, 27], [19, 29]]
	for k in path.size():
		var p: Array = path[k]
		var w := 1.4 + k * 0.3
		_ell(p[0], p[1], w, w * 0.7, 1.0, Color(0.12, 0.08, 0.15, 0.3))
	var n := 70 if _detail(1.0) else 40
	for k in n:
		var t := float(k) / (n - 1) * (path.size() - 1)
		var i := mini(int(t), path.size() - 2)
		var f := t - i
		var a: Array = path[i]
		var bb: Array = path[i + 1]
		var x := lerpf(a[0], bb[0], f) + sin(k * 12.9898) * (1.2 + t * 0.4)
		var y := lerpf(a[1], bb[1], f) + cos(k * 78.233) * (0.9 + t * 0.3)
		var s := 0.45 + 0.1 * t
		_poly([x - s * 1.4, y + s * 0.5, x - s * 0.4, y + s * 0.1, x, y + s * 0.3, x + s * 0.4, y + s * 0.1,
			x + s * 1.4, y + s * 0.5, x + s * 0.6, y - s * 0.4, x, y - s * 0.2, x - s * 0.6, y - s * 0.4], Color("1c1420"))

# --- Huntsville: Sam Houston ------------------------------------------------------------------------------

## "A Tribute to Courage": the 20 m white statue of Sam Houston in his long coat, leaning on his cane, on a granite
## base among the tall pines of East Texas, with an I-45 shield by the road.
static func _sam_houston_statue() -> void:
	for p in [[-9, 0, 20], [-6.5, 0, 24], [7, 0, 23], [9.5, 0, 18]]:
		_pine(p[0], p[1], p[2], PINE)
	# the granite base
	var gran := Color("8a7c78")
	_r(-4.5, 0, 4.5, 2.4, gran)
	_r(-4.8, 2.4, 4.8, 3.0, gran.lightened(0.15))
	if _detail(1.0):
		_r(-2, 1.0, 2, 1.6, gran.darkened(0.2))
	var wh := Color("f2f0ea")
	var sh := Color("c8ccd2")
	var b := 3.0
	# boots and trousers
	_r(-2.1, b, -0.4, b + 1.0, sh)
	_r(0.4, b, 2.1, b + 1.0, sh)
	_poly([-1.9, b + 1.0, -0.4, b + 1.0, -0.3, b + 9.5, -1.9, b + 9.5], wh)
	_poly([0.4, b + 1.0, 1.9, b + 1.0, 1.9, b + 9.5, 0.3, b + 9.5], sh)
	# the long frock coat, flaring at the tails
	_poly([-3.4, b + 7.0, 3.4, b + 7.0, 3.2, b + 18.5, 2.8, b + 19.5, -2.8, b + 19.5, -3.2, b + 18.5], wh)
	_poly([0.6, b + 7.0, 3.4, b + 7.0, 3.2, b + 18.5, 2.8, b + 19.5, 0.8, b + 19.5], sh)
	_poly([-0.4, b + 7.0, 0.4, b + 7.0, 0.3, b + 13.5, -0.3, b + 13.5], sh.darkened(0.1))
	# lapels, a waistcoat and buttons
	_poly([-1.2, b + 19.5, 1.2, b + 19.5, 0, b + 15.0], Color("dfe0e2"))
	_poly([-1.2, b + 19.5, -0.4, b + 19.5, 0, b + 17.5], sh)
	if _detail(0.8):
		for k in 3:
			_c(-0.5, b + 14.0 - k * 1.5, 0.18, sh.darkened(0.2))
	# arms: the left hanging, the right on the cane
	_poly([-3.6, b + 19.0, -2.6, b + 19.0, -2.6, b + 11.5, -3.8, b + 11.5], wh)
	_c(-3.2, b + 11.0, 0.65, wh)
	_poly([2.6, b + 19.0, 3.6, b + 19.0, 4.2, b + 12.5, 3.2, b + 12.2], sh)
	_c(3.8, b + 12.0, 0.65, wh)
	_l(3.9, b + 11.6, 4.5, b, sh.darkened(0.2), 0.3)
	# the head: neck, the face, the swept-back wavy hair
	_r(-0.6, b + 19.5, 0.6, b + 20.6, sh)
	_ell(0, b + 22.2, 1.5, 1.9, 0, wh)
	_poly([-1.6, b + 22.4, -1.2, b + 24.0, 0, b + 24.5, 1.3, b + 24.0, 1.7, b + 22.4, 1.2, b + 23.4, -1.2, b + 23.4], sh)
	if _detail(1.0):
		_c(-0.5, b + 22.4, 0.15, sh.darkened(0.2))
		_c(0.5, b + 22.4, 0.15, sh.darkened(0.2))
		_l(-0.4, b + 21.2, 0.4, b + 21.2, sh.darkened(0.2), 0.12)
	# the Interstate 45 shield on a post
	_r(10.8, 0, 11.1, 3.2, Color("8a8a8a"))
	_poly([9.7, 3.2, 12.2, 3.2, 12.3, 4.6, 11.0, 5.3, 9.6, 4.6], Color("1f4a9a"))
	_poly([9.6, 4.6, 12.3, 4.6, 12.2, 5.3, 11.0, 5.5, 9.7, 5.3], RED)

# --- Amarillo: Cadillac Ranch ----------------------------------------------------------------------------

## One Cadillac buried nose-first in the ground at angle `a`, tail fins up, painted `col` with graffiti blotches.
static func _cadillac(x: float, a: float, col: Color, k: int) -> void:
	var ax := Vector2(cos(a), sin(a)) * 1.3
	var up := Vector2(-sin(a), cos(a)) * 1.3
	var o := Vector2(x, 0) - ax * 1.4
	# the side-on shape in car coordinates: u from the nose (0) to the tail (5.8), v up from the sill
	var shape := [0.0, 0.0, 5.8, 0.0, 6.0, 1.0, 5.9, 1.9, 5.3, 1.3, 4.1, 1.25, 3.6, 2.1, 1.8, 2.1, 1.2, 1.3, 0.1, 1.1]
	var pts := []
	for i in range(0, shape.size(), 2):
		var p: Vector2 = o + ax * shape[i] + up * shape[i + 1]
		pts.append_array([p.x, p.y])
	_poly(_above(pts, 0.25), col)
	var win := []
	for q in [[1.9, 1.35], [2.0, 1.95], [3.4, 1.95], [3.8, 1.35]]:
		var p: Vector2 = o + ax * q[0] + up * q[1]
		win.append_array([p.x, p.y])
	var wc := _above(win, 0.25)
	if wc.size() >= 6:
		_poly(wc, Color("9cc4dc"))
	# graffiti: blotches and squiggles of other paints
	var paints := [Color("f2d23a"), Color("3a9ad8"), Color("e84a8a"), Color("4ac85a"), Color("f4f2ea"), Color("ef7a2a")]
	for j in 3:
		var pu := 1.4 + j * 1.6 + float((k * 3 + j) % 3) * 0.3
		var pv := 0.5 + float((k + j) % 2) * 0.4
		var p: Vector2 = o + ax * pu + up * pv
		if p.y > 1.0:
			_ell(p.x, p.y, 0.75, 0.42, a + 0.3 * j, paints[(k * 2 + j) % paints.size()])
	if _detail(1.1):
		var s0: Vector2 = o + ax * 2.2 + up * 0.3
		var s1: Vector2 = o + ax * 5.2 + up * 0.8
		_l(s0.x, s0.y, s1.x, s1.y, paints[(k + 4) % paints.size()], 0.12)
	# the rear wheel near the top and the fin's tail light
	var w: Vector2 = o + ax * 4.6 + up * 0.0
	_c(w.x, w.y, 0.7, DARK)
	_c(w.x, w.y, 0.3, Color("b8bcc0"))
	var tl: Vector2 = o + ax * 5.9 + up * 1.7
	_c(tl.x, tl.y, 0.22, RED)

## The polygon (flat [x, y, ...]) cut off below height y0, so a buried car does not poke out under the ground.
static func _above(xy: Array, y0: float) -> Array:
	var out := []
	var n := xy.size() / 2
	for k in n:
		var ax: float = xy[k * 2]
		var ay: float = xy[k * 2 + 1]
		var bx: float = xy[(k * 2 + 2) % xy.size()]
		var by: float = xy[(k * 2 + 3) % xy.size()]
		if ay >= y0:
			out.append_array([ax, ay])
		if (ay >= y0) != (by >= y0):
			var t := (y0 - ay) / (by - ay)
			out.append_array([lerpf(ax, bx, t), y0])
	return out

static func _cadillac_ranch() -> void:
	# the flat Texas Panhandle: a wheat field, and the dusty patch round the cars
	_r(-24, 0, 24, 0.5, Color("d8c27a"))
	_ell(0, 0.3, 23, 0.7, 0, Color("b89a6a"))
	var cols := [Color("e84a8a"), Color("3a9ad8"), Color("f2d23a"), Color("4ac85a"), Color("ef7a2a"), Color("8a5ac8"),
		Color("e83a3a"), Color("3ac8c0"), Color("f4f2ea"), Color("d84ad8")]
	for k in 10:
		_cadillac(-21.0 + k * 4.5, deg_to_rad(58), cols[k], k)
	# a mound of earth round each buried nose
	for k in 10:
		_ell(-21.0 + k * 4.5, 0.35, 1.6, 0.4, 0, Color("8a6a48"))
	# a visitor with a spray can
	if _detail(0.9):
		var x := 23.8
		_r(x - 0.25, 0, x + 0.25, 1.0, Color("3a4a6a"))
		_r(x - 0.3, 1.0, x + 0.3, 1.8, Color("e8423a"))
		_c(x, 2.1, 0.28, Color("e0b08a"))
		_l(x - 0.2, 1.6, x - 0.9, 1.9, Color("e8423a"), 0.2)
		_r(x - 1.1, 1.8, x - 0.85, 2.2, Color("4ac85a"))

# --- Santa Fe: Pueblo-style adobe -------------------------------------------------------------------------

## A rounded adobe block: soft corners, a darker right side, the vigas (beam ends) poking out under the parapet.
static func _adobe_block(x0: float, x1: float, y0: float, y1: float, vigas: bool) -> void:
	var r := 0.5
	_poly([x0, y0, x1, y0, x1, y1 - r, x1 - r * 0.3, y1 - r * 0.3, x1 - r, y1, x0 + r, y1, x0 + r * 0.3, y1 - r * 0.3, x0, y1 - r],
		ADOBE)
	_poly([x1 - 0.8, y0, x1, y0, x1, y1 - r, x1 - r * 0.3, y1 - r * 0.3, x1 - 0.8, y1], ADOBE.darkened(0.1))
	_r(x0 + 0.2, y1 - 0.25, x1 - 0.2, y1, ADOBE.lightened(0.1))
	if vigas:
		var n := int((x1 - x0) / 1.6)
		for k in n:
			var vx := x0 + 0.8 + k * (x1 - x0 - 1.6) / maxf(1.0, n - 1)
			_r(vx - 0.18, y1 - 1.3, vx + 0.18, y1 - 0.9, WOOD)
			_r(vx - 0.18, y1 - 1.3, vx + 0.4, y1 - 1.1, WOOD.darkened(0.15))

## A turquoise door or window with its frame.
static func _adobe_door(x: float, y: float, w: float, h: float) -> void:
	_r(x - w * 0.5 - 0.2, y, x + w * 0.5 + 0.2, y + h + 0.3, Color("8a6440"))
	_r(x - w * 0.5, y, x + w * 0.5, y + h, TURQ)

## A chili ristra: a string of red chili pods hanging from (x, y), `l` long.
static func _ristra(x: float, y: float, l: float) -> void:
	_l(x, y, x, y - 0.4, Color("8a6a3a"), 0.08)
	var n := int(l / 0.35)
	for k in n:
		var yy := y - 0.4 - k * 0.35
		var w := 0.35 - 0.12 * float(k) / n
		_ell(x - w * 0.4, yy, w * 0.6, 0.22, 0.6, CHILI)
		_ell(x + w * 0.4, yy - 0.1, w * 0.6, 0.22, -0.6, CHILI.darkened(0.12))
	_poly([x - 0.12, y - 0.4 - n * 0.35, x + 0.12, y - 0.4 - n * 0.35, x, y - 0.75 - n * 0.35], CHILI)

static func _santa_fe_adobe() -> void:
	# the hills behind and a dry yard
	_poly([-25, 0, -25, 6, -14, 9, -4, 7, 8, 10, 18, 8, 25, 9, 25, 0], Color("9aa070"))
	_r(-25, 0, 25, 0.8, Color("c9a878"))
	# the big stepped pueblo-style house on the left: three storeys stepping back, a ladder to the roof
	_adobe_block(-23, -5, 0, 5, true)
	_adobe_block(-20, -9, 5, 9, true)
	_adobe_block(-17, -12, 9, 12.3, true)
	_adobe_door(-15, 0, 1.6, 2.6)
	_adobe_door(-10, 1.5, 1.4, 1.4)
	_adobe_door(-20.5, 1.5, 1.4, 1.4)
	_adobe_door(-14.5, 6, 1.2, 1.3)
	_adobe_door(-14.5, 9.6, 0.9, 1.0)
	# the ladder up to the second roof
	var lad := Color("8a6440")
	_l(-7.6, 4.2, -7.6, 10.0, lad, 0.18)
	_l(-6.6, 4.2, -6.6, 10.0, lad, 0.18)
	for k in 5:
		_l(-7.6, 5.2 + k * 1.0, -6.6, 5.2 + k * 1.0, lad, 0.14)
	# the kiva chimney
	_poly([-22, 5, -20.5, 5, -20.6, 7.2, -21.25, 7.6, -21.9, 7.2], ADOBE.darkened(0.05))
	# the beehive horno oven in the yard
	_poly(_arc(-2, 0.6, 1.8, 2.0, 0, PI, 12), ADOBE.lightened(0.05))
	_poly(_arc(-2, 0.6, 0.6, 0.8, 0, PI, 8), DARK)
	# the house on the right with its portal: a shady porch on wooden posts and carved corbels
	_adobe_block(2, 23, 0, 6.2, true)
	_adobe_block(13, 21, 6.2, 9, false)
	_r(2, 4.6, 14, 5.2, WOOD)
	for x in [2.4, 6.2, 10.0, 13.6]:
		_r(x - 0.2, 0, x + 0.2, 4.6, WOOD.lightened(0.1))
		_poly([x - 0.8, 4.6, x + 0.8, 4.6, x + 0.5, 4.2, x - 0.5, 4.2], WOOD)
	_r(2.6, 0.8, 13.4, 4.2, Color(0.35, 0.22, 0.12, 0.25))
	_adobe_door(8, 0, 1.6, 2.8)
	_adobe_door(4.4, 1.4, 1.2, 1.4)
	_adobe_door(11.6, 1.4, 1.2, 1.4)
	_adobe_door(18.5, 1.4, 1.6, 1.8)
	_adobe_door(17, 7, 1.2, 1.2)
	# chili ristras hanging from the vigas and the porch beam
	for p in [[-21.0, 3.8, 2.4], [-11.5, 3.8, 2.0], [3.2, 4.6, 2.2], [9.4, 4.6, 2.6], [12.6, 4.6, 2.0], [21.5, 5.0, 2.4]]:
		_ristra(p[0], p[1], p[2])
	# a yucca and prickly pear in the yard
	for k in 7:
		var a := deg_to_rad(40 + k * 16)
		_l(0.6, 0.8, 0.6 + cos(a) * 1.4, 0.8 + sin(a) * 1.6, Color("6a8a4a"), 0.15)
	_ell(24, 1.4, 0.5, 0.7, 0.2, Color("6a9a4a"))
	_ell(23.4, 2.2, 0.4, 0.55, -0.3, Color("6a9a4a"))

# --- Colorado Springs: Garden of the Gods -----------------------------------------------------------------

## A sandstone fin: an upright slab from x0 to x1 with a jagged top given as heights, a sunlit left face and
## vertical cracks.
static func _fin(x0: float, x1: float, tops: Array, col: Color) -> void:
	var pts := [x1, 0.0, x0, 0.0]
	var n := tops.size()
	for k in n:
		pts.append_array([lerpf(x0, x1, float(k) / (n - 1)), tops[k]])
	_poly(pts, col)
	# the shaded right part
	var sh := [x1, 0.0, lerpf(x0, x1, 0.62), 0.0]
	for k in n:
		var f := float(k) / (n - 1)
		if f >= 0.62:
			sh.append_array([lerpf(x0, x1, f), tops[k]])
	if sh.size() >= 6:
		_poly(sh, col.darkened(0.18))
	if _detail(0.6):
		for k in range(1, n - 1):
			var x := lerpf(x0, x1, float(k) / (n - 1))
			var t: float = tops[k]
			_l(x + 0.3, 1.0, x, t * 0.85, col.darkened(0.28), 0.25)

static func _garden_of_the_gods() -> void:
	# Pikes Peak behind, blue-grey with snow on top
	var mt := Color("7d8aa8")
	_poly([-40, 6, -32, 12, -22, 18, -12, 24, -2, 30, 4, 34, 8, 36.5, 12, 35, 18, 31, 26, 25, 34, 18, 40, 13, 40, 6], mt)
	_poly([-2, 30, 4, 34, 8, 36.5, 12, 35, 18, 31, 14, 30.5, 11, 32, 8, 30, 5, 31.5, 2, 29.5], WHITE)
	_poly([8, 36.5, 12, 35, 18, 31, 26, 25, 34, 18, 40, 13, 40, 6, 8, 6], mt.darkened(0.08))
	_poly([8, 36.5, 12, 35, 18, 31, 14, 30.5, 11, 32], Color("dde4ee"))
	# the foothills
	_poly([-40, 0, -40, 9, -28, 11, -16, 9, -4, 11, 10, 9, 24, 11, 40, 9, 40, 0], Color("5f7a4a"))
	var red := Color("c4502e")
	# the Gateway Rocks: two tall fins with the gap between them, a smaller one, and a white-capped rock
	_fin(-34, -8, [3.0, 10.0, 14.0, 19.0, 16.5, 22.0, 25.0, 20.5, 23.0, 17.5, 19.5, 14.5, 11.0, 5.0], red)
	_fin(-6, 10, [4.0, 9.0, 13.5, 11.0, 16.0, 18.5, 15.0, 17.0, 12.0, 8.0, 4.0], red.lightened(0.05))
	_fin(12, 19, [3.0, 7.0, 10.0, 8.0, 11.0, 6.0, 3.0], red.darkened(0.06))
	# Balanced Rock: a huge boulder on a tiny foot
	_poly([24, 0, 30, 0, 28.6, 2.5, 27.6, 4.2, 26.4, 4.2, 25.6, 2.5], red.darkened(0.15))
	_poly([21.5, 5.8, 24.5, 4.2, 30, 4.2, 33.5, 6.0, 34.2, 9.0, 32.0, 11.6, 25.5, 12.2, 22.2, 10.6, 21.0, 8.2], red)
	_poly([30, 4.2, 33.5, 6.0, 34.2, 9.0, 32.0, 11.6, 30.0, 11.8, 31.0, 7.5], red.darkened(0.16))
	_poly([22.2, 10.6, 25.5, 12.2, 32.0, 11.6, 28.0, 11.0, 24.5, 10.2], red.lightened(0.18))
	_l(23.5, 7.0, 31.0, 6.4, red.darkened(0.25), 0.3)
	# junipers and scrub oak in front, a path
	_r(-40, 0, 40, 1.6, Color("b89a6a"))
	for p in [[-36, 1.0, 4.0], [-33, 1.0, 3.0], [-12.5, 1.0, 3.6], [3.5, 1.0, 3.0], [17, 1.0, 4.4], [20, 1.0, 3.2],
			[33, 1.0, 3.8], [37, 1.0, 3.0]]:
		_bush_tree(p[0], p[1], p[2], Color("3f6a3a"), WOOD)

# --- Holbrook: the Wigwam Motel ---------------------------------------------------------------------------

## One concrete teepee room: a white cone with slightly curved sides, a red zigzag band near the top, a red door
## frame, the poles sticking out at the tip; `s` scales it.
static func _wigwam(x: float, s: float) -> void:
	var h := 9.0 * s
	var r := 2.6 * s
	var pts := [x - r, 0.0]
	for k in 7:
		var f := float(k + 1) / 7.0
		var y := h * 0.86 * f
		var w := r * (1.0 - f) * (1.0 + 0.12 * sin(f * PI)) + 0.35 * s
		pts.append_array([x - w, y])
	for k in range(6, -1, -1):
		var f := float(k + 1) / 7.0
		var y := h * 0.86 * f
		var w := r * (1.0 - f) * (1.0 + 0.12 * sin(f * PI)) + 0.35 * s
		pts.append_array([x + w, y])
	pts.append_array([x + r, 0.0])
	_poly(pts, WHITE)
	_poly([x + 0.2 * s, 0.0, x + r, 0.0, x + 0.6 * s, h * 0.86, x + 0.2 * s, h * 0.86], Color("dcdad0"))
	# the poles at the tip
	_l(x - 0.2 * s, h * 0.84, x - 0.7 * s, h, WOOD, 0.18 * s)
	_l(x + 0.2 * s, h * 0.84, x + 0.7 * s, h, WOOD, 0.18 * s)
	_l(x, h * 0.84, x, h * 1.02, WOOD, 0.18 * s)
	# the red zigzag band
	var y0 := h * 0.6
	var y1 := h * 0.68
	var w0 := r * 0.42 + 0.35 * s
	var w1 := r * 0.34 + 0.35 * s
	_poly([x - w0, y0, x + w0, y0, x + w1, y1, x - w1, y1], RED)
	var zz := []
	for k in 9:
		var f := float(k) / 8.0
		var zy := y0 - 0.5 * s if k % 2 == 0 else y0
		zz.append_array([lerpf(x - w0 - 0.1 * s, x + w0 + 0.1 * s, f), zy])
	zz.append_array([x + w0, y0 + 0.01, x - w0, y0 + 0.01])
	if _detail(0.7):
		_pl(zz.slice(0, 18), RED, 0.22 * s)
	# the door with its red frame and a little window
	_r(x - 0.85 * s, 0, x + 0.85 * s, 2.6 * s, RED)
	_r(x - 0.6 * s, 0, x + 0.6 * s, 2.35 * s, Color("e8e2d2"))
	if _detail(1.0):
		_c(x + 1.6 * s, 3.6 * s, 0.35 * s, Color("5a8ab0"))

static func _wigwam_motel() -> void:
	# the red desert and mesas behind
	_poly([-25, 0, -25, 5, -20, 5.5, -18, 7, -12, 7, -10, 5, 10, 5, 13, 6.5, 19, 6.5, 21, 5, 25, 5, 25, 0], Color("c88a6a"))
	_r(-25, 0, 25, 1.2, Color("c9a878"))
	# three teepee rooms
	_wigwam(-15, 0.9)
	_wigwam(-3, 1.0)
	_wigwam(9, 0.95)
	# old cars parked in front
	_old_car(-11.5, 0.2, Color("4aa8b0"))
	_old_car(1.5, 0.2, Color("e8a0a8"))
	# the Route 66 shield on its post: white with a black rim and the big 66
	_r(22.4, 0, 22.7, 3.4, Color("8a8a8a"))
	_poly([21.0, 3.3, 24.1, 3.3, 24.1, 5.5, 23.5, 6.1, 22.55, 5.7, 21.6, 6.1, 21.0, 5.5], DARK)
	_poly([21.2, 3.5, 23.9, 3.5, 23.9, 5.4, 23.45, 5.85, 22.55, 5.45, 21.65, 5.85, 21.2, 5.4], WHITE)
	_r(21.4, 4.95, 23.7, 5.05, DARK)
	for cx in [22.1, 23.0]:
		_c(cx, 4.15, 0.36, DARK)
		_c(cx, 4.15, 0.15, WHITE)
		_l(cx - 0.3, 4.2, cx + 0.15, 4.85, DARK, 0.16)
	# a broken log of petrified wood from the Petrified Forest: stone banded red, yellow and purple, its cut end
	# showing the rings, and a smaller piece beside it
	for g in [[13.0, 18.5, 1.2], [19.0, 20.6, 0.8]]:
		var lx0: float = g[0]
		var lx1: float = g[1]
		var r: float = g[2]
		_poly([lx0, 0.2, lx1, 0.2, lx1, 0.2 + r * 2, lx0, 0.2 + r * 2], Color("a8584a"))
		_poly([lx0, 0.2 + r * 1.2, lx1, 0.2 + r * 1.3, lx1, 0.2 + r * 1.65, lx0, 0.2 + r * 1.55], Color("e0a84a"))
		_poly([lx0, 0.2 + r * 0.35, lx1, 0.2 + r * 0.45, lx1, 0.2 + r * 0.75, lx0, 0.2 + r * 0.65], Color("7a4a7a"))
		_ell(lx0, 0.2 + r, r * 0.4, r, 0, Color("8a4a3a"))
		if _detail(0.9):
			for k in int((lx1 - lx0) / 1.2):
				_l(lx0 + 0.8 + k * 1.2, 0.3, lx0 + 1.1 + k * 1.2, 0.1 + r * 2, Color("6a3a3a"), 0.08)
		_ell(lx1, 0.2 + r, r * 0.45, r, 0, Color("f0c070"))
		_ell(lx1, 0.2 + r, r * 0.3, r * 0.65, 0, Color("d0703a"))
		_ell(lx1, 0.2 + r, r * 0.14, r * 0.3, 0, Color("8a4a8a"))

# --- Flagstaff: Lowell Observatory ------------------------------------------------------------------------

## The domes on Mars Hill at night: the big wooden dome of the Clark telescope with its slit open and the tube
## pointing out, the small white dome of the telescope that found Pluto, ponderosa pines, a starry sky with the
## Milky Way and little Pluto with its heart.
static func _lowell_observatory() -> void:
	var sky := Color("142446")
	_poly(_arc(0, 0, 18, 30, PI, 0, 24), sky)
	_poly(_arc(0, 0, 18, 16, PI, 0, 20), Color("1d3460"))
	# the Milky Way: a faint diagonal band
	for k in 6:
		_ell(-13 + k * 4.0, 10 + k * 2.2, 4.0, 1.5, 0.5, Color(0.8, 0.85, 1.0, 0.1))
	if _detail(0.5):
		for p in [[-14, 20], [-9, 26], [-4, 22], [3, 28], [8, 24], [13, 19], [-15, 12], [15, 11], [-6, 17], [11, 26],
				[-11, 14], [5, 21], [0, 25], [-2, 18], [9, 15], [-12, 23], [14, 23]]:
			_c(p[0], p[1], 0.18, Color("f4f2d0"))
		for p in [[-7, 24], [10, 21], [-13, 17]]:
			_l(p[0] - 0.6, p[1], p[0] + 0.6, p[1], Color("f8f6e0"), 0.1)
			_l(p[0], p[1] - 0.6, p[0], p[1] + 0.6, Color("f8f6e0"), 0.1)
			_c(p[0], p[1], 0.25, Color("fffbe0"))
	# Pluto, with its pale heart
	_c(6.5, 23.5, 1.3, Color("c8a888"))
	_c(6.9, 23.3, 0.42, Color("f4ece0"))
	_c(7.4, 23.3, 0.42, Color("f4ece0"))
	_poly([6.5, 23.2, 7.8, 23.2, 7.15, 22.4], Color("f4ece0"))
	# Mars Hill and the pines
	_poly([-18, 0, -18, 3, -8, 4, 8, 4, 18, 3, 18, 0], Color("26341e"))
	for p in [[-16.5, 2.5, 13], [-13.5, 3.0, 10], [14.5, 2.6, 12], [17, 2.0, 9]]:
		_pine(p[0], p[1], p[2], Color("17301e"))
	# the stone drum of the Clark dome, with a lit door
	var stone := Color("7a7268")
	_r(-8, 3.5, 4, 10, stone)
	_r(1.2, 3.5, 4, 10, stone.darkened(0.15))
	if _detail(0.9):
		for y in [5.0, 6.5, 8.0]:
			_l(-8, y, 4, y, stone.darkened(0.25), 0.1)
	_r(-3.4, 3.5, -1.6, 6.2, Color("f2c860"))
	# the telescope tube poking out of the slit
	_l(-2, 15.5, -6.5, 21.5, Color("c8ccd2"), 1.1)
	# the wooden dome with its ribs and the open slit
	var wood := Color("a8784a")
	_poly(_arc(-2, 10, 6.8, 7.0, 0, PI, 20), wood)
	_poly([-2, 10] + _arc(-2, 10, 6.8, 7.0, 0, 1.2, 8), wood.darkened(0.15))
	if _detail(0.8):
		for a in [0.5, 0.95, 2.2, 2.65]:
			_l(-2 + cos(a) * 6.8, 10 + sin(a) * 7.0 * 0.15, -2 + cos(a) * 1.5, 16.6, wood.darkened(0.25), 0.12)
	_poly([-3.0, 10.3, -1.2, 10.3, -1.2, 17.0, -3.0, 16.95], Color("0e1424"))
	_r(-8.3, 9.6, 4.3, 10.3, wood.darkened(0.3))
	# the small white dome of the Pluto telescope
	_r(6.5, 3.5, 12.5, 8, Color("c8ccd0"))
	_r(10.5, 3.5, 12.5, 8, Color("a8acb0"))
	_poly(_arc(9.5, 8, 3.4, 3.6, 0, PI, 16), Color("e4e8ec"))
	_poly([9.5, 8] + _arc(9.5, 8, 3.4, 3.6, 0, 1.2, 6), Color("bcc2c8"))
	_r(9.0, 8.0, 9.9, 11.5, Color("2a3040"))
	_r(8.6, 3.5, 9.8, 5.8, Color("f2c860"))

# --- Camp Verde: Montezuma Castle -------------------------------------------------------------------------

## The Sinagua cliff dwelling: five storeys of stone and mud walls tucked into a shaded alcove halfway up a pale
## limestone cliff, small doorways and beam ends, ladders, and sycamores along Beaver Creek below.
static func _montezuma_castle() -> void:
	var lime := Color("e2d6bc")
	var lime_d := Color("c2b496")
	# the cliff face, with level bands
	var top := [-25, 18, -23, 24, -24, 28, -20, 31, -12, 33, -4, 34, 6, 35, 15, 33.5, 21, 31, 24, 27, 23, 22, 25, 17]
	var face := [-25, 0]
	face.append_array(top)
	face.append_array([25, 0])
	_poly(face, lime)
	for y in [8.0, 13.0]:
		_poly([-25, y, 25, y, 25, y + 0.8, -25, y + 0.8], lime_d)
	# dark streaks of desert varnish running down the face
	for p in [[-17, 32, 9], [-8, 33.5, 5], [15, 33.3, 6], [19, 31.5, 11], [-21.5, 30, 7]]:
		_poly([p[0] - 0.6, p[1] - 0.5, p[0] + 0.6, p[1] - 0.5, p[0] + 0.2, p[1] - p[2], p[0] - 0.2, p[1] - p[2]], lime_d.darkened(0.12))
	# scrub along the top
	for k in range(0, top.size(), 2):
		if top[k + 1] >= 31:
			_ell(top[k], top[k + 1] + 0.2, 1.6, 0.7, 0, Color("7a8a4a"))
	if _detail(0.7):
		for p in [[-21, 4.0, 3.0], [-15, 22.0, 4.0], [18, 20.0, 4.5], [21, 6.0, 3.0], [-19, 16, 2.0], [16, 10, 2.5]]:
			_l(p[0], p[1], p[0] + 0.4, p[1] + p[2], lime_d.darkened(0.08), 0.25)
		for p in [[-12, 26.0], [10, 27.5], [-20, 27.0], [18, 25.0]]:
			_ell(p[0], p[1], 0.8, 0.5, 0, lime_d.darkened(0.15))
	# the alcove: a deep shaded hollow, the overhang above
	_poly([-11, 14.5, -11.5, 20, -10, 26, -6, 30, 0, 31.5, 6, 31, 11, 28, 13, 22, 12.5, 14.5], Color("8a7a62"))
	_poly([-10, 28.5, -6, 30, 0, 31.5, 6, 31, 11, 28, 6, 29.8, 0, 30.4, -6, 29.2], Color("6e604a"))
	_poly([-11, 14.5, 12.5, 14.5, 12.0, 15.2, -10.8, 15.2], lime_d)
	# the dwelling: storey after storey of tan walls, each with doorways and beam ends
	var wall := Color("c9a676")
	var wall_d := Color("a8885a")
	var floors := [[-5.0, 8.0, 15.2, 18.4], [-8.0, 10.0, 18.4, 21.6], [-9.0, 10.5, 21.6, 24.6], [-8.0, 9.5, 24.6, 27.4],
		[-5.0, 6.5, 27.4, 29.8]]
	for f in floors:
		var x0: float = f[0]
		var x1: float = f[1]
		var y0: float = f[2]
		var y1: float = f[3]
		_r(x0, y0, x1, y1, wall)
		_r(x1 - 1.2, y0, x1, y1, wall_d)
		_r(x0, y1 - 0.3, x1, y1, wall.lightened(0.12))
		# beam ends under each roof
		if _detail(0.8):
			var n := int((x1 - x0) / 1.4)
			for k in n:
				var vx := x0 + 0.7 + k * 1.4
				_r(vx - 0.12, y1 - 0.75, vx + 0.12, y1 - 0.45, WOOD.darkened(0.2))
		# doorways
		var d := int((x1 - x0) / 4.0) + 1
		for k in d:
			var dx := lerpf(x0 + 1.4, x1 - 1.8, (float(k) + 0.5) / d)
			_r(dx - 0.4, y0 + 0.4, dx + 0.4, y0 + 1.9, Color("3a2e22"))
	# a side tower on the right, stepping down
	_r(8.0, 15.2, 11.0, 18.4, wall_d)
	_r(9.0, 15.8, 9.8, 17.3, Color("3a2e22"))
	# ladders up from the talus to the first floor and between floors
	var lad := Color("6a4a2e")
	for lad_at in [[-3.5, 9.0, 16.4], [-7.0, 15.2, 19.6]]:
		var lx: float = lad_at[0]
		var ly0: float = lad_at[1]
		var ly1: float = lad_at[2]
		_l(lx, ly0, lx + 0.3, ly1, lad, 0.2)
		_l(lx + 1.2, ly0, lx + 1.5, ly1, lad, 0.2)
		var y := ly0 + 0.7
		while y < ly1:
			var f := (y - ly0) / (ly1 - ly0) * 0.3
			_l(lx + f, y, lx + 1.2 + f, y, lad, 0.15)
			y += 1.0
	# the talus slope and the sycamores and willows along Beaver Creek
	_poly([-25, 0, -25, 7, -14, 9, -4, 8.5, 6, 9.2, 16, 8, 25, 7, 25, 0], Color("b8a478"))
	_r(-25, 0, 25, 1.4, Color("5a8ab0"))
	for p in [[-21, 0.8, 9.0], [-15, 0.8, 7.5], [-8, 0.8, 6.0], [7, 0.8, 6.5], [15, 0.8, 8.5], [21.5, 0.8, 7.0]]:
		var x: float = p[0]
		var h: float = p[2]
		_l(x, 0.8, x + 0.4, h * 0.6, Color("e8e4d8"), 0.45)
		_c(x - h * 0.2, h * 0.65, h * 0.26, Color("5a8a3a"))
		_c(x + h * 0.22, h * 0.68, h * 0.24, Color("4f7a34"))
		_c(x, h * 0.85, h * 0.25, Color("6a9a48"))
