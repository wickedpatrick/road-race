class_name LandmarksAtD
extends RefCounted
## Austrian landmarks, drawn with LandmarkPainter's helpers (metres from the base point, y up).

const WHITE := Color("f2efe6")
const YELLOW := Color("e8c35a")
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
const AT_RED := Color("c8102e")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"dom_wiener_neustadt": _dom_wiener_neustadt()
		"basilika_mondsee": _basilika_mondsee()
		"festung_kufstein": _festung_kufstein()
		"hohenwerfen": _hohenwerfen()
		"schloss_esterhazy": _schloss_esterhazy()
		"kaiservilla": _kaiservilla()
		"haydn": _haydn()
		"salzwelten": _salzwelten()
		"schloss_ort": _schloss_ort()
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
	_l(x, y + h * 0.9, x, y + h, Color("d8b14a"), 0.12)

## A flag on its pole: the pole from (x, y) up `h`, the cloth `fw` wide, stripes given from the top.
static func _flag(x: float, y: float, h: float, fw: float, stripes: Array) -> void:
	_l(x, y, x, y + h, Color("8a8d92"), 0.18)
	var fh := fw * 0.62
	var s := fh / stripes.size()
	for k in stripes.size():
		_r(x, y + h - s * (k + 1), x + fw, y + h - s * k, stripes[k])

## A rounded tree crown on a trunk.
static func _tree(x: float, y: float, r: float) -> void:
	_r(x - r * 0.12, y, x + r * 0.12, y + r, WOOD)
	_c(x, y + r * 1.4, r, TREE)
	_c(x - r * 0.35, y + r * 1.6, r * 0.55, TREE.lightened(0.1))

## Wiener Neustadt cathedral: a long nave of reddish-brown stone with a steep dark roof, the Romanesque west front
## with a round-arched portal and a rose window, and its two slim towers with tall green-copper spires.
static func _dom_wiener_neustadt() -> void:
	var st := Color("9a5b45")
	var sd := st.darkened(0.18)
	# the nave going back, behind the towers
	_r(-3, 0, 14, 16, sd)
	_poly([-3, 16, 14, 16, 14, 18, 5.5, 24, -3, 20], Color("4b4440"))
	_windows(0, 13, 5, 11, 4, WIN)
	# the west front between the towers
	_r(-7, 0, 3, 18, st)
	_poly([-7, 18, 3, 18, -2, 23], st)
	_poly([-3.4, 0, -0.6, 0, -0.6, 4.5] + _arc(-2, 4.5, 1.4, 1.4, 0, PI, 6), DARK)
	_c(-2, 12, 1.8, WIN)
	if _detail(1.2):
		_c(-2, 12, 1.0, Color("6d4a8a"))
	# the two towers
	for x in [-10.0, 6.0]:
		_r(x - 3, 0, x + 3, 34, st)
		_r(x - 3, 0, x - 2, 34, st.lightened(0.1))
		for y in [10.0, 18.0, 26.0]:
			_r(x - 3.3, y, x + 3.3, y + 0.6, sd)
		_poly([x - 0.9, 28, x + 0.9, 28, x + 0.9, 31] + _arc(x, 31, 0.9, 0.9, 0, PI, 4), WIN)
		_poly([x - 0.9, 20, x + 0.9, 20, x + 0.9, 23] + _arc(x, 23, 0.9, 0.9, 0, PI, 4), WIN)
		_poly([x - 3.4, 34, x + 3.4, 34, x, 51], COPPER)
		_poly([x - 3.4, 34, x - 0.6, 34, x, 51], COPPER.lightened(0.15))
		_l(x, 51, x, 52, Color("d8b14a"), 0.15)

