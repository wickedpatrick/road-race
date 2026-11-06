class_name LandmarksSbA
extends RefCounted
## Southern Balkans landmarks (Montenegro, Kosovo, Tirana and Durrës), drawn with LandmarkPainter's helpers
## (metres from the base point, y up).

const WHITE := Color("f2efe6")
const STONE := Color("cdbf9f")
const STONE_D := Color("a8987a")
const RED_ROOF := Color("b5432e")
const WATER := Color("4f8fc0")
const WATER_L := Color("9cc8e6")
const ROCK := Color("9a958a")
const GRASS := Color("5d8f42")
const TREE := Color("3f6f34")
const OLIVE := Color("7d8f4e")
const WIN := Color("3a4048")
const GOLD := Color("e0b43a")
const DARK := Color("2e3238")
const STEEL := Color("c9ced4")
const BRONZE := Color("5b4a32")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"millennium_bridge_pg": _millennium_bridge()
		"kotor_walls": _kotor_walls()
		"sveti_stefan": _sveti_stefan()
		"old_olive": _old_olive()
		"kosovo_library": _kosovo_library()
		"sinan_pasha": _sinan_pasha()
		"rugova_canyon": _rugova_canyon()
		"skanderbeg_square": _skanderbeg_square()
		"durres_amphitheatre": _durres_amphitheatre()
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

## A slim minaret: the shaft, a balcony, a pencil-point cap.
static func _minaret(x: float, y: float, h: float, w: float, col: Color, cap: Color) -> void:
	_r(x - w * 0.5, y, x + w * 0.5, y + h, col)
	_r(x - w * 0.8, y + h * 0.72, x + w * 0.8, y + h * 0.75, col.darkened(0.15))
	_poly([x - w * 0.55, y + h, x + w * 0.55, y + h, x, y + h + w * 3.2], cap)
	_l(x, y + h + w * 3.2, x, y + h + w * 3.8, GOLD, 0.15)

## A dome on a drum: half an ellipse.
static func _dome(x: float, y: float, rx: float, ry: float, col: Color) -> void:
	_poly(_arc(x, y, rx, ry, 0, PI, 12), col)

## Podgorica's Millennium Bridge: a white deck over the Morača hung from one leaning pylon by a fan of cables, with
## the back-stays running down to the bank.
static func _millennium_bridge() -> void:
	_r(-40, 0, 40, 3, WATER)
	_r(-40, 2.2, 40, 2.6, WATER_L)
	_poly([-40, 0, -30, 0, -26, 5, -40, 5], GRASS)
	_poly([28, 0, 40, 0, 40, 5, 24, 5], GRASS)
	# the deck
	_r(-38, 6, 38, 7.2, WHITE)
	_r(-38, 5.6, 38, 6, STEEL.darkened(0.3))
	# the pylon, leaning back
	var top := Vector2(-14, 46)
	_poly([-20, 5, -16, 5, top.x + 0.9, top.y, top.x - 0.9, top.y], WHITE)
	for i in 7:
		var x := -10.0 + i * 7.5
		_l(top.x, top.y - 2 - i * 1.2, x, 7.2, STEEL, 0.25)
	for i in 3:
		_l(top.x - 0.5, top.y - 4 - i * 2, -36 + i * 4, 7.2, STEEL, 0.3)
	if _detail(0.8):
		for x in [-30.0, -20.0, -10.0, 0.0, 10.0, 20.0, 30.0]:
			_r(x - 0.1, 7.2, x + 0.1, 8.2, DARK)
		_r(-38, 8.2, 38, 8.4, DARK)

