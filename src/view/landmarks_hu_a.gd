class_name LandmarksHuA
extends RefCounted
## Hungarian landmarks (Budapest to Székesfehérvár), drawn with LandmarkPainter's helpers (metres from the base
## point, y up).

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

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"hungarian_parliament": _parliament()
		"szechenyi_chain_bridge": _chain_bridge()
		"debrecen_great_church": _great_church()
		"hortobagy_bridge": _hortobagy()
		"szeged_votive_church": _votive_church()
		"diosgyor_castle": _diosgyor()
		"pecs_qasim_mosque": _qasim_mosque()
		"gyor_town_hall": _gyor_town_hall()
		"nyiregyhaza_zoo": _zoo()
		"kecskemet_cifrapalota": _cifrapalota()
		"bory_castle": _bory()
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

## A pinnacle: a thin spike from y0 to y1.
static func _spike(x: float, y0: float, y1: float, w: float, col: Color) -> void:
	_poly([x - w * 0.5, y0, x + w * 0.5, y0, x, y1], col)

## The Hungarian Parliament on the Danube: the long Neo-Gothic front with its rows of pointed windows and
## pinnacles, the red roofs, the end pavilions, the two slender towers and the ribbed dome in the middle.
static func _parliament() -> void:
	var w := Color("ede5d0")
	var wd := w.darkened(0.16)
	var roof := Color("b0473a")
	# the river and the embankment
	_r(-60, 0, 60, 2, WATER)
	if _detail(0.6):
		_l(-50, 1, -30, 1, WATER_L, 0.2)
		_l(20, 0.8, 44, 0.8, WATER_L, 0.2)
	_r(-60, 2, 60, 4, Color("b9b2a0"))
	# the long wings
	_r(-56, 4, 56, 19, w)
	_poly([-56.5, 19, 56.5, 19, 54, 24, -54, 24], roof)
	if _detail(0.7):
		for k in 29:
			var x := -53.0 + k * 3.8
			if absf(x) < 15.0: continue
			_pointed(x, 6.5, 1.3, 4.0, WIN)
			_pointed(x, 12.5, 1.3, 4.0, WIN)
			_spike(x + 1.9, 19, 26.5, 0.8, wd)
	else:
		_windows(-54, -16, 7, 10, 10, WIN)
		_windows(16, 54, 7, 10, 10, WIN)
	# the end pavilions with steep roofs and corner turrets
	for sg in [-1.0, 1.0]:
		var x0: float = minf(sg * 40.0, sg * 50.0)
		var x1: float = maxf(sg * 40.0, sg * 50.0)
		_r(x0, 4, x1, 24, w)
		_poly([x0 - 0.5, 24, x1 + 0.5, 24, (x0 + x1) * 0.5, 31], roof)
		for x in [x0, x1]:
			_r(x - 0.8, 4, x + 0.8, 27, wd)
			_spike(x, 27, 31, 1.6, wd)
		_windows(x0 + 1, x1 - 1, 15, 19, 4, WIN)
	# the middle block and the two towers in front of the dome
	_r(-15, 4, 15, 27, w)
	_poly([-15.5, 27, 15.5, 27, 13, 30, -13, 30], roof)
	_arched(0, 4, 5, 7, WIN)
	for x in [-10.0, -5.5, 5.5, 10.0]:
		_pointed(x, 9, 2, 6, WIN)
		_pointed(x, 18, 2, 6, WIN)
	for sg in [-1.0, 1.0]:
		var x: float = sg * 17.0
		_r(x - 1.6, 4, x + 1.6, 36, w)
		_r(x - 1.6, 4, x - 0.9, 36, wd)
		_spike(x, 36, 44, 3.2, roof)
		_spike(x - 1.6, 36, 39, 0.8, wd)
		_spike(x + 1.6, 36, 39, 0.8, wd)
	# the drum and the ribbed dome with its lantern and spire
	_r(-9, 30, 9, 35, w)
	if _detail(0.8):
		for k in 6:
			_pointed(-7.5 + k * 3.0, 31, 1.2, 3.2, WIN)
	_poly([-9.5, 35, 9.5, 35] + _arc(0, 35, 9.5, 11, 0, PI, 14), roof)
	if _detail(0.8):
		for x in [-6.0, -2.0, 2.0, 6.0]:
			var top := 35.0 + 11.0 * sqrt(maxf(0.0, 1.0 - x * x / 90.0))
			_l(x, 35, x * 0.35, top - 0.4, wd, 0.35)
	_r(-1.4, 45.5, 1.4, 48, w)
	_spike(0, 48, 52, 2.4, roof)

