class_name LandmarksSiA
extends RefCounted
## Slovenian landmarks, drawn with LandmarkPainter's helpers (metres from the base point, y up).

const WHITE := Color("f2efe6")
const STONE := Color("cdbf9f")
const RED_ROOF := Color("b5432e")
const WATER := Color("4f8fc0")
const WATER_L := Color("9cc8e6")
const ROCK := Color("9a958a")
const GRASS := Color("5d8f42")
const TREE := Color("3f6f34")
const WIN := Color("3a4048")
const GOLD := Color("e0b43a")
const DARK := Color("2e3238")
const WOOD := Color("7a5636")
const BRONZE := Color("a8783e")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"tromostovje": _tromostovje()
		"stara_trta": _stara_trta()
		"celje_castle": _celje_castle()
		"kranj_church": _kranj_church()
		"velenje_headframe": _velenje_headframe()
		"praetorian_palace": _praetorian_palace()
		"situla": _situla()
		"mura_mill": _mura_mill()
		"kurent": _kurent()
		"solkan_bridge": _solkan_bridge()
		"postojna_cave": _postojna_cave()
		"bled_island": _bled_island()
		"piran_tower": _piran_tower()
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

## A pointed (Gothic) window.
static func _pointed(x: float, y0: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.5, y0, x + w * 0.5, y0, x + w * 0.5, y0 + h - w * 0.8, x, y0 + h, x - w * 0.5, y0 + h - w * 0.8], col)

## Ljubljana's Triple Bridge: Plečnik's white stone balustrades on the old middle bridge and the two footbridges
## fanning out on either side, his lamp posts, the green Ljubljanica below and the pink Franciscan church behind.
static func _tromostovje() -> void:
	var pink := Color("d98f86")
	# the Franciscan church behind the right end
	_r(14, 0, 28, 13, pink)
	_poly([14, 13, 28, 13, 21, 16], pink.darkened(0.12))
	_r(19.5, 0, 22.5, 6, pink.darkened(0.3))
	_arched(21, 7.5, 2.4, 4, WIN)
	_r(14, 2, 28, 2.6, WHITE)
	# the river
	_r(-30, 0, 30, 2.4, Color("4f8a74"))
	if _detail(1.0):
		_l(-26, 1.2, -18, 1.2, Color("6fa894"), 0.15)
		_l(8, 0.8, 16, 0.8, Color("6fa894"), 0.15)
	# the side footbridges, splaying away
	var st := Color("e8e2d2")
	var sd := st.darkened(0.2)
	for sg in [-1.0, 1.0]:
		_poly([sg * 12, 3.8, sg * 29, 2.6, sg * 29, 3.6, sg * 12, 4.8], sd)
		for k in 9:
			var x: float = sg * (13.0 + k * 1.9)
			var y: float = 4.6 - k * 0.13
			_r(x - 0.25, y, x + 0.25, y + 1.0, st)
		_l(sg * 12, 5.8, sg * 29, 4.6, st, 0.3)
	# the middle bridge: a stone arch, a deck and a balustrade
	_poly([-14, 0, -14, 5.2, 14, 5.2, 14, 0] + _arc(0, 0, 9, 3.6, 0, PI, 10), st)
	_r(-14.5, 5.2, 14.5, 5.8, sd)
	for k in 25:
		var x := -13.0 + k * 1.08
		_r(x - 0.28, 5.8, x + 0.28, 7.2, st)
	_r(-14.5, 7.2, 14.5, 7.8, st)
	# Plečnik's lamp posts
	for x in [-14.0, -7.0, 7.0, 14.0]:
		_r(x - 0.2, 7.8, x + 0.2, 11.5, DARK)
		_c(x, 11.8, 0.55, Color("fff4c8"))
		_c(x - 0.9, 10.8, 0.35, Color("fff4c8"))
		_c(x + 0.9, 10.8, 0.35, Color("fff4c8"))

