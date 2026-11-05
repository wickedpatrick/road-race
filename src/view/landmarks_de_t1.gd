class_name LandmarksDeT1
extends RefCounted
## German landmarks of the towns between the map cities, drawn with LandmarkPainter's helpers (metres from the
## base point, y up).

const WHITE := Color("f2efe6")
const RED_ROOF := Color("b5432e")
const SLATE := Color("4a4f58")
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
const SKIN := Color("f1c9a5")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"schloss_ploen": _schloss_ploen()
		"wasserkunst_wismar": _wasserkunst_wismar()
		"colossos": _colossos()
		"steckenpferd": _steckenpferd()
		"glaselefant": _glaselefant()
		"kerpen_kart": _kerpen_kart()
		"nerobergbahn": _nerobergbahn()
		"alsfeld_rathaus": _alsfeld_rathaus()
		"gaenseliesel": _gaenseliesel()
		"veste_coburg": _veste_coburg()
		"schloss_bernburg": _schloss_bernburg()
		"spreewald_gurken": _spreewald_gurken()
		"legoland": _legoland()
		"kuerbis_ludwigsburg": _kuerbis_ludwigsburg()
		"kurhaus_baden_baden": _kurhaus_baden_baden()
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

static func _ell(cx: float, cy: float, rx: float, ry: float, rot: float, col: Color) -> void:
	LandmarkPainter._ell(cx, cy, rx, ry, rot, col)

static func _pl(xy: Array, col: Color, w: float) -> void:
	LandmarkPainter._pl(xy, col, w)

static func _detail(min_pm: float) -> bool:
	return LandmarkPainter._pm > min_pm

## A rectangle `len` long and `h` high standing on the point (cx, cy), turned by `ang` radians (its floor along ang).
static func _quad(cx: float, cy: float, ang: float, len: float, h: float, col: Color) -> void:
	var ux := cos(ang) * len * 0.5
	var uy := sin(ang) * len * 0.5
	var nx := -sin(ang) * h
	var ny := cos(ang) * h
	_poly([cx - ux, cy - uy, cx + ux, cy + uy, cx + ux + nx, cy + uy + ny, cx - ux + nx, cy - uy + ny], col)

## A rounded tree crown on a trunk.
static func _tree(x: float, y: float, r: float) -> void:
	_r(x - r * 0.12, y, x + r * 0.12, y + r, WOOD)
	_c(x, y + r * 1.4, r, TREE)
	_c(x - r * 0.35, y + r * 1.6, r * 0.55, TREE.lightened(0.1))

## A small bulb dome of width w and height h on (x, y), with a golden tip.
static func _bulb(x: float, y: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.5, y, x + w * 0.5, y, x + w * 0.6, y + h * 0.3, x + w * 0.45, y + h * 0.55, x + w * 0.12, y + h * 0.75,
		x, y + h * 0.8, x - w * 0.12, y + h * 0.75, x - w * 0.45, y + h * 0.55, x - w * 0.6, y + h * 0.3], col)
	_l(x, y + h * 0.8, x, y + h, GOLD, 0.12)

## Plön Castle: the long white palace with its dark roofs and a small tower in the middle, high on its green hill over
## the Großer Plöner See.
static func _schloss_ploen() -> void:
	_r(-25, 0, 25, 2, WATER)
	if _detail(1.0):
		_r(-22, 0.7, -12, 1.0, WATER_L)
		_r(8, 1.2, 19, 1.5, WATER_L)
	_poly([-25, 2, -22, 7, -15, 10.5, 15, 10.5, 22, 7, 25, 2], GRASS)
	_poly([-25, 2, -22, 7, -18, 9, -16, 5, -12, 2], GRASS.darkened(0.12))
	_tree(-21, 5, 1.8)
	_tree(20.5, 5, 1.8)
	_tree(17.5, 7.5, 1.4)
	var w := WHITE
	var wd := w.darkened(0.1)
	# the main block
	_r(-14, 10, 14, 20, w)
	_poly([-14.5, 20, 14.5, 20, 12, 24.5, -12, 24.5], SLATE)
	_windows(-13, 13, 11.6, 14.2, 11, WIN)
	_windows(-13, 13, 15.8, 18.4, 11, WIN)
	# the two front wings
	for x in [-14.5, 14.5]:
		_r(x - 3.5, 10, x + 3.5, 21, wd)
		_poly([x - 4, 21, x + 4, 21, x, 25], SLATE.darkened(0.1))
		_windows(x - 3, x + 3, 11.6, 14.2, 2, WIN)
		_windows(x - 3, x + 3, 15.8, 18.4, 2, WIN)
	# the middle gable, the door and the little tower
	_r(-3, 10, 3, 21, w.lightened(0.05))
	_poly([-3.4, 21, 3.4, 21, 0, 23.5], w)
	_poly([-1.2, 10, 1.2, 10, 1.2, 12.6] + _arc(0, 12.6, 1.2, 1.0, 0, PI, 6), Color("5a3b26"))
	_r(-1.1, 24.5, 1.1, 26.5, w)
	_bulb(0, 26.5, 2.4, 3.4, SLATE)

