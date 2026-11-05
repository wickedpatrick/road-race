class_name LandmarksGbT3
extends RefCounted
## British landmarks of the towns between the map cities, drawn with LandmarkPainter's helpers (metres from the
## base point, y up).

const WHITE := Color("f2efe6")
const WATER := Color("4f8fc0")
const WATER_L := Color("9cc8e6")
const ROCK := Color("8f8a80")
const GRASS := Color("5d8f42")
const TREE := Color("3f6f34")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const WOOD := Color("7a5634")
const SALTIRE := Color("1f5aa6")
const BRONZE := Color("4f5a42")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"ben_nevis": _ben_nevis()
		"commando_memorial": _commando_memorial()
		"dumbarton_castle": _dumbarton_castle()
		"royal_border_bridge": _royal_border_bridge()
		"forfar_bridie": _forfar_bridie()
		"cow_and_calf": _cow_and_calf()
		"skipton_castle": _skipton_castle()
		"goole_water_towers": _goole_water_towers()
		"newmarket_racehorse": _newmarket_racehorse()
		"willow_man": _willow_man()
		"gloster_e28": _gloster_e28()
		"gwrych_castle": _gwrych_castle()
		"faringdon_folly": _faringdon_folly()
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

static func _detail(min_pm: float) -> bool:
	return LandmarkPainter._pm > min_pm

## A Scottish saltire on its pole: the pole from (x, y) up `h`, the cloth `fw` wide.
static func _saltire(x: float, y: float, h: float, fw: float) -> void:
	_l(x, y, x, y + h, Color("8a8d92"), 0.18)
	var fh := fw * 0.62
	_r(x, y + h - fh, x + fw, y + h, SALTIRE)
	_l(x, y + h - fh, x + fw, y + h, Color.WHITE, fh * 0.18)
	_l(x, y + h, x + fw, y + h - fh, Color.WHITE, fh * 0.18)

## Battlements: merlons `mw` wide every 2*mw along y from x0 to x1.
static func _crenel(x0: float, x1: float, y: float, mw: float, h: float, col: Color) -> void:
	var x := x0
	while x + mw <= x1 + 0.01:
		_r(x, y, x + mw, y + h, col)
		x += mw * 2.0

## A round tower: shaded at both sides, light in the middle, battlements on top.
static func _drum(x: float, y0: float, r: float, y1: float, col: Color) -> void:
	_r(x - r, y0, x + r, y1, col)
	_r(x - r, y0, x - r * 0.6, y1, col.darkened(0.12))
	_r(x + r * 0.6, y0, x + r, y1, col.darkened(0.18))
	_r(x - r * 0.25, y0, x + r * 0.15, y1, col.lightened(0.08))
	_r(x - r - 0.3, y1 - 0.8, x + r + 0.3, y1, col.darkened(0.08))
	_crenel(x - r - 0.3, x + r + 0.3, y1, 0.8, 1.0, col.darkened(0.08))

## A pine tree: a dark cone on a short trunk.
static func _pine(x: float, y: float, h: float) -> void:
	_r(x - 0.2, y, x + 0.2, y + h * 0.25, WOOD)
	_poly([x - h * 0.22, y + h * 0.2, x + h * 0.22, y + h * 0.2, x, y + h], TREE)
	_poly([x - h * 0.22, y + h * 0.2, x - h * 0.02, y + h * 0.2, x, y + h], TREE.lightened(0.1))

## Ben Nevis by Fort William: the biggest mountain in Britain, a huge broad grey-brown hump with snow on its top all
## spring, dark cliffs on its north face, green slopes and Loch Linnhe in front.
static func _ben_nevis() -> void:
	_r(-35, 0, 35, 2, WATER)
	if _detail(1.0):
		_r(-30, 0.7, -18, 1.0, WATER_L)
		_r(8, 1.2, 24, 1.5, WATER_L)
	# Carn Mor Dearg, the neighbour behind on the right
	_poly([6, 2, 18, 26, 24, 30, 35, 14, 35, 2], Color("7d8590"))
	# the Ben: a broad dome
	var rk := Color("8a7f72")
	_poly([-35, 2, -30, 10, -22, 22, -14, 32, -6, 37, 2, 38, 10, 36, 16, 30, 24, 18, 30, 2], rk)
	# the north face: dark cliffs and gullies on the right
	_poly([10, 36, 16, 30, 24, 18, 22, 14, 16, 22, 12, 30], Color("5e5750"))
	if _detail(0.8):
		for x in [13.0, 16.0, 19.0]:
			_l(x, 31 - (x - 13) * 1.4, x + 3, 22 - (x - 13) * 1.4, Color("4a4540"), 0.4)
	# the green lower slopes
	_poly([-35, 2, -30, 10, -24, 14, -14, 12, -4, 9, 8, 10, 18, 6, 30, 2], GRASS)
	_poly([-35, 2, -30, 10, -24, 14, -20, 8, -16, 2], GRASS.lightened(0.1))
	_poly([-4, 9, 8, 10, 18, 6, 22, 2, 2, 2], TREE)
	# snow on the top
	var sn := Color("f4f6f8")
	_poly([-12, 33, -6, 37, 2, 38, 10, 36, 12, 33, 8, 34, 4, 32, 0, 34, -5, 32, -8, 34], sn)
	_poly([-18, 27, -15, 31, -12, 28], sn)
	_poly([14, 31, 17, 28, 18, 30], sn)
	# the summit cairn
	_r(1.2, 38, 2.8, 39.4, Color("6a625a"))
	_saltire(4, 37.6, 2.2, 2.2)

