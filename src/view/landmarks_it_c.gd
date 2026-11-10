class_name LandmarksItC
extends RefCounted
## Italian landmarks (Padova to Siena), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const MARBLE := Color("f1ede4")
const MARBLE_D := Color("d9d3c6")
const PINK := Color("e8c2b4")
const PINK_D := Color("c99d8d")
const STONE := Color("c9bfa7")
const STONE_D := Color("a69c84")
const BRICK := Color("b0603f")
const BRICK_D := Color("8a4a30")
const LEAD := Color("8a9298")
const LEAD_D := Color("6c747a")
const WIN := Color("3a3a40")
const DARK := Color("2b2b30")
const GRASS := Color("6b8f45")
const HILL := Color("7c8a4c")
const ROCK := Color("b8a888")
const ROCK_D := Color("97876a")
const ROOF := Color("a5583b")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"it_padova_santo": _padova_santo()
		"it_parma_battistero": _parma_battistero()
		"it_brescia_duomo": _brescia_duomo()
		"it_rimini_arco_augusto": _rimini_arco_augusto()
		"it_trento_buonconsiglio": _trento_buonconsiglio()
		"it_siracusa_teatro_greco": _siracusa_teatro_greco()
		"it_siena_torre_mangia": _siena_torre_mangia()
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

static func _arched(x: float, y0: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.5, y0, x + w * 0.5, y0, x + w * 0.5, y0 + h - w * 0.5] + _arc(x, y0 + h - w * 0.5, w * 0.5, w * 0.5, 0, PI, 6), col)

## A dome on a drum with a lantern on top.
static func _dome(x: float, y: float, r: float, col: Color, col_d: Color) -> void:
	_r(x - r * 0.8, y, x + r * 0.8, y + r * 0.35, col_d)
	_poly(_arc(x, y + r * 0.35, r * 0.8, r * 0.95, 0, PI, 10), col)
	_r(x - r * 0.12, y + r * 1.3, x + r * 0.12, y + r * 1.6, col_d)
	_poly([x - r * 0.18, y + r * 1.6, x + r * 0.18, y + r * 1.6, x, y + r * 1.85], col_d)

## The Basilica of Saint Anthony in Padua: the brick front with its arcaded loggia, the row of lead domes behind,
## the conical central dome and two slender bell towers like minarets.
static func _padova_santo() -> void:
	_r(-45, 0, 45, 0.8, GRASS)
	_r(-38, 0.8, 38, 26, BRICK)
	_r(-38.5, 26, 38.5, 27, BRICK_D)
	# the front: gable with the gallery of small arches and three portals
	_poly([-16, 0.8, 16, 0.8, 16, 30, 0, 38, -16, 30], BRICK)
	_poly([-17, 29.5, 0, 38.6, 17, 29.5, 17, 30.6, 0, 39.6, -17, 30.6], BRICK_D)
	for k in 9:
		_arched(-12.0 + k * 3.0, 20, 1.8, 4.5, WIN)
	for x in [-9.0, 0.0, 9.0]:
		_arched(x, 0.8, 4.0, 9.0, DARK)
	_c(0, 31, 2.2, MARBLE_D)
	# the domes behind, the cone of the central one
	for x in [-30.0, -20.0, 20.0, 30.0]:
		_dome(x, 27, 6.0, LEAD, LEAD_D)
	_dome(0, 40, 7.0, LEAD, LEAD_D)
	_poly([-4, 47, 4, 47, 0, 58], LEAD_D)
	# the two minaret-like bell towers
	for s in [-1, 1]:
		var x: float = s * 12.0
		_r(x - 1.4, 27, x + 1.4, 56, BRICK)
		_r(x - 1.8, 46, x + 1.8, 47, BRICK_D)
		_r(x - 1.0, 56, x + 1.0, 61, MARBLE)
		_poly([x - 1.3, 61, x + 1.3, 61, x, 68], LEAD_D)

## The Baptistery of Parma: the octagonal tower of pink Verona marble, open galleries of columns on five storeys,
## little pinnacles at the corners, the blind arches below.
static func _parma_battistero() -> void:
	_r(-12, 0, 12, 0.6, Color("9a9285"))
	_r(-9, 0.6, 9, 30, PINK)
	# the corner buttresses of the octagon
	for x in [-9.0, -3.2, 3.2, 9.0]:
		_r(x - 0.5, 0.6, x + 0.5, 30, PINK_D)
	# three portals and the blind arches over them
	for x in [-6.1, 0.0, 6.1]:
		_arched(x, 0.6, 3.6, 7.0, DARK)
		_arched(x, 9.0, 4.2, 4.0, PINK_D)
	# four storeys of open galleries
	for k in 4:
		var y := 14.0 + k * 4.0
		_r(-9, y, 9, y + 0.4, PINK_D)
		_r(-8.6, y + 0.4, 8.6, y + 3.4, WIN)
		for j in 13:
			var x := -8.4 + j * 1.4
			_r(x - 0.2, y + 0.4, x + 0.2, y + 3.4, PINK)
	_r(-9.5, 30, 9.5, 31, PINK_D)
	# the band of blind arches under the roof and the corner pinnacles
	for j in 6:
		_arched(-7.5 + j * 3.0, 31, 2.2, 2.2, PINK_D)
	_r(-9, 31, 9, 31.3, PINK)
	for x in [-9.0, -3.2, 3.2, 9.0]:
		_r(x - 0.6, 30, x + 0.6, 34, PINK)
		_poly([x - 0.7, 34, x + 0.7, 34, x, 37], PINK_D)