## Maribor's Old Vine: a white house on the Lent embankment with the 400-year-old vine trained along its wall,
## a gnarled trunk branching right and left, leaves and dark grapes.
static func _stara_trta() -> void:
	_r(-17, 0, 17, 1, Color("a59e8c"))
	_r(-14, 1, 14, 12, Color("ece4cf"))
	_poly([-15, 12, 15, 12, 11, 17, -11, 17], RED_ROOF)
	_windows(-12, 12, 4, 6.5, 6, WIN)
	_windows(-12, 12, 8.5, 10.5, 6, Color("7a8a96"))
	_r(-1.2, 1, 1.2, 4, WOOD)
	# the vine: a thick old trunk and two long arms under the eaves
	var vine := Color("5a3f28")
	_poly([-4.5, 1, -3.2, 1, -3.4, 7.5, -4.2, 7.5], vine)
	_l(-3.8, 7.5, -13.5, 7.8, vine, 0.5)
	_l(-3.8, 7.5, 13.5, 7.3, vine, 0.5)
	_l(-3.8, 5, -6, 6, vine, 0.3)
	var leaf := Color("4f8a3a")
	for k in 14:
		var x := -13.0 + k * 2.0
		if absf(x + 3.8) < 0.6: continue
		_c(x, 8.0 + (k % 2) * 0.4, 0.95, leaf if k % 3 else leaf.lightened(0.15))
		if k % 2 == 0:
			_c(x + 0.4, 6.7, 0.42, Color("4a2a4e"))
			_c(x + 0.1, 6.2, 0.36, Color("4a2a4e"))

## The Old Castle of Celje on its wooded hill: the long ruined walls along the ridge and Frederick's Tower,
## the tall square keep with its little roof.
static func _celje_castle() -> void:
	_poly([-35, 0, -24, 8, -12, 15, 0, 18, 14, 17, 26, 10, 35, 0], TREE)
	_poly([-35, 0, -26, 5, -16, 9, -2, 10, 12, 8, 26, 4, 35, 0], GRASS)
	var w := Color("bfb7a3")
	var wd := w.darkened(0.15)
	# the walls along the ridge, with merlons
	_poly([-20, 11, -10, 15.5, 16, 15.5, 22, 12, 22, 18, 16, 20.5, -10, 20.5, -20, 16], w)
	if _detail(0.8):
		for k in 13:
			var x := -9.0 + k * 2.0
			_r(x, 20.5, x + 1.0, 21.5, w)
	_r(-10, 15.5, -6, 23, wd)
	_r(10, 15.5, 14, 24, wd)
	# Frederick's Tower
	_r(-2, 15.5, 6, 31, w)
	_r(-2, 15.5, -0.8, 31, wd)
	_poly([-2.6, 31, 6.6, 31, 2, 34], RED_ROOF)
	for y in [20.0, 24.5, 28.0]:
		_arched(2, y, 1.2, 2, WIN)

## St Cantius in Kranj: a Gothic hall church under a steep roof with its tall free bell tower and needle spire.
static func _kranj_church() -> void:
	var s := Color("e6dfcd")
	var sd := s.darkened(0.16)
	_r(-14, 0, 6, 13, s)
	_poly([-14.6, 13, 6.6, 13, 4, 21, -12, 21], Color("6a6560"))
	for x in [-10.0, -5.0, 0.0]:
		_pointed(x, 3, 1.8, 7, WIN)
	for x in [-14.0, -7.5, -2.5, 6.0]:
		_r(x - 0.5, 0, x + 0.5, 11, sd)
	# the bell tower
	_r(7, 0, 14, 30, s)
	_r(7, 0, 8, 30, sd)
	_pointed(10.5, 24, 2, 4, DARK)
	_c(10.5, 20, 1.3, WHITE)
	_c(10.5, 20, 1.1, Color("2c4f80"))
	_l(10.5, 20, 10.5, 20.8, GOLD, 0.15)
	_poly([6.6, 30, 14.4, 30, 10.5, 42], Color("4d5a5e"))
	_l(10.5, 42, 10.5, 43.5, GOLD, 0.15)

