class_name LandmarksAtA
extends RefCounted
## Austrian landmarks, drawn with LandmarkPainter's helpers (metres from the base point, y up).

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
const AT_RED := Color("c8102e")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"stephansdom": _stephansdom()
		"riesenrad": _riesenrad()
		"uhrturm": _uhrturm()
		"g_class": _g_class()
		"ars_electronica": _ars_electronica()
		"linzer_torte": _linzer_torte()
		"hohensalzburg": _hohensalzburg()
		"mozart_house": _mozart_house()
		"golden_roof": _golden_roof()
		"minimundus": _minimundus()
		"steyr_tractor": _steyr_tractor()
		"schwammerlturm": _schwammerlturm()
		"seebuehne": _seebuehne()
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

## A wheel seen from the side: tyre, rim and hub.
static func _wheel(x: float, y: float, r: float, rim: Color) -> void:
	_c(x, y, r, Color("1e2023"))
	_c(x, y, r * 0.55, rim)
	_c(x, y, r * 0.2, Color("1e2023"))

## St. Stephen's Cathedral in Vienna: the Gothic nave under its steep roof of glazed tiles laid in green, yellow and
## black zigzags, the tall south spire (Steffl) rising to a needle, the unfinished north tower with its small
## Renaissance cap.
static func _stephansdom() -> void:
	var s := Color("c9b79a")
	var sd := s.darkened(0.18)
	# the nave
	_r(-17, 0, 17, 14, s)
	for x in [-17.0, -10.0, 3.0, 10.0, 17.0]:
		_r(x - 0.6, 0, x + 0.6, 12, sd)
		_poly([x - 0.6, 12, x + 0.6, 12, x, 14.5], sd)
	for x in [-3.5, 6.5]:
		_poly([x - 1.3, 3, x + 1.3, 3, x + 1.3, 9] + _arc(x, 9, 1.3, 2.2, 0, PI, 6), WIN)
	# the roof: yellow-green tiles, zigzag bands
	var roof := [-17.6, 14, 17.6, 14, 13.5, 30, -13.5, 30]
	_poly(roof, Color("d6b84a"))
	var bands := [Color("2f7a4a"), DARK, Color("2f7a4a")]
	for i in 3:
		var y0: float = 16.5 + i * 4.6
		var half: float = 17.6 - (y0 - 14.0) * 4.1 / 16.0
		var n := 10
		var step := half * 2.0 / n
		for k in n:
			var x: float = -half + k * step
			_poly([x, y0, x + step * 0.5, y0 + 2.2, x + step, y0, x + step, y0 + 1.0, x + step * 0.5, y0 + 3.2, x, y0 + 1.0], bands[i])
	_r(-13.5, 29.6, 13.5, 30.4, DARK)
	# the north tower with its cap
	_r(9, 0, 15, 31, s)
	_r(9, 0, 10.2, 31, sd)
	_windows(9.6, 14.4, 22, 27, 2, WIN)
	_poly(_arc(12, 31, 3.2, 3.0, 0, PI, 10), Color("5e8f7a"))
	_r(11.6, 33.8, 12.4, 35.5, Color("5e8f7a"))
	_c(12, 35.8, 0.5, GOLD)
	# the south tower and spire (the Steffl), at the west end of the nave
	var t := s.lightened(0.04)
	_r(-17, 0, -7, 24, t)
	_r(-17, 0, -15.6, 24, sd)
	_poly([-17, 24, -7, 24, -8.2, 34, -15.8, 34], t)
	_poly([-15.8, 34, -8.2, 34, -9.4, 44, -14.6, 44], t.darkened(0.04))
	_poly([-14.6, 44, -9.4, 44, -12, 63], t.darkened(0.08))
	_l(-12, 63, -12, 64, GOLD, 0.3)
	for p in [[-16.5, 24], [-7.5, 24], [-15.4, 34], [-8.6, 34], [-14.2, 44], [-9.8, 44]]:
		_poly([p[0] - 0.5, p[1], p[0] + 0.5, p[1], p[0], p[1] + 3.5], sd)
	if _detail(0.8):
		_poly([-13.4, 6, -10.6, 6, -10.6, 15] + _arc(-12, 15, 1.4, 3.0, 0, PI, 6), WIN)
		_poly([-13, 26, -11, 26, -11, 31] + _arc(-12, 31, 1.0, 1.6, 0, PI, 5), WIN)
		_poly([-12.8, 37, -11.2, 37, -11.2, 41] + _arc(-12, 41, 0.8, 1.2, 0, PI, 5), WIN)
		_l(-13.4, 46, -12, 60, sd, 0.15)
		_l(-10.6, 46, -12, 60, sd, 0.15)

