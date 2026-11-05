class_name LandmarksDeT3
extends RefCounted
## German landmarks of the towns between the map cities, drawn with LandmarkPainter's helpers (metres from the
## base point, y up).

const WHITE := Color("f2efe6")
const RED_ROOF := Color("b5432e")
const SLATE := Color("4a5058")
const WATER := Color("4f8fc0")
const WATER_L := Color("9cc8e6")
const ROCK := Color("8f8a80")
const GRASS := Color("5d8f42")
const TREE := Color("3f6f34")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const WOOD := Color("7a5634")
const BRONZE := Color("4e5a4a")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"schloss_ahrensburg": _schloss_ahrensburg()
		"vogelpark_flamingos": _vogelpark_flamingos()
		"miele_washer": _miele_washer()
		"duelmen_wild_horses": _duelmen_wild_horses()
		"bergbau_museum": _bergbau_museum()
		"bucket_wheel_excavator": _bucket_wheel_excavator()
		"limburger_dom": _limburger_dom()
		"hochzeitsturm": _hochzeitsturm()
		"schloss_friedenstein": _schloss_friedenstein()
		"goethe_schiller": _goethe_schiller()
		"bauhaus_dessau": _bauhaus_dessau()
		"beelitz_asparagus": _beelitz_asparagus()
		"reitender_roland": _reitender_roland()
		"leonberger_dog": _leonberger_dog()
		"schloss_bruchsal": _schloss_bruchsal()
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

static func _pl(xy: Array, col: Color, w: float) -> void:
	LandmarkPainter._pl(xy, col, w)

static func _ell(cx: float, cy: float, rx: float, ry: float, rot: float, col: Color) -> void:
	LandmarkPainter._ell(cx, cy, rx, ry, rot, col)

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

## A horse standing on (x, y), s metres to a unit, facing right (d = 1) or left (d = -1). `dark` is its mane, tail
## and lower legs.
static func _horse(x: float, y: float, s: float, d: float, col: Color, dark: Color) -> void:
	var p := func(px: float, py: float) -> Array: return [x + px * s * d, y + py * s]
	for lx in [-0.8, -0.55, 0.55, 0.8]:
		var a: Array = p.call(lx - 0.09, 0.0)
		var b: Array = p.call(lx + 0.09, 1.2)
		_r(minf(a[0], b[0]), a[1], maxf(a[0], b[0]), b[1], col.darkened(0.08))
		var c: Array = p.call(lx + 0.09, 0.35)
		_r(minf(a[0], c[0]), a[1], maxf(a[0], c[0]), c[1], dark)
	var tail: Array = p.call(-1.0, 1.7) + p.call(-1.25, 1.2) + p.call(-1.2, 0.6)
	_pl(tail, dark, 0.16 * s)
	var body: Array = p.call(0, 1.45)
	_ell(body[0], body[1], 1.08 * s, 0.46 * s, 0.0, col)
	var neck: Array = p.call(0.5, 1.75) + p.call(0.95, 1.3) + p.call(1.35, 2.15) + p.call(1.05, 2.4)
	_poly(neck, col)
	var head: Array = p.call(1.4, 2.05)
	_ell(head[0], head[1], 0.38 * s, 0.17 * s, -1.0 * d, col)
	_poly(p.call(1.08, 2.36) + p.call(1.16, 2.62) + p.call(1.26, 2.36), col)
	var mn: Array = p.call(0.55, 1.85) + p.call(1.12, 2.42)
	_l(mn[0], mn[1], mn[2], mn[3], dark, 0.13 * s)
	if _detail(1.0):
		var st: Array = p.call(-0.9, 1.86) + p.call(0.5, 1.86)
		_l(st[0], st[1], st[2], st[3], dark, 0.07 * s) # the dark stripe down the back
		var ey: Array = p.call(1.3, 2.18)
		_c(ey[0], ey[1], 0.05 * s, DARK)

