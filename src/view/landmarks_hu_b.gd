class_name LandmarksHuB
extends RefCounted
## Hungarian landmarks (Szombathely to Tokaj), drawn with LandmarkPainter's helpers (metres from the base point,
## y up).

const WHITE := Color("f2efe6")
const STONE := Color("ddd3bd")
const RED_ROOF := Color("b5432e")
const COPPER := Color("5f9e86")
const WATER := Color("4f86a8")
const WATER_L := Color("8fbcd8")
const GRASS := Color("6f9a48")
const TREE := Color("3f6f34")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const GOLD := Color("e0b43a")
const WOOD := Color("7a5636")
const THATCH := Color("b8955a")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"iseum_savariense": _iseum()
		"tiszavirag_bridge": _tiszavirag()
		"sopron_firewatch_tower": _firewatch()
		"kaposvar_csiky_theatre": _csiky_theatre()
		"csabai_kolbasz": _kolbasz()
		"veszprem_viaduct": _viaduct()
		"gocsej_skanzen": _skanzen()
		"eger_minaret": _minaret()
		"esztergom_basilica": _basilica()
		"siofok_water_tower": _water_tower()
		"tokaj_wine_cellar": _wine_cellar()
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

## A dome (half ellipse) on the line y from x - rx to x + rx.
static func _dome(x: float, y: float, rx: float, ry: float, col: Color) -> void:
	_poly([x - rx, y, x + rx, y] + _arc(x, y, rx, ry, 0, PI, 12), col)

## An onion helmet: a bulb swelling from the neck at y to a point at y + h.
static func _onion(x: float, y: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.3, y, x + w * 0.3, y, x + w * 0.5, y + h * 0.3, x + w * 0.42, y + h * 0.55, x + w * 0.12, y + h * 0.8,
		x, y + h, x - w * 0.12, y + h * 0.8, x - w * 0.42, y + h * 0.55, x - w * 0.5, y + h * 0.3], col)

## The Iseum of Savaria in Szombathely: the Roman temple of Isis rebuilt on its podium, steps up to four tall
## columns and a pediment with the goddess riding her dog, framed by the light steel of the modern hall.
static func _iseum() -> void:
	var m := Color("ebe3cf")
	var md := m.darkened(0.15)
	var steel := Color("8a949a")
	# the modern frame behind
	_l(-15, 0, -15, 18, steel, 0.25)
	_l(15, 0, 15, 18, steel, 0.25)
	_l(-15, 18, 15, 18, steel, 0.25)
	if _detail(0.9):
		for x in [-10.0, -5.0, 0.0, 5.0, 10.0]:
			_l(x, 15.5, x, 18, steel, 0.1)
	_r(-14.5, 0, 14.5, 9, Color("c9c2b0"))
	# the podium and its steps
	_r(-11, 0, 11, 4, md)
	for k in 6:
		_r(-4.5 + k * 0.2, k * 0.7, 4.5 - k * 0.2, k * 0.7 + 0.7, m.darkened(0.04 * (k % 2)))
	# the cella wall, the columns and the pediment
	_r(-8.6, 4, 8.6, 4.5, m)
	_r(-6.5, 4.5, 6.5, 12.6, Color("6a6258"))
	for x in [-7.0, -2.4, 2.4, 7.0]:
		_r(x - 0.7, 4.5, x + 0.7, 12.6, m)
		_r(x - 0.95, 12.6, x + 0.95, 13.2, md)
		if _detail(1.0):
			_l(x - 0.25, 4.6, x - 0.25, 12.5, md, 0.08)
			_l(x + 0.25, 4.6, x + 0.25, 12.5, md, 0.08)
	_r(-9, 13.2, 9, 14.4, m)
	_poly([-9.4, 14.4, 9.4, 14.4, 0, 18], m)
	_poly([-7.6, 14.8, 7.6, 14.8, 0, 17.4], md)
	# Isis on the dog Sothis
	_r(-0.9, 15.0, 0.9, 15.6, m)
	_c(0.9, 15.7, 0.3, m)
	_r(-0.2, 15.6, 0.25, 16.6, m)
	_c(0, 16.9, 0.25, m)

