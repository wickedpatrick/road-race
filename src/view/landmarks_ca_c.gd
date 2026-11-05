class_name LandmarksCaC
extends RefCounted
## Canadian landmarks of the Prairies' edge and Ontario (Winnipeg, Thunder Bay, the Soo, Sudbury, Toronto,
## Niagara, Wawa), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const WHITE := Color("f4f2ea")
const WATER := Color("3f7fb5")
const WATER_L := Color("9cc8e6")
const GRASS := Color("6f9a48")
const PINE := Color("2f5a36")
const WOOD := Color("7a5634")
const DARK := Color("2e3238")
const WIN := Color("3a4048")
const RED := Color("d52b1e")
const BRONZE := Color("6e5634")
const BRONZE_L := Color("9a7c4a")
const CONC := Color("d8d4cc")
const CONC_D := Color("b4b0a8")
const MIST := Color(1, 1, 1, 0.5)

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"human_rights_museum": _human_rights_museum()
		"winnie_bear": _winnie_bear()
		"sleeping_giant": _sleeping_giant()
		"terry_fox_monument": _terry_fox_monument()
		"soo_locks": _soo_locks()
		"big_nickel": _big_nickel()
		"cn_tower": _cn_tower()
		"casa_loma": _casa_loma()
		"horseshoe_falls": _horseshoe_falls()
		"skylon_tower": _skylon_tower()
		"wawa_goose": _wawa_goose()
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

## A dark spruce: a brown stem and three stacked triangles, `h` tall.
static func _spruce(x: float, y: float, h: float, col: Color) -> void:
	_r(x - h * 0.04, y, x + h * 0.04, y + h * 0.2, WOOD)
	for k in 3:
		var y0 := y + h * (0.15 + k * 0.25)
		var w := h * (0.28 - k * 0.07)
		_poly([x - w, y0, x + w, y0, x, y0 + h * 0.4], col)
		_poly([x - w, y0, x, y0, x, y0 + h * 0.4], col.lightened(0.1))

## A round leafy tree, `h` tall.
static func _tree(x: float, y: float, h: float) -> void:
	_r(x - h * 0.05, y, x + h * 0.05, y + h * 0.45, WOOD)
	_c(x, y + h * 0.62, h * 0.3, Color("4f7d3a"))
	_c(x - h * 0.14, y + h * 0.72, h * 0.2, Color("5f9046"))
	_c(x + h * 0.12, y + h * 0.78, h * 0.17, Color("6aa04e"))

## A red maple leaf `s` tall centred on (x, y).
static func _maple(x: float, y: float, s: float, col: Color) -> void:
	var r := [0.0, 0.5, 0.1, 0.32, 0.2, 0.37, 0.17, 0.12, 0.4, 0.3, 0.36, 0.15, 0.47, 0.12, 0.3, -0.02, 0.34, -0.12,
		0.05, -0.1, 0.04, -0.4]
	var u := r.duplicate()
	for k in range(r.size() - 2, 1, -2):
		u.append_array([-r[k], r[k + 1]])
	var pts := []
	for k in range(0, u.size(), 2):
		pts.append_array([x + u[k] * s, y + u[k + 1] * s])
	_poly(pts, col)

## The Canadian flag on a pole whose foot is (x, y): a pole `h` tall, a flag `fw` wide at the top.
static func _canada_flag(x: float, y: float, h: float, fw: float) -> void:
	_l(x, y, x, y + h, Color("c8ccd0"), fw * 0.05)
	var fh := fw * 0.5
	var y1 := y + h - 0.1
	_r(x, y1 - fh, x + fw, y1, Color.WHITE)
	_r(x, y1 - fh, x + fw * 0.25, y1, RED)
	_r(x + fw * 0.75, y1 - fh, x + fw, y1, RED)
	_maple(x + fw * 0.5, y1 - fh * 0.5, fh * 0.75, RED)

## A digit 5 in a box w wide and h tall whose lower left corner is (x, y), drawn as strokes.
static func _five(x: float, y: float, w: float, h: float, col: Color, lw: float) -> void:
	var r := h * 0.3
	_pl([x + w, y + h, x + w * 0.1, y + h, x, y + h * 0.55] + _arc(x + w * 0.45, y + r, w * 0.55, r, PI * 0.75, -PI * 0.8, 9),
		col, lw)

