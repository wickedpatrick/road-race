class_name LandmarksAtT2
extends RefCounted
## Austrian landmarks of the towns between the map cities, drawn with LandmarkPainter's helpers (metres from the
## base point, y up).

const WHITE := Color("f2efe6")
const CREAM := Color("efe3c6")
const RED_ROOF := Color("b5432e")
const COPPER := Color("5f9e86")
const WATER := Color("4f8fc0")
const WATER_L := Color("9cc8e6")
const ROCK := Color("8f8a80")
const GRASS := Color("5d8f42")
const TREE := Color("3f6f34")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const WOOD := Color("7a5634")
const GOLD := Color("d8b14a")
const AT_RED := Color("c8102e")
const SLATE := Color("4a4f57")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"kraftwerk_ybbs": _kraftwerk_ybbs()
		"stadtturm_enns": _stadtturm_enns()
		"solarbaum_gleisdorf": _solarbaum_gleisdorf()
		"schloss_velden": _schloss_velden()
		"burg_kreuzenstein": _burg_kreuzenstein()
		"samson_lungau": _samson_lungau()
		"liechtensteinklamm": _liechtensteinklamm()
		"trisanna_bridge": _trisanna_bridge()
		"gloeckler_ebensee": _gloeckler_ebensee()
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

## A baroque bulb (onion) dome of width w and height h standing on (x, y), with a little lantern and cross on top.
static func _bulb(x: float, y: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.5, y, x + w * 0.5, y, x + w * 0.6, y + h * 0.3, x + w * 0.45, y + h * 0.55, x + w * 0.12, y + h * 0.75,
		x, y + h * 0.8, x - w * 0.12, y + h * 0.75, x - w * 0.45, y + h * 0.55, x - w * 0.6, y + h * 0.3], col)
	_poly([x - w * 0.5, y, x - w * 0.15, y, x - w * 0.2, y + h * 0.5, x - w * 0.45, y + h * 0.55, x - w * 0.6, y + h * 0.3],
		col.lightened(0.15))
	_r(x - w * 0.08, y + h * 0.78, x + w * 0.08, y + h * 0.9, col.darkened(0.15))
	_l(x, y + h * 0.9, x, y + h, GOLD, 0.12)

## A rounded tree crown on a trunk.
static func _tree(x: float, y: float, r: float) -> void:
	_r(x - r * 0.12, y, x + r * 0.12, y + r, WOOD)
	_c(x, y + r * 1.4, r, TREE)
	_c(x - r * 0.35, y + r * 1.6, r * 0.55, TREE.lightened(0.1))

## A round tower from y0 to y1 with a pointed cone roof `rh` high: shaded at both sides, light in the middle.
static func _round_tower(x: float, y0: float, y1: float, w: float, rh: float, col: Color, roof: Color) -> void:
	_r(x - w * 0.5, y0, x + w * 0.5, y1, col)
	_r(x - w * 0.5, y0, x - w * 0.3, y1, col.darkened(0.12))
	_r(x + w * 0.3, y0, x + w * 0.5, y1, col.darkened(0.12))
	_r(x - w * 0.1, y0, x + w * 0.1, y1, col.lightened(0.08))
	_poly([x - w * 0.6, y1, x + w * 0.6, y1, x, y1 + rh], roof)
	_poly([x - w * 0.6, y1, x - w * 0.15, y1, x, y1 + rh], roof.lightened(0.12))

