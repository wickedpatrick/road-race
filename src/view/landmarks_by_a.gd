class_name LandmarksByA
extends RefCounted
## Belarusian landmarks (Minsk to Pinsk), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const WHITE := Color("f3f0e8")
const CREAM := Color("efe3c4")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const BRICK := Color("a5452f")
const BRICK_D := Color("7f3424")
const GREEN_ROOF := Color("5f7f6c")
const GRASS := Color("5d8f42")
const TREE := Color("3f6f34")
const GOLD := Color("e0b43a")
const BRONZE := Color("6b5a3a")
const BRONZE_L := Color("8a7448")
const GRANITE := Color("8d8a84")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"by_minsk_library": _minsk_library()
		"by_homiel_palace": _homiel_palace()
		"by_viciebsk_amphitheatre": _viciebsk_amphitheatre()
		"by_mahiliou_ratusha": _mahiliou_ratusha()
		"by_hrodna_kalozha": _hrodna_kalozha()
		"by_brest_kholm_gate": _brest_kholm_gate()
		"by_babrujsk_beaver": _babrujsk_beaver()
		"by_baranavicy_locomotive": _baranavicy_locomotive()
		"by_barysau_stone": _barysau_stone()
		"by_pinsk_franciscan": _pinsk_franciscan()
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

static func _windows(x0: float, x1: float, y0: float, y1: float, n: int, col: Color) -> void:
	LandmarkPainter._windows(x0, x1, y0, y1, n, col)

static func _arc(cx: float, cy: float, rx: float, ry: float, a0: float, a1: float, n: int) -> Array:
	return LandmarkPainter._arc_pts(cx, cy, rx, ry, a0, a1, n)

static func _detail(min_pm: float) -> bool:
	return LandmarkPainter._pm > min_pm

## An arched window or door: a rectangle under a half circle.
static func _arched(x: float, y0: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.5, y0, x + w * 0.5, y0, x + w * 0.5, y0 + h - w * 0.5] + _arc(x, y0 + h - w * 0.5, w * 0.5, w * 0.5, 0, PI, 6), col)

## A row of merlons on top of a wall from x0 to x1 at height y.
static func _merlons(x0: float, x1: float, y: float, h: float, n: int, col: Color) -> void:
	var step := (x1 - x0) / n
	for k in n:
		_r(x0 + step * k + step * 0.15, y, x0 + step * k + step * 0.65, y + h, col)

## The National Library of Belarus in Minsk: a glass rhombicuboctahedron, the "diamond", 23 storeys high on a
## low podium; square faces head-on, the oblique ones darker, the corner triangles darkest.
static func _minsk_library() -> void:
	var pod := Color("d9d6cc")
	_r(-29, 0, 29, 9, pod)
	_r(-29.5, 8.4, 29.5, 9.2, Color("bdb9ad"))
	_windows(-27, 27, 2.5, 6.5, 14, Color("4a6278"))
	var s := 26.0
	var a := 10.8
	var cy := 35.0
	var light := Color("7fb0cc")
	var mid := Color("4f86a8")
	var dark := Color("2f5a76")
	# the whole octagon first, then the faces over it
	_poly([-a, cy - s, a, cy - s, s, cy - a, s, cy + a, a, cy + s, -a, cy + s, -s, cy + a, -s, cy - a], dark)
	_r(-a, cy - a, a, cy + a, light)
	_r(-a, cy + a, a, cy + s, mid)
	_r(-a, cy - s, a, cy - a, mid)
	_r(-s, cy - a, -a, cy + a, mid)
	_r(a, cy - a, s, cy + a, mid)
	# the facet edges and the storeys
	var edge := Color("cfe2ec")
	for e in [[-a, cy - s, -a, cy + s], [a, cy - s, a, cy + s], [-s, cy - a, s, cy - a], [-s, cy + a, s, cy + a]]:
		_l(e[0], e[1], e[2], e[3], edge, 0.25)
	if _detail(1.0):
		for k in 22:
			var y := cy - s + 2.4 * (k + 1)
			var hw := s if absf(y - cy) < a else s - (absf(y - cy) - a)
			_l(-hw, y, hw, y, Color(1, 1, 1, 0.18), 0.12)
	# the viewing platform on top
	_r(-4, cy + s, 4, cy + s + 3, Color("c9ccd0"))
	_l(0, cy + s + 3, 0, cy + s + 6, DARK, 0.3)

