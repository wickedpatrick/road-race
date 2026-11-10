class_name LandmarksNoB
extends RefCounted
## Norwegian landmarks (Molde to Hammerfest), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const WIN := Color("38404a")
const DARK := Color("2c3036")
const GRASS := Color("5a8c40")
const ROCK := Color("6e6a64")
const WATER := Color("466f94")
const WATER_L := Color("7aa2c0")
const SNOW := Color("eef2f4")
const STEEL := Color("9aa2a8")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"no_molde_domkirke": _molde_domkirke()
		"no_flam_flamsbana": _flam_flamsbana()
		"no_moirana_havmannen": _moirana_havmannen()
		"no_bodo_saltstraumen": _bodo_saltstraumen()
		"no_narvik_halogaland": _narvik_halogaland()
		"no_tromso_ishavskatedralen": _tromso_ishavskatedralen()
		"no_alta_nordlys": _alta_nordlys()
		"no_hammerfest_meridian": _hammerfest_meridian()
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

## Molde Cathedral (1957): a long brick church with a steep roof and, beside it, the tall free-standing square bell
## tower with a slim cross on top.
static func _molde_domkirke() -> void:
	var brick := Color("a65a40")
	var brick_d := Color("8a4834")
	_r(-22, 0, 22, 0.8, GRASS)
	# the church
	_r(-20, 0.8, 6, 12, brick)
	_poly([-21, 12, 7, 12, 7, 13, -7, 22, -21, 13], Color("4a4e54"))
	for k in 5:
		_r(-18 + k * 4.8, 4, -16.6 + k * 4.8, 10, WIN)
	_r(-1.6, 0.8, 1.6, 5.4, DARK)
	# the bell tower
	_r(10, 0.8, 18, 44, brick)
	_r(10, 43, 18, 44.6, brick_d)
	for k in 3:
		_r(11.2 + k * 2.4, 36, 12.6 + k * 2.4, 41.5, DARK)
	_r(13.75, 44.6, 14.25, 51.5, Color("d8d4c8"))
	_r(12.6, 49, 15.4, 49.5, Color("d8d4c8"))

## The Flåm Railway (1940): a green train climbing a steep track along a mountainside above the valley, with a
## waterfall in the gorge (Kjosfossen) and snow on the peaks.
static func _flam_flamsbana() -> void:
	_poly([-35, 0, 35, 0, 35, 22, 20, 34, 6, 26, -12, 32, -35, 18], ROCK)
	_poly([20, 34, 26, 30, 14, 29.5, 6, 26, 12, 30.5], SNOW)
	_r(-35, 0, 35, 2.4, GRASS)
	# the waterfall
	_poly([24, 2.4, 28, 2.4, 27, 24, 25.6, 24], WATER_L)
	# the track rising to the right
	_l(-33, 4, 18, 16, Color("4a3e34"), 0.8)
	# the train: a locomotive and three carriages on the slope
	var ang := atan2(12.0, 51.0)
	for k in 4:
		var x := -26.0 + k * 9.0
		var y := 4.0 + (x + 33.0) * 12.0 / 51.0 + 0.4
		var d := Vector2(cos(ang), sin(ang))
		var n := Vector2(-sin(ang), cos(ang))
		var p0 := Vector2(x, y)
		var corners := [p0, p0 + d * 8.2, p0 + d * 8.2 + n * 3.4, p0 + n * 3.4]
		var col := Color("2f6b45") if k > 0 else Color("1f4f34")
		_poly([corners[0].x, corners[0].y, corners[1].x, corners[1].y, corners[2].x, corners[2].y, corners[3].x, corners[3].y], col)
		if _detail(1.5):
			var w0: Vector2 = p0 + d * 1.0 + n * 1.6
			var w1: Vector2 = p0 + d * 7.2 + n * 1.6
			_l(w0.x, w0.y, w1.x, w1.y, Color("d8d0b0"), 0.9)

## Havmannen (1995) by Antony Gormley: a ten-metre granite man standing upright in the fjord at Mo i Rana, arms at his
## sides, with the town's quay behind.
static func _moirana_havmannen() -> void:
	var granite := Color("5c5c60")
	_r(-10, 0, 10, 2.2, WATER)
	# legs standing in the water, the ripple over them, body, arms and head
	_r(-0.9, 2.2, -0.15, 5.2, granite)
	_r(0.15, 2.2, 0.9, 5.2, granite)
	_r(-10, 2.2, 10, 2.5, WATER_L)
	_poly([-1.2, 5.2, 1.2, 5.2, 1.3, 8.6, -1.3, 8.6], granite)
	_r(-1.75, 5.4, -1.3, 8.4, granite)
	_r(1.3, 5.4, 1.75, 8.4, granite)
	_r(-0.3, 8.6, 0.3, 9.0, granite)
	_c(0, 9.6, 0.65, granite)

## Saltstraumen: the tidal current racing through the narrow strait in whirlpools, under the Saltstraumen Bridge (1978), a
## cantilever box girder whose haunched underside reads as a high arch, with rocky shores on both sides.
static func _bodo_saltstraumen() -> void:
	_r(-40, 0, 40, 4, WATER)
	_poly([-40, 4, -22, 4, -26, 10, -40, 12], ROCK)
	_poly([40, 4, 22, 4, 26, 10, 40, 12], ROCK)
	# whirlpools
	for w in [[-10.0, 2.0, 3.2], [4.0, 1.6, 2.6], [14.0, 2.4, 2.0]]:
		var pts := _arc(w[0], w[1], w[2], w[2] * 0.3, 0, TAU, 12)
		for i in range(0, pts.size() - 2, 2):
			_l(pts[i], pts[i + 1], pts[i + 2], pts[i + 3], WATER_L, 0.3)
	# the haunched underside and the deck
	var arch := _arc(0, 4, 24, 19, PI, 0, 16)
	for i in range(0, arch.size() - 2, 2):
		_l(arch[i], arch[i + 1], arch[i + 2], arch[i + 3], Color("c8ccd0"), 1.4)
	_r(-40, 24, 40, 25.6, Color("b8bcc0"))
	for k in 9:
		var x := -20.0 + k * 5.0
		var y := 4.0 + 19.0 * sqrt(maxf(0.0, 1.0 - pow(x / 24.0, 2)))
		_l(x, y, x, 24, STEEL, 0.3)