## The Giant Ferris Wheel (Riesenrad) in the Prater: a big spoked wheel held by a lattice frame, the red cabins
## like little railway wagons hanging round the rim, the wheel turning slowly.
static func _riesenrad() -> void:
	var cy := 24.0
	var rr := 19.0
	var steel := Color("5a5f66")
	# the base hall
	_r(-10, 0, 10, 3.2, Color("d9c9a6"))
	_r(-10.5, 3.2, 10.5, 3.8, RED_ROOF)
	_windows(-9, 9, 0.8, 2.4, 6, WIN)
	# frame legs
	for sx in [-1.0, 1.0]:
		_l(sx * 13.0, 0, 0, cy, steel, 0.6)
		_l(sx * 7.0, 0, 0, cy, steel, 0.5)
		if _detail(1.0):
			for k in 5:
				var f: float = float(k + 1) / 6.0
				_l(lerpf(sx * 13.0, 0, f), cy * f, lerpf(sx * 7.0, 0, f + 0.15), cy * (f + 0.15), steel, 0.15)
	var turn := Time.get_ticks_msec() * 0.00008
	var n := 15
	# rim (two rings) and spokes
	for ring in [rr, rr - 1.6]:
		var pts := _arc(0, cy, ring, ring, 0, TAU, 40)
		for k in range(0, pts.size() - 2, 2):
			_l(pts[k], pts[k + 1], pts[k + 2], pts[k + 3], steel, 0.25)
	for k in n * 2:
		var a: float = turn + TAU * k / (n * 2)
		_l(0, cy, cos(a) * rr, cy + sin(a) * rr, steel, 0.1)
	_c(0, cy, 1.2, steel.darkened(0.2))
	# cabins
	for k in n:
		var a: float = turn + TAU * k / n
		var x: float = cos(a) * rr
		var y: float = cy + sin(a) * rr
		_l(x, y, x, y - 0.6, steel, 0.15)
		_r(x - 1.3, y - 2.4, x + 1.3, y - 0.6, AT_RED)
		_r(x - 1.4, y - 0.8, x + 1.4, y - 0.5, Color("7a1a14"))
		if _detail(1.4):
			_r(x - 1.0, y - 1.7, x + 1.0, y - 1.0, Color("f2efe6"))

## The Clock Tower (Uhrturm) of Graz on the wooded Schlossberg: the square white tower with its big clock faces,
## the wooden gallery under the roof and the dark pointed roof.
static func _uhrturm() -> void:
	_poly([-18, 0, -14, 6, -9, 12, -4, 16, 4, 16, 10, 12, 15, 6, 18, 0], GRASS)
	for p in [[-13, 5, 2.6], [-8, 9.5, 2.8], [-3, 13, 2.4], [7, 12.5, 2.6], [12, 8, 2.8], [15.5, 3.5, 2.2], [-15.5, 2.5, 2.2], [3, 6, 3]]:
		_c(p[0], p[1], p[2], TREE)
	_r(-6, 15, 6, 17, STONE.darkened(0.1)) # the bastion
	var w := WHITE
	_r(-3.4, 16, 3.4, 25.5, w)
	_r(-3.4, 16, -2.4, 25.5, w.darkened(0.08))
	_c(0.4, 22.6, 2.3, DARK)
	_c(0.4, 22.6, 2.0, Color("f7f3e6"))
	_l(0.4, 22.6, 0.4, 24.0, DARK, 0.25)
	_l(0.4, 22.6, 1.4, 22.6, DARK, 0.25)
	if _detail(1.0):
		_windows(-2.4, 3, 17.2, 19, 2, WIN)
	# the wooden gallery
	_r(-4.4, 25.5, 4.4, 26.6, Color("7a4f2a"))
	if _detail(1.0):
		for x in [-3.6, -2.0, -0.4, 1.2, 2.8]:
			_r(x, 25.7, x + 0.7, 26.4, Color("b07a44"))
	# roof
	_poly([-4.6, 26.6, 4.6, 26.6, 3.2, 27.6, 1.0, 29.2, -1.0, 29.2, -3.2, 27.6], Color("3b3f3a"))
	_l(0, 29.2, 0, 30, GOLD, 0.2)

