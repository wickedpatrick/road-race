class_name LandmarksEsA
extends RefCounted
## Spanish landmarks (Madrid to Córdoba), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const GRANITE := Color("d9d2c3")
const GRANITE_D := Color("b3ab9a")
const STONE := Color("d8c39a")
const STONE_D := Color("b39c72")
const OCHRE := Color("d9b07a")
const OCHRE_D := Color("b48a56")
const BRICK := Color("c98a5a")
const BRICK_D := Color("a0663c")
const WHITE := Color("f2ede2")
const WHITE_D := Color("d6cfc0")
const WIN := Color("3a3a40")
const DARK := Color("2b2b30")
const GRASS := Color("8a9a4c")
const HILL := Color("a79a62")
const PINE := Color("4f6b38")
const RED := Color("b23a2e")
const TILE_G := Color("3f8a5c")
const TILE_Y := Color("e2b33c")
const TILE_B := Color("3a6aa8")
const TITAN := Color("b9bec4")
const TITAN_D := Color("8f959c")
const GLASS := Color("7fa6bf")
const WATER := Color("4f86a8")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"es_madrid_puerta_alcala": _madrid_puerta_alcala()
		"es_barcelona_sagrada": _barcelona_sagrada()
		"es_valencia_serranos": _valencia_serranos()
		"es_zaragoza_pilar": _zaragoza_pilar()
		"es_sevilla_giralda": _sevilla_giralda()
		"es_malaga_alcazaba": _malaga_alcazaba()
		"es_murcia_catedral": _murcia_catedral()
		"es_alicante_santa_barbara": _alicante_santa_barbara()
		"es_bilbao_guggenheim": _bilbao_guggenheim()
		"es_cordoba_mezquita": _cordoba_mezquita()
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

## A round-headed opening `w` wide and `h` high standing on y0.
static func _arched(x: float, y0: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.5, y0, x + w * 0.5, y0, x + w * 0.5, y0 + h - w * 0.5] + _arc(x, y0 + h - w * 0.5, w * 0.5, w * 0.5, 0, PI, 6), col)

## A dome of radius r on y.
static func _dome(x: float, y: float, r: float, h: float, col: Color) -> void:
	_poly(_arc(x, y, r, h, 0, PI, 12), col)

## Battlements along x0..x1 standing on y.
static func _merlons(x0: float, x1: float, y: float, h: float, n: int, col: Color) -> void:
	var step: float = (x1 - x0) / n
	for k in n:
		_r(x0 + step * k + step * 0.2, y, x0 + step * k + step * 0.8, y + h, col)

## The Puerta de Alcalá in Madrid: five openings (three arches, two square doors), paired columns, the attic with
## the royal coat of arms and the sculpture groups on top.
static func _madrid_puerta_alcala() -> void:
	_r(-20, 0, 20, 0.6, GRANITE_D)
	_r(-18, 0.6, 18, 16.5, GRANITE)
	for x in [-7.0, 0.0, 7.0]:
		_arched(x, 0.6, 4.2, 10.5, DARK)
	for s in [-1, 1]:
		_r(s * 14.0 - 1.6, 0.6, s * 14.0 + 1.6, 6.5, DARK)
		_r(s * 14.0 - 2.2, 6.5, s * 14.0 + 2.2, 7.2, GRANITE_D)
	for x in [-17.0, -11.0, -10.0, -4.0, 4.0, 10.0, 11.0, 17.0]:
		_r(x - 0.4, 0.6, x + 0.4, 15.5, WHITE_D)
	_r(-19, 15.5, 19, 17.3, GRANITE_D)
	_r(-9, 17.3, 9, 20.5, GRANITE)
	_poly([-6.5, 20.5, 6.5, 20.5, 0, 22.4], GRANITE_D)
	_c(0, 19, 1.3, OCHRE_D)
	# the sculpture groups: children and trophies over the outer bays
	for x in [-13.0, 13.0]:
		_r(x - 1.5, 17.3, x + 1.5, 19.2, GRANITE_D)
		_poly([x - 1.2, 19.2, x + 1.2, 19.2, x + 0.5, 21.5, x - 0.5, 21.5], WHITE_D)
	_poly([-2.5, 22.4, 2.5, 22.4, 1, 24, -1, 24], WHITE_D)

## One of the Sagrada Família's spires: a tapering cone with its rows of openings and a round finial on top.
static func _spire(x: float, y0: float, w: float, top: float, col: Color, col_d: Color) -> void:
	_poly([x - w, y0, x + w, y0, x + w * 0.55, top - w * 2.5, x, top, x - w * 0.55, top - w * 2.5], col)
	var y: float = y0 + 4.0
	while y < top - w * 4.0:
		_r(x - w * 0.18, y, x + w * 0.18, y + 1.8, col_d)
		y += 4.0
	_c(x, top - w * 0.4, w * 0.45, TILE_Y)

