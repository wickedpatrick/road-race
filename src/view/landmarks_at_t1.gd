class_name LandmarksAtT1
extends RefCounted
## Austrian landmarks of the towns between the map cities, drawn with LandmarkPainter's helpers (metres from the
## base point, y up).

const WHITE := Color("f2efe6")
const YELLOW := Color("e8c35a")
const RED_ROOF := Color("b5432e")
const COPPER := Color("5f9e86")
const WATER := Color("4f8fc0")
const WATER_L := Color("9cc8e6")
const ROCK := Color("8f8a80")
const STONE := Color("b8ad98")
const GRASS := Color("5d8f42")
const TREE := Color("3f6f34")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const WOOD := Color("7a5634")
const GOLD := Color("d8b14a")
const AT_RED := Color("c8102e")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"beethoventempel": _beethoventempel()
		"stift_herzogenburg": _stift_herzogenburg()
		"wachauer_marille": _wachauer_marille()
		"wurbauerkogel": _wurbauerkogel()
		"burgbau_friesach": _burgbau_friesach()
		"schloss_wolfsberg": _schloss_wolfsberg()
		"schloss_fuschl": _schloss_fuschl()
		"narzissenfest": _narzissenfest()
		"muenzerturm_hall": _muenzerturm_hall()
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

## A pointed fir tree.
static func _fir(x: float, y: float, h: float) -> void:
	_r(x - h * 0.04, y, x + h * 0.04, y + h * 0.2, WOOD)
	_poly([x - h * 0.22, y + h * 0.15, x + h * 0.22, y + h * 0.15, x, y + h], TREE.darkened(0.1))

## Baden's Beethoven temple in the spa park: a small round temple of white columns under a green copper dome, on a
## terrace with steps, trees of the park around it.
static func _beethoventempel() -> void:
	_r(-8, 0, 8, 1, GRASS)
	_tree(-6.4, 1, 1.2)
	_tree(6.4, 1, 1.2)
	var w := WHITE
	var wd := w.darkened(0.14)
	# the terrace and its steps
	_r(-5.5, 1, 5.5, 2.4, STONE)
	for k in 3:
		_r(-2 + k * 0.3, 1 + k * 0.45, 2 - k * 0.3, 1.45 + k * 0.45, STONE.lightened(0.12))
	# the floor, the dark inside and the columns
	_r(-4.4, 2.4, 4.4, 3.0, w)
	_r(-3.6, 3.0, 3.6, 8.2, Color("8d8a80"))
	if _detail(1.5):
		_c(0, 5.6, 0.8, Color("e8e4d8")) # the bust of Beethoven inside
		_r(-0.5, 3.0, 0.5, 4.8, Color("e8e4d8"))
	for k in 6:
		var x := -3.8 + k * 1.52
		_r(x - 0.3, 3.0, x + 0.3, 8.2, w if k > 0 and k < 5 else wd)
	# the round beam and the dome
	_r(-4.4, 8.2, 4.4, 9.2, w)
	_r(-4.4, 8.9, 4.4, 9.2, wd)
	_poly([-4.0, 9.2, 4.0, 9.2] + _arc(0, 9.2, 4.0, 3.6, 0, PI, 12), COPPER)
	_poly([-4.0, 9.2, -1.6, 9.2, -1.2, 12.2, -2.6, 11.9, -3.6, 10.8], COPPER.lightened(0.15))
	_r(-0.5, 12.8, 0.5, 13.4, w)
	_c(0, 13.6, 0.3, GOLD)

