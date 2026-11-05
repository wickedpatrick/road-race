class_name LandmarksAtB
extends RefCounted
## Austrian landmarks, drawn with LandmarkPainter's helpers (metres from the base point, y up).

const WHITE := Color("f2efe6")
const WATER := Color("4f8fc0")
const WATER_L := Color("9cc8e6")
const ROCK := Color("9a958a")
const GRASS := Color("5d8f42")
const SNOW := Color("f4f6f8")
const WIN := Color("3a4048")
const TYRE := Color("1e2226")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"alpine_lake": _alpine_lake()
		"stift_melk": _stift_melk()
		"hallstatt": _hallstatt()
		"erzberg": _erzberg()
		"red_bull_ring": _red_bull_ring()
		"grossglockner": _grossglockner()
		"swarovski": _swarovski()
		"gondola": _gondola()
		"rolls_royce": _rolls_royce()
		"porsche_356": _porsche_356()
		"milka_cow": _milka_cow()
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

## A small white church with a pointed spire, its base centred at x (the shore churches).
static func _church(x: float, y: float, s: float, spire: Color) -> void:
	_r(x - 2.2 * s, y, x + 1.6 * s, y + 3.2 * s, WHITE)
	_poly([x - 2.5 * s, y + 3.2 * s, x + 1.9 * s, y + 3.2 * s, x - 0.3 * s, y + 4.8 * s], Color("8a4a3a"))
	_r(x + 1.6 * s, y, x + 3.2 * s, y + 6.5 * s, WHITE)
	_poly([x + 1.4 * s, y + 6.5 * s, x + 3.4 * s, y + 6.5 * s, x + 2.4 * s, y + 11.5 * s], spire)
	if _detail(1.0):
		_r(x + 2.1 * s, y + 4.6 * s, x + 2.7 * s, y + 5.6 * s, WIN)

## A wheel with spokes (old cars).
static func _wheel(x: float, y: float, r: float, rim: Color, spokes: int) -> void:
	_c(x, y, r, TYRE)
	_c(x, y, r * 0.72, rim)
	if _detail(6.0) and spokes > 0:
		for k in spokes:
			var a: float = TAU * k / spokes
			_l(x, y, x + cos(a) * r * 0.7, y + sin(a) * r * 0.7, rim.darkened(0.35), 0.03)
	_c(x, y, r * 0.22, rim.darkened(0.25))

## Zell am See: the blue lake in front, green slopes and the Kitzsteinhorn's snowy glacier peak behind, a cable car
## climbing to it and a small church spire on the shore.
static func _alpine_lake() -> void:
	var far := Color("8d98a6")
	_poly([-40, 6, -30, 14, -22, 12, -14, 22, -6, 18, 4, 34, 12, 30, 20, 24, 28, 20, 40, 10, 40, 6], far)
	_poly([-14, 22, -10, 20, -8, 19.2, -11, 18.5], SNOW) # small snowy side peak
	_poly([4, 34, 12, 30, 15.5, 27.6, 11, 27, 7.5, 28.4, 5, 27.5, 1.5, 29.6, -1, 28], SNOW) # the glacier peak
	_poly([-1, 28, 1.5, 29.6, 5, 27.5, 7.5, 28.4, 11, 27, 15.5, 27.6, 20, 24, 14, 23, 9, 24.5, 4, 23, -2, 25], Color("dfe7ee"))
	# green slopes
	_poly([-40, 4, -34, 10, -24, 9, -16, 13, -8, 10, 2, 16, 12, 13, 22, 11, 32, 8, 40, 5, 40, 3, -40, 3], GRASS)
	_poly([-40, 3, -30, 7, -18, 6, -8, 8, 4, 7, 16, 8, 30, 5, 40, 3], GRASS.darkened(0.15))
	# the cable car from the shore up towards the peak
	var rope := Color("3a3e44")
	_l(-12, 4, 6, 26.5, rope, 0.15)
	for p in [[-6.0, 11.2], [0.0, 18.5]]:
		_l(p[0], p[1] - 4.0, p[0], p[1] + 0.2, rope, 0.3)
	_r(6.5 - 0.0, 26, 9.0, 28, Color("b9b4a8")) # top station
	_l(-1.8, 15.6, -1.8, 14.2, rope, 0.12)
	_r(-3.0, 12.2, -0.6, 14.4, Color("c8322b"))
	_r(-2.6, 13.2, -1.0, 14.0, WIN)
	# the lake
	_r(-40, 0, 40, 3.2, WATER)
	if _detail(0.8):
		for p in [[-30, 1.6, -22], [-6, 0.9, 4], [16, 2.2, 26]]:
			_l(p[0], p[1], p[2], p[1], WATER_L, 0.25)
	# the shore with the church
	_poly([20, 0, 40, 0, 40, 4, 22, 3.4], GRASS.darkened(0.05))
	_church(28, 3.4, 0.9, Color("4e6c58"))
	_r(33, 3.6, 37, 6.2, Color("efe3c4"))
	_poly([32.6, 6.2, 37.4, 6.2, 35, 7.8], Color("8a4a3a"))

