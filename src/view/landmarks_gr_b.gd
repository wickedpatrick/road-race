class_name LandmarksGrB
extends RefCounted
## Greek landmarks (Kalamata to Meteora), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const MARBLE := Color("ece4d2")
const MARBLE_D := Color("cfc3a6")
const LIME := Color("f4f1e8")
const STONE := Color("d9c9a3")
const STONE_D := Color("b5a27a")
const ROCK := Color("a89277")
const ROOF := Color("c25a35")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const WATER := Color("2f86b8")
const WATER_L := Color("8ccbe8")
const TURQUOISE := Color("3fc1c9")
const GRASS := Color("8a9a4a")
const OLIVE := Color("6f7f45")
const CYPRESS := Color("3d5a32")
const WOOD := Color("7a5636")
const BRONZE := Color("8a6a3a")
const GOLD := Color("e0b43a")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"kalamata_olive_harvest": _olive_harvest()
		"alexandroupoli_lighthouse": _alexandroupoli_lighthouse()
		"kavala_kamares": _kamares()
		"leonidas_thermopylae": _leonidas()
		"rethymno_fortezza": _fortezza()
		"corinth_canal": _corinth_canal()
		"olympia_flame": _olympia_flame()
		"nafplio_bourtzi": _bourtzi()
		"mystras_palace": _mystras()
		"syvota_bays": _syvota()
		"meteora_monastery": _meteora()
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

## An arched opening (round top) from y0 up to the spring line y1.
static func _archway(x: float, hw: float, y0: float, y1: float, col: Color) -> void:
	_poly([x + hw, y0, x + hw, y1] + _arc(x, y1, hw, hw, 0, PI, 6) + [x - hw, y0], col)

## A band of sea up to y with lighter wave crests.
static func _sea(x0: float, x1: float, y: float, col := WATER) -> void:
	_r(x0, 0, x1, y, col)
	if _detail(1.0):
		var x := x0 + 2.0
		while x < x1 - 3.0:
			_l(x, y * 0.5, x + 2.5, y * 0.5, WATER_L, 0.15)
			x += 7.0

## Battlements: merlons of width w along y from x0 to x1.
static func _merlons(x0: float, x1: float, y: float, w: float, h: float, col: Color) -> void:
	var x := x0
	while x + w <= x1 + 0.01:
		_r(x, y, x + w, y + h, col)
		x += w * 2.0

## A cypress: a narrow dark flame.
static func _cypress(x: float, y: float, h: float) -> void:
	_poly([x - h * 0.09, y, x + h * 0.09, y, x + h * 0.11, y + h * 0.45, x, y + h, x - h * 0.11, y + h * 0.45], CYPRESS)

## A small Byzantine church: a block, a drum and a red-tiled dome, brick-banded walls.
static func _byz_church(x: float, y: float, s: float) -> void:
	var wall := Color("c9a57a")
	_r(x - 3 * s, y, x + 3 * s, y + 3.4 * s, wall)
	_poly([x - 3.4 * s, y + 3.4 * s, x + 3.4 * s, y + 3.4 * s, x, y + 4.6 * s], ROOF)
	_r(x - 1.2 * s, y + 3.6 * s, x + 1.2 * s, y + 5.4 * s, wall)
	_poly(_arc(x, y + 5.4 * s, 1.3 * s, 1.1 * s, 0, PI, 8), ROOF)
	if _detail(1.5):
		_r(x - 3 * s, y + 1.6 * s, x + 3 * s, y + 1.8 * s, Color("a5452f"))
		_archway(x, 0.5 * s, y, y + 1.4 * s, WIN)

