class_name LandmarksSkT1
extends RefCounted
## Slovak landmarks of the towns between the map cities, drawn with LandmarkPainter's helpers (metres from the
## base point, y up).

const WHITE := Color("f2efe6")
const RED_ROOF := Color("b5432e")
const WATER := Color("4f8fc0")
const WATER_L := Color("9cc8e6")
const ROCK := Color("9a958a")
const LIME := Color("d9d3c2")
const GRASS := Color("5d8f42")
const TREE := Color("3f6f34")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const WOOD := Color("7a5634")
const SAND := Color("e6d29a")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"senec_sunny_lakes": _senec_sunny_lakes()
		"beckov_castle": _beckov_castle()
		"puchov_tyres": _puchov_tyres()
		"manin_gorge": _manin_gorge()
		"vlkolinec_belfry": _vlkolinec_belfry()
		"harmanec_bat_cave": _harmanec_bat_cave()
		"turcianske_blue_bath": _turcianske_blue_bath()
		"sliac_f16": _sliac_f16()
		"slanec_castle": _slanec_castle()
		"velky_meder_slides": _velky_meder_slides()
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

## A rounded tree crown on a trunk.
static func _tree(x: float, y: float, r: float) -> void:
	_r(x - r * 0.12, y, x + r * 0.12, y + r, WOOD)
	_c(x, y + r * 1.4, r, TREE)
	_c(x - r * 0.35, y + r * 1.6, r * 0.55, TREE.lightened(0.1))

## A pointed spruce.
static func _spruce(x: float, y: float, h: float) -> void:
	_r(x - h * 0.04, y, x + h * 0.04, y + h * 0.2, WOOD)
	_poly([x - h * 0.22, y + h * 0.15, x + h * 0.22, y + h * 0.15, x, y + h], TREE.darkened(0.1))

## A flying bat (seen from the front, wings spread) of span s.
static func _bat(x: float, y: float, s: float) -> void:
	var c := Color("2a2428")
	_poly([x, y + s * 0.12, x - s * 0.2, y + s * 0.2, x - s * 0.5, y + s * 0.18, x - s * 0.38, y + s * 0.02,
		x - s * 0.25, y + s * 0.08, x - s * 0.12, y - s * 0.04, x, y - s * 0.12,
		x + s * 0.12, y - s * 0.04, x + s * 0.25, y + s * 0.08, x + s * 0.38, y + s * 0.02, x + s * 0.5, y + s * 0.18,
		x + s * 0.2, y + s * 0.2], c)
	_c(x, y + s * 0.06, s * 0.1, c)
	_poly([x - s * 0.09, y + s * 0.12, x - s * 0.03, y + s * 0.14, x - s * 0.08, y + s * 0.24], c)
	_poly([x + s * 0.09, y + s * 0.12, x + s * 0.03, y + s * 0.14, x + s * 0.08, y + s * 0.24], c)

## Senec's Sunny Lakes: a sandy beach with striped sun umbrellas, the blue lake with a little sailing boat, poplars
## on the far shore and a big summer sun.
static func _senec_sunny_lakes() -> void:
	_r(-13, 0, 13, 2.2, GRASS)
	for x in [3.0, 7.0, 11.0]:
		_poly([x - 0.9, 2.2, x + 0.9, 2.2, x, 7.0], TREE) # poplars behind the lake
	_r(-13, 0, -3, 1.2, SAND)
	_poly([-3, 0, -1, 0, -3, 1.2], SAND)
	_r(-1, 0, 13, 1.4, WATER)
	_poly([-3, 0, -1, 0, -1, 1.4], WATER)
	if _detail(1.0):
		_l(1, 0.5, 6, 0.5, WATER_L, 0.15)
		_l(9, 0.9, 12, 0.9, WATER_L, 0.15)
	# the sun umbrellas, red-and-white and blue-and-white
	var cols := [Color("d8402e"), Color("2f6fb5"), Color("e8a52a")]
	for k in 3:
		var x: float = -11.0 + k * 3.2
		_l(x, 0.6, x, 3.4, Color("eeeeee"), 0.12)
		_poly(_arc(x, 3.2, 1.5, 0.9, 0, PI, 8), cols[k])
		_poly(_arc(x, 3.2, 0.5, 0.9, 0, PI, 4), WHITE)
		_r(x + 0.4, 0.5, x + 1.6, 0.8, Color("f2efe6") if k != 1 else Color("f0c040")) # a towel
	# the sailing boat
	_poly([4.5, 1.2, 8.5, 1.2, 8.0, 0.6, 5.0, 0.6], WHITE)
	_l(6.5, 1.2, 6.5, 5.4, WOOD, 0.12)
	_poly([6.6, 1.5, 6.6, 5.3, 8.4, 1.5], WHITE)
	_poly([6.4, 1.6, 6.4, 4.6, 5.0, 1.6], Color("d8402e"))
	# the sun
	var sun := Color("f6cf3a")
	for k in 8:
		var a: float = k * TAU / 8.0
		_l(10.5 + cos(a) * 1.6, 8 + sin(a) * 1.6, 10.5 + cos(a) * 2.2, 8 + sin(a) * 2.2, sun, 0.15)
	_c(10.5, 8, 1.3, sun)