## The Tiszavirág Bridge in Szolnok: the white steel arch of the footbridge over the Tisza with its hangers and
## the mayflies dancing over the water on a June evening.
static func _tiszavirag() -> void:
	var w := Color("f0f0ea")
	var wd := w.darkened(0.2)
	_r(-45, 0, 45, 3, WATER)
	if _detail(0.7):
		_l(-30, 1.5, -18, 1.5, WATER_L, 0.2)
		_l(10, 1.0, 22, 1.0, WATER_L, 0.2)
	# the banks with trees
	_poly([-45, 0, -45, 7, -36, 7, -32, 0], GRASS)
	_poly([45, 0, 45, 7, 36, 7, 32, 0], GRASS)
	for x in [-43.0, -39.0, 39.0, 43.0]:
		_c(x, 9.5, 2.6, TREE)
	# the deck
	_r(-38, 6.2, 38, 7.0, wd)
	_l(-38, 8.0, 38, 8.0, wd, 0.12)
	# the arch, its hangers and the piers
	var pts := _arc(0, 6.6, 30, 14, 0, PI, 24)
	for k in range(0, pts.size() - 2, 2):
		_l(pts[k], pts[k + 1], pts[k + 2], pts[k + 3], w, 0.9)
		if k > 0 and k % 4 == 0:
			_l(pts[k], pts[k + 1], pts[k], 7.0, wd, 0.12)
	for x in [-30.0, 30.0]:
		_r(x - 1.0, 0, x + 1.0, 6.4, Color("c9c2b0"))
	# the mayflies
	if _detail(0.6):
		for k in 9:
			var x := -24.0 + k * 6.0 + (k % 2) * 1.7
			var y := 10.0 + (k * 7 % 5) * 1.2
			_l(x - 0.5, y, x + 0.5, y, Color("e8e0b0"), 0.12)
			_poly([x, y, x - 0.7, y + 0.6, x - 0.1, y + 0.15], Color(1, 1, 0.9, 0.85))
			_poly([x, y, x + 0.7, y + 0.6, x + 0.1, y + 0.15], Color(1, 1, 0.9, 0.85))

## Sopron's Firewatch Tower: the square Romanesque base with the Gate of Loyalty, the round Renaissance middle
## with its arcaded gallery and clock, the Baroque copper helmet, and the old houses of the main square beside it.
static func _firewatch() -> void:
	var st := Color("cfc4ad")
	var sd := st.darkened(0.15)
	var ren := Color("ece2c8")
	# the houses
	for sg in [-1.0, 1.0]:
		var x0: float = minf(sg * 5.0, sg * 12.0)
		var x1: float = maxf(sg * 5.0, sg * 12.0)
		var col := Color("e8c88a") if sg < 0.0 else Color("d9a8a0")
		_r(x0, 0, x1, 10, col)
		_poly([x0 - 0.3, 10, x1 + 0.3, 10, (x0 + x1) * 0.5, 13], RED_ROOF)
		_windows(x0 + 0.5, x1 - 0.5, 3.5, 5.5, 3, WIN)
		_windows(x0 + 0.5, x1 - 0.5, 6.8, 8.6, 3, WIN)
	# the square base with the gate
	_r(-4, 0, 4, 21, st)
	_r(-4, 0, -3.2, 21, sd)
	_arched(0, 0, 3.4, 5.6, DARK)
	_r(-2.8, 5.8, 2.8, 7.4, Color("a8783e"))
	if _detail(1.0):
		_c(0, 6.6, 0.5, GOLD)
	_arched(0, 13, 1.4, 3, WIN)
	_r(-4.3, 21, 4.3, 21.8, sd)
	# the round middle, the clock and the gallery
	_r(-3.4, 21.8, 3.4, 34, ren)
	_r(-3.4, 21.8, -2.6, 34, ren.darkened(0.12))
	_c(0, 30.5, 1.7, WHITE)
	_c(0, 30.5, 1.4, Color("2c4f80"))
	_l(0, 30.5, 0, 31.6, GOLD, 0.15)
	_l(0, 30.5, 0.8, 30.5, GOLD, 0.15)
	_arched(0, 25, 1.2, 2.6, WIN)
	_r(-4.4, 34, 4.4, 34.7, sd)
	_r(-3.6, 34.7, 3.6, 38.5, ren)
	for x in [-2.4, -0.8, 0.8, 2.4]:
		_arched(x, 35.0, 1.0, 2.8, DARK)
	_l(-4.4, 35.6, 4.4, 35.6, DARK, 0.12)
	_r(-3.8, 38.5, 3.8, 39.2, sd)
	# the Baroque helmet: a bulb, a lantern and a smaller bulb
	_onion(0, 39.2, 7.4, 8.0, COPPER)
	_r(-1.2, 46, 1.2, 49, COPPER.darkened(0.15))
	_onion(0, 49, 3.0, 5.0, COPPER)
	_l(0, 54, 0, 57.5, GOLD, 0.2)
	_c(0, 56, 0.4, GOLD)