## The olive harvest near Kalamata: an old twisted olive tree with a silvery crown full of dark olives, green nets
## spread on the ground, a ladder and crates of black Kalamata olives.
static func _olive_harvest() -> void:
	_r(-15, 0, 15, 0.6, Color("b59a68"))
	# the nets
	_poly([-14, 0.6, 14, 0.6, 12, 1.4, -12, 1.4], Color("3f9a52"))
	# the twisted trunk
	var trunk := Color("6b5a44")
	_poly([-1.8, 1, 1.6, 1, 1.0, 3.2, 1.8, 5.6, 0.6, 6.2, -0.2, 4.6, -1.0, 6.4, -2.0, 5.8, -0.8, 3.4], trunk)
	_l(0.8, 5.6, 4.0, 8.0, trunk, 0.4)
	_l(-1.2, 6.0, -4.4, 8.2, trunk, 0.4)
	# the silvery crown
	var leaf := Color("8b9a6a")
	for p in [[-6.0, 8.6, 3.2], [-2.0, 10.4, 3.6], [2.6, 10.0, 3.4], [6.0, 8.4, 3.0], [0.0, 7.6, 3.2]]:
		_c(p[0], p[1], p[2], leaf)
	for p in [[-5.0, 9.6, 1.6], [1.5, 11.5, 1.8], [5.0, 9.4, 1.4]]:
		_c(p[0], p[1], p[2], Color("a7b38a"))
	if _detail(2.0):
		for k in 22:
			var a := k * 2.4
			_c(cos(a) * (2.0 + k % 6), 9.0 + sin(a) * 2.6, 0.22, Color("2e2233"))
	# a ladder and crates
	_l(8.6, 0.6, 6.6, 8.0, WOOD, 0.18)
	_l(9.6, 0.6, 7.6, 8.0, WOOD, 0.18)
	for k in 6:
		var t := (k + 0.5) / 6.0
		_l(8.6 - 2.0 * t, 0.6 + 7.4 * t, 9.6 - 2.0 * t, 0.6 + 7.4 * t, WOOD, 0.12)
	for x in [-11.0, -8.6]:
		_r(x - 1.0, 0.6, x + 1.0, 2.0, Color("c08a4a"))
		_r(x - 0.9, 1.6, x + 0.9, 2.0, Color("2e2233"))

## The lighthouse of Alexandroupolis: a white round stone tower with a gallery and a black lantern, standing on the
## seafront promenade with its lamp posts, the sea beside it.
static func _alexandroupoli_lighthouse() -> void:
	_sea(-10, 10, 1.4)
	_r(-10, 0, 10, 1.6, Color("cfc7b3"))
	# the tower
	_poly([-3.4, 1.6, 3.4, 1.6, 2.4, 24, -2.4, 24], LIME)
	_poly([2.0, 1.6, 3.4, 1.6, 2.4, 24, 1.6, 24], Color("dcd8cc"))
	for k in 3:
		_r(-0.4, 6.0 + k * 5.5, 0.4, 7.4 + k * 5.5, WIN)
	_archway(0, 0.8, 1.6, 3.4, DARK)
	# the gallery and lantern
	_r(-3.4, 24, 3.4, 25, Color("dcd8cc"))
	_l(-3.2, 26.2, 3.2, 26.2, DARK, 0.12)
	_r(-1.6, 25, 1.6, 28.4, Color("ffe9a3"))
	if _detail(2.0):
		for x in [-0.8, 0.0, 0.8]:
			_l(x, 25, x, 28.4, DARK, 0.08)
	_poly([-2.0, 28.4, 2.0, 28.4, 0, 31], DARK)
	_c(0, 31.3, 0.4, DARK)
	# lamp posts on the promenade
	for x in [-8.0, 7.5]:
		_l(x, 1.6, x, 6, DARK, 0.15)
		_c(x, 6.2, 0.4, Color("fff4c8"))