## Melk Abbey: the long yellow-and-white baroque abbey on its rock above the Danube, the church in the middle with
## two towers and the big green copper dome between and behind them.
static func _stift_melk() -> void:
	var yel := Color("e8c25a")
	var cop := Color("5f9e86")
	_r(-30, 0, 30, 2.4, WATER)
	if _detail(0.8):
		_l(-26, 1.2, -12, 1.2, WATER_L, 0.25)
		_l(8, 0.9, 22, 0.9, WATER_L, 0.25)
	_poly([-30, 2.4, 30, 2.4, 26, 7, 14, 9, -12, 9, -24, 7, -30, 5], ROCK)
	_poly([-30, 5, -24, 7, -12, 9, -18, 6.5, -26, 4.6], ROCK.lightened(0.1))
	# the long wings
	_r(-27, 8, 27, 15, yel)
	_r(-27, 14.4, 27, 15, WHITE)
	_poly([-27.5, 15, 27.5, 15, 26.5, 16.6, -26.5, 16.6], Color("8a4a3a"))
	_windows(-26, -9, 9.5, 11.5, 9, WIN)
	_windows(-26, -9, 12.2, 13.8, 9, WIN)
	_windows(9, 26, 9.5, 11.5, 9, WIN)
	_windows(9, 26, 12.2, 13.8, 9, WIN)
	for x in [-27.0, -18.0, 18.0, 27.0]:
		_r(x - 0.4, 8, x + 0.4, 15, WHITE)
	# the dome behind the towers
	_r(-4, 15, 4, 21, yel)
	_poly(_arc(0, 21, 4.6, 5.4, 0, PI, 14), cop)
	_poly(_arc(0, 21, 4.6, 5.4, PI * 0.55, PI, 6) + [0, 21], cop.lightened(0.12))
	_r(-0.8, 26.2, 0.8, 28, yel)
	_poly([-1.1, 28, 1.1, 28, 0, 30], cop)
	# the church front and its two towers
	_r(-8, 8, 8, 18, yel)
	_r(-4.5, 8, 4.5, 18, WHITE)
	_poly([-1.4, 8, 1.4, 8, 1.4, 11] + _arc(0, 11, 1.4, 1.2, 0, PI, 6), WIN)
	for x in [-6.5, 6.5]:
		_r(x - 1.6, 8, x + 1.6, 24, yel)
		_r(x - 1.6, 23.4, x + 1.6, 24, WHITE)
		_windows(x - 1.2, x + 1.2, 19, 22, 1, WIN)
		_poly(_arc(x, 24, 1.7, 1.6, 0, PI, 8), cop)
		_r(x - 0.7, 25.4, x + 0.7, 27, yel)
		_poly(_arc(x, 27, 0.9, 1.2, 0, PI, 6), cop)
		_l(x, 28, x, 29.6, LandmarkPainter.GOLD, 0.2)
	_poly([-4.5, 18, 4.5, 18, 0, 20.4], WHITE)