## The Csiky Gergely Theatre in Kaposvár: the Art Nouveau front in warm yellow, the tall middle with its great
## arched window and curved gable, the wings under turquoise domes and the three arched doors.
static func _csiky_theatre() -> void:
	var y := Color("efd7a2")
	var yd := y.darkened(0.15)
	var wt := Color("f6eedc")
	var tq := Color("4f9a8a")
	_r(-19, 0, 19, 0.8, Color("b9b4a8"))
	# the wings
	for sg in [-1.0, 1.0]:
		var x0: float = minf(sg * 8.0, sg * 17.5)
		var x1: float = maxf(sg * 8.0, sg * 17.5)
		_r(x0, 0.8, x1, 14, y)
		_r(x0, 13.4, x1, 14, wt)
		_windows(x0 + 0.5, x1 - 0.5, 3, 6, 3, WIN)
		_windows(x0 + 0.5, x1 - 0.5, 8.5, 11.5, 3, WIN)
		var cx: float = sg * 14.5
		_r(cx - 2.2, 14, cx + 2.2, 15.8, y)
		_dome(cx, 15.8, 2.4, 2.6, tq)
		_l(cx, 18.4, cx, 19.6, GOLD, 0.15)
	# the middle
	_r(-8, 0.8, 8, 19, y)
	_r(-8, 0.8, -7.3, 19, yd)
	_poly([-8, 19, 8, 19, 8, 19.5] + _arc(0, 19.5, 8, 4.5, 0, PI, 14) + [-8, 19.5], y)
	var g := _arc(0, 19.5, 8, 4.5, 0, PI, 14)
	for k in range(0, g.size() - 2, 2):
		_l(g[k], g[k + 1], g[k + 2], g[k + 3], wt, 0.35)
	_c(0, 21.5, 1.0, GOLD)
	_arched(0, 9, 7, 9, wt)
	_arched(0, 9.3, 6.2, 8.4, Color("5a6a78"))
	if _detail(1.0):
		_l(0, 9.3, 0, 17.5, wt, 0.15)
		_l(-3.1, 13, 3.1, 13, wt, 0.15)
	for x in [-4.4, 0.0, 4.4]:
		_arched(x, 0.8, 2.6, 5.4, WOOD)
	if _detail(1.0):
		for x in [-6.8, 6.8]:
			_r(x - 0.3, 0.8, x + 0.3, 18, GOLD.darkened(0.1))

## Csaba sausage hanging to smoke: a wooden rack with red paprika sausages looped over its bar and a string of
## dried red peppers beside it.
static func _kolbasz() -> void:
	var w := WOOD
	_r(-5, 0, 5, 0.3, Color("8a7a60"))
	_r(-4.3, 0, -3.9, 5.2, w)
	_r(3.9, 0, 4.3, 5.2, w)
	_r(-4.6, 4.9, 4.6, 5.3, w.darkened(0.15))
	var red := Color("a8322a")
	for k in 7:
		var x := -3.2 + k * 1.07
		var drop := 2.0 + (k % 3) * 0.35
		var col := red if k % 2 == 0 else red.darkened(0.15)
		_l(x - 0.22, 4.9, x - 0.22, 4.9 - drop, col, 0.32)
		_l(x + 0.22, 4.9, x + 0.22, 4.9 - drop, col, 0.32)
		_c(x, 4.9 - drop, 0.38, col)
		if _detail(4.0):
			_l(x, 5.3, x, 4.9, Color("e8e0c8"), 0.05)
	# the string of dried peppers
	_l(4.7, 5.2, 4.7, 1.2, Color("c8b88a"), 0.06)
	for k in 7:
		var y := 4.8 - k * 0.55
		_poly([4.5, y, 4.95, y, 4.72, y - 0.6], Color("c8241a") if k % 2 == 0 else Color("b01e14"))