## The Canadian Museum for Human Rights in Winnipeg: rough limestone "roots" at the foot, the glass cloud
## folding round the building like wings, and the slender glass Tower of Hope rising out of it.
static func _human_rights_museum() -> void:
	var stone := Color("cdb98e")
	var stone_d := Color("a8936a")
	var glass := Color("a8cde2")
	var glass_d := Color("7aa6c4")
	var glass_l := Color("dcf0f8")
	_r(-35, 0, 35, 1.5, GRASS)
	# the Tower of Hope: a tall, slim glass spire
	_poly([1.5, 22, 8.5, 22, 6.2, 45, 3.6, 45], glass_d)
	_poly([1.5, 22, 4.6, 22, 4.6, 45, 3.6, 45], glass_l)
	_poly([3.6, 45, 6.2, 45, 4.9, 50], glass)
	if _detail(1.0):
		for k in 9:
			var y := 24.0 + k * 2.4
			var t := (y - 22.0) / 23.0
			_l(lerpf(1.5, 3.6, t), y, lerpf(8.5, 6.2, t), y, Color(1, 1, 1, 0.6), 0.12)
	# the glass cloud: two wings wrapping round the middle
	var right := [-6, 10, 4, 15, 13, 21, 21, 25, 28, 24, 32, 19, 31, 13, 24, 9, 10, 8]
	var left := [-31, 9, -33, 13, -29, 19, -21, 24.5, -11, 28, -1, 29.5, 6, 28, 5, 21, -5, 15, -17, 10.5]
	_poly(right, glass_d)
	_poly(left, glass)
	# a light sheen along the top of each wing
	_poly([-29, 19, -21, 24.5, -11, 28, -1, 29.5, 6, 28, 5.6, 25.5, -1, 26.8, -11, 25.2, -20, 22, -27.5, 17.5], glass_l)
	_poly([13, 21, 21, 25, 28, 24, 32, 19, 30.5, 18, 27, 21.6, 21, 22.6, 14, 19], glass.lightened(0.15))
	if _detail(0.9):
		for k in 7:
			var x := -27.0 + k * 4.4
			_l(x, 11.5 + k * 0.4, x + 5.5, 21.0 + k * 1.1, Color(1, 1, 1, 0.45), 0.12)
		for k in 5:
			var x := 10.0 + k * 4.4
			_l(x, 9.0, x + 3.0, 19.0 + k * 0.9, Color(1, 1, 1, 0.35), 0.12)
	# the stone roots: three rounded limestone masses
	_poly([-10, 1.5, -9, 8, -5, 12, 2, 13, 8, 11, 10, 6, 10, 1.5], stone_d)
	_poly([-29, 1.5, -29, 7, -26, 11, -19, 12.5, -12, 11.5, -9, 7, -9, 1.5], stone)
	_poly([9, 1.5, 10, 6, 14, 9.5, 22, 10.5, 28, 8.5, 30, 4, 30, 1.5], stone)
	if _detail(0.9):
		for y in [3.5, 5.5, 7.5, 9.5]:
			_l(-28.5, y, -9.5, y, stone_d, 0.15)
			_l(10.5, y - 0.5, 29.5, y - 0.5, stone_d, 0.15)
			_l(-9.5, y + 0.5, 9.5, y + 0.5, stone_d.darkened(0.15), 0.15)
	# the entrance: a dark glass slot between the roots
	_poly([-9, 1.5, -8, 6, -6.5, 6, -6, 1.5], WIN)
	_r(-35, 0, 35, 1.5, GRASS)

## Winnie and Lieutenant Harry Colebourn in Assiniboine Park, Winnipeg: a bronze soldier in his peaked cap and
## tunic holding the paw of a black bear cub standing up on its hind legs, on a low stone base among trees.
static func _winnie_bear() -> void:
	_tree(-2.8, 0, 3.9)
	_tree(2.9, 0, 3.4)
	_r(-1.5, 0, 1.6, 0.45, Color("9a948a"))
	_r(-1.6, 0.4, 1.7, 0.5, Color("b2aca2"))
	var b := BRONZE
	var bl := BRONZE_L
	# Harry: boots, legs in puttees, tunic, belt, cap
	_r(0.3, 0.5, 0.47, 1.35, b.darkened(0.1))
	_r(0.55, 0.5, 0.72, 1.35, b)
	_r(0.24, 0.5, 0.5, 0.6, DARK)
	_r(0.52, 0.5, 0.78, 0.6, DARK)
	_poly([0.22, 1.25, 0.8, 1.25, 0.76, 2.02, 0.26, 2.02], b)
	_poly([0.22, 1.25, 0.45, 1.25, 0.45, 2.02, 0.26, 2.02], bl)
	_r(0.23, 1.55, 0.79, 1.63, b.darkened(0.3))
	_l(0.78, 1.98, 0.84, 1.4, b, 0.13)
	_c(0.5, 2.18, 0.14, bl)
	_r(0.36, 2.26, 0.66, 2.38, b.darkened(0.25))
	_poly([0.36, 2.26, 0.2, 2.24, 0.36, 2.3], b.darkened(0.25))
	# his arm reaching down to the cub's paw
	_pl([0.3, 1.95, 0.1, 1.65, -0.08, 1.48], b, 0.13)
	# Winnie: a black bear cub up on its hind legs, reaching
	var bear := Color("2b2622")
	var bear_l := Color("4a4038")
	_ell(-0.45, 0.62, 0.16, 0.1, 0, bear)
	_ell(-0.2, 0.62, 0.16, 0.1, 0, bear)
	_ell(-0.35, 1.0, 0.27, 0.4, -0.2, bear)
	_ell(-0.3, 1.0, 0.13, 0.25, -0.2, bear_l)
	_pl([-0.25, 1.25, -0.12, 1.42, -0.06, 1.47], bear, 0.11)
	_c(-0.28, 1.5, 0.15, bear)
	_c(-0.39, 1.62, 0.055, bear)
	_c(-0.18, 1.64, 0.055, bear)
	_ell(-0.18, 1.45, 0.09, 0.06, 0.6, Color("6a5a48"))
	if _detail(12.0):
		_c(-0.25, 1.53, 0.022, Color.WHITE)