## Herzogenburg Abbey: a long yellow-and-white baroque front of the monastery and its church tower, crowned not by
## an onion dome but by a big golden-red ducal hat, the sign of the town's name.
static func _stift_herzogenburg() -> void:
	_r(-17, 0, 17, 1, GRASS)
	var y := Color("efcf6a")
	var w := WHITE
	# the long monastery wing
	_r(-16, 1, 16, 13, y)
	_poly([-16.5, 13, 16.5, 13, 15, 15.5, -15, 15.5], Color("7a4a3a"))
	for x in [-16.0, -8.0, 8.0, 16.0]:
		_r(x - 0.4, 1, x + 0.4, 13, w)
	_r(-16, 6.8, 16, 7.3, w)
	for row in [[2.5, 5.2], [8.5, 11.5]]:
		_windows(-15, -9, row[0], row[1], 4, WIN)
		_windows(9, 15, row[0], row[1], 4, WIN)
	# the church front and its tower in the middle
	_r(-6, 1, 6, 20, y)
	_poly([-6, 20, 6, 20, 0, 24], y)
	_poly([-4.8, 20.4, 4.8, 20.4, 0, 23.2], w)
	_r(-6.3, 19.6, 6.3, 20.3, w)
	_poly([-1.6, 1, 1.6, 1, 1.6, 5] + _arc(0, 5, 1.6, 1.4, 0, PI, 6), Color("5a3b26"))
	_windows(-5, 5, 9, 13, 3, WIN)
	_r(-3.4, 20, 3.4, 34, y)
	_r(-3.4, 20, -2.8, 34, w)
	_r(2.8, 20, 3.4, 34, w)
	_r(-3.7, 33.4, 3.7, 34.2, w)
	_c(0, 27.5, 1.5, w) # the clock
	_c(0, 27.5, 1.2, Color("2e4a6a"))
	_l(0, 27.5, 0, 28.4, GOLD, 0.15)
	_l(0, 27.5, 0.6, 27.5, GOLD, 0.15)
	_poly([-1, 30, 1, 30, 1, 32.2] + _arc(0, 32.2, 1, 0.8, 0, PI, 4), WIN)
	# the ducal hat: a red cap in a golden ring with golden hoops and a cross-orb
	_r(-4.4, 34.2, 4.4, 35.8, GOLD)
	if _detail(1.0):
		for x in [-3.0, 0.0, 3.0]:
			_c(x, 35.0, 0.35, AT_RED)
	_poly([-3.8, 35.8, 3.8, 35.8, 3.6, 37.0] + _arc(0, 37.0, 3.6, 3.0, 0, PI, 10), Color("b3262c"))
	_poly([-3.8, 35.8, -1.6, 35.8, -1.6, 39.4, -2.8, 39.2, -3.6, 37.0], Color("cc4046"))
	_l(0, 35.8, 0, 40.0, GOLD, 0.4)
	_pl_arc(0, 36.8, 3.6, 3.2)
	_c(0, 40.5, 0.7, GOLD)
	_l(0, 41, 0, 42, GOLD, 0.2)
	_l(-0.45, 41.5, 0.45, 41.5, GOLD, 0.2)

## A golden hoop over the ducal hat.
static func _pl_arc(cx: float, cy: float, rx: float, ry: float) -> void:
	var p := _arc(cx, cy, rx, ry, 0, PI, 10)
	for k in range(0, p.size() - 2, 2):
		_l(p[k], p[k + 1], p[k + 2], p[k + 3], GOLD, 0.25)

## Wachau apricots from Spitz: an apricot tree full of orange fruit on the Danube bank, a wooden crate heaped with
## apricots beside it, the vineyard hill and the river behind.
static func _wachauer_marille() -> void:
	_poly([-8, 1.6, -8, 6, -4, 8.4, 1, 7.6, 5, 5.4, 8, 4, 8, 1.6], Color("7fa54e"))
	if _detail(2.0):
		for k in 5:
			var y := 2.4 + k * 1.1
			_l(-7.6, y, 6.4 - k * 1.6, y + 0.3, GRASS.darkened(0.15), 0.1) # vine rows on the hill
	_r(-8, 0.8, 8, 1.8, WATER)
	if _detail(2.0):
		_r(-6, 1.2, -3, 1.35, WATER_L)
	_r(-8, 0, 8, 0.9, GRASS)
	# the apricot tree
	_poly([-3.2, 0.5, -2.4, 0.5, -2.5, 3.2, -1.6, 4.6, -2.2, 4.8, -2.9, 3.8, -3.8, 4.8, -4.3, 4.5, -3.2, 3.2], WOOD)
	_c(-2.8, 6.0, 2.6, TREE)
	_c(-4.4, 5.2, 1.6, TREE.lightened(0.08))
	_c(-1.2, 5.4, 1.7, TREE.lightened(0.04))
	_c(-3.0, 7.4, 1.6, TREE.lightened(0.12))
	var ap := Color("f0902a")
	for p in [[-4.6, 5.6], [-3.2, 4.4], [-1.6, 6.2], [-2.6, 7.6], [-4.0, 7.0], [-0.6, 4.8], [-5.4, 4.6], [-2.0, 5.0]]:
		_c(p[0], p[1], 0.38, ap)
		if _detail(2.5):
			_c(p[0] - 0.12, p[1] + 0.12, 0.14, Color("f8c060"))
	# the crate heaped with apricots
	_r(1.2, 0.3, 6.2, 2.4, Color("b8874e"))
	_r(1.2, 1.25, 6.2, 1.45, Color("8a6136"))
	_r(1.2, 0.3, 1.5, 2.4, Color("8a6136"))
	_r(5.9, 0.3, 6.2, 2.4, Color("8a6136"))
	for k in 6:
		_c(1.8 + k * 0.85, 2.6, 0.48, ap if k % 2 == 0 else ap.darkened(0.08))
	for k in 4:
		_c(2.6 + k * 0.85, 3.3, 0.48, ap.lightened(0.05))
	_c(3.9, 3.9, 0.48, ap)
	_poly([3.9, 4.3, 4.6, 4.8, 4.2, 4.3], GRASS) # a leaf on top

