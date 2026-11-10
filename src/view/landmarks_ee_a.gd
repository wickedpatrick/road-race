class_name LandmarksEeA
extends RefCounted
## Estonian landmarks (Tallinn to Kuressaare), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const LIME := Color("c9c2b0") ## grey North Estonian limestone
const LIME_D := Color("a69f8e")
const WHITE := Color("f3f0e8")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const ROOF_D := Color("4a4d52")
const TILE := Color("a4452f")
const TILE_D := Color("7f3424")
const GRASS := Color("5d8f42")
const GRASS_D := Color("4b7a35")
const TREE := Color("3f6f34")
const WATER := Color("4f7fa6")
const BRONZE := Color("6b5a3a")
const BRONZE_L := Color("8a7448")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"ee_tallinn_townhall": _tallinn_townhall()
		"ee_tartu_university": _tartu_university()
		"ee_narva_castle": _narva_castle()
		"ee_parnu_gate": _parnu_gate()
		"ee_kohtla_ash_hills": _kohtla_ash_hills()
		"ee_viljandi_bridge": _viljandi_bridge()
		"ee_rakvere_tarvas": _rakvere_tarvas()
		"ee_kuressaare_castle": _kuressaare_castle()
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

static func _ell(cx: float, cy: float, rx: float, ry: float, rot: float, col: Color) -> void:
	LandmarkPainter._ell(cx, cy, rx, ry, rot, col)

static func _windows(x0: float, x1: float, y0: float, y1: float, n: int, col: Color) -> void:
	LandmarkPainter._windows(x0, x1, y0, y1, n, col)

static func _arc(cx: float, cy: float, rx: float, ry: float, a0: float, a1: float, n: int) -> Array:
	return LandmarkPainter._arc_pts(cx, cy, rx, ry, a0, a1, n)

static func _detail(min_pm: float) -> bool:
	return LandmarkPainter._pm > min_pm

## An arched window or door: a rectangle under a half circle.
static func _arched(x: float, y0: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.5, y0, x + w * 0.5, y0, x + w * 0.5, y0 + h - w * 0.5] + _arc(x, y0 + h - w * 0.5, w * 0.5, w * 0.5, 0, PI, 6), col)

## A pointed (Gothic) window: a rectangle under a pointed top.
static func _pointed(x: float, y0: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.5, y0, x + w * 0.5, y0, x + w * 0.5, y0 + h - w * 0.7, x, y0 + h, x - w * 0.5, y0 + h - w * 0.7], col)

## A row of merlons on top of a wall from x0 to x1 at height y.
static func _merlons(x0: float, x1: float, y: float, h: float, n: int, col: Color) -> void:
	var step := (x1 - x0) / n
	for k in n:
		_r(x0 + step * k + step * 0.15, y, x0 + step * k + step * 0.65, y + h, col)