## The Mercedes G-Class, built in Graz: a tall boxy off-roader, dark green, round headlights and the spare
## wheel on its back door.
static func _g_class() -> void:
	var body := Color("2f3d2c")
	var hi := body.lightened(0.12)
	_r(-2.6, 0.5, 2.6, 1.6, body)
	_r(-2.4, 1.6, 1.5, 2.65, body)
	_poly([1.5, 1.6, 2.25, 1.6, 1.6, 2.65, 1.5, 2.65], body) # the upright windscreen
	_r(-2.6, 1.5, 2.6, 1.62, hi)
	_r(-2.1, 1.75, -0.6, 2.45, Color("8fb3c9"))
	_r(-0.4, 1.75, 1.15, 2.45, Color("8fb3c9"))
	_r(-2.6, 0.5, 2.6, 0.7, DARK)
	_c(2.45, 1.3, 0.2, Color("f2efd0"))
	_r(2.55, 0.75, 2.75, 1.0, Color("9aa0a6"))
	_c(-2.75, 1.25, 0.48, Color("1e2023")) # spare wheel
	_c(-2.75, 1.25, 0.22, Color("9aa0a6"))
	_wheel(-1.55, 0.45, 0.45, Color("9aa0a6"))
	_wheel(1.65, 0.45, 0.45, Color("9aa0a6"))

## The Ars Electronica Center in Linz: the glass wedge of a building by the Danube, its skin of LED panes
## glowing in shifting colour stripes.
static func _ars_electronica() -> void:
	_r(-18, 0, 18, 1.6, WATER)
	if _detail(1.0):
		_l(-16, 0.8, -6, 0.8, WATER_L, 0.2)
		_l(4, 0.5, 15, 0.5, WATER_L, 0.2)
	_r(-18, 1.6, 18, 3, Color("b4ada0")) # the quay
	var cols := [Color("e0409a"), Color("6a4ae0"), Color("2fa8e8"), Color("3ccf8a"), Color("f2d23a"), Color("f2803a")]
	var shift := int(Time.get_ticks_msec() / 900.0)
	var n := 14
	var x0 := -14.0
	var x1 := 14.0
	var step := (x1 - x0) / n
	for k in n:
		var xa: float = x0 + k * step
		var xb: float = xa + step
		var ha: float = 19.5 - (xa - x0) / (x1 - x0) * 7.5
		var hb: float = 19.5 - (xb - x0) / (x1 - x0) * 7.5
		_poly([xa, 3, xb, 3, xb, hb, xa, ha], cols[(k + shift) % cols.size()])
	if _detail(1.0):
		for k in range(1, 5):
			var y: float = 3.0 + k * 3.0
			_l(x0, y, x1, minf(y, 12.0), Color(1, 1, 1, 0.35), 0.1)
	_l(x0, 19.5, x1, 12, Color("2e3238"), 0.25)
	_r(x0, 3, x0 + 0.3, 19.5, DARK)
	_r(x1 - 0.3, 3, x1, 12, DARK)

## The Linzer Torte, as a giant cake: a round tart of nutty dough, red currant jam under a lattice of dough
## strips, almonds round its side, on a white plate.
static func _linzer_torte() -> void:
	var dough := Color("b9773d")
	var cy := 1.9
	_poly(_arc(0, 0.3, 3.9, 0.45, 0, TAU, 20), Color("eeeeea"))
	_r(-3.5, 0.5, 3.5, cy, dough)
	_poly(_arc(0, 0.5, 3.5, 0.9, PI, TAU, 16), dough.darkened(0.08))
	if _detail(3.0):
		for x in [-2.8, -1.6, -0.4, 0.8, 2.0, 3.0]:
			_poly([x - 0.25, 1.1, x, 1.35, x + 0.25, 1.1, x, 0.85], Color("e8d8b0"))
	_poly(_arc(0, cy, 3.5, 1.0, 0, TAU, 24), dough.lightened(0.1))
	_poly(_arc(0, cy, 3.0, 0.82, 0, TAU, 24), Color("a8202a"))
	# the lattice
	for k in range(-3, 4):
		var x: float = k * 0.8
		var h: float = 0.82 * sqrt(maxf(0.0, 1.0 - pow(x / 3.0, 2)))
		_l(x - 0.35, cy - h, x + 0.35, cy + h, dough.lightened(0.18), 0.22)
		_l(x + 0.35, cy - h, x - 0.35, cy + h, dough.lightened(0.18), 0.22)