## The Széchenyi Chain Bridge: two stone towers like triumphal arches standing in the Danube, the iron chains
## hanging between them and out to the banks, the deck, and a stone lion at each end.
static func _chain_bridge() -> void:
	var st := Color("d9cfb8")
	var sd := st.darkened(0.2)
	var iron := Color("4a4f4a")
	_r(-40, 0, 40, 3, WATER)
	if _detail(0.8):
		_l(-36, 1.5, -26, 1.5, WATER_L, 0.2)
		_l(4, 1.2, 12, 1.2, WATER_L, 0.2)
	# the banks
	_r(-40, 0, -34, 7, sd)
	_r(34, 0, 40, 7, sd)
	# the deck
	_r(-40, 6.3, 40, 7.3, iron)
	_l(-40, 8.2, 40, 8.2, iron, 0.15)
	# the chains and the hangers
	var pts := []
	for k in 25:
		var x := -14.5 + k * 29.0 / 24.0
		pts.append(Vector2(x, 8.4 + 10.6 * pow(x / 18.0, 2)))
	for sg in [-1.0, 1.0]:
		for k in 13:
			var u := k / 12.0
			var x: float = sg * (21.5 + u * 18.0)
			pts.append(Vector2(x, 7.6 + 11.4 * pow(1.0 - u, 2)))
	var mid := pts.slice(0, 25)
	for k in range(1, mid.size()):
		_l(mid[k - 1].x, mid[k - 1].y, mid[k].x, mid[k].y, iron, 0.45)
		if _detail(1.0) and k % 2 == 0:
			_l(mid[k].x, mid[k].y, mid[k].x, 7.3, iron, 0.08)
	for s in 2:
		var side := pts.slice(25 + s * 13, 38 + s * 13)
		for k in range(1, side.size()):
			_l(side[k - 1].x, side[k - 1].y, side[k].x, side[k].y, iron, 0.45)
			if _detail(1.0) and k % 2 == 0:
				_l(side[k].x, side[k].y, side[k].x, 7.3, iron, 0.08)
	# the two towers
	for sg in [-1.0, 1.0]:
		var x: float = sg * 18.0
		_r(x - 4.5, 0, x + 4.5, 3, sd)
		_r(x - 3.5, 3, x + 3.5, 19, st)
		_r(x - 3.5, 3, x - 2.8, 19, sd)
		_poly([x - 1.6, 7.3, x + 1.6, 7.3, x + 1.6, 13] + _arc(x, 13, 1.6, 1.6, 0, PI, 6), Color("7f9bb0"))
		_r(x - 4, 19, x + 4, 20.2, sd)
		_r(x - 3.5, 20.2, x + 3.5, 21.5, st)
		if _detail(1.0):
			_r(x - 3.0, 16, x + 3.0, 16.4, sd)
	# the lions on their plinths
	for sg in [-1.0, 1.0]:
		var x: float = sg * 37.0
		_r(x - 1.5, 7.3, x + 1.5, 8.6, st)
		_poly([x - 1.2 * sg, 8.6, x + 1.2 * sg, 8.6, x + 1.2 * sg, 9.4, x + 0.6 * sg, 10.4, x - 0.4 * sg, 9.6, x - 1.2 * sg, 9.4], sd)
		_c(x - 0.9 * sg, 10.0, 0.6, sd)