## Tallinn Town Hall: the long Gothic hall of grey limestone over its open arcade, battlements along the eaves,
## the steep roof, and the slender tower with its Baroque spire and Old Thomas, the watchman weathervane, on top.
static func _tallinn_townhall() -> void:
	# the hall
	_r(-18, 0, 14, 15.5, LIME)
	_r(-18, 0, 14, 0.6, LIME_D)
	# the arcade at street level
	for k in 8:
		_pointed(-15.6 + k * 3.8, 0.6, 2.6, 5.4, Color("54524c"))
	_r(-18, 6.6, 14, 7.2, LIME_D)
	# tall Gothic windows on the upper floor
	for k in 6:
		_pointed(-14.5 + k * 5.2, 8.4, 1.5, 5.2, WIN)
	# battlements and the steep roof behind them
	_poly([-17.5, 15.5, 13.5, 15.5, 11, 25, -15, 25], ROOF_D)
	_r(-18.3, 15.5, 14.3, 16.3, LIME_D)
	_merlons(-18.3, 14.3, 16.3, 1.2, 16, LIME)
	# dragon-head gargoyles under the eaves
	if _detail(1.2):
		for x in [-12.0, -2.0, 8.0]:
			_poly([x, 14.6, x + 1.8, 14.9, x + 1.8, 14.3], Color("2f6f5e"))
	# the tower, square below, octagonal above
	var tx := 9.0
	_r(tx - 3.2, 0, tx + 3.2, 33, LIME)
	_r(tx - 3.2, 0, tx - 2.4, 33, LIME_D)
	_pointed(tx, 18, 1.2, 3, WIN)
	_pointed(tx, 25, 1.2, 3, WIN)
	_r(tx - 3.6, 33, tx + 3.6, 34, LIME_D)
	_r(tx - 2.4, 34, tx + 2.4, 39, LIME)
	_r(tx - 0.8, 34, tx + 0.8, 39, Color("b8b19f"))
	_arched(tx - 1.5, 35, 0.8, 2.6, WIN)
	_arched(tx + 1.5, 35, 0.8, 2.6, WIN)
	# the Baroque spire: a bell, an open lantern, a smaller bell and the needle
	var sp := Color("3f5e55")
	_poly(_arc(tx, 39, 2.6, 4.2, 0, PI, 12), sp)
	_poly([tx - 2.6, 39, tx + 2.6, 39, tx + 1.2, 43.5, tx - 1.2, 43.5], sp)
	_r(tx - 1, 43.5, tx + 1, 46.5, sp)
	_r(tx - 0.4, 44, tx + 0.4, 46, WIN)
	_ell(tx, 47.6, 1.3, 1.4, 0, sp)
	_poly([tx - 0.7, 48.5, tx + 0.7, 48.5, tx, 58], sp)
	_l(tx, 58, tx, 60, DARK, 0.15)
	# Old Thomas: a little soldier with a flag
	var ot := Color("2b2b2b")
	_r(tx - 0.25, 60, tx + 0.25, 61.6, ot)
	_c(tx, 62, 0.35, ot)
	_l(tx + 0.3, 60.5, tx + 0.3, 63.6, ot, 0.1)
	_poly([tx + 0.3, 63.6, tx + 2, 63.2, tx + 0.3, 62.6], ot)

## The University of Tartu main building: a long white Neoclassical front with a portico of six columns and a
## pediment over the middle, three floors of windows either side.
static func _tartu_university() -> void:
	_r(-31, 0, 31, 17, WHITE)
	_r(-31, 0, 31, 1, Color("d8d3c6"))
	_r(-31.5, 16.6, 31.5, 17.6, Color("dcd6c8"))
	_poly([-31.5, 17.6, 31.5, 17.6, 29, 19.5, -29, 19.5], Color("8a8c86"))
	for side in [-1.0, 1.0]:
		var x0: float = 12.0 if side > 0 else -30.0
		var x1: float = 30.0 if side > 0 else -12.0
		_windows(x0, x1, 2.5, 5.2, 6, WIN)
		_windows(x0, x1, 7.2, 10.2, 6, WIN)
		_windows(x0, x1, 12.2, 14.8, 6, WIN)
	# the portico
	_r(-11, 0, 11, 1.6, Color("d8d3c6"))
	_r(-10, 1.6, 10, 15.2, Color("e2ddd0"))
	_windows(-8.5, 8.5, 3, 6, 5, WIN)
	_windows(-8.5, 8.5, 8, 11, 5, WIN)
	for k in 6:
		var x := -9.0 + k * 3.6
		_r(x - 0.65, 1.6, x + 0.65, 15.2, WHITE)
		_r(x - 0.85, 14.8, x + 0.85, 15.4, Color("d8d3c6"))
	_r(-10.6, 15.2, 10.6, 16.4, Color("dcd6c8"))
	_poly([-11.2, 16.4, 11.2, 16.4, 0, 22.5], WHITE)
	_poly([-9, 17, 9, 17, 0, 21.4], Color("e4dfd2"))
	_c(0, 18.8, 0.9, Color("d0c9b8"))
	_l(-11.2, 16.4, 0, 22.5, Color("cfc9b9"), 0.2)
	_l(11.2, 16.4, 0, 22.5, Color("cfc9b9"), 0.2)
	# steps up to the door
	_r(-7, 0, 7, 0.5, Color("bdb7a8"))
	_r(-6, 0.5, 6, 1, Color("c9c3b4"))