## Hohensalzburg Fortress over Salzburg: the long white castle on its wooded rock ridge, the high keep with its
## towers, the walls and the red funicular climbing the slope.
static func _hohensalzburg() -> void:
	_poly([-35, 0, -30, 6, -24, 14, -18, 20, 18, 21, 26, 15, 31, 7, 35, 0], ROCK)
	for p in [[-29, 4, 3], [-24, 9, 3.4], [-12, 7, 4], [0, 9, 4.6], [12, 8, 4], [24, 8, 3.6], [30, 3, 3], [-6, 15, 3.4], [8, 16, 3.2], [-18, 14, 2.8], [20, 14, 2.8]]:
		_c(p[0], p[1], p[2], TREE)
	var w := WHITE
	var ws := w.darkened(0.1)
	_r(-24, 19.5, 22, 23.5, Color("ddd6c6")) # the outer walls
	_r(-22, 23.5, 18, 29, w)
	_windows(-20, 16, 25, 27, 12, WIN)
	_poly([-22.4, 29, 18.4, 29, 16, 31, -20, 31], Color("7d6a5a"))
	# the keep (Hoher Stock) and its towers
	_r(-6, 29, 7, 36, w)
	_r(-6, 29, -4.6, 36, ws)
	_windows(-4, 6, 31.5, 34, 4, WIN)
	_poly([-6.4, 36, 7.4, 36, 5.6, 38.4, -4.6, 38.4], Color("7d6a5a"))
	_r(-1.5, 36, 1.5, 38.6, w)
	_poly([-1.9, 38.6, 1.9, 38.6, 0, 40], Color("5e8f7a"))
	for x in [-22.0, 18.0]:
		_r(x - 2, 22, x + 2, 32, ws)
		_poly([x - 2.4, 32, x + 2.4, 32, x, 34.5], Color("5e8f7a"))
	_r(9, 29, 13, 33.5, w)
	_poly([8.6, 33.5, 13.4, 33.5, 11, 35.5], Color("7d6a5a"))
	# the funicular
	_l(-31, 1, -20, 20, Color("6b5a3a"), 0.4)
	_poly([-26.9, 8, -24.3, 8, -23.3, 10.6, -25.9, 10.6], AT_RED)

## Mozart's birthplace, Getreidegasse 9 in Salzburg: the tall narrow yellow house with rows of windows, the gold
## lettering band "Mozarts Geburtshaus" and the red-white-red flag on the roof.
static func _mozart_house() -> void:
	_r(-7, 0, -5.5, 18, Color("d8cdb5")) # the neighbours
	_r(5.5, 0, 7, 17, Color("b8c9a8"))
	var y := Color("e9c25a")
	_r(-5.5, 0, 5.5, 19.5, y)
	_r(-5.5, 19.5, 5.5, 20.3, Color("7d6a5a"))
	_r(-5.5, 3.6, 5.5, 4.1, y.darkened(0.15))
	for k in 5:
		var y0: float = 5.2 + k * 2.8
		if k == 2:
			continue
		_windows(-5, 5, y0, y0 + 1.7, 4, WIN)
	_r(-4.8, 10.6, 4.8, 12.2, Color("6b4a20")) # the lettering band
	if _detail(1.6):
		for k in 9:
			_r(-4.3 + k * 0.98, 11.1, -3.8 + k * 0.98, 11.7, GOLD)
	else:
		_r(-4.3, 11.2, 4.3, 11.6, GOLD)
	_poly([-1.4, 0, 1.4, 0, 1.4, 2.2] + _arc(0, 2.2, 1.4, 1.0, 0, PI, 6), Color("4a3020"))
	_r(-4.6, 0.6, -2.6, 2.6, WIN)
	_r(2.6, 0.6, 4.6, 2.6, WIN)
	# the flag
	_l(3.5, 20.3, 3.5, 22, DARK, 0.12)
	_r(3.6, 20.9, 6.0, 21.25, AT_RED)
	_r(3.6, 21.25, 6.0, 21.6, Color.WHITE)
	_r(3.6, 21.6, 6.0, 21.95, AT_RED)