## Debrecen's Reformed Great Church: the yellow Classicist front with its columned portico and pediment
## between the two square towers with their copper caps and clocks.
static func _great_church() -> void:
	var y := Color("e8c25a")
	var yd := y.darkened(0.15)
	var wt := Color("f2ead2")
	_r(-20, 0, 20, 0.8, Color("b9b4a8"))
	# the body behind the portico
	_r(-12, 0.8, 12, 22, y)
	_poly([-12.5, 22, 12.5, 22, 0, 26], Color("8a5a3a"))
	_windows(-11, 11, 15, 19, 5, WIN)
	# the portico
	_r(-8.5, 0.8, 8.5, 1.8, wt)
	for x in [-7.0, -2.4, 2.4, 7.0]:
		_r(x - 0.7, 1.8, x + 0.7, 12, wt)
	if _detail(1.0):
		_arched(-4.7, 1.8, 1.8, 5, WIN)
		_arched(4.7, 1.8, 1.8, 5, WIN)
		_arched(0, 1.8, 2.4, 6.5, WOOD)
	_r(-8.8, 12, 8.8, 13.6, wt)
	_poly([-9.2, 13.6, 9.2, 13.6, 0, 18], wt)
	_poly([-7.4, 14.1, 7.4, 14.1, 0, 17.3], y)
	# the towers
	for sg in [-1.0, 1.0]:
		var x0: float = minf(sg * 12.0, sg * 19.0)
		var x1: float = maxf(sg * 12.0, sg * 19.0)
		var cx := (x0 + x1) * 0.5
		_r(x0, 0.8, x1, 30, y)
		_r(x0, 0.8, x0 + 0.8, 30, yd)
		for yy in [10.0, 17.0]:
			_arched(cx, yy, 1.6, 3.4, WIN)
		_c(cx, 25, 1.8, wt)
		_c(cx, 25, 1.4, Color("2c4f80"))
		_l(cx, 25, cx, 26.1, GOLD, 0.15)
		_l(cx, 25, cx + 0.8, 25, GOLD, 0.15)
		_r(x0 - 0.3, 30, x1 + 0.3, 31, wt)
		_r(x0 + 1, 31, x1 - 1, 33.5, y)
		_poly([x0 + 0.6, 33.5, x1 - 0.6, 33.5] + _arc(cx, 33.5, 2.9, 3.2, 0, PI, 10), COPPER)
		_l(cx, 36.7, cx, 39.5, GOLD, 0.2)

## The Nine-Hole Bridge of Hortobágy: the long white stone bridge on nine arches over the little river, a sweep
## well with its long pole beside it and a grey cattle with lyre-shaped horns on the puszta.
static func _hortobagy() -> void:
	var st := Color("ebe5d6")
	var sd := st.darkened(0.15)
	_r(-35, 0, 35, 1.0, Color("8fa86a"))
	_r(-34, 0, 20, 1.2, WATER)
	# the bridge on its nine arches
	_poly([-35, 1.2, -34, 4.6, 20, 4.6, 21, 1.2], st)
	for k in 9:
		var x := -31.0 + k * 6.0
		_poly([x + 2.2, 0.6, x + 2.2, 1.6] + _arc(x, 1.6, 2.2, 1.9, 0, PI, 8) + [x - 2.2, 0.6], Color("5f7f80"))
	_r(-34.5, 4.6, 20.5, 5.0, sd)
	_r(-34.5, 5.0, 20.5, 5.9, st)
	if _detail(1.0):
		for k in 18:
			var x := -33.0 + k * 3.0
			_r(x, 5.0, x + 0.25, 5.9, sd)
	# the sweep well
	_r(23, 0, 26, 1.3, WOOD.darkened(0.15))
	_l(30, 0, 30, 8.0, WOOD, 0.35)
	_l(29.4, 8.2, 30, 7.4, WOOD, 0.2)
	_l(30.6, 8.2, 30, 7.4, WOOD, 0.2)
	_l(23.6, 12.5, 35, 4.6, WOOD, 0.25)
	_l(24, 12.2, 24, 1.8, DARK, 0.08)
	_r(23.6, 1.3, 24.4, 2.0, WOOD)
	_r(33.8, 4.2, 35.3, 5.4, Color("8a8478"))
	# a grey cattle
	var g := Color("c9c4b8")
	_r(-3, 0.9, -2.6, 2.0, g.darkened(0.25))
	_r(-0.6, 0.9, -0.2, 2.0, g.darkened(0.25))
	_poly([-3.4, 1.8, 0.4, 1.8, 0.6, 3.1, -3.2, 3.0], g)
	_c(1.0, 2.9, 0.55, g)
	_l(0.8, 3.3, 0.3, 4.2, Color("f2ead2"), 0.12)
	_l(1.2, 3.3, 1.8, 4.2, Color("f2ead2"), 0.12)
	_l(-3.4, 2.8, -3.7, 1.8, g.darkened(0.2), 0.08)