## The Sleeping Giant across Thunder Bay: a long, dark, forested mesa on Lake Superior shaped like a giant lying
## on his back, his face to the sky at the left, arms folded on his chest, his knees and feet at the right.
static func _sleeping_giant() -> void:
	var hill := Color("4e5f78")
	var hill_d := Color("3e4c63")
	var cliff := Color("6c7a8c")
	var giant := [-50, 3, -49, 7, -47.5, 11.5, -45.5, 15, -43, 17, -40.6, 17.6, -39.4, 18.4, -38.4, 20.4, -37.4, 19.4,
		-36.2, 18.8, -35.2, 19.2, -34.2, 19.8, -33, 17.6, -30.5, 14.5, -27, 16.5, -23, 20.5, -19, 23, -15, 23.8,
		-11, 23.2, -7, 21.2, -1, 20, 8, 19.6, 16, 19.2, 22, 19, 26, 20.5, 30, 22.5, 34, 22, 38, 19, 41, 18, 43, 19,
		44.5, 24, 46, 23.4, 47, 19, 48.5, 12, 50, 5, 50, 3]
	_poly(giant, hill)
	# the lower forested slopes, darker
	_poly([-50, 3, -48, 5, -42, 8, -34, 9, -24, 10.5, -8, 11, 10, 10.5, 26, 10, 40, 9.5, 47, 8, 50, 4.5, 50, 3], hill_d)
	if _detail(0.5):
		# pale cliff faces under the chest and at the feet
		_poly([-23, 20.5, -19, 23, -16, 23.6, -17, 16, -21, 14.5], cliff)
		_poly([44.5, 23.5, 46, 23, 47, 19, 48.5, 12, 46.5, 13, 45.5, 18], cliff)
		_poly([-43, 17, -40.6, 17.6, -39.4, 18.4, -38.4, 20.4, -37.4, 19.4, -36.2, 18.8, -35.2, 19.2, -34.2, 19.8, -33, 17.6,
			-34, 16.2, -38, 16.4, -42, 15.6], hill.lightened(0.1))
	# Lake Superior
	_r(-50, 0, 50, 3.2, WATER)
	_poly([-47, 3.2, 47, 3.2, 38, 2.4, -40, 2.4], hill_d.lerp(WATER, 0.6))
	if _detail(0.5):
		for p in [[-36, 1.2], [-20, 0.6], [4, 1.6], [26, 0.9]]:
			_r(p[0], p[1], p[0] + 8, p[1] + 0.3, WATER_L)
	# the near shore with spruces at the ends
	_poly([-50, 0, -50, 2.5, -44, 1.6, -38, 0], Color("5e6a4a"))
	_poly([50, 0, 50, 3, 42, 1.6, 36, 0], Color("5e6a4a"))
	for p in [[-48, 1.6, 8.5], [-45, 1.0, 6.0], [47.5, 1.8, 9.0], [44, 1.0, 6.5]]:
		_spruce(p[0], p[1], p[2], PINE)

## The Terry Fox Monument by Thunder Bay: the bronze runner in mid-stride with his artificial leg, his curly
## head up, on a tall pink-grey granite plinth with a maple leaf, Canadian flags on poles and Lake Superior behind.
static func _terry_fox_monument() -> void:
	_r(-6, 0, 6, 2.6, WATER)
	_r(-6, 0, 6, 1.0, GRASS)
	_canada_flag(-5.4, 0.8, 9.0, 2.0)
	_canada_flag(4.0, 0.8, 9.0, 2.0)
	var gr := Color("a39088")
	var gr_d := Color("85736c")
	_r(-3.6, 0.5, 3.6, 1.0, gr_d)
	_r(-3.0, 1.0, 3.0, 1.5, gr)
	_r(-2.0, 1.5, 2.0, 5.2, gr)
	_r(0.9, 1.5, 2.0, 5.2, gr_d)
	_r(-2.3, 5.2, 2.3, 5.65, gr_d)
	_maple(-0.5, 3.9, 1.6, BRONZE_L)
	if _detail(8.0):
		_r(-1.4, 2.0, 0.4, 2.6, BRONZE)
	# the runner, heading right
	var b := BRONZE
	var bl := BRONZE_L
	var steel := Color("c4c8cc")
	# the artificial right leg, stretched back: a socket on the thigh and a thin steel rod to the foot
	_pl([-0.05, 6.95, -0.35, 6.4], b, 0.24)
	_l(-0.35, 6.4, -0.75, 5.75, steel, 0.09)
	_c(-0.35, 6.4, 0.12, steel)
	_r(-0.98, 5.65, -0.62, 5.78, DARK)
	# the good left leg, bent forward
	_pl([0.12, 6.95, 0.55, 6.38, 0.42, 5.75], bl, 0.22)
	_r(0.38, 5.65, 0.74, 5.78, DARK)
	# shorts, shirt, head with curls
	_poly([-0.3, 6.78, 0.4, 6.78, 0.36, 7.12, -0.26, 7.12], b.darkened(0.15))
	_poly([-0.24, 7.05, 0.32, 7.05, 0.46, 7.88, -0.04, 7.92], bl)
	_pl([0.08, 7.78, -0.3, 7.42, -0.48, 7.62], b, 0.12)
	_pl([0.34, 7.78, 0.6, 7.42, 0.8, 7.66], bl, 0.12)
	_c(0.3, 8.15, 0.19, bl)
	for p in [[0.18, 8.3], [0.3, 8.34], [0.42, 8.28], [0.14, 8.17]]:
		_c(p[0], p[1], 0.09, b)