## Ybbs-Persenbeug, the first power station across the Danube: the long concrete weir with its steel gates and
## white water under them, a yellow gantry crane on top, the power house, and Persenbeug Castle on its rock.
static func _kraftwerk_ybbs() -> void:
	_r(-35, 0, 35, 3, WATER)
	if _detail(1.0):
		_r(-30, 1.2, -22, 1.5, WATER_L)
		_r(-2, 0.6, 8, 0.9, WATER_L)
	var con := Color("cfcac0")
	var cd := con.darkened(0.15)
	# the power house on the left bank
	_r(-35, 0, -27, 12, cd)
	_r(-35, 12, -27, 13, con)
	_windows(-34, -28, 6, 10, 3, WIN)
	# the weir: piers and gates
	for k in 8:
		var x := -26.0 + k * 6.0
		_r(x - 1.2, 0, x + 1.2, 13, con)
		_r(x - 1.2, 0, x - 0.6, 13, con.lightened(0.08))
		if k < 7:
			_r(x + 1.2, 3.2, x + 4.8, 9.5, Color("4d6b6a"))
			_r(x + 1.2, 9.5, x + 4.8, 10, Color("3b5352"))
			_r(x + 1.2, 2.2, x + 4.8, 3.2, Color("e8f1f6"))
			if _detail(1.2):
				_r(x + 1.6, 1.4, x + 4.4, 2.2, WATER_L)
	_r(-27.5, 13, 18.5, 14.5, cd)
	# the gantry crane riding on the weir
	var cr := Color("e8b030")
	_l(-12, 14.5, -10.5, 20, cr, 0.45)
	_l(-3, 14.5, -4.5, 20, cr, 0.45)
	_r(-13, 20, -2, 21.2, cr)
	_r(-9, 18.4, -6, 20, cr.darkened(0.2))
	# Persenbeug Castle on the rock of the other bank
	_poly([18, 0, 19, 4, 22, 7, 35, 7.5, 35, 0], ROCK)
	_poly([18, 0, 19, 4, 21, 5.5, 23, 0], ROCK.darkened(0.12))
	_r(21, 7, 34, 14, WHITE)
	_windows(22, 27, 9, 12, 3, WIN)
	_poly([20.5, 14, 34.5, 14, 33, 16.5, 22, 16.5], RED_ROOF)
	_r(28, 7, 32, 19, WHITE.darkened(0.06))
	_windows(29, 31, 15.5, 17.5, 1, WIN)
	_bulb(30, 19, 3.6, 3, COPPER)

## The Enns city tower: a free-standing Renaissance tower, a gateway through its foot, rusticated corners, clock
## faces, a gallery and a green-copper onion dome with a lantern.
static func _stadtturm_enns() -> void:
	var st := Color("e9ddc2")
	var sd := st.darkened(0.14)
	_r(-4.5, 0, 4.5, 36, st)
	_r(-4.5, 0, -3.5, 36, sd)
	if _detail(0.8):
		for k in 12:
			var y := k * 3.0
			var xo := 0.6 if k % 2 == 0 else 0.0
			_r(-4.5, y + 0.3, -3.2 + xo, y + 1.6, Color("d2c3a2"))
			_r(3.2 - xo, y + 0.3, 4.5, y + 1.6, Color("d2c3a2"))
	# the gateway at its foot
	_poly([-2, 0, 2, 0, 2, 4.5] + _arc(0, 4.5, 2, 2, 0, PI, 8) + [-2, 4.5], DARK)
	for y in [12.0, 20.0, 28.0]:
		_poly([-0.8, y, 0.8, y, 0.8, y + 2.4] + _arc(0, y + 2.4, 0.8, 0.8, 0, PI, 4), WIN)
	_r(-5, 36, 5, 37.2, sd)
	# the clock storey
	_r(-4, 37.2, 4, 46, st)
	_r(-4, 37.2, -3.2, 46, sd)
	_c(0, 41.6, 2.4, DARK)
	_c(0, 41.6, 2.1, Color("2f4f8a"))
	_l(0, 41.6, 0, 43.2, GOLD, 0.25)
	_l(0, 41.6, 1.2, 41.0, GOLD, 0.25)
	# the gallery
	_r(-5, 46, 5, 46.8, sd)
	if _detail(0.8):
		for x in range(-4, 5, 2):
			_r(x - 0.15, 46.8, x + 0.15, 48, sd)
	_r(-5, 47.8, 5, 48.2, sd)
	# the top storey and the dome
	_r(-3, 46.8, 3, 51, st.lightened(0.04))
	_windows(-2.2, 2.2, 48.6, 50.4, 2, WIN)
	_bulb(0, 51, 6.2, 9, COPPER)

## The solar tree of Gleisdorf, the "sun town": a steel trunk with branches that carry blue solar panels instead
## of leaves.
static func _solarbaum_gleisdorf() -> void:
	_r(-3, 0, 3, 0.5, Color("9a9a96"))
	var st := Color("8d949b")
	_l(0, 0.5, 0, 10, st, 0.7)
	var ends := [[-6.2, 12], [6.2, 12], [-4.2, 15], [4.2, 15], [0, 16.8], [-6.5, 8.5], [6.5, 8.5], [-2, 12.5], [2, 12.5]]
	var forks := [[0, 6], [0, 6], [0, 9], [0, 9], [0, 10], [0, 4.5], [0, 4.5], [0, 9], [0, 9]]
	for k in ends.size():
		_l(forks[k][0], forks[k][1], ends[k][0], ends[k][1] - 0.4, st, 0.3)
	for e in ends:
		var x: float = e[0]
		var y: float = e[1]
		_poly([x - 1.4, y - 0.5, x + 1.4, y - 0.1, x + 1.2, y + 1.1, x - 1.6, y + 0.7], Color("e0e4e8"))
		_poly([x - 1.25, y - 0.35, x + 1.25, y, x + 1.07, y + 0.95, x - 1.43, y + 0.6], Color("2a4a86"))
		if _detail(2.0):
			_l(x - 0.08, y - 0.2, x - 0.25, y + 0.8, Color("5a7cc0"), 0.06)
			_l(x - 1.35, y + 0.13, x + 1.15, y + 0.48, Color("5a7cc0"), 0.06)