## The Votive Church of Szeged: red brick with white stone trim, the two tall towers with their spires, the rose
## window over the portal and the dome over the crossing behind.
static func _votive_church() -> void:
	var b := Color("b04a35")
	var bd := b.darkened(0.18)
	var wt := Color("efe6d2")
	_r(-18, 0, 18, 1, Color("b9b4a8"))
	# the dome behind
	_r(-4, 30, 4, 37, b)
	_poly([-4.5, 37, 4.5, 37] + _arc(0, 37, 4.5, 4.5, 0, PI, 10), Color("5c6e6a"))
	_l(0, 41.5, 0, 44, GOLD, 0.2)
	# the front between the towers
	_r(-8, 1, 8, 30, b)
	_poly([-8.5, 30, 8.5, 30, 0, 36.5], b)
	_l(-8.5, 30, 0, 36.5, wt, 0.3)
	_l(8.5, 30, 0, 36.5, wt, 0.3)
	_pointed(0, 1, 5, 9, wt)
	_pointed(0, 1, 3.8, 8, WOOD)
	_c(0, 18, 4, wt)
	_c(0, 18, 3.2, Color("4a5a78"))
	if _detail(1.0):
		for k in 8:
			var a := k * PI / 4.0
			_l(0, 18, cos(a) * 3.2, 18 + sin(a) * 3.2, wt, 0.15)
	_r(-8, 24, 8, 24.6, wt)
	for x in [-5.0, -2.5, 0.0, 2.5, 5.0]:
		_pointed(x, 25.2, 1.2, 3.6, WIN)
	# the towers
	for sg in [-1.0, 1.0]:
		var x0: float = minf(sg * 8.0, sg * 16.0)
		var x1: float = maxf(sg * 8.0, sg * 16.0)
		var cx := (x0 + x1) * 0.5
		_r(x0, 1, x1, 45, b)
		_r(x0, 1, x0 + 0.9, 45, bd)
		for yy in [12.0, 24.0, 34.0]:
			_r(x0, yy, x1, yy + 0.5, wt)
		_pointed(cx, 5, 2.4, 5, WIN)
		_pointed(cx, 15, 2.0, 6, WIN)
		_pointed(cx - 1.4, 37, 1.2, 5, DARK)
		_pointed(cx + 1.4, 37, 1.2, 5, DARK)
		_c(cx, 29, 1.6, wt)
		_c(cx, 29, 1.25, Color("2c4f80"))
		_r(x0 - 0.3, 45, x1 + 0.3, 46, wt)
		_spike(cx, 46, 61, 7.4, Color("5c6e6a"))
		_spike(x0 + 0.3, 46, 49.5, 1.0, wt)
		_spike(x1 - 0.3, 46, 49.5, 1.0, wt)
		_l(cx, 61, cx, 62.5, GOLD, 0.2)

## Diósgyőr Castle: the square Gothic royal castle of pale stone with four corner towers (two in front, two
## peeping from behind), crenellated walls, the gate on its wooden bridge and one tower's restored timber gallery.
static func _diosgyor() -> void:
	var st := Color("d6ccb4")
	var sd := st.darkened(0.16)
	_poly([-26, 0, 26, 0, 24, 3, -24, 3], Color("7f9a58"))
	# the back towers
	for sg in [-1.0, 1.0]:
		var x0: float = minf(sg * 6.0, sg * 12.0)
		_r(x0, 3, x0 + 6, 22, sd)
		for k in 3:
			_r(x0 + k * 2.2, 22, x0 + k * 2.2 + 1.3, 23.2, sd)
	# the walls
	_r(-18, 3, 18, 17, st)
	for k in 13:
		var x := -17.5 + k * 2.8
		_r(x, 17, x + 1.5, 18.4, st)
	_windows(-14, 14, 11, 13.5, 6, WIN)
	_poly([-2.5, 3, 2.5, 3, 2.5, 7] + _arc(0, 7, 2.5, 2.5, 0, PI, 8), DARK)
	_poly([-2.5, 2, 2.5, 2, 2.0, 3, -2.0, 3], WOOD)
	# the front towers
	for sg in [-1.0, 1.0]:
		var x0: float = minf(sg * 17.0, sg * 25.0)
		var x1: float = maxf(sg * 17.0, sg * 25.0)
		var cx := (x0 + x1) * 0.5
		_r(x0, 3, x1, 24, st)
		_r(x0, 3, x0 + 1, 24, sd)
		_arched(cx, 9, 1.4, 2.6, WIN)
		_arched(cx, 16, 1.4, 2.6, WIN)
		if sg > 0.0:
			# the restored timber gallery and its roof
			_r(x0 - 0.4, 24, x1 + 0.4, 26.5, WOOD)
			if _detail(1.0):
				for k in 5:
					_r(x0 + 0.6 + k * 1.6, 24.6, x0 + 1.3 + k * 1.6, 26, WOOD.darkened(0.35))
			_poly([x0 - 1, 26.5, x1 + 1, 26.5, cx, 30.5], RED_ROOF.darkened(0.15))
		else:
			for k in 4:
				_r(x0 + k * 2.2, 24, x0 + k * 2.2 + 1.3, 25.5, st)