## The Soo Locks at Sault Ste. Marie: a long red lake freighter (pilot house at the bow, engine house and funnel
## at the stern) raised in the concrete lock chamber, the dark mitre gates at both ends, the river above and below.
static func _soo_locks() -> void:
	# the far bank and the International Bridge
	_poly([-35, 4, -35, 9, -20, 10, -5, 8.5, 12, 10, 25, 8.8, 35, 9.5, 35, 4], Color("4f7a46"))
	if _detail(0.8):
		var br := Color("4a5560")
		_l(-35, 11.5, 35, 11.5, br, 0.5)
		for x0 in [-30.0, 2.0]:
			_pl(_arc(x0 + 14, 11.5, 14, 3.2, PI, 0, 12), br, 0.35)
			for k in 7:
				var x: float = x0 + 2.0 + k * 4.0
				_l(x, 11.5, x, 11.5 + 3.2 * sqrt(maxf(0.0, 1.0 - pow((x - x0 - 14) / 14.0, 2))), br, 0.12)
	_r(-35, 0, 35, 4, GRASS)
	# the river: high above the locks (left), low below them (right)
	_r(-35, 0, -29, 5.2, WATER)
	_r(29, 0, 35, 1.8, WATER)
	# the freighter in the full chamber
	var hull := Color("8e2a22")
	var sup := Color("f2efe6")
	_poly([-25, 9.2, -23.5, 2.6, 23, 2.6, 24, 8.6, 24, 9.2], hull)
	_r(-24.6, 8.4, 24, 9.2, DARK)
	if _detail(0.9):
		for k in 9:
			var x := -14.0 + k * 3.3
			_r(x, 9.2, x + 2.4, 9.7, Color("7a7a74"))
	# forecastle with the pilot house at the bow
	_r(-23.5, 9.2, -16, 10.6, sup)
	_r(-22.5, 10.6, -17.5, 13.2, sup)
	_r(-22.2, 12.0, -17.8, 12.8, WIN)
	_r(-23, 13.2, -17, 13.6, DARK)
	_l(-20, 13.6, -20, 16.5, DARK, 0.18)
	# engine house and funnel at the stern
	_r(15, 9.2, 23.5, 12.6, sup)
	_windows(15.5, 23, 10.6, 11.6, 5, WIN)
	_r(18, 12.6, 21, 15.6, DARK)
	_r(18, 14.4, 21, 15.0, Color("e0b43a"))
	# the near lock wall, with bollards
	_r(-29, 0, 29, 4.4, CONC)
	_r(-29, 4.4, 29, 4.9, CONC_D)
	if _detail(0.9):
		for k in 8:
			var x := -25.0 + k * 7.2
			_r(x, 4.9, x + 0.6, 5.5, DARK)
		for k in 6:
			_l(-29 + k * 11.6, 0, -29 + k * 11.6, 4.4, CONC_D, 0.12)
	# the gates at both ends, with a walkway and railings on top
	var gate := Color("3e5248")
	for x in [-29.0, 29.0]:
		_r(x - 1.3, 0, x + 1.3, 7.0, gate)
		_r(x - 1.5, 7.0, x + 1.5, 7.4, gate.darkened(0.3))
		_l(x - 1.3, 0.5, x + 1.3, 6.5, gate.lightened(0.15), 0.18)
		_l(x + 1.3, 0.5, x - 1.3, 6.5, gate.lightened(0.15), 0.18)
		_l(x - 1.5, 8.2, x + 1.5, 8.2, Color("e0b43a"), 0.12)