## Ahrensburg Castle: the white Renaissance castle on its moat, three houses side by side under curved stepped
## gables, red tiled roofs and octagonal corner towers with dark bell caps.
static func _schloss_ahrensburg() -> void:
	_r(-18, 0, 18, 1.6, WATER)
	if _detail(1.0):
		_l(-16, 0.7, -9, 0.7, WATER_L, 0.2)
		_l(6, 0.9, 14, 0.9, WATER_L, 0.2)
	var w := WHITE
	var wd := w.darkened(0.12)
	# the roofs of the three houses going back
	for cx in [-7.2, 0.0, 7.2]:
		_poly([cx - 3.6, 13, cx + 3.6, 13, cx + 2.4, 19, cx - 2.4, 19], RED_ROOF.darkened(0.1))
	_r(-11, 1.6, 11, 13, w)
	_r(-11, 1.6, 11, 2.6, wd)
	# the three curved stepped gables
	for cx in [-7.2, 0.0, 7.2]:
		var tiers := [[3.6, 13.0, 15.2], [2.4, 15.2, 17.2], [1.2, 17.2, 19.0]]
		for t in tiers:
			_r(cx - t[0], t[1], cx + t[0], t[2], w)
		for k in 2:
			var wi: float = tiers[k + 1][0]
			var ys: float = tiers[k][2]
			_poly([cx + wi, ys] + _arc(cx + wi, ys, 1.2, 1.2, 0, PI * 0.5, 5), w)
			_poly([cx - wi, ys] + _arc(cx - wi, ys, 1.2, 1.2, PI * 0.5, PI, 5), w)
		_poly(_arc(cx, 19.0, 1.2, 1.2, 0, PI, 6), w)
		_l(cx, 20.2, cx, 21.2, DARK, 0.15)
		_windows(cx - 2.2, cx + 2.2, 15.6, 16.8, 2, WIN)
		_windows(cx - 3.2, cx + 3.2, 9, 11.2, 3, WIN)
		_windows(cx - 3.2, cx + 3.2, 5, 7.2, 3, WIN)
		if cx != 0.0:
			_l(cx - 3.6 * signf(cx), 2.6, cx - 3.6 * signf(cx), 13, wd, 0.2)
	# the door and the bridge over the moat
	_poly([-1.1, 1.6, 1.1, 1.6, 1.1, 3.6] + _arc(0, 3.6, 1.1, 1.1, 0, PI, 6), Color("5a3b26"))
	_r(-1.6, 1.2, 1.6, 1.8, Color("9a8a74"))
	# the four towers (two at the front corners, two behind)
	for x in [-12.6, 12.6]:
		var tx: float = x
		_r(tx - 1.8, 1.6, tx + 1.8, 17, w)
		_r(tx - 1.8, 1.6, tx - 1.1, 17, wd)
		_r(tx + 1.1, 1.6, tx + 1.8, 17, wd)
		_windows(tx - 1.0, tx + 1.0, 13, 14.6, 1, WIN)
		_windows(tx - 1.0, tx + 1.0, 8, 9.6, 1, WIN)
		_r(tx - 2.0, 17, tx + 2.0, 17.6, wd)
		# the bell cap with a little lantern and spike
		_poly([tx - 2.0, 17.6, tx + 2.0, 17.6, tx + 1.2, 19.6, tx + 0.5, 21.2, tx - 0.5, 21.2, tx - 1.2, 19.6], SLATE)
		_r(tx - 0.4, 21.2, tx + 0.4, 22.4, SLATE.lightened(0.1))
		_poly([tx - 0.6, 22.4, tx + 0.6, 22.4, tx, 24.6], SLATE)
		_l(tx, 24.6, tx, 26, LandmarkPainter.GOLD, 0.15)

## A flamingo standing on (x, y) in the water, facing d; one leg tucked up when `one_leg`.
static func _flamingo(x: float, y: float, d: float, one_leg: bool) -> void:
	var pink := Color("f28fa6")
	var leg := Color("d97a8c")
	_l(x - 0.1 * d, y, x - 0.1 * d, y + 2.4, leg, 0.09)
	if one_leg:
		_pl([x + 0.1 * d, y + 2.4, x + 0.45 * d, y + 1.9, x + 0.1 * d, y + 1.6], leg, 0.09)
	else:
		_l(x + 0.15 * d, y, x + 0.05 * d, y + 2.4, leg, 0.09)
	_ell(x, y + 2.75, 0.75, 0.42, -0.15 * d, pink)
	_poly([x - 0.6 * d, y + 2.85, x - 1.05 * d, y + 2.6, x - 0.6 * d, y + 2.55], Color("e0607e"))
	if _detail(1.0):
		_ell(x - 0.15 * d, y + 2.8, 0.4, 0.2, -0.2 * d, Color("f7b4c3"))
	_pl([x + 0.55 * d, y + 2.9, x + 0.75 * d, y + 3.5, x + 0.5 * d, y + 4.1, x + 0.6 * d, y + 4.7], pink, 0.17)
	_c(x + 0.72 * d, y + 4.8, 0.2, pink)
	_pl([x + 0.85 * d, y + 4.85, x + 1.1 * d, y + 4.6, x + 1.12 * d, y + 4.4], Color("f4ecd8"), 0.1)
	_l(x + 1.12 * d, y + 4.55, x + 1.12 * d, y + 4.35, DARK, 0.1)

## Weltvogelpark Walsrode: pink flamingos wading in a pond with reeds behind them.
static func _vogelpark_flamingos() -> void:
	_poly([-5, 0, 5, 0, 5, 1.6, 3.5, 2.0, -3.5, 1.9, -5, 1.5], GRASS)
	var reed := Color("6f8f3c")
	for k in 9:
		var x: float = -4.6 + k * 1.15
		_l(x, 1.5, x + 0.15, 3.0 + float(k % 3) * 0.5, reed, 0.12)
		if _detail(1.4) and k % 2 == 0:
			_ell(x + 0.17, 3.0 + float(k % 3) * 0.5, 0.09, 0.3, 0.0, Color("6b4a2a"))
	_poly([-5, 0, 5, 0, 4.6, 0.9, -4.6, 0.9], WATER)
	if _detail(1.0):
		_l(-4, 0.4, -1.5, 0.4, WATER_L, 0.08)
		_l(1.5, 0.6, 4, 0.6, WATER_L, 0.08)
	_flamingo(-3.0, 0.3, 1.0, false)
	_flamingo(0.0, 0.5, -1.0, true)
	_flamingo(2.9, 0.2, 1.0, false)

