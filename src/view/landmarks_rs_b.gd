class_name LandmarksRsB
extends RefCounted
## Serbian landmarks (Smederevo to Kladovo), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const STONE := Color("cdbf9f")
const STONE_D := Color("a99a7a")
const BRICK := Color("a5452f")
const WATER := Color("4f8fc0")
const WATER_L := Color("9cc8e6")
const GRASS := Color("5d8f42")
const TREE := Color("3f6f34")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const WHITE := Color("f2efe6")
const CONCRETE := Color("b8b6ae")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"smederevo_fortress": _smederevo_fortress()
		"pljeskavica": _pljeskavica()
		"tesnjar": _tesnjar()
		"sargan_eight": _sargan_eight()
		"beli_most": _beli_most()
		"sabac_tower": _sabac_tower()
		"romuliana": _romuliana()
		"pirot_kilim": _pirot_kilim()
		"djerdap_dam": _djerdap_dam()
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

## Merlons along a wall top from x0 to x1 at height y.
static func _merlons(x0: float, x1: float, y: float, w: float, col: Color) -> void:
	var x := x0
	while x + w <= x1 + 0.01:
		_r(x, y, x + w, y + w, col)
		x += w * 2.0

## Smederevo Fortress: the long curtain wall by the Danube, its square towers with merlons, the taller towers of the
## inner Small Town at one end.
static func _smederevo_fortress() -> void:
	var s := Color("b9a27e")
	_r(-35, 0, 35, 2, WATER)
	_r(-33, 2, 33, 12, s)
	_merlons(-33, 33, 12, 1, s)
	for i in 7:
		var x := -30.0 + i * 9.5
		_r(x - 2.5, 2, x + 2.5, 17, s.darkened(0.08))
		_merlons(x - 2.5, x + 2.5, 17, 0.9, s.darkened(0.08))
		_r(x - 0.5, 12, x + 0.5, 14, WIN)
	_r(23, 2, 31, 22, s.darkened(0.15))
	_merlons(23, 31, 22, 1.1, s.darkened(0.15))
	_r(26.3, 15, 27.7, 18, WIN)
	for i in 30:
		_l(-33 + i * 2.2, 3, -32 + i * 2.2, 3, s.darkened(0.25), 0.15)

## The Leskovac pljeskavica: a big round grilled patty in a split lepinja flatbread, with onion and kajmak.
static func _pljeskavica() -> void:
	_r(-2.6, 0, 2.6, 0.3, Color("8a6a4a"))
	_poly(_arc(0, 0.4, 2.8, 1.0, PI, TAU, 12), Color("d9a95f"))
	_poly([-2.8, 0.4, 2.8, 0.4, 2.7, 0.9, -2.7, 0.9], Color("d9a95f"))
	_poly([-2.9, 0.9, 2.9, 0.9, 2.7, 1.6, -2.7, 1.6], Color("6b3a22"))
	for x in [-2.0, -0.8, 0.5, 1.8]:
		_c(x, 1.7, 0.28, Color("f0eadf"))
	_r(-2.6, 1.6, 2.6, 1.8, Color("f6f0d8"))
	_poly([-2.8, 1.8, 2.8, 1.8] + _arc(0, 1.8, 2.8, 1.6, 0, PI, 12), Color("e0b46a"))
	for x in [-1.2, 0.0, 1.2]:
		_c(x, 2.8, 0.12, Color("f2e0b0"))

