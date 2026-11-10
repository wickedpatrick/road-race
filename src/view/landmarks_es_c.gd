class_name LandmarksEsC
extends RefCounted
## Spanish landmarks (Albacete to Mérida), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const STONE := Color("d8c39a")
const STONE_D := Color("b39c72")
const GOLD_ST := Color("dcb878")
const GOLD_ST_D := Color("b8925a")
const WHITE := Color("f2ede2")
const WHITE_D := Color("d6cfc0")
const CREAM := Color("efe2c2")
const CREAM_D := Color("cdbd98")
const MARBLE := Color("ece6da")
const MARBLE_D := Color("c9c1b0")
const GREY := Color("c4c0b6")
const GREY_D := Color("9c978b")
const BRICK := Color("c98a5a")
const BRICK_D := Color("a0663c")
const SLATE := Color("5d6670")
const WIN := Color("3a3a40")
const DARK := Color("2b2b30")
const GRASS := Color("6f8f45")
const HILL := Color("a79a62")
const WATER := Color("4f86a8")
const GOLD := Color("e0b440")
const GLASS := Color("8fb6cc")
const ROOF := Color("a5583b")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"es_albacete_lodares": _albacete_lodares()
		"es_santander_magdalena": _santander_magdalena()
		"es_logrono_redonda": _logrono_redonda()
		"es_salamanca_plaza_mayor": _salamanca_plaza_mayor()
		"es_tarragona_anfiteatro": _tarragona_anfiteatro()
		"es_leon_catedral": _leon_catedral()
		"es_cadiz_catedral": _cadiz_catedral()
		"es_jaen_catedral": _jaen_catedral()
		"es_toledo_alcazar": _toledo_alcazar()
		"es_merida_teatro": _merida_teatro()
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

static func _pointed(x: float, y0: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.5, y0, x + w * 0.5, y0, x + w * 0.5, y0 + h - w * 0.8, x, y0 + h, x - w * 0.5, y0 + h - w * 0.8], col)

static func _dome(x: float, y: float, r: float, h: float, col: Color) -> void:
	_poly(_arc(x, y, r, h, 0, PI, 12), col)

static func _merlons(x0: float, x1: float, y: float, h: float, n: int, col: Color) -> void:
	var step: float = (x1 - x0) / n
	for k in n:
		_r(x0 + step * k + step * 0.2, y, x0 + step * k + step * 0.8, y + h, col)

## The Pasaje de Lodares in Albacete: the arched entrance of the glass-roofed arcade between two richly decorated
## house fronts with their balconies.
static func _albacete_lodares() -> void:
	_r(-15, 0, 15, 0.5, GREY_D)
	_r(-14, 0.5, 14, 19, CREAM)
	_arched(0, 0.5, 7, 13, GLASS)
	_r(-0.2, 0.5, 0.2, 9.5, WHITE_D)
	_poly(_arc(0, 9.5, 3.5, 3.5, 0, PI, 10) + _arc(0, 9.5, 2.8, 2.8, PI, 0, 10), CREAM_D)
	for s in [-1, 1]:
		var x: float = s * 9.0
		_r(x - 4.0, 0.5, x + 4.0, 3.5, CREAM_D)
		for y in [5.0, 11.0]:
			_arched(x - 1.8, y, 1.6, 3.6, WIN)
			_arched(x + 1.8, y, 1.6, 3.6, WIN)
			_r(x - 3.6, y - 0.3, x + 3.6, y + 0.2, DARK)
	_r(-14.5, 19, 14.5, 20, CREAM_D)
	_poly([-6, 20, 6, 20, 6, 21.5] + _arc(0, 21.5, 6, 2.5, 0, PI, 8), CREAM)
	for x in [-12.0, 12.0]:
		_r(x - 1.0, 20, x + 1.0, 22, CREAM_D)
		_c(x, 22.6, 0.7, CREAM_D)