## The St Stephen Viaduct in Veszprém: the slender concrete arch over the Séd valley with its row of posts under
## the deck, and the castle hill of the town of queens behind, with the Fire Tower and the cathedral's towers.
static func _viaduct() -> void:
	var c := Color("d8d4c8")
	var cd := c.darkened(0.18)
	# the castle hill behind
	_poly([-35, 0, -35, 22, -28, 24, -14, 23, -8, 18, -10, 0], Color("9a958a"))
	_poly([-35, 22, -28, 24, -14, 23, -13, 21, -35, 20], TREE)
	_r(-31, 23, -21, 27, Color("ece4d0"))
	_poly([-31.4, 27, -20.6, 27, -22, 28.5, -30, 28.5], RED_ROOF)
	for x in [-19.5, -16.5]:
		_r(x - 1, 23, x + 1, 32.5, Color("ece4d0"))
		_poly([x - 1.3, 32.5, x + 1.3, 32.5, x, 34.5], Color("5a6068"))
	_r(-28.5, 27, -26, 30, Color("cfc4ad"))
	_poly([-28.8, 30, -25.7, 30, -27.25, 32.5], COPPER)
	# the valley sides
	_poly([10, 0, 22, 14, 35, 18, 35, 0], GRASS)
	_poly([-10, 0, -8, 18, -20, 19, -20, 0], GRASS.darkened(0.05))
	_r(-10, 0, 10, 0.8, Color("7f9a58"))
	# the arch and the posts
	var pts := _arc(0, 2, 18, 15.5, 0, PI, 20)
	for k in range(0, pts.size() - 2, 2):
		_l(pts[k], pts[k + 1], pts[k + 2], pts[k + 3], c, 1.2)
	for k in 11:
		var x := -15.0 + k * 3.0
		var ya := 2.0 + 15.5 * sqrt(maxf(0.0, 1.0 - x * x / 324.0))
		_l(x, ya, x, 19.6, cd, 0.35)
	for x in [-24.0, 24.0]:
		_r(x - 0.6, 14, x + 0.6, 19.6, cd)
	_r(-35, 19.6, 35, 20.6, c)
	_l(-35, 21.4, 35, 21.4, cd, 0.1)

## Göcsej Village Museum in Zalaegerszeg: whitewashed cottages under tall thatched roofs, a wattle fence and the
## water mill turning on the Zala.
static func _skanzen() -> void:
	var w := Color("f2eee2")
	_r(-16, 0, 16, 0.4, Color("8fae5a"))
	# the mill stream
	_r(10, 0, 16, 0.9, WATER)
	# two cottages
	for x0 in [-15.0, -6.5]:
		_r(x0, 0.4, x0 + 7, 3.6, w)
		_r(x0, 0.4, x0 + 7, 0.9, Color("8a7a60"))
		_r(x0 + 1.2, 1.6, x0 + 2.2, 2.6, Color("4a6a8a"))
		_r(x0 + 4.4, 1.6, x0 + 5.4, 2.6, Color("4a6a8a"))
		_poly([x0 - 0.6, 3.6, x0 + 7.6, 3.6, x0 + 5.6, 7.6, x0 + 1.4, 7.6], THATCH)
		if _detail(2.0):
			for k in 6:
				var yy := 4.2 + k * 0.6
				_l(x0 - 0.3 + k * 0.33, yy, x0 + 7.3 - k * 0.33, yy, THATCH.darkened(0.12), 0.06)
	# the wattle fence
	for k in 10:
		_l(-15.5 + k * 0.9, 0.4, -15.5 + k * 0.9, 1.5, WOOD, 0.1)
	_l(-15.5, 1.1, -7.4, 1.1, WOOD.darkened(0.2), 0.15)
	# the water mill
	_r(2, 0.4, 9.5, 5, WOOD)
	if _detail(1.5):
		for k in 6:
			_l(2.6 + k * 1.3, 0.4, 2.6 + k * 1.3, 5, WOOD.darkened(0.2), 0.06)
	_r(5, 0.4, 6.4, 2.6, WOOD.darkened(0.4))
	_poly([1.4, 5, 10.1, 5, 7.8, 8.6, 3.7, 8.6], THATCH.darkened(0.1))
	_c(12.4, 2.6, 2.4, WOOD.darkened(0.15))
	_c(12.4, 2.6, 1.9, WATER.lightened(0.25))
	for k in 8:
		var a := k * PI / 4.0
		_l(12.4, 2.6, 12.4 + cos(a) * 2.4, 2.6 + sin(a) * 2.4, WOOD.darkened(0.3), 0.2)
	_r(10, 0, 16, 0.6, WATER)

