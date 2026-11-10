class_name LandmarksChB
extends RefCounted
## Swiss landmarks (St. Gallen to Sion), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const SAND := Color("d8cdb4")
const SAND_D := Color("b5a98d")
const WHITE := Color("f2efe6")
const WHITE_D := Color("d6d1c4")
const GREY := Color("a7a39a")
const GREY_D := Color("85827a")
const ROOF := Color("8c4a32")
const ROOF_D := Color("6e3726")
const RED := Color("b8402f")
const SLATE := Color("5d646b")
const COPPER := Color("6fa58f")
const COPPER_D := Color("558a75")
const GOLD := Color("d9b13b")
const BRONZE := Color("6b5a3a")
const WIN := Color("3a3a40")
const DARK := Color("2b2b30")
const WATER := Color("4f86a8")
const WATER_L := Color("7fb0cc")
const GRASS := Color("6b8f45")
const ROCK := Color("9a8f7a")
const ROCK_D := Color("7a705e")
const PAVE := Color("9a9285")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"ch_st_gallen_kathedrale": _st_gallen_kathedrale()
		"ch_lugano_san_lorenzo": _lugano_san_lorenzo()
		"ch_biel_vennerbrunnen": _biel_vennerbrunnen()
		"ch_thun_schloss": _thun_schloss()
		"ch_fribourg_cathedrale": _fribourg_cathedrale()
		"ch_chur_obertor": _chur_obertor()
		"ch_sion_valere_tourbillon": _sion_valere_tourbillon()
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

## The Abbey Cathedral of St. Gallen: the late Baroque east front with its twin towers, each with a clock and a
## green copper helm of a dome and a lantern, the curved gable between them.
static func _st_gallen_kathedrale() -> void:
	_r(-30, 0, 30, 0.6, PAVE)
	# the long nave stretching to both sides
	_r(-29, 0.6, 29, 20, WHITE)
	_poly([-29.5, 20, 29.5, 20, 26, 25, -26, 25], ROOF)
	for x in [-24.0, -19.0, 19.0, 24.0]:
		_arched(x, 6, 2.6, 9.0, WIN)
	# the curved gable between the towers
	_r(-6, 0.6, 6, 32, WHITE)
	_poly(_arc(0, 32, 6, 5, 0, PI, 10), WHITE)
	_arched(0, 0.6, 3.4, 7.0, DARK)
	_c(0, 30, 1.6, WHITE_D)
	for s in [-1, 1]:
		var x: float = s * 10.0
		_r(x - 4, 0.6, x + 4, 46, WHITE)
		_r(x - 4.3, 20, x + 4.3, 21, WHITE_D)
		_r(x - 4.3, 36, x + 4.3, 37, WHITE_D)
		_arched(x, 8, 2.2, 7.0, WIN)
		_arched(x, 26, 2.2, 7.0, WIN)
		_c(x, 41, 2.4, GOLD)
		_c(x, 41, 2.0, Color("2c4f8a"))
		_r(x - 4.3, 46, x + 4.3, 47, WHITE_D)
		# the onion-like helm, the lantern and the cross
		_poly(_arc(x, 47, 4.2, 7.0, 0, PI, 12), COPPER)
		_r(x - 1.2, 53.5, x + 1.2, 57, COPPER_D)
		_poly([x - 1.6, 57, x + 1.6, 57, x, 62], COPPER)
		_l(x, 62, x, 66, GOLD, 0.3)
		_l(x - 1, 64.5, x + 1, 64.5, GOLD, 0.3)