## Velden Castle on the Wörthersee: a cream Renaissance palace with a red roof, a stone portal and two corner
## towers with onion domes, the lake with a little boat in front.
static func _schloss_velden() -> void:
	_r(-25, 0, 25, 3, WATER)
	if _detail(1.0):
		_r(-22, 1.2, -12, 1.5, WATER_L)
		_r(8, 0.6, 20, 0.9, WATER_L)
	# a little white boat
	_poly([-21, 1.6, -15, 1.6, -14, 2.6, -22, 2.6], Color.WHITE)
	_r(-19, 2.6, -16.5, 3.6, Color("d8dde2"))
	_r(-25, 3, 25, 4, GRASS)
	_tree(-22, 4, 2.4)
	_tree(22, 4, 2.4)
	var w := CREAM
	var wd := w.darkened(0.12)
	_r(-14, 4, 14, 17, w)
	_r(-14, 10.4, 14, 10.9, wd)
	_windows(-12.5, -3.5, 6, 9, 3, WIN)
	_windows(3.5, 12.5, 6, 9, 3, WIN)
	_windows(-12.5, 12.5, 12.5, 15.5, 7, WIN)
	_poly([-14.8, 17, 14.8, 17, 12, 21.5, -12, 21.5], RED_ROOF)
	# the portal and its gable
	_r(-3, 4, 3, 17, wd)
	_poly([-1.4, 4, 1.4, 4, 1.4, 7.5] + _arc(0, 7.5, 1.4, 1.4, 0, PI, 6) + [-1.4, 7.5], Color("5a3b26"))
	_poly([-3.4, 17, 3.4, 17, 3.4, 19, 2, 19, 2, 21, 1, 21, 1, 23, -1, 23, -1, 21, -2, 21, -2, 19, -3.4, 19], wd)
	_c(0, 19.4, 0.8, WIN)
	# corner towers
	for x in [-16.0, 16.0]:
		_r(x - 2.5, 4, x + 2.5, 20, w)
		_r(x - 2.5, 4, x - 1.7, 20, wd)
		_windows(x - 1.2, x + 1.2, 7, 9, 1, WIN)
		_windows(x - 1.2, x + 1.2, 13, 15, 1, WIN)
		_r(x - 2.8, 20, x + 2.8, 20.6, wd)
		_bulb(x, 20.6, 4.4, 5.4, Color("6b3a2e"))

## Kreuzenstein Castle above the Danube near Korneuburg: grey stone towers with steep pointed slate roofs, the tall
## keep, a half-timbered bay and walls with battlements on a wooded hill.
static func _burg_kreuzenstein() -> void:
	_poly([-30, 0, -24, 6, -14, 11, 0, 12.5, 14, 11, 24, 6, 30, 0], GRASS)
	_poly([-30, 0, -24, 6, -18, 8, -10, 0], GRASS.lightened(0.08))
	for t in [[-25.0, 1.5, 2.2], [-20.0, 4.0, 2.0], [22.0, 2.0, 2.4], [26.0, 0.5, 1.8], [17.0, 6.0, 1.8]]:
		_tree(t[0], t[1], t[2])
	var st := Color("a39886")
	var sd := st.darkened(0.15)
	# the walls
	_r(-17, 11, 16, 20, st)
	for x in range(-17, 16, 2):
		_r(x, 20, x + 1, 21, st)
	_poly([-2, 11, 2, 11, 2, 14] + _arc(0, 14, 2, 2, 0, PI, 6) + [-2, 14], DARK)
	_windows(-14, -6, 15, 18, 3, WIN)
	# a hall with a half-timbered bay
	_r(5, 20, 13, 25, Color("efe6d4"))
	if _detail(0.8):
		for x in [5.0, 7.0, 9.0, 11.0, 13.0]:
			_l(x, 20, x, 25, WOOD, 0.25)
		_l(5, 22.5, 13, 22.5, WOOD, 0.25)
	_poly([4.5, 25, 13.5, 25, 9, 29], SLATE)
	# the square tower
	_r(-11, 18, -6, 27, st)
	_r(-11, 18, -10, 27, sd)
	_windows(-10, -7, 23, 25, 1, WIN)
	_poly([-11.5, 27, -5.5, 27, -8.5, 32], SLATE)
	# round towers at the corners
	_round_tower(-17.5, 11, 25, 4.4, 6, st, SLATE)
	_round_tower(15.5, 11, 23, 4, 5.5, st, SLATE)
	# the tall keep with its spire
	_r(-3, 18, 3, 28, st)
	_r(-3, 18, -2, 28, sd)
	_windows(-1.8, 1.8, 23, 26, 1, WIN)
	_r(-3.4, 28, 3.4, 29, sd)
	_poly([-3.4, 29, 3.4, 29, 0, 36], SLATE)
	_poly([-3.4, 29, -0.8, 29, 0, 36], SLATE.lightened(0.15))