## Hallstatt: the lake in front, the slim white Protestant church spire on the shore, colourful wooden houses stacked
## up the steep green mountainside and the rock face behind.
static func _hallstatt() -> void:
	_poly([-30, 6, -24, 22, -16, 30, -6, 34, 6, 32, 16, 26, 24, 18, 30, 8], ROCK)
	_poly([-16, 30, -6, 34, 0, 33, -8, 26], ROCK.lightened(0.12))
	_poly([-30, 3, -26, 12, -18, 18, -8, 20, 4, 18, 14, 15, 22, 11, 30, 6, 30, 3], Color("4f8a3e"))
	if _detail(0.9): # dark firs over the village
		for p in [[-24, 12], [-19, 16], [-12, 18.4], [10, 15.4], [18, 12.4], [25, 9]]:
			_poly([p[0] - 1.2, p[1] - 2, p[0] + 1.2, p[1] - 2, p[0], p[1] + 1.4], Color("2f5a32"))
	# the houses up the slope (each a wall and a dark roof)
	var cols := [Color("efe3c4"), Color("d9a05a"), Color("e8d6a0"), Color("c96a4a"), Color("f2efe6"), Color("b9c7a0")]
	var houses := [[-20, 4, 3.2], [-15, 6.5, 3.0], [-9, 9, 3.2], [-3, 11, 3.0], [-17, 2.6, 3.0], [-11, 5, 3.2],
		[-5, 7.2, 3.0], [2, 8.8, 3.2], [8, 6.5, 3.0], [12, 4.2, 3.2], [4, 4, 3.0], [16, 2.8, 3.0], [-1, 3.4, 3.0]]
	for k in houses.size():
		var h: Array = houses[k]
		var x: float = h[0]
		var y: float = h[1]
		var w: float = h[2]
		_r(x - w * 0.5, y, x + w * 0.5, y + 2.6, cols[k % cols.size()])
		_poly([x - w * 0.6, y + 2.6, x + w * 0.6, y + 2.6, x, y + 4.0], Color("5a3a2a"))
		if _detail(1.4):
			_r(x - 0.5, y + 0.9, x + 0.5, y + 1.8, WIN)
	# the lake and the shore
	_r(-30, 0, 30, 2.6, WATER)
	if _detail(0.8):
		_l(-26, 1.2, -14, 1.2, WATER_L, 0.25)
		_l(14, 0.8, 26, 0.8, WATER_L, 0.25)
	_r(-24, 2.4, 22, 3.0, Color("b9b4a8"))
	# the Protestant church: a slim white tower with a tall pointed spire
	var x0 := -24.0
	_r(x0 - 1.2, 2.8, x0 + 1.2, 13, WHITE)
	_r(x0 + 0.6, 2.8, x0 + 1.2, 13, WHITE.darkened(0.08))
	_r(x0 + 1.2, 2.8, x0 + 5.2, 7, WHITE)
	_poly([x0 + 1.0, 7, x0 + 5.4, 7, x0 + 3.2, 8.6], Color("6b4a3a"))
	if _detail(1.0):
		_r(x0 - 0.4, 10.4, x0 + 0.4, 11.8, WIN)
	_poly([x0 - 1.4, 13, x0 + 1.4, 13, x0, 22], Color("4a5560"))
	_l(x0, 22, x0, 23.2, LandmarkPainter.GOLD, 0.15)

## Erzberg in Eisenerz: the red-brown iron ore mountain cut into big terraces like a stepped pyramid, and in front
## one of the huge yellow dump trucks (the Haulys, giving tourist rides).
static func _erzberg() -> void:
	var ore := Color("a8583a")
	var steps := 9
	for k in steps:
		var y0: float = k * 3.4
		var half0: float = 35.0 - k * 3.6
		var half1: float = half0 - 2.2
		var col := ore.lightened(0.06 * (k % 2)) if k < steps - 1 else ore.darkened(0.1)
		_poly([-half0, y0, half0, y0, half1, y0 + 3.4, -half1, y0 + 3.4], col)
		_r(-half1, y0 + 3.0, half1, y0 + 3.4, ore.lightened(0.25))
	_poly([-4, 30.6, 4, 30.6, 1.2, 34, -1.6, 34], ore.darkened(0.1))
	if _detail(1.0): # grass on the old upper steps
		_poly([-20, 13.6, -12, 13.6, -12.8, 17.0, -20, 17.0], GRASS)
		_poly([14, 20.4, 18, 20.4, 17.2, 23.8, 14, 23.8], GRASS)
	# the truck, drawn larger than life so it reads beside the mountain
	var yel := Color("f2c22e")
	var yd := yel.darkened(0.2)
	var tx := 14.0
	var k := 1.7
	_poly([tx - 7 * k, 3.4 * k, tx + 3.5 * k, 3.4 * k, tx + 4.5 * k, 7.4 * k, tx - 8 * k, 7.4 * k], yd) # the dump body
	_poly([tx - 7 * k, 4.6 * k, tx + 3.4 * k, 4.6 * k, tx + 4.1 * k, 7 * k, tx - 7.6 * k, 7 * k], yel)
	_r(tx + 3.0 * k, 3.0 * k, tx + 6.6 * k, 4.0 * k, yd) # the deck over the cab
	_r(tx + 3.6 * k, 4.0 * k, tx + 6.2 * k, 6.0 * k, yel)
	_r(tx + 4.3 * k, 4.6 * k, tx + 5.8 * k, 5.6 * k, WIN)
	_r(tx - 7 * k, 2.0 * k, tx + 6.6 * k, 3.4 * k, Color("3a3e44"))
	_wheel(tx - 4.0 * k, 1.9 * k, 1.9 * k, Color("c9a228"), 0)
	_wheel(tx + 4.0 * k, 1.9 * k, 1.9 * k, Color("c9a228"), 0)

