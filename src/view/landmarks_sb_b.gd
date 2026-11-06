class_name LandmarksSbB
extends RefCounted
## Southern Balkans landmarks (the rest of Albania and North Macedonia), drawn with LandmarkPainter's helpers
## (metres from the base point, y up).

const WHITE := Color("f2efe6")
const STONE := Color("cdbf9f")
const STONE_D := Color("a8987a")
const SLATE := Color("7f8288")
const RED_ROOF := Color("b5432e")
const BRICK := Color("b0664a")
const WATER := Color("4f8fc0")
const WATER_L := Color("9cc8e6")
const ROCK := Color("9a958a")
const GRASS := Color("5d8f42")
const TREE := Color("3f6f34")
const WIN := Color("3a4048")
const GOLD := Color("e0b43a")
const DARK := Color("2e3238")
const WOOD := Color("8a6440")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"rozafa": _rozafa()
		"zvernec": _zvernec()
		"elbasan_castle": _elbasan_castle()
		"korce_cathedral": _korce_cathedral()
		"gjirokaster_houses": _gjirokaster_houses()
		"skopje_stone_bridge": _skopje_stone_bridge()
		"painted_mosque": _painted_mosque()
		"kaneo": _kaneo()
		"bitola_clock": _bitola_clock()
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

## An arched window or door: a rectangle with a round top.
static func _arch(x: float, y: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.5, y, x + w * 0.5, y, x + w * 0.5, y + h - w * 0.5] + _arc(x, y + h - w * 0.5, w * 0.5, w * 0.5, 0, PI, 6), col)

## A dome: half an ellipse.
static func _dome(x: float, y: float, rx: float, ry: float, col: Color) -> void:
	_poly(_arc(x, y, rx, ry, 0, PI, 12), col)

## Battlements along a wall top.
static func _merlons(x0: float, x1: float, y: float, w: float, col: Color) -> void:
	var x := x0
	while x + w <= x1 + 0.01:
		_r(x, y, x + w, y + w, col)
		x += w * 2.0

## Rozafa Castle above Shkodër: long grey walls with square towers along a rocky hilltop.
static func _rozafa() -> void:
	_poly([-46, 0, -34, 14, -18, 22, 18, 24, 36, 16, 46, 0], ROCK)
	_poly([-46, 0, -40, 6, 40, 6, 46, 0], GRASS)
	_r(-30, 18, 32, 28, STONE)
	_merlons(-30, 32, 28, 1.4, STONE)
	for x in [-30.0, -10.0, 12.0, 30.0]:
		_r(x - 3, 18, x + 3, 33, STONE.darkened(0.06))
		_merlons(x - 3, x + 3, 33, 1.2, STONE.darkened(0.06))
		_r(x - 0.5, 26, x + 0.5, 29, WIN)
	_arch(0, 18, 4, 7, WIN)
	if _detail(0.8):
		for x in [-20.0, -4.0, 20.0]:
			_r(x, 23, x + 0.6, 24.6, WIN)

## Zvërnec Monastery near Vlorë: a little Byzantine church with a tiled dome on a wooded islet, a long wooden
## footbridge across the lagoon leading to it.
static func _zvernec() -> void:
	_r(-46, 0, 46, 2.5, WATER)
	_r(-46, 2, 46, 2.5, WATER_L)
	_poly([6, 2, 44, 2, 40, 6, 12, 7], Color("8a8a5a"))
	for x in [10.0, 14.0, 34.0, 38.0, 41.0]:
		_poly([x - 1.4, 5, x + 1.4, 5, x, 16], TREE)
	# the church
	var s := Color("c9a982")
	_r(18, 6, 32, 14, s)
	_poly([17.5, 14, 32.5, 14, 30, 16.5, 20, 16.5], RED_ROOF)
	_r(23, 16.5, 27, 19.5, s)
	_dome(25, 19.5, 2.4, 2.4, RED_ROOF)
	_l(25, 21.9, 25, 23.6, DARK, 0.2)
	_l(24.3, 23, 25.7, 23, DARK, 0.2)
	_arch(25, 6, 2, 4, WIN)
	for k in 6:
		var x := 19.5 + k * 2.2
		if k != 2 and k != 3:
			_r(x, 10, x + 0.8, 12, BRICK)
	# the footbridge
	_r(-46, 3.2, 8, 3.8, WOOD)
	var x := -44.0
	while x < 8:
		_r(x, 0, x + 0.4, 3.2, WOOD.darkened(0.2))
		x += 4.0
	_l(-46, 4.8, 8, 4.8, WOOD.darkened(0.1), 0.2)

