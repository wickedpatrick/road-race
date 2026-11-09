class_name LandmarksLvB
extends RefCounted
## Latvian landmarks (Jēkabpils to Salacgrīva), drawn with LandmarkPainter's helpers (metres from the base point,
## y up).

const WHITE := Color("f3f0e8")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const GRASS := Color("5d8f42")
const TREE := Color("3f6f34")
const GOLD := Color("e0b43a")
const RED_ROOF := Color("a5452f")
const RED_ROOF_D := Color("7f3424")
const WATER := Color("4f7f9e")
const WATER_D := Color("3d6886")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"lv_jekabpils_krustpils": _jekabpils_krustpils()
		"lv_cesis_castle": _cesis_castle()
		"lv_kuldiga_rumba": _kuldiga_rumba()
		"lv_sigulda_turaida": _sigulda_turaida()
		"lv_talsi_hills": _talsi_hills()
		"lv_bauska_rundale": _bauska_rundale()
		"lv_salacgriva_weir": _salacgriva_weir()
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

## An arched window or door: a rectangle under a half circle.
static func _arched(x: float, y0: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.5, y0, x + w * 0.5, y0, x + w * 0.5, y0 + h - w * 0.5] + _arc(x, y0 + h - w * 0.5, w * 0.5, w * 0.5, 0, PI, 6), col)

## A row of merlons on top of a wall from x0 to x1 at height y.
static func _merlons(x0: float, x1: float, y: float, h: float, n: int, col: Color) -> void:
	var step := (x1 - x0) / n
	for k in n:
		_r(x0 + step * k + step * 0.15, y, x0 + step * k + step * 0.65, y + h, col)

## Krustpils Castle in Jēkabpils: a pale two-storey house under a red hipped roof, rebuilt many times, with its square
## tower and a low wing, on the green bank of the Daugava.
static func _jekabpils_krustpils() -> void:
	var wall := Color("ece4d0")
	var wall_d := Color("d6ccb4")
	_r(-22, 0, 22, 1.2, GRASS)
	# the low wing on the right
	_r(10, 1.2, 21, 8, wall)
	_poly([9.5, 8, 21.5, 8, 19.5, 10.5, 11.5, 10.5], RED_ROOF)
	_windows(11, 20.5, 3.5, 6, 4, WIN)
	# the main house
	_r(-19, 1.2, 6, 13, wall)
	_poly([-19.5, 13, 6.5, 13, 3.5, 18, -16.5, 18], RED_ROOF)
	_l(-16.5, 18, 3.5, 18, RED_ROOF_D, 0.25)
	_windows(-18, 5, 3.5, 6.2, 8, WIN)
	_windows(-18, 5, 8.5, 11.2, 8, WIN)
	_r(-8, 1.2, -5, 5.5, Color("6b5040"))
	# the tower
	_r(4, 1.2, 11, 21, wall_d)
	_windows(5, 10, 14, 17, 2, WIN)
	_windows(5, 10, 8, 11, 2, WIN)
	_r(3.6, 20.6, 11.4, 21.4, wall)
	_poly([3.6, 21.4, 11.4, 21.4, 7.5, 25.6], RED_ROOF)
	_l(7.5, 25.6, 7.5, 26, DARK, 0.1)

## Cēsis Castle: the grey stone ruins of the Order's castle, the tall round west tower with merlons, broken walls and
## the square Lademacher tower, the light New Castle with its tower beside them.
static func _cesis_castle() -> void:
	var stone := Color("8f8a7e")
	var stone_d := Color("756f63")
	_poly([-25, 0, 25, 0, 25, 2, -25, 3], GRASS)
	# the New Castle on the right
	var manor := Color("e6d6c0")
	_r(11, 2, 24.5, 11, manor)
	_poly([10.5, 11, 25, 11, 23, 13.5, 12.5, 13.5], RED_ROOF)
	_windows(12, 24, 4, 6.5, 5, WIN)
	_windows(12, 24, 8, 10, 5, WIN)
	_r(18, 2, 22, 17, manor)
	_poly([17.6, 17, 22.4, 17, 20, 20], RED_ROOF)
	_windows(18.6, 21.4, 13.5, 15.5, 1, WIN)
	# the ruined walls: a jagged top line
	_poly([-14, 2.6, 9, 2, 9, 9, 7, 11, 5, 9.5, 2, 13, -1, 11.5, -3, 14, -6, 12, -9, 15, -11, 12.5, -14, 14], stone)
	for x in [-9.0, -3.0, 3.0]:
		_arched(x, 4, 1.6, 4.5, Color("3b3631"))
	# the square Lademacher tower
	_poly([1, 2.2, 8, 2.1, 8, 19, 6.5, 20.5, 4.5, 18.5, 2.5, 20, 1, 19], stone_d)
	_r(3.6, 12, 5.2, 14.5, Color("3b3631"))
	# the round west tower
	_r(-21, 2.8, -13, 22.5, stone)
	_r(-21, 2.8, -19.8, 22.5, stone_d)
	_r(-21.6, 22.5, -12.4, 23.4, stone_d)
	_merlons(-21.6, -12.4, 23.4, 1.8, 5, stone_d)
	_r(-17.8, 13, -16.2, 15.5, Color("3b3631"))
	_r(-17.8, 7, -16.2, 9.5, Color("3b3631"))