## The Wasserkunst on Wismar's market square: a twelve-sided Dutch Renaissance pavilion of pale stone with round
## arches, a green copper bell roof and a little lantern on top; it once gave the town its water.
static func _wasserkunst_wismar() -> void:
	_r(-6, 0, 6, 0.5, Color("9c958a")) # the cobbled square
	_r(-4.4, 0.5, 4.4, 1.3, Color("b8ad9a")) # steps
	var st := Color("d9cbb0")
	var sd := st.darkened(0.15)
	_r(-3.8, 1.3, 3.8, 6.4, st)
	_r(-3.8, 1.3, -2.8, 6.4, sd)
	_r(2.8, 1.3, 3.8, 6.4, sd)
	# arches between pilasters
	for x in [-1.9, 0.0, 1.9]:
		_poly([x - 0.6, 1.3, x + 0.6, 1.3, x + 0.6, 4.2] + _arc(x, 4.2, 0.6, 0.6, 0, PI, 6), Color("3d3a36"))
	if _detail(2.0):
		for x in [-2.9, -0.95, 0.95, 2.9]:
			_r(x - 0.12, 1.3, x + 0.12, 6.0, Color("b5a283"))
	_r(-4.1, 6.0, 4.1, 6.7, Color("a65a3e")) # a reddish band under the roof
	# the bell roof
	var cu := COPPER
	_poly([-4.3, 6.7, 4.3, 6.7, 3.8, 7.6, 2.6, 8.4, 1.6, 9.6, 1.1, 10.8, -1.1, 10.8, -1.6, 9.6, -2.6, 8.4, -3.8, 7.6], cu)
	_poly([-4.3, 6.7, -1.4, 6.7, -1.0, 9.6, -1.1, 10.8, -1.6, 9.6, -2.6, 8.4, -3.8, 7.6], cu.lightened(0.15))
	# the lantern
	_r(-0.8, 10.8, 0.8, 12.0, cu.darkened(0.1))
	if _detail(2.0):
		_r(-0.35, 11.0, 0.35, 11.8, WIN)
	_poly([-1.0, 12.0, 1.0, 12.0, 0, 13.0], cu)
	_l(0, 13.0, 0, 14.0, GOLD, 0.1)
	_c(0, 13.6, 0.18, GOLD)

## Colossos in Heide Park Soltau: a huge wooden roller coaster, its white-grey timber lattice, the steep lift hill
## with a red train on it, the big drop and the next hills.
static func _colossos() -> void:
	var pts := [-29.0, 1.0, -27.0, 2.0, -24.0, 5.5, -21.0, 9.5, -18.0, 13.5, -15.0, 17.5, -12.0, 21.5, -9.0, 25.5,
		-6.0, 29.5, -3.0, 33.0, -1.0, 35.5, 1.0, 36.6, 3.0, 36.0, 5.0, 33.0, 7.0, 26.0, 9.0, 17.0, 11.0, 9.0,
		13.0, 5.0, 15.0, 4.5, 17.0, 6.5, 19.0, 11.0, 21.0, 15.5, 23.0, 17.5, 25.0, 17.0, 27.0, 14.0, 29.0, 10.0]
	var wood := Color("d9cdb4")
	var wd := wood.darkened(0.25)
	_r(-30, 0, 30, 0.6, Color("9a8f7e"))
	var n := pts.size() / 2
	# the lattice: posts under the track, ledgers every 3 m and cross braces
	for k in n:
		var x: float = pts[k * 2]
		var y: float = pts[k * 2 + 1]
		_l(x, 0, x, y, wd, 0.25)
		if k + 1 < n:
			var x2: float = pts[k * 2 + 2]
			var y2: float = pts[k * 2 + 3]
			var top := minf(y, y2)
			var h := 3.0
			while h < top:
				_l(x, h, x2, h, wood, 0.15)
				if _detail(1.5):
					_l(x, h - 3.0, x2, h, wood.darkened(0.1), 0.1)
				h += 3.0
	# the track
	_pl(pts, Color("6b3a2a"), 0.7)
	if _detail(1.2):
		_pl(pts, Color("a8a8a8"), 0.2)
	# the train going up the lift hill
	var ang := atan2(4.0, 3.0)
	var cols := [Color("d7342a"), Color("e8c35a"), Color("d7342a"), Color("e8c35a")]
	for k in 4:
		var t := 0.12 + k * 0.17
		var cx := lerpf(-12.0, -3.0, t)
		var cy := lerpf(21.5, 33.0, t) + 0.3
		_quad(cx, cy, ang, 2.2, 1.0, cols[k])
		if _detail(1.2):
			var hx := cx - sin(ang) * 1.3
			var hy := cy + cos(ang) * 1.3
			_c(hx, hy, 0.35, SKIN)
	# a little flag on top
	_l(1, 36.6, 1, 39.6, Color("8a8d92"), 0.15)
	_poly([1, 39.6, 3.4, 39.0, 1, 38.4], Color("2b6fc4"))