## The Big Nickel at Sudbury: a giant twelve-sided silver 5-cent coin standing on edge on a rock base, a beaver on
## a log raised on its face under a big 5.
static func _big_nickel() -> void:
	_spruce(-5.8, 0, 6.5, PINE)
	_spruce(5.6, 0, 5.5, PINE)
	_poly([-4, 0, -3.4, 1.4, 3.2, 1.6, 4, 0], Color("4a4844"))
	_r(-2.4, 1.4, 2.4, 2.4, Color("8a8a84"))
	var cx := 0.0
	var cy := 6.8
	var rr := 4.6
	var face := Color("c9ced3")
	var edge := Color("8e959c")
	var rim := []
	var inner := []
	var side := []
	for k in 12:
		var a := TAU * k / 12.0 + PI / 12.0
		rim.append_array([cx + cos(a) * rr, cy + sin(a) * rr])
		inner.append_array([cx + cos(a) * rr * 0.86, cy + sin(a) * rr * 0.86])
		side.append_array([cx + 0.6 + cos(a) * rr, cy + sin(a) * rr])
	_poly(side, edge)
	_poly(rim, face)
	_poly(inner, face.lightened(0.15))
	_pl(inner + [inner[0], inner[1]], face.darkened(0.12), 0.12)
	# the beaver on its log (in relief, a shade darker than the face)
	var rel := Color("969ca3")
	var rel_d := Color("7c838b")
	_r(-2.6, 5.0, 2.4, 5.5, rel_d)
	_ell(-1.9, 5.85, 0.95, 0.35, -0.35, rel_d)
	_ell(0.1, 6.15, 1.5, 0.85, 0, rel)
	_c(1.45, 6.5, 0.55, rel)
	_ell(1.95, 6.38, 0.3, 0.2, 0, rel)
	_c(1.2, 7.0, 0.14, rel_d)
	_r(-0.6, 5.5, -0.2, 5.75, rel_d)
	_r(0.8, 5.5, 1.2, 5.75, rel_d)
	if _detail(10.0):
		_c(1.62, 6.62, 0.06, DARK)
	# the big 5 and two little maple leaves
	_five(-0.55, 7.8, 1.1, 1.9, rel_d, 0.3)
	_maple(-2.2, 8.6, 0.9, rel)
	_maple(2.0, 8.6, 0.9, rel)

## The CN Tower over Toronto's skyline: the tall grey concrete shaft, the round main pod with its window band,
## the little SkyPod and the long needle, the domed stadium and the towers downtown, and Lake Ontario in front.
static func _cn_tower() -> void:
	# the downtown towers behind
	for b in [[-19.5, -15.5, 17.0, Color("7a8ea4")], [-15, -11.5, 24.0, Color("5e7590")], [-10.5, -7.0, 14.0, Color("a5b4c4")],
			[5.0, 8.5, 21.0, Color("6a8098")], [9.0, 12.5, 27.0, Color("44607e")], [13.0, 16.0, 18.0, Color("98a8ba")],
			[16.5, 19.5, 23.0, Color("5e7590")]]:
		var x0: float = b[0]
		var x1: float = b[1]
		var h: float = b[2]
		_r(x0, 3, x1, h, b[3])
		if _detail(1.0):
			for y in range(5, int(h) - 1, 2):
				_l(x0 + 0.4, y, x1 - 0.4, y, Color(1, 1, 1, 0.25), 0.15)
	# the stadium dome by the foot of the tower
	_poly([-11, 3] + _arc(-6.5, 3, 5.5, 5.0, PI, 0, 14), Color("e2e2dc"))
	if _detail(1.0):
		for k in 3:
			var a := PI * (0.3 + k * 0.2)
			_l(-6.5 + cos(a) * 5.5, 3 + sin(a) * 5.0, -6.5, 3, Color("b8b8b0"), 0.12)
	# the tower: shaft, main pod, SkyPod and needle
	_poly([-4.0, 3, 4.0, 3, 1.7, 51, -1.7, 51], CONC)
	_poly([0.8, 3, 4.0, 3, 1.7, 51, 0.5, 51], CONC_D)
	_l(-1.6, 3, -0.6, 51, CONC_D, 0.25)
	_poly([-2.4, 50.5, 2.4, 50.5, 6.0, 53.5, -6.0, 53.5], CONC_D)
	_r(-6.5, 53.5, 6.5, 56.6, Color("3a4a5a"))
	if _detail(1.2):
		for k in 7:
			_l(-5.4 + k * 1.8, 53.5, -5.4 + k * 1.8, 56.6, Color("6a7a8a"), 0.15)
	_poly([-6.7, 56.6, 6.7, 56.6, 5.8, 58.8, -5.8, 58.8], CONC)
	_poly([-5.8, 58.8, 5.8, 58.8, 2.6, 60.6, -2.6, 60.6], CONC_D)
	_poly([-1.3, 60.6, 1.3, 60.6, 0.9, 71, -0.9, 71], CONC)
	_r(-2.0, 71, 2.0, 72.8, Color("3a4a5a"))
	_r(-2.1, 72.8, 2.1, 73.4, CONC_D)
	_poly([-0.7, 73.4, 0.7, 73.4, 0.18, 89.5, -0.18, 89.5], Color("c8ccd0"))
	_c(0, 89.6, 0.4, RED)
	# Lake Ontario and the waterfront
	_r(-20, 0, 20, 3, WATER)
	if _detail(0.8):
		for p in [[-17, 1.2], [-4, 0.6], [8, 1.7]]:
			_r(p[0], p[1], p[0] + 6, p[1] + 0.3, WATER_L)