## The minaret of Eger: the slender fourteen-sided Ottoman tower of reddish stone on its plinth, the balcony ring,
## the pointed cap and the crescent, with the castle's wall beside it.
static func _minaret() -> void:
	var s := Color("c9a27e")
	var sd := s.darkened(0.18)
	# the castle wall
	_r(-7, 0, -3.2, 6, Color("bfb39a"))
	for k in 3:
		_r(-7 + k * 1.3, 6, -7 + k * 1.3 + 0.7, 6.8, Color("bfb39a"))
	_r(3.2, 0, 7, 4.5, Color("e8dcc0"))
	_poly([3.0, 4.5, 7.2, 4.5, 5.1, 6.2], RED_ROOF)
	# the plinth and the shaft
	_r(-2.6, 0, 2.6, 4, sd)
	_poly([-1.7, 4, 1.7, 4, 1.4, 35.5, -1.4, 35.5], s)
	_poly([-1.7, 4, -1.0, 4, -0.8, 35.5, -1.4, 35.5], sd)
	if _detail(1.5):
		for k in 4:
			var x := -0.5 + k * 0.45
			_l(x, 4.2, x * 0.85, 35, sd, 0.05)
	# the balcony
	_poly([-1.55, 25, 1.55, 25, 2.6, 26.6, -2.6, 26.6], sd)
	_r(-2.6, 26.6, 2.6, 27.6, s.lightened(0.1))
	if _detail(1.5):
		for k in 6:
			_l(-2.3 + k * 0.92, 26.7, -2.3 + k * 0.92, 27.5, sd, 0.06)
	_r(-1.7, 35.5, 1.7, 36.2, sd)
	# the cap and the crescent
	_poly([-1.7, 36.2, 1.7, 36.2, 0, 41.2], Color("5c6a6e"))
	_l(0, 41.2, 0, 41.7, GOLD, 0.12)
	_poly(_arc(0, 42.0, 0.55, 0.55, PI * 1.15, PI * 1.85, 6) + _arc(0, 42.25, 0.45, 0.38, PI * 1.8, PI * 1.2, 6), GOLD)

## Esztergom Basilica on its hill above the Danube: the great green dome on its colonnaded drum, the columned
## portico and the two bell towers at the front corners.
static func _basilica() -> void:
	var w := Color("ece5d2")
	var wd := w.darkened(0.15)
	var g := Color("4f8f78")
	_r(-38, 0, 38, 3, WATER)
	if _detail(0.5):
		_l(-30, 1.5, -16, 1.5, WATER_L, 0.2)
		_l(12, 1.2, 26, 1.2, WATER_L, 0.2)
	_poly([-38, 3, -38, 18, -30, 24, 30, 24, 36, 16, 38, 3], Color("7f9a58"))
	for k in 6:
		_c(-34.0 + k * 3.4, 15.5 - absf(k - 1.5) * 2.4, 2.4, TREE)
	for k in 4:
		_c(24.0 + k * 3.2, 14.0 - k * 2.6, 2.2, TREE)
	_r(-24, 24, 24, 26, Color("bfb39a"))
	# the body
	_r(-22, 26, 22, 42, w)
	_windows(-21, 21, 33, 37, 9, WIN)
	_r(-22.4, 42, 22.4, 43, wd)
	# the bell towers
	for sg in [-1.0, 1.0]:
		var x: float = sg * 16.5
		_r(x - 2.8, 26, x + 2.8, 51, w)
		_r(x - 2.8, 26, x - 2.1, 51, wd)
		_arched(x, 44, 1.6, 4, WIN)
		_r(x - 3.1, 51, x + 3.1, 51.8, wd)
		_dome(x, 51.8, 2.4, 3.0, g)
		_l(x, 54.8, x, 56.6, GOLD, 0.2)
	# the drum and the dome
	_r(-9.5, 43, 9.5, 55, w)
	for k in 9:
		var x := -8.6 + k * 2.15
		_r(x - 0.4, 44, x + 0.4, 54, wd)
	_r(-10.2, 55, 10.2, 56, wd)
	_dome(0, 56, 10, 10.5, g)
	_poly(_arc(0, 56, 10, 10.5, PI * 0.55, PI, 8) + [-6.5, 56], g.lightened(0.12))
	_r(-1.5, 66, 1.5, 70, w)
	_dome(0, 70, 1.7, 1.5, g)
	_l(0, 71.5, 0, 73.8, GOLD, 0.25)
	_l(-0.8, 73, 0.8, 73, GOLD, 0.2)
	# the portico
	_r(-10, 26, 10, 27, wd)
	for k in 8:
		var x := -8.75 + k * 2.5
		_r(x - 0.55, 27, x + 0.55, 38, w)
	_r(-10.2, 38, 10.2, 39.4, w)
	_poly([-10.6, 39.4, 10.6, 39.4, 0, 43.6], w)
	_poly([-8.6, 39.9, 8.6, 39.9, 0, 43.0], wd)

