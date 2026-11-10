class_name LandmarksEsB
extends RefCounted
## Spanish landmarks (Valladolid to Burgos), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const STONE := Color("d8c39a")
const STONE_D := Color("b39c72")
const SAND := Color("e3d3a8")
const SAND_D := Color("c2ae80")
const GREY := Color("c4c0b6")
const GREY_D := Color("9c978b")
const WHITE := Color("f2ede2")
const WHITE_D := Color("d6cfc0")
const RED_ST := Color("c27a55")
const RED_ST_D := Color("9c5a3a")
const WIN := Color("3a3a40")
const DARK := Color("2b2b30")
const GRASS := Color("6f8f45")
const HILL := Color("8f8a58")
const ROCK := Color("8a8478")
const ROCK_D := Color("6c665b")
const SNOW := Color("f4f6f8")
const MOUNT := Color("8e9aac")
const IRON := Color("5a4a40")
const IRON_D := Color("3e322b")
const BRONZE := Color("6e5a3a")
const WATER := Color("4f86a8")
const SLATE := Color("5d6670")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"es_valladolid_san_pablo": _valladolid_san_pablo()
		"es_vigo_sireno": _vigo_sireno()
		"es_vitoria_catedral_nueva": _vitoria_catedral_nueva()
		"es_coruna_torre_hercules": _coruna_torre_hercules()
		"es_granada_alhambra": _granada_alhambra()
		"es_oviedo_naranco": _oviedo_naranco()
		"es_pamplona_ayuntamiento": _pamplona_ayuntamiento()
		"es_almeria_cable_ingles": _almeria_cable_ingles()
		"es_donostia_peine_viento": _donostia_peine_viento()
		"es_burgos_catedral": _burgos_catedral()
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

## A pointed (Gothic) opening `w` wide and `h` high standing on y0.
static func _pointed(x: float, y0: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.5, y0, x + w * 0.5, y0, x + w * 0.5, y0 + h - w * 0.8, x, y0 + h, x - w * 0.5, y0 + h - w * 0.8], col)

static func _merlons(x0: float, x1: float, y: float, h: float, n: int, col: Color) -> void:
	var step: float = (x1 - x0) / n
	for k in n:
		_r(x0 + step * k + step * 0.2, y, x0 + step * k + step * 0.8, y + h, col)

## San Pablo in Valladolid: the Isabelline front, its carved upper panel framed by two slim turrets, the big
## pointed portal and the ogee arch over it.
static func _valladolid_san_pablo() -> void:
	_r(-18, 0, 18, 0.5, GREY_D)
	_r(-16, 0.5, 16, 30, SAND)
	_poly([-16, 30, 16, 30, 16, 34, 0, 38, -16, 34], SAND)
	for s in [-1, 1]:
		_r(s * 14.0 - 2.0, 0.5, s * 14.0 + 2.0, 36, SAND_D)
		_poly([s * 14.0 - 2.0, 36, s * 14.0 + 2.0, 36, s * 14.0, 40], SAND_D)
	_pointed(0, 0.5, 9, 13, DARK)
	_poly([-6, 13.5, 6, 13.5, 0, 17.5], SAND_D)
	# the carved panels of the upper front
	for row in 3:
		for k in 5:
			_r(-10.0 + k * 4.2, 18.0 + row * 4.0, -8.0 + k * 4.2, 21.0 + row * 4.0, SAND_D)
	_c(0, 33.5, 1.6, SAND_D)

## O Sireno in Vigo: Leiro's half man, half fish standing on a tall column over the square.
static func _vigo_sireno() -> void:
	_r(-5, 0, 5, 0.5, GREY_D)
	_r(-1.5, 0.5, 1.5, 2, GREY)
	_r(-0.8, 2, 0.8, 13, GREY)
	_r(-1.2, 13, 1.2, 13.6, GREY_D)
	# the figure: a fish's body bent upward with a man's head and arms
	_poly([-0.4, 13.6, 0.6, 13.6, 1.2, 15.5, 0.9, 17.5, -0.5, 17.8, -0.9, 15.6], BRONZE)
	_poly([-0.9, 15.4, -3.2, 14.4, -3.6, 15.2, -1.0, 16.2], BRONZE)
	_poly([0.9, 17.3, 2.0, 18.9, 1.4, 19.2, 0.3, 17.6], BRONZE)
	_c(0.2, 18.4, 0.7, BRONZE)
	_poly([-3.6, 14.2, -4.6, 13.6, -4.4, 15.6], BRONZE)