## Casa Loma in Toronto: a buff-stone castle with a round tower and a tall pointed green roof, a square battlemented
## tower flying the flag, steep roofs, little turrets and chimneys, rows of arched windows and a lawn in front.
static func _casa_loma() -> void:
	var wall := Color("d9c79a")
	var wall_d := Color("b8a578")
	var roof := Color("5a786a")
	var roof_d := Color("42594e")
	_tree(-28, 1, 9)
	_tree(28.5, 1, 8)
	# the low east wing
	_r(22, 2, 28, 11, wall_d)
	_poly([21.5, 11, 28.5, 11, 25, 14], roof_d)
	# the main block with its steep roof, dormers and chimneys
	_r(-14, 14, -12.6, 22, wall_d)
	_r(10, 14, 11.4, 21, wall_d)
	_poly([-19, 16, 17, 16, 14, 20.5, -16, 20.5], roof)
	if _detail(0.9):
		for x in [-12.0, -5.0, 2.0, 9.0]:
			_poly([x - 1.2, 16.5, x + 1.2, 16.5, x + 1.2, 18.4, x, 19.6, x - 1.2, 18.4], wall)
			_r(x - 0.5, 16.8, x + 0.5, 18.2, WIN)
	_r(-18, 2, 16, 16, wall)
	_windows(-17, 15, 11.5, 14.2, 11, WIN)
	_windows(-17, 15, 6.5, 9.4, 11, WIN)
	_r(-18, 10.2, 16, 10.6, wall_d)
	# the porch in the middle with its arch
	_r(-3.5, 2, 3.5, 9, wall_d)
	_poly([-2, 2] + _arc(0, 5.2, 2, 2, PI, 0, 8) + [2, 2], WIN)
	_r(-4, 9, 4, 9.6, wall)
	for k in 5:
		_r(-4 + k * 1.75, 9.6, -3.3 + k * 1.75, 10.4, wall)
	# a corner turret with its cone
	_r(-6.5, 16, -3.5, 22.5, wall)
	_poly([-7, 22.5, -3, 22.5, -5, 27.5], roof_d)
	_r(-5.4, 18.5, -4.6, 20.5, WIN)
	_r(6, 16, 8.4, 21, wall)
	_poly([5.6, 21, 8.8, 21, 7.2, 25], roof_d)
	# the round tower at the left with its tall pointed roof
	_r(-26, 2, -18, 22.5, wall)
	_r(-20, 2, -18, 22.5, wall_d)
	_poly([-27, 22.5, -17, 22.5, -22, 31.5], roof)
	_poly([-22, 22.5, -17, 22.5, -22, 31.5], roof_d)
	_l(-22, 31.5, -22, 32.5, DARK, 0.2)
	_windows(-25.5, -18.5, 17, 19.5, 3, WIN)
	_windows(-25.5, -18.5, 11, 13.5, 3, WIN)
	_windows(-25.5, -18.5, 5, 7.5, 3, WIN)
	# the square tower at the right with battlements and the flag
	_r(15, 2, 22.5, 25, wall)
	_r(20.8, 2, 22.5, 25, wall_d)
	for k in 4:
		_r(15 + k * 2.1, 25, 16.2 + k * 2.1, 26.2, wall)
	_windows(15.5, 22, 20, 22.5, 2, WIN)
	_windows(15.5, 22, 14, 16.5, 2, WIN)
	_windows(15.5, 22, 7, 9.5, 2, WIN)
	_canada_flag(18.8, 26.2, 5.5, 3.0)
	# the lawn
	_r(-30, 0, 30, 2, GRASS)
	if _detail(0.9):
		for x in [-14.0, -9.0, 8.0, 13.0]:
			_c(x, 2.3, 1.0, Color("4f7d3a"))