## A Miele washing machine from Gütersloh, where they have been made since 1907: the white front loader with its
## red name badge, the program dial and a round door with the wash spinning behind the glass.
static func _miele_washer() -> void:
	var w := Color("f4f4f2")
	var wd := Color("d4d6d8")
	_r(-1.9, 0, -1.5, 0.3, DARK)
	_r(1.5, 0, 1.9, 0.3, DARK)
	_r(-2.1, 0.3, 2.1, 5.9, w)
	_r(1.7, 0.3, 2.1, 5.9, wd)
	_r(-2.1, 0.3, 2.1, 0.7, wd)
	# the control panel along the top
	_r(-2.1, 4.8, 2.1, 5.9, Color("e6e7e8"))
	_l(-2.1, 4.8, 2.1, 4.8, wd, 0.06)
	_r(-1.9, 5.1, -1.3, 5.6, wd) # the soap drawer
	_r(-1.2, 5.2, -0.3, 5.55, Color("a80f1e")) # the red Miele badge
	_c(0.5, 5.35, 0.36, Color("b8bcc2"))
	_c(0.5, 5.35, 0.26, Color("dfe1e4"))
	_l(0.5, 5.35, 0.5, 5.6, DARK, 0.06)
	_r(1.05, 5.2, 1.85, 5.5, Color("2a3a3a"))
	if _detail(2.0):
		_r(1.15, 5.28, 1.5, 5.42, Color("7ee0a8"))
	# the round door
	_c(0, 2.6, 1.6, Color("aeb4bb"))
	_c(0, 2.6, 1.35, Color("dfe3e8"))
	_c(0, 2.6, 1.1, Color("2f4a63"))
	_poly(_arc(0, 2.6, 1.1, 1.1, PI * 1.05, PI * 1.95, 10), Color("5d9dd0"))
	_ell(-0.35, 2.0, 0.35, 0.2, 0.4, Color("e05050"))
	_ell(0.35, 2.15, 0.3, 0.18, -0.3, Color("f0d040"))
	if _detail(1.2):
		for b in [[-0.5, 2.9, 0.12], [0.2, 3.1, 0.09], [0.55, 2.7, 0.14], [-0.1, 2.55, 0.08]]:
			_c(b[0], b[1], b[2], Color(1, 1, 1, 0.55))
	_ell(-0.45, 3.1, 0.35, 0.15, 0.7, Color(1, 1, 1, 0.35))
	_r(1.55, 2.3, 1.75, 2.9, Color("9aa0a8"))

## The Dülmen wild horses: little mouse-grey and brown ponies with dark manes and a stripe down the back, living
## free in the Merfelder Bruch, and a foal.
static func _duelmen_wild_horses() -> void:
	_poly([-7, 0, 7, 0, 7, 0.8, -7, 1.1], GRASS)
	_tree(-5.6, 0.6, 1.4)
	_tree(5.4, 0.8, 1.6)
	_tree(6.4, 0.6, 1.1)
	var dark := Color("2f2924")
	_horse(-2.6, 0.1, 1.6, 1.0, Color("a08a6c"), dark)
	_horse(2.4, 0.3, 1.5, -1.0, Color("8a7a66"), dark)
	_horse(0.4, 0.0, 1.0, 1.0, Color("b49c78"), Color("4a3e32"))
	if _detail(1.0):
		for x in [-6.0, -3.6, 1.4, 4.0, 6.2]:
			_l(x, 0.2, x + 0.1, 0.7, TREE.lightened(0.2), 0.08)

## The German Mining Museum in Bochum: the long red-brick museum with its tall windows, the big green steel winding
## tower standing on top of it, and its two rope wheels.
static func _bergbau_museum() -> void:
	var brick := LandmarkPainter.BRICK
	var bd := LandmarkPainter.BRICK_D
	_r(-9, 0, 9, 11, brick)
	_r(-9, 0, 9, 1.2, bd)
	_r(-9.3, 10.4, 9.3, 11.4, bd)
	_poly([-1.5, 1.2, 1.5, 1.2, 1.5, 4] + _arc(0, 4, 1.5, 1.5, 0, PI, 6), DARK)
	if _detail(1.0):
		for x in [-7.5, -5.5, -3.5, 3.5, 5.5, 7.5]:
			_r(x - 0.6, 3, x + 0.6, 9, WIN)
	var g := Color("3f7a52")
	var gl := g.lightened(0.2)
	# the slanting struts on both sides (the double trestle)
	_l(-8.5, 11.4, -2.4, 33, g, 0.6)
	_l(8.5, 11.4, 2.4, 33, g, 0.6)
	_l(-5.5, 11.4, -2.4, 26, g, 0.35)
	_l(5.5, 11.4, 2.4, 26, g, 0.35)
	# the tower: two legs and the cross bracing
	_l(-2.6, 11.4, -2.2, 34, g, 0.5)
	_l(2.6, 11.4, 2.2, 34, g, 0.5)
	var ys := [11.4, 15.0, 18.6, 22.2, 25.8, 29.4, 33.0]
	for k in ys.size() - 1:
		var y0: float = ys[k]
		var y1: float = ys[k + 1]
		_l(-2.5, y1, 2.5, y1, gl, 0.3)
		if _detail(0.9):
			_l(-2.5, y0, 2.5, y1, g, 0.18)
			_l(2.5, y0, -2.5, y1, g, 0.18)
	# the top platform and the two rope wheels
	_r(-3.4, 33.4, 3.4, 34.4, g.darkened(0.1))
	for x in [-1.6, 1.6]:
		_c(x, 36.6, 2.1, g.darkened(0.15))
		_c(x, 36.6, 1.7, gl)
		_c(x, 36.6, 1.45, g.darkened(0.15))
		if _detail(1.0):
			for a in 4:
				var an: float = a * PI / 4.0
				_l(x - cos(an) * 1.5, 36.6 - sin(an) * 1.5, x + cos(an) * 1.5, 36.6 + sin(an) * 1.5, gl, 0.12)
		_c(x, 36.6, 0.35, gl)
	_l(0, 36.6, 0, 39.4, g, 0.25)
	_r(-0.9, 38.6, 0.9, 39.2, g)