## The Golden Roof (Goldenes Dachl) in Innsbruck: an old town house with the late-Gothic oriel balconies, topped
## by the roof of 2,657 gilded copper tiles shining gold.
static func _golden_roof() -> void:
	var house := Color("e8dcc0")
	_r(-7, 0, 7, 16, house)
	_poly([-7.4, 16, 7.4, 16, 0, 21.5], Color("6b4a3a"))
	_windows(-6.5, -3, 11, 13, 2, WIN)
	_windows(3, 6.5, 11, 13, 2, WIN)
	_windows(-6.5, -3, 6, 8, 2, WIN)
	_windows(3, 6.5, 6, 8, 2, WIN)
	# arcades
	for x in [-5.0, 0.0, 5.0]:
		_poly([x - 1.6, 0, x + 1.6, 0, x + 1.6, 2.4] + _arc(x, 2.4, 1.6, 1.2, 0, PI, 6), Color("8a7c66"))
	# the oriel
	var o := Color("f2ead8")
	_r(-2.8, 4, 2.8, 15.2, o)
	_r(-2.8, 4, -2.0, 15.2, o.darkened(0.1))
	_r(-3.1, 8.6, 3.1, 9.6, Color("c9b79a")) # the lower balcony parapet
	_r(-3.1, 12.6, 3.1, 13.4, Color("c9b79a"))
	if _detail(1.2):
		for x in [-2.2, -0.8, 0.6, 2.0]:
			_r(x, 8.8, x + 0.5, 9.4, Color("b5432e"))
			_r(x, 12.7, x + 0.5, 13.2, Color("3d5a78"))
		_windows(-2.4, 2.4, 10.2, 12.2, 3, WIN)
	# the golden roof
	_poly([-3.4, 15.2, 3.4, 15.2, 2.2, 17.5, 0, 18.8, -2.2, 17.5], GOLD)
	_poly([-3.4, 15.2, -1.6, 15.2, -0.6, 18.4, -2.2, 17.5], GOLD.lightened(0.25))
	if _detail(1.2):
		for k in 3:
			var y: float = 15.8 + k * 0.9
			_l(-3.0 + k * 0.4, y, 3.0 - k * 0.4, y, GOLD.darkened(0.2), 0.08)

## Minimundus by the Wörthersee: a park of little models, a small Eiffel Tower, a small Big Ben, a small church
## and a toy ship on a pond, behind a low hedge.
static func _minimundus() -> void:
	_r(-20, 0, 20, 1, GRASS)
	# the Eiffel Tower
	var iron := Color("7a5a3a")
	_poly([-16.2, 1, -14.8, 1, -12.4, 8, -13.6, 8], iron)
	_poly([-7.8, 1, -9.2, 1, -11.6, 8, -10.4, 8], iron)
	_r(-15.2, 4.2, -8.8, 4.8, iron)
	_r(-13.8, 8, -10.2, 8.6, iron)
	_poly([-13.2, 8.6, -10.8, 8.6, -11.85, 18.5, -12.15, 18.5], iron)
	_r(-12.7, 12.5, -11.3, 13, iron)
	_l(-12, 18.5, -12, 19.6, iron, 0.15)
	# Big Ben
	var sand := Color("d9c08a")
	_r(-3, 1, -0.6, 13, sand)
	_c(-1.8, 11.4, 0.85, Color("f2efe6"))
	_poly([-3.2, 13, -0.4, 13, -1.8, 16], Color("4a5a50"))
	_r(-0.6, 1, 3.6, 5, sand.darkened(0.08))
	_poly([-0.6, 5, 3.6, 5, 1.5, 6.6], Color("4a5a50"))
	# a church
	_r(5, 1, 11, 5, WHITE)
	_poly([4.6, 5, 11.4, 5, 8, 7.6], RED_ROOF)
	_r(5, 1, 6.8, 9, WHITE)
	_poly([4.8, 9, 7, 9, 5.9, 11.6], Color("5e8f7a"))
	# the pond and the ship
	_poly(_arc(15.5, 1, 4.2, 0.7, PI, TAU, 10), WATER)
	_r(11.3, 0.95, 19.7, 1.1, WATER)
	_poly([13.6, 1.3, 17.6, 1.3, 17.0, 0.7, 14.0, 0.7], Color("2e3238"))
	_r(14.6, 1.3, 16.4, 1.9, WHITE)
	_r(15.4, 1.9, 15.9, 2.6, AT_RED)
	# the hedge
	for x in [-19.0, -7.0, 3.8]:
		_r(x, 1, x + 1.4, 2, TREE)