## Kavala's Kamares: the Ottoman aqueduct, two tiers of tall arches across the town, the fortress on the hill of the
## old town behind it, red roofs below.
static func _kamares() -> void:
	# the old town hill and the fortress
	_poly([4, 0, 12, 14, 22, 20, 34, 16, 40, 0], Color("9a8a68"))
	_r(18, 18, 32, 23, STONE_D)
	_merlons(18, 32, 23, 1.0, 1.0, STONE_D)
	_r(22, 23, 26, 27, STONE_D)
	_merlons(22, 26, 27, 0.8, 0.8, STONE_D)
	# houses below
	for k in 6:
		var x := -36.0 + k * 13.0
		_r(x, 0, x + 6, 4.2, LIME)
		_poly([x - 0.4, 4.2, x + 6.4, 4.2, x + 3, 6], ROOF)
	# the aqueduct: an upper tier of small arches over a lower tier of tall ones
	var stone := Color("c7b48a")
	var top := 25.0
	_r(-40, top - 2.6, 26, top, stone)
	_r(-40, 0, 26, 15, stone)
	for k in 7:
		var x := -35.5 + k * 9.0
		_archway(x, 2.9, 0, 11, Color("9fc6e6"))
	_r(-40, 15, 26, top - 2.6, stone)
	for k in 14:
		var x := -37.5 + k * 4.5
		_archway(x, 1.4, 15.4, 20.8, Color("9fc6e6"))
	if _detail(1.5):
		_l(-40, 15, 26, 15, stone.darkened(0.2), 0.2)

## The Leonidas monument at Thermopylae: the bronze king with helmet, round shield and raised spear on a stone
## pedestal, the words ΜΟΛΩΝ ΛΑΒΕ below him.
static func _leonidas() -> void:
	_r(-10, 0, 10, 1.0, MARBLE_D)
	_r(-4, 1.0, 4, 6.0, MARBLE)
	_r(-4.6, 5.6, 4.6, 6.4, MARBLE_D)
	if _detail(2.5):
		_r(-3.0, 2.8, 3.0, 3.4, BRONZE)
	# the statue
	var b := BRONZE
	_l(-0.6, 6.4, -1.0, 9.2, b, 0.55)
	_l(0.6, 6.4, 1.2, 9.2, b, 0.55)
	_poly([-1.4, 9.0, 1.4, 9.0, 1.2, 12.2, -1.2, 12.2], b)
	_c(0, 13.0, 0.75, b)
	_poly([-0.8, 13.4, 0.8, 13.4, 0.9, 14.2, 0, 15.2, -0.9, 14.2], b.darkened(0.15))
	_l(-0.2, 15.0, -1.4, 13.6, Color("9b2a1f"), 0.2) # the crest
	# the raised spear and the shield
	_l(1.2, 12, 2.8, 14.6, b, 0.35)
	_l(3.0, 8.0, 2.4, 17.6, Color("5a4a2e"), 0.18)
	_poly([2.1, 17.6, 2.7, 17.6, 2.4, 18.8], b)
	_c(-2.0, 10.6, 1.9, b.darkened(0.1))
	_c(-2.0, 10.6, 1.4, b)
	if _detail(2.0):
		_poly([-2.6, 9.6, -1.4, 9.6, -2.0, 11.8], Color("c0a060"))
	# laurel shrubs
	for x in [-8.0, 8.0]:
		_c(x, 2.2, 1.6, OLIVE)

## Rethymno's Fortezza: angular Venetian bastions on the headland above the sea, the long walls, and inside the
## mosque of Ibrahim Han with its big dome.
static func _fortezza() -> void:
	_poly([-40, 0, -36, 6, -20, 10, 24, 10, 36, 6, 40, 0], ROCK)
	_sea(-40, -28, 2.4)
	_sea(30, 40, 2.4)
	var wall := Color("d2bb8a")
	_poly([-30, 10, -26, 18, 22, 18, 28, 10], wall)
	_poly([-32, 10, -30, 20, -24, 20, -24, 10], wall.darkened(0.08)) # a bastion's point
	_poly([20, 10, 20, 20, 27, 20, 30, 10], wall.darkened(0.08))
	_r(-30, 20, -24, 21, STONE_D)
	_r(20, 20, 27, 21, STONE_D)
	if _detail(1.5):
		_l(-26, 14, 22, 14, wall.darkened(0.15), 0.2)
		_archway(-6, 1.2, 10, 13, DARK)
	# the mosque and its dome
	_r(-2, 18, 12, 24, LIME)
	_poly(_arc(5, 24, 6, 5.6, 0, PI, 12), Color("c9c4b8"))
	_c(5, 29.8, 0.4, GOLD)
	for x in [1.0, 9.0]:
		_archway(x, 0.7, 19.5, 22, WIN)
	# a stump of a minaret and a small church
	_r(-14, 18, -12.4, 24, LIME)
	_r(-22, 18, -17, 21.4, LIME)
	_poly([-22.4, 21.4, -16.6, 21.4, -19.5, 23], ROOF)