## Horseshoe Falls at Niagara: the broad horseshoe of green-and-white water pouring over the curved brink, the
## cloud of mist rising from the pool, the cliffs at both ends and the blue tour boat full of blue ponchos below.
static func _horseshoe_falls() -> void:
	# the far bank with trees, and the upper river running to the brink
	_poly([-45, 30, -45, 37, -30, 38, -12, 36.5, 8, 38, 26, 36.8, 45, 38, 45, 30], Color("4f7a46"))
	_r(-45, 22, 45, 33.5, Color("4f9aa0"))
	if _detail(0.6):
		for p in [[-38, 30.5], [-14, 32], [12, 31], [30, 29.5]]:
			_r(p[0], p[1], p[0] + 8, p[1] + 0.35, Color("8ccac8"))
	# the falling water: a band between the brink (back half of an ellipse) and the pool
	var top := _arc(0, 21, 36, 9, PI, 0, 24)
	var bot := _arc(0, 7, 36, 7, 0, PI, 24)
	_poly(top + bot, Color("dcefee"))
	# the green lip where the water curls over, then streaks down the face
	var lip := _arc(0, 19.8, 35.5, 8.4, 0, PI, 24)
	_poly(top + lip, Color("5fb3a0"))
	if _detail(0.5):
		for k in range(1, 24):
			var a := PI - PI * k / 24.0
			var x0 := cos(a) * 35.0
			var y0 := 19.5 + sin(a) * 8.0
			var y1 := 7.5 + sin(a) * 6.8
			var c := Color("a8d8d0") if k % 2 == 0 else Color("ffffff")
			_l(x0, y0, x0, y1, c, 0.6)
	# the cliffs at both ends of the horseshoe
	var rock := Color("8a7a66")
	_poly([-45, 0, -45, 23, -35.5, 23, -36, 19, -34.5, 8, -33, 0], rock)
	_poly([-45, 23, -35.5, 23, -36, 21.5, -45, 21.5], Color("6f9a48"))
	_poly([45, 0, 45, 23, 35.5, 23, 36, 19, 34.5, 8, 33, 0], rock.darkened(0.1))
	_poly([45, 23, 35.5, 23, 36, 21.5, 45, 21.5], Color("6f9a48"))
	_spruce(40, 23, 7, PINE)
	_spruce(43.5, 23, 5.5, PINE)
	# the pool and the river below, foam at the foot of the falls
	_poly(bot + [-36, 0, 36, 0], Color("4f8cb0"))
	_r(-45, 0, 45, 4, WATER)
	_poly(_arc(0, 7, 36, 7, 0, PI, 24) + _arc(0, 6, 34, 5, PI, 0, 24), Color("eef8f8"))
	# the mist rising out of the horseshoe
	for p in [[0, 12, 16, 4.5], [-12, 17, 9, 4], [8, 22, 10, 5], [-3, 28, 8, 3.5], [16, 13, 8, 3], [-20, 10, 7, 2.5]]:
		_ell(p[0], p[1], p[2], p[3], 0, Color(1, 1, 1, 0.38))
	# the tour boat: blue hull, white decks, a crowd of blue ponchos
	var bx := -10.0
	_poly([bx - 8, 3.6, bx + 7, 3.6, bx + 8.5, 5.2, bx - 8.5, 5.2], Color("2f5fa8"))
	_r(bx - 8.5, 1.6, bx + 7, 3.6, Color("2f5fa8").darkened(0.2))
	_r(bx - 7, 5.2, bx + 5, 6.6, Color("f4f4f0"))
	_windows(bx - 6.5, bx + 4.5, 5.5, 6.3, 7, Color("6a8aa8"))
	_r(bx - 7.2, 6.6, bx + 5.2, 6.9, Color("2f5fa8"))
	for k in 9:
		var px := bx - 6.4 + k * 1.35
		_poly([px - 0.55, 6.9, px + 0.55, 6.9, px, 8.1], Color("3a7ad8"))
		_c(px, 8.15, 0.32, Color("3a7ad8").lightened(0.15))
	_l(bx - 9, 2.0, bx - 16, 1.6, Color(1, 1, 1, 0.7), 0.3)

## The Skylon Tower at Niagara Falls: a slim concrete shaft with the round, tiered top house and its mast, and the
## yellow "bug" lifts riding up the outside of the shaft.
static func _skylon_tower() -> void:
	_tree(-8, 0, 7)
	_tree(8.5, 0, 6)
	_r(-6.5, 0, 6.5, 4, Color("e6e2d8"))
	_windows(-6, 6, 1.2, 3.2, 6, WIN)
	_poly([-2.0, 4, 2.0, 4, 1.5, 50, -1.5, 50], CONC)
	_poly([0.4, 4, 2.0, 4, 1.5, 50, 0.3, 50], CONC_D)
	# the lift tracks and two yellow cabs
	var yel := Color("f2c230")
	_l(-2.15, 4, -1.65, 50, Color("5a5a58"), 0.2)
	_l(2.15, 4, 1.65, 50, Color("5a5a58"), 0.2)
	for c in [[1.9, 19.0], [-4.2, 35.0]]:
		var x0: float = c[0]
		var y0: float = c[1]
		_r(x0, y0, x0 + 2.3, y0 + 4.2, yel)
		_r(x0 + 0.3, y0 + 2.0, x0 + 2.0, y0 + 3.6, WIN)
		_poly([x0, y0 + 4.2, x0 + 2.3, y0 + 4.2, x0 + 1.15, y0 + 4.9], yel.darkened(0.15))
		_poly([x0, y0, x0 + 2.3, y0, x0 + 1.15, y0 - 0.6], yel.darkened(0.15))
	# the top house: a flared underside, two window rings, a domed roof and the mast
	_poly([-1.5, 50, 1.5, 50, 6.2, 54.5, -6.2, 54.5], CONC_D)
	_r(-6.6, 54.5, 6.6, 57.2, Color("3a4a5a"))
	_r(-7.2, 57.2, 7.2, 58.0, CONC)
	_poly([-6.4, 58, 6.4, 58, 6.0, 60.4, -6.0, 60.4], Color("3a4a5a"))
	if _detail(1.0):
		for k in 8:
			var x := -5.6 + k * 1.6
			_l(x, 54.5, x, 57.2, Color("7a8a9a"), 0.12)
	_poly([-6.0, 60.4, 6.0, 60.4] + _arc(0, 60.4, 6.0, 2.4, 0, PI, 10), CONC)
	_poly([-0.4, 62.8, 0.4, 62.8, 0.1, 69.5, -0.1, 69.5], Color("c8ccd0"))
	_c(0, 69.6, 0.3, RED)
	_r(-10, 0, 10, 0.8, GRASS)