## The Red Bull Ring at Spielberg: the track with its red-and-white kerb, a grandstand behind, the huge steel bull
## sculpture and a Formula 1 car racing past.
static func _red_bull_ring() -> void:
	_r(-20, 0, 20, 1.6, GRASS)
	_r(-20, 1.6, 20, 3.4, Color("4a4d52"))
	if _detail(1.0):
		for k in 20:
			_r(-20 + k * 2.0, 3.4, -19 + k * 2.0, 3.9, Color("d8322b"))
			_r(-19 + k * 2.0, 3.4, -18 + k * 2.0, 3.9, WHITE)
	else:
		_r(-20, 3.4, 20, 3.9, Color("d8322b"))
	# the grandstand
	_poly([-19, 3.9, -2, 3.9, -2, 9.5, -19, 6.5], Color("b9b4a8"))
	if _detail(1.0):
		for k in 4:
			var y: float = 4.6 + k * 1.1
			_l(-18.5, y, -2.5, y + (y - 3.9) * 0.53, Color("2d6fbf"), 0.25)
	_poly([-20, 9.8, -1, 11.0, -1, 10.4, -20, 9.2], Color("70767c")) # the roof
	_l(-19, 6.5, -19, 9.4, Color("70767c"), 0.25)
	_l(-2, 9.5, -2, 10.6, Color("70767c"), 0.25)
	# the steel bull: a big dark silhouette charging left, horns up
	var st := Color("8c9298")
	var bx := 11.0
	_poly([bx - 5, 7, bx + 4, 7.4, bx + 6, 9.4, bx + 5.2, 11.6, bx - 2, 12.2, bx - 5.6, 11.0, bx - 7.6, 10.6, bx - 8, 9,
		bx - 6.6, 8.2], st)
	_poly([bx - 5, 7, bx - 3.8, 7, bx - 3.4, 3.9, bx - 4.6, 3.9], st.darkened(0.15))
	_poly([bx - 2.2, 7.2, bx - 1.0, 7.2, bx - 0.6, 3.9, bx - 1.8, 3.9], st)
	_poly([bx + 2.2, 7.4, bx + 3.4, 7.4, bx + 3.8, 3.9, bx + 2.6, 3.9], st.darkened(0.15))
	_poly([bx + 4.4, 8.2, bx + 5.4, 8.6, bx + 5.4, 3.9, bx + 4.4, 3.9], st)
	_poly([bx - 6.4, 11.2, bx - 7.2, 13.6, bx - 5.4, 11.6], Color("d8d2c2")) # horns
	_poly([bx - 4.8, 11.6, bx - 4.2, 14.0, bx - 3.8, 11.8], Color("d8d2c2"))
	_l(bx + 6, 9.6, bx + 7.4, 8.0, st, 0.3) # tail
	# the Formula 1 car on the track, drawn larger than life so it reads beside the grandstand
	var cx := 1.0
	var k := 2.4
	var car := Color("2d5fd0")
	_poly([cx - 2.2 * k, 2.0, cx + 2.2 * k, 2.0, cx + 2.3 * k, 2.0 + 0.2 * k, cx + 0.5 * k, 2.0 + 0.5 * k,
		cx - 0.8 * k, 2.0 + 0.6 * k, cx - 1.8 * k, 2.0 + 0.4 * k], car)
	_r(cx - 2.3 * k, 2.0, cx - 1.9 * k, 2.0 + 0.8 * k, Color("d8322b")) # rear wing
	_r(cx + 1.9 * k, 2.0 - 0.05 * k, cx + 2.4 * k, 2.0 + 0.1 * k, Color("d8322b")) # front wing
	_c(cx - 0.3 * k, 2.0 + 0.6 * k, 0.18 * k, Color("f2c22e")) # helmet
	_c(cx - 1.4 * k, 2.0 + 0.1 * k, 0.33 * k, TYRE)
	_c(cx + 1.45 * k, 2.0 + 0.1 * k, 0.28 * k, TYRE)