## A giant bucket-wheel excavator from the Garzweiler open-pit mine by Jüchen: the spinning wheel of buckets at the
## end of its long boom, the house on its crawler tracks, the tall mast with its cables and the counterweight.
static func _bucket_wheel_excavator() -> void:
	var soil := Color("8a6a46")
	var coal := Color("4a3b30")
	# the bank of earth and coal the wheel bites into
	_poly([-20, 0, -8, 0, -11, 3.5, -14, 5.5, -20, 6.5], soil)
	_poly([-20, 0, -12.5, 0, -14, 2.2, -20, 2.8], coal)
	_r(-20, 0, 20, 0.5, soil.darkened(0.15))
	var body := Color("d8dadc")
	var bd := Color("9aa0a6")
	var steel := Color("5a6068")
	var orange := Color("e07a2a")
	# the cables from the mast to both booms
	_l(4, 20, -11, 7.6, steel, 0.12)
	_l(4, 20, -6, 7.8, steel, 0.12)
	_l(4, 20, 16, 11.8, steel, 0.12)
	# the wheel boom (a truss going down to the wheel)
	_poly([-13, 6.2, 1, 8.2, 1, 9.6, -13, 7.6], bd)
	if _detail(0.8):
		for k in 7:
			var x: float = -12.0 + k * 2.0
			_l(x, 6.4 + (x + 13.0) * 0.143, x + 1.0, 7.8 + (x + 14.0) * 0.143, steel, 0.12)
	# the conveyor boom out to the back
	_poly([7, 4, 19.5, 2.8, 19.5, 3.6, 7, 5.2], bd)
	_l(19.5, 3.2, 19.5, 1.4, steel, 0.25)
	# the counterweight boom
	_poly([6, 9.2, 17, 11.2, 17, 12.2, 6, 10.6], bd)
	_r(14.5, 9.2, 18.5, 12.2, steel)
	# the crawlers and the turntable
	for x in [-1.0, 7.0]:
		_r(x - 3.2, 0.5, x + 3.2, 2.4, DARK)
		if _detail(1.0):
			for k in 6:
				_c(x - 2.6 + k * 1.04, 1.45, 0.38, steel)
	_r(-2, 2.4, 10, 3.4, steel)
	# the house
	_r(-1.5, 3.4, 9.5, 9.2, body)
	_r(-1.5, 3.4, 9.5, 4.2, orange)
	_windows(-0.8, 8.8, 6.2, 7.6, 5, WIN)
	_r(0.6, 9.2, 4.6, 11.2, body.darkened(0.06))
	_windows(1.0, 4.2, 9.8, 10.7, 2, WIN)
	# the mast
	_poly([1.5, 9.2, 3.0, 9.2, 4.4, 20.4, 3.6, 20.4], bd)
	_poly([5.0, 9.2, 6.5, 9.2, 4.4, 20.4, 3.6, 20.4], bd.darkened(0.08))
	_c(4, 20.4, 0.5, orange)
	# the bucket wheel
	var cx := -14.0
	var cy := 6.8
	for k in 12:
		var a: float = k * TAU / 12.0
		var bx := cx + cos(a) * 5.3
		var by := cy + sin(a) * 5.3
		var t := a + PI * 0.5
		_poly([bx + cos(a) * 0.4 - cos(t) * 0.9, by + sin(a) * 0.4 - sin(t) * 0.9,
			bx + cos(a) * 0.9 + cos(t) * 0.4, by + sin(a) * 0.9 + sin(t) * 0.4,
			bx - cos(a) * 0.6 + cos(t) * 0.7, by - sin(a) * 0.6 + sin(t) * 0.7,
			bx - cos(a) * 0.6 - cos(t) * 0.7, by - sin(a) * 0.6 - sin(t) * 0.7], orange)
	_c(cx, cy, 5.0, steel)
	_c(cx, cy, 4.3, body)
	_c(cx, cy, 3.4, bd)
	for k in 6:
		var a: float = k * PI / 6.0
		_l(cx - cos(a) * 3.6, cy - sin(a) * 3.6, cx + cos(a) * 3.6, cy + sin(a) * 3.6, steel, 0.3)
	_c(cx, cy, 1.0, orange)