## The Velenje coal mine: a steel winding tower with its two sheave wheels over the shaft, the hall at its foot.
static func _velenje_headframe() -> void:
	var steel := Color("8a3a2a")
	_r(-17, 0, 17, 9, Color("b9ae98"))
	_poly([-17.5, 9, 17.5, 9, 14, 12, -14, 12], Color("6a6560"))
	_windows(-15, 15, 3, 6.5, 8, WIN)
	# the legs and cross-braces
	_l(-6, 9, -3, 30, steel, 0.7)
	_l(6, 9, 3, 30, steel, 0.7)
	_l(-6, 9, 13, 20, steel, 0.6) # the back strut
	for k in 5:
		var y0 := 11.0 + k * 4.0
		var y1 := y0 + 4.0
		var xa := -6.0 + (y0 - 9.0) / 21.0 * 3.0
		var xb := -6.0 + (y1 - 9.0) / 21.0 * 3.0
		_l(xa, y0, -xb, y1, steel, 0.25)
		_l(-xa, y0, xb, y1, steel, 0.25)
		_l(xb, y1, -xb, y1, steel, 0.3)
	_r(-4.5, 29.5, 4.5, 31, steel)
	# the sheave wheels
	for x in [-2.2, 2.2]:
		_c(x, 32, 2.0, DARK)
		_c(x, 32, 1.6, Color("cfcabd"))
		_c(x, 32, 0.4, DARK)
	_l(-2.2, 30, -2.2, 9, DARK, 0.1)
	_l(2.2, 30, 2.2, 9, DARK, 0.1)

## The Praetorian Palace in Koper: a Venetian Gothic town hall, white with swallow-tail merlons along the top,
## pointed windows, the loggia in the middle reached by twin stairs and the winged lion of St Mark.
static func _praetorian_palace() -> void:
	var s := Color("efe8d6")
	var sd := s.darkened(0.14)
	_r(-24, 0, 24, 18, s)
	# merlons
	for k in 16:
		var x := -23.5 + k * 3.0
		_poly([x, 18, x + 2, 18, x + 2, 20.5, x + 1, 19.6, x, 20.5], s)
	_r(-24, 17.4, 24, 18, sd)
	for x in [-20.0, -16.0, -12.0, 12.0, 16.0, 20.0]:
		_pointed(x, 4, 1.8, 4.5, WIN)
		_pointed(x, 11, 1.8, 4.5, WIN)
	# the loggia
	_r(-8, 8, 8, 16, sd)
	for k in 5:
		_pointed(-6.4 + k * 3.2, 8.6, 2.4, 6.4, Color("5a5a58"))
	_r(-8.5, 8, 8.5, 8.6, s)
	# the twin stairs
	_poly([-8, 8, -8, 7, -14, 0, -10, 0], sd)
	_poly([8, 8, 8, 7, 14, 0, 10, 0], sd)
	_arched(0, 0, 3, 5, WOOD)
	# St Mark's lion
	_r(-2, 16.2, 2, 17.2, GOLD)
	_c(0, 16.8, 0.7, GOLD)

## The Novo Mesto situla: a 2,500-year-old bronze bucket on a plinth, narrow at the foot, its friezes of
## warriors on horseback and animals, the bail handle above.
static func _situla() -> void:
	_r(-3.5, 0, 3.5, 3, Color("b9b4a8"))
	_r(-4, 2.7, 4, 3.1, Color("cfcabd"))
	var b := BRONZE
	_poly([-2.2, 3.1, 2.2, 3.1, 3.2, 9.4, -3.2, 9.4], b)
	_poly([-2.2, 3.1, -1.4, 3.1, -2.2, 9.4, -3.2, 9.4], b.lightened(0.18))
	_r(-3.4, 9.4, 3.4, 9.9, b.darkened(0.2))
	for y in [5.0, 7.3]:
		var w: float = 2.2 + (y - 3.1) / 6.3
		_l(-w, y, w, y, b.darkened(0.3), 0.1)
	if _detail(3.0):
		var f := b.darkened(0.35)
		for k in 3:
			var x := -1.6 + k * 1.6
			_c(x, 6.1, 0.3, f) # a rider's head
			_r(x - 0.45, 5.4, x + 0.45, 5.75, f) # the horse
			_c(x + 0.15, 8.3, 0.25, f)
			_r(x - 0.1, 7.6, x + 0.35, 8.1, f)
	var h := _arc(0, 9.9, 3.2, 2.4, 0, PI, 10)
	for k in range(0, h.size() - 2, 2):
		_l(h[k], h[k + 1], h[k + 2], h[k + 3], b.darkened(0.25), 0.18)