## The Rumyantsev-Paskevich Palace in Homieĺ: a Neoclassical palace with a portico and a green dome over the middle,
## long wings either side and the square tower with its belvedere on the right.
static func _homiel_palace() -> void:
	var roof := GREEN_ROOF
	# the wings
	_r(-38, 0, 38, 13, CREAM)
	_r(-38.5, 12.5, 38.5, 13.6, Color("d8c9a4"))
	_poly([-38.5, 13.6, 38.5, 13.6, 36, 16, -36, 16], roof)
	_windows(-36, -15, 3, 6.5, 7, WIN)
	_windows(-36, -15, 8.5, 11.5, 7, WIN)
	_windows(15, 36, 3, 6.5, 7, WIN)
	_windows(15, 36, 8.5, 11.5, 7, WIN)
	# the tower on the right
	_r(25, 13, 32, 29, CREAM)
	_windows(26, 31, 17, 20, 2, WIN)
	_windows(26, 31, 23, 26, 2, WIN)
	_r(24.5, 29, 32.5, 30, Color("d8c9a4"))
	for k in 4:
		_r(25.4 + k * 1.9, 30, 26.2 + k * 1.9, 33, WHITE)
	_poly([24.5, 33, 32.5, 33, 28.5, 36], roof)
	_l(28.5, 36, 28.5, 38.5, DARK, 0.15)
	_poly([28.5, 38.5, 30.3, 37.9, 28.5, 37.3], Color("c8102e"))
	# the middle block with the portico and the dome
	_r(-14, 0, 14, 19, CREAM)
	_r(-10, 1.2, 10, 15, Color("ddd0ae"))
	_arched(0, 1.2, 2.4, 5, Color("6b5040"))
	_windows(-8, 8, 8.5, 12, 4, WIN)
	_r(-10, 0, 10, 1.2, Color("d8c9a4"))
	for k in 6:
		var x := -9.0 + k * 3.6
		_r(x - 0.55, 1.2, x + 0.55, 15, WHITE)
	_poly([-10.5, 15, 10.5, 15, 0, 19.5], Color("e8dcc0"))
	_poly([-8.5, 15.6, 8.5, 15.6, 0, 18.7], Color("d8c9a4"))
	_r(-6.5, 19, 6.5, 24, CREAM)
	_windows(-5.5, 5.5, 20, 23, 4, WIN)
	_poly(_arc(0, 24, 7, 6, 0, PI, 14), roof)
	_r(-1, 29.6, 1, 32, WHITE)
	_poly([-1.3, 32, 1.3, 32, 0, 33.5], roof)