## Hermann Castle in Narva: the square convent castle of pale limestone with red roofs, a corner tower on the
## outer wall and Tall Hermann, the 51-metre keep, with its battlements and low pointed roof.
static func _narva_castle() -> void:
	# drawn from x -28.6 to 16.4: moved right by 6 m to stand centred on its base point
	var base: Vector2 = LandmarkPainter._b
	LandmarkPainter._b = base + Vector2(6.0 * LandmarkPainter._pm, 0.0)
	_narva_castle_shape()
	LandmarkPainter._b = base

static func _narva_castle_shape() -> void:
	var wall := Color("d6d0c0")
	var wall_d := Color("b8b1a0")
	# the outer wall with a round corner tower on the left
	_r(-28, 0, 4, 11, wall_d)
	_merlons(-28, 4, 11, 1.1, 14, wall_d)
	_r(-28, 0, -23, 15, wall)
	_poly([-28.6, 15, -22.4, 15, -25.5, 20], TILE)
	# the convent house with its red roof
	_r(-20, 0, 4, 22, wall)
	_r(-20, 0, -19, 22, wall_d)
	_poly([-20.6, 22, 4.6, 22, 2, 28, -18, 28], TILE)
	_poly([-20.6, 22, -18, 28, -18, 22], TILE_D)
	if _detail(0.8):
		for k in 6:
			_r(-17.5 + k * 3.6, 15, -16.9 + k * 3.6, 17.5, WIN)
			_r(-17.5 + k * 3.6, 8, -16.9 + k * 3.6, 10, WIN)
	# Tall Hermann
	_r(4, 0, 16, 46, wall)
	_r(4, 0, 5.2, 46, wall_d)
	_r(3.6, 43, 16.4, 44, wall_d)
	_merlons(3.6, 16.4, 44, 1.4, 6, wall)
	_poly([4.6, 45.4, 15.4, 45.4, 10, 52], TILE)
	_poly([4.6, 45.4, 10, 52, 8, 45.4], TILE_D)
	for y in [12.0, 22.0, 31.0, 38.0]:
		_r(9.5, y, 10.5, y + 2.4, WIN)
	_r(8.5, 0, 11.5, 4, Color("5a4a3a"))
	# the river below
	_r(-28, 0, 16, 0.6, WATER)

## The Tallinn Gate in Pärnu: the Swedish-era gate tunnel through a grassy earth rampart, its white front with
## pilasters and a pediment, the dark arch of the passage.
static func _parnu_gate() -> void:
	_poly([-18, 0, 18, 0, 13, 9, -13, 9], GRASS)
	_poly([-18, 0, -13, 9, -11, 9, -15, 0], GRASS_D)
	for x in [-14.0, 13.0]:
		_c(x, 10.5, 2.2, TREE)
	# the gate front
	_r(-6, 0, 6, 10, WHITE)
	_r(-6, 9.6, 6, 10.4, Color("d9d3c4"))
	_poly([-6.4, 10.4, 6.4, 10.4, 0, 13.6], WHITE)
	_poly([-5, 10.9, 5, 10.9, 0, 12.9], Color("e2dccd"))
	for x in [-5.2, -3.6, 3.6, 5.2]:
		_r(x - 0.4, 0, x + 0.4, 9.6, Color("e6e1d4"))
	_arched(0, 0, 4.4, 7.2, Color("3b3631"))
	_r(-1.6, 0, 1.6, 0.4, Color("8d8a84"))