## A floating mill on the Mura: a wooden mill house with a shingle roof on one pontoon, the big paddle wheel
## turning in the current between it and the second, smaller boat.
static func _mura_mill() -> void:
	_r(-18, 0, 18, 2.2, Color("5f8c86"))
	var w := WOOD
	# the pontoons
	_poly([-15, 1.2, 4, 1.2, 5, 3, -16, 3], w.darkened(0.25))
	_poly([9, 1.2, 15, 1.2, 16, 3, 8, 3], w.darkened(0.25))
	# the mill house
	_r(-13, 3, 2, 9.5, w)
	if _detail(1.2):
		for k in 10:
			var x := -12.5 + k * 1.5
			_l(x, 3, x, 9.5, w.darkened(0.15), 0.08)
	_r(-8, 3, -6, 7, w.darkened(0.4))
	_r(-3, 6, -1, 7.6, WIN)
	_poly([-14.2, 9.5, 3.2, 9.5, 0, 14.5, -11, 14.5], Color("8f7a5a"))
	# the wheel between the boats
	_c(6.5, 4, 4.6, w.darkened(0.15))
	_c(6.5, 4, 4.0, Color("5f8c86").lightened(0.15))
	for k in 8:
		var a := k * PI / 4.0
		_l(6.5, 4, 6.5 + cos(a) * 4.5, 4 + sin(a) * 4.5, w.darkened(0.3), 0.3)
	_c(6.5, 4, 0.6, DARK)
	_r(-18, 0, 18, 1.0, Color("5f8c86")) # the water hides the bottom of the wheel

## A Kurent from Ptuj's carnival: a shaggy sheepskin body, a leather mask with horns, a long red tongue and
## cow bells hanging on a chain round the waist.
static func _kurent() -> void:
	var fur := Color("f0ece0")
	var fd := fur.darkened(0.12)
	_r(-0.9, 0, -0.3, 1.2, Color("3a2a1e"))
	_r(0.3, 0, 0.9, 1.2, Color("3a2a1e"))
	_poly([-1.6, 1, 1.6, 1, 1.4, 4.0, -1.4, 4.0], fur)
	for k in 6:
		var x := -1.3 + k * 0.52
		_c(x, 1.2 + (k % 2) * 0.2, 0.32, fd)
		_c(x, 2.6 + (k % 2) * 0.2, 0.3, fur.lightened(0.05))
	# the bells on their chain
	_l(-1.5, 2.0, 1.5, 2.0, DARK, 0.08)
	for x in [-1.0, 0.0, 1.0]:
		_poly([x - 0.3, 2.0, x + 0.3, 2.0, x + 0.38, 1.3, x - 0.38, 1.3], Color("8a6a2a"))
	# the head and mask
	_c(0, 4.4, 1.1, fur)
	_r(-0.7, 3.8, 0.7, 5.0, Color("4a3020"))
	_c(-0.35, 4.6, 0.18, WHITE)
	_c(0.35, 4.6, 0.18, WHITE)
	_c(-0.35, 4.6, 0.08, Color("c8102e"))
	_c(0.35, 4.6, 0.08, Color("c8102e"))
	_poly([-0.15, 4.0, 0.15, 4.0, 0.05, 2.8, -0.05, 2.8], Color("c8102e")) # the tongue
	# the horns, with coloured ribbons
	_poly([-0.6, 5.0, -0.3, 5.1, -1.2, 6.0, -1.5, 5.8], Color("d8c8a0"))
	_poly([0.6, 5.0, 0.3, 5.1, 1.2, 6.0, 1.5, 5.8], Color("d8c8a0"))
	_l(-1.0, 5.4, -1.8, 4.8, Color("2a6ab0"), 0.12)
	_l(1.0, 5.4, 1.8, 4.8, Color("e0b43a"), 0.12)