## The Mosque of Pasha Qasim in Pécs: the square stone hall, the octagonal drum and the great green dome topped
## by a cross over the Ottoman crescent, with arched windows in two rows.
static func _qasim_mosque() -> void:
	var st := Color("e8dcc0")
	var sd := st.darkened(0.15)
	_r(-16, 0, 16, 0.8, Color("b9b4a8"))
	for x in [-14.0, 14.0]:
		_c(x, 3.4, 2.2, TREE)
		_r(x - 0.25, 0.8, x + 0.25, 1.6, WOOD)
	_r(-10, 0.8, 10, 12.5, st)
	_r(-10, 0.8, -9.2, 12.5, sd)
	for x in [-6.0, 0.0, 6.0]:
		_arched(x, 2.5, 2.0, 3.6, WIN)
		_arched(x, 7.4, 1.6, 3.0, WIN)
	_r(-10.4, 12.5, 10.4, 13.2, sd)
	# the drum and the dome
	_r(-8.5, 13.2, 8.5, 15.6, st)
	if _detail(1.0):
		for x in [-6.0, -3.0, 0.0, 3.0, 6.0]:
			_c(x, 14.4, 0.5, WIN)
	var g := Color("4f8f6a")
	_poly([-9, 15.6, 9, 15.6] + _arc(0, 15.6, 9, 7.8, 0, PI, 16), g)
	_poly(_arc(0, 15.6, 9, 7.8, PI * 0.55, PI, 8) + [-6, 15.6], g.lightened(0.12))
	# the crescent and the cross
	_l(0, 23.4, 0, 24.6, GOLD, 0.2)
	_poly(_arc(0, 25.4, 0.9, 0.9, PI * 1.1, PI * 1.9, 6) + _arc(0, 25.7, 0.75, 0.6, PI * 1.85, PI * 1.15, 6), GOLD)
	_l(0, 25.3, 0, 27.6, GOLD, 0.18)
	_l(-0.6, 26.9, 0.6, 26.9, GOLD, 0.18)