## Tešnjar in Valjevo: a row of old shop-houses with whitewashed walls, wooden fronts and folding shutters under
## wide tiled roofs.
static func _tesnjar() -> void:
	var cols := [WHITE, Color("efe1c4"), WHITE, Color("e8d6b6"), WHITE]
	for i in 5:
		var x0 := -20.0 + i * 8
		_r(x0, 0, x0 + 8, 8, cols[i])
		_r(x0 + 0.6, 0, x0 + 7.4, 3.6, Color("7a5032"))
		_r(x0 + 1.2, 0.5, x0 + 6.8, 3.2, Color("5a3a22"))
		_l(x0 + 4, 0.5, x0 + 4, 3.2, Color("7a5032"), 0.2)
		_r(x0 + 1.5, 5, x0 + 3, 6.8, WIN)
		_r(x0 + 5, 5, x0 + 6.5, 6.8, WIN)
		_r(x0 + 0.8, 4, x0 + 7.2, 4.4, Color("7a5032"))
		_poly([x0 - 0.8, 8, x0 + 8.8, 8, x0 + 4, 11.5], BRICK)

## The Šargan Eight near Mokra Gora: a narrow-gauge line climbing the hillside in a figure of eight, a little steam
## engine with two coaches crossing a stone viaduct.
static func _sargan_eight() -> void:
	_poly([-35, 0, -35, 14, -20, 30, 0, 40, 20, 32, 35, 18, 35, 0], Color("5a8a44"))
	var track := Color("6b5a44")
	var p := []
	for i in 49:
		var t := TAU * i / 48.0
		p.append_array([sin(t) * 22.0, 20.0 + sin(t * 2.0) * 7.0 + cos(t) * 6.0])
	for i in range(0, p.size() - 2, 2):
		_l(p[i], p[i + 1], p[i + 2], p[i + 3], track, 0.8)
	for x in [-28.0, 26.0, -8.0, 14.0]:
		_c(x, 30.0 - abs(x) * 0.4, 2.5, Color("3f6f34"))
	# the viaduct and the train
	_r(-14, 0, 14, 6, STONE_D)
	for x in [-9.0, -3.0, 3.0, 9.0]:
		_poly([x - 2, 0, x + 2, 0, x + 2, 2.5] + _arc(x, 2.5, 2, 2, 0, PI, 6), Color("4a7a3a"))
	_r(-14, 6, 14, 6.5, track)
	_r(-10, 6.5, -4, 9.5, Color("2f2f33"))
	_r(-6, 9.5, -5, 11.5, Color("2f2f33"))
	_r(-10, 9.5, -8, 11, Color("2f2f33"))
	for k in 2:
		var x0 := -3.0 + k * 6.5
		_r(x0, 6.8, x0 + 5.8, 9.8, Color("7a2a24"))
		_windows(x0 + 0.3, x0 + 5.5, 8.2, 9.3, 3, Color("f0e6c8"))
	_c(-5.5, 13, 1.2, Color(1, 1, 1, 0.7))

## The White Bridge (Beli most) in Vranje: a single white stone arch over the Vranjska river.
static func _beli_most() -> void:
	_r(-9, 0, 9, 1, WATER)
	_r(-9, 0, -6.5, 4.5, GRASS)
	_r(6.5, 0, 9, 4.5, GRASS)
	_poly([-7, 0, -7, 5.5, 7, 5.5, 7, 0, 5, 0] + _arc(0, 0, 5, 4.3, 0, PI, 12) + [-5, 0], WHITE)
	_r(-7.3, 5.5, 7.3, 6.0, Color("dcd8cc"))
	for i in 6:
		_l(-4.4 + i * 1.75, 4.8, -4.4 + i * 1.75, 5.4, Color("cfcabd"), 0.1)

## Šabac Fortress: a squat round tower and a stretch of wall on the bank of the Sava.
static func _sabac_tower() -> void:
	var s := Color("a8916f")
	_r(-12, 0, 12, 1.5, WATER)
	_r(-12, 1.5, 0, 8, s.darkened(0.1))
	_merlons(-12, 0, 8, 1, s.darkened(0.1))
	_r(-1, 1.5, 9, 13, s)
	_r(-1, 1.5, 1, 13, s.darkened(0.12))
	_r(7, 1.5, 9, 13, s.lightened(0.1))
	_merlons(-1, 9, 13, 1, s)
	_r(3.3, 6, 4.7, 8.5, WIN)
	_poly([-1.6, 13, 9.6, 13, 4, 16], BRICK)