## The old town of Kotor: the town walls zigzagging up the grey mountain to the fortress of St John, with the
## twin-towered Cathedral of St Tryphon and red roofs below, water in front.
static func _kotor_walls() -> void:
	_poly([-40, 0, -30, 30, -14, 52, 0, 60, 14, 50, 30, 34, 40, 0], ROCK)
	_poly([-30, 30, -14, 52, 0, 60, -6, 44], ROCK.lightened(0.08))
	_poly([-40, 0, -36, 14, -20, 22, 10, 18, 40, 0], Color("6f8a52"))
	# the walls zigzagging up
	var zig := [[-30, 6], [-8, 14], [-24, 24], [-4, 32], [-16, 40], [-2, 48], [0, 56]]
	for i in zig.size() - 1:
		_l(zig[i][0], zig[i][1], zig[i + 1][0], zig[i + 1][1], STONE, 0.9)
	_r(-3, 55, 3, 59, STONE)
	_poly([-3, 59, 3, 59, 0, 61], STONE_D)
	# the town
	_r(-40, 0, 40, 2, WATER)
	_r(-36, 2, 34, 4, STONE_D)
	for i in 7:
		var x := -34.0 + i * 9.5
		_r(x, 4, x + 7, 11, STONE)
		_poly([x - 0.5, 11, x + 7.5, 11, x + 3.5, 14], RED_ROOF)
		_windows(x + 1, x + 6, 6, 9, 2, WIN)
	# the cathedral of St Tryphon
	_r(-6, 4, 6, 16, Color("e3d6b8"))
	_arch(0, 6, 4, 7, WIN)
	for x in [-9.0, 9.0]:
		_r(x - 3, 4, x + 3, 24, Color("e3d6b8"))
		_arch(x, 17, 2, 4, WIN)
		_poly([x - 3.4, 24, x + 3.4, 24, x, 28], STONE_D)
	_c(0, 14, 1.2, WIN)

## Sveti Stefan: the islet village of stone houses with red roofs, joined to the beach by a narrow sandy causeway.
static func _sveti_stefan() -> void:
	_r(-46, 0, 46, 3, WATER)
	_r(-46, 2.4, 46, 3, WATER_L)
	_poly([-46, 0, -30, 0, -26, 3.4, -46, 3.4], Color("e7d39a"))
	_r(-28, 2.6, -14, 3.6, Color("e7d39a"))
	# the islet
	_poly([-16, 2, 30, 2, 26, 8, 14, 14, -6, 12, -14, 6], ROCK)
	var rows := [[-12.0, 22.0, 7.0], [-6.0, 18.0, 12.0], [0.0, 12.0, 17.0], [4.0, 8.0, 22.0]]
	for row in rows:
		var x: float = row[0]
		while x < row[1]:
			_r(x, row[2] - 4, x + 4.2, row[2] + 1.5, STONE.lightened(0.05))
			_poly([x - 0.3, row[2] + 1.5, x + 4.5, row[2] + 1.5, x + 2.1, row[2] + 3.4], RED_ROOF)
			if _detail(0.8):
				_r(x + 1.6, row[2] - 2.5, x + 2.6, row[2] - 0.5, WIN)
			x += 5.0
	# the church at the top
	_r(5, 22, 8, 29, WHITE)
	_poly([4.6, 29, 8.4, 29, 6.5, 31.5], RED_ROOF)
	for x in [-10.0, 20.0, 25.0]:
		_poly([x - 1, 5, x + 1, 5, x, 14], TREE)

## The Old Olive of Mirovica in Bar: a gnarled, hollow trunk splitting in two with a wide silver-green crown,
## inside a low stone wall.
static func _old_olive() -> void:
	_r(-24, 0, 24, 1.2, GRASS)
	_r(-22, 0, 22, 2.4, STONE)
	for x in range(-21, 22, 4):
		_r(x, 2.0, x + 0.3, 2.4, STONE_D)
	var bark := Color("5e5040")
	_poly([-5, 1, 5, 1, 4, 6, 7, 11, 3, 10, 1, 7, -1, 7, -3, 10, -8, 12, -4, 6], bark)
	_poly([-1.5, 1, 1.5, 1, 0.8, 5, -0.8, 5], DARK)
	_l(-3, 10, -10, 15, bark, 1.2)
	_l(3, 10, 9, 16, bark, 1.2)
	_l(7, 11, 13, 13, bark, 0.8)
	for p in [[-12, 16, 6], [-4, 19, 6.5], [5, 19, 6.5], [12, 16, 6], [0, 14, 7], [-15, 12, 4], [15, 12, 4]]:
		_c(p[0], p[1], p[2], OLIVE)
	for p in [[-8, 18, 3], [3, 21, 3.5], [11, 15, 3]]:
		_c(p[0], p[1], p[2], OLIVE.lightened(0.18))
	if _detail(0.8):
		for p in [[-6, 15], [2, 17], [8, 13], [-11, 13], [12, 18]]:
			_c(p[0], p[1], 0.4, Color("3e3a2a"))