## The Wurbauerkogel above Windischgarsten: a green hill with the alpine coaster's track snaking down and a child on
## the sled, the panorama tower on the top and the rocky peaks behind.
static func _wurbauerkogel() -> void:
	_poly([-20, 0, -20, 12, -14, 21, -8, 15, -2, 25, 6, 17, 13, 23, 20, 12, 20, 0], Color("a9adb5"))
	_poly([-4, 22, -2, 25, 0, 22.5], Color("eef2f6"))
	_poly([11, 21, 13, 23, 15, 20.5], Color("eef2f6"))
	_poly([-20, 0, -20, 5, -12, 10, -4, 13, 2, 14, 10, 11, 20, 4, 20, 0], GRASS)
	_poly([-20, 0, -20, 5, -12, 10, -10, 6, -14, 0], GRASS.lightened(0.1))
	_fir(-16, 4.5, 3.5)
	_fir(15, 3.5, 3.4)
	_fir(17.5, 2, 3)
	# the coaster track down the slope
	var track := [1, 13.6, -3, 11.6, 2, 9.4, -4, 7.2, 3, 4.6, -6, 2.4, -14, 0.6]
	for k in range(0, track.size() - 2, 2):
		_l(track[k], track[k + 1], track[k + 2], track[k + 3], Color("d0d4da"), 0.45)
	# the sled with a child in a red jacket
	_r(-4.4, 7.4, -1.8, 8.0, Color("e1a21e"))
	_r(-3.4, 8.0, -2.4, 9.3, AT_RED)
	_c(-2.9, 9.8, 0.55, Color("f0c8a0"))
	_r(-3.5, 10.1, -2.3, 10.4, Color("2f5d8a"))
	# the panorama tower: a slim steel frame with a glass room on top
	var st := Color("6e757e")
	_l(-0.2, 14, 1.4, 22, st, 0.45)
	_l(3.8, 14, 2.2, 22, st, 0.45)
	_l(0.3, 16.5, 3.3, 19.5, st, 0.22)
	_l(3.3, 16.5, 0.3, 19.5, st, 0.22)
	_r(-0.2, 22, 3.8, 24.4, Color("9fd2ec"))
	_r(-0.2, 22, 3.8, 22.4, st)
	_poly([-0.6, 24.4, 4.2, 24.4, 1.8, 25.6], st)
	_l(1.8, 25.6, 1.8, 26, st, 0.1)