## The Hålogaland Bridge (2018): a suspension bridge across the Rombaksfjord, two tall concrete A-shaped towers, the
## main cables sagging between them and snowy mountains behind.
static func _narvik_halogaland() -> void:
	_poly([-60, 0, -30, 26, -6, 12, 18, 30, 60, 6, 60, 0], Color("7a7e84"))
	_poly([-36, 21, -30, 26, -24, 22, -30, 23], SNOW)
	_poly([12, 26, 18, 30, 25, 26, 18, 27], SNOW)
	_r(-60, 0, 60, 2, WATER)
	var deck := 9.0
	_r(-60, deck, 60, deck + 1.2, Color("8a9096"))
	for s in [-1, 1]:
		var x: float = s * 36.0
		_poly([x - 3, 2, x - 1.6, 2, x - 0.3, 38, x + 0.3, 38, x + 1.6, 2, x + 3, 2, x + 0.6, 40, x - 0.6, 40], Color("d0d0cc"))
		_r(x - 2.4, deck + 1.2, x + 2.4, deck + 2, Color("d0d0cc"))
	# the main cable between and beyond the towers
	var pts := _arc(0, 38, 36, 26, PI, TAU, 16)
	for i in range(0, pts.size() - 2, 2):
		_l(pts[i], pts[i + 1], pts[i + 2], pts[i + 3], Color("40464c"), 0.5)
	_l(-36, 38, -60, deck + 2, Color("40464c"), 0.5)
	_l(36, 38, 60, deck + 2, Color("40464c"), 0.5)
	if _detail(1.0):
		for k in 13:
			var hx := -30.0 + k * 5.0
			var hy := 38.0 - 26.0 * sqrt(maxf(0.0, 1.0 - pow(hx / 36.0, 2)))
			_l(hx, deck + 1.2, hx, hy, Color("5a6066"), 0.15)

## The Arctic Cathedral (1965): white triangular wall planes stepping up one behind another to a tall gable, with the
## glass mosaic in the east wall and the snowy hills behind.
static func _tromso_ishavskatedralen() -> void:
	_poly([-22, 0, -22, 14, -6, 24, 10, 18, 22, 22, 22, 0], Color("8a96a2"))
	_r(-22, 0, 22, 1, SNOW)
	# the stepped triangular planes, from the low back ones to the high front one
	var shades := [Color("c9ced3"), Color("d6dadf"), Color("e2e6ea"), Color("eef1f4"), Color("f8fafb")]
	for k in 5:
		var w := 9.0 + k * 3.2
		var h := 14.0 + k * 5.2
		_poly([-w, 1, w, 1, 0, 1 + h], shades[k])
		_poly([-w, 1, -w + 0.6, 1, 0, 1 + h - 0.8, 0, 1 + h], Color("9aa2aa"))
	# the glass front
	_poly([-5.5, 1, 5.5, 1, 0, 14], Color("6a8fb6"))
	if _detail(1.2):
		for k in 4:
			_l(-4.0 + k * 2.7, 1, 0, 14, Color("b8cce0"), 0.2)
	_r(-1.6, 1, 1.6, 4, DARK)

## The Northern Lights Cathedral in Alta (2013): a low curved body and a tower clad in titanium plates that winds up
## in a spiral to a slim point, the northern lights above.
static func _alta_nordlys() -> void:
	var ti := Color("a9b0b4")
	var ti_d := Color("858d92")
	if _detail(0.8):
		_poly([-18, 40, -6, 46, 8, 42, 18, 47, 18, 44, 8, 39, -6, 43, -18, 37], Color(0.4, 0.9, 0.6, 0.5))
	_r(-18, 0, 18, 0.8, SNOW)
	# the low body
	_poly([-17, 0.8, 8, 0.8, 8, 8, -4, 9.5, -17, 6], ti)
	_windows(-14, 4, 2.6, 4.6, 5, WIN)
	# the spiral tower
	_poly([0, 0.8, 12, 0.8, 9, 18, 6.4, 30, 5.2, 46, 4.4, 30, 2, 18], ti)
	for k in 6:
		var y0 := 3.0 + k * 6.0
		var w := 10.0 - k * 1.5
		_l(6 - w * 0.5, y0, 6 + w * 0.5, y0 + 3.6, ti_d, 0.5)

## The Meridian Column (1854): a granite column on a stepped base, topped by a bronze globe, marking the northern end
## of the Struve Geodetic Arc on the Fuglenes point by the harbour.
static func _hammerfest_meridian() -> void:
	var granite := Color("8c8478")
	_r(-8, 0, 8, 0.6, ROCK)
	_r(-3.4, 0.6, 3.4, 1.6, granite)
	_r(-2.6, 1.6, 2.6, 2.6, granite)
	_poly([-1.0, 2.6, 1.0, 2.6, 0.7, 10.6, -0.7, 10.6], Color("9a9286"))
	_r(-1.1, 10.6, 1.1, 11.2, granite)
	_c(0, 12.2, 1.0, Color("6a5a3a"))
	_l(-1.0, 12.2, 1.0, 12.2, Color("8a7a52"), 0.15)