## The National Library in Pristina: a low cube block crowned by many white domes of different sizes, the whole
## building wrapped in a dark metal lattice.
static func _kosovo_library() -> void:
	var w := Color("e9e6df")
	_r(-30, 0, 30, 14, w)
	var domes := [[-22, 5.5, 4], [-10, 7, 5.5], [4, 9, 7], [18, 6, 5], [27, 3.5, 3]]
	for d in domes:
		_dome(d[0], 14, d[1], d[2], w)
	_dome(4, 14 + 7.0, 2.2, 2.6, w)
	_dome(-10, 14 + 5.5, 1.6, 1.8, w)
	# the lattice
	var net := Color("4a4f57")
	var y := 1.0
	while y < 14:
		_l(-30, y, 30, y, net, 0.25)
		y += 2.2
	var x := -29.0
	while x < 30:
		_l(x, 0, x, 14, net, 0.25)
		x += 2.6
	if _detail(0.8):
		for d in domes:
			for k in 3:
				var a: float = PI * (0.25 + k * 0.25)
				_l(d[0], 14, d[0] + cos(a) * d[1], 14 + sin(a) * d[2], net, 0.15)
	_r(-4, 0, 4, 5, WIN)

## Prizren: the Sinan Pasha Mosque with its big lead dome and tall minaret, above the humped Stone Bridge over the
## Bistrica, the fortress walls on the hill behind.
static func _sinan_pasha() -> void:
	_poly([-36, 14, -20, 34, 0, 38, 20, 30, 36, 14], Color("7f8f5a"))
	_r(-14, 33, 6, 37, STONE_D)
	for x in [-14.0, -6.0, 2.0]:
		_r(x, 37, x + 2, 39, STONE_D)
	# the mosque
	var s := Color("d9cbb0")
	_r(-12, 6, 10, 18, s)
	_dome(-1, 18, 8, 7, Color("7d8794"))
	_l(-1, 25, -1, 27, GOLD, 0.25)
	_c(-1, 27.3, 0.4, GOLD)
	_dome(-9, 18, 2.5, 2.2, Color("7d8794"))
	_dome(7, 18, 2.5, 2.2, Color("7d8794"))
	for x in [-8.0, -3.0, 2.0, 7.0]:
		_arch(x, 9, 2, 5, WIN)
	_minaret(14, 6, 26, 1.6, s, Color("7d8794"))
	# the river and the stone bridge
	_r(-36, 0, 36, 3, WATER)
	_r(-36, 2.4, 36, 3, WATER_L)
	_poly([-30, 3, 2, 3, -6, 5.5, -14, 8.5, -22, 5.5], STONE)
	_poly(_arc(-14, 3, 6.5, 3.2, 0, PI, 10), WATER.darkened(0.25))
	_r(-36, 3, -28, 5, GRASS)
	_r(-2, 3, 36, 6, GRASS)

## The Rugova Gorge outside Peja: steep grey walls on both sides, the white-water Lumbardhi below, and a zipline
## strung across the top with a rider halfway along.
static func _rugova_canyon() -> void:
	_poly([-44, 0, -10, 0, -14, 20, -8, 34, -18, 52, -44, 56], ROCK)
	_poly([44, 0, 10, 0, 12, 18, 6, 30, 14, 50, 44, 54], ROCK.darkened(0.1))
	_poly([-44, 40, -30, 44, -20, 52, -44, 56], TREE)
	_poly([44, 40, 30, 46, 16, 50, 44, 54], TREE)
	_poly([-10, 0, 10, 0, 8, 4, -8, 4], WATER)
	for x in [-6.0, -1.0, 4.0]:
		_l(x, 1, x + 2, 2.5, WHITE, 0.4)
	for p in [[-14, 20], [-8, 34], [12, 18], [6, 30]]:
		_l(p[0], p[1], p[0] * 0.7, p[1] - 5, ROCK.darkened(0.2), 0.4)
	# the zipline
	_l(-18, 52, 14, 46, DARK, 0.2)
	_r(-19, 51, -17, 54, Color("7a5a3a"))
	_r(13, 45, 15, 48, Color("7a5a3a"))
	var x := -2.0
	var y := 52.0 - (x + 18) * 6.0 / 32.0
	_l(x, y, x, y - 2.2, DARK, 0.15)
	_c(x, y - 2.8, 0.6, Color("e05a2a"))
	_r(x - 0.4, y - 4.6, x + 0.4, y - 3.2, Color("e05a2a"))