## Beckov Castle: the pale ruined walls and the tall keep standing on a sheer white limestone cliff over the Váh,
## with green slopes on the gentle side.
static func _beckov_castle() -> void:
	_r(10, 0, 22, 1.4, WATER)
	if _detail(1.0):
		_l(12, 0.7, 19, 0.7, WATER_L, 0.2)
	var rock := Color("d6d0c0")
	_poly([-22, 0, 10, 0, 10, 2, 8.5, 6, 9.5, 12, 8, 17, 8.5, 21, -6, 21, -12, 14, -18, 6, -22, 2], rock)
	_poly([-22, 0, -4, 0, -10, 10, -12, 14, -18, 6, -22, 2], GRASS) # the gentle green side
	_poly([3, 0, 10, 0, 10, 2, 8.5, 6, 9.5, 12, 8, 17, 6, 17, 7, 10, 5.5, 5], rock.darkened(0.12)) # the sheer face
	if _detail(1.2):
		_l(2, 4, 3.5, 10, rock.darkened(0.2), 0.2)
		_l(-2, 8, -1, 15, rock.darkened(0.2), 0.2)
	for p in [[-19.0, 2.0, 2.4], [-15.0, 5.0, 2.0], [-11.0, 9.0, 1.8]]:
		_tree(p[0], p[1], p[2])
	var w := Color("ece6d6")
	var ws := w.darkened(0.14)
	# the outer wall along the cliff top, with ragged ruined edges
	_poly([-7, 21, 8.5, 21, 8.5, 26, 7, 26, 6.5, 25, 5, 25.5, 4, 24.5, -2, 24.5, -3, 25.5, -5, 24.8, -7, 24.6], w)
	# the palace block with a roof and a row of windows
	_r(-4, 24.5, 4, 29, w)
	_r(-4, 24.5, -3, 29, ws)
	_poly([-4.4, 29, 4.4, 29, 3, 31.4, -3, 31.4], RED_ROOF)
	_windows(-3, 3.6, 26, 27.6, 4, WIN)
	# the keep
	_r(4.5, 21, 8.5, 33.6, w)
	_r(4.5, 21, 5.3, 33.6, ws)
	for x in [4.5, 5.9, 7.3]:
		_r(x, 33.6, x + 0.9, 34, w)
	_poly([6.0, 28, 7.0, 28, 7.0, 29.5] + _arc(6.5, 29.5, 0.5, 0.5, 0, PI, 4), WIN)
	_r(6.1, 24, 6.9, 25.4, WIN)
	# a broken window arch in the outer wall
	_poly([-5.8, 21.8, -4.8, 21.8, -4.8, 23] + _arc(-5.3, 23, 0.5, 0.5, 0, PI, 4), WIN)