## The castle of Elbasan: a thick stone wall with the arched King's Gate and a slim clock tower behind it.
static func _elbasan_castle() -> void:
	var s := Color("c4b496")
	_r(-36, 0, 36, 14, s)
	_merlons(-36, 36, 14, 1.4, s)
	for x in [-36.0, 30.0]:
		_r(x, 0, x + 6, 18, s.darkened(0.06))
		_merlons(x, x + 6, 18, 1.2, s.darkened(0.06))
	_r(-6, 0, 6, 18, s.lightened(0.04))
	_merlons(-6, 6, 18, 1.2, s.lightened(0.04))
	_arch(0, 0, 6, 10, WIN)
	_l(-3.4, 7.2, 3.4, 7.2, s.darkened(0.15), 0.6)
	# the clock tower
	_r(14, 14, 19, 34, Color("d8c8a6"))
	_c(16.5, 30, 1.6, WHITE)
	_l(16.5, 30, 16.5, 31.2, DARK, 0.2)
	_l(16.5, 30, 17.4, 30, DARK, 0.2)
	_poly([13.4, 34, 19.6, 34, 16.5, 39], RED_ROOF)
	if _detail(0.8):
		for i in 12:
			_r(-34 + i * 6, 4, -33 + i * 6, 4.4, s.darkened(0.2))

## The Resurrection Cathedral in Korçë: a long nave with a red-tiled roof, a central dome and a tall bell tower with
## its own small dome.
static func _korce_cathedral() -> void:
	var w := Color("eae2d2")
	_r(-24, 0, 20, 16, w)
	_poly([-25, 16, 21, 16, 18, 20, -22, 20], RED_ROOF)
	for x in [-18.0, -10.0, 6.0, 14.0]:
		_arch(x, 4, 3, 8, WIN)
	_arch(-2, 0, 5, 10, WIN)
	_r(-8, 20, 4, 26, w)
	_dome(-2, 26, 7, 7, Color("6d7f8a"))
	_l(-2, 33, -2, 36, GOLD, 0.3)
	_l(-3, 35, -1, 35, GOLD, 0.3)
	# the bell tower
	_r(22, 0, 32, 34, w)
	_windows(23.5, 30.5, 8, 14, 2, WIN)
	_arch(27, 24, 4, 7, WIN)
	_r(21.4, 33, 32.6, 34.4, w.darkened(0.12))
	_r(24, 34.4, 30, 38, w)
	_dome(27, 38, 3.5, 3.6, Color("6d7f8a"))
	_l(27, 41.6, 27, 44.6, GOLD, 0.3)
	_l(26, 43.6, 28, 43.6, GOLD, 0.3)

## Gjirokastër: tall white tower-houses with grey stone-slab roofs climbing a slope below the castle's long walls.
static func _gjirokaster_houses() -> void:
	_poly([-46, 0, 46, 0, 46, 22, 20, 32, -30, 30, -46, 20], Color("8f8a6e"))
	# the castle on top
	var s := Color("b8ad96")
	_r(-28, 30, 22, 38, s)
	_merlons(-28, 22, 38, 1.4, s)
	_r(-6, 30, 0, 44, s.darkened(0.06))
	_merlons(-6, 0, 44, 1.2, s.darkened(0.06))
	# the houses
	var houses := [[-40, 0, 12, 9], [-26, 4, 14, 10], [-12, 0, 13, 9], [2, 6, 12, 10], [16, 1, 14, 10], [30, 5, 12, 9]]
	for h in houses:
		var x0: float = h[0]
		var y0: float = h[1]
		var hh: float = h[2]
		var w: float = h[3]
		_r(x0, y0, x0 + w, y0 + hh * 0.45, STONE.darkened(0.1))
		_r(x0, y0 + hh * 0.45, x0 + w, y0 + hh, WHITE)
		_poly([x0 - 1, y0 + hh, x0 + w + 1, y0 + hh, x0 + w * 0.5, y0 + hh + 4.5], SLATE)
		_windows(x0 + 1, x0 + w - 1, y0 + hh * 0.6, y0 + hh * 0.85, 3, WIN)
		_r(x0 + w * 0.5 - 0.6, y0 + hh * 0.15, x0 + w * 0.5 + 0.6, y0 + hh * 0.3, WIN)
		if _detail(0.8):
			for k in 3:
				var yy: float = y0 + hh + 1.2 + k * 1.1
				var half: float = (w * 0.5 + 1) * (1.0 - (yy - y0 - hh) / 4.5)
				_l(x0 + w * 0.5 - half, yy, x0 + w * 0.5 + half, yy, SLATE.darkened(0.2), 0.15)

## The Stone Bridge in Skopje: a long, low stone bridge of round arches over the Vardar.
static func _skopje_stone_bridge() -> void:
	_r(-48, 0, 48, 4, WATER)
	_r(-48, 3.4, 48, 4, WATER_L)
	var s := Color("cbbf9f")
	_r(-48, 4, 48, 11, s)
	_r(-48, 11, 48, 12.2, s.darkened(0.12))
	for k in 8:
		var x := -38.5 + k * 11.0
		_poly(_arc(x, 4, 4.2, 4.6, 0, PI, 10), WATER.darkened(0.3))
		_r(x + 4.6, 4, x + 6.4, 8, s.darkened(0.06))
		_poly([x + 4.6, 4, x + 6.4, 4, x + 5.5, 1.5], s.darkened(0.1))
	# the little watch post in the middle
	_r(-2, 12.2, 2, 16, s)
	_poly([-2.4, 16, 2.4, 16, 0, 18], RED_ROOF)
	if _detail(0.8):
		var x := -47.0
		while x < 48:
			_l(x, 4, x, 11, s.darkened(0.08), 0.12)
			x += 3.0