## The Commando Memorial by Spean Bridge: three bronze commandos in their woollen caps standing on a stone plinth,
## looking out at Ben Nevis.
static func _commando_memorial() -> void:
	_r(-4.5, 0, 4.5, 0.5, GRASS)
	var st := Color("b8b3a6")
	_r(-3.4, 0.5, 3.4, 3.6, st)
	_r(-3.4, 0.5, -2.6, 3.6, st.darkened(0.1))
	_r(-3.7, 3.4, 3.7, 3.8, st.lightened(0.1))
	if _detail(2.0):
		_r(-1.6, 1.6, 1.6, 2.4, st.darkened(0.2)) # the inscription
	_commando(-1.8, 3.8, 0.9, false)
	_commando(1.8, 3.8, 0.9, false)
	_commando(0.0, 3.8, 1.0, true)

## One bronze soldier `s` times 6 m tall at (x, y): boots, a long coat, the rifle sling, a cap comforter on his head.
static func _commando(x: float, y: float, s: float, front: bool) -> void:
	var b := BRONZE if front else BRONZE.darkened(0.15)
	var h := 6.0 * s
	_r(x - 0.55 * s, y, x - 0.1 * s, y + h * 0.42, b.darkened(0.1))
	_r(x + 0.1 * s, y, x + 0.55 * s, y + h * 0.42, b.darkened(0.1))
	_poly([x - 0.8 * s, y + h * 0.38, x + 0.8 * s, y + h * 0.38, x + 0.75 * s, y + h * 0.8, x - 0.75 * s,
		y + h * 0.8], b)
	_r(x - 1.0 * s, y + h * 0.42, x - 0.72 * s, y + h * 0.78, b.darkened(0.05)) # arms
	_r(x + 0.72 * s, y + h * 0.42, x + 1.0 * s, y + h * 0.78, b.darkened(0.05))
	_l(x - 0.7 * s, y + h * 0.78, x + 0.6 * s, y + h * 0.45, b.lightened(0.15), 0.12 * s) # the sling
	_c(x, y + h * 0.88, 0.42 * s, b.lightened(0.08))
	_poly([x - 0.45 * s, y + h * 0.9, x + 0.45 * s, y + h * 0.9, x + 0.1 * s, y + h, x - 0.2 * s, y + h * 0.99],
		b.darkened(0.2)) # the cap

