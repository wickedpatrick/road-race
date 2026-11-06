class_name LandmarksHrB
extends RefCounted
## Croatian landmarks (Varaždin to Gospić), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const STONE := Color("e6dcc4")
const STONE_D := Color("c9bb9b")
const LIME := Color("efe9da")
const ROOF := Color("c4562f")
const ORANGE_ROOF := Color("d8743a")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const BRICK := Color("a8432f")
const GRASS := Color("5d8f42")
const WATER := Color("3f86b8")
const ROCK := Color("a39e92")
const HR_RED := Color("d0102e")
const HR_BLUE := Color("17377f")
const GOLD := Color("e0b43a")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"varazdin_castle": _varazdin()
		"dubrovnik_walls": _dubrovnik()
		"sisak_fortress": _sisak()
		"bjelovar_church": _bjelovar()
		"zrinski_castle": _zrinski()
		"vukovar_water_tower": _vukovar()
		"pozega_trinity": _trinity()
		"biokovo_skywalk": _skywalk()
		"tesla_smiljan": _tesla()
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

static func _archway(x: float, hw: float, y0: float, y1: float, col: Color) -> void:
	_poly([x + hw, y0, x + hw, y1] + _arc(x, y1, hw, hw, 0, PI, 6) + [x - hw, y0], col)

## A small Croatian flag (red, white, blue) on a pole at x, the pole's top at y.
static func _flag(x: float, y: float, w: float) -> void:
	var h := w * 0.5
	_l(x, y - h * 3.0, x, y, DARK, 0.2)
	_r(x, y - h / 3.0, x + w, y, HR_RED)
	_r(x, y - h * 2.0 / 3.0, x + w, y - h / 3.0, Color.WHITE)
	_r(x, y - h, x + w, y - h * 2.0 / 3.0, HR_BLUE)

## Varaždin's Old Castle: the white Renaissance fortress with its round corner towers and red pyramid roofs,
## behind green earthen ramparts and a moat, the gate tower in front.
static func _varazdin() -> void:
	_r(-22, 0, 22, 1.4, WATER)
	_poly([-21, 1.4, 21, 1.4, 17, 6, -17, 6], GRASS)
	_r(-12, 6, 12, 17, LIME)
	_windows(-11, 11, 11, 13.5, 8, WIN)
	_poly([-13, 17, 13, 17, 10, 21, -10, 21], ROOF)
	for x in [-14.0, 14.0]:
		_r(x - 3, 6, x + 3, 20, LIME)
		_poly([x - 3.5, 20, x + 3.5, 20, x, 26], ROOF)
	# gate tower
	_r(-3, 6, 3, 23, Color("f3eee2"))
	_archway(0, 1.4, 6, 9.5, DARK)
	_r(-0.8, 15, 0.8, 17, WIN)
	_poly([-3.5, 23, 3.5, 23, 0, 28], ROOF)

## Dubrovnik: the round Minčeta tower with its crown of merlons above the wall, the orange roofs of the Old Town
## below it and the sea at its foot.
static func _dubrovnik() -> void:
	_r(-30, 0, 30, 1.5, WATER)
	var s := Color("dccfb0")
	_poly([-30, 1.5, 30, 1.5, 30, 12, -30, 12], s)
	_r(-30, 12, 30, 13, s.darkened(0.1))
	# roofs of the Old Town peeking over the wall
	for k in 9:
		var x := -26.0 + k * 5.5
		var h := 13.0 + (k % 3) * 1.2
		_poly([x - 2.6, h, x + 2.6, h, x, h + 2.5], ORANGE_ROOF.darkened(0.04 * (k % 2)))
	# a bell tower
	_r(-6, 13, -3.5, 22, s)
	_poly([-6.3, 22, -3.2, 22, -4.75, 24.5], ORANGE_ROOF)
	# Minčeta
	_r(8, 1.5, 22, 22, s.lightened(0.04))
	_poly([7, 1.5, 23, 1.5, 22, 8, 8, 8], s.darkened(0.08))
	_r(9.5, 22, 20.5, 26, s)
	for k in 5:
		_r(9.5 + k * 2.4, 26, 10.8 + k * 2.4, 28, s)
	_r(14.4, 15, 15.6, 18, WIN)
	_flag(15, 30, 3.0)

## Old Sisak fortress: a triangle of brick walls with three big round towers, white-washed with red roofs,
## on the bank of the Kupa.
static func _sisak() -> void:
	_r(-23, 0, 23, 1.5, WATER)
	_r(-23, 1.5, 23, 3, GRASS)
	_r(-16, 3, 16, 10, Color("ece4d0"))
	for x in [-17.0, 0.0, 17.0]:
		var rr := 5.0 if x == 0.0 else 6.0
		_r(x - rr, 3, x + rr, 14, BRICK if x != 0.0 else BRICK.lightened(0.1))
		_poly([x - rr - 0.5, 14] + _arc(x, 14, rr + 0.5, 5.5, PI, 0, 10) + [x + rr + 0.5, 14], ROOF)
		_r(x - 0.6, 7, x + 0.6, 9, WIN)

## Bjelovar's Cathedral of St Teresa: a yellow Baroque church with a single front tower and an onion-like cap.
static func _bjelovar() -> void:
	var y := Color("efd889")
	_r(-12, 0, 12, 16, y)
	_poly([-12.5, 16, 12.5, 16, 0, 23], ROOF)
	_windows(-11, 11, 6, 11, 5, WIN)
	_r(-4, 0, 4, 30, y.lightened(0.05))
	_archway(0, 1.5, 0, 4, DARK)
	_c(0, 25, 1.4, Color.WHITE)
	_r(-4.4, 30, 4.4, 31, LIME)
	_poly([-3.8, 31] + _arc(0, 31, 3.8, 4.5, PI, 0, 10) + [3.8, 31], Color("3e6b56"))
	_poly([-1.2, 35.3, 1.2, 35.3, 1.6, 37] + _arc(0, 37, 1.6, 2.4, 0, PI, 6), Color("3e6b56"))
	_l(0, 39.4, 0, 44, GOLD, 0.25)
	_l(-0.9, 42.8, 0.9, 42.8, GOLD, 0.25)