## Púchov tyres: one huge car tyre standing on its edge, with a chunky tread and a silver rim, beside a stack of
## three tyres lying on top of each other.
static func _puchov_tyres() -> void:
	var rub := Color("26272a")
	var rub_l := Color("3c3e42")
	# the stack, seen from the side: three fat rounded bands
	for k in 3:
		var y: float = k * 1.55
		_poly([-6, y + 0.3, -5.7, y, -1.8, y, -1.5, y + 0.3, -1.5, y + 1.25, -1.8, y + 1.55, -5.7, y + 1.55, -6, y + 1.25], rub)
		_r(-5.7, y + 0.6, -1.8, y + 0.95, rub_l)
		if _detail(1.6):
			for x in [-5.2, -4.4, -3.6, -2.8]:
				_l(x, y + 0.15, x + 0.3, y + 0.5, rub_l, 0.1)
	# the standing tyre
	var cx := 2.0
	var cy := 4.4
	_c(cx, cy, 4.4, rub)
	if _detail(0.8): # tread blocks around the edge
		for k in 24:
			var a: float = k * TAU / 24.0
			_l(cx + cos(a) * 3.8, cy + sin(a) * 3.8, cx + cos(a) * 4.35, cy + sin(a) * 4.35, rub_l, 0.35)
	_c(cx, cy, 3.4, rub_l)
	_c(cx, cy, 2.4, Color("c4c8cc"))
	_c(cx, cy, 2.0, Color("9aa0a6"))
	for k in 5: # the spokes of the rim
		var a: float = k * TAU / 5.0 + 0.3
		_l(cx, cy, cx + cos(a) * 2.0, cy + sin(a) * 2.0, Color("d8dce0"), 0.45)
	_c(cx, cy, 0.7, Color("6a7076"))
	_c(cx - 0.9, cy + 0.9, 0.3, Color("eef0f2"))

## The Manín Gorge: two tall white-grey limestone walls almost touching, a road and a stream squeezing through the
## gap, trees clinging to the tops, and a little red car for scale.
static func _manin_gorge() -> void:
	var rock := Color("cfc8b6")
	var rd := rock.darkened(0.16)
	# the left wall
	_poly([-18, 0, -2.2, 0, -2.6, 8, -1.8, 15, -2.8, 22, -2.2, 27, -5, 28.5, -8, 27, -11, 28, -14, 24, -16, 18, -18, 12], rock)
	_poly([-5, 0, -2.2, 0, -2.6, 8, -1.8, 15, -2.8, 22, -2.2, 27, -4, 27.5, -4.4, 18, -3.8, 9], rd)
	# the right wall
	_poly([2.2, 0, 18, 0, 18, 10, 16, 17, 13, 22, 9, 25.5, 5, 25, 2.6, 23, 3, 16, 2, 9], rock)
	_poly([2.2, 0, 5, 0, 4.4, 9, 5.2, 16, 4.4, 24.6, 2.6, 23, 3, 16, 2, 9], rd)
	if _detail(1.0): # cracks and ledges
		for p in [[-13, 8, -11, 14], [-9, 16, -7.5, 22], [9, 6, 11, 12], [12, 14, 10.5, 19]]:
			_l(p[0], p[1], p[2], p[3], rd, 0.25)
	# trees on the tops and the slopes
	for p in [[-12.5, 27.0, 3.0], [-7.0, 26.6, 2.6], [-16.0, 17.0, 2.4], [7.0, 24.6, 2.6], [11.5, 21.0, 2.8], [15.5, 15.0, 2.6]]:
		_spruce(p[0], p[1], p[2])
	# the road and the stream through the gap
	_r(-18, 0, 18, 1.0, Color("6a6e72"))
	_r(-18, 0, 18, 0.3, WATER)
	if _detail(1.4):
		for x in range(-16, 18, 3):
			_r(x, 0.62, x + 1.4, 0.72, Color("e8e8e0"))
	# the little car in the gap
	_r(-1.5, 1.2, 1.5, 2.1, Color("d23b2e"))
	_poly([-1.0, 2.1, 0.9, 2.1, 0.5, 2.8, -0.6, 2.8], Color("d23b2e"))
	_r(-0.5, 2.15, 0.4, 2.65, Color("bfe0f0"))
	_c(-0.9, 1.2, 0.35, DARK)
	_c(0.9, 1.2, 0.35, DARK)