## Dumbarton Castle: the twin-peaked black volcanic rock over the River Clyde, the walls climbing the cleft between
## the peaks, the white Governor's House at the foot and a saltire on the higher summit.
static func _dumbarton_castle() -> void:
	_r(-28, 0, 28, 2, WATER)
	if _detail(1.0):
		_r(-24, 0.7, -12, 1.0, WATER_L)
		_r(10, 1.2, 22, 1.5, WATER_L)
	var rk := Color("4e4a48")
	# the two summits: White Tower Crag on the left, the Beak on the right
	_poly([-26, 2, -22, 14, -17, 26, -12, 31, -7, 30, -3, 22, 0, 18, 4, 20, 8, 25, 12, 26, 16, 20, 22, 10, 26, 2], rk)
	_poly([-26, 2, -22, 14, -17, 26, -12, 31, -15, 18, -18, 2], rk.lightened(0.12))
	_poly([8, 25, 12, 26, 11, 16, 7, 10, 5, 18], rk.lightened(0.1))
	_poly([-22, 2, -20, 8, -14, 6, -8, 2], GRASS)
	_poly([18, 2, 22, 10, 24, 6, 26, 2], GRASS)
	# the walls and steps in the cleft
	var w := Color("c9c0ae")
	_poly([-8, 6, -3, 16, 0, 18, 3, 16, 6, 6], w.darkened(0.12))
	_r(-5, 14, 4, 18, w)
	_crenel(-5, 4, 18, 0.9, 0.9, w)
	_r(-24, 2, 24, 6, w)
	_crenel(-24, 24, 6, 1.0, 1.0, w)
	_poly([-2.2, 2, 2.2, 2, 2.2, 3.8] + _arc(0, 3.8, 2.2, 1.6, 0, PI, 6), DARK)
	# the Governor's House
	_r(6, 6, 18, 13, WHITE)
	_poly([5.6, 13, 18.4, 13, 17, 15.6, 7, 15.6], Color("5a5f66"))
	_r(8, 15, 9, 17, Color("8a7f72"))
	_r(15, 15, 16, 17, Color("8a7f72"))
	_windows(6.5, 17.5, 10.3, 12, 5, WIN)
	_windows(6.5, 17.5, 7.2, 9, 5, WIN)
	_r(-12.6, 31, -11.4, 32, Color("6a625a"))
	_saltire(-12, 31.5, 4, 3.6)

## The Royal Border Bridge at Berwick-upon-Tweed: Robert Stephenson's long railway viaduct of tall stone arches over
## the River Tweed, a train crossing on top.
static func _royal_border_bridge() -> void:
	_r(-40, 0, 40, 3, WATER)
	if _detail(1.0):
		_r(-34, 1.0, -20, 1.3, WATER_L)
		_r(4, 1.8, 22, 2.1, WATER_L)
	_poly([-40, 0, -40, 12, -36, 10, -33, 3, -30, 0], GRASS)
	_poly([40, 0, 40, 14, 36, 12, 33, 4, 30, 0], GRASS)
	var st := Color("b49a82")
	var sd := st.darkened(0.15)
	var top := 19.0
	var span := 5.0
	var n := 15
	var x0 := -span * n * 0.5
	for k in n:
		var a := x0 + span * k
		var b := a + span
		var cx := (a + b) * 0.5
		var spring := 14.0
		var r := span * 0.5 - 0.5
		# the arch: the spandrel over the opening, then the pier under it
		_poly([a, top, b, top, b, spring] + _arc(cx, spring, r + 0.5, 3.6, 0, PI, 8), st)
		if _detail(1.0):
			_poly(_arc(cx, spring, r + 0.5, 3.6, 0, PI, 8) + _arc(cx, spring, r, 3.0, PI, 0, 8), sd)
	for k in n + 1:
		var px := x0 + span * k
		_r(px - 0.5, 0, px + 0.5, 14.5, st)
		_r(px - 0.5, 0, px - 0.2, 14.5, sd)
		if k > 0 and k < n:
			_poly([px - 0.9, 0, px + 0.9, 0, px, 2.6], sd) # the cutwater
	_r(x0 - 0.6, top, -x0 + 0.6, top + 1.0, sd)
	if _detail(1.2):
		for k in range(0, int(-x0 * 2), 2):
			_r(x0 + k, top + 1.0, x0 + k + 0.2, top + 1.8, sd)
		_r(x0, top + 1.6, -x0, top + 1.8, sd)
	# the train: a white-and-yellow express
	var tr := Color("e9ecef")
	_r(-22, top + 1.0, 4, top + 4.4, tr)
	_poly([4, top + 1.0, 7, top + 1.0, 7, top + 2.4, 4, top + 4.4], tr)
	_poly([5.8, top + 1.0, 7, top + 1.0, 7, top + 2.4, 5.8, top + 3.2], Color("f2c230"))
	_r(-22, top + 1.0, 4, top + 1.6, Color("4a4f57"))
	_r(-22, top + 2.8, 3.6, top + 3.6, Color("3a4555"))
	for x in [-13.0, -4.0]:
		_r(x - 0.1, top + 1.0, x + 0.1, top + 4.4, Color("9aa1a8"))