## The Sagrada Família in Barcelona: the nave and the Nativity façade, its four bell towers, the evangelists'
## towers and the tall central Tower of Jesus Christ with its cross.
static func _barcelona_sagrada() -> void:
	_r(-45, 0, 45, 0.6, GRASS)
	_r(-40, 0.6, 40, 42, STONE)
	_poly([-40, 42, 40, 42, 30, 52, -30, 52], STONE_D)
	for x in [-30.0, -15.0, 15.0, 30.0]:
		_arched(x, 8, 5, 22, WIN)
	_spire(0, 50, 6.0, 168, STONE, STONE_D)
	_poly([-0.6, 166, 0.6, 166, 0.6, 172, -0.6, 172], WHITE)
	_r(-2.2, 169.4, 2.2, 170.6, WHITE)
	for s in [-1.0, 1.0]:
		_spire(s * 13.0, 46, 4.0, 135, STONE_D, BRICK_D)
	# the Nativity façade: the portals and its four bell towers
	_r(-34, 0.6, -6, 30, STONE_D)
	_poly([-34, 30, -6, 30, -20, 46], STONE_D)
	_arched(-20, 0.6, 8, 18, DARK)
	_arched(-29, 0.6, 4, 12, DARK)
	_arched(-11, 0.6, 4, 12, DARK)
	for t in [[-32.0, 98.0], [-25.0, 107.0], [-15.0, 107.0], [-8.0, 98.0]]:
		_spire(t[0], 28, 2.6, t[1], STONE, STONE_D)

## The Torres de Serranos in Valencia: two polygonal towers either side of the gate, the Gothic tracery over it and
## the battlements.
static func _valencia_serranos() -> void:
	_r(-20, 0, 20, 0.5, STONE_D)
	_r(-8, 0.5, 8, 24, STONE)
	_arched(0, 0.5, 6, 11, DARK)
	_r(-6, 15, 6, 17.5, STONE_D)
	for k in 6:
		_arched(-5.0 + k * 2.0, 15.3, 1.2, 2.0, STONE)
	_r(-8.5, 24, 8.5, 25, STONE_D)
	_merlons(-8.5, 8.5, 25, 1.8, 7, STONE)
	for s in [-1, 1]:
		var x0: float = s * 8.0
		var x1: float = s * 19.0
		_r(minf(x0, x1), 0.5, maxf(x0, x1), 30, STONE)
		# the polygonal tower's shaded face towards the gate
		_r(minf(x0, x0 + s * 3.0), 0.5, maxf(x0, x0 + s * 3.0), 30, STONE_D)
		_r(minf(x0, x1) - 0.3, 30, maxf(x0, x1) + 0.3, 31, STONE_D)
		_merlons(minf(x0, x1) - 0.3, maxf(x0, x1) + 0.3, 31, 2.0, 5, STONE)
		for y in [8.0, 18.0]:
			_r(s * 13.5 - 0.6, y, s * 13.5 + 0.6, y + 2.5, WIN)

## The Basílica del Pilar in Zaragoza: the long body by the Ebro, the big central dome, the smaller domes in green,
## yellow and blue tiles and the four corner towers.
static func _zaragoza_pilar() -> void:
	_r(-65, 0, 65, 2, WATER)
	_r(-54, 2, 54, 30, OCHRE)
	_r(-55, 30, 55, 32, OCHRE_D)
	_windows(-50, 50, 18, 24, 14, WIN)
	_windows(-50, 50, 6, 13, 14, OCHRE_D)
	# the domes, the middle one largest
	for d in [[-40.0, 7.0, TILE_G], [-24.0, 8.0, TILE_Y], [24.0, 8.0, TILE_B], [40.0, 7.0, TILE_G]]:
		_r(d[0] - d[1] * 0.8, 32, d[0] + d[1] * 0.8, 36, OCHRE_D)
		_dome(d[0], 36, d[1], d[1] * 0.9, d[2])
		_r(d[0] - 0.8, 36.0 + d[1] * 0.9, d[0] + 0.8, 38.5 + d[1] * 0.9, WHITE_D)
	_r(-10, 32, 10, 42, OCHRE_D)
	_dome(0, 42, 12, 13, TILE_G)
	for k in 5:
		_l(-8.0 + k * 4.0, 43, -6.0 + k * 3.0, 53, TILE_Y, 0.6)
	_r(-1.2, 55, 1.2, 60, WHITE_D)
	_poly([-1.5, 60, 1.5, 60, 0, 63], WHITE_D)
	# the four towers at the corners
	for x in [-59.0, 59.0]:
		_r(x - 4.5, 2, x + 4.5, 70, OCHRE)
		_r(x - 5, 70, x + 5, 72, OCHRE_D)
		_r(x - 3.5, 72, x + 3.5, 80, OCHRE)
		_arched(x, 73, 2.5, 5.5, WIN)
		_dome(x, 80, 3.5, 4, TILE_B)
		_r(x - 0.8, 84, x + 0.8, 88, WHITE_D)
		_poly([x - 1, 88, x + 1, 88, x, 92], WHITE_D)
		for y in [20.0, 40.0, 58.0]:
			_arched(x, y, 2.2, 5, WIN)