## The Corinth Canal, seen from the bridge along the cut: sheer layered rock walls 80 m deep on both sides, the
## narrow strip of blue water running away to the far end, a small ship towed by a tug down in the gorge.
static func _corinth_canal() -> void:
	var rock := Color("c9a46c")
	var rock_d := Color("a5824e")
	var vy := 24.0 # the far end of the cut, where the walls meet the water
	# the land on both sides, its rims sloping down to the far end
	_poly([-35, 0, -35, 34, -12, 30, -1.2, vy, -8, 0], rock)
	_poly([35, 0, 35, 34, 12, 30, 1.2, vy, 8, 0], rock_d)
	_poly([-35, 34, -12, 30, -1.2, vy, 1.2, vy, 12, 30, 35, 34, 35, 36, -35, 36], Color("8a9a4a"))
	# the strata of the walls
	if _detail(1.0):
		for k in 6:
			var t := (k + 1) / 7.0
			_l(-8.0 + 6.8 * t, vy * t, -35, 34 * t + 2, rock_d, 0.25)
			_l(8.0 - 6.8 * t, vy * t, 35, 34 * t + 2, rock.darkened(0.3), 0.25)
	# the water, wide below and narrowing away
	_poly([-8, 0, 8, 0, 1.2, vy, -1.2, vy], WATER)
	_poly([-2.5, 0, 2.5, 0, 0.4, vy, -0.4, vy], Color("3d9ac8"))
	# a ship towed by a tug down in the gorge
	var y := 6.0
	_poly([-2.0, y, 2.0, y, 1.6, y - 1.0, -1.6, y - 1.0], LIME)
	_r(-1.0, y, 1.0, y + 1.6, LIME)
	_r(-0.25, y + 1.6, 0.25, y + 2.4, Color("b3261e"))
	_poly([-0.6, 13.6, 0.6, 13.6, 0.45, 13.0, -0.45, 13.0], DARK) # the tug ahead
	_r(-0.22, 13.6, 0.22, 14.2, Color("e04030"))

## The lighting of the Olympic flame at Olympia: the Doric columns of the Temple of Hera, a priestess in white
## kneeling at the parabolic mirror, the flame rising from it and a torch in the hand of another.
static func _olympia_flame() -> void:
	_r(-25, 0, 25, 1.2, MARBLE_D)
	# the ruined temple: a row of columns of different heights
	var hs := [10.0, 7.0, 10.0, 4.0, 8.5, 10.0, 2.0, 10.0]
	for k in 8:
		var x := -21.0 + k * 6.0
		_r(x - 0.9, 1.2, x + 0.9, 1.2 + hs[k], Color("d8c9a6"))
		if hs[k] >= 10.0:
			_r(x - 1.3, 10.6, x + 1.3, 11.2, Color("bfae88"))
	_r(-22.4, 11.2, -13.6, 12.4, Color("d8c9a6"))
	# the mirror on its stand and the flame
	_r(-0.5, 1.2, 0.5, 2.6, DARK)
	_poly(_arc(0, 4.0, 2.6, 1.6, PI, TAU, 10), Color("c9cdd2"))
	_poly([-0.8, 4.0, 0.8, 4.0, 1.0, 5.8, 0, 8.4, -0.9, 6.0], Color("ff9a2e"))
	_poly([-0.4, 4.0, 0.4, 4.0, 0.45, 5.4, 0, 6.6, -0.45, 5.4], Color("ffe066"))
	# the priestesses in white chitons, one kneeling at the mirror, one holding the torch
	for kneel in [true, false]:
		var x := -4.4 if kneel else 5.6
		var h := 4.4 if kneel else 6.6
		_poly([x - 1.3, 1.2, x + 1.3, 1.2, x + 0.7, 1.2 + h, x - 0.7, 1.2 + h], Color("f7f4ec"))
		_c(x, 1.9 + h, 0.7, Color("d9a882"))
		_l(x - 0.7, 2.2 + h, x + 0.7, 2.2 + h, Color("4d3b2a"), 0.35)
		if kneel:
			_l(x + 0.6, 4.4, x + 2.2, 4.4, Color("d9a882"), 0.25)
		else:
			_l(x + 0.6, h, x + 2.0, h + 2.2, Color("c0a060"), 0.3)
			_poly([x + 1.6, h + 2.2, x + 2.4, h + 2.2, x + 2.0, h + 3.8], Color("ff9a2e"))