## Osnabrück's hobby horse ride: every year the children ride wooden hobby horses to the town hall, wearing paper hats,
## to celebrate the peace of 1648. A child with a brown hobby horse on a stick.
static func _steckenpferd() -> void:
	_r(-2.5, 0, 2.5, 0.12, Color("9c958a"))
	# legs
	_r(-0.35, 0.12, -0.12, 1.2, Color("2f4f86"))
	_r(0.12, 0.12, 0.35, 1.2, Color("2f4f86"))
	_r(-0.45, 0.12, -0.08, 0.3, DARK)
	_r(0.08, 0.12, 0.48, 0.3, DARK)
	# body and head
	_poly([-0.5, 1.1, 0.5, 1.1, 0.42, 2.2, -0.42, 2.2], Color("e04a3a"))
	_c(0, 2.55, 0.36, SKIN)
	_poly([-0.36, 2.6, 0.36, 2.6, 0.3, 2.85, -0.3, 2.85], Color("8a5a2a")) # hair
	if _detail(10.0):
		_c(0.13, 2.58, 0.04, DARK)
		_c(-0.13, 2.58, 0.04, DARK)
	# the paper hat (a folded triangle)
	_poly([-0.5, 2.78, 0.5, 2.78, 0, 3.55], Color("f4f1e6"))
	_l(-0.38, 2.88, 0.38, 2.88, Color("3a6fd0"), 0.06)
	# the hobby horse: a stick between the legs and the head in front
	_l(-1.6, 0.15, 1.25, 1.75, WOOD, 0.08)
	var hb := Color("8a5530")
	_ell(1.55, 2.05, 0.38, 0.28, 0.6, hb) # the head
	_poly([1.3, 1.75, 1.75, 2.0, 2.15, 1.75, 2.05, 1.6, 1.7, 1.75], hb) # the muzzle
	_poly([1.35, 2.25, 1.5, 2.6, 1.6, 2.25], hb) # an ear
	_poly([1.05, 1.85, 1.3, 2.35, 1.0, 2.25, 0.85, 1.95], Color("2a2420")) # the mane
	_c(1.6, 2.1, 0.06, DARK)
	_l(1.85, 1.75, 1.2, 1.6, Color("d13a2a"), 0.05) # the rein
	_l(-0.42, 1.8, 1.35, 1.75, SKIN, 0.12) # an arm holding it
	_c(1.3, 1.72, 0.12, SKIN)
	# a little flag in the other hand
	_l(-0.55, 1.8, -1.0, 2.2, SKIN, 0.12)
	_l(-1.05, 1.9, -1.05, 3.6, WOOD, 0.05)
	_r(-2.05, 3.0, -1.05, 3.6, Color("f4f1e6"))
	if _detail(10.0):
		_c(-1.55, 3.3, 0.16, Color("3a8a3a"))

## The Glass Elephant in Hamm's Maximilianpark: an old coal-washing hall of the mine turned into a giant elephant, its
## head and back of glass, the trunk curling down to the lawn.
static func _glaselefant() -> void:
	_r(-20, 0, 20, 1.2, GRASS)
	var body := Color("8c9aa0")
	var bd := body.darkened(0.2)
	var glass := Color("7fb6d2")
	var frame := Color("4d5b63")
	# legs
	for x in [-6.0, -1.0, 9.0, 14.0]:
		_r(x - 1.8, 1.2, x + 1.8, 11, bd if x == -1.0 or x == 14.0 else body)
	# the body (the old hall)
	_poly([-9, 9, 18, 9, 19, 14, 18, 22, -8, 22, -10, 15], body)
	_windows(-7, 17, 11.5, 14, 6, Color("5d6b72"))
	# the glass back
	_poly([-8, 22, 18, 22, 15, 26] + _arc(4.5, 26, 10.5, 4.5, 0, PI, 10) + [-6, 26], glass)
	if _detail(1.2):
		for k in 8:
			var x := -6.0 + k * 3.0
			_l(x, 22, x, 26 + sqrt(maxf(0, 1.0 - pow((x - 4.5) / 10.5, 2))) * 4.5, frame, 0.15)
		_l(-7, 26, 16, 26, frame, 0.15)
	# the tail
	_l(18.5, 19, 20, 13, bd, 0.4)
	# the ear, the head of glass and the trunk
	_poly([-9, 12, -3, 14, -1, 24, -4, 29, -9, 28], bd)
	_poly(_arc(-13, 22, 6.5, 7.5, 0, TAU, 20), glass)
	if _detail(1.2):
		for y in [17.0, 20.0, 23.0, 26.0]:
			var hw := 6.5 * sqrt(maxf(0.0, 1.0 - pow((y - 22.0) / 7.5, 2)))
			_l(-13 - hw, y, -13 + hw, y, frame, 0.15)
		for x in [-17.0, -13.0, -9.0]:
			var hh := 7.5 * sqrt(maxf(0.0, 1.0 - pow((x + 13.0) / 6.5, 2)))
			_l(x, 22 - hh, x, 22 + hh, frame, 0.15)
	_pl(_arc(-13, 22, 6.5, 7.5, 0, TAU, 20), frame, 0.3)
	_c(-15.5, 24, 0.9, DARK) # the eye
	_c(-15.2, 24.3, 0.3, Color.WHITE)
	_pl([-17, 17, -18.5, 12, -18.5, 7, -17.5, 4, -15.5, 2.6, -14, 3.4], body, 2.6)
	_c(-17.6, 16, 1.6, body)
	# a tusk
	_poly([-15, 16, -14, 15.4, -11.5, 12.6, -12.1, 12.3], Color("f4f1e6"))