## Vlkolínec: the wooden log belfry on its stone foot with a shingled roof and a little bell window, beside a log
## cottage painted pale blue with a steep wooden roof and a picket fence.
static func _vlkolinec_belfry() -> void:
	_r(-8, 0, 8, 0.6, GRASS)
	var log := Color("8a6a46")
	var shingle := Color("6b5236")
	# the cottage
	var blue := Color("a9c4dc")
	_r(0, 0.4, 7.2, 4.6, blue)
	if _detail(1.0):
		for y in [1.2, 2.0, 2.8, 3.6]:
			_l(0, y, 7.2, y, blue.darkened(0.1), 0.08)
	_r(0, 0.2, 7.2, 0.6, ROCK)
	_poly([-0.5, 4.6, 7.7, 4.6, 3.6, 9.4], shingle)
	_poly([-0.5, 4.6, 1.4, 4.6, 3.6, 9.4], shingle.lightened(0.12))
	for x in [1.6, 4.8]:
		_r(x, 1.8, x + 1.0, 3.2, WHITE)
		_r(x + 0.12, 1.92, x + 0.88, 3.08, WIN)
		_l(x + 0.5, 1.9, x + 0.5, 3.1, WHITE, 0.08)
	# the belfry
	var bx := -4.0
	_r(bx - 2.0, 0, bx + 2.0, 1.6, ROCK)
	_r(bx - 1.6, 1.6, bx + 1.6, 8.0, log)
	if _detail(1.0):
		for k in 11:
			_l(bx - 1.6, 2.0 + k * 0.55, bx + 1.6, 2.0 + k * 0.55, log.darkened(0.2), 0.07)
	_r(bx - 1.6, 1.6, bx - 1.1, 8.0, log.lightened(0.1))
	_poly([bx - 0.5, 1.6, bx + 0.5, 1.6, bx + 0.5, 3.0, bx - 0.5, 3.0], Color("4a3624")) # the door
	_r(bx - 1.9, 7.6, bx + 1.9, 8.1, shingle) # a small eave
	_r(bx - 1.3, 8.1, bx + 1.3, 9.9, log)
	_r(bx - 0.8, 8.4, bx + 0.8, 9.6, Color("2a1e14")) # the bell window
	_poly(_arc(bx, 9.4, 0.5, 0.6, PI, TAU, 6), Color("c09a3a")) # the bell
	_poly([bx - 2.2, 9.9, bx + 2.2, 9.9, bx, 13.4], shingle)
	_poly([bx - 2.2, 9.9, bx - 0.7, 9.9, bx, 13.4], shingle.lightened(0.12))
	_l(bx, 13.4, bx, 14.0, Color("4a3624"), 0.12)
	_l(bx - 0.3, 13.75, bx + 0.3, 13.75, Color("4a3624"), 0.1)
	# the picket fence
	for k in 8:
		var x: float = -1.5 + k * 1.2
		_r(x, 0.4, x + 0.3, 1.6, Color("b89a70"))
	_l(-1.5, 1.2, 7.6, 1.2, Color("b89a70"), 0.12)

## Harmanec Cave: a wooded hill with a grey rocky face and the dark cave mouth, white dripstones hanging inside,
## the wooden steps going up to it and bats flitting out.
static func _harmanec_bat_cave() -> void:
	_poly([-15, 0, 15, 0, 15, 6, 11, 12, 6, 16, 0, 17.4, -6, 16.5, -11, 12, -15, 6], GRASS.darkened(0.08))
	for p in [[-12.0, 8.0, 3.6], [-8.0, 12.5, 3.8], [-3.0, 15.0, 3.4], [6.0, 14.0, 3.6], [10.5, 10.5, 3.4], [13.0, 4.0, 3.4]]:
		_spruce(p[0], p[1], p[2])
	var rock := Color("a8a294")
	_poly([-7, 2, 5, 2, 7, 6, 6, 11, 2, 13, -3, 12.6, -7, 10, -8.5, 6], rock)
	_poly([-7, 2, -3, 2, -5, 7, -3, 12.6, -7, 10, -8.5, 6], rock.lightened(0.1))
	# the cave mouth with dripstones
	_poly([-3.5, 3, 3, 3, 3.2, 6.5] + _arc(-0.2, 6.5, 3.3, 3.6, 0, PI, 12), Color("1f1b1a"))
	if _detail(0.9):
		for p in [[-2.6, 0.9], [-1.4, 1.5], [-0.2, 1.1], [1.0, 1.6], [2.1, 1.0]]:
			var top: float = 6.5 + sqrt(maxf(0.0, 1.0 - pow((p[0] + 0.2) / 3.3, 2))) * 3.6 - 0.1
			_poly([p[0] - 0.3, top, p[0] + 0.3, top, p[0], top - p[1]], Color("ece8dc"))
		_poly([-1.0, 3, -0.2, 3, -0.6, 4.4], Color("ece8dc")) # a stalagmite
	# the wooden steps up to the mouth
	var wood := Color("9a7448")
	for k in 6:
		var x: float = 4.0 - k * 1.6
		var y: float = 3.0 - k * 0.5
		_r(x - 1.0, y - 0.25, x + 0.6, y, wood)
	_l(-4.5, 0.4, 4.4, 3.4, wood.darkened(0.2), 0.14)
	_l(-4.5, 1.4, 4.4, 4.4, wood.darkened(0.2), 0.1)
	# bats flying out
	for p in [[1.0, 11.0, 2.2], [-4.0, 14.5, 1.8], [5.0, 16.0, 2.0], [-9.0, 18.2, 1.6], [9.5, 18.5, 1.5]]:
		_bat(p[0], p[1], p[2])