## Siófok's Water Tower in the main square: the slender white column with its ribs, the wider lookout with its
## windows and balcony, and the green cap with its spire, among the trees of the park.
static func _water_tower() -> void:
	var w := Color("ece6d8")
	var wd := w.darkened(0.15)
	for x in [-6.0, 6.0]:
		_c(x, 4.5, 2.6, TREE)
		_r(x - 0.25, 0, x + 0.25, 2.5, WOOD)
	_r(-3.6, 0, 3.6, 2, wd)
	_poly([-2.6, 2, 2.6, 2, 2.0, 32, -2.0, 32], w)
	_poly([-2.6, 2, -1.8, 2, -1.4, 32, -2.0, 32], wd)
	if _detail(1.2):
		for x in [-0.6, 0.6]:
			_l(x, 2.2, x * 0.8, 31.8, wd, 0.1)
	_arched(0, 2, 1.6, 3, WOOD)
	for y in [10.0, 18.0, 25.0]:
		_arched(0, y, 0.8, 1.8, WIN)
	# the lookout
	_poly([-2.0, 32, 2.0, 32, 3.6, 34, -3.6, 34], wd)
	_r(-3.6, 34, 3.6, 38.5, w)
	_windows(-3.4, 3.4, 35, 37.6, 4, Color("5a7a98"))
	_r(-4.2, 38.5, 4.2, 39.2, wd)
	if _detail(1.2):
		for k in 8:
			_l(-4 + k * 1.14, 38.5, -4 + k * 1.14, 37.6, wd, 0.06)
	_dome(0, 39.2, 3.6, 3.4, COPPER)
	_l(0, 42.6, 0, 45.6, GOLD, 0.2)

## Wine barrel lying on its side, seen end on: centre x, y, radius r.
static func _barrel(x: float, y: float, r: float) -> void:
	_c(x, y, r, Color("8a5a32"))
	_c(x, y, r * 0.8, Color("a8743e"))
	_c(x, y, r * 0.18, Color("5a3a20"))
	if _detail(2.0):
		_l(x - r * 0.8, y, x + r * 0.8, y, Color("8a5a32"), 0.06)

## The Rákóczi Cellar in Tokaj: the stone doorway into the hill, barrels of Tokaji at its mouth, and the Kopasz
## hill above, striped with rows of vines, its TV mast on the top.
static func _wine_cellar() -> void:
	# the hill with its vineyards
	_poly([-16, 0, -16, 9, -8, 13, 0, 16, 8, 14, 16, 9, 16, 0], Color("7f9a58"))
	if _detail(0.9):
		for k in 7:
			var y := 6.0 + k * 1.3
			var hw := 15.0 - k * 1.6
			_l(-hw, y, hw - 2.0, y + 0.4, Color("4f7f3a"), 0.18)
	_l(1, 16, 1, 21.5, Color("c8c4bc"), 0.18)
	_l(1, 21.5, 1, 22.5, Color("c8241a"), 0.18)
	# the cellar front
	var st := Color("cfc4ad")
	_r(-12, 0, 2, 6.2, st)
	_poly([-12.4, 6.2, 2.4, 6.2, 1.6, 7.0, -11.6, 7.0], st.darkened(0.15))
	_poly([-7.9, 0, -2.1, 0, -2.1, 3.2] + _arc(-5, 3.2, 2.9, 2.9, 0, PI, 10), st.darkened(0.25))
	_poly([-7.4, 0, -2.6, 0, -2.6, 3.2] + _arc(-5, 3.2, 2.4, 2.4, 0, PI, 10), Color("2a221c"))
	_r(-11, 3.5, -9, 5, Color("5a6a78"))
	_r(-1, 3.5, 1, 5, Color("5a6a78"))
	# the barrels and a bunch of grapes
	_barrel(5.2, 1.3, 1.3)
	_barrel(8.0, 1.3, 1.3)
	_barrel(10.8, 1.3, 1.3)
	_barrel(6.6, 3.7, 1.3)
	_barrel(9.4, 3.7, 1.3)
	var gr := Color("d8c25a")
	for k in 6:
		_c(13.6 + (k % 2) * 0.45 - (1 if k > 3 else 0) * 0.2, 2.8 - (k / 2) * 0.45, 0.3, gr if k % 2 else gr.darkened(0.1))
	_l(13.8, 3.1, 14.2, 3.6, Color("4f7f3a"), 0.1)