## The Cathedral of San Lorenzo in Lugano: the white marble Renaissance front on its terrace above the town, the
## three portals, the rose window and the square bell tower behind.
static func _lugano_san_lorenzo() -> void:
	_r(-18, 0, 18, 1.2, PAVE)
	# the bell tower behind on the right
	_r(8, 1.2, 14, 40, SAND)
	_arched(11, 30, 2.4, 6.0, WIN)
	_poly([7.6, 40, 14.4, 40, 11, 45], ROOF)
	# the flat-topped marble front
	_r(-12, 1.2, 12, 28, WHITE)
	_r(-12.4, 14, 12.4, 15, WHITE_D)
	_r(-12.6, 28, 12.6, 29.4, WHITE_D)
	for x in [-12.0, -4.5, 4.5, 12.0]:
		_r(x - 0.5, 1.2, x + 0.5, 28, WHITE_D)
	for x in [-8.2, 0.0, 8.2]:
		_arched(x, 1.2, 3.0 if x != 0.0 else 3.8, 8.0 if x != 0.0 else 9.5, DARK)
	_c(0, 21, 3.4, WHITE_D)
	_c(0, 21, 2.8, WIN)
	_c(0, 21, 0.8, WHITE_D)
	for x in [-8.2, 8.2]:
		_arched(x, 18, 1.8, 5.0, WIN)

## The Banneret Fountain (Vennerbrunnen) in the Ring of Biel's old town: the many-sided stone trough, the column and
## the painted standard-bearer in armour with his banner.
static func _biel_vennerbrunnen() -> void:
	_r(-4, 0, 4, 0.2, PAVE)
	_r(-3.6, 0.2, 3.6, 1.2, GREY)
	_r(-3.8, 1.2, 3.8, 1.45, GREY_D)
	_r(-3.2, 0.4, 3.2, 1.1, WATER)
	_r(-0.35, 1.2, 0.35, 4.6, GREY)
	_r(-0.6, 4.6, 0.6, 5.0, GREY_D)
	# the banneret: legs, armoured body, head and helmet, the banner on its pole
	_r(-0.3, 5.0, -0.08, 6.2, SLATE)
	_r(0.08, 5.0, 0.3, 6.2, SLATE)
	_r(-0.38, 6.2, 0.38, 7.3, Color("8a9298"))
	_r(-0.42, 6.2, 0.42, 6.5, RED)
	_c(0, 7.55, 0.24, Color("e4c7a8"))
	_poly([-0.28, 7.7, 0.28, 7.7, 0, 8.05], Color("8a9298"))
	_l(0.45, 5.0, 0.45, 8.9, BRONZE, 0.07)
	_poly([0.48, 8.9, 2.4, 8.7, 2.3, 7.6, 0.48, 7.8], RED)
	# Biel's arms: two white axes in saltire
	_l(0.85, 7.85, 2.0, 8.6, WHITE, 0.18)
	_l(0.85, 8.65, 2.0, 7.8, WHITE, 0.18)

## Thun Castle: the white keep of the Zähringer on its hill, four round corner towers with pointed red roofs and the
## steep hipped roof between them.
static func _thun_schloss() -> void:
	_poly([-15, 0, 15, 0, 11, 5, -11, 5], GRASS)
	_r(-9, 5, 9, 32, WHITE)
	_windows(-7, 7, 12, 15, 4, WIN)
	_windows(-7, 7, 22, 25, 4, WIN)
	_r(-1.2, 5, 1.2, 8, DARK)
	_poly([-8.6, 32, 8.6, 32, 4.5, 41, -4.5, 41], ROOF)
	for s in [-1, 1]:
		var x: float = s * 9.0
		_r(x - 2, 5, x + 2, 35, WHITE_D)
		_r(x - 0.5, 26, x + 0.5, 28, WIN)
		_poly([x - 2.4, 35, x + 2.4, 35, x, 44.5], RED)