## Mondsee basilica (St. Michael): a yellow baroque front with white pilasters, a curved gable, and two towers with
## dark bulb domes, the lake in front.
static func _basilika_mondsee() -> void:
	_r(-15, 0, 15, 1.4, WATER)
	if _detail(1.0):
		_r(-12, 0.5, -6, 0.75, WATER_L)
		_r(3, 0.9, 10, 1.15, WATER_L)
	_r(-15, 1.4, 15, 2.4, GRASS)
	var y := YELLOW
	var wh := WHITE
	# the middle of the front with its curved gable
	_r(-5, 2.4, 5, 18, y)
	_poly([-5, 18, 5, 18, 3.5, 21] + _arc(0, 21, 3.5, 2.6, 0, PI, 8) + [-3.5, 21], y)
	_c(0, 21.2, 1.0, wh)
	_poly([-1.6, 2.4, 1.6, 2.4, 1.6, 7] + _arc(0, 7, 1.6, 1.6, 0, PI, 6), Color("5a3b26"))
	_windows(-4.2, 4.2, 10, 14, 3, WIN)
	for x in [-5.0, 5.0]:
		_r(x - 0.4, 2.4, x + 0.4, 18, wh)
	# the towers
	for x in [-9.0, 9.0]:
		_r(x - 4, 2.4, x + 4, 28, y)
		_r(x - 4, 2.4, x - 3.2, 28, wh)
		_r(x + 3.2, 2.4, x + 4, 28, wh)
		for yy in [12.0, 20.0, 27.6]:
			_r(x - 4.3, yy, x + 4.3, yy + 0.6, wh)
		_windows(x - 2.4, x + 2.4, 6, 9, 1, WIN)
		_windows(x - 2.4, x + 2.4, 14.5, 17.5, 1, WIN)
		_poly([x - 1.1, 21.5, x + 1.1, 21.5, x + 1.1, 24.5] + _arc(x, 24.5, 1.1, 1.1, 0, PI, 4), WIN)
		_r(x - 3, 28.2, x + 3, 29.4, y)
		_bulb(x, 29.4, 5.2, 11, Color("3e4a44"))

## Kufstein Fortress: the rock over the Inn, the long walls and the huge round Kaiserturm with its cone roof, and two
## flags flying side by side: Austria's red-white-red and Tyrol's white-and-red with the red eagle.
static func _festung_kufstein() -> void:
	_r(-25, 0, 25, 2, WATER)
	if _detail(1.0):
		_r(-20, 0.8, -10, 1.1, WATER_L)
		_r(6, 1.2, 18, 1.5, WATER_L)
	_poly([-25, 2, -23, 9, -18, 15, -10, 18, 4, 19, 14, 17, 21, 11, 25, 2], ROCK)
	_poly([-25, 2, -23, 9, -20, 11, -16, 5, -10, 2], GRASS)
	_poly([25, 2, 21, 11, 18, 8, 15, 2], GRASS)
	_poly([-14, 2, -10, 10, -6, 4], ROCK.darkened(0.12))
	var w := Color("d9d1c0")
	var wd := w.darkened(0.12)
	# walls and houses along the top of the rock
	_r(-18, 15, 18, 20, w)
	for x in range(-18, 18, 2):
		_r(x, 20, x + 1, 21, w)
	_r(-16, 20, -6, 25, wd)
	_poly([-16.5, 25, -5.5, 25, -11, 28], RED_ROOF)
	_windows(-15, -7, 21.5, 23.5, 3, WIN)
	_r(10, 20, 16, 26, w)
	_poly([9.5, 26, 16.5, 26, 13, 28.5], RED_ROOF)
	# the Kaiserturm: a fat round tower
	_r(-5, 18, 8, 30, w)
	_r(-5, 18, -3, 30, wd) # round: shaded at both sides, light in the middle
	_r(6, 18, 8, 30, wd)
	_r(0, 18, 3, 30, w.lightened(0.08))
	_r(-5.3, 29, 8.3, 30.4, wd)
	_windows(-3, 6, 22, 24.5, 4, WIN)
	_poly([-5.6, 30.4, 8.6, 30.4, 1.5, 35.5], Color("5f6b70"))
	_poly([-5.6, 30.4, -1, 30.4, 1.5, 35.5], Color("76838a"))
	# the two flags
	_flag(-9, 28, 7, 3.4, [AT_RED, Color.WHITE, AT_RED])
	_flag(12, 28.5, 6.5, 3.4, [Color.WHITE, AT_RED])
	if _detail(1.4):
		_c(13.7, 33.7, 0.45, AT_RED) # the Tyrolean eagle, in a word