## A go-kart on the track in Kerpen, where Michael Schumacher learned to race: the red kart, its driver in a helmet,
## a stack of tyres and the chequered flag.
static func _kerpen_kart() -> void:
	_r(-4, 0, 4, 0.3, Color("55585e"))
	if _detail(10.0):
		for k in 8:
			_r(-4 + k, 0.12, -3.5 + k, 0.18, Color.WHITE)
	# the tyre wall
	for row in 3:
		for col in 2:
			_c(2.9 + col * 0.6, 0.6 + row * 0.55, 0.28, DARK)
			_c(2.9 + col * 0.6, 0.6 + row * 0.55, 0.1, Color("7a7d82"))
	# the kart
	var red := Color("d7262d")
	_poly([-1.8, 0.35, 1.7, 0.35, 1.9, 0.55, 1.4, 0.7, -1.6, 0.7, -1.9, 0.55], red)
	_r(-2.0, 0.42, -1.6, 0.68, Color("e0e0e0")) # bumper
	_r(-0.6, 0.7, 0.2, 1.2, DARK) # seat
	_c(-1.25, 0.3, 0.3, DARK)
	_c(1.25, 0.3, 0.3, DARK)
	_c(-1.25, 0.3, 0.12, Color("c0c0c0"))
	_c(1.25, 0.3, 0.12, Color("c0c0c0"))
	if _detail(8.0):
		_l(1.1, 0.75, 0.8, 1.15, DARK, 0.06)
	# the driver
	_poly([-0.4, 0.75, 0.3, 0.75, 0.25, 1.5, -0.35, 1.5], Color("e8c35a"))
	_l(0.1, 1.25, 0.8, 1.15, Color("e8c35a"), 0.15)
	_c(0, 1.85, 0.36, Color.WHITE)
	_poly([0.05, 1.75, 0.36, 1.8, 0.3, 2.0, 0.05, 2.0], Color("2a3a5a"))
	_l(-0.33, 1.85, 0.0, 2.15, red, 0.08)
	# the chequered flag
	_l(-3.2, 0.3, -3.2, 3.9, Color("8a8d92"), 0.06)
	for i in 4:
		for j in 3:
			_r(-3.2 + i * 0.25, 3.15 + j * 0.25, -2.95 + i * 0.25, 3.4 + j * 0.25,
				DARK if (i + j) % 2 == 0 else Color.WHITE)

## Wiesbaden's Nerobergbahn: two little cars pulled up and down the green hill by water filled into a tank, the
## straight track, and the round white temple on top of the Neroberg.
static func _nerobergbahn() -> void:
	_poly([-25, 0, 25, 0, 25, 21, 18, 24, 10, 23, -4, 15, -18, 5, -25, 3], GRASS)
	_poly([18, 24, 25, 21, 25, 12, 18, 16], TREE)
	_poly([-25, 0, -10, 0, -18, 5, -25, 3], GRASS.lightened(0.08))
	_tree(-21, 3.5, 1.6)
	_tree(6, 12.5, 1.6)
	_tree(-4, 6, 1.4)
	var ang := atan2(18.0, 34.0)
	# the track with its passing loop
	_l(-20, 2, 14, 20, Color("6e6255"), 0.9)
	_l(-20, 2, 14, 20, Color("4a4038"), 0.25)
	# the stations
	_r(-24, 0, -18, 4.5, Color("d9c7a8"))
	_poly([-24.5, 4.5, -17.5, 4.5, -21, 6.4], RED_ROOF)
	_r(12.5, 18, 18, 22.5, Color("d9c7a8"))
	_poly([12, 22.5, 18.5, 22.5, 15.25, 24.4], RED_ROOF)
	# two cars: one going up, one coming down
	for t in [0.28, 0.66]:
		var cx := lerpf(-20.0, 14.0, t)
		var cy := lerpf(2.0, 20.0, t) + 0.4
		_quad(cx, cy, ang, 6.0, 0.7, Color("6a6f78")) # the water tank
		_quad(cx - sin(ang) * 0.7, cy + cos(ang) * 0.7, ang, 6.0, 2.8, Color("f0e6cc"))
		_quad(cx - sin(ang) * 3.5, cy + cos(ang) * 3.5, ang, 6.4, 0.5, Color("2f5d8a"))
		if _detail(1.2):
			for k in 3:
				var o := -1.9 + k * 1.9
				_quad(cx + cos(ang) * o - sin(ang) * 1.4, cy + sin(ang) * o + cos(ang) * 1.4, ang, 1.1, 1.3, WIN)
	# the Monopteros: a round temple of white columns
	var tx := -0.5
	var ty := 18.5
	_r(tx - 3, ty - 1, tx + 3, ty, Color("d8d2c2"))
	for k in 5:
		var x := tx - 2.4 + k * 1.2
		_r(x - 0.25, ty, x + 0.25, ty + 4, WHITE)
	_r(tx - 2.9, ty + 4, tx + 2.9, ty + 4.8, WHITE)
	_poly([tx - 3, ty + 4.8, tx + 3, ty + 4.8, tx + 2, ty + 6.2, tx - 2, ty + 6.2], Color("a8b0b0"))