## The Wawa Goose: the giant Canada goose statue by the highway, black neck and head with the white chinstrap,
## grey-brown body and wings spread wide and high, on a stone base.
static func _wawa_goose() -> void:
	_spruce(-6.2, 0, 7, PINE)
	_spruce(6.3, 0, 6, PINE)
	_r(-3.2, 0, 3.2, 1.6, Color("8e8a84"))
	_r(-3.4, 1.6, 3.4, 1.9, Color("a8a49c"))
	var fea := Color("8a7c68")
	var fea_d := Color("5e5244")
	var tip := Color("3a332c")
	# the wings, raised in a wide V: the far one darker, ragged flight feathers along their inner edges
	var lw := [-0.6, 5.0, -2.2, 6.6, -4.0, 9.0, -5.6, 12.0, -6.4, 13.8, -5.0, 13.5, -4.5, 12.6, -3.6, 12.5, -3.1, 11.4,
		-2.2, 11.1, -1.7, 9.8, -0.7, 9.0, 0.1, 7.0, 1.0, 5.4]
	_poly(lw, fea_d)
	_poly([-5.6, 12.0, -6.4, 13.8, -5.0, 13.5, -4.5, 12.6, -3.6, 12.5, -3.1, 11.4, -4.4, 10.4], tip)
	var rw := []
	for k in range(0, lw.size(), 2):
		rw.append_array([0.8 - lw[k], lw[k + 1] + 0.1])
	_poly(rw, fea)
	_poly([6.4, 12.1, 7.2, 13.9, 5.8, 13.6, 5.3, 12.7, 4.4, 12.6, 3.9, 11.5, 5.2, 10.5], tip)
	if _detail(4.0):
		for k in 4:
			var t := 0.2 + k * 0.18
			_l(lerpf(1.2, 6.2, t), lerpf(5.6, 11.8, t), lerpf(1.2, 4.0, t) + 0.6, lerpf(5.6, 12.6, t) + 0.5, fea_d, 0.1)
			_l(lerpf(-0.4, -5.4, t), lerpf(5.5, 11.7, t), lerpf(-0.4, -3.2, t) - 0.6, lerpf(5.5, 12.5, t) + 0.5,
				fea_d.darkened(0.2), 0.1)
	# legs and feet
	_l(-0.3, 1.9, -0.2, 3.0, tip, 0.18)
	_l(0.9, 1.9, 0.8, 3.0, tip, 0.18)
	_r(-0.7, 1.9, 0.1, 2.05, tip)
	_r(0.5, 1.9, 1.3, 2.05, tip)
	# the body: grey-brown back, pale belly, black tail
	_poly([2.6, 4.6, 3.6, 4.2, 3.4, 3.7, 2.4, 3.8], tip)
	_ell(0.4, 4.2, 2.5, 1.35, 0.08, fea)
	_ell(0.0, 3.6, 1.8, 0.7, 0.05, Color("e8e2d4"))
	if _detail(4.0):
		for k in 3:
			_pl(_arc(0.9 + k * 0.6, 4.6, 0.5, 0.35, PI, 0, 5), fea_d, 0.08)
	# the long black neck and head, the white chinstrap and the beak
	_poly([-1.8, 4.2, -1.0, 5.0, -1.3, 7.8, -1.6, 8.6, -2.3, 8.5, -2.1, 7.6, -2.3, 5.2], tip)
	_ell(-2.3, 8.75, 0.6, 0.38, -0.1, tip)
	_poly([-2.9, 8.8, -3.6, 8.7, -2.9, 8.45], tip)
	_ell(-2.0, 8.5, 0.32, 0.2, -0.6, Color.WHITE)
	if _detail(6.0):
		_c(-2.45, 8.88, 0.06, Color.WHITE)
	_poly([-2.3, 5.2, -1.8, 4.2, -1.2, 4.4, -1.0, 5.0], Color("d8d0c0"))