## A Forfar bridie: a horseshoe-shaped pastry stuffed with minced beef and onion, golden and crimped round its edge,
## fresh from the oven on a plate.
static func _forfar_bridie() -> void:
	_ell(0, 0.35, 2.9, 0.35, 0, Color("dfe3e6"))
	_ell(0, 0.42, 2.5, 0.22, 0, Color("f6f7f8"))
	var g := Color("d99a3f")
	# the D-shaped pastry, the straight crimped edge at the back
	_poly([-2.3, 0.5] + _arc(0, 0.5, 2.3, 1.9, PI, 0, 14) + [2.3, 0.5], g)
	_poly([-2.3, 0.5] + _arc(0, 0.5, 2.3, 1.9, PI, PI * 0.55, 6) + [-0.6, 0.5], g.lightened(0.15))
	_poly([-1.6, 0.5] + _arc(0, 0.5, 1.6, 1.25, PI, 0, 10) + [1.6, 0.5], g.darkened(0.12))
	_poly([-1.4, 0.5] + _arc(0, 0.5, 1.4, 1.05, PI, 0, 10) + [1.4, 0.5], g.lightened(0.05))
	# the crimps along the round edge
	for k in 9:
		var a := PI * (k + 0.5) / 9.0
		_c(cos(a) * 2.0, 0.5 + sin(a) * 1.65, 0.16, g.darkened(0.2))
	_c(0, 1.3, 0.12, Color("6b3e1c")) # the steam hole
	if _detail(1.5):
		for x in [-0.4, 0.4]:
			_l(x, 1.6, x + 0.2, 2.2, Color(1, 1, 1, 0.6), 0.08)
			_l(x + 0.2, 2.2, x - 0.1, 2.8, Color(1, 1, 1, 0.5), 0.08)

## The Cow and Calf on Ilkley Moor: a huge block of gritstone, the Cow, overhanging the edge of the purple heather
## moor, and the smaller Calf rock sitting below her.
static func _cow_and_calf() -> void:
	var heath := Color("7f5f86")
	_poly([-15, 0, -15, 7, -8, 9, 2, 9, 15, 6, 15, 0], GRASS)
	_poly([-15, 7, -8, 9, 2, 9, 4, 7, -6, 6.4, -15, 5.5], heath)
	if _detail(1.0):
		for x in [-12.0, -9.0, -5.0, -1.0]:
			_c(x, 7.2, 0.6, heath.lightened(0.15))
	var gr := Color("a39176")
	var gd := gr.darkened(0.2)
	# the Cow: a big block leaning out over the edge
	_poly([-11, 9, -10, 14, -6, 15.6, 0, 15.2, 3, 13, 2.4, 9], gr)
	_poly([2.4, 9, 3, 13, 0, 15.2, 0.4, 9.4], gd)
	_l(-10, 12, 2.8, 12, gd, 0.25)
	_poly([-11, 9, -10, 14, -9, 13, -9.6, 9], gr.lightened(0.1))
	# the old quarry face under her, falling to the lower slope
	_poly([-5, 0, -4.6, 6.4, -2, 9, 3, 9, 4.4, 5, 5, 0], Color("8c7c64"))
	_poly([3, 9, 4.4, 5, 5, 0, 3.6, 0, 3.4, 6], Color("75684f"))
	if _detail(1.0):
		_l(-4.2, 4.5, 4.4, 4.5, Color("75684f"), 0.25)
		_l(-4.6, 2.0, 4.8, 2.0, Color("75684f"), 0.25)
	# the Calf: a smaller rock, down on the slope
	_poly([5, 0, 5.4, 4.6, 8, 6.6, 12, 6.2, 13.6, 3.8, 13.4, 0], gr)
	_poly([12, 6.2, 13.6, 3.8, 13.4, 0, 11.6, 0, 11.6, 5.6], gd)
	# a sheep on the moor
	_ell(-8, 9.9, 0.9, 0.55, 0, Color("eeeae0"))
	_c(-7, 10.1, 0.3, DARK)
	_r(-8.5, 9, -8.3, 9.5, DARK)
	_r(-7.6, 9, -7.4, 9.5, DARK)