## La Giralda in Seville: the Almohad brick shaft with its sebka panels, the Renaissance belfry in white and ochre,
## the lantern stages and the Giraldillo weather vane.
static func _sevilla_giralda() -> void:
	_r(-15, 0, 15, 0.5, STONE_D)
	_r(-7, 0.5, 7, 70, BRICK)
	for y in [10.0, 30.0, 50.0]:
		_r(-5, y, 5, y + 14, BRICK_D)
		_r(-4, y + 1, 4, y + 13, BRICK)
		_arched(0, y + 4, 2.2, 6, WIN)
	_r(-7.5, 70, 7.5, 71.2, WHITE_D)
	_r(-6.5, 71.2, 6.5, 83, WHITE)
	for x in [-3.5, 0.0, 3.5]:
		_arched(x, 72.5, 2.3, 7, WIN)
	_r(-7, 83, 7, 84, OCHRE_D)
	_r(-5, 84, 5, 91, OCHRE)
	_arched(0, 85, 2.2, 5, WIN)
	_r(-3.5, 91, 3.5, 96, WHITE)
	_dome(0, 96, 2.5, 3, OCHRE_D)
	_r(-0.3, 99, 0.3, 102, DARK)
	_poly([-0.4, 102, 0.4, 102, 0.6, 103.2, 0, 104, -0.6, 103.2], DARK)
	_poly([0.3, 102.4, 1.6, 103.2, 0.3, 103.4], DARK)

## The Alcazaba of Málaga: walls and square towers climbing the slope of Gibralfaro over pines.
static func _malaga_alcazaba() -> void:
	_poly([-55, 0, 55, 0, 55, 10, 35, 22, 10, 33, -15, 30, -38, 18, -55, 8], HILL)
	for p in [[-48.0, 4.0], [-30.0, 6.0], [40.0, 5.0], [48.0, 3.0], [-5.0, 8.0], [22.0, 9.0]]:
		_c(p[0], p[1] + 3.0, 3.0, PINE)
		_r(p[0] - 0.3, p[1], p[0] + 0.3, p[1] + 1.5, BRICK_D)
	# the lower ring of walls
	_r(-36, 14, 32, 22, STONE)
	_merlons(-36, 32, 22, 1.5, 22, STONE)
	for x in [-36.0, -14.0, 8.0, 28.0]:
		_r(x - 2.5, 14, x + 2.5, 26, STONE_D)
		_merlons(x - 2.5, x + 2.5, 26, 1.5, 3, STONE_D)
	# the inner citadel with its palace
	_r(-18, 26, 18, 38, STONE)
	_merlons(-18, 18, 38, 1.6, 12, STONE)
	for x in [-18.0, 0.0, 18.0]:
		_r(x - 3, 26, x + 3, 44, STONE_D)
		_merlons(x - 3, x + 3, 44, 1.8, 3, STONE_D)
	_arched(-9, 26, 3, 6, DARK)
	_windows(4, 15, 32, 35, 3, WIN)
	_r(-55, 0, 55, 1, GRASS)

## Murcia Cathedral: the Baroque front with its columns and curved crown, and the tall bell tower beside it with
## its stages and the dome-capped lantern.
static func _murcia_catedral() -> void:
	_r(-30, 0, 30, 0.6, STONE_D)
	_r(-28, 0.6, 8, 26, STONE)
	_poly([-20, 26, 0, 26] + _arc(-10, 32, 10, 6, 0, PI, 8), STONE)
	_arched(-10, 0.6, 6, 13, DARK)
	_arched(-22, 0.6, 3, 8, DARK)
	_arched(2, 0.6, 3, 8, DARK)
	for x in [-26.0, -16.5, -3.5, 6.0]:
		_r(x - 0.5, 0.6, x + 0.5, 25, WHITE_D)
	_c(-10, 20, 2.5, WIN)
	_r(-28.5, 25.5, 8.5, 26.5, STONE_D)
	# the bell tower, its stages narrowing upwards
	_r(12, 0.6, 26, 48, STONE)
	_r(11.5, 48, 26.5, 49.5, STONE_D)
	_r(13, 49.5, 25, 64, STONE)
	_arched(19, 52, 4, 9, WIN)
	_r(12.5, 64, 25.5, 65.5, STONE_D)
	_r(14.5, 65.5, 23.5, 76, STONE)
	_arched(19, 67, 3, 7, WIN)
	_dome(19, 76, 5, 7, STONE_D)
	_r(18, 83, 20, 88, STONE)
	_dome(19, 88, 1.6, 2, STONE_D)
	_r(18.8, 90, 19.2, 93, DARK)
	for y in [12.0, 28.0, 40.0]:
		_r(17.5, y, 20.5, y + 5, WIN)