## The Solkan Bridge over the emerald Soča: an 85-metre stone arch, the widest stone railway arch in the world,
## between the rocky gorge sides, with smaller arches over the banks.
static func _solkan_bridge() -> void:
	var rock := ROCK
	_poly([-45, 0, -45, 32, -38, 30, -30, 18, -26, 4, -24, 0], rock)
	_poly([45, 0, 45, 30, 38, 28, 30, 16, 26, 3, 24, 0], rock.darkened(0.08))
	_poly([-45, 32, -38, 30, -36, 34, -45, 36], TREE)
	_poly([45, 30, 38, 28, 37, 32, 45, 34], TREE)
	_r(-26, 0, 26, 3, Color("2fa58f"))
	var st := Color("d9d2c0")
	var sd := st.darkened(0.18)
	# the main arch and the spandrel
	_poly([-30, 30, 30, 30, 30, 18] + _arc(0, 4, 21, 22, 0, PI, 20) + [-30, 18], st)
	_poly(_arc(0, 4, 23.5, 24.5, 0.1, PI - 0.1, 20) + _arc(0, 4, 21, 22, PI - 0.1, 0.1, 20), sd)
	# the side arches
	for sg in [-1.0, 1.0]:
		for k in 3:
			var x: float = sg * (24.0 + k * 3.0)
			_arched(x, 22, 2, 5, rock.darkened(0.3))
	# the deck and the parapet
	_r(-38, 30, 38, 31.5, sd)
	_r(-38, 31.5, 38, 32.3, st)
	if _detail(0.8):
		_l(-38, 33.5, 38, 33.5, DARK, 0.1) # the overhead wire

## Postojna Cave: inside the dark cave, white stalactites hanging and stalagmites growing, the little red cave
## train with its open cars, and a pink olm in a pool.
static func _postojna_cave() -> void:
	var dark := Color("3a332c")
	_poly([-25, 0, 25, 0, 25, 14] + _arc(0, 14, 25, 8, 0, PI, 12), dark)
	var dr := Color("e8dcc4")
	for k in 9:
		var x := -21.0 + k * 5.2
		var h := 3.0 + (k * 7 % 5)
		_poly([x - 1.0, 20.5 - absf(x) * 0.18, x + 1.0, 20.5 - absf(x) * 0.18, x, 20.5 - absf(x) * 0.18 - h], dr)
	for x in [-20.0, -14.5, 15.0, 21.0]:
		var h: float = 4.0 + absf(x) * 0.2
		_poly([x - 1.4, 2, x + 1.4, 2, x + 0.3, 2 + h, x - 0.3, 2 + h], dr.darkened(0.08))
	# the track and the train
	_r(-25, 1.6, 25, 2.0, Color("6a6058"))
	_r(-12, 2.0, -6, 5.6, Color("b5432e"))
	_r(-11, 4.6, -7.5, 5.6, Color("f2d98a"))
	for k in 3:
		var x := -5.0 + k * 5.0
		_r(x, 2.6, x + 4.4, 4.0, Color("2f6a9a"))
		_c(x + 1.4, 4.5, 0.45, Color("e0b090"))
		_c(x + 3.0, 4.5, 0.45, Color("6a4a30"))
	for x in [-11.0, -7.0, -4.0, -1.0, 1.0, 4.0, 6.0, 9.0]:
		_c(x, 2.2, 0.45, DARK)
	# the olm in a pool
	_r(12, 0, 22, 1.4, Color("2f5a70"))
	_r(14.5, 0.7, 19.5, 1.1, Color("f0c0b0"))
	_c(14.3, 0.9, 0.35, Color("f0c0b0"))