## Nafplio: the little Venetian castle of Bourtzi on its islet in the harbour, an octagonal tower with battlements,
## and on the steep hill behind the Palamidi fortress with the long stair zig-zagging up.
static func _bourtzi() -> void:
	# Palamidi hill and fortress
	_poly([4, 0, 12, 18, 24, 32, 34, 30, 40, 18, 40, 0], Color("9a8a68"))
	_r(18, 28, 36, 32, STONE_D)
	_merlons(18, 36, 32, 1.0, 1.0, STONE_D)
	if _detail(1.2):
		var pts := [[12.0, 6.0], [20.0, 10.0], [14.0, 14.0], [22.0, 19.0], [18.0, 23.0], [24.0, 28.0]]
		for k in pts.size() - 1:
			_l(pts[k][0], pts[k][1], pts[k + 1][0], pts[k + 1][1], LIME, 0.25)
	_sea(-40, 40, 3.2)
	# the islet and Bourtzi
	_poly([-30, 2.4, -10, 2.4, -12, 4.2, -28, 4.2], ROCK)
	var st := Color("d9c08e")
	_r(-27, 4.2, -13, 10, st)
	_merlons(-27, -13, 10, 1.0, 1.0, st)
	_r(-23, 10, -17, 17, st)
	_merlons(-23, -17, 17, 0.9, 0.9, st)
	_r(-21, 17.9, -19, 20, st)
	_r(-20.4, 20, -19.6, 22, DARK)
	if _detail(1.5):
		_archway(-20, 0.7, 11, 13.5, WIN)
		_archway(-24, 0.6, 5, 7, WIN)
		_archway(-16, 0.6, 5, 7, WIN)

## Mystras: the Byzantine town climbing the side of the Taygetus, domed churches and the long Palace of the
## Despots with its arched windows, and the Frankish castle on the summit.
static func _mystras() -> void:
	_poly([-40, 0, -30, 12, -16, 26, -4, 40, 4, 44, 12, 38, 26, 22, 40, 10, 40, 0], Color("7f8a5a"))
	_poly([-4, 40, 4, 44, 12, 38, 6, 36, -2, 36], ROCK)
	# the castle on top
	var st := Color("c7b48a")
	_r(-3, 39, 9, 43, st)
	_merlons(-3, 9, 43, 0.9, 0.9, st)
	_r(2, 43, 5, 46, st)
	# the palace of the Despots: a long block with two rows of arched windows
	_r(-20, 18, 4, 27, Color("cdb488"))
	_poly([-21, 27, 5, 27, 3, 29, -19, 29], ROOF)
	for k in 7:
		_archway(-17.5 + k * 3.2, 0.6, 20, 22, WIN)
		_archway(-17.5 + k * 3.2, 0.5, 23.6, 25.4, WIN)
	# churches down the slope
	_byz_church(-24, 6, 1.4)
	_byz_church(16, 14, 1.2)
	_byz_church(-6, 4, 1.6)
	for x in [-32.0, 26.0, 8.0]:
		_cypress(x, 2 + absf(x) * 0.05, 6)