## Skipton Castle: the gatehouse between two fat round towers, the old Clifford family motto DESORMAIS ("henceforth")
## cut in big stone letters along its top, more towers of the castle behind.
static func _skipton_castle() -> void:
	_r(-24, 0, 24, 1.2, GRASS)
	var st := Color("b9ad93")
	var sd := st.darkened(0.15)
	# the castle behind
	_r(-22, 1.2, 22, 14, sd)
	_crenel(-22, 22, 14, 1.0, 1.0, sd)
	_drum(-19, 1.2, 3.2, 18, sd)
	_drum(19, 1.2, 3.2, 18, sd)
	_windows(-14, -6, 9, 11, 3, WIN)
	_windows(6, 14, 9, 11, 3, WIN)
	# the gatehouse: two drum towers and the arch between
	_r(-6, 1.2, 6, 20, st)
	_drum(-7, 1.2, 4, 22, st)
	_drum(7, 1.2, 4, 22, st)
	_poly([-2.4, 1.2, 2.4, 1.2, 2.4, 6] + _arc(0, 6, 2.4, 2.4, 0, PI, 8), DARK)
	if _detail(1.0):
		_poly([-2.0, 1.2, 2.0, 1.2, 2.0, 6] + _arc(0, 6, 2.0, 2.0, 0, PI, 8), WOOD)
		for x in [-1.2, 0.0, 1.2]:
			_l(x, 1.2, x, 7.8, WOOD.darkened(0.25), 0.12)
	_windows(-2, 2, 12, 14.5, 1, WIN)
	_windows(-8.5, -5.5, 15, 17, 1, WIN)
	_windows(5.5, 8.5, 15, 17, 1, WIN)
	# DESORMAIS: the stone letters standing on the parapet
	_r(-3.2, 20, 3.2, 21.2, st.darkened(0.08))
	var lc := st.darkened(0.08)
	for k in 9:
		var x := -2.9 + k * 0.72
		if _detail(2.0):
			_r(x, 21.2, x + 0.18, 22.6, lc)
			_r(x + 0.4, 21.2, x + 0.58, 22.6, lc)
			_r(x, 22.4, x + 0.58, 22.6, lc)
		else:
			_r(x, 21.2, x + 0.5, 22.6, lc)

## Goole's "Salt and Pepper Pots": the two water towers of the port town side by side, the old red-brick one with its
## dark iron tank and the bigger white concrete one.
static func _goole_water_towers() -> void:
	_r(-15, 0, 15, 1, GRASS)
	# Pepper: red brick, 1885
	var br := Color("a5482f")
	_r(-11, 1, -5, 30, br)
	_r(-11, 1, -9.8, 30, br.darkened(0.15))
	_r(-6.2, 1, -5, 30, br.darkened(0.25))
	if _detail(1.0):
		for y in [8.0, 16.0, 24.0]:
			_r(-11.3, y, -4.7, y + 0.5, br.lightened(0.12))
	_windows(-10, -6, 10, 13, 1, WIN)
	_windows(-10, -6, 20, 23, 1, WIN)
	_poly([-11, 30, -5, 30, -4, 31.5, -12, 31.5], br.darkened(0.1))
	var ir := Color("3d4448")
	_r(-12.5, 31.5, -3.5, 36.5, ir)
	_r(-12.5, 31.5, -11, 36.5, ir.lightened(0.15))
	if _detail(1.2):
		for x in [-10.0, -8.0, -6.0]:
			_r(x, 31.5, x + 0.2, 36.5, ir.lightened(0.25))
	_poly([-12.8, 36.5, -3.2, 36.5, -8, 39], Color("5a6064"))
	_r(-8.2, 39, -7.8, 40, Color("5a6064"))
	# Salt: white concrete, 1927, the bigger one
	var wh := Color("ecebe5")
	var wd := wh.darkened(0.12)
	_poly([-1, 1, 11, 1, 10, 26, 0, 26], wh)
	_poly([-1, 1, 0.8, 1, 1.6, 26, 0, 26], wd)
	_poly([9.2, 1, 11, 1, 10, 26, 8.6, 26], wd.darkened(0.06))
	_poly([3.8, 1, 6.2, 1, 6.2, 4] + _arc(5, 4, 1.2, 1.2, 0, PI, 6), DARK)
	_windows(3.5, 6.5, 12, 15, 1, WIN)
	_poly([0, 26, 10, 26, 13.5, 29, -3.5, 29], wd)
	_r(-3.5, 29, 13.5, 37, wh)
	_r(-3.5, 29, -1.8, 37, wd)
	_r(11.8, 29, 13.5, 37, wd.darkened(0.06))
	_r(-3.8, 36.6, 13.8, 37.6, wd)
	_poly([-3.5, 37.6, 13.5, 37.6] + _arc(5, 37.6, 8.5, 3.6, 0, PI, 10), wh.darkened(0.04))
	_r(4.6, 41, 5.4, 42, wd)