## The Blue Bath in Turčianske Teplice: the old spa pavilion of 1885, a round middle with a blue dome and lantern,
## low wings with tall arched windows, its walls in pale blue tiles.
static func _turcianske_blue_bath() -> void:
	_r(-10, 0, 10, 0.7, Color("bdb6a6"))
	var wall := Color("8fb6d8")
	var wl := Color("d6e6f2")
	var dome := Color("2f6ea8")
	# the wings
	for s in [-1.0, 1.0]:
		var x0: float = 3.5 * s
		var x1: float = 9.5 * s
		_r(minf(x0, x1), 0.7, maxf(x0, x1), 6.0, wall)
		_r(minf(x0, x1) - 0.2, 6.0, maxf(x0, x1) + 0.2, 6.6, wl)
		for k in 3:
			var x: float = (4.6 + k * 1.8) * s
			_poly([x - 0.55, 1.6, x + 0.55, 1.6, x + 0.55, 4.0] + _arc(x, 4.0, 0.55, 0.7, 0, PI, 5), WIN)
		_poly([minf(x0, x1), 6.6, maxf(x0, x1), 6.6, maxf(x0, x1) - (0.0 if s < 0 else 1.0), 7.4, minf(x0, x1) + (1.0 if s < 0 else 0.0), 7.4], dome.darkened(0.15))
	# the round middle
	_r(-4, 0.7, 4, 8.2, wall.lightened(0.08))
	_r(-4, 0.7, -3.3, 8.2, wl)
	_r(3.3, 0.7, 4, 8.2, wl)
	_poly([-1.2, 0.7, 1.2, 0.7, 1.2, 3.6] + _arc(0, 3.6, 1.2, 1.3, 0, PI, 6), Color("4a3a2a"))
	for x in [-2.4, 2.4]:
		_poly([x - 0.5, 2.0, x + 0.5, 2.0, x + 0.5, 4.6] + _arc(x, 4.6, 0.5, 0.6, 0, PI, 4), WIN)
	_r(-1.6, 5.6, 1.6, 6.9, wl)
	_r(-1.4, 5.8, 1.4, 6.7, dome.darkened(0.2))
	_r(-4.4, 8.2, 4.4, 8.8, wl)
	# the dome and lantern
	_poly(_arc(0, 8.8, 4.0, 3.8, 0, PI, 14), dome)
	_poly(_arc(-1.4, 8.8, 2.4, 3.2, PI * 0.5, PI, 5) + [-1.4, 8.8], dome.lightened(0.15))
	_r(-0.6, 12.4, 0.6, 13.4, wl)
	_poly(_arc(0, 13.4, 0.7, 0.5, 0, PI, 6), dome)
	_l(0, 13.9, 0, 14.0, Color("d8b14a"), 0.15)