## The Summer Amphitheatre in Viciebsk, the stage of the Slavianski Bazaar: a great white roof curving over the stage,
## two masts holding it, the rows of seats below and the festival's flags.
static func _viciebsk_amphitheatre() -> void:
	# the banks of seats rising to both sides
	_poly([-35, 0, -20, 0, -20, 8, -35, 4], Color("a9a69c"))
	_poly([20, 0, 35, 0, 35, 4, 20, 8], Color("a9a69c"))
	for k in 4:
		var y := 1.0 + k * 1.6
		_l(-34, y * 0.6 + 0.4, -21, y + 0.4, Color("c84a3a"), 0.35)
		_l(21, y + 0.4, 34, y * 0.6 + 0.4, Color("c84a3a"), 0.35)
	# the stage house and its dark opening
	_r(-20, 0, 20, 12, Color("d8d4c8"))
	_r(-16, 1.5, 16, 11, Color("2a2e36"))
	_r(-16, 0, 16, 1.5, Color("6b5040"))
	if _detail(0.8):
		for x in [-12.0, -6.0, 0.0, 6.0, 12.0]:
			_c(x, 10.2, 0.45, Color("f2d36a"))
	# the white roof: a wave over the stage, thicker in the middle
	var top := []
	var bot := []
	for k in 21:
		var x := -34.0 + k * 3.4
		var t := x / 34.0
		top.append_array([x, 15.0 + 8.0 * (1.0 - t * t)])
		bot.push_front(12.5 + 5.0 * (1.0 - t * t))
		bot.push_front(x)
	_poly(top + bot, WHITE)
	# its shaded underside
	var under := []
	for k in 21:
		var x := -34.0 + k * 3.4
		var t := x / 34.0
		under.append_array([x, 12.5 + 5.0 * (1.0 - t * t)])
	for k in 21:
		var x := 34.0 - k * 3.4
		var t := x / 34.0
		under.append_array([x, 12.0 + 4.2 * (1.0 - t * t)])
	_poly(under, Color("cfcabd"))
	# the masts and the cables
	for x in [-24.0, 24.0]:
		_l(x, 0, x, 25, Color("8a8f96"), 0.5)
		_l(x, 25, x * 0.3, 21.5, Color("8a8f96"), 0.12)
		_l(x, 25, x * 1.35, 15.5, Color("8a8f96"), 0.12)
	# the festival flags
	var cols := [Color("c8102e"), Color("f2c418"), Color("1d5bbf"), Color("2f8f4a")]
	for i in 4:
		var x := -9.0 + i * 6.0
		_l(x, 23.5, x, 26.5, DARK, 0.1)
		_poly([x, 26.5, x + 1.8, 26.0, x, 25.5], cols[i])

## The town hall of Mahilioŭ: a white two-storey building with a dark roof and the tall tower in its middle, rising
## through square and slimmer tiers to a clock, a baroque cap and a spire.
static func _mahiliou_ratusha() -> void:
	var roof := Color("4f5e58")
	_r(-14, 0, 14, 11, WHITE)
	_r(-14.5, 10.5, 14.5, 11.5, Color("d6d2c6"))
	_poly([-14.5, 11.5, 14.5, 11.5, 11, 15.5, -11, 15.5], roof)
	for x in [-11.0, -8.0, -5.0, 5.0, 8.0, 11.0]:
		_arched(x, 1.5, 1.4, 3.2, WIN)
		_arched(x, 6.2, 1.4, 3.2, WIN)
	_arched(0, 0, 3.0, 5.5, Color("5a4436"))
	# the tower
	_r(-4.5, 11, 4.5, 26, WHITE)
	_r(-4.8, 25.5, 4.8, 26.5, Color("d6d2c6"))
	_arched(0, 15, 1.6, 4, WIN)
	_arched(0, 20, 1.6, 4, WIN)
	_r(-3.4, 26.5, 3.4, 34, WHITE)
	_c(0, 30.5, 2.0, Color("f6f3ea"))
	_c(0, 30.5, 1.7, Color("2a3036"))
	_l(0, 30.5, 0, 31.9, GOLD, 0.15)
	_l(0, 30.5, 1.0, 30.5, GOLD, 0.15)
	_r(-3.7, 34, 3.7, 34.8, Color("d6d2c6"))
	# the baroque cap: a bulge, a lantern, a slim spire
	_poly([-3.7, 34.8, 3.7, 34.8, 2.6, 37.5, 1.2, 38.5, -1.2, 38.5, -2.6, 37.5], roof)
	_r(-1.0, 38.5, 1.0, 41, WHITE)
	_poly([-1.3, 41, 1.3, 41, 0, 46.5], roof)
	_l(0, 46.5, 0, 48, GOLD, 0.15)