## A Lungau Samson: a giant of wood and cloth, carried by one strong man in summer parades, with a plumed helmet,
## a black beard, a sword and a jawbone, two little dwarfs walking beside him.
static func _samson_lungau() -> void:
	# the carrier's legs under the skirt
	_r(-0.6, 0, -0.15, 1.7, Color("3a3430"))
	_r(0.15, 0, 0.6, 1.7, Color("3a3430"))
	_r(-0.75, 0, -0.1, 0.25, DARK)
	_r(0.1, 0, 0.75, 0.25, DARK)
	# the robe
	var red := Color("b0302a")
	_poly([-1.4, 1.6, 1.4, 1.6, 0.9, 4.6, -0.9, 4.6], red)
	_r(-1.4, 1.6, 1.4, 1.9, GOLD)
	_poly([-1.4, 1.9, -0.5, 1.9, -0.6, 4.6, -0.9, 4.6], red.lightened(0.12))
	# the armour and the arms
	_poly([-0.9, 4.5, 0.9, 4.5, 1.0, 6.0, -1.0, 6.0], Color("c9cdd2"))
	_r(-0.9, 4.5, 0.9, 4.75, GOLD)
	_l(-0.9, 5.8, -1.9, 4.9, red, 0.4)
	_l(0.9, 5.8, 1.8, 5.3, red, 0.4)
	_c(-1.95, 4.85, 0.22, Color("e8b896"))
	_c(1.85, 5.3, 0.22, Color("e8b896"))
	# the sword held up and the jawbone
	_l(1.85, 5.0, 1.85, 7.9, Color("d0d4d8"), 0.18)
	_r(1.5, 5.6, 2.2, 5.75, GOLD)
	_poly([-2.6, 4.2, -2.0, 4.6, -1.9, 5.3, -2.3, 5.0, -2.75, 4.5], Color("f0ead8"))
	# the head: face, beard, helmet and plume
	_c(0, 6.6, 0.5, Color("e8b896"))
	_poly([-0.5, 6.5, 0.5, 6.5, 0.35, 5.9, 0, 5.7, -0.35, 5.9], Color("2a2420"))
	_c(-0.18, 6.75, 0.07, DARK)
	_c(0.18, 6.75, 0.07, DARK)
	_poly([-0.6, 6.9, 0.6, 6.9, 0.45, 7.3, 0, 7.45, -0.45, 7.3], GOLD)
	_poly([-0.15, 7.4, 0.15, 7.4, 0.9, 8.2, 0.2, 8.0, -0.4, 8.25], Color.WHITE)
	_poly([0.0, 7.45, 0.3, 7.45, 0.7, 7.9, 0.1, 7.9], red)
	# the two dwarfs
	for d in [[-3.3, Color("2f6a3a")], [3.3, Color("3a4f8a")]]:
		var x: float = d[0]
		_r(x - 0.25, 0, x - 0.05, 0.6, DARK)
		_r(x + 0.05, 0, x + 0.25, 0.6, DARK)
		_poly([x - 0.5, 0.6, x + 0.5, 0.6, x + 0.35, 1.6, x - 0.35, 1.6], d[1])
		_c(x, 1.85, 0.3, Color("e8b896"))
		_poly([x - 0.3, 1.8, x + 0.3, 1.8, x, 1.45], Color("e8e4dc"))
		_poly([x - 0.35, 2.0, x + 0.35, 2.0, x + 0.1, 2.75], red)