## A Newmarket racehorse: Newmarket is the home of horse racing; a bay horse gallops along the white rails with its
## jockey in bright silks.
static func _newmarket_racehorse() -> void:
	_r(-4.5, 0, 4.5, 0.6, GRASS)
	if _detail(1.0):
		_r(-4.5, 0.6, 4.5, 0.75, GRASS.lightened(0.15))
	# the white rails behind
	for x in [-4.0, -1.0, 2.0]:
		_r(x, 0.6, x + 0.15, 1.9, WHITE)
	_r(-4.5, 1.7, 4.5, 1.9, WHITE)
	var hb := Color("7a4126")
	var hd := hb.darkened(0.3)
	# legs at full gallop
	_l(-1.6, 2.3, -3.3, 1.0, hd, 0.3)
	_l(-3.3, 1.0, -3.6, 0.7, DARK, 0.3)
	_l(-1.2, 2.3, -2.2, 0.9, hb, 0.3)
	_l(-2.2, 0.9, -2.0, 0.6, DARK, 0.3)
	_l(1.6, 2.4, 2.8, 1.2, hd, 0.3)
	_l(2.8, 1.2, 3.6, 1.3, DARK, 0.3)
	_l(1.2, 2.4, 1.5, 1.0, hb, 0.3)
	_l(1.5, 1.0, 2.0, 0.8, DARK, 0.3)
	# body, neck and head
	_ell(0, 2.7, 2.2, 0.85, 0.05, hb)
	_poly([1.4, 2.6, 2.2, 3.7, 2.9, 4.0, 3.2, 3.6, 2.4, 2.4], hb)
	_poly([2.8, 4.1, 4.2, 3.4, 4.3, 3.0, 3.8, 2.9, 2.6, 3.4], hb)
	_poly([1.9, 3.4, 2.7, 4.2, 2.9, 4.0, 2.1, 3.1], DARK) # mane
	_c(3.3, 3.6, 0.07, DARK)
	_poly([-2.1, 3.0, -2.9, 3.1, -3.5, 2.3, -2.2, 2.6], DARK) # tail
	# the saddle cloth and the jockey crouched over the neck
	_r(-0.6, 2.9, 0.6, 3.5, WHITE)
	_poly([-0.8, 3.5, 0.2, 3.5, 1.4, 4.3, 0.6, 4.6, -0.6, 4.0], Color("e8b500"))
	_poly([-0.4, 3.5, 0.2, 3.5, 1.0, 4.0, 0.3, 4.2], Color("1d5fb8"))
	_l(-0.3, 3.5, 0.3, 2.9, Color("f2efe6"), 0.28) # white breeches
	_l(0.9, 4.2, 2.0, 3.8, Color("e8b500"), 0.18) # arm to the reins
	_c(1.25, 4.85, 0.32, Color("e9b38a"))
	_poly([0.9, 4.95, 1.65, 4.95, 1.55, 5.35, 1.0, 5.35], Color("1d5fb8")) # cap
	_r(1.55, 4.95, 1.95, 5.05, Color("1d5fb8"))

## The Willow Man by the M5 at Bridgwater: a giant striding man woven from dark willow branches, as tall as a
## four-storey house, his arms swinging as he walks.
static func _willow_man() -> void:
	_r(-4.5, 0, 4.5, 0.6, GRASS)
	_r(-1.4, 0.6, 1.4, 1.0, ROCK)
	var w := Color("5b3a22")
	var wl := w.lightened(0.2)
	# legs mid-stride
	_poly([-0.6, 6.4, 0.6, 6.4, -1.8, 1.0, -3.0, 1.0], w)
	_poly([-0.6, 6.4, 0.7, 6.4, 2.6, 1.0, 1.4, 1.0], w)
	# the body: broad shoulders, a narrower waist
	_poly([-0.9, 6.2, 0.9, 6.2, 1.6, 10.2, -1.6, 10.2], w)
	# arms swinging back and forth
	_poly([1.3, 10.0, 1.9, 9.6, 3.6, 6.6, 3.0, 6.3], w)
	_poly([-1.3, 10.0, -1.9, 9.6, -3.4, 6.8, -2.8, 6.5], w)
	_c(3.3, 6.4, 0.35, w)
	_c(-3.1, 6.6, 0.35, w)
	# the neck and head
	_r(-0.3, 10.2, 0.3, 10.8, w)
	_ell(0, 11.8, 0.85, 1.05, 0, w)
	# the weave: thin lighter strands crossing the body
	if _detail(1.2):
		for k in 6:
			var y := 6.6 + k * 0.6
			_l(-1.0 - k * 0.1, y, 1.0 + k * 0.1, y + 0.5, wl, 0.08)
			_l(-1.0 - k * 0.1, y + 0.5, 1.0 + k * 0.1, y, wl, 0.08)
		_l(-0.6, 11.2, 0.6, 12.4, wl, 0.08)
		_l(-0.6, 12.4, 0.6, 11.2, wl, 0.08)
		_l(-2.2, 1.6, -0.2, 6.0, wl, 0.08)
		_l(2.0, 1.6, 0.2, 6.0, wl, 0.08)