## A red Steyr tractor: big rear wheels, small front ones, the long bonnet with its exhaust pipe and the cab.
static func _steyr_tractor() -> void:
	var red := Color("c62a24")
	_r(-0.6, 0.9, 2.7, 1.9, red)
	_r(2.55, 0.95, 2.75, 1.85, Color("dddddd"))
	_r(-0.6, 1.75, 2.7, 1.9, red.lightened(0.15))
	_r(-2.3, 1.2, -0.4, 2.0, red.darkened(0.1))
	_r(-2.2, 2.0, -2.0, 3.5, DARK)
	_r(-0.6, 2.0, -0.4, 3.5, DARK)
	_r(-2.0, 2.1, -0.6, 3.3, Color("8fb3c9"))
	_r(-2.4, 3.5, -0.2, 3.75, red)
	_r(1.8, 1.9, 1.95, 2.8, DARK)
	_wheel(-1.25, 1.1, 1.1, Color("e0b43a"))
	_wheel(1.95, 0.55, 0.55, Color("e0b43a"))

## The Schwammerlturm in Leoben: the old town gate tower with a gate arch through it and its mushroom
## ("Schwammerl") shaped roof.
static func _schwammerlturm() -> void:
	var s := Color("e6dcc6")
	_r(-3, 0, 3, 15, s)
	_r(-3, 0, -2.2, 15, s.darkened(0.1))
	_poly([-1.6, 0, 1.6, 0, 1.6, 3] + _arc(0, 3, 1.6, 1.6, 0, PI, 8), Color("4a3020"))
	_windows(-2, 2, 8, 10, 2, WIN)
	_c(0, 12.6, 1.1, Color("f7f3e6"))
	_c(0, 12.6, 0.2, DARK)
	var roof := Color("4a4f52")
	_poly([-3.2, 15, 3.2, 15, 4.8, 16, -4.8, 16], roof.darkened(0.1))
	_poly([-4.8, 16] + _arc(0, 16, 4.8, 4.2, 0, PI, 14), roof)
	_poly(_arc(0, 16, 4.8, 4.2, PI * 0.55, PI * 0.9, 6) + [0, 16], roof.lightened(0.12))
	_r(-0.7, 20, 0.7, 21.2, roof)
	_l(0, 21.2, 0, 22, GOLD, 0.2)

## The Bregenz floating stage on Lake Constance: the stage on the water with a huge prop (a giant eye), the
## steep stand of seats on the shore.
static func _seebuehne() -> void:
	_r(-25, 0, 25, 2, WATER)
	if _detail(1.0):
		_l(-23, 1, -12, 1, WATER_L, 0.2)
	_r(-17, 2, 9, 3.6, Color("6e6a64")) # the stage
	# the eye
	_poly(_arc(-4, 13, 11, 8, 0, TAU, 28), Color("f2efe6"))
	_c(-4, 13, 5.2, Color("2f7ac0"))
	_c(-4, 13, 3.6, Color("1d4f88"))
	_c(-4, 13, 2.4, Color("101418"))
	_c(-5.5, 14.6, 1.0, Color.WHITE)
	var lid := _arc(-4, 13, 11, 8, 0, PI, 28)
	for k in range(0, lid.size() - 2, 2):
		_l(lid[k], lid[k + 1], lid[k + 2], lid[k + 3], Color("5a3a2a"), 0.7)
	_l(-12, 3.6, -9, 7, Color("5a3a2a"), 0.6) # props holding it
	_l(4, 3.6, 1, 7, Color("5a3a2a"), 0.6)
	# the stand on the shore
	_r(12, 0, 25, 2, Color("b4ada0"))
	for k in 6:
		_r(12 + k * 2.1, 2, 25, 3.6 + k * 1.7, Color("8a8580").lightened(k * 0.04))
		if _detail(1.0):
			_r(12 + k * 2.1, 3.0 + k * 1.7, 25, 3.6 + k * 1.7, Color("3d5a78"))