## Felix Romuliana at Gamzigrad: the stone walls of Emperor Galerius's palace with polygonal towers, banded in brick
## and stone, and a gateway.
static func _romuliana() -> void:
	var s := Color("c7b394")
	_r(-30, 0, 30, 10, s)
	for i in 4:
		_r(-30, 2 + i * 2.2, 30, 2.5 + i * 2.2, BRICK)
	for x in [-26.0, -12.0, 12.0, 26.0]:
		_r(x - 3, 0, x + 3, 15, s.darkened(0.06))
		_r(x - 3, 4, x + 3, 4.5, BRICK)
		_r(x - 3, 9, x + 3, 9.5, BRICK)
		_poly([x - 3, 15, x + 3, 15, x + 2, 16, x - 2, 16], s.darkened(0.2))
	_poly([-3, 0, 3, 0, 3, 5] + _arc(0, 5, 3, 3, 0, PI, 8), DARK)
	for x in [-6.0, 6.0]:
		_r(x - 0.6, 0, x + 0.6, 11, WHITE)
		_r(x - 1, 11, x + 1, 11.8, WHITE)
	_r(-30, 0, 30, 0.4, Color("6a9a50"))

## A Pirot kilim hung on a wooden frame: a red field with rows of blue and white diamonds and a striped border.
static func _pirot_kilim() -> void:
	_l(-3.6, 0, -3.6, 6, Color("6b4a2a"), 0.18)
	_l(3.6, 0, 3.6, 6, Color("6b4a2a"), 0.18)
	_l(-3.9, 5.7, 3.9, 5.7, Color("6b4a2a"), 0.2)
	_r(-3.2, 0.8, 3.2, 5.5, Color("b4262c"))
	_r(-3.2, 0.8, 3.2, 1.2, Color("1f2a44"))
	_r(-3.2, 5.1, 3.2, 5.5, Color("1f2a44"))
	for row in 2:
		for k in 4:
			var x := -2.25 + k * 1.5
			var y := 2.15 + row * 1.95
			_poly([x - 0.6, y, x, y + 0.75, x + 0.6, y, x, y - 0.75], Color("2c4f8a") if (k + row) % 2 == 0 else WHITE)
			_c(x, y, 0.16, Color("e0b43a"))
	for k in 9:
		_l(-3.0 + k * 0.75, 0.8, -3.0 + k * 0.75, 0.4, Color("e8dcc0"), 0.05)

## The Iron Gate I dam at Kladovo: the long concrete wall across the Danube, the power-house blocks with gantry
## cranes and the spillway gates, wooded gorge sides behind.
static func _djerdap_dam() -> void:
	_poly([-60, 0, -60, 30, -50, 34, -40, 20, -30, 0], Color("4a6e3a"))
	_poly([30, 0, 42, 22, 52, 36, 60, 30, 60, 0], Color("4a6e3a"))
	_r(-60, 0, 60, 3, WATER)
	_r(-50, 3, 50, 16, CONCRETE)
	for i in 14:
		var x := -46.0 + i * 7
		_r(x, 3, x + 4.5, 12, CONCRETE.darkened(0.12))
		_r(x + 0.5, 3, x + 4, 5, WATER_L)
	_r(-50, 16, 50, 17.5, CONCRETE.darkened(0.25))
	for x in [-30.0, 20.0]:
		_l(x, 17.5, x, 25, Color("d07a2a"), 0.6)
		_l(x + 8, 17.5, x + 8, 25, Color("d07a2a"), 0.6)
		_l(x - 1, 25, x + 9, 25, Color("d07a2a"), 0.8)
	_r(-6, 17.5, 6, 21, WHITE)
	_windows(-5, 5, 18.5, 20, 4, WIN)