## The New Cathedral of Vitoria-Gasteiz: the neo-Gothic apse side with buttresses and pinnacles, the tall pointed
## windows and the crossing's lantern.
static func _vitoria_catedral_nueva() -> void:
	_r(-35, 0, 35, 0.6, GRASS)
	_r(-30, 0.6, 30, 40, STONE)
	_poly([-31, 40, 31, 40, 24, 52, -24, 52], SLATE)
	for k in 7:
		var x: float = -27.0 + k * 9.0
		_r(x - 1.2, 0.6, x + 1.2, 44, STONE_D)
		_poly([x - 1.2, 44, x + 1.2, 44, x, 50], STONE_D)
		if k < 6:
			_pointed(x + 4.5, 8, 4, 24, WIN)
	_r(-9, 52, 9, 66, STONE)
	_poly([-9, 66, 9, 66, 0, 82], SLATE)
	for x in [-5.0, 0.0, 5.0]:
		_pointed(x, 54, 2.4, 9, WIN)
	for s in [-1, 1]:
		_r(s * 9.0 - 1.0, 52, s * 9.0 + 1.0, 70, STONE_D)
		_poly([s * 9.0 - 1.0, 70, s * 9.0 + 1.0, 70, s * 9.0, 76], STONE_D)
	_r(-0.3, 82, 0.3, 90, DARK)
	_r(-1.6, 87, 1.6, 87.8, DARK)

## The Tower of Hercules in A Coruña: the square Roman tower with the 18th-century neoclassical casing, its
## stepped top and the lantern, on the rocky headland.
static func _coruna_torre_hercules() -> void:
	_poly([-15, 0, 15, 0, 15, 2, 8, 5, -9, 5, -15, 2.5], ROCK)
	_r(-9, 5, 9, 7, GREY_D)
	_r(-6.5, 7, 6.5, 41, GREY)
	_l(-6.5, 12, 6.5, 18, GREY_D, 0.8)
	_l(-6.5, 22, 6.5, 28, GREY_D, 0.8)
	_l(-6.5, 32, 6.5, 38, GREY_D, 0.8)
	_arched(0, 7, 2.4, 4.5, DARK)
	for y in [15.0, 25.0, 35.0]:
		_r(-0.6, y, 0.6, y + 2.2, WIN)
	_r(-7, 41, 7, 42.5, GREY_D)
	_r(-5, 42.5, 5, 49, GREY)
	_r(-5.5, 49, 5.5, 50, GREY_D)
	_r(-3, 50, 3, 54, GREY)
	# the lantern, an octagon with a small dome
	_r(-2, 54, 2, 57, WHITE)
	_poly(_arc(0, 57, 2.2, 2.2, 0, PI, 8), GREY_D)
	_r(-0.2, 59.2, 0.2, 60, DARK)

## The Alhambra above Granada: the long ochre walls and towers on the Sabika hill, the Comares Tower and the
## Sierra Nevada's snowy peaks behind.
static func _granada_alhambra() -> void:
	_poly([-80, 30, -55, 58, -30, 46, 0, 78, 30, 52, 55, 70, 80, 40, 80, 30], MOUNT)
	_poly([-61, 51, -55, 58, -49, 53], SNOW)
	_poly([-7, 70, 0, 78, 7, 71, 3, 69, -3, 70], SNOW)
	_poly([49, 63, 55, 70, 61, 62], SNOW)
	_poly([-80, 0, 80, 0, 80, 18, 50, 24, -20, 26, -60, 20, -80, 14], HILL)
	for p in [[-70.0, 6.0], [-50.0, 9.0], [-30.0, 5.0], [10.0, 7.0], [40.0, 4.0], [66.0, 8.0]]:
		_c(p[0], p[1] + 3.0, 3.2, GRASS)
	_r(-62, 18, 52, 30, RED_ST)
	_merlons(-62, 52, 30, 1.4, 38, RED_ST)
	for x in [-55.0, -36.0, -14.0, 22.0, 44.0]:
		_r(x - 3.0, 18, x + 3.0, 36, RED_ST_D)
		_merlons(x - 3.0, x + 3.0, 36, 1.4, 3, RED_ST_D)
	# the Comares Tower and the palace roofs
	_r(-2, 18, 12, 48, RED_ST)
	_merlons(-2, 12, 48, 1.6, 5, RED_ST)
	for x in [1.5, 5.0, 8.5]:
		_arched(x, 38, 1.6, 4, WIN)
	_poly([14, 30, 34, 30, 34, 33, 24, 36, 14, 33], RED_ST_D)
	_r(-80, 0, 80, 1, GRASS)