## The Palacio de la Magdalena in Santander: the English-style palace with its towers and steep slate roofs on the
## green peninsula over the bay.
static func _santander_magdalena() -> void:
	_r(-40, 0, 40, 1.5, WATER)
	_poly([-36, 1.5, 36, 1.5, 32, 4, -32, 4], GRASS)
	_r(-26, 4, 26, 16, WHITE)
	_poly([-27, 16, 27, 16, 22, 21, -22, 21], SLATE)
	_windows(-24, 24, 7, 10, 12, WIN)
	_windows(-24, 24, 12, 14.5, 12, WIN)
	# the gabled bays and corner towers
	for x in [-14.0, 14.0]:
		_r(x - 4.0, 4, x + 4.0, 19, WHITE)
		_poly([x - 4.5, 19, x + 4.5, 19, x, 24], SLATE)
		_arched(x, 15.5, 2, 2.6, WIN)
	for x in [-24.0, 24.0]:
		_r(x - 3.0, 4, x + 3.0, 22, WHITE_D)
		_poly([x - 3.5, 22, x + 3.5, 22, x + 2.0, 26, x - 2.0, 26], SLATE)
		_r(x - 1.0, 26, x + 1.0, 28, SLATE)
		_r(x - 0.7, 16, x + 0.7, 19, WIN)
	_r(-3, 4, 3, 22, WHITE)
	_poly([-3.5, 22, 3.5, 22, 0, 30], SLATE)
	_r(-0.2, 30, 0.2, 32, DARK)
	_arched(0, 4, 2.6, 5, DARK)

## Santa María de la Redonda in Logroño: the Baroque front with its big niche and the twin towers with their
## stacked belfries and lanterns.
static func _logrono_redonda() -> void:
	_r(-20, 0, 20, 0.5, GREY_D)
	_r(-9, 0.5, 9, 24, STONE)
	_arched(0, 0.5, 8, 18, STONE_D)
	_arched(0, 1.5, 4.5, 11, DARK)
	_poly([-9, 24, 9, 24, 0, 30], STONE)
	for s in [-1, 1]:
		var x: float = s * 13.5
		_r(x - 4.5, 0.5, x + 4.5, 30, STONE)
		_r(x - 5.0, 30, x + 5.0, 31.5, STONE_D)
		_r(x - 4.0, 31.5, x + 4.0, 40, STONE)
		_arched(x, 32.5, 3, 6, WIN)
		_r(x - 4.5, 40, x + 4.5, 41.2, STONE_D)
		_r(x - 3.2, 41.2, x + 3.2, 48, STONE)
		_arched(x, 42, 2.2, 5, WIN)
		_r(x - 3.6, 48, x + 3.6, 49, STONE_D)
		_dome(x, 49, 3, 4, STONE_D)
		_r(x - 0.8, 53, x + 0.8, 56, STONE)
		_dome(x, 56, 1, 1.6, STONE_D)
		_r(x - 0.15, 57.6, x + 0.15, 61, DARK)
		_r(x - 1.0, 59.8, x + 1.0, 60.3, DARK)
		for y in [10.0, 20.0]:
			_r(x - 0.8, y, x + 0.8, y + 3, WIN)

## The Plaza Mayor of Salamanca: the long arcaded front of golden Villamayor stone with its rows of balconies and
## the town hall pavilion with its bell gable in the middle.
static func _salamanca_plaza_mayor() -> void:
	_r(-45, 0, 45, 0.6, GOLD_ST_D)
	_r(-44, 0.6, 44, 18, GOLD_ST)
	for k in 17:
		var x: float = -40.0 + k * 5.0
		_arched(x, 0.6, 3.6, 5.8, WIN)
	for y in [8.0, 11.5, 15.0]:
		_windows(-43, 43, y, y + 2.2, 17, GOLD_ST_D)
	_r(-44.5, 18, 44.5, 19, GOLD_ST_D)
	_merlons(-44, 44, 19, 1.0, 30, GOLD_ST_D)
	# the town hall pavilion
	_r(-9, 0.6, 9, 22, GOLD_ST)
	for x in [-4.5, 0.0, 4.5]:
		_arched(x, 0.6, 3.2, 6, WIN)
		_r(x - 1.0, 9, x + 1.0, 13, WIN)
	_r(-9.5, 22, 9.5, 23, GOLD_ST_D)
	_poly([-5, 23, 5, 23, 5, 26.5, 2, 29, -2, 29, -5, 26.5], GOLD_ST)
	_arched(0, 24, 2, 3.4, WIN)
	_r(-0.2, 29, 0.2, 30, DARK)

## The Roman amphitheatre of Tarragona: the tiers cut into the slope by the sea, the arena with the ruined
## church in it.
static func _tarragona_anfiteatro() -> void:
	_r(-60, 0, 60, 2, WATER)
	_poly([-60, 2, 60, 2, 60, 6, -60, 6], Color("e3d3a8"))
	_poly([-56, 6, 56, 6, 56, 24, 40, 26, -40, 26, -56, 24], HILL)
	# the tiers of seats, stepping down to the arena
	for k in 5:
		var w: float = 50.0 - k * 6.0
		var y: float = 24.0 - k * 3.4
		_r(-w, y - 3.4, w, y, STONE if k % 2 == 0 else STONE_D)
	_r(-24, 6, 24, 8, Color("d9c08a"))
	# the arena wall and the vaults under the tiers
	for k in 8:
		_arched(-21.0 + k * 6.0, 8, 2.4, 3.6, DARK)
	# the ruined church in the arena
	_r(-6, 8, 6, 14, STONE)
	_poly([-6, 14, 6, 14, 6, 15.5, -2, 17, -6, 15.5], STONE)
	_arched(-2, 8, 2, 4, DARK)
	_arched(3, 10, 1.4, 2.6, DARK)