## Brescia's two cathedrals: the white marble Baroque New Cathedral with its tall dome and the low round Romanesque
## Rotonda (the Old Cathedral) beside it.
static func _brescia_duomo() -> void:
	_r(-40, 0, 40, 0.6, Color("9a9285"))
	# the New Cathedral: the front of two orders with the pediment
	_r(-16, 0.6, 16, 34, MARBLE)
	_r(-16.5, 17, 16.5, 18.2, MARBLE_D)
	_poly([-17, 34, 17, 34, 0, 40], MARBLE_D)
	_poly([-14, 34.6, 14, 34.6, 0, 39], MARBLE)
	for x in [-14.0, -8.0, 8.0, 14.0]:
		_r(x - 0.7, 0.6, x + 0.7, 17, MARBLE_D)
		_r(x - 0.6, 18.2, x + 0.6, 34, MARBLE_D)
	_arched(0, 0.6, 5, 11, DARK)
	_arched(0, 21, 4, 9, WIN)
	for x in [-11.0, 11.0]:
		_arched(x, 4, 2.5, 7, WIN)
	# the dome on its tall drum behind the front
	_r(-12, 40, 12, 52, MARBLE_D)
	_windows(-11, 11, 43, 49, 6, WIN)
	_poly(_arc(0, 52, 12, 20, 0, PI, 14), Color("b8c2c0"))
	_r(-1.6, 71.5, 1.6, 77, MARBLE)
	_poly([-2, 77, 2, 77, 0, 80], MARBLE_D)
	_l(0, 80, 0, 82, DARK, 0.3)
	# the Rotonda to the left
	_r(-38, 0.6, -19, 14, STONE)
	_r(-38.5, 14, -18.5, 15, STONE_D)
	_windows(-36, -21, 8, 12, 5, WIN)
	_r(-33, 15, -24, 21, STONE)
	_poly([-34, 21, -23, 21, -28.5, 24], ROOF)
	_arched(-28.5, 0.6, 3, 5.5, DARK)

## The Arch of Augustus in Rimini: one wide arch of white stone between two Corinthian columns, the roundels with
## the gods' heads, the pediment and the medieval battlements over it.
static func _rimini_arco_augusto() -> void:
	_r(-8.5, 0, 8.5, 0.5, Color("8a8478"))
	_r(-7.5, 0.5, 7.5, 12, STONE)
	_arched(0, 0.5, 8.6, 10.6, DARK)
	for s in [-1, 1]:
		_r(s * 5.8 - 0.5, 0.5, s * 5.8 + 0.5, 11, STONE_D)
		_r(s * 5.8 - 0.8, 10.6, s * 5.8 + 0.8, 11.2, STONE_D)
		_c(s * 3.6, 10.2, 0.8, STONE_D)
	_r(-8, 11.2, 8, 12.4, STONE_D)
	_poly([-4.8, 12.4, 4.8, 12.4, 0, 14.4], STONE_D)
	# the battlements added in the Middle Ages
	_r(-7.5, 12.4, 7.5, 14.2, STONE)
	for k in 6:
		var x := -7.0 + k * 2.8
		_r(x, 14.2, x + 1.4, 16.4, STONE)
		_poly([x, 16.4, x + 1.4, 16.4, x + 0.7, 17], STONE_D)