## Hohenwerfen Castle: white walls, a tall keep and red roofs on top of a steep wooded cone of rock, the Tennengebirge
## behind, an Austrian flag on the keep.
static func _hohenwerfen() -> void:
	_poly([-23, 0, -14, 22, -6, 16, 4, 30, 13, 18, 23, 0], Color("b4b8bf"))
	_poly([0, 26, 4, 30, 7, 26, 5, 25], Color("eef2f6"))
	_poly([-16, 0, -11, 9, -6, 18, 0, 21, 6, 18, 11, 9, 16, 0], TREE)
	_poly([-16, 0, -11, 9, -8, 6, -4, 0], TREE.lightened(0.1))
	_poly([-5, 17, -3, 19, 3, 19.5, 5, 17, 2, 14, -2, 14], ROCK)
	var w := WHITE
	var wd := w.darkened(0.1)
	_r(-9, 18, 9, 23, w)
	for x in range(-9, 9, 2):
		_r(x, 23, x + 1, 24, w)
	_r(-8, 23, -1, 27, wd)
	_poly([-8.5, 27, -0.5, 27, -4.5, 29.5], RED_ROOF)
	_windows(-7.5, -1.5, 24, 26, 3, WIN)
	# the keep
	_r(1, 23, 5.5, 33, w)
	_r(1, 23, 2, 33, wd)
	_windows(1.8, 4.8, 28, 30, 1, WIN)
	_poly([0.6, 33, 5.9, 33, 3.25, 36], RED_ROOF)
	_r(5.5, 23, 9, 26, wd)
	_poly([5.3, 26, 9.2, 26, 7.2, 27.6], RED_ROOF)
	_flag(3.25, 36, 2, 2.4, [AT_RED, Color.WHITE, AT_RED])

## Esterházy Palace in Eisenstadt: a long yellow baroque front with rows of white-framed windows, the higher middle
## block with its dark roof, a balcony and a small clock tower on top.
static func _schloss_esterhazy() -> void:
	var y := Color("efc94c")
	var wh := WHITE
	_r(-25, 0, 25, 11, y)
	_poly([-25.5, 11, 25.5, 11, 23.5, 13.5, -23.5, 13.5], Color("6b4a3a"))
	# corner towers
	for x in [-22.0, 22.0]:
		_r(x - 3, 0, x + 3, 14, y)
		_poly([x - 3.4, 14, x + 3.4, 14, x, 16.5], Color("5b4a42"))
	# the middle block
	_r(-8, 0, 8, 14, y)
	_r(-8.3, 14, 8.3, 14.6, wh)
	_poly([-8, 14.6, 8, 14.6, 6.5, 16.2, -6.5, 16.2], Color("6b4a3a"))
	_r(-1.2, 16.2, 1.2, 18.5, y)
	_c(0, 17.4, 0.7, wh)
	_bulb(0, 18.5, 2.2, 1.6, Color("5b6b62"))
	_r(-4, 6.5, 4, 7, wh) # the balcony
	_poly([-1.4, 0, 1.4, 0, 1.4, 3.6] + _arc(0, 3.6, 1.4, 1.2, 0, PI, 6), Color("5a3b26"))
	if _detail(1.0):
		for x in [-24.0, -16.0, -8.0, 8.0, 16.0, 24.0]:
			_r(x - 0.3, 0, x + 0.3, 11, wh)
	# rows of windows with white frames
	for row in [[2.0, 4.5], [7.5, 10.0]]:
		for seg in [[-24.5, -8.5, 7], [-7.5, 7.5, 6], [8.5, 24.5, 7]]:
			LandmarkPainter._windows(seg[0], seg[1], row[0] - 0.3, row[1] + 0.3, seg[2], wh)
			LandmarkPainter._windows(seg[0], seg[1], row[0], row[1], seg[2], WIN)
	_windows(-7, 7, 11.6, 13.4, 6, WIN)