## The Syvota bays: turquoise water over white sand between green pine-covered islets, sailing boats at anchor and a
## few white houses on the shore.
static func _syvota() -> void:
	_r(-45, 0, 45, 5, TURQUOISE)
	_r(-45, 0, 45, 1.4, WATER)
	if _detail(1.0):
		for k in 8:
			_l(-40.0 + k * 11.0, 3.2, -37.0 + k * 11.0, 3.2, Color("bff0f0"), 0.15)
	# islets with pines
	for p in [[-30.0, 16.0, 11.0], [4.0, 22.0, 14.0], [32.0, 14.0, 9.0]]:
		var x: float = p[0]
		var w: float = p[1]
		var h: float = p[2]
		_poly(_arc(x, 4.4, w * 0.5, h, 0, PI, 10), Color("4f7a3a"))
		_r(x - w * 0.5, 4.0, x + w * 0.5, 4.6, Color("f1e8cc"))
		for j in 3:
			_c(x - w * 0.25 + j * w * 0.25, 4.4 + h * 0.8, 1.4, Color("3d6a30"))
	# houses on the near shore
	for k in 3:
		var x := 14.0 + k * 4.0
		_r(x, 4.6, x + 3, 7.2, LIME)
		_r(x + 1.1, 4.6, x + 1.9, 6.0, Color("2f6fa8"))
	# sailing boats
	for p in [[-16.0, 1.0], [-8.0, 0.8], [22.0, 1.1]]:
		var x: float = p[0]
		var s: float = p[1]
		_poly([x - 2.4 * s, 2.4, x + 2.4 * s, 2.4, x + 1.8 * s, 1.6, x - 1.8 * s, 1.6], Color.WHITE)
		_l(x, 2.4, x, 2.4 + 7 * s, DARK, 0.1)
		_poly([x + 0.2, 2.8, x + 0.2, 2.4 + 6.6 * s, x + 2.6 * s, 2.8], Color("f7f7f2"))

## Meteora: tall grey sandstone pillars rising sheer from the plain, the monastery of the Great Meteoron on the
## biggest one with red roofs and a dome, a smaller one on the next rock, a winch house and its rope.
static func _meteora() -> void:
	var rock := Color("9e9184")
	var rock_d := Color("82766a")
	# rock pillars of different heights
	_poly([-30, 0, -29, 30, -26, 40, -20, 42, -16, 36, -14, 0], rock_d)
	_poly([-14, 0, -13, 38, -8, 50, 4, 52, 10, 46, 12, 0], rock)
	_poly([12, 0, 13, 28, 17, 34, 24, 33, 27, 24, 30, 0], rock_d)
	if _detail(1.0):
		for x in [-24.0, -6.0, 2.0, 20.0]:
			_l(x, 2, x + 1, 30, rock.darkened(0.2), 0.3)
	# trees at the foot
	for k in 10:
		_c(-28.0 + k * 6.0, 1.4, 2.0, Color("4f7a3a"))
	# the Great Meteoron on the big rock
	var wall := Color("d8b98a")
	_r(-8, 51, 8, 57, wall)
	_poly([-8.6, 57, 8.6, 57, 6, 59, -6, 59], ROOF)
	_r(-2, 57, 2, 60, wall)
	_poly(_arc(0, 60, 2.2, 2.0, 0, PI, 8), ROOF)
	_windows(-7, 7, 53, 55, 6, WIN)
	_r(6, 49, 10, 52, wall) # the winch house overhanging the cliff
	_l(9, 49, 11.5, 30, Color("4d3b2a"), 0.08)
	# a smaller monastery on the right pillar
	_r(15, 33, 23, 37, wall)
	_poly([14.6, 37, 23.4, 37, 19, 39], ROOF)
	_windows(15.5, 22.5, 34.2, 35.6, 3, WIN)