## Alsfeld town hall: a stone ground floor with pointed arches for the market, two half-timbered floors of white
## plaster and dark red beams, a steep slate roof and two pointed corner turrets.
static func _alsfeld_rathaus() -> void:
	var stone := Color("b5ab9b")
	var plaster := Color("f2ead8")
	var beam := Color("7a2e22")
	_r(-9, 0, 9, 0.4, Color("9c958a"))
	# ground floor with the arches
	_r(-7, 0.4, 7, 5, stone)
	for x in [-4.5, -1.5, 1.5, 4.5]:
		_poly([x - 1.0, 0.4, x + 1.0, 0.4, x + 1.0, 2.8, x, 4.2, x - 1.0, 2.8], Color("4a4540"))
	# the timbered floors, sticking out a little
	_r(-7.4, 5, 7.4, 8.4, plaster)
	_r(-7.8, 8.4, 7.8, 11.8, plaster)
	for y in [5.0, 8.4, 11.6]:
		_r(-7.8, y, 7.8, y + 0.3, beam)
	var fx := -7.4
	while fx <= 7.5:
		_r(fx - 0.15, 5, fx + 0.15, 11.8, beam)
		fx += 1.85
	if _detail(1.5):
		for k in 8:
			var x0 := -7.4 + k * 1.85
			_l(x0, 5.3, x0 + 1.85, 8.3, beam, 0.15)
			_l(x0 + 1.85, 5.3, x0, 8.3, beam, 0.15)
	_windows(-7, 7, 9.2, 11.0, 8, WIN)
	# the steep roof
	_poly([-8, 11.9, 8, 11.9, 4, 20, -4, 20], SLATE)
	_r(-1, 14, 1, 16.5, plaster)
	_poly([-1.3, 16.5, 1.3, 16.5, 0, 17.6], SLATE.darkened(0.1))
	# the corner turrets with their pointed spires
	for x in [-7.6, 7.6]:
		_r(x - 1.2, 7.5, x + 1.2, 13.5, plaster)
		_r(x - 0.2, 7.5, x + 0.2, 13.5, beam)
		_r(x - 1.2, 7.5, x + 1.2, 7.8, beam)
		_windows(x - 1.1, x + 1.1, 10.5, 12.3, 1, WIN)
		_poly([x - 1.4, 13.5, x + 1.4, 13.5, x, 22.5], SLATE)
		_poly([x - 1.4, 13.5, x - 0.3, 13.5, x, 22.5], SLATE.lightened(0.15))
		_l(x, 22.5, x, 23.6, GOLD, 0.1)

## The Gänseliesel in Göttingen: the little bronze goose girl on her fountain, a goose under her arm, a basket, the
## iron canopy of curly leaves above her; students who finish their doctorate climb up to kiss her.
static func _gaenseliesel() -> void:
	var st := Color("b9b4a8")
	var bz := Color("5d7a62")
	var bl := bz.lightened(0.2)
	_r(-4, 0, 4, 0.2, Color("9c958a"))
	# the basin and water
	_r(-3.6, 0.2, 3.6, 1.3, st)
	_r(-3.3, 1.0, 3.3, 1.3, WATER)
	_r(-3.8, 1.3, 3.8, 1.5, st.lightened(0.1))
	# the pedestal
	_r(-0.7, 1.5, 0.7, 4.0, st)
	_r(-0.9, 3.8, 0.9, 4.1, st.lightened(0.1))
	if _detail(8.0):
		_l(-0.7, 2.3, -1.6, 2.0, Color("9cc8e6"), 0.08) # water spouting
		_l(0.7, 2.3, 1.6, 2.0, Color("9cc8e6"), 0.08)
	# the iron canopy
	var ir := Color("2b2e33")
	for x in [-2.6, 2.6]:
		_l(x, 1.5, x, 7.4, ir, 0.12)
	_pl(_arc(0, 7.4, 2.6, 1.6, 0, PI, 10), ir, 0.12)
	_l(0, 9.0, 0, 9.9, ir, 0.1)
	_c(0, 9.9, 0.18, GOLD)
	if _detail(6.0):
		for s in [-1.0, 1.0]:
			_pl([s * 2.6, 6.5, s * 1.9, 6.9, s * 1.6, 6.5, s * 1.9, 6.2], ir, 0.07)
			_c(s * 1.5, 8.3, 0.2, Color("4a6a3a"))
	# the girl
	_poly([-0.55, 4.1, 0.55, 4.1, 0.3, 5.3, -0.3, 5.3], bz) # skirt
	_r(-0.25, 5.3, 0.25, 6.0, bz)
	_c(0, 6.3, 0.27, bl)
	_poly([-0.3, 6.35, 0.3, 6.35, 0.15, 6.65, -0.15, 6.65], bz) # headscarf
	# a goose under her right arm
	_ell(0.55, 5.6, 0.42, 0.24, -0.3, bl)
	_l(0.85, 5.55, 1.05, 6.05, bl, 0.1)
	_c(1.08, 6.08, 0.1, bl)
	# the basket on her left arm and a goose at her feet
	_poly([-0.9, 5.0, -0.35, 5.0, -0.4, 5.4, -0.85, 5.4], bz.darkened(0.2))
	_ell(-0.5, 4.3, 0.36, 0.2, 0.2, bl)
	_l(-0.8, 4.35, -0.95, 4.75, bl, 0.09)
	# a real white goose walking by the fountain
	_ell(2.6, 0.55, 0.45, 0.28, 0.0, Color.WHITE)
	_l(2.25, 0.6, 2.05, 1.15, Color.WHITE, 0.12)
	_c(2.05, 1.18, 0.12, Color.WHITE)
	_poly([1.93, 1.14, 1.78, 1.1, 1.93, 1.22], Color("e8962a"))