## The Gloster E.28/39 on the roundabout at Lutterworth: a full-size copy of Britain's first jet plane, whose engine
## Frank Whittle built here, flying on a pole: green-and-brown on top, yellow underneath.
static func _gloster_e28() -> void:
	_poly([-5, 0, -4, 0.8, 4, 0.8, 5, 0], GRASS)
	_r(-0.12, 0.8, 0.12, 2.6, Color("8a8d92"))
	var top := Color("6b6a3c")
	var yel := Color("e8c230")
	# the fuselage: a fat cigar with the round air intake at the nose
	_poly([-4.4, 3.2, -3.0, 2.7, 1.6, 2.5, 3.6, 2.9, 4.2, 3.4, 3.6, 3.9, 1.6, 4.2, -3.0, 3.8], top)
	_poly([-4.4, 3.2, -3.0, 2.7, 1.6, 2.5, 3.6, 2.9, 4.2, 3.4, 1.6, 3.2, -3.0, 3.2], yel)
	_poly([-1.0, 4.1, 1.0, 4.15, 1.6, 4.1, 1.6, 3.6, -1.0, 3.6], Color("7a5a36"))
	_ell(4.15, 3.4, 0.15, 0.42, 0, DARK)
	# the canopy
	_poly([0.4, 4.15, 0.9, 4.65, 1.8, 4.65, 2.3, 4.05], Color("9fc4dc"))
	# the tail fin with its red-white-blue stripes
	_poly([-4.2, 3.6, -3.0, 3.8, -3.4, 4.9, -4.3, 5.0], top)
	if _detail(1.5):
		_r(-4.15, 3.75, -3.95, 4.6, Color("c8102e"))
		_r(-3.95, 3.75, -3.75, 4.5, Color.WHITE)
		_r(-3.75, 3.75, -3.55, 4.4, Color("1f3f8a"))
	_poly([-4.4, 3.3, -3.2, 3.3, -3.6, 3.1, -4.5, 3.1], top.darkened(0.15)) # the tailplane
	# the wing seen edge-on, the roundel on the side
	_poly([-0.8, 3.0, 2.0, 3.0, 2.2, 3.15, -0.6, 3.25], top.darkened(0.2))
	_c(-1.8, 3.35, 0.42, yel)
	_c(-1.8, 3.35, 0.34, Color("1f3f8a"))
	_c(-1.8, 3.35, 0.16, Color("c8102e"))
	# the wheels down
	_l(1.4, 2.5, 1.4, 2.1, DARK, 0.1)
	_c(1.4, 2.0, 0.18, DARK)
	_l(3.4, 2.9, 3.5, 2.4, DARK, 0.08)
	_c(3.5, 2.3, 0.14, DARK)