## The ash hills of Kohtla-Järve: long grey flat-topped heaps of burnt oil shale, scarred with gullies, grass and
## birches creeping up their foot, a power plant chimney behind.
static func _kohtla_ash_hills() -> void:
	var ash := Color("8f908b")
	var ash_l := Color("a6a7a1")
	var ash_d := Color("75766f")
	# the chimney far behind
	_r(30, 0, 32.2, 34, Color("b5b0a6"))
	for y in [26.0, 30.0]:
		_r(30, y, 32.2, y + 1, Color("c0392b"))
	# the back hill
	_poly([-14, 0, 46, 0, 40, 22, 4, 24], ash_d)
	# the front hill with its flat top
	_poly([-48, 0, 26, 0, 18, 26, -34, 28], ash)
	_poly([-34, 28, 18, 26, 16, 27.5, -31, 29.2], ash_l)
	# gullies down the slopes
	if _detail(0.6):
		for k in 7:
			var x := -30.0 + k * 7.0
			_poly([x, 27, x + 1.2, 27, x + 3, 4, x + 1.4, 4], ash_d)
	# grass and birches at the foot
	_poly([-48, 0, 46, 0, 46, 3, 20, 5, -10, 4, -40, 5, -48, 3], GRASS)
	for x in [-42.0, -30.0, -19.0, 2.0, 14.0, 38.0]:
		_r(x - 0.2, 2, x + 0.2, 7, Color("e8e4da"))
		_ell(x, 7.5, 1.6, 2.4, 0, Color("6a9a46"))

## The suspension footbridge in Viljandi: a red bridge slung over a wooded ravine of the castle park, its cables
## sagging between red portals, the ruin of the Order castle's wall on the left bank.
static func _viljandi_bridge() -> void:
	var red := Color("c0392b")
	var red_d := Color("8e2a20")
	# the ravine banks
	_poly([-26, 0, -26, 14, -18, 14, -8, 0], GRASS)
	_poly([26, 0, 26, 14, 18, 14, 8, 0], GRASS)
	_poly([-8, 0, 8, 0, 4, 1.5, -4, 1.5], GRASS_D)
	for x in [-14.0, -10.0, 11.0, 15.0]:
		_c(x, 7 + absf(x) * 0.15, 2.2, TREE)
	# the castle wall ruin
	_poly([-26, 14, -19, 14, -19, 19, -21, 20.5, -23, 18, -26, 21], Color("b8ad98"))
	_arched(-22.5, 14, 1.6, 3.4, Color("5a5146"))
	# the portals
	for x in [-18.0, 18.0]:
		_r(x - 0.4, 14, x + 0.4, 20, red)
		_r(x - 1.6, 14, x - 1.2, 20, red_d)
		_r(x - 1.6, 19.6, x + 0.4, 20.2, red)
	# the deck, with its own slight sag
	_poly([-18, 13.6, 0, 12.4, 18, 13.6, 18, 13.1, 0, 11.9, -18, 13.1], red_d)
	_poly([-18, 14, 0, 12.9, 18, 14, 18, 13.6, 0, 12.4, -18, 13.6], red)
	# the main cables and hangers
	var prev := Vector2(-18, 20)
	for k in range(1, 13):
		var x := -18.0 + k * 3.0
		var y := 20.0 - 5.4 * (1.0 - pow(x / 18.0, 2))
		_l(prev.x, prev.y, x, y, red, 0.18)
		if k < 12:
			_l(x, y, x, 13.0 + 0.0031 * x * x, red, 0.08)
		prev = Vector2(x, y)