## The Venta Rapid in Kuldīga: the river spilling over a low ledge the whole width of the picture, white foam below
## it, and the long red-brick road bridge of 1874 on its arches behind.
static func _kuldiga_rumba() -> void:
	# the far bank and the bridge
	_r(-35, 4, 35, 6, Color("6f9a52"))
	var brick := Color("a14a34")
	_r(-35, 9.5, 35, 12, brick)
	_r(-35, 12, 35, 12.6, Color("8a3e2b"))
	for k in 7:
		var x0 := -35.0 + k * 10.0
		var x1 := x0 + 10.0
		_poly([x0, 4, x0 + 1.4, 4] + _arc(x0 + 5.0, 6.8, 3.6, 2.4, PI, 0, 8) + [x1 - 1.4, 4, x1, 4, x1, 9.6, x0, 9.6], brick)
	if _detail(1.0):
		for k in 70:
			var x := -35.0 + k
			_l(x, 12.6, x, 13.6, Color("6b2f22"), 0.08)
	_l(-35, 13.6, 35, 13.6, Color("6b2f22"), 0.15)
	# the river above the falls
	_r(-35, 2.6, 35, 4.6, WATER)
	_l(-35, 3.8, 35, 3.8, Color("6a97b4"), 0.12)
	# the ledge and the falling water
	_r(-35, 1.3, 35, 2.6, Color("e9f1f2"))
	if _detail(0.6):
		for k in 35:
			var x := -34.5 + k * 2.0
			_l(x, 2.6, x + 0.3, 1.4, Color("bcd2da"), 0.18)
	# the foam and the river below
	_r(-35, 0, 35, 1.3, WATER_D)
	for k in 14:
		var x := -33.0 + k * 5.0
		_c(x, 1.2, 0.75, Color("f6fafa"))

## Turaida Castle above the Gauja valley: red-brick walls on a green hill, the round main tower with its dark roof and
## the half-round south tower.
static func _sigulda_turaida() -> void:
	var brick := Color("b0503a")
	var brick_d := Color("8c3d2c")
	# the hill and the woods
	_poly([-20, 0, 20, 0, 20, 4, 12, 7, -10, 7.5, -20, 3.5], GRASS)
	for x in [-18.0, -15.5, 15.0, 17.8]:
		_c(x, 5.5, 2.0, TREE)
	# the walls
	_r(-14, 7, 13, 13.5, brick)
	_merlons(-14, -5, 13.5, 1.2, 6, brick)
	_merlons(5, 13, 13.5, 1.2, 5, brick)
	_r(-14, 7, 13, 8, brick_d)
	# the half-round south tower on the right
	_r(9, 7, 16, 21, brick)
	_r(9, 7, 10.2, 21, brick_d)
	_poly([8.5, 21, 16.5, 21, 12.5, 25], Color("4a3a32"))
	_r(11.8, 14, 13.2, 16.5, Color("3b2a24"))
	# the round main tower
	_r(-4.5, 7, 4.5, 35, brick)
	_r(-4.5, 7, -3, 35, brick_d)
	_r(2.6, 7, 4.5, 35, Color("c25e45"))
	for y in [15.0, 22.0, 29.0]:
		_r(-0.7, y, 0.7, y + 2.2, Color("3b2a24"))
	_r(-5, 35, 5, 35.8, brick_d)
	_poly([-5.2, 35.8, 5.2, 35.8, 0, 41.5], Color("4a3a32"))
	_l(0, 41.5, 0, 42, DARK, 0.1)

## Talsi on its hills: green hills round a lake, red roofs on the slopes and the white church with its tower and spire on
## Church Hill.
static func _talsi_hills() -> void:
	# the lake in front
	_poly([-30, 0, 4, 0, 0, 3, -26, 3.4], WATER)
	_l(-24, 1.6, -6, 1.6, Color("7aa6c0"), 0.15)
	# the hills
	var hill := Color("6a9a4c")
	var hill_d := Color("5a8a40")
	_poly(_arc(-20, 3.4, 10, 7, PI, 0, 10), hill_d)
	_poly([18, 0, 30, 0, 30, 9] + _arc(24, 3, 7, 8, 0.8, PI, 8), hill_d)
	_poly(_arc(2, 0, 16, 13, PI, 0, 14), hill)
	# red roofs on the slopes
	for h in [[-22.0, 7.5], [-17.0, 8.6], [-9.0, 6.0], [10.0, 7.6], [14.0, 4.2], [22.0, 9.0]]:
		var x: float = h[0]
		var y: float = h[1]
		_r(x - 1.4, y - 0.4, x + 1.4, y + 1.4, Color("efe6d4"))
		_poly([x - 1.8, y + 1.4, x + 1.8, y + 1.4, x, y + 2.8], RED_ROOF)
	# the church on the top
	_r(-6, 10.5, 3, 17.5, WHITE)
	_poly([-6.5, 17.5, 3.5, 17.5, 1.5, 20.5, -4.5, 20.5], RED_ROOF)
	for x in [-4.0, -1.5, 1.0]:
		_r(x - 0.4, 13.5, x + 0.4, 16, WIN)
	_r(3, 10.5, 6.5, 23, WHITE)
	_r(4.2, 19, 5.3, 21, WIN)
	_poly([2.8, 23, 6.7, 23, 4.75, 29.4], Color("3a4a44"))
	_l(4.75, 29.4, 4.75, 30, GOLD, 0.12)