## The castle site in Friesach, where a castle is being built just as in the Middle Ages: a half-finished stone keep
## with wooden scaffolding, a big wooden treadwheel crane lifting a block, a cart of stones.
static func _burgbau_friesach() -> void:
	_r(-16, 0, 16, 1, Color("a58b5e"))
	var s := STONE
	var sd := s.darkened(0.15)
	# the wall, finished on the left, still low on the right
	_r(-15, 1, -2, 9, s)
	for x in range(-15, -2, 2):
		_r(x, 9, x + 1, 10, s)
	_poly([-2, 1, 8, 1, 8, 4, 5, 4, 5, 6, 1, 6, 1, 8, -2, 8], s)
	if _detail(1.1):
		for row in [3.0, 6.0]:
			_r(-15, row, 5, row + 0.15, sd)
	# the keep, still without its top
	_r(-11, 1, -4, 17, s)
	_r(-11, 1, -10, 17, sd)
	_poly([-11, 17, -9, 17, -9, 17.8, -7, 17.8, -7, 17, -4, 17, -4, 16, -11, 16], s)
	_poly([-8.5, 1, -6.5, 1, -6.5, 3.6] + _arc(-7.5, 3.6, 1, 0.9, 0, PI, 4), DARK)
	_r(-8.1, 11, -7.1, 13, DARK)
	# wooden scaffolding along the keep
	for x in [-12.4, -2.6]:
		_l(x, 1, x, 19, WOOD, 0.25)
	for y in [6.0, 11.0, 16.0]:
		_r(-12.8, y, -2.2, y + 0.35, WOOD.lightened(0.15))
	_l(-12.4, 6, -2.6, 11, WOOD, 0.18)
	_l(-12.4, 11, -2.6, 16, WOOD, 0.18)
	# the treadwheel crane
	var wd := WOOD
	_c(11, 7.5, 4.6, wd)
	_c(11, 7.5, 4.0, Color("c7a27a"))
	for a in 6:
		var an := a * PI / 6
		_l(11 - cos(an) * 4, 7.5 - sin(an) * 4, 11 + cos(an) * 4, 7.5 + sin(an) * 4, wd, 0.22)
	_c(11, 7.5, 0.6, wd.darkened(0.2))
	_l(8, 1, 11, 7.5, wd, 0.4)
	_l(14, 1, 11, 7.5, wd, 0.4)
	# the crane's mast and jib, the rope and the block
	_l(11, 7.5, 11, 20, wd, 0.6)
	_l(11, 20, 3, 18.6, wd, 0.5)
	_l(11, 15, 4.5, 18.7, wd, 0.3)
	_l(3.4, 18.6, 3.4, 12, Color("ddd2b4"), 0.12)
	_r(2.4, 10.6, 4.4, 12, s.lightened(0.05))
	# a cart of stones
	_r(-15, 1.6, -11.6, 3.2, wd)
	_c(-14.3, 1.4, 0.6, DARK)
	_c(-12.3, 1.4, 0.6, DARK)
	for x in [-14.4, -13.2, -12.1]:
		_c(x, 3.6, 0.5, sd)

## Wolfsberg Castle over the Lavant valley: a white castle rebuilt in the English Tudor style, with crenellated walls,
## square towers and thin pointed turrets, standing on the wooded hill above the town.
static func _schloss_wolfsberg() -> void:
	_poly([-22, 0, -22, 4, -14, 9, -4, 11, 8, 11, 16, 8, 22, 3, 22, 0], TREE)
	_poly([-22, 0, -22, 4, -14, 9, -12, 5, -16, 0], TREE.lightened(0.1))
	_poly([12, 0, 16, 4, 22, 3, 22, 0], GRASS)
	var w := Color("f4f1ea")
	var wd := w.darkened(0.12)
	# the main block
	_r(-14, 10, 14, 20, w)
	for x in range(-14, 14, 2):
		_r(x, 20, x + 1, 21, w)
	_windows(-12, 12, 12, 14.5, 8, WIN)
	_windows(-12, 12, 16, 18.5, 8, WIN)
	# square towers at both ends and a taller one in the middle
	for x in [-14.0, 12.0]:
		_r(x - 1, 10, x + 3, 24, wd)
		for k in 2:
			_r(x - 1 + k * 2.2, 24, x - 1 + k * 2.2 + 1.2, 25, wd)
		_windows(x - 0.5, x + 2.5, 20, 22.5, 1, WIN)
	_r(-3, 10, 3, 27, w)
	_r(-3, 10, -2, 27, wd)
	for k in 3:
		_r(-3 + k * 2.2, 27, -3 + k * 2.2 + 1.4, 28.2, w)
	_poly([-1, 22, 1, 22, 1, 24.4, 0, 25.4, -1, 24.4], WIN)
	_poly([-1.4, 10, 1.4, 10, 1.4, 12.6, 0, 14, -1.4, 12.6], Color("5a3b26")) # a Tudor arch
	# thin pointed turrets at the corners
	for x in [-9.0, 8.0, -4.2, 4.2]:
		_r(x - 0.5, 18, x + 0.5, 25 if absf(x) > 5 else 29, wd)
		var top := 25.0 if absf(x) > 5 else 29.0
		_poly([x - 0.7, top, x + 0.7, top, x, top + 2], Color("6b6e74"))
	# a red-white-red flag on the middle tower
	_l(0, 28.2, 0, 30, Color("8a8d92"), 0.15)
	_r(0, 28.8, 2.2, 29.2, AT_RED)
	_r(0, 29.2, 2.2, 29.6, Color.WHITE)
	_r(0, 29.6, 2.2, 30, AT_RED)