## The Painted Mosque in Tetovo: a square prayer hall under a hipped roof, its walls covered in panels of bright
## painted flowers and patterns, a slim minaret beside it.
static func _painted_mosque() -> void:
	var base := Color("efe6d0")
	_r(-18, 0, 14, 16, base)
	_poly([-20, 16, 16, 16, 8, 22, -12, 22], Color("8a5a3a"))
	_r(-20, 0, 16, 1.5, STONE_D)
	# the painted panels
	var cols := [Color("2f6fa8"), Color("c84a3a"), Color("3f8a52"), Color("d8a63a")]
	for i in 8:
		var x := -17.0 + i * 3.9
		_r(x, 2.5, x + 3.3, 14.5, cols[i % 4])
		_c(x + 1.65, 10.5, 1.1, base)
		_c(x + 1.65, 6.0, 0.8, cols[(i + 2) % 4].lightened(0.3))
		if _detail(0.8):
			_poly([x + 1.65, 12.3, x + 2.6, 13.6, x + 1.65, 14.2, x + 0.7, 13.6], WHITE)
	_arch(-2, 2.5, 3, 7, WIN)
	# the minaret
	var mx := 20.0
	_r(mx - 1, 0, mx + 1, 26, base)
	for i in 4:
		_r(mx - 1, 3 + i * 5.5, mx + 1, 4.2 + i * 5.5, cols[i])
	_r(mx - 1.6, 20, mx + 1.6, 21, base.darkened(0.15))
	_poly([mx - 1.1, 26, mx + 1.1, 26, mx, 31], Color("6f7682"))

## The church of St John at Kaneo above Lake Ohrid: a small cross-shaped church of banded brick and stone with a
## tiled drum dome, on a cliff over the water.
static func _kaneo() -> void:
	_r(-40, 0, 40, 4, WATER)
	_r(-40, 3.4, 40, 4, WATER_L)
	_poly([-30, 4, 26, 4, 22, 12, 14, 16, -20, 16, -26, 10], ROCK)
	_poly([-20, 16, 14, 16, 12, 17.5, -18, 17.5], GRASS)
	# the church
	var body := Color("c98a5a")
	_r(-12, 17.5, 8, 26, body)
	for y in [19.5, 22.0, 24.5]:
		_r(-12, y, 8, y + 0.6, STONE)
	_poly([-13, 26, 9, 26, 6, 28.5, -10, 28.5], RED_ROOF)
	_r(-6, 28.5, 2, 33, body)
	_r(-6, 30.4, 2, 31, STONE)
	for x in [-4.5, -2.0, 0.5]:
		_arch(x, 31, 1, 1.6, WIN)
	_poly(_arc(-2, 33, 4.8, 3.0, 0, PI, 10), RED_ROOF)
	_l(-2, 36, -2, 38, DARK, 0.2)
	_l(-2.8, 37.3, -1.2, 37.3, DARK, 0.2)
	_r(8, 17.5, 12, 23, body)
	_poly(_arc(8, 23, 4, 3, 0, PI * 0.5, 6) + [8, 23], RED_ROOF)
	_arch(-2, 17.5, 2, 4, WIN)
	for x in [-24.0, 18.0, 22.0]:
		_poly([x - 1.2, 10, x + 1.2, 10, x, 18], TREE)

## The Clock Tower of Bitola: a tall square stone tower with a balcony, a clock on top and a slim spire.
static func _bitola_clock() -> void:
	var s := Color("c8b48e")
	_r(-12, 0, 12, 1, STONE_D)
	_r(-5, 1, 5, 26, s)
	_r(-5, 1, -4, 26, s.darkened(0.15))
	_arch(0, 1, 3, 5, WIN)
	_windows(-3, 3, 12, 15, 2, WIN)
	_r(-6, 26, 6, 27.4, s.darkened(0.1))
	for x in range(-6, 7, 2):
		_r(x - 0.2, 27.4, x + 0.2, 29, s.darkened(0.2))
	_r(-6, 29, 6, 29.4, s.darkened(0.2))
	_r(-4, 27.4, 4, 37, s.lightened(0.04))
	_c(0, 33, 2.6, WHITE)
	_l(0, 33, 0, 34.8, DARK, 0.25)
	_l(0, 33, 1.3, 33, DARK, 0.25)
	_poly([-4.4, 37, 4.4, 37, 0, 46], Color("5f6a6f"))
	_l(0, 46, 0, 48, GOLD, 0.25)
	for x in [-10.0, 9.0]:
		_c(x, 6, 3, TREE)
		_r(x - 0.3, 1, x + 0.3, 4, WOOD)