## Rundāle Palace: the long Baroque front in pale ochre with white pilasters, the higher central block with its
## pediment and balcony, the wings either side, under a dark roof.
static func _bauska_rundale() -> void:
	var ochre := Color("efdca5")
	var ochre_d := Color("dcc58a")
	var roof := Color("5b5f5a")
	_r(-40, 0, 40, 1, Color("c8c2b0"))
	# the wings
	for s in [-1.0, 1.0]:
		var x0: float = 15.0 * s
		var x1: float = 38.5 * s
		_r(minf(x0, x1), 1, maxf(x0, x1), 14, ochre)
		_poly([minf(x0, x1) - 0.5, 14, maxf(x0, x1) + 0.5, 14, maxf(x0, x1) - 1.5, 18, minf(x0, x1) + 1.5, 18], roof)
		_windows(minf(x0, x1) + 1, maxf(x0, x1) - 1, 3, 6.5, 8, WIN)
		_windows(minf(x0, x1) + 1, maxf(x0, x1) - 1, 8.5, 12, 8, WIN)
		# the corner pavilion at the end of the wing
		var px: float = 35.0 * s
		_r(px - 4, 1, px + 4, 15.5, ochre_d)
		_poly([px - 4.4, 15.5, px + 4.4, 15.5, px, 19.5], roof)
	# the central block
	_r(-15, 1, 15, 17, ochre)
	_poly([-15.5, 17, 15.5, 17, 13, 22, -13, 22], roof)
	_windows(-14, 14, 3, 7, 8, WIN)
	_windows(-14, 14, 9.5, 14.5, 8, WIN)
	# its higher middle bay with the pediment
	_r(-6, 1, 6, 19, ochre_d)
	_poly([-6.6, 19, 6.6, 19, 0, 23.6], ochre_d)
	_poly([-5, 19.6, 5, 19.6, 0, 22.8], ochre)
	_c(0, 21, 0.9, GOLD)
	_arched(0, 1, 2.6, 5, Color("5b4636"))
	_windows(-5, 5, 9.5, 15, 3, WIN)
	_r(-4.5, 8.2, 4.5, 8.8, Color("8a8f86"))
	for x in [-14.5, -6.0, -2.2, 2.2, 6.0, 14.5]:
		_r(x - 0.35, 1, x + 0.35, 16.6, WHITE)
	# the chimneys
	for x in [-10.0, 10.0]:
		_r(x - 0.5, 21, x + 0.5, 23.5, Color("cfc5b0"))

## A lamprey weir on the Salaca: a row of posts across the river, the plank walkway on top, the funnel traps hanging
## between the posts and the water rushing through.
static func _salacgriva_weir() -> void:
	_r(-20, 0, 20, 3, WATER)
	_l(-20, 1.6, 20, 1.6, Color("7aa6c0"), 0.15)
	var wood := Color("7a5a3a")
	var wood_l := Color("9a7650")
	# the posts and the walkway
	for k in 11:
		var x := -18.0 + k * 3.6
		_l(x, 0, x, 7.4, wood, 0.32)
		if k < 10: _l(x, 1.2, x + 1.8, 6.6, wood_l, 0.16)
	_r(-19.5, 6.6, 19.5, 7.4, wood_l)
	_l(-18.8, 8.5, 18.8, 8.5, wood, 0.12)
	for k in 6:
		var x := -18.0 + k * 7.2
		_l(x, 7.4, x, 8.5, wood, 0.14)
	# the funnel traps between the posts
	var trap := Color("b49460")
	for k in 10:
		var x := -16.2 + k * 3.6
		_poly([x - 1.2, 5.4, x + 1.2, 5.4, x + 0.2, 1.4, x - 0.2, 1.4], trap)
		if _detail(1.5):
			_l(x - 0.9, 4.2, x + 0.9, 4.2, wood, 0.06)
			_l(x - 0.6, 3.0, x + 0.6, 3.0, wood, 0.06)
	# the foam below the weir
	for k in 12:
		_c(-19.0 + k * 3.4, 0.5, 0.5, Color("e8f2f4"))