## Schloss Fuschl: the old hunting castle of the Salzburg archbishops, a square white tower house with a steep hipped
## roof and a little lantern, on a green point of land in the clear Fuschlsee, the forest behind.
static func _schloss_fuschl() -> void:
	_poly([-13, 3, -13, 12, -6, 15, 4, 14, 13, 10, 13, 3], TREE.darkened(0.08))
	_fir(-11, 3, 7)
	_fir(10.5, 3, 6)
	_r(-13, 0, 13, 3, WATER)
	if _detail(1.0):
		_r(-11, 1.0, -5, 1.3, WATER_L)
		_r(6, 1.8, 11, 2.1, WATER_L)
	_poly([-8, 3, -6, 4, 6, 4, 8, 3], GRASS)
	var w := Color("f2ede0")
	var wd := w.darkened(0.12)
	_r(-5, 4, 5, 16, w)
	_r(-5, 4, -3.8, 16, wd)
	_r(-5, 4, 5, 4.8, STONE)
	# windows with red-and-white shutters
	for y in [6.5, 10.0, 13.2]:
		for x in [-2.6, 0.0, 2.6]:
			_r(x - 0.5, y, x + 0.5, y + 1.6, WIN)
			if _detail(1.4):
				_r(x - 0.9, y, x - 0.5, y + 1.6, AT_RED)
				_r(x + 0.5, y, x + 0.9, y + 1.6, AT_RED)
	_r(-0.8, 4.8, 0.8, 6.0, Color("5a3b26"))
	# the steep roof, a lantern and a flag
	_poly([-5.8, 16, 5.8, 16, 1.4, 21.5, -1.4, 21.5], RED_ROOF)
	_poly([-5.8, 16, -2.6, 16, -0.6, 21.5, -1.4, 21.5], RED_ROOF.lightened(0.12))
	_r(-0.8, 21.5, 0.8, 22.6, w)
	_poly([-1.1, 22.6, 1.1, 22.6, 0, 23.8], Color("4e6c58"))
	_l(0, 23.8, 0, 24, GOLD, 0.1)
	# a little wooden jetty and a rowing boat
	_r(5, 2.6, 11, 3, WOOD)
	_poly([-11, 1.4, -6.6, 1.4, -7.2, 0.6, -10.4, 0.6], WOOD.lightened(0.1))

## The Narcissus Festival in Bad Aussee: a boat on the lake carrying a huge swan made of thousands of white
## narcissus flowers, and the meadow in front full of them.
static func _narzissenfest() -> void:
	_r(-9, 0, 9, 2.2, WATER)
	if _detail(1.5):
		_r(-8, 0.9, -5, 1.1, WATER_L)
		_r(5, 1.5, 8, 1.7, WATER_L)
	# the mountains behind the lake
	_poly([-9, 2.2, -9, 6, -5, 9, -1, 6.5, 3, 10, 9, 5, 9, 2.2], Color("a9adb5"))
	_poly([1.6, 8.6, 3, 10, 4.4, 8.8], Color("eef2f6"))
	# the boat
	_poly([-6.4, 2.8, 5.6, 2.8, 4.8, 1.6, -5.6, 1.6], WOOD)
	_r(-6.4, 2.6, 5.6, 2.9, WOOD.lightened(0.2))
	# the swan of flowers: body, neck, head, beak
	var fl := Color("fbfaf2")
	_poly([-5, 2.9, 4.4, 2.9, 3.4, 5.2, 0, 6.0, -3.4, 5.6, -5.6, 4.4], fl)
	_poly([-5.6, 4.4, -3.6, 5.8, -1.2, 7.6, -3.6, 6.8, -5.4, 5.6], Color("ecebe0")) # the wing raised
	_pl_neck(fl)
	_c(3.6, 9.2, 0.8, fl)
	_poly([4.2, 9.4, 5.6, 9.0, 4.2, 8.8], Color("f0a020"))
	_c(3.8, 9.5, 0.15, DARK)
	# yellow flower hearts all over the swan
	if _detail(2.0):
		for p in [[-3.6, 3.6], [-1.6, 4.4], [0.6, 3.6], [2.4, 4.4], [-4.4, 4.8], [-2.4, 5.6], [1.4, 5.2], [3.0, 6.6],
				[3.0, 8.0], [-2.6, 6.8]]:
			_c(p[0], p[1], 0.18, Color("f2c230"))
	# the meadow of narcissi in front
	_r(-9, 0, 9, 0.6, GRASS)
	for k in 9:
		var x := -8.0 + k * 2.0
		_l(x, 0, x, 0.9, GRASS.darkened(0.1), 0.08)
		_c(x, 1.0, 0.32, fl)
		_c(x, 1.0, 0.13, Color("f2c230"))