## The Liechtenstein Gorge: tall rock walls only a few metres apart, white water rushing down between them, a
## wooden walkway clinging to the rock and forest on top.
static func _liechtensteinklamm() -> void:
	# the deep inside of the gorge
	_poly([-5, 0, 5, 0, 6, 30, -6, 30], Color("4c4a46"))
	# the falling water and its pool
	_poly([-1.2, 1, 1.2, 1, 1.0, 26, -0.8, 26], Color("dfeef6"))
	if _detail(0.9):
		_l(-0.3, 3, -0.2, 24, WATER_L, 0.25)
		_l(0.5, 5, 0.6, 22, WATER_L, 0.2)
	_r(-4, 0, 4, 1.4, WATER)
	_r(-1.8, 1, 1.8, 1.6, Color.WHITE)
	# the rock walls
	var rk := Color("7d7a72")
	_poly([-15, 0, -15, 29, -6, 29, -3.5, 23, -4.5, 15, -2.2, 8, -3, 0], rk)
	_poly([15, 0, 15, 29, 5.5, 29, 3.2, 24, 4.5, 16, 2.4, 9, 3.2, 0], rk.darkened(0.1))
	_poly([-15, 0, -15, 29, -11, 29, -9, 14, -10, 0], rk.lightened(0.08))
	if _detail(0.9):
		for s in [[-8.0, 26.0, -7.0, 18.0], [-12.0, 22.0, -12.5, 12.0], [9.0, 27.0, 8.0, 17.0], [12.0, 20.0, 12.5, 9.0]]:
			_l(s[0], s[1], s[2], s[3], Color("5f6a52"), 0.4)
	# forest on top
	_r(-15, 29, -6, 30, GRASS)
	_r(5.5, 29, 15, 30, GRASS)
	for x in [-13.0, -10.0, -7.5, 7.5, 10.0, 13.0]:
		_poly([x - 1.1, 29, x + 1.1, 29, x, 30], TREE)
	# the wooden walkway along the walls
	var wd := Color("8a6038")
	_l(-12, 6, -3.2, 9, wd, 0.5)
	_l(3.6, 13, 12, 16.5, wd, 0.5)
	if _detail(0.9):
		for k in 6:
			var t := k / 5.0
			_l(lerpf(-12, -3.2, t), lerpf(6, 9, t), lerpf(-12, -3.2, t), lerpf(7.2, 10.2, t), wd.darkened(0.2), 0.12)
			_l(lerpf(3.6, 12, t), lerpf(13, 16.5, t), lerpf(3.6, 12, t), lerpf(14.2, 17.7, t), wd.darkened(0.2), 0.12)
		_l(-12, 7.2, -3.2, 10.2, wd.darkened(0.2), 0.12)
		_l(3.6, 14.2, 12, 17.7, wd.darkened(0.2), 0.12)
	# the tunnel the path comes out of
	_poly([-13.8, 6, -12, 6, -12, 7.5] + _arc(-12.9, 7.5, 0.9, 0.9, 0, PI, 4), DARK)