## Limburg Cathedral: high on its rock above the Lahn, white walls painted with red and ochre bands, the two west
## towers and the tall crossing tower with dark diamond-shaped spires, and two little towers at the sides.
static func _limburger_dom() -> void:
	_r(-17, 0, 17, 1.6, WATER)
	if _detail(1.0):
		_l(-15, 0.8, -6, 0.8, WATER_L, 0.2)
		_l(5, 0.8, 14, 0.8, WATER_L, 0.2)
	_poly([-17, 1.6, 17, 1.6, 15, 6, 11, 8.6, -11, 8.6, -15, 6], ROCK)
	_poly([-17, 1.6, -15, 6, -12, 4.5, -10, 1.6], TREE)
	_poly([17, 1.6, 15, 6, 12, 3.5, 10, 1.6], TREE)
	_poly([-4, 1.6, -1, 6, 2, 1.6], ROCK.darkened(0.15))
	var w := WHITE
	var red := Color("b5473a")
	var ochre := Color("d9a54a")
	# the helm of a tower centred at x, its walls ending at y, a little gable on each face and the dark diamond spire
	var helm := func(x: float, y: float, hw: float, top: float) -> void:
		_poly([x - hw, y, x + hw, y, x, y + hw * 0.9], w)
		_poly([x - hw, y, x, y + hw * 0.9, x + hw, y, x, top], SLATE)
		_poly([x - hw, y, x, y + hw * 0.9, x, top], SLATE.lightened(0.12))
		_l(x, top, x, top + 1.2, LandmarkPainter.GOLD, 0.15)
	# the little side towers and the crossing tower behind the front
	for x in [-12.5, 12.5]:
		_r(x - 1.8, 8.6, x + 1.8, 24, w)
		_r(x - 1.8, 21, x + 1.8, 22, red)
		_windows(x - 1.2, x + 1.2, 17.5, 19.5, 1, WIN)
		helm.call(x, 24.0, 1.8, 30.0)
	_r(-11, 8.6, 11, 20, w.darkened(0.06))
	_r(-11, 18.4, 11, 19.4, red)
	_r(-3, 20, 3, 34, w)
	_r(-3, 30, 3, 31, red)
	_r(-3, 25.6, 3, 26.2, ochre)
	_windows(-2.4, 2.4, 27, 29.4, 2, WIN)
	helm.call(0.0, 34.0, 3.0, 44.0)
	# the west front with its rose window and gable
	_r(-4.5, 8.6, 4.5, 22, w)
	_poly([-4.5, 22, 4.5, 22, 0, 26], w)
	_r(-4.5, 13.8, 4.5, 14.4, ochre)
	_c(0, 18.2, 2.1, red)
	_c(0, 18.2, 1.6, WIN)
	if _detail(1.2):
		for a in 4:
			var an: float = a * PI / 4.0
			_l(-cos(an) * 1.6, 18.2 - sin(an) * 1.6, cos(an) * 1.6, 18.2 + sin(an) * 1.6, red, 0.15)
	_poly([-1.4, 8.6, 1.4, 8.6, 1.4, 11.4] + _arc(0, 11.4, 1.4, 1.4, 0, PI, 6), Color("5a3b26"))
	_windows(-4, 4, 23, 24.4, 3, red)
	# the two west towers
	for x in [-7.5, 7.5]:
		_r(x - 3, 8.6, x + 3, 34, w)
		_r(x - 3, 8.6, x - 2.3, 34, red)
		_r(x + 2.3, 8.6, x + 3, 34, red)
		for y in [16.0, 24.0]:
			_r(x - 3, y, x + 3, y + 0.7, red)
		_r(x - 3, 31.6, x + 3, 32.4, ochre)
		_windows(x - 2, x + 2, 12, 14.4, 2, WIN)
		_windows(x - 2, x + 2, 19, 22, 2, WIN)
		_windows(x - 2, x + 2, 27, 30, 2, WIN)
		helm.call(x, 34.0, 3.0, 41.0)

## The Wedding Tower in Darmstadt: a tall dark-red brick tower with bands of corner windows, a big clock, and the
## five rounded "fingers" on its top with copper roofs, the golden domes of the little Russian chapel beside it.
static func _hochzeitsturm() -> void:
	_poly([-7, 0, 7, 0, 7, 1.6, -7, 2.0], GRASS)
	# the Russian chapel
	var cw := Color("e8e2d4")
	_r(-7, 1.8, -3.8, 6.6, cw)
	_poly([-7.2, 6.6, -3.6, 6.6, -5.4, 7.8], Color("4a6aa8"))
	_windows(-6.6, -4.2, 3.4, 5.2, 2, WIN)
	var gold := LandmarkPainter.GOLD
	for d in [[-5.4, 7.9, 0.9], [-6.6, 6.6, 0.45], [-4.2, 6.6, 0.45]]:
		var x: float = d[0]
		var y: float = d[1]
		var s: float = d[2]
		_poly([x - s, y, x + s, y, x + s * 1.1, y + s * 0.9, x, y + s * 2.0, x - s * 1.1, y + s * 0.9], gold)
		_l(x, y + s * 2.0, x, y + s * 2.6, gold, 0.1)
	# the tower
	var b := Color("8a3a2a")
	var bl := b.lightened(0.1)
	_r(-3.6, 1.8, 4.6, 37.2, b)
	_r(3.4, 1.8, 4.6, 37.2, b.darkened(0.15))
	_r(-3.6, 1.8, -2.9, 37.2, bl)
	# the bands of windows wrapping round the corner, climbing
	for k in 4:
		var y0: float = 8.0 + k * 5.6
		_r(-1.8 + k * 1.2, y0, 4.6, y0 + 1.8, Color("2a3038"))
		if _detail(1.0):
			_l(-1.8 + k * 1.2, y0 + 0.9, 4.6, y0 + 0.9, Color("c9c2b0"), 0.1)
	_poly([-1, 1.8, 1, 1.8, 1, 4.6] + _arc(0, 4.6, 1, 1, 0, PI, 6), DARK)
	# the clock
	_c(0.5, 32.4, 2.0, gold)
	_c(0.5, 32.4, 1.7, Color("1f2a44"))
	_l(0.5, 32.4, 0.5, 33.8, gold, 0.18)
	_l(0.5, 32.4, 1.4, 32.0, gold, 0.18)
	# the five fingers, the middle one highest
	var cop := Color("4f8c84")
	var hs := [39.6, 41.8, 44.2, 41.8, 39.6]
	for k in 5:
		var x0: float = -3.6 + k * 1.64
		var x1: float = x0 + 1.64
		var h: float = hs[k]
		_r(x0 + 0.1, 37.0, x1 - 0.1, h, b if k % 2 == 0 else bl)
		_poly(_arc((x0 + x1) * 0.5, h, 0.86, 1.5, 0, PI, 8), cop)
		_poly(_arc((x0 + x1) * 0.5, h, 0.86, 1.5, PI * 0.5, PI, 4) + [(x0 + x1) * 0.5, h], cop.lightened(0.15))
		if _detail(1.2):
			_poly([x0 + 0.55, 38.0, x1 - 0.55, 38.0, x1 - 0.55, h - 1.0] + _arc((x0 + x1) * 0.5, h - 1.0, 0.27, 0.35, 0, PI, 4),
				WIN)