## Skanderbeg Square in Tirana: the bronze horseman on his plinth in front, behind him the small Et'hem Bey Mosque
## with its dome and minaret, and the slender Clock Tower.
static func _skanderbeg_square() -> void:
	_r(-34, 0, 34, 1.2, Color("c7b9a3"))
	# the clock tower
	var t := Color("d8c4a0")
	_r(16, 1, 22, 30, t)
	_r(15.4, 26, 22.6, 27, t.darkened(0.15))
	_r(16.5, 27, 21.5, 33, t)
	_c(19, 30, 1.8, WHITE)
	_l(19, 30, 19, 31.3, DARK, 0.2)
	_l(19, 30, 20, 30, DARK, 0.2)
	_poly([16, 33, 22, 33, 19, 38], Color("7a4e3a"))
	# the Et'hem Bey Mosque
	var m := Color("e6d8bb")
	_r(-6, 1, 12, 12, m)
	_r(-8, 1, 12, 7, m.darkened(0.08))
	for x in [-5.0, -1.0, 3.0, 7.0, 11.0]:
		_r(x - 0.3, 1, x + 0.3, 7, m.darkened(0.2))
	_dome(3, 12, 5, 4.5, Color("8a6b52"))
	_minaret(-4, 12, 14, 1.4, m, Color("6f7682"))
	# the horseman
	_r(-26, 1, -10, 9, Color("8f8a80"))
	_r(-27, 8.6, -9, 9.4, Color("7a756c"))
	_poly([-24, 9, -22, 9, -21, 13, -14, 13, -13, 9, -11, 9, -12, 14, -10, 18, -11, 19, -13, 16, -22, 16, -24, 14], BRONZE)
	_poly([-11, 16, -9, 18, -8, 21, -10, 21, -11, 18], BRONZE)
	_poly([-19, 16, -16, 16, -16, 22, -19, 22], BRONZE)
	_c(-17.5, 23.3, 1.3, BRONZE)
	_poly([-18.5, 24.2, -16.5, 24.2, -17.5, 27], BRONZE)
	_l(-16, 21, -12, 24, BRONZE, 0.4)

## The Roman amphitheatre of Durrës: tiers of brick arches curving round the sunken arena, with old-town houses
## standing on its rim.
static func _durres_amphitheatre() -> void:
	var brick := Color("b07a55")
	var brick_d := brick.darkened(0.25)
	_poly([-36, 0, 36, 0, 30, 18, -30, 18], brick)
	for row in 3:
		var y0: float = 1.5 + row * 5.5
		var half: float = 34.0 - row * 2.0
		var n := 12 - row
		var step := half * 2.0 / n
		for k in n:
			var x: float = -half + step * (k + 0.5)
			_arch(x, y0, step * 0.55, 4.2, brick_d)
	# the arena floor in front
	_poly([-20, 0, 20, 0, 14, 4, -14, 4], Color("c9b48c"))
	_r(-30, 17.5, 30, 18.5, STONE_D)
	# houses on the rim
	for x in [-24.0, 6.0, 18.0]:
		_r(x, 18, x + 8, 25, WHITE)
		_poly([x - 0.5, 25, x + 8.5, 25, x + 4, 28], RED_ROOF)
		_windows(x + 1, x + 7, 20, 23, 2, WIN)
	_poly([-8, 18, -6, 18, -7, 26], TREE)