## Sliač air base: a grey F-16 fighter of the Slovak air force on the runway, with its bubble canopy, the tall tail
## fin with the Slovak roundel, and the control tower behind.
static func _sliac_f16() -> void:
	_r(-8, 0, 8, 0.5, Color("5c6064"))
	if _detail(1.4):
		for x in [-6.0, -2.0, 2.0, 6.0]:
			_r(x, 0.2, x + 1.6, 0.3, WHITE)
	# the control tower
	_r(-7.6, 0.5, -6.8, 5.6, Color("d8d4cc"))
	_r(-8.0, 5.6, -6.4, 6.9, Color("4a6880"))
	_r(-8.0, 6.9, -6.4, 7.2, Color("d8d4cc"))
	var g := Color("8e959c")
	var gd := g.darkened(0.2)
	# landing gear
	for x in [-1.2, 4.6]:
		_l(x, 0.9, x, 2.0, DARK, 0.12)
		_c(x, 0.85, 0.35, DARK)
	# the fuselage, nose to the right
	_poly([-5.6, 2.2, 5.0, 2.0, 7.0, 2.5, 7.8, 2.85, 6.8, 3.15, 4.8, 3.5, 2.0, 3.6, -5.0, 3.6, -5.8, 3.1], g)
	_poly([-5.6, 2.2, 5.0, 2.0, 7.0, 2.5, -5.2, 2.6], gd)
	_poly([0.0, 2.1, 3.0, 2.0, 3.0, 1.6, 0.6, 1.6], gd.darkened(0.1)) # the intake under the belly
	_r(-6.2, 2.3, -5.6, 3.3, DARK) # the exhaust
	# the canopy
	_poly(_arc(4.0, 3.5, 1.7, 0.7, 0, PI, 10), Color("6a8aa0"))
	_poly(_arc(4.2, 3.5, 0.8, 0.45, PI * 0.15, PI * 0.85, 4) + [4.2, 3.6], Color("c8dce8"))
	# the wing and the tailplane
	_poly([-2.6, 2.7, 1.6, 2.9, -2.2, 3.3], gd)
	_poly([-5.6, 2.8, -3.6, 2.8, -5.2, 3.2], gd)
	# the tail fin
	_poly([-5.0, 3.6, -2.4, 3.6, -4.4, 6.8, -5.6, 6.8], g)
	_poly([-5.0, 3.6, -4.2, 3.6, -5.2, 6.8, -5.6, 6.8], g.lightened(0.1))
	# the Slovak air force roundel on the fin: the double cross on red over the blue hills, in a white ring
	var rx := -4.5
	var ry := 5.2
	_c(rx, ry, 0.66, Color("2a4ea0"))
	_c(rx, ry, 0.56, WHITE)
	_c(rx, ry, 0.46, Color("d43030"))
	_poly(_arc(rx, ry, 0.46, 0.46, PI * 1.15, PI * 1.85, 6) + [rx, ry - 0.3], Color("2a4ea0"))
	_l(rx, ry - 0.28, rx, ry + 0.38, WHITE, 0.08)
	_l(rx - 0.2, ry + 0.08, rx + 0.2, ry + 0.08, WHITE, 0.07)
	_l(rx - 0.14, ry + 0.24, rx + 0.14, ry + 0.24, WHITE, 0.07)

## Slanec Castle: the ruins of a round tower and broken walls on top of a steep cone-shaped old volcano, with the
## village's red roofs at its foot.
static func _slanec_castle() -> void:
	_poly([-20, 0, 20, 0, 16, 3, 10, 8, 6, 14, 3, 18, -3, 18.5, -7, 15, -11, 9, -16, 4], GRASS)
	_poly([-20, 0, -6, 0, -8, 6, -7, 15, -11, 9, -16, 4], GRASS.lightened(0.08))
	for p in [[-13.0, 4.5, 2.0], [-9.5, 9.5, 1.8], [11.0, 6.5, 2.0], [7.5, 11.0, 1.8], [14.5, 2.5, 1.8]]:
		_tree(p[0], p[1], p[2])
	_poly([-4, 17, 4, 17, 3, 18.3, -3, 18.6], ROCK) # the rocky top
	var st := Color("d2c8b2")
	var sd := st.darkened(0.15)
	# broken walls
	_poly([-7.5, 17.3, 7.0, 17.3, 7.0, 21.0, 5.8, 22.4, 4.8, 20.6, 2.4, 21.2, 1.2, 20.0, -3.0, 21.6, -4.5, 23.4, -7.5, 22.6], st)
	_poly([-1.2, 17.3, 0.4, 17.3, 0.4, 18.8] + _arc(-0.4, 18.8, 0.8, 0.8, 0, PI, 4), WIN)
	_poly([3.4, 18.0, 4.4, 18.0, 4.4, 19.2] + _arc(3.9, 19.2, 0.5, 0.5, 0, PI, 4), WIN)
	# the round tower, broken at the top
	_r(-5.6, 17.3, -1.4, 28.0, st)
	_r(-5.6, 17.3, -4.6, 28.0, sd)
	_r(-5.0, 28.0, -4.2, 28.6, st)
	_r(-2.8, 28.0, -2.0, 28.5, st)
	_r(-3.9, 24.0, -3.0, 25.6, WIN)
	_r(-3.9, 20.2, -3.0, 21.6, WIN)
	# village houses at the foot
	for p in [[-17.0, 2.6], [-12.5, 3.0], [13.0, 2.6], [17.0, 2.4]]:
		var x: float = p[0]
		_r(x - 1.4, 0, x + 1.4, p[1], WHITE)
		_poly([x - 1.7, p[1], x + 1.7, p[1], x, p[1] + 1.6], RED_ROOF)
		_r(x - 0.4, 0.8, x + 0.4, 1.6, WIN)