## The Kalozha church in Hrodna (12th century): walls of grey brick set with coloured stones and the mouths of clay
## jugs, the side that slid into the Neman in 1853 rebuilt in wood, a low roof and a small cupola.
static func _hrodna_kalozha() -> void:
	var wall := Color("b9a99a")
	_r(-12, 0, 6, 12, wall)
	# the wooden part on the right
	_r(6, 0, 12, 12, Color("8a6440"))
	if _detail(0.8):
		for k in 6:
			_l(6.5 + k, 0.2, 6.5 + k, 11.8, Color("6b4a30"), 0.08)
	# the coloured stones and the jug mouths, in a fixed pattern
	var cols := [Color("c86a50"), Color("6f7f8a"), Color("d8b070"), Color("7a8f5a"), Color("9a5a7a")]
	for row in 5:
		for k in 8:
			var x := -11.0 + k * 2.2 + (row % 2) * 1.1
			var y := 1.5 + row * 2.2
			if x > 5.3: continue
			_c(x, y, 0.42, cols[(row * 3 + k) % cols.size()])
	for x in [-9.0, -4.0, 1.0]:
		_c(x, 10.6, 0.5, DARK)
	_arched(-3, 0, 2.6, 5.5, Color("3a2e28"))
	_arched(-9, 4, 1.0, 2.6, WIN)
	_arched(3, 4, 1.0, 2.6, WIN)
	# the roof and the cupola
	_poly([-12.8, 12, 12.8, 12, 9, 16, -9, 16], Color("5a5248"))
	_r(-1.2, 16, 1.2, 17.6, wall)
	_poly(_arc(0, 17.6, 1.5, 1.6, 0, PI, 8), Color("5a5248"))
	_l(0, 19.2, 0, 20, GOLD, 0.15)
	_l(-0.4, 19.7, 0.4, 19.7, GOLD, 0.12)

## The Kholm Gate of the Brest fortress: a red brick gate with a round-arched passage, a row of small windows, and
## three crenellated turrets over the top.
static func _brest_kholm_gate() -> void:
	_r(-19, 0, 19, 12, BRICK)
	_r(-19.5, 11.4, 19.5, 12.2, BRICK_D)
	_merlons(-19, 19, 12.2, 1.2, 19, BRICK)
	_arched(0, 0, 5, 7.5, Color("2a2420"))
	for x in [-15.0, -12.0, -9.0, -6.0, 6.0, 9.0, 12.0, 15.0]:
		_arched(x, 7.0, 1.0, 2.6, WIN)
		_arched(x, 2.0, 1.0, 2.6, WIN)
	# white trim of the arch
	_poly(_arc(0, 5.0, 3.0, 3.0, 0, PI, 10) + _arc(0, 5.0, 2.5, 2.5, PI, 0, 10), Color("e8dcc8"))
	# the turrets
	for x in [-11.0, 0.0, 11.0]:
		var w := 2.2 if x == 0.0 else 1.8
		_r(x - w, 12.2, x + w, 16.0, BRICK)
		_r(x - w - 0.3, 15.6, x + w + 0.3, 16.2, BRICK_D)
		_merlons(x - w - 0.3, x + w + 0.3, 16.2, 1.0, 4, BRICK)
		_arched(x, 13.0, 0.8, 2.0, WIN)
	if _detail(1.0):
		for row in 6:
			_l(-19, 1.0 + row * 1.8, -16.5, 1.0 + row * 1.8, BRICK_D, 0.08)
			_l(16.5, 1.0 + row * 1.8, 19, 1.0 + row * 1.8, BRICK_D, 0.08)