## Gwrych Castle above Abergele: a fairy-tale castle with a long grey wall full of towers and battlements stepping up
## a wooded hillside, built 200 years ago just for show.
static func _gwrych_castle() -> void:
	_poly([-35, 0, -35, 6, -20, 12, -5, 18, 10, 24, 25, 28, 35, 30, 35, 0], TREE)
	_poly([-35, 0, -35, 6, -20, 12, -15, 8, -20, 3, -28, 0], TREE.lightened(0.1))
	_r(-35, 0, 35, 1.5, GRASS)
	var st := Color("a8a59c")
	var sd := st.darkened(0.15)
	# the long wall stepping up the hill
	var steps := [[-33.0, -22.0, 4.0], [-22.0, -10.0, 8.0], [-10.0, 2.0, 12.0], [2.0, 14.0, 16.0], [14.0, 26.0, 20.0]]
	for s in steps:
		_r(s[0], 1.5, s[1], s[2], sd)
		_crenel(s[0], s[1], s[2], 0.8, 0.8, sd)
	# towers along it
	for t in [[-30.0, 2.0, 7.5], [-21.0, 2.5, 11.5], [-12.0, 2.0, 12.0], [-2.0, 3.0, 17.0], [8.0, 2.5, 20.0],
			[20.0, 2.5, 24.0]]:
		_r(t[0] - t[1], 1.5, t[0] + t[1], t[2], st)
		_r(t[0] - t[1], 1.5, t[0] - t[1] + 0.6, t[2], sd)
		_r(t[0] - t[1] - 0.3, t[2] - 0.6, t[0] + t[1] + 0.3, t[2], sd)
		_crenel(t[0] - t[1] - 0.3, t[0] + t[1] + 0.3, t[2], 0.7, 0.9, st)
		_poly([t[0] - 0.4, t[2] - 4.0, t[0] + 0.4, t[2] - 4.0, t[0] + 0.4, t[2] - 2.6] + _arc(t[0], t[2] - 2.6, 0.4,
			0.4, 0, PI, 4), WIN)
	# the big house in the middle with its tall tower
	_r(-8, 1.5, 6, 16, st)
	_crenel(-8, 6, 16, 0.8, 0.9, st)
	_windows(-7.5, 5.5, 11, 13.5, 5, WIN)
	_windows(-7.5, 5.5, 6, 8.5, 5, WIN)
	_poly([-1.6, 1.5, 1.6, 1.5, 1.6, 3.8] + _arc(0, 3.8, 1.6, 1.4, 0, PI, 6), DARK)
	_r(24, 1.5, 30, 29, st)
	_r(24, 1.5, 25, 29, sd)
	_r(23.7, 28.2, 30.3, 29, sd)
	_crenel(23.7, 30.3, 29, 0.8, 1.0, st)
	_windows(25, 29, 22, 25, 2, WIN)
	_windows(25, 29, 14, 17, 2, WIN)
	_l(27, 30, 27, 32, Color("8a8d92"), 0.15)
	# the Welsh flag: white over green, the red dragon in a dot
	_r(27, 30.6, 29.6, 31.3, Color.WHITE)
	_r(27, 30, 29.6, 30.6, Color("2e8b3a"))
	if _detail(1.0):
		_c(28.3, 30.65, 0.35, Color("c8102e"))

## Faringdon Folly: a tall brick tower on a hill of pine trees, with a lookout room of big Gothic windows and
## battlements at the top; its builder, Lord Berners, dyed the doves around his house in rainbow colours.
static func _faringdon_folly() -> void:
	_poly([-8, 0, -8, 3, -4, 5, 4, 5, 8, 3, 8, 0], GRASS)
	var br := Color("b0603f")
	var bd := br.darkened(0.15)
	# the tower
	_r(-2.5, 4, 2.5, 26, br)
	_r(-2.5, 4, -1.6, 26, bd)
	_r(1.8, 4, 2.5, 26, bd.darkened(0.08))
	_windows(-1.2, 1.2, 12, 14, 1, WIN)
	_windows(-1.2, 1.2, 19, 21, 1, WIN)
	# the lookout room, a bit wider
	_r(-3.2, 25.6, 3.2, 26.2, Color("d8cfc0"))
	_r(-3, 26.2, 3, 30.4, br)
	for x in [-1.6, 0.0, 1.6]:
		_poly([x - 0.55, 26.8, x + 0.55, 26.8, x + 0.55, 28.6, x, 29.6, x - 0.55, 28.6], WIN)
	_r(-3.3, 30.4, 3.3, 31.0, Color("d8cfc0"))
	_crenel(-3.3, 3.3, 31.0, 0.75, 0.9, br)
	_l(0, 31.9, 0, 33.6, Color("8a8d92"), 0.12)
	_poly([0, 33.6, 1.4, 33.2, 0, 32.8], Color("c8102e"))
	# the pine clump hiding the bottom
	for p in [[-6.5, 2.4, 11.0], [-4.0, 3.5, 13.0], [4.2, 3.5, 12.5], [6.6, 2.4, 10.0], [-1.0, 4.0, 9.0], [1.6, 4.0, 8.0]]:
		_pine(p[0], p[1], p[2])
	# the rainbow doves
	var dv := [[-6.0, 22.0, "f28bb3"], [5.5, 25.0, "7fc4f0"], [-5.0, 29.0, "9be08a"], [6.0, 18.5, "f5d04a"],
		[-6.5, 16.0, "c39af0"]]
	for d in dv:
		var c := Color(d[2])
		_ell(d[0], d[1], 0.9, 0.45, 0, c)
		_c(d[0] + 0.8, d[1] + 0.25, 0.32, c)
		_poly([d[0] - 0.9, d[1], d[0] - 1.4, d[1] - 0.25, d[0] - 1.4, d[1] + 0.3], c)
		_poly([d[0] - 0.5, d[1] + 0.15, d[0] + 0.4, d[1] + 0.15, d[0] - 0.6, d[1] + 1.4], c.darkened(0.15))