## Friedenstein Palace in Gotha: a huge plain white early-baroque palace with three rows of windows under a steep
## dark roof, and a tall square tower at each end with a bell cap, a lantern and a spike.
static func _schloss_friedenstein() -> void:
	_r(-28, 0, 28, 1.2, Color("b8b0a0"))
	var w := Color("f0ead8")
	var wd := w.darkened(0.12)
	_poly([-23, 13, 23, 13, 21, 17.5, -21, 17.5], SLATE)
	if _detail(1.0):
		for x in [-16.0, -10.0, -4.0, 4.0, 10.0, 16.0]:
			_r(x - 0.6, 14, x + 0.6, 15.6, WIN)
			_poly([x - 0.8, 15.6, x + 0.8, 15.6, x, 16.4], SLATE.lightened(0.15))
	_r(-23, 1.2, 23, 13, w)
	_r(-23, 1.2, 23, 2.2, wd)
	_r(-23.3, 12.6, 23.3, 13.2, wd)
	_windows(-20, 20, 3.4, 5.4, 16, WIN)
	_windows(-20, 20, 7.0, 9.0, 16, WIN)
	_windows(-20, 20, 10.2, 11.8, 16, WIN)
	# the middle portal
	_r(-3, 1.2, 3, 13, w.lightened(0.05))
	_poly([-1.3, 1.2, 1.3, 1.2, 1.3, 4.2] + _arc(0, 4.2, 1.3, 1.3, 0, PI, 6), Color("5a3b26"))
	_poly([-3.4, 13, 3.4, 13, 0, 15.2], w)
	_c(0, 13.9, 0.5, LandmarkPainter.GOLD)
	# the two corner towers
	for x in [-25.0, 25.0]:
		_r(x - 3, 1.2, x + 3, 19, w)
		_r(x + signf(x) * 2.2, 1.2, x + signf(x) * 3, 19, wd)
		_windows(x - 2.2, x + 2.2, 3.4, 5.4, 2, WIN)
		_windows(x - 2.2, x + 2.2, 7.0, 9.0, 2, WIN)
		_windows(x - 2.2, x + 2.2, 10.2, 11.8, 2, WIN)
		_windows(x - 2.2, x + 2.2, 14.6, 16.6, 2, WIN)
		_r(x - 3.3, 19, x + 3.3, 19.6, wd)
		_poly([x - 3.3, 19.6, x + 3.3, 19.6, x + 2.6, 21.4, x + 1.0, 22.6, x - 1.0, 22.6, x - 2.6, 21.4], SLATE)
		_r(x - 0.7, 22.6, x + 0.7, 23.8, w)
		_poly([x - 1.0, 23.8, x + 1.0, 23.8, x, 25.4], SLATE)
		_l(x, 25.4, x, 26, LandmarkPainter.GOLD, 0.15)

## A man in a long coat for a monument, standing on (x, y): head at y + 6.
static func _poet(x: float, y: float, h: float, col: Color) -> void:
	var cl := col.lightened(0.12)
	_r(x - 0.45, y, x - 0.1, y + 2.2 * h, col.darkened(0.1))
	_r(x + 0.1, y, x + 0.45, y + 2.2 * h, col.darkened(0.1))
	_poly([x - 0.75, y + 1.5 * h, x + 0.75, y + 1.5 * h, x + 0.6, y + 4.8 * h, x - 0.6, y + 4.8 * h], cl)
	_r(x - 0.35, y + 4.8 * h, x + 0.35, y + 5.2 * h, cl)
	_c(x, y + 5.6 * h, 0.42, cl)

## The Goethe and Schiller Monument in Weimar: the two poets side by side in bronze on a stone pedestal, Goethe
## with his hand on Schiller's shoulder, both holding one laurel wreath.
static func _goethe_schiller() -> void:
	var stone := Color("b9b4a8")
	_r(-3.4, 0, 3.4, 0.8, stone.darkened(0.1))
	_r(-2.8, 0.8, 2.8, 3.2, stone)
	_r(-3.1, 3.2, 3.1, 3.7, stone.lightened(0.1))
	if _detail(1.4):
		_r(-1.8, 1.6, 1.8, 2.4, stone.darkened(0.12)) # the plaque
	var b := BRONZE
	_poet(-1.0, 3.7, 0.98, b)
	_poet(1.0, 3.7, 1.04, b.darkened(0.05))
	# Goethe's arm on Schiller's shoulder, and the wreath between them
	_l(-0.5, 8.0, 0.6, 8.4, b.lightened(0.12), 0.22)
	_l(-0.6, 7.2, -0.15, 6.4, b.lightened(0.12), 0.22)
	_l(0.6, 7.6, 0.25, 6.4, b.lightened(0.12), 0.22)
	_pl(_arc(0.05, 6.0, 0.6, 0.5, 0, TAU, 12), Color("6f7a3e"), 0.22)
	# Schiller's other arm down, a scroll in his hand
	_l(1.6, 7.9, 1.85, 6.4, b, 0.2)
	_r(1.75, 5.9, 1.95, 6.6, b.lightened(0.2))