## The Großglockner seen from Heiligenblut: Austria's highest mountain, a sharp snowy pyramid over its glacier, and in
## front the slim white pilgrimage church with its very tall pointed spire.
static func _grossglockner() -> void:
	var rock := Color("7b7f86")
	_poly([-35, 8, -26, 18, -18, 16, -8, 30, 0, 44, 6, 36, 14, 30, 24, 22, 35, 12, 35, 8], rock)
	_poly([0, 44, 6, 36, 3.6, 34, 1, 36.8, -2.5, 34.6, -5, 34.6], SNOW)
	_poly([-8, 30, -5, 34.6, -2.5, 34.6, 1, 36.8, 3.6, 34, 6, 36, 14, 30, 24, 22, 18, 21, 10, 23, 4, 20, -4, 23, -12, 24],
		Color("dfe7ee"))
	_poly([-26, 18, -18, 16, -22, 14.5], SNOW)
	_poly([-4, 23, 4, 20, 10, 23, 18, 21, 12, 18, 2, 17, -6, 19], Color("c9d8e4")) # the glacier tongue
	# green valley slopes
	_poly([-35, 0, 35, 0, 35, 10, 26, 13, 16, 12, 8, 14, 0, 12, -10, 14, -20, 12, -28, 13, -35, 10], GRASS)
	_poly([-35, 0, 35, 0, 35, 5, 18, 7, 2, 6, -16, 7, -35, 5], GRASS.darkened(0.15))
	# the church in front: a nave and the very tall spire on the left
	var x0 := -8.0
	_r(x0, 2, x0 + 10, 7.5, WHITE)
	_poly([x0 - 0.3, 7.5, x0 + 10.3, 7.5, x0 + 5, 10.2], Color("5a5f66"))
	if _detail(1.0):
		_windows(x0 + 2.5, x0 + 9.5, 3.6, 6.0, 3, WIN)
	_r(x0 - 2.6, 2, x0 + 0.4, 15, WHITE)
	_r(x0 - 0.4, 2, x0 + 0.4, 15, WHITE.darkened(0.08))
	if _detail(0.8):
		_r(x0 - 1.6, 12, x0 - 0.6, 13.6, WIN)
	_c(x0 - 1.1, 10.4, 0.6, Color("6b7a8a")) # clock
	_poly([x0 - 2.9, 15, x0 + 0.7, 15, x0 - 1.1, 31], Color("4a5560"))
	_l(x0 - 1.1, 31, x0 - 1.1, 32.4, LandmarkPainter.GOLD, 0.2)