## The Trisanna Bridge near Landeck: a long steel girder with a curved belly, high over a deep valley on stone
## abutments, a red train crossing it and the white tower of Wiesberg Castle beside it.
static func _trisanna_bridge() -> void:
	_poly([-35, 0, -35, 25, -24, 25, -13, 8, -8, 0], GRASS)
	_poly([35, 0, 35, 25, 24, 25, 13, 8, 8, 0], GRASS.darkened(0.08))
	_poly([-20, 18, -13, 8, -8, 0, -11, 0, -16, 9], ROCK)
	_poly([20, 18, 13, 8, 8, 0, 11, 0, 16, 9], ROCK.darkened(0.08))
	_r(-8, 0, 8, 1.2, WATER)
	if _detail(1.0):
		for t in [[-28.0, 22.0], [27.0, 21.0], [-17.0, 15.0], [18.0, 15.0], [-31.0, 18.0]]:
			_poly([t[0] - 1.1, t[1], t[0] + 1.1, t[1], t[0], t[1] + 2.8], TREE)
	# the stone abutments
	var stn := Color("b8ad98")
	_poly([-25, 25, -20, 25, -20, 18, -24, 21], stn)
	_poly([25, 25, 20, 25, 20, 18, 24, 21], stn)
	# the girder: straight top, curved belly, verticals and diagonals
	var g := Color("5d6670")
	var bot := []
	for k in 13:
		var x := -21.0 + k * 3.5
		var y := 25.6 - 6.0 * (1.0 - pow(x / 21.0, 2))
		bot.append(Vector2(x, y))
	for k in 12:
		_l(bot[k].x, bot[k].y, bot[k + 1].x, bot[k + 1].y, g, 0.7)
		_l(bot[k].x, bot[k].y, bot[k].x, 26.6, g, 0.35)
		if k < 6:
			_l(bot[k + 1].x, bot[k + 1].y, bot[k].x, 26.6, g, 0.3)
		else:
			_l(bot[k].x, bot[k].y, bot[k + 1].x, 26.6, g, 0.3)
	_l(bot[12].x, bot[12].y, bot[12].x, 26.6, g, 0.35)
	_r(-22, 26.2, 22, 27.3, g)
	_r(-35, 25, -22, 26.2, Color("a0968a"))
	_r(22, 25, 35, 26.2, Color("a0968a"))
	# a train on the bridge
	var tr := Color("c8102e")
	_poly([-14, 27.3, -2, 27.3, -2, 30, -12.5, 30, -14, 28.6], tr)
	_r(-1.6, 27.3, 9.6, 30, tr)
	_r(-12, 28.6, -2.6, 29.4, Color("4a4f57"))
	_windows(-1, 9, 28.6, 29.4, 5, Color("4a4f57"))
	_r(-14, 27.3, 9.6, 27.7, DARK)
	# Wiesberg Castle on the hill
	_r(-32, 25, -26, 29, WHITE.darkened(0.05))
	_r(-31, 25, -28, 32, WHITE)
	_windows(-30.4, -28.6, 29.5, 31, 1, WIN)
	_poly([-31.5, 32, -27.5, 32, -29.5, 34], RED_ROOF)
	_poly([-32.4, 29, -25.6, 29, -27, 30.5, -31, 30.5], RED_ROOF)

## Ebensee's Glöckler: men dressed all in white with bells at their belts, wearing huge glowing lanterns on their
## heads, patterned like coloured glass.
static func _gloeckler_ebensee() -> void:
	_draw_gloeckler(-2.4, 0, [Color("d8342c"), Color("2f6fc0"), Color("f2c230"), Color("3a9a4a")])
	_draw_gloeckler(2.4, 0.4, [Color("8a3ab0"), Color("f2c230"), Color("d8342c"), Color("2fa0b0")])

static func _draw_gloeckler(x: float, lift: float, cols: Array) -> void:
	var wh := Color("f4f2ec")
	var sh := Color("d8d4ca")
	# legs, body, arms
	_r(x - 0.55, 0, x - 0.1, 2.3, wh)
	_r(x + 0.1, 0, x + 0.55, 2.3, sh)
	_r(x - 0.65, 0, x - 0.05, 0.25, DARK)
	_r(x + 0.05, 0, x + 0.65, 0.25, DARK)
	_poly([x - 0.75, 2.2, x + 0.75, 2.2, x + 0.6, 4.4, x - 0.6, 4.4], wh)
	_l(x - 0.6, 4.2, x - 1.1, 2.9, wh, 0.35)
	_l(x + 0.6, 4.2, x + 1.1, 2.9, sh, 0.35)
	_r(x - 0.8, 2.5, x + 0.8, 2.8, AT_RED)
	_poly([x - 0.3, 2.5, x + 0.3, 2.5, x + 0.4, 1.9, x - 0.4, 1.9], GOLD)
	_c(x, 4.75, 0.35, Color("e8b896"))
	# the glowing lantern on the head
	var cy := 5.1 + lift
	_poly(_arc(x, cy, 2.2, 3.0, 0, PI, 16), Color("4a3a20"))
	_poly(_arc(x, cy, 2.0, 2.8, 0, PI, 16), Color("fff1b8"))
	for k in 6:
		var a0 := PI * k / 6.0 + 0.06
		var a1 := PI * (k + 1) / 6.0 - 0.06
		_poly([x, cy] + _arc(x, cy, 1.85, 2.6, a0, a1, 3), cols[k % cols.size()])
	_poly(_arc(x, cy, 0.9, 1.25, 0, PI, 10), Color("fff1b8"))
	if _detail(6.0):
		_c(x, cy + 0.6, 0.35, cols[2])
	_r(x - 2.2, cy - 0.15, x + 2.2, cy + 0.1, Color("4a3a20"))