## The Castello del Buonconsiglio in Trento: the medieval Castelvecchio with its battlements, the round Torre
## d'Augusto on the hillside, the Renaissance Magno Palazzo with the loggia.
static func _trento_buonconsiglio() -> void:
	_poly([-45, 0, 45, 0, 45, 4, -10, 6, -45, 3], HILL)
	var wall := Color("d8cdb3")
	var wall_d := Color("b5aa90")
	# the round Torre d'Augusto
	_r(-40, 3, -30, 34, wall)
	_r(-40.6, 34, -29.4, 35.4, wall_d)
	for k in 5:
		_r(-40 + k * 2.2, 35.4, -39 + k * 2.2, 37.4, wall)
	_windows(-38, -32, 22, 25, 2, WIN)
	# the Castelvecchio with the Venetian loggia
	_r(-30, 4, 2, 24, wall)
	_r(-30.4, 24, 2.4, 25, wall_d)
	for k in 12:
		_r(-30 + k * 2.7, 25, -28.8 + k * 2.7, 27, wall)
	_windows(-27, -1, 9, 12, 7, WIN)
	for k in 5:
		_arched(-24.0 + k * 4.0, 15, 2.6, 6, WIN)
	_r(-6, 24, 0, 31, wall)
	_poly([-7, 31, 1, 31, -3, 36], ROOF)
	# the Magno Palazzo
	_r(2, 4, 40, 20, Color("e6dcc4"))
	_poly([1, 20, 41, 20, 38, 23, 4, 23], ROOF)
	_windows(5, 37, 7, 10, 8, WIN)
	_windows(5, 37, 13, 17, 8, WIN)
	_r(2, 11.2, 40, 11.8, wall_d)

## The Greek Theatre of Syracuse: the half-circle of seats cut into the rock of the hill, rows of white stone
## rising to the top, the orchestra and the stage at the foot, pines on the hillside.
static func _siracusa_teatro_greco() -> void:
	_poly([-70, 0, 70, 0, 70, 22, 55, 24, -55, 24, -70, 22], HILL)
	# the bowl: rows of seats as stripes, wider towards the top
	for k in 12:
		var y := 1.5 + k * 1.7
		var w := 22.0 + k * 3.6
		_poly([-w, y, w, y, w + 3.6, y + 1.7, -w - 3.6, y + 1.7], ROCK if k % 2 == 0 else ROCK_D)
	# the stairways dividing the seats into wedges
	for s in [-1.0, -0.6, -0.2, 0.2, 0.6, 1.0]:
		_l(s * 22.0, 1.5, s * 65.0, 21.9, ROCK_D, 0.6)
	_r(-62, 21.9, 62, 22.6, ROCK_D)
	# the orchestra and the low stage ruins
	_poly(_arc(0, 0, 20, 2.2, 0, PI, 10), Color("d7c9a6"))
	_r(-26, 0, 26, 1.2, ROCK_D)
	for x in [-18.0, -9.0, 9.0, 18.0]:
		_r(x - 1, 0, x + 1, 3, ROCK)
	# umbrella pines on the hill
	for x in [-60.0, 52.0, 64.0]:
		_l(x, 22, x, 25, Color("5b4632"), 0.6)
		_poly(_arc(x, 24.5, 4.5, 1.5, 0, PI, 6), Color("4d6b35"))

## The Torre del Mangia in Siena: the slender brick tower with the white stone crown and bell cage, beside the
## Palazzo Pubblico with its crenellated brick front and the stone ground floor, over the Campo.
static func _siena_torre_mangia() -> void:
	_r(-35, 0, 35, 0.8, Color("c47e55"))
	# the Palazzo Pubblico: stone below, brick above, Gothic triple windows, battlements
	_r(-34, 0.8, 18, 8, STONE)
	_r(-34, 8, 18, 22, BRICK)
	_r(-6, 22, 8, 28, BRICK)
	for k in 10:
		_arched(-31.0 + k * 5.0, 1.5, 2.4, 5.0, DARK)
		_arched(-31.0 + k * 5.0, 11, 2.6, 4.6, MARBLE)
		_arched(-31.0 + k * 5.0, 16, 2.6, 4.6, MARBLE)
	for k in 13:
		_r(-34 + k * 4.0, 22, -32 + k * 4.0, 24, BRICK_D)
	_c(1, 25, 1.8, MARBLE)
	# the tower
	_r(19, 0.8, 27, 86, BRICK)
	_r(18.6, 30, 27.4, 30.6, BRICK_D)
	_r(18.6, 60, 27.4, 60.6, BRICK_D)
	_windows(20, 26, 70, 74, 2, WIN)
	# the stone crown with the machicolations
	_r(17.5, 86, 28.5, 89, MARBLE)
	for k in 6:
		_r(17.8 + k * 1.8, 86.3, 18.6 + k * 1.8, 87.6, STONE_D)
	_r(20, 89, 26, 95, MARBLE)
	_arched(23, 89.5, 3.2, 4.8, WIN)
	_r(19.4, 95, 26.6, 96, MARBLE_D)
	# the bell cage
	_l(20.4, 96, 20.4, 100, DARK, 0.3)
	_l(25.6, 96, 25.6, 100, DARK, 0.3)
	_poly(_arc(23, 100, 2.6, 1.5, 0, PI, 6), DARK)
	_l(23, 101.5, 23, 102, DARK, 0.3)