## Santa María del Naranco near Oviedo: the pre-Romanesque hall on the green slope, its buttresses, the triple
## arched loggia at the end and the gabled roof.
static func _oviedo_naranco() -> void:
	_poly([-18, 0, 18, 0, 18, 2.6, -18, 0.6], GRASS)
	_r(-14, 0.7, 14, 9.5, SAND)
	_poly([-14.5, 9.5, 14.5, 9.5, 12, 12.5, -12, 12.5], RED_ST_D)
	for x in [-14.0, -8.0, -2.0, 4.0, 10.0]:
		_r(x - 0.6, 0.7, x + 0.6, 9.5, SAND_D)
	for x in [-11.0, -5.0, 1.0, 7.0]:
		_arched(x, 5.5, 1.4, 3, WIN)
	# the steps up to the hall
	_poly([-4, 0.7, 2, 0.7, 2, 1.8, -3, 4.2, -4, 4.2], SAND_D)
	# the loggia at the east end, its three arches
	_r(14, 1.6, 17, 11, SAND)
	_poly([13.8, 11, 17.4, 11, 15.6, 13], RED_ST_D)
	for k in 3:
		_arched(14.6 + k * 0.9, 5.5, 0.6, 3.5, WIN)

## Pamplona Town Hall: the Baroque front with its balcony, the columns of its three orders and the statues and
## pediment on top.
static func _pamplona_ayuntamiento() -> void:
	_r(-14, 0, 14, 0.5, GREY_D)
	_r(-10, 0.5, 10, 22, STONE)
	_arched(0, 0.5, 3.4, 6.5, DARK)
	for x in [-6.0, 6.0]:
		_arched(x, 1.5, 2.2, 4.6, WIN)
	for y in [8.5, 15.0]:
		_r(-10.5, y, 10.5, y + 0.6, STONE_D)
		for x in [-6.0, 0.0, 6.0]:
			_arched(x, y + 1.2, 2.4, 4.4, WIN)
	# the balcony from which the rocket is fired
	_r(-8, 8.5, 8, 9.6, IRON)
	for x in [-8.5, -3.2, 3.2, 8.5]:
		_r(x - 0.4, 0.5, x + 0.4, 21.5, STONE_D)
	_r(-11, 21.5, 11, 22.6, STONE_D)
	_poly([-7, 22.6, 7, 22.6, 7, 25.5, 0, 28, -7, 25.5], STONE)
	_c(0, 24.8, 1.3, STONE_D)
	for x in [-8.5, 8.5]:
		_r(x - 0.5, 22.6, x + 0.5, 24.0, STONE_D)
		_c(x, 25.0, 0.8, STONE_D)
	_r(-0.2, 28, 0.2, 30, DARK)

## The Cable Inglés in Almería: the iron loading pier on its lattice of legs over the water, the chutes on the
## sea end and the ramp from the land.
static func _almeria_cable_ingles() -> void:
	_r(-55, 0, 55, 2, WATER)
	_poly([-55, 0, -38, 0, -38, 4, -55, 6], SAND)
	_poly([-48, 6, -38, 4, -38, 12, -40, 12], IRON)
	_r(-40, 12, 50, 15, IRON)
	_r(-40, 15, 50, 16, IRON_D)
	# the lattice of legs and braces
	for k in 10:
		var x: float = -36.0 + k * 9.0
		_r(x - 0.6, 2, x + 0.6, 12, IRON_D)
		_l(x, 2.5, x + 9.0, 11.5, IRON, 0.4)
		_l(x + 9.0, 2.5, x, 11.5, IRON, 0.4)
	_r(-38, 16, -30, 21, IRON)
	_poly([-38, 21, -30, 21, -34, 22], IRON_D)
	_r(40, 16, 50, 20, IRON)
	for x in [42.0, 46.0, 50.0]:
		_poly([x - 1.0, 12, x, 12, x + 2.5, 6, x + 1.5, 6], IRON_D)