## Tarvas in Rakvere: the giant bronze aurochs striding on its rock, head low and long horns swept forward.
static func _rakvere_tarvas() -> void:
	var far := Color("4f4230")
	# the rock, flat on top
	_poly([-4.4, 0, 4.4, 0, 4.1, 0.9, 3.4, 1.5, -3.6, 1.5, -4.2, 0.8], Color("8d8a84"))
	_poly([-4.4, 0, -1.0, 0, -2.0, 0.7, -4.2, 0.8], Color("7a7771"))
	# the far horn and the far legs, darker behind the body
	for seg in [[2.6, 4.5, 2.9, 5.0, 0.26], [2.9, 5.0, 3.4, 5.35, 0.2], [3.4, 5.35, 3.75, 5.75, 0.14]]:
		_l(seg[0], seg[1], seg[2], seg[3], far, seg[4])
	_l(-2.0, 3.0, -2.0, 2.2, far, 0.5)
	_l(-2.0, 2.2, -2.2, 1.5, far, 0.3)
	_l(1.0, 2.7, 0.9, 1.5, far, 0.34)
	# the near legs: the hind leg with its hock, the foreleg striding forward
	_l(-2.8, 3.2, -2.55, 2.3, BRONZE, 0.6)
	_l(-2.55, 2.3, -2.95, 1.5, BRONZE, 0.32)
	_l(1.6, 2.7, 2.0, 2.0, BRONZE, 0.4)
	_l(2.0, 2.0, 2.35, 1.5, BRONZE, 0.32)
	for x in [-2.95, -2.2, 0.9, 2.35]:
		_r(x - 0.2, 1.5, x + 0.2, 1.7, far) # the hooves
	# the body: the rump, the high hump over the shoulders and the heavy head held low
	_poly([-3.75, 3.3, -3.45, 4.2, -2.0, 4.4, -0.5, 4.6, 0.5, 5.15, 1.4, 5.35, 2.1, 5.05, 2.7, 4.55, 3.3, 3.95,
			3.75, 3.2, 3.6, 2.8, 3.15, 2.75, 2.55, 3.15, 1.95, 2.85, 1.5, 2.45, 0.4, 2.55, -0.8, 2.6, -2.2, 2.6,
			-3.25, 2.75], BRONZE)
	_ell(-0.6, 4.15, 2.3, 0.32, 0.1, BRONZE_L) # the light along the back
	_poly([2.45, 4.55, 2.15, 4.85, 2.7, 4.7], far) # the ear
	if _detail(2.0):
		_c(3.05, 4.0, 0.08, DARK)
	# the near horn: out of the poll, forward and then up at the tip
	for seg in [[2.75, 4.35, 3.25, 4.75, 0.3], [3.25, 4.75, 3.85, 4.95, 0.24], [3.85, 4.95, 4.25, 5.25, 0.18],
			[4.25, 5.25, 4.35, 5.7, 0.12]]:
		_l(seg[0], seg[1], seg[2], seg[3], BRONZE_L, seg[4])
	# the tail with its tuft
	_l(-3.6, 3.9, -3.95, 3.0, BRONZE, 0.13)
	_l(-3.95, 3.0, -3.9, 2.4, BRONZE, 0.12)
	_ell(-3.9, 2.2, 0.16, 0.3, 0, far)

## Kuressaare Castle: the square dolomite convent castle on its star-shaped ramparts behind the moat, the slim
## watchtower Tall Hermann at one corner and the broad defence tower at the other.
static func _kuressaare_castle() -> void:
	var dol := Color("ddd5c1")
	var dol_d := Color("bfb6a0")
	# the moat and the rampart
	_r(-30, 0, 30, 1.4, WATER)
	_poly([-30, 1.4, 30, 1.4, 26, 6, -26, 6], GRASS)
	_poly([-30, 1.4, -26, 6, -22, 6, -24, 1.4], GRASS_D)
	# the main block
	_r(-17, 6, 13, 24, dol)
	_r(-17, 6, -15.8, 24, dol_d)
	_poly([-17.4, 24, 13.4, 24, 11, 27, -15, 27], Color("6b6862"))
	if _detail(0.8):
		for k in 7:
			_pointed(-13 + k * 3.8, 15, 0.8, 2.6, WIN)
			_r(-13.3 + k * 3.8, 9, -12.7 + k * 3.8, 11, WIN)
	_arched(-1, 6, 2.2, 4, Color("4a4038"))
	# Tall Hermann, the slim watchtower
	_r(-21, 6, -15, 30, dol)
	_r(-21, 6, -20, 30, dol_d)
	_r(-21.4, 29, -14.6, 30, dol_d)
	_poly([-21.4, 30, -14.6, 30, -18, 32], Color("6b6862"))
	_r(-18.4, 21, -17.6, 23.5, WIN)
	# the defence tower, broad and lower
	_r(12, 6, 20, 27, dol)
	_r(12, 6, 13.2, 27, dol_d)
	_merlons(11.6, 20.4, 27, 1, 5, dol)
	_r(15.6, 18, 16.4, 20.5, WIN)