## The Bauhaus in Dessau: the white workshop block with its whole wall of glass, the bridge wing on pillars, the
## tall studio house with little balconies, and the BAUHAUS letters going down the white corner.
static func _bauhaus_dessau() -> void:
	_r(-20, 0, 20, 1, GRASS)
	var w := Color("f4f2ec")
	var wd := w.darkened(0.12)
	var glass := Color("44607a")
	# the studio house (Prellerhaus)
	_r(-20, 1, -13.5, 17.5, w)
	_r(-14.3, 1, -13.5, 17.5, wd)
	for k in 5:
		var y: float = 3.5 + k * 2.9
		_r(-19.4, y, -14.6, y + 1.6, glass)
		_r(-19.8, y - 0.25, -16.6, y, DARK) # the little balconies
		if _detail(1.2):
			_r(-18.8, y, -17.8, y + 1.6, Color("c63a2e")) # the red balcony doors
	_r(-20.2, 17.5, -13.3, 18, wd)
	# the bridge wing on its pillars
	_r(-13.5, 6.5, -5, 12, w)
	_r(-13.5, 8.2, -5, 10.6, glass)
	for x in [-11.0, -7.5]:
		_r(x - 0.4, 1, x + 0.4, 6.5, wd)
	# the workshop block with its glass wall
	_r(-5, 1, 20, 2.6, DARK)
	_r(-5, 2.6, 20, 12.6, glass)
	if _detail(0.8):
		for k in 14:
			var x: float = -5.0 + k * 1.8
			_l(x, 2.6, x, 12.6, w, 0.12)
		for y in [5.0, 7.6, 10.2]:
			_l(-5, y, 20, y, w, 0.12)
	_poly([-5, 7, 20, 2.6, 20, 4.0, -5, 9.2], Color(1, 1, 1, 0.12))
	_r(-5.3, 12.6, 20, 14, w)
	# the white corner with the letters
	_r(-5, 2.6, -2.6, 14, w)
	for k in 7:
		var y: float = 12.6 - k * 1.45
		_r(-4.3, y - 1.0, -3.3, y, DARK)
		if _detail(1.6):
			_r(-4.05, y - 0.75, -3.55, y - 0.25, w)

## Beelitz asparagus: a bundle of fat white spears with violet tips, tied with a red ribbon, a couple more poking out of
## the sandy ridge beside it.
static func _beelitz_asparagus() -> void:
	var sand := Color("c9a874")
	_poly([-2.5, 0, 2.5, 0, 2.3, 0.8, 1.4, 1.2, -1.4, 1.2, -2.3, 0.8], sand)
	var sp := Color("f3eedc")
	var tip := Color("b28aa8")
	var spear := func(x: float, y: float, h: float, wd: float) -> void:
		_r(x - wd, y, x + wd, y + h, sp)
		_r(x + wd * 0.4, y, x + wd, y + h, sp.darkened(0.08))
		_l(x - wd, y, x - wd, y + h, sp.darkened(0.2), 0.05)
		_poly([x - wd, y + h, x + wd, y + h, x + wd * 0.9, y + h + wd * 1.6, x + wd * 0.5, y + h + wd * 2.8,
			x, y + h + wd * 3.4, x - wd * 0.5, y + h + wd * 2.8, x - wd * 0.9, y + h + wd * 1.6], tip)
		_poly([x - wd, y + h, x + wd, y + h, x, y + h + wd * 1.4], tip.lightened(0.25))
		if _detail(1.4):
			for k in 3:
				var yy: float = y + h * (0.35 + k * 0.2)
				_poly([x - wd, yy, x - wd * 0.2, yy + wd * 0.6, x - wd, yy + wd * 0.8], tip.lightened(0.3))
	# two spears coming out of the ground
	spear.call(-2.0, 0.9, 1.4, 0.22)
	spear.call(2.0, 0.9, 0.9, 0.22)
	# the bundle
	var xs := [-0.9, -0.3, 0.3, 0.9, -1.2, -0.6, 0.0, 0.6, 1.2]
	var hs := [4.6, 4.9, 4.8, 4.5, 4.2, 4.4, 4.7, 4.3, 4.1]
	for k in xs.size():
		spear.call(xs[k], 1.0, hs[k], 0.27)
	_r(-1.6, 2.4, 1.6, 3.1, Color("c62a2a"))
	_poly([0.2, 2.5, 1.0, 1.7, 1.3, 1.9, 0.6, 2.6], Color("a81f1f"))
	_poly([0.2, 2.5, -0.5, 1.6, -0.8, 1.8, -0.2, 2.6], Color("a81f1f"))

## The riding Roland of Haldensleben: a knight in armour on his horse, holding up his sword, on a stone pedestal in
## the market square.
static func _reitender_roland() -> void:
	var stone := Color("b9b4a8")
	_r(-2.8, 0, 2.8, 2.8, stone)
	_r(-3.1, 2.6, 3.1, 3.1, stone.lightened(0.1))
	var st := Color("cfc3a2")
	var sd := st.darkened(0.25)
	_horse(-0.3, 3.1, 1.75, 1.0, st, sd)
	# the knight
	var arm := Color("9aa3ad")
	_poly([-0.9, 5.4, 0.3, 5.4, 0.2, 7.4, -0.8, 7.4], arm)
	_poly([-0.4, 5.6, 0.2, 5.6, 0.4, 4.4, 0.0, 4.2], arm.darkened(0.1)) # the leg
	_c(-0.3, 7.9, 0.45, arm)
	_poly([-0.75, 8.0, 0.15, 8.0, -0.3, 8.6], arm.darkened(0.15))
	_poly([-1.1, 6.8, -0.5, 5.2, -1.4, 5.0, -1.6, 6.2], Color("c0392b")) # the shield
	_l(0.2, 7.0, 0.8, 7.4, arm, 0.22)
	_l(0.8, 7.0, 0.8, 9.0, Color("dfe3e8"), 0.14) # the sword held up
	_l(0.5, 7.2, 1.1, 7.2, LandmarkPainter.GOLD, 0.12)