## The beaver of Babrujsk: a bronze beaver sitting up on a low granite plinth, its flat tail behind it.
static func _babrujsk_beaver() -> void:
	_r(-2.2, 0, 2.2, 1.0, GRANITE)
	_r(-2.4, 0.9, 2.4, 1.1, Color("a8a49c"))
	# the tail, flat and scaly, on the plinth
	_ell(1.6, 1.4, 1.3, 0.35, -0.2, Color("4f4230"))
	if _detail(3.0):
		for k in 3:
			_l(1.0 + k * 0.45, 1.2, 1.1 + k * 0.45, 1.6, BRONZE_L, 0.04)
	# the body, sitting up
	_ell(0, 2.7, 1.15, 1.6, 0.0, BRONZE)
	_ell(0.15, 2.4, 0.7, 1.0, 0.0, BRONZE_L)
	# the head, the ears, the nose and the front teeth
	_c(0, 4.6, 0.75, BRONZE)
	_c(-0.55, 5.2, 0.22, BRONZE)
	_c(0.55, 5.2, 0.22, BRONZE)
	_ell(0, 4.25, 0.42, 0.3, 0.0, BRONZE_L)
	_c(0, 4.45, 0.12, DARK)
	_r(-0.09, 3.85, 0.09, 4.05, Color("e8dcb0"))
	_c(-0.3, 4.85, 0.09, DARK)
	_c(0.3, 4.85, 0.09, DARK)
	# the paws held in front
	_ell(-0.4, 3.4, 0.25, 0.16, 0.4, Color("4f4230"))
	_ell(0.4, 3.4, 0.25, 0.16, -0.4, Color("4f4230"))
	_ell(-0.6, 1.2, 0.4, 0.18, 0.0, Color("4f4230"))
	_ell(0.6, 1.2, 0.4, 0.18, 0.0, Color("4f4230"))

## A steam locomotive of the Baranavičy railway museum on its stretch of track: black boiler, red wheels, the cab
## and the tender behind.
static func _baranavicy_locomotive() -> void:
	# the track
	_r(-12, 0, 12, 0.35, Color("6b5a48"))
	if _detail(1.5):
		for k in 16:
			_r(-11.6 + k * 1.5, 0, -11.0 + k * 1.5, 0.35, Color("4a3e32"))
	_r(-12, 0.35, 12, 0.5, Color("8a8f96"))
	var black := Color("23262a")
	var red := Color("b02a24")
	# the tender
	_r(5.5, 1.2, 11.5, 4.2, black)
	_r(5.5, 3.8, 11.5, 4.2, red)
	for x in [7.0, 10.0]:
		_c(x, 1.25, 0.75, red)
		_c(x, 1.25, 0.25, black)
	# the frame, the boiler, the smokebox and the chimney
	_r(-10.5, 1.4, 5, 2.2, black)
	_r(-11.2, 1.3, -10.2, 2.0, red)
	_r(-9.5, 2.2, 0.5, 5.0, black)
	_c(-9.5, 3.6, 1.4, Color("33373c"))
	_r(-8.6, 5.0, -7.4, 6.8, black)
	_r(-8.9, 6.6, -7.1, 7.0, black)
	_r(-4.5, 5.0, -3.3, 5.8, black)
	_poly(_arc(-1.5, 5.0, 0.8, 0.8, 0, PI, 6), black)
	_l(-9.5, 4.2, 0.5, 4.2, red, 0.12)
	# the cab
	_r(0.5, 2.2, 5.0, 6.0, black)
	_r(0.2, 6.0, 5.4, 6.5, Color("33373c"))
	_r(1.3, 3.8, 2.8, 5.2, Color("8aa0b0"))
	_r(3.3, 3.8, 4.4, 5.2, Color("8aa0b0"))
	_r(0.5, 2.2, 5.0, 2.6, red)
	# the driving wheels and the rods
	for x in [-6.6, -3.8, -1.0]:
		_c(x, 1.55, 1.15, red)
		_c(x, 1.55, 0.3, black)
	_c(-9.2, 1.1, 0.6, red)
	_c(3.0, 1.1, 0.6, red)
	_l(-6.6, 1.3, -1.0, 1.3, Color("c9ccd0"), 0.15)
	# a puff of steam
	if _detail(1.0):
		_c(-8.0, 8.0, 0.8, Color(1, 1, 1, 0.75))
		_c(-7.1, 8.8, 1.0, Color(1, 1, 1, 0.6))