## León Cathedral: the Gothic west front with its great rose window, the triple portal, the two towers with their
## spires and the flying buttresses of the nave behind.
static func _leon_catedral() -> void:
	_r(-30, 0, 30, 0.6, GREY_D)
	_r(-27, 0.6, 27, 26, GOLD_ST_D)
	_poly([-27, 26, 27, 26, 0, 34], SLATE)
	for x in [-24.0, -16.0, 16.0, 24.0]:
		_l(x, 30, x + (3.0 if x < 0.0 else -3.0), 22, GOLD_ST, 0.6)
	_r(-10, 0.6, 10, 30, GOLD_ST)
	_poly([-10, 30, 10, 30, 0, 40], GOLD_ST)
	_c(0, 21, 5.5, GOLD_ST_D)
	_c(0, 21, 4.5, Color("3d5a8a"))
	for k in 8:
		var a: float = k * PI / 4.0
		_l(0, 21, cos(a) * 4.5, 21.0 + sin(a) * 4.5, GOLD_ST_D, 0.3)
	for x in [-6.0, 0.0, 6.0]:
		_pointed(x, 0.6, 3.6 if x == 0.0 else 2.8, 10 if x == 0.0 else 8.0, DARK)
	for s in [-1, 1]:
		var x: float = s * 15.5
		_r(x - 4.5, 0.6, x + 4.5, 42, GOLD_ST)
		_r(x - 5.0, 42, x + 5.0, 43, GOLD_ST_D)
		for y in [10.0, 24.0, 34.0]:
			_pointed(x, y, 2.2, 6, WIN)
		_poly([x - 4.0, 43, x + 4.0, 43, x, 63], GOLD_ST_D)
		for d in [-4.5, 4.5]:
			_poly([x + d - 0.6, 43, x + d + 0.6, 43, x + d, 48], GOLD_ST_D)

## Cádiz Cathedral: the Baroque front with its twin towers, the dome covered in golden tiles behind and the
## seawall of the Campo del Sur in front.
static func _cadiz_catedral() -> void:
	_r(-40, 0, 40, 1.5, WATER)
	_r(-38, 1.5, 38, 4, GREY_D)
	_r(-18, 4, 18, 30, CREAM)
	_poly([-11, 30, 11, 30, 11, 32] + _arc(0, 32, 11, 4, 0, PI, 10), CREAM)
	_arched(0, 4, 5, 11, DARK)
	_arched(-12, 4, 3, 7, DARK)
	_arched(12, 4, 3, 7, DARK)
	for x in [-16.0, -6.5, 6.5, 16.0]:
		_r(x - 0.5, 4, x + 0.5, 29, CREAM_D)
	_c(0, 21, 2.3, WIN)
	# the dome behind
	_r(-9, 34, 9, 40, CREAM_D)
	_dome(0, 40, 10, 11, GOLD)
	for x in [-6.0, -2.0, 2.0, 6.0]:
		_l(x * 0.4, 51, x, 40.5, Color("c89a2e"), 0.4)
	_r(-1, 51, 1, 54, CREAM)
	_dome(0, 54, 1.4, 2, GOLD)
	_r(-0.2, 56, 0.2, 58, DARK)
	for s in [-1, 1]:
		var x: float = s * 25.0
		_r(x - 6.0, 4, x + 6.0, 34, CREAM)
		_r(x - 6.5, 34, x + 6.5, 35.2, CREAM_D)
		_r(x - 4.5, 35.2, x + 4.5, 43, CREAM)
		_arched(x, 36.5, 3, 5.5, WIN)
		_dome(x, 43, 4.5, 4.5, GOLD)
		_r(x - 0.2, 47.5, x + 0.2, 50, DARK)
		for y in [12.0, 24.0]:
			_arched(x, y, 2.4, 5, WIN)