## Bad Ischl Kaiservilla: a yellow Empire-style villa, two long wings and the middle with a white portico of columns
## under a triangular pediment, trees of the park on both sides.
static func _kaiservilla() -> void:
	_r(-18, 0, 18, 1, GRASS)
	var y := Color("f0cd5a")
	var wh := WHITE
	_r(-14, 1, 14, 9, y)
	_poly([-14.4, 9, 14.4, 9, 13, 10.6, -13, 10.6], Color("7a6a5e"))
	_r(-14, 1, -13.4, 9, wh)
	_r(13.4, 1, 14, 9, wh)
	_windows(-13, -5, 2.5, 4.5, 4, WIN)
	_windows(5, 13, 2.5, 4.5, 4, WIN)
	_windows(-13, -5, 6, 8, 4, WIN)
	_windows(5, 13, 6, 8, 4, WIN)
	# the portico
	_r(-5, 1, 5, 11, y.lightened(0.08))
	_r(-5.4, 1, 5.4, 1.6, wh)
	for k in 5:
		var x := -4.2 + k * 2.1
		_r(x - 0.35, 1.6, x + 0.35, 9.4, wh)
	_r(-5.4, 9.4, 5.4, 10.4, wh)
	_poly([-5.6, 10.4, 5.6, 10.4, 0, 13], wh)
	_poly([-4, 10.8, 4, 10.8, 0, 12.4], y)
	_r(-1, 1.6, 1, 4.6, Color("5a3b26"))
	# park trees
	_tree(-16.5, 1, 1.8)
	_tree(16.5, 1, 1.8)
	_tree(-15.2, 1, 1.3)

## Haydn's music: a black grand piano with its lid up, on three legs, and music notes floating above it.
static func _haydn() -> void:
	var bk := Color("1c1d21")
	var hi := Color("4a4d55")
	# legs
	_r(-2.9, 0, -2.6, 1.8, bk)
	_r(1.6, 0, 1.9, 1.8, bk)
	_r(-0.5, 0, -0.2, 1.8, bk)
	# the curved body seen from the side
	_poly([-3.2, 1.8, 3.4, 1.8, 3.4, 2.7, 0.8, 2.7, -3.2, 2.7], bk)
	_r(-3.2, 2.55, 3.4, 2.7, hi)
	# keyboard
	_r(-3.6, 2.0, -3.2, 2.5, Color.WHITE)
	# the lid, propped up
	_poly([-3.0, 2.7, 3.4, 2.7, -1.2, 4.6], bk)
	_l(0.5, 2.7, -0.4, 4.2, hi, 0.08)
	# notes
	var nc := Color("23262b")
	for n in [[1.6, 4.2], [2.9, 4.9], [-2.6, 5.0]]:
		_c(n[0], n[1], 0.32, nc)
		_l(n[0] + 0.28, n[1], n[0] + 0.28, n[1] + 1.0, nc, 0.08)
	_l(1.88, 5.2, 3.18, 5.9, nc, 0.12)