## The Peine del Viento in San Sebastián: the rocks at the end of the bay with Chillida's three steel claws, one
## on the shore rocks, two on the rocks in the sea.
static func _donostia_peine_viento() -> void:
	_r(-20, 0, 20, 1.2, WATER)
	_poly([-20, 0, -6, 0, -7, 4, -12, 6.5, -20, 5], ROCK)
	_poly([2, 0, 8, 0, 7.5, 3.5, 3.0, 3.0], ROCK_D)
	_poly([12, 0, 19, 0, 18, 4, 13, 4.5], ROCK)
	_poly([-14, 6, -8, 4.5, -9, 6.5, -12, 7.5], ROCK_D)
	_claw(-11, 6.2, 1.0)
	_claw(5, 3.2, -1.0)
	_claw(15.5, 4.2, 1.0)

## One of Chillida's steel combs: a bar out of the rock curling into arms.
static func _claw(x: float, y: float, s: float) -> void:
	_r(x - 0.4, y - 0.3, x + 0.4, y + 2.5, RED_ST_D)
	_poly([x - s * 0.4, y + 2.5, x + s * 0.4, y + 2.5, x + s * 2.6, y + 3.6, x + s * 2.6, y + 4.2, x - s * 0.4, y + 3.3], RED_ST_D)
	_poly([x - s * 0.4, y + 2.5, x + s * 0.4, y + 2.5, x + s * 0.4, y + 3.0, x - s * 1.8, y + 4.8, x - s * 2.2, y + 4.4], RED_ST_D)
	_r(x - 0.3, y + 3.0, x + 0.3, y + 5.0, RED_ST_D)

## Burgos Cathedral: the white Gothic west front with its rose window, the two towers ending in openwork spires and
## the crossing's lantern with its pinnacles.
static func _burgos_catedral() -> void:
	_r(-45, 0, 45, 0.6, GREY_D)
	# the lantern over the crossing, behind
	_r(18, 0.6, 40, 36, WHITE_D)
	_r(22, 36, 36, 50, WHITE_D)
	for x in [22.0, 26.5, 31.5, 36.0]:
		_poly([x - 1.0, 50, x + 1.0, 50, x, 58], WHITE_D)
	_windows(23, 35, 40, 47, 3, WIN)
	# the front between the towers
	_r(-12, 0.6, 12, 40, WHITE)
	_pointed(0, 0.6, 7, 12, DARK)
	_c(0, 22, 5, WHITE_D)
	_c(0, 22, 3.6, WIN)
	_r(-12, 30, 12, 31, WHITE_D)
	for k in 6:
		_pointed(-9.0 + k * 3.6, 32, 1.6, 6, WIN)
	for s in [-1, 1]:
		var x: float = s * 17.0
		_r(x - 5.0, 0.6, x + 5.0, 52, WHITE)
		_r(x - 5.5, 52, x + 5.5, 53.2, WHITE_D)
		for y in [12.0, 26.0, 40.0]:
			_pointed(x, y, 2.6, 7, WIN)
		# the openwork spire with its holes and the pinnacles at its foot
		_poly([x - 4.5, 53.2, x + 4.5, 53.2, x, 86], WHITE_D)
		for y in [58.0, 64.0, 70.0, 76.0]:
			var hw: float = 4.5 * (86.0 - y) / 32.8 * 0.4
			_r(x - hw, y, x + hw, y + 2.5, WIN)
		for d in [-5.0, 5.0]:
			_poly([x + d - 0.7, 53.2, x + d + 0.7, 53.2, x + d, 60], WHITE_D)