## Veste Coburg: one of the biggest castles in Germany, a long ring of walls and towers, light walls and red roofs on
## top of its wooded hill above the town.
static func _veste_coburg() -> void:
	_poly([-35, 0, -28, 6, -18, 14, -8, 17, 8, 17, 18, 14, 28, 6, 35, 0], TREE)
	_poly([-35, 0, -28, 6, -24, 8, -20, 3, -14, 0], TREE.lightened(0.1))
	_poly([35, 0, 28, 6, 24, 7, 20, 2, 14, 0], TREE.lightened(0.06))
	_tree(-26, 1, 2.0)
	_tree(26, 1, 2.0)
	var w := Color("e6dcc4")
	var wd := w.darkened(0.14)
	# the outer wall with bastions
	_r(-24, 14, 24, 19, wd)
	for x in range(-24, 24, 2):
		_r(x, 19, x + 1, 19.8, wd)
	for x in [-24.0, 24.0]:
		_r(x - 2.2, 13, x + 2.2, 21, w)
		_poly([x - 2.6, 21, x + 2.6, 21, x, 24], RED_ROOF)
	# buildings inside: halls with red roofs
	_r(-20, 19, -6, 25, w)
	_poly([-20.5, 25, -5.5, 25, -7.5, 28, -18.5, 28], RED_ROOF)
	_windows(-19, -7, 21, 23.5, 5, WIN)
	_r(4, 19, 19, 24, w)
	_poly([3.5, 24, 19.5, 24, 17, 27.5, 6, 27.5], RED_ROOF)
	_windows(5, 18, 20.5, 22.5, 6, WIN)
	_r(-6, 19, 4, 26.5, wd)
	_poly([-6.4, 26.5, 4.4, 26.5, -1, 30], RED_ROOF.darkened(0.1))
	# the tall towers
	_r(-14, 25, -10, 33, w)
	_poly([-14.4, 33, -9.6, 33, -12, 37.2], RED_ROOF)
	_windows(-13.4, -10.6, 29, 31, 1, WIN)
	_r(9, 24, 13, 31, w)
	_r(9, 24, 10, 31, wd)
	_bulb(11, 31, 4.4, 5, SLATE)
	_r(-3, 26.5, 1, 31, w)
	_poly([-3.4, 31, 1.4, 31, -1, 34], RED_ROOF)
	if _detail(1.2):
		_r(-22, 15.5, -21, 17, WIN)
		_r(21, 15.5, 22, 17, WIN)

## Bernburg Castle, "the crown of Anhalt": the Renaissance palace with its curly gables and bay windows high over the
## Saale, the round Eulenspiegel tower, and the brown bears that live in the castle moat.
static func _schloss_bernburg() -> void:
	_r(-25, 0, 25, 2, WATER)
	if _detail(1.0):
		_r(-23, 0.7, -14, 1.0, WATER_L)
	_poly([-25, 2, -22, 9, -14, 12, 14, 12, 18, 9, 18, 2], ROCK)
	_poly([-25, 2, -22, 9, -18, 7, -14, 2], ROCK.darkened(0.12))
	var w := Color("eadfca")
	var wd := w.darkened(0.12)
	# the palace with gables
	_r(-12, 12, 12, 21, w)
	_windows(-11, 11, 13.6, 15.8, 8, WIN)
	_windows(-11, 11, 17.4, 19.6, 8, WIN)
	_poly([-12.4, 21, 12.4, 21, 10.5, 24, -10.5, 24], RED_ROOF)
	for x in [-6.0, 0.5, 7.0]:
		_poly([x - 2.4, 21, x + 2.4, 21, x + 2.4, 22.5, x + 1.6, 22.8, x + 1.6, 24.5, x + 0.8, 24.8, x + 0.6, 26.2,
			x - 0.6, 26.2, x - 0.8, 24.8, x - 1.6, 24.5, x - 1.6, 22.8, x - 2.4, 22.5], w)
		_c(x, 26.5, 0.4, w)
		_windows(x - 1.2, x + 1.2, 22, 23.6, 1, WIN)
	# a bay window (Erker) on the front
	_r(2, 14, 5, 20.5, wd)
	_windows(2.2, 4.8, 15, 19.5, 2, Color("5a6a80"))
	# the Eulenspiegel tower
	_r(-19, 9, -13, 26, w)
	_r(-19, 9, -18, 26, wd)
	_r(-14, 9, -13, 26, wd)
	_windows(-17.5, -14.5, 20.5, 23, 2, WIN)
	_r(-19.4, 25.6, -12.6, 26.6, wd)
	_poly([-19.2, 26.6, -12.8, 26.6, -14, 28.4, -18, 28.4], SLATE)
	_bulb(-16, 28.4, 2.6, 1.6, SLATE)
	# the bear moat and a bear
	_r(14, 2, 25, 9, Color("8a7a5e"))
	_r(14, 2, 25, 3, GRASS.darkened(0.1))
	_r(13.5, 9, 25, 9.8, Color("b8ad9a"))
	var bear := Color("6b4428")
	_ell(19.5, 4.6, 2.2, 1.3, 0.0, bear)
	_r(17.8, 3, 18.5, 4.2, bear)
	_r(20.6, 3, 21.3, 4.2, bear)
	_c(17.2, 5.4, 0.9, bear)
	_c(16.7, 6.2, 0.32, bear)
	_c(17.6, 6.2, 0.32, bear)
	_c(16.5, 5.2, 0.4, bear.lightened(0.25))
	_c(17.0, 5.7, 0.12, DARK)