## Jaén Cathedral: Vandelvira's Renaissance front with its columns and balustrade, the statues along its top and
## the two square towers.
static func _jaen_catedral() -> void:
	_r(-35, 0, 35, 0.6, GREY_D)
	_r(-20, 0.6, 20, 32, STONE)
	for x in [-16.0, -10.0, -4.0, 4.0, 10.0, 16.0]:
		_r(x - 0.8, 0.6, x + 0.8, 30, STONE_D)
	_r(-20.5, 16, 20.5, 17.2, STONE_D)
	for x in [-7.0, 0.0, 7.0]:
		_arched(x, 0.6, 3.6 if x == 0.0 else 2.8, 10 if x == 0.0 else 8.0, DARK)
		_arched(x, 19, 2.4, 6.5, WIN)
	_r(-21, 32, 21, 33.4, STONE_D)
	for k in 9:
		var x: float = -16.0 + k * 4.0
		_r(x - 0.4, 33.4, x + 0.4, 36, STONE_D)
		_c(x, 36.6, 0.6, STONE_D)
	_poly([-8, 33.4, 8, 33.4, 0, 39], STONE)
	for s in [-1, 1]:
		var x: float = s * 27.0
		_r(x - 7.0, 0.6, x + 7.0, 50, STONE)
		_r(x - 7.5, 50, x + 7.5, 51.5, STONE_D)
		_r(x - 5.0, 51.5, x + 5.0, 57, STONE)
		_arched(x, 52, 3, 4.5, WIN)
		_poly([x - 5.5, 57, x + 5.5, 57, x, 61], STONE_D)
		for y in [12.0, 26.0, 40.0]:
			_arched(x, y, 2.6, 5.5, WIN)

## The Alcázar of Toledo: the square fortress with its four corner towers and slate spires, on the hill above the
## houses of the old town.
static func _toledo_alcazar() -> void:
	_poly([-40, 0, 40, 0, 40, 6, 28, 12, -28, 12, -40, 6], HILL)
	for k in 6:
		var x: float = -36.0 + k * 13.0
		var h: float = 5.0 + float(k % 3) * 1.5
		var base: float = 3.0 if absf(x) > 30.0 else 1.0
		_r(x, 0, x + 8, base + h, CREAM)
		_poly([x - 0.5, base + h, x + 8.5, base + h, x + 4, base + h + 2], ROOF)
	_r(-26, 11, 26, 30, GOLD_ST)
	_windows(-22, 22, 15, 18, 10, WIN)
	_windows(-22, 22, 22, 25, 10, WIN)
	_arched(0, 11, 4, 7, DARK)
	_r(-26.5, 30, 26.5, 31, GOLD_ST_D)
	for x in [-24.0, 24.0]:
		_r(x - 4.5, 11, x + 4.5, 35, GOLD_ST)
		_r(x - 5.0, 35, x + 5.0, 36, GOLD_ST_D)
		_poly([x - 4.5, 36, x + 4.5, 36, x + 1.0, 42.5, x - 1.0, 42.5], SLATE)
		_r(x - 0.15, 42.5, x + 0.15, 45, DARK)
		for y in [16.0, 24.0, 31.0]:
			_r(x - 0.7, y, x + 0.7, y + 2, WIN)

## The Roman theatre of Mérida: the stage front with its two storeys of marble columns and statues between them,
## and the stone tiers of the cavea curving round on both sides.
static func _merida_teatro() -> void:
	_r(-35, 0, 35, 0.8, STONE_D)
	for s in [-1, 1]:
		_poly([s * 22.0, 0.8, s * 35.0, 0.8, s * 35.0, 10, s * 26.0, 14, s * 22.0, 12], STONE)
		for k in 4:
			_l(s * 23.0, 2.5 + k * 2.6, s * 34.5, 2.0 + k * 2.4, STONE_D, 0.3)
	_r(-22, 0.8, 22, 2.5, STONE_D)
	_r(-21, 2.5, 21, 14, Color("cdb88e"))
	_r(-21, 14.5, 21, 25.5, Color("cdb88e"))
	for x in [-14.0, 0.0, 14.0]:
		_arched(x, 2.5, 4.4 if x == 0.0 else 3.2, 9 if x == 0.0 else 7.0, DARK)
	# the two storeys of columns with their entablatures
	for row in [[2.5, 13.0], [14.5, 24.0]]:
		for k in 15:
			var x: float = -19.6 + k * 2.8
			_r(x - 0.45, row[0], x + 0.45, row[1], MARBLE)
		_r(-21.5, row[1], 21.5, row[1] + 1.2, MARBLE_D)
		_r(-21.5, row[1] + 1.2, 21.5, row[1] + 1.5, STONE_D)
	for x in [-11.2, -5.6, 5.6, 11.2]:
		_r(x - 0.4, 16, x + 0.4, 19.5, MARBLE_D)
		_c(x, 20.1, 0.55, MARBLE_D)
	_r(-22, 25.5, 22, 26.2, STONE_D)