## The swan's curved neck.
static func _pl_neck(col: Color) -> void:
	var p := [3.0, 4.8, 3.9, 6.0, 3.6, 7.4, 3.4, 8.6]
	for k in range(0, p.size() - 2, 2):
		_l(p[k], p[k + 1], p[k + 2], p[k + 3], col, 0.9)

## The Mint Tower of Hasegg Castle in Hall, where the big silver Taler coins were first struck: a tall tower that
## turns twelve-sided at the top, under a steep spire, and a giant shiny silver coin beside it.
static func _muenzerturm_hall() -> void:
	_r(-8, 0, 8, 1, GRASS)
	var w := Color("ece4d2")
	var wd := w.darkened(0.14)
	# the castle wing at the foot
	_r(-7.5, 1, 1, 9, w)
	_poly([-8, 9, 1.5, 9, 0, 11, -6.5, 11], RED_ROOF)
	_windows(-7, 0, 4, 6.5, 3, WIN)
	# the square tower
	_r(-2, 1, 4, 22, w)
	_r(-2, 1, -1, 22, wd)
	_windows(-0.5, 3.5, 10, 12, 1, WIN)
	_windows(-0.5, 3.5, 16, 18, 1, WIN)
	_r(-2.3, 21.6, 4.3, 22.4, wd)
	# the twelve-sided top: faces shaded light to dark
	var faces := [Color("d4cbb6"), w.lightened(0.05), w, wd]
	for k in 4:
		_r(-2 + k * 1.5, 22.4, -0.5 + k * 1.5, 27, faces[k])
	_windows(-1.8, 3.8, 24, 25.8, 4, WIN)
	_r(-2.3, 27, 4.3, 27.6, wd)
	# the spire
	_poly([-2.4, 27.6, 4.4, 27.6, 1, 34], Color("5b6b62"))
	_poly([-2.4, 27.6, 0.2, 27.6, 1, 34], Color("74867b"))
	_l(1, 34, 1, 35.4, GOLD, 0.15)
	# the silver Taler with an eagle in it
	var cx := 6.2
	var cy := 4.4
	var k := 1.3
	_c(cx, cy, 3.3 * k, Color("7d8590"))
	_c(cx, cy, 3.0 * k, Color("d6dbe1"))
	_c(cx, cy, 2.4 * k, Color("b9c0c8"))
	var e := Color("8a929c")
	_poly([cx - 1.1 * k, cy + 1.0 * k, cx + 1.1 * k, cy + 1.0 * k, cx + 0.6 * k, cy - 1.0 * k, cx, cy - 1.8 * k,
		cx - 0.6 * k, cy - 1.0 * k], e)
	_c(cx, cy + 1.4 * k, 0.45 * k, e)
	_poly([cx - 1.8 * k, cy + 1.2 * k, cx - 1.1 * k, cy + 1.0 * k, cx - 0.8 * k, cy - 0.2 * k], e)
	_poly([cx + 1.8 * k, cy + 1.2 * k, cx + 1.1 * k, cy + 1.0 * k, cx + 0.8 * k, cy - 0.2 * k], e)
	if _detail(1.5):
		_c(cx - 1.0 * k, cy + 1.8 * k, 0.35 * k, Color.WHITE) # a glint