## Spreewald gherkins from Lübben: a wooden barrel full of green pickled gherkins with dill, a big glass jar of them,
## and one gherkin leaning on the barrel.
static func _spreewald_gurken() -> void:
	_r(-2.5, 0, 2.5, 0.1, Color("9c958a"))
	var wood := Color("a8743e")
	var hoop := Color("4e4a45")
	var gk := Color("4f7a2a")
	var gl := Color("7aa53f")
	# the barrel
	_poly([-1.9, 0.1, -0.1, 0.1, 0.15, 1.2, -0.1, 2.3, -1.9, 2.3, -2.15, 1.2], wood)
	if _detail(10.0):
		for x in [-1.5, -1.0, -0.5]:
			_l(x, 0.15, x, 2.25, wood.darkened(0.2), 0.03)
	for y in [0.45, 1.95]:
		_r(-2.05, y, 0.05, y + 0.14, hoop)
	# gherkins sticking out on top
	for g in [[-1.6, 2.5, 0.4], [-1.05, 2.6, -0.2], [-0.5, 2.45, 0.6], [-1.3, 2.75, 1.4]]:
		_ell(g[0], g[1], 0.32, 0.13, g[2], gk)
	if _detail(10.0):
		_l(-0.6, 2.4, -0.2, 3.0, Color("6b9a3a"), 0.03) # dill
		_c(-0.2, 3.05, 0.12, Color("9fc25a"))
	# the jar
	var jar := Color("cfe6d0")
	_r(0.6, 0.1, 2.2, 2.1, jar)
	_r(0.7, 2.1, 2.1, 2.4, Color("d0b040"))
	for g in [[1.0, 0.7, 1.4], [1.45, 0.75, 1.55], [1.85, 0.7, 1.5], [1.2, 1.5, 1.4], [1.7, 1.5, 1.6]]:
		_ell(g[0], g[1], 0.45, 0.17, g[2], gk)
	_r(0.75, 0.9, 2.05, 1.4, Color("f4ead0")) # the label
	if _detail(10.0):
		_ell(1.4, 1.15, 0.35, 0.12, 0.0, gl)
	# a big gherkin leaning on the barrel
	_ell(-2.1, 0.9, 0.95, 0.32, 1.25, gk)
	if _detail(8.0):
		for p in [[-2.2, 0.5], [-2.0, 0.9], [-2.15, 1.3], [-1.95, 1.6]]:
			_c(p[0], p[1], 0.05, gl)

## Legoland Deutschland in Günzburg: a tower of giant toy bricks in red, yellow, blue and green with their round
## studs, and a smiling yellow toy figure as tall as a house beside it.
static func _legoland() -> void:
	_r(-7, 0, 7, 0.3, Color("9c958a"))
	var cols := [Color("d01012"), Color("f2c717"), Color("0d69ab"), Color("237841"), Color("d01012"), Color("0d69ab"),
		Color("f2c717")]
	var y := 0.3
	for k in cols.size():
		var x0 := -6.0 + (0.5 if k % 2 == 1 else 0.0)
		var x1 := x0 + 6.0
		var col: Color = cols[k]
		_r(x0, y, x1, y + 1.6, col)
		_r(x0, y, x1, y + 0.2, col.darkened(0.2))
		y += 1.6
	# studs on the top brick
	var topc: Color = cols[cols.size() - 1]
	for k in 4:
		_r(-5.0 + k * 1.5, y, -4.1 + k * 1.5, y + 0.5, topc.lightened(0.1))
	# the toy figure
	var yl := Color("f2c717")
	var fx := 3.6
	_r(fx - 1.5, 0.3, fx - 0.1, 3.6, Color("1f3f86")) # legs
	_r(fx + 0.1, 0.3, fx + 1.5, 3.6, Color("1f3f86"))
	_r(fx - 1.5, 3.4, fx + 1.5, 4.2, Color("1f3f86"))
	_poly([fx - 1.6, 4.2, fx + 1.6, 4.2, fx + 1.2, 7.6, fx - 1.2, 7.6], Color("d01012")) # torso
	_poly([fx - 1.5, 7.4, fx - 2.3, 5.2, fx - 1.8, 5.0, fx - 1.2, 6.8], Color("d01012")) # arms
	_poly([fx + 1.5, 7.4, fx + 2.3, 5.2, fx + 1.8, 5.0, fx + 1.2, 6.8], Color("d01012"))
	_c(fx - 2.1, 4.8, 0.45, yl)
	_c(fx + 2.1, 4.8, 0.45, yl)
	_r(fx - 0.4, 7.6, fx + 0.4, 8.0, yl) # neck
	_r(fx - 1.0, 8.0, fx + 1.0, 10.2, yl) # head
	_r(fx - 0.5, 10.2, fx + 0.5, 10.6, yl) # the stud on the head
	_c(fx - 0.4, 9.4, 0.14, DARK)
	_c(fx + 0.4, 9.4, 0.14, DARK)
	_pl(_arc(fx, 8.9, 0.5, 0.35, PI * 1.15, PI * 1.85, 6), DARK, 0.1)