## Győr's Town Hall: the grand Neo-Baroque salmon-pink front with white trim, the corner pavilions under small
## domes and the tall clock tower in the middle with its stacked domes.
static func _gyor_town_hall() -> void:
	var p := Color("e3b08c")
	var pd := p.darkened(0.15)
	var wt := Color("f2ead8")
	var slate := Color("5a6068")
	_r(-23, 0, 23, 0.8, Color("b9b4a8"))
	_r(-20, 0.8, 20, 16, p)
	_r(-20, 6, 20, 6.5, wt)
	_r(-20.4, 15.4, 20.4, 16.2, wt)
	_windows(-19, 19, 2.2, 4.8, 10, WIN)
	_windows(-19, 19, 8.2, 12.6, 10, WIN)
	_poly([-20, 16.2, 20, 16.2, 18.5, 19, -18.5, 19], slate)
	# the corner pavilions
	for sg in [-1.0, 1.0]:
		var x0: float = minf(sg * 14.0, sg * 20.5)
		var x1: float = maxf(sg * 14.0, sg * 20.5)
		var cx := (x0 + x1) * 0.5
		_r(x0, 0.8, x1, 19, p)
		_r(x0, 18.4, x1, 19, wt)
		_poly([x0 + 0.5, 19, x1 - 0.5, 19] + _arc(cx, 19, 2.8, 3.6, 0, PI, 10), slate)
		_l(cx, 22.6, cx, 24, GOLD, 0.15)
	# the central part and the tower
	_r(-6, 0.8, 6, 20, p)
	_r(-6, 0.8, -5.3, 20, pd)
	_arched(0, 0.8, 3, 4.5, WOOD)
	for x in [-3.4, 0.0, 3.4]:
		_arched(x, 8.2, 1.6, 5, WIN)
	_poly([-6.5, 20, 6.5, 20, 0, 23], wt)
	_r(-3.5, 20, 3.5, 30.5, p)
	_r(-3.5, 20, -2.9, 30.5, pd)
	_c(0, 27, 1.8, wt)
	_c(0, 27, 1.45, Color("2c4f80"))
	_l(0, 27, 0, 28.2, GOLD, 0.15)
	_l(0, 27, 0.9, 27, GOLD, 0.15)
	_arched(0, 22, 1.4, 3, WIN)
	_r(-4, 30.5, 4, 31.5, wt)
	_r(-2.4, 31.5, 2.4, 33.6, p)
	_poly([-2.8, 33.6, 2.8, 33.6] + _arc(0, 33.6, 2.8, 2.6, 0, PI, 10), slate)
	_r(-0.6, 36.2, 0.6, 37.6, wt)
	_poly([-0.9, 37.6, 0.9, 37.6, 0, 39.6], slate)
	_l(0, 39.6, 0, 40, GOLD, 0.15)

## One elephant (s = scale, d = 1 facing right, -1 facing left) standing at x.
static func _elephant(x: float, s: float, d: float) -> void:
	var g := Color("8d8a86")
	var gd := g.darkened(0.2)
	for lx in [-1.5, -0.6, 0.6, 1.4]:
		_r(x + (lx - 0.3) * s * d, 0, x + (lx + 0.3) * s * d, 1.6 * s, gd if lx < 0.0 else g)
	_c(x - 0.9 * s * d, 2.5, 1.35 * s, g)
	_c(x + 0.7 * s * d, 2.6, 1.45 * s, g)
	_r(x - 1.0 * s, 1.3 * s, x + 1.0 * s, 3.6 * s, g)
	_c(x + 2.2 * s * d, 3.0 * s, 1.0 * s, g)
	_c(x + 1.9 * s * d, 2.9 * s, 0.8 * s, gd)
	_l(x + 2.9 * s * d, 2.9 * s, x + 3.3 * s * d, 1.6 * s, g, 0.38 * s)
	_l(x + 3.3 * s * d, 1.6 * s, x + 3.0 * s * d, 0.6 * s, g, 0.3 * s)
	_l(x + 2.7 * s * d, 2.4 * s, x + 3.2 * s * d, 2.1 * s, Color("f2ead8"), 0.14 * s)
	_c(x + 2.5 * s * d, 3.3 * s, 0.11 * s, DARK)
	_l(x - 2.2 * s * d, 3.0 * s, x - 2.5 * s * d, 1.8 * s, gd, 0.1 * s)

## The Sóstó Zoo in Nyíregyháza: an elephant with her calf on the grass under an acacia, by the woods.
static func _zoo() -> void:
	_r(-9, 0, 9, 0.4, Color("8fae5a"))
	# the woods behind and an acacia
	for k in 5:
		_c(-8 + k * 4.0, 4.6 + (k % 2) * 0.6, 2.2, TREE.lightened(0.08 * (k % 3)))
	_r(-6.3, 0, -5.8, 5.2, WOOD)
	_l(-6, 4.4, -7.4, 5.8, WOOD, 0.25)
	_poly([-9, 5.6, -3, 5.6, -3.8, 6.6, -8.4, 6.6], Color("4f7f3a"))
	# a pool
	_poly([2.5, 0, 9, 0, 9, 0.5, 3.5, 0.5], WATER)
	# the elephants
	_elephant(0.5, 1.0, 1.0)
	_elephant(-3.8, 0.55, 1.0)