## Swarovski Crystal Worlds in Wattens: a grassy hill shaped as a giant's head, two glittering crystal eyes, and a
## waterfall pouring from his mouth into the pond.
static func _swarovski() -> void:
	var g := Color("5d9a46")
	var gd := g.darkened(0.18)
	_poly(_arc(0, 0, 12, 14, 0, PI, 20), g)
	_poly([-12, 0, -8, 0, -6, 6, -9.4, 9.6, -11.6, 5], gd)
	if _detail(1.0): # grass texture
		for p in [[-6, 12], [5, 11], [8, 6], [-3, 3]]:
			_l(p[0], p[1], p[0] + 0.4, p[1] + 0.8, gd, 0.12)
	# the eyes: blue-white crystals with glints
	for x in [-4.4, 4.4]:
		_poly([x - 2.2, 8.4, x, 10.4, x + 2.2, 8.4, x, 6.6], Color("7fd0f0"))
		_poly([x - 2.2, 8.4, x, 10.4, x, 8.4], Color("d8f4ff"))
		_poly([x, 6.6, x + 2.2, 8.4, x, 8.4], Color("3d8fbf"))
		if _detail(1.5):
			_l(x + 1.2, 10.6, x + 1.2, 11.8, WHITE, 0.12)
			_l(x + 0.6, 11.2, x + 1.8, 11.2, WHITE, 0.12)
	# the nose and the mouth with the waterfall
	_poly([-1, 6.4, 1, 6.4, 0, 8.4], gd)
	_poly([-3, 3.6, 3, 3.6, 2, 4.8, -2, 4.8], Color("2e3a2e"))
	_r(-2, 0.8, 2, 3.8, Color("b7e0f4"))
	if _detail(1.0):
		for x in [-1.2, 0.0, 1.2]:
			_l(x, 3.6, x, 1.0, WHITE, 0.12)
	_poly(_arc(0, 0.8, 7, 1.2, PI, TAU, 12), WATER)
	_r(-7, 0, 7, 0.8, WATER)

## The Hahnenkamm cable car in Kitzbühel: the snowy slope, steel pylons, a red gondola cabin on the rope and the
## valley station at the bottom.
static func _gondola() -> void:
	_poly([-22, 0, 22, 0, 22, 36, 14, 34, 4, 28, -6, 20, -16, 10, -22, 6], SNOW)
	_poly([22, 36, 22, 26, 12, 22, 4, 28, 14, 34], Color("dfe7ee"))
	if _detail(0.8): # firs along the piste
		for p in [[-14, 6], [-8, 11], [-2, 16], [6, 22], [12, 10], [16, 16], [-4, 4]]:
			_poly([p[0] - 1.4, p[1] - 2.4, p[0] + 1.4, p[1] - 2.4, p[0], p[1] + 2], Color("2f5a32"))
			_r(p[0] - 0.2, p[1] - 3.2, p[0] + 0.2, p[1] - 2.4, Color("5a3a2a"))
	var steel := Color("6b7178")
	# the valley station
	_r(-21, 0, -12, 5, Color("efe3c4"))
	_poly([-21.6, 5, -11.4, 5, -13, 7, -20, 7], Color("8a4a3a"))
	if _detail(1.0):
		_windows(-20, -13, 1.6, 3.6, 3, WIN)
	# the rope up the slope, pylons under it
	_l(-13, 6, 20, 33, steel, 0.15)
	for x in [-2.0, 10.0]:
		var y: float = 6.0 + (x + 13.0) * 27.0 / 33.0
		_l(x, y - 9.0, x, y, steel, 0.6)
		_l(x - 1.4, y, x + 1.4, y, steel, 0.3)
	# the cabin
	var gx := 4.0
	var gy := 6.0 + (gx + 13.0) * 27.0 / 33.0
	_l(gx, gy, gx, gy - 1.6, steel, 0.15)
	_r(gx - 2.4, gy - 6.2, gx + 2.4, gy - 1.6, Color("c8322b"))
	_r(gx - 1.8, gy - 3.8, gx + 1.8, gy - 2.4, WIN)