## Veľký Meder's thermal baths: a steaming blue pool of hot spring water, a tall slide tower with a yellow and a red
## twisting water slide splashing down into it.
static func _velky_meder_slides() -> void:
	_r(-12, 0, 12, 0.8, Color("d8d2c4"))
	_r(-11, 0.2, 11, 1.4, Color("e8e4dc"))
	_r(-10, 0.6, 10, 1.4, Color("5fb4d8"))
	if _detail(1.0):
		_l(-8, 1.0, -3, 1.0, WATER_L, 0.15)
		_l(2, 1.1, 7, 1.1, WATER_L, 0.15)
	# steam from the warm water: soft white puffs
	for p in [[-8.5, 2.4, 0.5], [-8.0, 3.4, 0.4], [-5.5, 2.2, 0.45], [-5.0, 3.1, 0.35]]:
		_c(p[0], p[1], p[2], Color(1, 1, 1, 0.55))
	# the slide tower
	var steel := Color("e0e0dc")
	var tx := 7.5
	for x in [tx - 1.5, tx + 1.5]:
		_l(x, 1.4, x, 14.0, steel.darkened(0.25), 0.25)
	for y in [5.0, 9.5, 14.0]:
		_r(tx - 1.9, y - 0.3, tx + 1.9, y, steel.darkened(0.1))
	_l(tx - 1.5, 1.4, tx + 1.5, 5.0, steel.darkened(0.3), 0.12)
	_l(tx + 1.5, 5.0, tx - 1.5, 9.5, steel.darkened(0.3), 0.12)
	_l(tx - 1.5, 9.5, tx + 1.5, 14.0, steel.darkened(0.3), 0.12)
	_poly([tx - 2.2, 14.0, tx + 2.2, 14.0, tx, 16.0], Color("d84030")) # the little roof
	# the yellow slide: from the top, round and round, down into the pool
	var ys := [tx - 1.9, 13.8, 1.5, 12.8, -2.5, 11.0, 0.5, 8.6, 4.5, 7.6, 2.5, 5.8, -3.0, 4.8, -6.0, 2.4, -7.5, 1.6]
	for k in range(0, ys.size() - 2, 2):
		_l(ys[k], ys[k + 1], ys[k + 2], ys[k + 3], Color("f0c02a"), 0.9)
		_c(ys[k + 2], ys[k + 3], 0.45, Color("f0c02a"))
	# the red slide from the middle platform
	var rs := [tx - 1.9, 9.3, 3.5, 9.6, 0.0, 6.4, -2.5, 3.4, -1.0, 2.0, 1.5, 1.6]
	for k in range(0, rs.size() - 2, 2):
		_l(rs[k], rs[k + 1], rs[k + 2], rs[k + 3], Color("d84030"), 0.9)
		_c(rs[k + 2], rs[k + 3], 0.45, Color("d84030"))
	# splashes
	for p in [[-8.0, 1.6], [2.0, 1.6]]:
		_c(p[0], p[1], 0.5, Color(1, 1, 1, 0.85))
		_c(p[0] + 0.6, p[1] + 0.3, 0.3, Color(1, 1, 1, 0.85))