## A Leonberger: the big fluffy lion-like dog first bred in Leonberg, golden red with a black face, sitting on the grass.
static func _leonberger_dog() -> void:
	_poly([-2.5, 0, 2.5, 0, 2.5, 0.5, -2.5, 0.6], GRASS)
	var f := Color("c8893e")
	var fl := Color("dca865")
	var blk := Color("2a2420")
	# the bushy tail and the haunch
	_ell(-1.9, 0.9, 0.9, 0.35, 0.3, f.darkened(0.1))
	_ell(-0.9, 1.4, 1.2, 1.05, 0.0, f)
	_r(-1.3, 0.3, -0.2, 0.6, f.darkened(0.1))
	# the chest, the mane and the front legs
	_poly([-0.6, 0.6, 0.9, 0.4, 1.4, 2.6, 0.9, 3.2, -0.6, 2.4], f)
	for x in [0.3, 0.95]:
		_r(x - 0.22, 0.3, x + 0.22, 2.0, f.darkened(0.05))
		_ell(x + 0.1, 0.35, 0.32, 0.16, 0.0, f.darkened(0.15))
	_ell(0.8, 2.3, 0.7, 0.9, 0.0, fl) # the ruff
	# the head
	_c(1.0, 3.4, 0.75, f)
	_ell(1.6, 3.15, 0.5, 0.33, -0.15, blk)
	_c(2.05, 3.2, 0.14, Color("111111"))
	_ell(0.6, 3.25, 0.25, 0.5, 0.2, f.darkened(0.3)) # the ear
	_c(1.25, 3.6, 0.09, Color("111111"))
	_ell(1.75, 2.85, 0.18, 0.1, 0.0, Color("d06070")) # the tongue

## Bruchsal Palace: the baroque palace of the prince-bishops, a long cream front painted with red-pink pilasters and
## window frames, the middle with its triangular gable and coat of arms, a dark mansard roof and two side wings.
static func _schloss_bruchsal() -> void:
	_r(-28, 0, 28, 1.0, Color("cfc4ae"))
	var w := Color("efe2c8")
	var pk := Color("b8574a")
	var roof := Color("5a5658")
	# the side wings
	for s in [-1.0, 1.0]:
		var x0: float = 16.0 * s
		var x1: float = 27.0 * s
		var lo := minf(x0, x1)
		var hi := maxf(x0, x1)
		_poly([lo, 10, hi, 10, hi - 0.8, 14, lo + 0.8, 14], roof)
		_r(lo, 1, hi, 10, w)
		_r(lo, 1, hi, 1.8, pk)
		_r(lo, 9.4, hi, 10, pk)
		for x in [lo, hi - 0.7]:
			_r(x, 1, x + 0.7, 10, pk)
		_windows(lo + 0.8, hi - 0.8, 3.0, 5.4, 5, WIN)
		_windows(lo + 0.8, hi - 0.8, 6.6, 8.6, 5, WIN)
	# the main block
	_poly([-16, 14, 16, 14, 14.5, 18, 13, 20, -13, 20, -14.5, 18], roof)
	if _detail(1.0):
		for x in [-11.0, -7.0, 7.0, 11.0]:
			_r(x - 0.5, 15, x + 0.5, 16.8, w)
			_r(x - 0.3, 15.3, x + 0.3, 16.4, WIN)
	_r(-16, 1, 16, 14, w)
	_r(-16, 1, 16, 2, pk)
	_r(-16.2, 13.4, 16.2, 14.1, pk)
	for x in [-16.0, -10.3, 4.6, 9.6, 15.3]:
		_r(x, 2, x + 0.7, 13.4, pk)
	_windows(-15.2, 15.2, 3.2, 5.8, 12, WIN)
	_windows(-15.2, 15.2, 7.4, 10.0, 12, WIN)
	_windows(-15.2, 15.2, 11.2, 12.6, 12, WIN)
	# the middle with its gable
	_r(-5, 1, 5, 15.2, w.lightened(0.04))
	for x in [-5.0, -1.8, 1.1, 4.3]:
		_r(x, 2, x + 0.7, 15.2, pk)
	_windows(-4.2, 4.2, 7.4, 10.0, 3, WIN)
	_windows(-4.2, 4.2, 11.2, 12.6, 3, WIN)
	_poly([-1.2, 1, 1.2, 1, 1.2, 4.4] + _arc(0, 4.4, 1.2, 1.2, 0, PI, 6), Color("5a3b26"))
	_poly([-5.6, 15.2, 5.6, 15.2, 0, 19.6], pk)
	_poly([-4.4, 15.7, 4.4, 15.7, 0, 18.9], w)
	_c(0, 16.9, 0.75, LandmarkPainter.GOLD)
	_c(0, 16.9, 0.45, Color("c62a2a"))
	for x in [-5.6, 0.0, 5.6]:
		_r(x - 0.25, 19.3 if x == 0.0 else 15.2, x + 0.25, (20.6 if x == 0.0 else 16.4), Color("cfc4ae"))