## The Barys Stone in Barysaŭ: a grey granite boulder carved in the 12th century with a cross and an inscription,
## on a low stone setting.
static func _barysau_stone() -> void:
	_r(-3.8, 0, 3.8, 0.4, Color("a8a49c"))
	var g := Color("8f8c88")
	_poly([-3.4, 0.4, 3.5, 0.4, 3.8, 1.4, 3.1, 2.6, 1.6, 3.3, -0.6, 3.5, -2.4, 2.9, -3.5, 1.8], g)
	_poly([-2.6, 2.3, -0.6, 3.1, 1.4, 2.9, 0.4, 2.4, -1.4, 2.2], Color("a5a29c"))
	_c(2.4, 1.2, 0.35, Color("7d7a76"))
	_c(-2.6, 1.0, 0.25, Color("9c9894"))
	# the cross, carved deep, on a step
	var cut := Color("4a4844")
	_l(-1.2, 0.9, -1.2, 2.9, cut, 0.16)
	_l(-1.8, 2.3, -0.6, 2.3, cut, 0.16)
	_l(-1.7, 0.9, -0.7, 0.9, cut, 0.12)
	# the lines of the inscription
	if _detail(2.0):
		for k in 4:
			var y := 2.5 - k * 0.45
			_l(-0.2, y, 2.4 - k * 0.15, y, cut, 0.06)

## The Franciscan Church of the Assumption in Pinsk: a pale yellow Baroque front with white pilasters and a curved
## gable, the long nave behind, and the tall separate bell tower to its right.
static func _pinsk_franciscan() -> void:
	var wall := Color("efe2bf")
	var trim := Color("f8f4ea")
	var roof := Color("6d5a4a")
	# the nave behind the front
	_r(-26, 0, -6, 16, wall)
	_poly([-26.5, 16, -5.5, 16, -8, 21, -24, 21], roof)
	for x in [-23.0, -18.0, -13.0]:
		_arched(x, 4, 1.8, 7, WIN)
	# the front
	_r(-6, 0, 10, 20, wall)
	for x in [-5.5, -1.0, 5.0, 9.5]:
		_r(x - 0.4, 0, x + 0.4, 19, trim)
	_r(-6.3, 9.5, 10.3, 10.3, trim)
	_r(-6.3, 19, 10.3, 20, trim)
	_arched(2, 0, 3, 7, Color("5a4436"))
	_arched(2, 12, 2.2, 5.5, WIN)
	_arched(-3.2, 12, 1.4, 4, WIN)
	_arched(7.2, 12, 1.4, 4, WIN)
	# the curved gable with its volutes
	_poly([-4, 20, 8, 20, 6.5, 23, 4.5, 26, -0.5, 26, -2.5, 23], wall)
	_c(-4, 21, 1.2, trim)
	_c(8, 21, 1.2, trim)
	_poly([-1.0, 26, 5.0, 26, 2, 28], trim)
	_l(2, 28, 2, 30, GOLD, 0.2)
	_l(1.2, 29.3, 2.8, 29.3, GOLD, 0.15)
	_c(2, 23.3, 1.0, Color("c9ccd0"))
	# the bell tower
	var tx := 20.0
	_r(tx - 5, 0, tx + 5, 15, wall)
	_r(tx - 5.3, 14.5, tx + 5.3, 15.3, trim)
	_arched(tx, 2, 2.2, 6, WIN)
	_r(tx - 4, 15.3, tx + 4, 25, wall)
	_r(tx - 4.3, 24.5, tx + 4.3, 25.3, trim)
	_arched(tx, 17, 2.2, 6, Color("2a2e36"))
	_r(tx - 3, 25.3, tx + 3, 32, wall)
	_arched(tx, 26.5, 1.6, 4.5, Color("2a2e36"))
	_r(tx - 3.3, 32, tx + 3.3, 32.8, trim)
	_poly(_arc(tx, 32.8, 3.2, 4.2, 0, PI, 10), roof)
	_r(tx - 0.8, 37, tx + 0.8, 39.5, wall)
	_poly([tx - 1.1, 39.5, tx + 1.1, 39.5, tx, 43.5], roof)
	_l(tx, 43.5, tx, 46, GOLD, 0.18)
	_l(tx - 0.7, 45.2, tx + 0.7, 45.2, GOLD, 0.14)