## The pumpkin festival in the Blühendes Barock garden of Ludwigsburg, the biggest in the world: a giant pumpkin as
## big as a car, a pumpkin figure and heaps of orange, yellow and green pumpkins.
static func _kuerbis_ludwigsburg() -> void:
	_r(-5, 0, 5, 0.4, GRASS)
	var org := Color("e57a1f")
	var od := org.darkened(0.18)
	# the giant pumpkin
	_ell(-1.5, 2.0, 3.0, 1.75, 0.0, org)
	_ell(-1.5, 2.0, 1.8, 1.75, 0.0, od)
	_ell(-1.5, 2.0, 0.8, 1.7, 0.0, org.lightened(0.08))
	_r(-1.7, 3.6, -1.3, 4.3, Color("5a6b2a"))
	# a pumpkin figure: a body pumpkin, a head pumpkin and a hat
	var fx := 3.2
	_ell(fx, 1.3, 1.1, 0.85, 0.0, Color("f0b429"))
	_ell(fx, 1.3, 0.5, 0.85, 0.0, Color("f0b429").darkened(0.12))
	_ell(fx, 2.85, 0.75, 0.62, 0.0, org)
	_c(fx - 0.25, 3.0, 0.1, DARK)
	_c(fx + 0.25, 3.0, 0.1, DARK)
	_pl(_arc(fx, 2.85, 0.35, 0.25, PI * 1.1, PI * 1.9, 5), DARK, 0.06)
	_r(fx - 0.7, 3.4, fx + 0.7, 3.55, DARK)
	_r(fx - 0.45, 3.55, fx + 0.45, 4.3, DARK)
	_r(fx - 0.45, 3.6, fx + 0.45, 3.75, Color("c8102e"))
	_l(fx - 1.0, 1.6, fx - 1.6, 2.2, Color("5a6b2a"), 0.1) # arms of stalks
	_l(fx + 1.0, 1.6, fx + 1.6, 2.2, Color("5a6b2a"), 0.1)
	# small pumpkins in front
	for p in [[-4.3, 0.75, 0.45, Color("6b9a3a")], [0.9, 0.7, 0.5, Color("f2d24a")], [1.8, 0.55, 0.35, org],
		[-3.4, 0.55, 0.32, Color("f4f1e6")], [4.6, 0.55, 0.32, Color("6b9a3a")]]:
		_ell(p[0], p[1], p[2] * 1.2, p[2], 0.0, p[3])
		_r(p[0] - 0.05, p[1] + p[2] * 0.85, p[0] + 0.05, p[1] + p[2] * 1.2, Color("5a6b2a"))

## The Kurhaus in Baden-Baden with its famous casino: a long white classical building, a portico of eight tall
## columns with a golden inscription, the side wings and the chestnut trees of the park.
static func _kurhaus_baden_baden() -> void:
	_r(-25, 0, 25, 1, GRASS)
	var w := WHITE
	var wd := w.darkened(0.08)
	# wings
	_r(-21, 1, 21, 11, wd)
	_poly([-21.4, 11, 21.4, 11, 20, 12.6, -20, 12.6], Color("7a7068"))
	for x in [-17.0, -13.0, 13.0, 17.0]:
		_poly([x - 1, 2, x + 1, 2, x + 1, 6.5] + _arc(x, 6.5, 1, 1, 0, PI, 6), WIN)
		_r(x - 0.8, 8.6, x + 0.8, 10.2, WIN)
	# the middle and its portico
	_r(-10, 1, 10, 14, w)
	_r(-10.4, 1, 10.4, 2, Color("d8d2c2"))
	for k in 8:
		var x := -8.75 + k * 2.5
		_r(x - 0.45, 2, x + 0.45, 11.2, Color("faf8f2"))
		_r(x - 0.7, 11.0, x + 0.7, 11.6, Color("e8e2d2"))
		if _detail(1.5):
			_r(x - 0.7, 2.0, x + 0.7, 2.4, Color("e8e2d2"))
	# dark gaps between columns
	if _detail(1.0):
		for k in 7:
			var x := -7.5 + k * 2.5
			_r(x - 0.75, 2.4, x + 0.75, 10.8, Color("cfc8b8"))
			_poly([x - 0.5, 2.4, x + 0.5, 2.4, x + 0.5, 6.5] + _arc(x, 6.5, 0.5, 0.5, 0, PI, 4), Color("8a7d6a"))
	_r(-10.4, 11.6, 10.4, 13.6, w)
	_r(-6, 12.2, 6, 13.0, GOLD) # the inscription
	_r(-10.6, 13.6, 10.6, 14.2, Color("d8d2c2"))
	_poly([-10.2, 14.2, 10.2, 14.2, 9, 15.4, -9, 15.4], Color("7a7068"))
	# chestnut trees
	_tree(-23, 1, 2.2)
	_tree(23, 1, 2.2)
	_tree(-11.5, 1, 1.4)
	_tree(11.5, 1, 1.4)