## The Cifrapalota in Kecskemét: the Art Nouveau "ornamental palace", its cream walls studded with colourful
## Zsolnay-tile flowers and its wavy roofline of glazed tiles.
static func _cifrapalota() -> void:
	var w := Color("f0e6d0")
	var blue := Color("3b7fb5")
	var red := Color("c8402e")
	var yel := Color("e8b43a")
	var grn := Color("4f9a6a")
	_r(-16, 0, 16, 0.8, Color("b9b4a8"))
	_r(-14, 0.8, 14, 13.5, w)
	# the wavy roof: tiled bumps along the top, a taller one in the middle
	var top := []
	for k in 29:
		var x := -14.0 + k
		var hump := 1.2 + absf(sin(x * PI / 3.5)) * 1.6
		if absf(x) < 4.0: hump += (4.0 - absf(x)) * 1.4
		top.append_array([x, 13.5 + hump])
	_poly([14, 13.5, -14, 13.5] + top, blue)
	for k in range(0, top.size() - 2, 2):
		_l(top[k], top[k + 1], top[k + 2], top[k + 3], yel, 0.3)
	_r(-14, 13.2, 14, 13.8, grn)
	# the tile bands and flowers
	_r(-14, 7, 14, 7.6, blue)
	if _detail(0.9):
		for k in 9:
			var x := -12.0 + k * 3.0
			var col: Color = [red, blue, yel][k % 3]
			_c(x, 11.4, 0.7, col)
			_c(x, 11.4, 0.28, w)
			_c(x, 9.9, 0.25, grn)
	# the windows with coloured surrounds
	for x in [-11.0, -7.0, -3.0, 3.0, 7.0, 11.0]:
		_arched(x, 2.0, 2.2, 4.0, yel)
		_arched(x, 2.2, 1.6, 3.4, WIN)
	_arched(0, 0.8, 3.6, 5.5, red)
	_arched(0, 0.8, 2.8, 5.0, WOOD)
	_c(0, 16.6, 1.0, red)
	_c(0, 16.6, 0.5, yel)

## Bory Castle in Székesfehérvár: the white concrete castle the architect Jenő Bory built for his wife, its keep
## with turrets, red-roofed corner towers and the arcade of statues round the courtyard.
static func _bory() -> void:
	var w := Color("e6e2d8")
	var wd := w.darkened(0.15)
	_poly([-20, 0, 20, 0, 19, 1, -19, 1], Color("7f9a58"))
	# the keep
	_r(-4, 1, 4, 19, w)
	_r(-4, 1, -3.2, 19, wd)
	for k in 4:
		_r(-4 + k * 2.2, 19, -4 + k * 2.2 + 1.3, 20.3, w)
	for sg in [-1.0, 1.0]:
		var x: float = sg * 4.0
		_r(x - 0.9, 16, x + 0.9, 21.5, w)
		_poly([x - 1.2, 21.5, x + 1.2, 21.5, x, 24], RED_ROOF)
	_pointed(0, 9, 1.6, 4, WIN)
	_pointed(0, 14, 1.2, 3, WIN)
	# the corner towers
	for sg in [-1.0, 1.0]:
		var x: float = sg * 15.0
		_r(x - 2.5, 1, x + 2.5, 12, w)
		_r(x - 2.5, 1, x - 1.8, 12, wd)
		_poly([x - 3, 12, x + 3, 12, x, 16.5], RED_ROOF)
		_arched(x, 6, 1.2, 2.6, WIN)
	# the arcade with statues on its columns
	_r(-12.5, 1, 12.5, 6.5, w)
	for k in 8:
		var x := -11.0 + k * 3.15
		if absf(x) < 3.5: continue
		_poly([x - 1.0, 1, x + 1.0, 1, x + 1.0, 3.6] + _arc(x, 3.6, 1.0, 1.0, 0, PI, 6), Color("7f8a8f"))
	_r(-12.5, 6.5, 12.5, 7.1, wd)
	if _detail(1.2):
		for k in 7:
			var x := -9.5 + k * 3.15
			if absf(x) < 3.5: continue
			_r(x - 0.2, 7.1, x + 0.2, 8.4, wd)
			_c(x, 8.7, 0.3, wd)