## Lake Bled: the islet with the white Church of the Assumption and its tall tower among trees, a pletna boat
## rowing over, Bled Castle on its cliff to the right and the Julian Alps behind.
static func _bled_island() -> void:
	_poly([-35, 6, -22, 26, -12, 18, 0, 30, 14, 20, 24, 28, 35, 10], Color("8a9aa8"))
	_poly([-22, 26, -19, 22, -25, 22], WHITE)
	_poly([0, 30, 3.5, 25, -3.5, 25], WHITE)
	_r(-35, 0, 35, 6, WATER)
	if _detail(0.8):
		_l(-30, 2, -20, 2, WATER_L, 0.2)
		_l(-6, 4, 6, 4, WATER_L, 0.2)
	# the island
	_poly([-18, 3, -15, 7, -3, 8, 3, 6, 6, 3], GRASS)
	for x in [-16.0, -13.0, 1.0, 4.0]:
		_c(x, 9, 2.2, TREE)
	_r(-11, 7, -2, 13, WHITE)
	_poly([-11.5, 13, -1.5, 13, -4, 16, -9, 16], RED_ROOF)
	_r(-1.5, 7, 1.5, 22, WHITE)
	_poly([-1.9, 22, 1.9, 22, 0, 27], RED_ROOF)
	_arched(0, 18, 1.2, 2.2, WIN)
	_c(0, 15.5, 0.8, GOLD)
	# the cliff and the castle
	_poly([18, 0, 20, 16, 24, 22, 34, 22, 35, 0], ROCK)
	_r(23, 22, 32, 27, Color("e6dfcd"))
	_r(28, 22, 31, 30, Color("e6dfcd"))
	_poly([27.6, 30, 31.4, 30, 29.5, 32.5], RED_ROOF)
	_windows(23.5, 27.5, 24, 25.5, 2, WIN)
	# a pletna with its striped awning
	_poly([-30, 1.5, -20, 1.5, -18.5, 3, -31, 3], Color("6a4a30"))
	_poly([-28, 3, -21, 3, -21.5, 5, -27.5, 5], Color("e8e0c8"))
	_l(-27.5, 4.2, -21.5, 4.2, Color("b5432e"), 0.25)

## Piran: Tartini Square with the violinist's bronze statue, the tall Venetian bell tower of St George above
## (a copy of St Mark's in Venice) and the town's houses at its foot.
static func _piran_tower() -> void:
	var brick := Color("c49a6c")
	# the houses
	_r(-18, 0, -7, 11, Color("e8c88a"))
	_poly([-18.4, 11, -6.6, 11, -12.5, 14], RED_ROOF)
	_windows(-17, -8, 4, 6, 3, WIN)
	_windows(-17, -8, 7.5, 9.5, 3, WIN)
	_r(8, 0, 18, 13, Color("d9a8a0"))
	_poly([7.6, 13, 18.4, 13, 13, 15.5], RED_ROOF)
	_windows(9, 17, 4, 6, 3, WIN)
	_windows(9, 17, 8, 10.5, 3, WIN)
	# the bell tower
	_r(-3.5, 0, 3.5, 32, brick)
	_r(-3.5, 0, -2.5, 32, brick.darkened(0.15))
	if _detail(1.0):
		for y in [8.0, 16.0, 24.0]:
			_r(-3.5, y, 3.5, y + 0.4, brick.darkened(0.2))
	_r(-4, 32, 4, 33, WHITE)
	_r(-3.5, 33, 3.5, 38, WHITE)
	for x in [-1.8, 0.0, 1.8]:
		_arched(x, 33.6, 1.1, 3.6, DARK)
	_r(-4, 38, 4, 39, WHITE)
	_poly([-3.5, 39, 3.5, 39, 0, 45.5], Color("5a7a6a"))
	_r(-0.15, 45.5, 0.15, 47.5, GOLD)
	_c(0, 47, 0.5, GOLD) # the angel
	# Tartini on his pedestal
	_r(-7, 0, -4.4, 2.6, Color("b9b4a8"))
	var bz := Color("4f5a4a")
	_r(-6.2, 2.6, -5.2, 5.6, bz)
	_c(-5.7, 6.2, 0.6, bz)
	_l(-5.4, 5.0, -4.2, 5.6, bz, 0.25) # the bow arm