## The Castillo de Santa Bárbara on Mount Benacantil above Alicante: the bare rock rising from the town and the
## walls and towers along its top.
static func _alicante_santa_barbara() -> void:
	_poly([-80, 0, 80, 0, 62, 30, 38, 80, 18, 140, 6, 158, -14, 156, -32, 120, -55, 60, -80, 14], HILL)
	_poly([-14, 156, 6, 158, -6, 120, -26, 110], STONE_D)
	# the town at the foot with its palms
	for k in 8:
		var x: float = -74.0 + k * 19.0
		_r(x, 0, x + 12, 8.0 + float(k % 3) * 3.0, WHITE)
		_windows(x + 1, x + 11, 3, 5, 3, WIN)
	for x in [-60.0, 30.0]:
		_r(x - 0.4, 0, x + 0.4, 14, BRICK_D)
		_poly([x - 4, 13, x, 15, x + 4, 13, x, 14], PINE)
	# the castle walls on the summit
	_r(-20, 140, 16, 160, STONE)
	_merlons(-20, 16, 160, 2.5, 10, STONE)
	_r(-8, 152, 6, 170, STONE)
	_merlons(-8, 6, 170, 2.5, 4, STONE)
	_r(-36, 106, -14, 120, STONE)
	_merlons(-36, -14, 120, 2, 6, STONE)
	_r(-2, 162, 1, 165, WIN)

## One of the Guggenheim's titanium sails: a lens between two arcs.
static func _sail(x: float, y: float, w: float, h: float, col: Color) -> void:
	_poly(_arc(x, y, w * 0.5, h, 0, PI, 10), col)

## The Guggenheim Museum Bilbao: the curved titanium volumes, the glass atrium and the Nervión in front.
static func _bilbao_guggenheim() -> void:
	_r(-65, 0, 65, 3, WATER)
	_r(-60, 3, 60, 6, GRANITE_D)
	_r(-55, 6, 50, 14, GRANITE)
	_sail(-40, 6, 34, 24, TITAN)
	_sail(-20, 10, 26, 34, TITAN_D)
	_sail(22, 6, 40, 26, TITAN)
	_sail(44, 6, 28, 18, TITAN_D)
	# the glass atrium and its tower of curving fins
	_poly([-8, 6, 10, 6, 12, 38, 4, 50, -4, 44, -10, 30], GLASS)
	for x in [-6.0, 0.0, 6.0]:
		_l(x, 7, x + 1.0, 28, GRANITE_D, 0.4)
	_poly([-2, 30, 4, 32, 6, 54, 1, 55, -3, 42], TITAN)
	_sail(6, 18, 20, 22, TITAN)

## The Mezquita of Córdoba: the long outer wall with its buttresses and decorated horseshoe-arched doors, the roof
## of the cathedral nave rising from the middle, and the bell tower that was the minaret.
static func _cordoba_mezquita() -> void:
	_r(-65, 0, 65, 0.6, STONE_D)
	_r(-62, 0.6, 38, 14, OCHRE)
	_r(-62.5, 14, 38.5, 15, OCHRE_D)
	_merlons(-62, 38, 15, 1.2, 30, OCHRE_D)
	for k in 7:
		var x: float = -58.0 + k * 15.0
		_r(x - 0.8, 0.6, x + 0.8, 14.5, OCHRE_D)
		var dx: float = x + 7.0
		if dx < 36.0:
			_r(dx - 3.0, 0.6, dx + 3.0, 10.5, WHITE_D)
			_c(dx, 6.5, 2.2, RED)
			_c(dx, 6.5, 1.5, WHITE)
			_r(dx - 1.5, 0.6, dx + 1.5, 6.5, DARK)
			_c(dx, 6.5, 1.0, DARK)
	# the cathedral nave in the middle of the mosque
	_poly([-14, 15, 18, 15, 18, 26, 2, 34, -14, 26], OCHRE_D)
	_r(-4, 26, 8, 30, STONE)
	# the bell tower
	_r(46, 0.6, 58, 40, STONE)
	_r(45.5, 40, 58.5, 41.5, STONE_D)
	_r(47.5, 41.5, 56.5, 50, STONE)
	_arched(52, 42.5, 3, 6, WIN)
	_dome(52, 50, 3.5, 4, STONE_D)
	_r(51.6, 54, 52.4, 58, DARK)
	_c(52, 59, 0.9, TILE_Y)
	for y in [10.0, 22.0, 32.0]:
		_arched(52, y, 2.4, 5, WIN)