## Salzwelten Hallein: the mountain side with the stone portal of the salt mine, the miners' little train coming out
## on its rails, the wooden slide down the slope and a heap of white salt.
static func _salzwelten() -> void:
	_poly([-18, 0, -18, 14, -10, 20, -2, 24, 8, 21, 18, 12, 18, 0], GRASS.darkened(0.05))
	_poly([-2, 24, 8, 21, 12, 17, 4, 16, -4, 19], ROCK)
	_poly([-18, 14, -10, 20, -9, 16, -16, 10], TREE)
	_tree(13, 9, 1.6)
	_tree(15.5, 8, 1.4)
	# the slide down the slope
	_l(-14, 12.5, 2, 3, WOOD, 0.9)
	_l(-14, 13.1, 2, 3.6, WOOD.lightened(0.2), 0.25)
	# the portal
	_r(-2, 0, 10, 9, Color("cbc3b2"))
	_poly([1, 0, 7, 0, 7, 4.5] + _arc(4, 4.5, 3, 2.6, 0, PI, 8), DARK)
	_r(-2.4, 9, 10.4, 10, Color("a89f8e"))
	if _detail(1.0):
		_r(1.5, 8.2, 6.5, 8.7, Color("6b4a2a"))
	# rails and the little train
	_r(-18, 0, 7, 0.3, Color("5a5a5a"))
	for x in [-11.0, -6.4]:
		_r(x - 2, 0.6, x + 2, 2.4, Color("2f5d8a"))
		_c(x - 1.2, 0.6, 0.45, DARK)
		_c(x + 1.2, 0.6, 0.45, DARK)
	_r(-17, 0.6, -13.4, 3.2, Color("c8102e")) # the engine
	_r(-16.6, 3.2, -14.6, 4.2, Color("c8102e").darkened(0.2))
	_c(-16.1, 0.6, 0.5, DARK)
	_c(-14.2, 0.6, 0.5, DARK)
	# white salt
	_poly([11, 0, 17, 0, 15.5, 2.2, 13, 2.8], Color("f4f6f8"))

## Seeschloss Ort in Gmunden: the white castle on its island in the Traunsee, a tower with an onion dome, the long
## wooden bridge to the shore and the big Traunstein rising behind.
static func _schloss_ort() -> void:
	_poly([-28, 2, -8, 22, -2, 26, 6, 21, 18, 9, 28, 2], Color("8f949a"))
	_poly([-8, 22, -2, 26, 1, 24, -4, 20], Color("b5b9be"))
	_poly([-28, 2, -16, 13, -12, 8, -18, 2], TREE)
	_r(-28, 0, 28, 2.2, WATER)
	if _detail(1.0):
		_r(-24, 0.8, -14, 1.1, WATER_L)
		_r(14, 1.2, 24, 1.5, WATER_L)
	# the shore and the bridge
	_r(-28, 0, -20, 2.6, GRASS)
	_r(-20, 2.4, 0, 2.9, WOOD)
	if _detail(1.0):
		for x in range(-19, 0, 3):
			_r(x, 0.8, x + 0.4, 2.4, WOOD.darkened(0.2))
	# the island
	_poly([-1, 2.2, 22, 2.2, 20, 3.6, 1, 3.6], ROCK)
	var w := WHITE
	var wd := w.darkened(0.1)
	_r(2, 3.6, 20, 12, w)
	_poly([1.5, 12, 20.5, 12, 18, 14.6, 4, 14.6], RED_ROOF)
	_r(2, 3.6, 3, 12, wd)
	_windows(4, 19, 6, 8, 6, WIN)
	_windows(4, 19, 9.5, 11, 6, WIN)
	_poly([8.5, 3.6, 11.5, 3.6, 11.5, 6] + _arc(10, 6, 1.5, 1.2, 0, PI, 6), DARK)
	# the tower with its onion dome
	_r(-0.5, 3.6, 4.5, 18, w)
	_r(-0.5, 3.6, 0.5, 18, wd)
	_windows(0.5, 3.5, 14.5, 16.5, 1, WIN)
	_c(2, 12.8, 0.8, Color("2e3238"))
	_bulb(2, 18, 4.6, 7, Color("4e6c58"))