## The Cathedral of St. Nicholas in Fribourg: the Gothic nave and the 74 m west tower with its open belfry storey
## and the flat crown of pinnacles instead of a spire.
static func _fribourg_cathedrale() -> void:
	_r(-18, 0, 18, 0.6, PAVE)
	_r(-2, 0.6, 18, 22, GREY)
	_poly([-2, 22, 18, 22, 18, 28, -2, 28], SLATE)
	for x in [3.0, 9.0, 15.0]:
		_arched(x, 7, 2.4, 10.0, WIN)
	# the tower
	_r(-10, 0.6, 2, 62, GREY)
	_r(-10.4, 22, 2.4, 23, GREY_D)
	_r(-10.4, 42, 2.4, 43, GREY_D)
	_arched(-4, 0.6, 5.0, 10.0, DARK)
	_arched(-4, 26, 3.0, 12.0, WIN)
	# the open octagonal belfry storey
	_r(-9, 43, 1, 66, GREY)
	_arched(-6.2, 47, 2.0, 14.0, WIN)
	_arched(-1.8, 47, 2.0, 14.0, WIN)
	_r(-9.6, 66, 1.6, 67, GREY_D)
	# the crown of pinnacles on the flat top
	for k in 6:
		var x := -9.2 + k * 2.0
		_r(x, 67, x + 0.8, 70.5, GREY)
		_poly([x - 0.1, 70.5, x + 0.9, 70.5, x + 0.4, 74], GREY_D)

## Chur's Obertor: the medieval gate tower of the old town wall, the arch of the passage, the clock and the steep
## roof with its little ridge turret.
static func _chur_obertor() -> void:
	_r(-6, 0, 6, 0.4, PAVE)
	_r(-4.5, 0.4, 4.5, 18, SAND)
	_r(-4.5, 0.4, -3.5, 18, SAND_D)
	_arched(0, 0.4, 4.0, 6.5, DARK)
	_r(-0.6, 9, 0.6, 10.6, WIN)
	_c(0, 14, 1.8, WHITE)
	_c(0, 14, 1.5, Color("2c4f8a"))
	_l(0, 14, 0, 15.2, GOLD, 0.15)
	_l(0, 14, 0.9, 14, GOLD, 0.15)
	_poly([-5, 18, 5, 18, 0, 26], ROOF)
	_r(-0.5, 23, 0.5, 26.5, SLATE)
	_poly([-0.8, 26.5, 0.8, 26.5, 0, 29.5], SLATE)

## Sion's two hills: Tourbillon with the ruined castle walls and keep on the left, Valère with its fortified
## basilica and the bell tower on the right, the vineyards on their slopes.
static func _sion_valere_tourbillon() -> void:
	# the hills
	_poly([-80, 0, -66, 30, -54, 70, -46, 84, -32, 82, -22, 50, -10, 22, 0, 0], ROCK)
	_poly([-10, 0, 6, 26, 18, 52, 30, 62, 46, 60, 60, 36, 80, 0], ROCK_D)
	_poly([-80, 0, -70, 20, 0, 20, -6, 0], GRASS)
	_poly([-6, 0, 2, 16, 72, 16, 80, 0], GRASS)
	# Tourbillon: the ruined curtain wall and the keep
	_r(-46, 82, -32, 90, SAND_D)
	for k in 6:
		_r(-46.0 + k * 2.5, 90, -44.6 + k * 2.5, 92, SAND_D)
	_r(-44, 82, -36, 104, SAND)
	_r(-42, 96, -40, 100, WIN)
	for k in 3:
		_r(-44.0 + k * 3.2, 104, -42.4 + k * 3.2, 106, SAND)
	# Valère: the walls, the basilica's nave and its square bell tower
	_r(22, 52, 50, 70, SAND_D)
	_r(26, 70, 46, 82, SAND)
	_poly([25.5, 82, 46.5, 82, 43, 88, 29, 88], ROOF)
	_r(30, 70, 37, 104, SAND)
	_arched(33.5, 94, 2.4, 6.0, WIN)
	_poly([29.6, 104, 37.4, 104, 33.5, 112], ROOF_D)
	_r(18, 52, 22, 76, SAND_D)
	_poly([17.6, 76, 22.4, 76, 20, 81], ROOF)