## The Zrinski castle in Čakovec: a square palace around a courtyard, two storeys, a tall square tower over the
## gate, within an earthen star rampart.
static func _zrinski() -> void:
	_poly([-22, 0, 22, 0, 19, 4, -19, 4], GRASS)
	var s := Color("f1e6cc")
	_r(-17, 4, 17, 15, s)
	_windows(-16, 16, 6, 8.5, 10, WIN)
	_windows(-16, 16, 10.5, 13, 10, WIN)
	_poly([-17.5, 15, 17.5, 15, 15, 18.5, -15, 18.5], ROOF)
	_r(-3, 4, 3, 22, s.lightened(0.04))
	_archway(0, 1.5, 4, 7.5, DARK)
	_r(-0.7, 17, 0.7, 19, WIN)
	_poly([-3.5, 22, 3.5, 22, 0, 26], ROOF)

## The Vukovar water tower: a concrete shaft with a wide tank on top, still full of shell holes from 1991, the
## Croatian flag flying on its top as a memorial.
static func _vukovar() -> void:
	var c := Color("bcb8ae")
	_poly([-3.5, 0, 3.5, 0, 2.6, 30, -2.6, 30], c)
	_poly([-2.6, 30, 2.6, 30, 7.5, 36, -7.5, 36], c.darkened(0.06))
	_r(-7.5, 36, 7.5, 43, c.lightened(0.05))
	_r(-7.8, 43, 7.8, 44, c.darkened(0.1))
	var holes := [[-1.5, 6], [1.2, 11], [-0.8, 17], [1.6, 22], [-1.8, 26], [-5, 39], [-2, 41], [2.5, 38], [5.5, 40], [0.5, 37.5]]
	for h in holes:
		_c(h[0], h[1], 0.55, DARK)
	_flag(0, 50, 4.0)

## The Holy Trinity plague column in Požega: a Baroque pillar on a stepped base with saints at the corners, a
## cloud and the Trinity group on top with a golden ray.
static func _trinity() -> void:
	var s := Color("dcd5c4")
	_r(-5.5, 0, 5.5, 1, s.darkened(0.08))
	_r(-4.5, 1, 4.5, 4.5, s)
	for x in [-4.0, 4.0]:
		_r(x - 0.6, 4.5, x + 0.6, 6.5, s.darkened(0.05))
		_c(x, 7, 0.5, s.darkened(0.05))
	_r(-1, 4.5, 1, 13, s)
	_r(-1.4, 12.8, 1.4, 13.4, s.darkened(0.1))
	LandmarkPainter._ell(0, 14.5, 2.5, 1.3, 0, s.lightened(0.05))
	_r(-1.2, 15.2, 1.2, 16.8, s)
	_c(0, 17.2, 0.6, s)
	_poly([-0.2, 17.5, 0.2, 17.5, 0, 18], GOLD)

## The Biokovo Skywalk: a glass horseshoe sticking out from the grey limestone wall high above the Makarska coast,
## the sea far below.
static func _skywalk() -> void:
	_r(-25, 0, 25, 4, WATER)
	_poly([-25, 4, 25, 4, 25, 30, 6, 30, -2, 22, -25, 20], ROCK)
	_poly([-25, 4, -5, 4, -10, 12, -25, 14], Color("6f8f4c"))
	_poly([10, 30, 25, 30, 25, 27], ROCK.darkened(0.1))
	# the walkway: a frame and glass
	_r(-12, 21.6, 6, 22.4, Color("9fd4ec", 0.8))
	_l(-12, 22.4, -12, 24, DARK, 0.15)
	_l(-12, 24, 6, 24, DARK, 0.15)
	_l(-6, 22.4, -6, 24, DARK, 0.15)
	for x in [-11.0, -9.0]:
		_l(x, 22.4, x, 23.7, Color("e2513a"), 0.35)
		_c(x, 24.2, 0.35, Color("e2b08a"))

## Nikola Tesla Memorial Centre in Smiljan: Tesla's white family house with a red tiled roof beside the church,
## and a Tesla coil with sparks flying from its round top.
static func _tesla() -> void:
	_r(-18, 0, 18, 1, GRASS)
	_r(-16, 1, -2, 9, LIME)
	_poly([-17, 9, -1, 9, -4, 13.5, -14, 13.5], ROOF)
	_windows(-15, -3, 4, 6.5, 4, WIN)
	_r(-10.2, 1, -8.6, 5, DARK)
	# the coil
	_r(9, 1, 13, 2, DARK)
	_r(10.2, 2, 11.8, 14, Color("b87333"))
	for y in range(3, 14, 2):
		_l(10.2, y, 11.8, y, Color("8a5524"), 0.12)
	LandmarkPainter._ell(11, 15.2, 3.4, 1.4, 0, Color("cfd3d8"))
	var spark := Color("bfe6ff")
	_l(14, 15.5, 16.5, 18, spark, 0.2)
	_l(16.5, 18, 15.6, 19.5, spark, 0.2)
	_l(8, 15.5, 5.5, 17.5, spark, 0.2)
	_l(5.5, 17.5, 6.6, 20, spark, 0.2)
	_l(11, 16.5, 11.6, 19, spark, 0.2)
	_l(11.6, 19, 10.6, 21.5, spark, 0.2)