## A 1920s Rolls-Royce from the museum in Dornbirn: a long bonnet, the silver radiator with the Spirit of Ecstasy
## on top, separate mudguards and running boards, spoked wheels, two-tone paint.
static func _rolls_royce() -> void:
	var low := Color("2c3a5c")
	var up := Color("b9bcc2")
	var silver := Color("d9dde2")
	_r(-2.6, 0.75, 2.6, 0.9, Color("1e2226")) # running board
	_poly([-3.0, 0.9, -1.6, 0.9, -1.6, 1.4, -3.0, 1.2], low) # rear mudguard to the boot
	_r(-2.4, 0.9, 0.6, 1.9, low) # the body
	_r(-2.4, 1.9, 0.0, 2.7, up) # the hood/top
	_r(-2.4, 2.6, 0.0, 2.75, Color("1e2226"))
	if _detail(10.0):
		_r(-2.1, 2.0, -1.3, 2.5, WIN)
		_r(-1.1, 2.0, -0.3, 2.5, WIN)
	_poly([0.0, 1.9, 0.6, 1.9, 0.6, 2.4, 0.15, 2.4], WIN.lightened(0.3)) # windscreen
	_r(0.6, 1.0, 2.5, 1.6, up) # the long bonnet
	_r(0.6, 1.55, 2.5, 1.65, silver)
	_r(2.5, 0.85, 2.85, 1.75, silver) # radiator
	if _detail(10.0):
		_l(2.68, 0.95, 2.68, 1.65, Color("8c9298"), 0.04)
	_l(2.7, 1.75, 2.75, 1.95, silver, 0.06) # the figurine
	_c(2.75, 1.97, 0.04, silver)
	_poly([1.4, 0.9, 2.9, 0.9, 2.9, 1.1, 1.8, 1.25], low) # front mudguard
	_c(2.9, 1.25, 0.13, Color("f2e6a0")) # lamp
	_wheel(-1.9, 0.45, 0.45, silver, 10)
	_wheel(2.0, 0.45, 0.45, silver, 10)

## The first Porsche, the 356 from Gmünd: a small rounded silver car, bulging wings, a sloping back.
static func _porsche_356() -> void:
	var s := Color("c4c8ce")
	var sd := s.darkened(0.18)
	_poly([-2.4, 0.4, 2.4, 0.4, 2.45, 0.7] + _arc(1.7, 0.7, 0.75, 0.45, 0, PI * 0.5, 5) + [0.6, 1.25] +
		_arc(-0.2, 1.1, 1.2, 0.75, PI * 0.15, PI * 0.95, 8) + [-2.4, 0.9], s)
	_poly(_arc(-0.25, 1.15, 0.95, 0.55, PI * 0.2, PI * 0.85, 6), WIN.lightened(0.15)) # side windows
	if _detail(12.0):
		_l(-0.25, 1.2, -0.25, 1.65, s, 0.05)
	_r(-2.4, 0.38, 2.4, 0.5, sd)
	_c(2.1, 0.75, 0.12, Color("f2e6a0"))
	_wheel(-1.45, 0.38, 0.38, Color("8c9298"), 0)
	_wheel(1.5, 0.38, 0.38, Color("8c9298"), 0)

## The Milka cow from Bludenz, where the chocolate is made: lilac with white patches, a bell on her neck, on grass.
static func _milka_cow() -> void:
	var lil := Color("9b7fc8")
	var ld := lil.darkened(0.18)
	_r(-2.5, 0, 2.5, 0.25, GRASS)
	for x in [-1.4, -0.9, 0.9, 1.4]:
		_r(x - 0.14, 0.25, x + 0.14, 1.6, ld if absf(x) < 1.0 else lil)
		_r(x - 0.16, 0.2, x + 0.16, 0.38, Color("3a3030"))
	_poly(_arc(0, 2.2, 1.9, 0.75, 0, TAU, 16), lil)
	_poly(_arc(-0.6, 2.4, 0.55, 0.35, 0, TAU, 10), WHITE)
	_poly(_arc(0.7, 2.1, 0.4, 0.3, 0, TAU, 10), WHITE)
	_l(-1.9, 2.4, -2.3, 1.6, lil, 0.1) # tail
	_c(-2.3, 1.55, 0.1, ld)
	# the head
	_poly([1.6, 2.2, 2.4, 2.6, 2.6, 3.0, 2.0, 3.2, 1.6, 2.8], lil)
	_poly(_arc(2.55, 2.55, 0.32, 0.25, 0, TAU, 10), Color("f0c8d8")) # muzzle
	_l(1.9, 3.2, 1.75, 3.6, WHITE, 0.08) # horns
	_l(2.15, 3.2, 2.3, 3.6, WHITE, 0.08)
	_c(2.1, 2.95, 0.07, Color("1e2226"))
	# the bell
	_l(1.6, 2.4, 1.9, 1.9, Color("8a4a3a"), 0.06)
	_poly([1.75, 1.85, 2.05, 1.85, 2.15, 1.5, 1.65, 1.5], LandmarkPainter.GOLD)
