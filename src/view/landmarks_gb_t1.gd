class_name LandmarksGbT1
extends RefCounted
## British landmarks of the towns between the map cities, drawn with LandmarkPainter's helpers (metres from the
## base point, x right, y up).

const WHITE := Color("f2efe6")
const WATER := Color("4f8fc0")
const WATER_L := Color("9cc8e6")
const GRASS := Color("5d8f42")
const TREE := Color("3f6f34")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const WOOD := Color("7a5634")
const SLATE := Color("4f5660")
const BRASS := Color("d8b14a")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"jack_and_jill_windmills": _jack_and_jill_windmills()
		"portchester_castle": _portchester_castle()
		"new_forest_ponies": _new_forest_ponies()
		"bekonscot_model_village": _bekonscot_model_village()
		"banbury_cross": _banbury_cross()
		"harborough_grammar_school": _harborough_grammar_school()
		"caban_coch_dam": _caban_coch_dam()
		"double_fairlie": _double_fairlie()
		"lichfield_cathedral": _lichfield_cathedral()
		"victoria_tower_castle_hill": _victoria_tower_castle_hill()
		"locomotion_no1": _locomotion_no1()
		"loch_leven_castle": _loch_leven_castle()
		"elgin_cathedral": _elgin_cathedral()
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

## A rounded tree crown on a trunk.
static func _tree(x: float, y: float, r: float) -> void:
	_r(x - r * 0.12, y, x + r * 0.12, y + r, WOOD)
	_c(x, y + r * 1.4, r, TREE)
	_c(x - r * 0.35, y + r * 1.6, r * 0.55, TREE.lightened(0.1))

## Four windmill sails crossing at (x, y), turned by `a`, each `ln` long: a lattice of white bars on a dark stock.
static func _sails(x: float, y: float, ln: float, a: float) -> void:
	for k in 4:
		var t := a + k * PI * 0.5
		var d := Vector2(cos(t), sin(t))
		var n := Vector2(-d.y, d.x)
		var p0 := Vector2(x, y) + d * ln * 0.18
		var p1 := Vector2(x, y) + d * ln
		_l(x, y, p1.x, p1.y, DARK, 0.35)
		var q0 := p0 + n * ln * 0.2
		var q1 := p1 + n * ln * 0.2
		_poly([p0.x, p0.y, p1.x, p1.y, q1.x, q1.y, q0.x, q0.y], Color("ebe6da"))
		if _detail(1.4):
			for j in 4:
				var f := 0.25 + j * 0.25
				var a0 := p0.lerp(p1, f)
				var a1 := q0.lerp(q1, f)
				_l(a0.x, a0.y, a1.x, a1.y, Color("8a8070"), 0.12)
	_c(x, y, 0.5, DARK)

## Jack and Jill above Pyecombe: on the green South Downs, Jack, a black brick tower mill with a white cap, and Jill,
## a white wooden post mill on its trestle, both with four sails.
static func _jack_and_jill_windmills() -> void:
	_poly([-15, 0, -15, 2.5, -6, 4, 4, 4.5, 15, 3, 15, 0], GRASS)
	_poly([-15, 0, -15, 2.5, -8, 3.5, -2, 0], GRASS.lightened(0.08))
	# Jack: a tapering black tower with a white boat-shaped cap
	var jx := -7.0
	_poly([jx - 3, 3.8, jx + 3, 3.8, jx + 2.1, 13, jx - 2.1, 13], Color("26282c"))
	_poly([jx - 3, 3.8, jx - 1.8, 3.8, jx - 1.2, 13, jx - 2.1, 13], Color("3a3d42"))
	_r(jx - 0.7, 3.8, jx + 0.7, 6, Color("5a4030"))
	_windows(jx - 1.2, jx + 1.2, 8.5, 9.8, 1, Color("cfd6dd"))
	_poly([jx - 2.6, 13, jx + 2.6, 13, jx + 1.8, 14.6, jx - 1.8, 14.6], WHITE)
	_r(jx - 0.15, 14.6, jx + 0.15, 15.4, WHITE)
	_sails(jx, 13.6, 6, 0.5)
	# Jill: a white post mill, the body up on a brick roundhouse and its tail pole
	var lx := 7.0
	_r(lx - 2.2, 4.4, lx + 2.2, 7, Color("a8553e"))
	_poly([lx - 2.4, 7, lx + 2.4, 7, lx, 8], Color("5a5a5a"))
	_r(lx - 2.6, 8, lx + 2.6, 13, WHITE)
	_r(lx + 1.8, 8, lx + 2.6, 13, WHITE.darkened(0.1))
	_poly([lx - 2.8, 13, lx + 2.8, 13, lx + 2.2, 14.4, lx - 2.2, 14.4], WHITE.darkened(0.06))
	_windows(lx - 1.5, lx + 1.5, 10, 11.4, 1, WIN)
	_l(lx + 2.6, 8.5, lx + 6, 4.4, WOOD, 0.3)
	_sails(lx, 12.2, 5.6, 1.1)

## Portchester Castle by Fareham: the square stone walls the Romans built by the harbour, with round bastions, and the
## tall Norman keep standing in the corner, the water of Portsmouth Harbour in front.
static func _portchester_castle() -> void:
	_r(-30, 0, 30, 2, WATER)
	if _detail(1.0):
		_r(-24, 0.7, -12, 1.0, WATER_L)
		_r(6, 1.2, 20, 1.5, WATER_L)
	_r(-30, 2, 30, 3.5, GRASS)
	var st := Color("c9c0aa")
	var sd := st.darkened(0.15)
	# the long Roman wall with its half-round bastions
	_r(-28, 3.5, 28, 10, sd)
	for x in [-26.0, -13.0, 0.0, 13.0, 26.0]:
		_r(x - 1.8, 3.5, x + 1.8, 10.6, st)
		_r(x - 1.8, 3.5, x - 1.1, 10.6, st.lightened(0.08))
	if _detail(1.2):
		for x in range(-28, 28, 3):
			_l(x, 6.5, x + 2.4, 6.5, sd.darkened(0.12), 0.2)
	# the Norman keep, tall and square, with a stair turret
	_r(-22, 3.5, -8, 23, st)
	_r(-22, 3.5, -20, 23, st.lightened(0.08))
	_r(-11, 3.5, -8, 23, sd)
	for x in range(-22, -7, 2):
		_r(x, 23, x + 1, 24, st)
	_r(-9, 3.5, -6, 22, sd)
	for y in [8.0, 13.0, 18.0]:
		_poly([-17.3, y, -16.3, y, -16.3, y + 1.6] + _arc(-16.8, y + 1.6, 0.5, 0.5, 0, PI, 4), WIN)
		_poly([-13.3, y, -12.3, y, -12.3, y + 1.6] + _arc(-12.8, y + 1.6, 0.5, 0.5, 0, PI, 4), WIN)
	# the gatehouse in the wall and the priory church behind on the right
	_r(5, 10, 21, 13, sd.darkened(0.05))
	_poly([5, 13, 21, 13, 19, 15, 7, 15], Color("6a5f55"))
	_r(18, 10, 21, 17, st)
	_poly([18, 17, 21, 17, 19.5, 18.5], Color("6a5f55"))
	_poly([-2.2, 3.5, 2.2, 3.5, 2.2, 6.5] + _arc(0, 6.5, 2.2, 2.2, 0, PI, 6), DARK)

## Two New Forest ponies grazing by Lyndhurst: a bay mare and her little foal under an oak, on the open heath.
static func _new_forest_ponies() -> void:
	_r(-5, 0, 5, 0.4, GRASS)
	_poly([-5, 0.4, -4.4, 0.75, -1.6, 0.7, -1.0, 0.4], Color("8a6a9a")) # a bit of heather
	_tree(-3.6, 0.3, 1.2)
	_pony(0.6, 0.4, 1.0, Color("7a4a2a"), true)
	_pony(3.8, 0.4, 0.62, Color("9a6438"), false)

## A pony facing left at (x, y), scaled by s; `grazing` puts its head down to the grass.
static func _pony(x: float, y: float, s: float, col: Color, grazing: bool) -> void:
	var dk := col.darkened(0.3)
	var leg := 0.75 * s
	for lx in [-0.85, -0.55, 0.55, 0.85]:
		_r(x + lx * s - 0.09 * s, y, x + lx * s + 0.09 * s, y + leg, dk if absf(lx) < 0.7 else col)
		_r(x + lx * s - 0.1 * s, y, x + lx * s + 0.1 * s, y + 0.1 * s, DARK)
	_ell(x, y + leg + 0.32 * s, 1.05 * s, 0.42 * s, 0, col)
	# tail
	_poly([x + 0.95 * s, y + leg + 0.5 * s, x + 1.25 * s, y + leg + 0.1 * s, x + 1.2 * s, y + leg - 0.35 * s,
		x + 1.05 * s, y + leg + 0.3 * s], DARK)
	if grazing:
		_poly([x - 0.7 * s, y + leg + 0.55 * s, x - 0.95 * s, y + leg + 0.2 * s, x - 1.45 * s, y + 0.3 * s,
			x - 1.25 * s, y + 0.25 * s, x - 0.6 * s, y + leg + 0.1 * s], col)
		_ell(x - 1.45 * s, y + 0.25 * s, 0.28 * s, 0.17 * s, -1.0, col.darkened(0.08))
		_poly([x - 0.7 * s, y + leg + 0.6 * s, x - 1.0 * s, y + leg + 0.25 * s, x - 0.9 * s, y + leg + 0.15 * s,
			x - 0.6 * s, y + leg + 0.45 * s], DARK)
	else:
		_poly([x - 0.7 * s, y + leg + 0.5 * s, x - 0.95 * s, y + leg + 1.25 * s, x - 0.7 * s, y + leg + 1.35 * s,
			x - 0.45 * s, y + leg + 0.3 * s], col)
		_ell(x - 1.1 * s, y + leg + 1.15 * s, 0.33 * s, 0.17 * s, -0.4, col.darkened(0.05))
		_poly([x - 0.75 * s, y + leg + 1.4 * s, x - 0.65 * s, y + leg + 1.62 * s, x - 0.6 * s, y + leg + 1.35 * s], col)
		_poly([x - 0.62 * s, y + leg + 1.3 * s, x - 0.4 * s, y + leg + 0.5 * s, x - 0.5 * s, y + leg + 0.45 * s,
			x - 0.72 * s, y + leg + 1.1 * s], DARK)
		_c(x - 1.0 * s, y + leg + 1.22 * s, 0.05 * s, DARK)

## Bekonscot in Beaconsfield, the oldest model village in the world: a lawn of tiny Tudor houses, a church with a
## spire, a windmill and a little train running round, all knee-high.
static func _bekonscot_model_village() -> void:
	_r(-12, 0, 12, 0.6, GRASS)
	_r(-12, 0.6, 12, 0.75, Color("8a8070"))
	# the track and the little train on it
	_r(-12, 0.75, 12, 0.85, DARK)
	_r(-7, 0.85, -4.6, 2.0, Color("2a5a3a"))
	_r(-5.4, 2.0, -4.6, 2.6, Color("2a5a3a"))
	_r(-6.8, 2.0, -6.4, 2.5, DARK)
	_r(-4.4, 0.95, -1.8, 2.0, Color("8b3a2b"))
	_r(-1.6, 0.95, 1.0, 2.0, Color("c9a05a"))
	for x in [-6.6, -5.2, -4.0, -2.2, -1.2, 0.6]:
		_c(x, 0.95, 0.18, DARK)
	_r(-12, 2.6, 12, 3.0, GRASS.lightened(0.05))
	# little houses: white walls with black beams, red roofs
	var xs := [-11.0, -8.0, 3.5, 7.0]
	for k in xs.size():
		var x: float = xs[k]
		var h := 1.4 + (k % 2) * 0.4
		_r(x, 3.0, x + 2.6, 3.0 + h, WHITE)
		if _detail(1.0):
			_l(x + 0.9, 3.0, x + 0.9, 3.0 + h, DARK, 0.1)
			_l(x + 1.7, 3.0, x + 1.7, 3.0 + h, DARK, 0.1)
			_l(x, 3.0 + h * 0.5, x + 2.6, 3.0 + h * 0.5, DARK, 0.1)
		_poly([x - 0.2, 3.0 + h, x + 2.8, 3.0 + h, x + 1.3, 4.4 + h], Color("b5432e") if k % 2 == 0 else Color("6a5040"))
	# the church with its spire
	_r(-4.5, 3.0, 0.5, 5.0, Color("c9c0aa"))
	_poly([-4.7, 5.0, 0.7, 5.0, -2.0, 6.2], SLATE)
	_r(0.5, 3.0, 2.0, 6.5, Color("c9c0aa"))
	_poly([0.4, 6.5, 2.1, 6.5, 1.25, 9.0], SLATE)
	# a little windmill
	_poly([10.0, 3.0, 11.6, 3.0, 11.3, 5.5, 10.3, 5.5], WHITE)
	_sails(10.8, 5.6, 1.6, 0.3)

## Banbury Cross: the tall stone Gothic cross on its steps, and next to it the bronze Fine Lady on her white horse
## from the nursery rhyme, with rings on her fingers and bells on her toes.
static func _banbury_cross() -> void:
	_r(-8, 0, 8, 0.4, Color("8a8a84"))
	var st := Color("d8c9a0")
	var sd := st.darkened(0.15)
	var x := -3.0
	_r(x - 2.6, 0.4, x + 2.6, 1.0, sd)
	_r(x - 2.2, 1.0, x + 2.2, 1.6, st)
	# the base with pointed arches, then slimmer stages up to the spire
	_r(x - 1.7, 1.6, x + 1.7, 6.0, st)
	_r(x - 1.7, 1.6, x - 1.2, 6.0, st.lightened(0.08))
	_poly([x - 0.6, 2.2, x + 0.6, 2.2, x + 0.6, 4.4, x, 5.2, x - 0.6, 4.4], sd.darkened(0.2))
	_r(x - 1.9, 6.0, x + 1.9, 6.5, sd)
	_r(x - 1.2, 6.5, x + 1.2, 9.5, st)
	_poly([x - 0.4, 7.0, x + 0.4, 7.0, x + 0.4, 8.5, x, 9.0, x - 0.4, 8.5], sd.darkened(0.2))
	_r(x - 1.4, 9.5, x + 1.4, 9.9, sd)
	_poly([x - 0.9, 9.9, x + 0.9, 9.9, x + 0.2, 14.5, x - 0.2, 14.5], st)
	for p in [-1.4, 1.4]:
		_poly([x + p - 0.25, 6.5, x + p + 0.25, 6.5, x + p, 8.0], st)
		_poly([x + p * 0.75 - 0.2, 9.9, x + p * 0.75 + 0.2, 9.9, x + p * 0.75, 11.2], st)
	_l(x, 14.5, x, 15.0, BRASS, 0.15)
	_l(x - 0.3, 14.85, x + 0.3, 14.85, BRASS, 0.12)
	# the Fine Lady on her horse, on a stone plinth
	var hx := 4.6
	_r(hx - 2.4, 0.4, hx + 2.4, 1.6, Color("b9b4a8"))
	var hc := Color("eeeae0")
	var hy := 1.6
	for lx in [-1.4, -1.0, 1.0, 1.4]:
		_r(hx + lx - 0.13, hy, hx + lx + 0.13, hy + 1.4, hc.darkened(0.12) if absf(lx) < 1.2 else hc)
	_ell(hx, hy + 1.85, 1.75, 0.65, 0, hc)
	_poly([hx - 1.4, hy + 2.2, hx - 2.0, hy + 3.6, hx - 1.6, hy + 3.7, hx - 1.0, hy + 2.3], hc)
	_ell(hx - 2.2, hy + 3.4, 0.55, 0.28, -0.5, hc)
	_poly([hx + 1.6, hy + 2.2, hx + 2.1, hy + 1.0, hx + 1.9, hy + 1.0, hx + 1.4, hy + 1.8], Color("cfc8b8"))
	# the lady: a flowing bronze dress, hat and a raised hand
	var br := Color("6e5a3a")
	_poly([hx - 0.6, hy + 2.5, hx + 0.8, hy + 2.5, hx + 0.5, hy + 1.1, hx, hy + 1.0], br)
	_poly([hx - 0.3, hy + 2.4, hx + 0.4, hy + 2.4, hx + 0.3, hy + 3.9, hx - 0.2, hy + 3.9], br)
	_c(hx + 0.05, hy + 4.3, 0.33, br.lightened(0.15))
	_poly([hx - 0.5, hy + 4.5, hx + 0.6, hy + 4.5, hx + 0.05, hy + 4.8], br.darkened(0.2))
	_l(hx + 0.2, hy + 3.6, hx + 0.9, hy + 4.4, br, 0.18)
	if _detail(1.6):
		_c(hx + 0.95, hy + 4.45, 0.1, BRASS) # a ring on her finger
		_c(hx + 0.15, hy + 1.0, 0.1, BRASS) # a bell on her toes

## The Old Grammar School in Market Harborough (1614): a little timber-framed school standing on wooden posts over
## the open market place, and the tall stone spire of St Dionysius right behind it.
static func _harborough_grammar_school() -> void:
	_r(-12, 0, 12, 0.5, Color("8a8a84"))
	var st := Color("c8b48a")
	var sd := st.darkened(0.15)
	# the church tower and its broach spire
	_r(-2, 0.5, 4, 14, st)
	_r(-2, 0.5, -1, 14, st.lightened(0.08))
	_r(-2.3, 13.4, 4.3, 14.2, sd)
	_poly([0.5, 15, 1.5, 15, 1.5, 16.3] + _arc(1, 16.3, 0.5, 0.5, 0, PI, 4), WIN)
	_poly([-2, 14.2, 4, 14.2, 1.3, 32], st)
	_poly([-2, 14.2, 0.2, 14.2, 1.3, 32], st.lightened(0.08))
	_poly([-2, 14.2, -1.2, 14.2, -1.6, 16.2], sd)
	_poly([4, 14.2, 3.2, 14.2, 3.6, 16.2], sd)
	_l(1.3, 32, 1.3, 33, BRASS, 0.15)
	# the church nave to the right
	_r(4, 0.5, 12, 8, sd)
	_r(4, 8, 12, 8.6, st)
	_windows(5, 11.5, 3, 6.5, 3, WIN)
	# the school on its posts: open underneath, a black-and-white upper floor, a tiled roof with dormers
	var wh := Color("f0e8d6")
	var bk := Color("2e2620")
	_r(-11, 3.4, -1, 3.8, bk)
	for x in [-10.6, -8.2, -5.8, -3.4, -1.4]:
		_r(x - 0.2, 0.5, x + 0.2, 3.4, Color("4a3a2c"))
	_r(-11, 3.8, -1, 7.4, wh)
	for x in [-11.0, -8.6, -6.2, -3.8, -1.4]:
		_r(x, 3.8, x + 0.35, 7.4, bk)
	_r(-11, 5.5, -1, 5.8, bk)
	if _detail(1.0):
		for x in [-10.0, -7.6, -5.2, -2.8]:
			_l(x - 0.5, 3.9, x + 0.5, 5.4, bk, 0.15)
			_l(x + 0.5, 3.9, x - 0.5, 5.4, bk, 0.15)
	_windows(-10.6, -1.4, 6.0, 7.0, 4, WIN)
	_poly([-11.6, 7.4, -0.4, 7.4, -3, 10.2, -9, 10.2], Color("8a4a36"))
	_r(-7.2, 8.0, -4.8, 9.2, wh)
	_poly([-7.5, 9.2, -4.5, 9.2, -6, 10.4], Color("8a4a36"))

## Caban Coch dam in the Elan Valley near Rhayader: a high curved wall of stone blocks with water pouring over it in
## a white curtain, a reservoir behind and green Welsh hills either side.
static func _caban_coch_dam() -> void:
	_poly([-35, 0, -35, 26, -28, 30, -18, 24, -16, 0], GRASS.darkened(0.1))
	_poly([35, 0, 35, 25, 26, 29, 18, 23, 16, 0], GRASS.darkened(0.1))
	_poly([-35, 26, -28, 30, -24, 27, -30, 22], GRASS)
	_poly([-35, 0, -16, 0, -17, 14, -22, 18, -28, 12, -35, 9], TREE)
	_poly([35, 0, 16, 0, 17, 13, 22, 17, 28, 11, 35, 8], TREE)
	# the reservoir showing over the top of the dam
	_r(-18, 21, 18, 22.5, WATER)
	var st := Color("9c958a")
	var sd := st.darkened(0.15)
	_poly([-19, 0, 19, 0, 18, 21, -18, 21], st)
	if _detail(1.0):
		for y in range(3, 21, 3):
			_l(-18.8 + y * 0.05, y, 18.8 - y * 0.05, y, sd, 0.18)
	# the white water spilling over the whole width, with a pool at the foot
	_poly([-15, 21, 15, 21, 15.5, 19, 15, 4, -15, 4, -15.5, 19], Color("dbe9f2"))
	if _detail(1.0):
		for x in range(-14, 15, 2):
			_l(x, 20.5, x + 0.2, 5, Color("b3d2e6"), 0.25)
	_r(-15, 20.6, 15, 21.4, Color("f7fbff"))
	_poly([-19, 0, 19, 0, 17, 4, -17, 4], Color("e8f2f8"))
	_r(-35, 0, 35, 1.2, WATER)
	# the parapet with its little arches on top
	_r(-19, 21.4, 19, 22.4, sd)
	if _detail(1.4):
		for x in range(-17, 18, 3):
			_poly([x - 0.8, 21.4, x + 0.8, 21.4] + _arc(x, 21.4, 0.8, 0.6, 0, PI, 4), sd.darkened(0.2))

## Merddin Emrys of the Ffestiniog Railway at Blaenau Ffestiniog: a little "Double Fairlie" engine with two boilers
## and two chimneys, one at each end, the crew's cab in the middle, in maroon with brass; slate heaps behind.
static func _double_fairlie() -> void:
	_poly([-6, 0, -6, 3.2, -3, 4.6, 0, 3.8, 3, 4.8, 6, 3.4, 6, 0], SLATE.lightened(0.15))
	_r(-6, 0, 6, 0.25, Color("6a6560"))
	_r(-5.8, 0.25, 5.8, 0.4, DARK)
	var body := Color("7a2630")
	# the two bogies
	for bx in [-3.0, 3.0]:
		_r(bx - 2.1, 0.5, bx + 2.1, 0.95, DARK)
		for wx in [-1.2, 0.0, 1.2]:
			_c(bx + wx, 0.6, 0.38, Color("2a2a2a"))
			_c(bx + wx, 0.6, 0.12, Color("888888"))
	_r(-5.4, 1.0, 5.4, 1.35, body.darkened(0.2))
	_r(-5.6, 1.0, -5.2, 1.5, Color("c43a2a"))
	_r(5.2, 1.0, 5.6, 1.5, Color("c43a2a"))
	# the two boilers with their smokeboxes, chimneys and domes
	for sgn in [-1.0, 1.0]:
		var x0: float = sgn * 1.1
		var x1: float = sgn * 5.0
		_r(minf(x0, x1), 1.35, maxf(x0, x1), 2.55, Color("2f4a3a"))
		_r(minf(x0, x1), 2.25, maxf(x0, x1), 2.4, Color("3f6a52"))
		_r(minf(x1, x1 - sgn * 0.8), 1.3, maxf(x1, x1 - sgn * 0.8), 2.6, DARK)
		_c(x1, 1.95, 0.6, DARK)
		var cx: float = sgn * 4.4
		_poly([cx - 0.22, 2.5, cx + 0.22, 2.5, cx + 0.35, 3.5, cx - 0.35, 3.5], DARK)
		_r(cx - 0.42, 3.5, cx + 0.42, 3.7, DARK)
		var dx: float = sgn * 2.6
		_r(dx - 0.3, 2.5, dx + 0.3, 2.95, BRASS)
		_c(dx, 2.95, 0.3, BRASS)
	# the cab in the middle
	_r(-1.1, 1.35, 1.1, 3.7, body)
	_r(-1.3, 3.7, 1.3, 3.95, DARK)
	_windows(-0.9, 0.9, 2.6, 3.3, 2, Color("e8e0c8"))
	if _detail(1.4):
		_c(-4.4, 4.2, 0.35, Color(0.9, 0.9, 0.9, 0.6))
		_c(-4.1, 4.6, 0.45, Color(0.9, 0.9, 0.9, 0.45))

## Lichfield Cathedral, "the Ladies of the Vale": the only medieval English cathedral with three spires, two on the
## west front and a taller one over the crossing, all in red sandstone.
static func _lichfield_cathedral() -> void:
	var st := Color("a85a48")
	var sd := st.darkened(0.18)
	var sl := st.lightened(0.1)
	_r(-30, 0, 30, 0.6, GRASS)
	# the long nave and choir, then the central tower and its spire
	_r(-6, 0.6, 29, 15, sd)
	_poly([-6, 15, 29, 15, 29, 16, 11, 20, -6, 16], Color("5a5a5e"))
	_windows(0, 28, 5, 11, 6, WIN)
	for x in range(-2, 29, 5):
		_r(x, 0.6, x + 0.8, 15.5, st)
	_r(7, 0.6, 15, 26, st)
	_r(7, 0.6, 8.2, 26, sl)
	_poly([9.5, 18, 12.5, 18, 12.5, 22] + _arc(11, 22, 1.5, 1.5, 0, PI, 6), WIN)
	_poly([7, 26, 15, 26, 11, 49], st)
	_poly([7, 26, 9.6, 26, 11, 49], sl)
	_l(11, 49, 11, 50, BRASS, 0.18)
	# the west front with its great window and statues, and the two spires
	_r(-24, 0.6, -6, 18, st)
	_poly([-24, 18, -6, 18, -15, 22], st)
	_poly([-17, 8, -13, 8, -13, 13] + _arc(-15, 13, 2, 2.6, 0, PI, 8), WIN)
	_poly([-16.5, 0.6, -13.5, 0.6, -13.5, 4] + _arc(-15, 4, 1.5, 2, 0, PI, 6), DARK)
	if _detail(1.4):
		for x in range(-22, -7, 2):
			_r(x, 5.5, x + 0.8, 7.0, sl)
	for x in [-24.0, -6.0]:
		_r(x - 3, 0.6, x + 3, 25, st)
		_r(x - 3, 0.6, x - 2, 25, sl)
		_poly([x - 0.8, 17, x + 0.8, 17, x + 0.8, 20] + _arc(x, 20, 0.8, 0.8, 0, PI, 4), WIN)
		_r(x - 3.3, 24.5, x + 3.3, 25.3, sd)
		_poly([x - 2.8, 25.3, x + 2.8, 25.3, x, 44], st)
		_poly([x - 2.8, 25.3, x - 0.7, 25.3, x, 44], sl)
		_l(x, 44, x, 45, BRASS, 0.15)

## Victoria Tower on Castle Hill above Huddersfield: a square stone tower with battlements and a stair turret, built
## for Queen Victoria's jubilee, on top of a high green hill.
static func _victoria_tower_castle_hill() -> void:
	_poly([-20, 0, -14, 6, -8, 10, 8, 10, 14, 6, 20, 0], GRASS)
	_poly([-20, 0, -14, 6, -10, 8.5, -6, 4, 0, 0], GRASS.lightened(0.08))
	_poly([-8, 10, -4, 9, 4, 9, 8, 10], GRASS.darkened(0.08))
	var st := Color("b9a882")
	var sd := st.darkened(0.15)
	_r(-4, 9.5, 4, 35, st)
	_r(-4, 9.5, -3, 35, st.lightened(0.08))
	_r(2.8, 9.5, 4, 35, sd)
	for y in [16.0, 24.0]:
		_r(-4.3, y, 4.3, y + 0.5, sd)
	for y in [12.0, 19.0, 27.0]:
		_poly([-0.6, y, 0.6, y, 0.6, y + 2] + _arc(0, y + 2, 0.6, 0.6, 0, PI, 4), WIN)
	_r(-4.6, 35, 4.6, 36.2, sd)
	for x in [-4.6, -2.6, -0.6, 1.4, 3.4]:
		_r(x, 36.2, x + 1.2, 37.4, st)
	# the round stair turret at one corner, a bit higher
	_r(3.6, 28, 5.8, 38, st)
	_r(5.0, 28, 5.8, 38, sd)
	for x in [3.6, 4.6]:
		_r(x, 38, x + 0.6, 38.8, st)
	_l(-2.4, 37.4, -2.4, 40, Color("8a8d92"), 0.15)
	_r(-2.4, 38.6, -0.4, 39.9, Color("1f3f8f"))
	if _detail(1.4):
		_l(-2.4, 38.6, -0.4, 39.9, Color.WHITE, 0.12)
		_l(-2.4, 39.9, -0.4, 38.6, Color.WHITE, 0.12)
		_l(-1.4, 38.6, -1.4, 39.9, Color("c8102e"), 0.18)
		_l(-2.4, 39.25, -0.4, 39.25, Color("c8102e"), 0.18)

## Locomotion No. 1 at Darlington's Head of Steam museum: the engine that pulled the first passenger train on a
## public steam railway in 1825, with its tall chimney, the cylinders and rods standing up on top of the boiler, and
## a wooden water-barrel tender behind.
static func _locomotion_no1() -> void:
	_r(-5, 0, 5, 0.25, Color("6a6560"))
	_r(-4.8, 0.25, 4.8, 0.4, DARK)
	var bo := Color("3d4a3c")
	var yl := Color("d9a634")
	# the engine on four big wheels
	for wx in [-3.3, -1.3]:
		_c(wx, 1.15, 0.75, yl)
		_c(wx, 1.15, 0.55, Color("3a3a3a"))
		_c(wx, 1.15, 0.18, yl)
		if _detail(1.0):
			for k in 4:
				var a := k * PI * 0.25
				_l(wx - cos(a) * 0.55, 1.15 - sin(a) * 0.55, wx + cos(a) * 0.55, 1.15 + sin(a) * 0.55, yl, 0.08)
	_r(-4.4, 1.6, -0.2, 3.0, bo)
	_r(-4.4, 2.7, -0.2, 3.0, bo.lightened(0.12))
	_r(-4.6, 1.5, -0.2, 1.7, WOOD)
	# the tall chimney at the front
	_r(-4.3, 3.0, -3.8, 5.2, DARK)
	_r(-4.45, 5.0, -3.65, 5.25, DARK)
	# the two upright cylinders with the crossheads and rods above
	for cx in [-2.9, -1.0]:
		_r(cx - 0.25, 3.0, cx + 0.25, 4.0, BRASS)
		_l(cx, 4.0, cx, 4.7, Color("8a8d92"), 0.1)
		_l(cx - 0.6, 4.7, cx + 0.6, 4.7, Color("8a8d92"), 0.12)
		_l(cx - 0.6, 4.7, cx - 0.6, 1.4, Color("8a8d92"), 0.08)
	# the tender: a wooden wagon carrying a big water barrel
	_c(1.2, 0.85, 0.45, yl)
	_c(3.6, 0.85, 0.45, yl)
	_r(0.3, 1.25, 4.5, 1.65, WOOD)
	_ell(2.4, 2.4, 1.9, 0.8, 0, Color("8a6038"))
	if _detail(1.2):
		for bx in [1.1, 2.4, 3.7]:
			_l(bx, 1.65, bx, 3.15, DARK, 0.08)
	_l(-0.2, 1.5, 0.3, 1.5, DARK, 0.12)
	if _detail(1.4):
		_c(-4.0, 5.7, 0.4, Color(0.9, 0.9, 0.9, 0.6))
		_c(-3.6, 6.2, 0.5, Color(0.9, 0.9, 0.9, 0.45))

## Loch Leven Castle by Kinross: a grey stone tower house and its curtain wall on a little island in the loch, where
## Mary, Queen of Scots was kept prisoner, with a few trees and the hills behind.
static func _loch_leven_castle() -> void:
	_poly([-25, 6, -16, 14, -6, 10, 6, 15, 16, 11, 25, 6], Color("7a9a6a"))
	_r(-25, 0, 25, 6, WATER)
	if _detail(1.0):
		_r(-22, 1.2, -14, 1.5, WATER_L)
		_r(10, 3.6, 20, 3.9, WATER_L)
		_r(-6, 0.4, 4, 0.7, WATER_L)
	_poly([-17, 4.5, -14, 6.5, 14, 6.5, 17, 4.5], GRASS)
	_tree(-13.5, 6.3, 1.6)
	_tree(13.5, 6.3, 1.8)
	var st := Color("a8a296")
	var sd := st.darkened(0.15)
	# the curtain wall round the island
	_r(-12, 6.3, 12, 10.5, sd)
	_r(-12.5, 10.5, -10, 12.5, sd)
	_poly([-12.8, 12.5, -9.7, 12.5, -11.25, 14], Color("5a5a5e"))
	# the tower house, tall and plain with few windows
	_r(-6, 6.3, 3, 21, st)
	_r(-6, 6.3, -5, 21, st.lightened(0.08))
	_r(1.8, 6.3, 3, 21, sd)
	_poly([-6.6, 21, 3.6, 21, 3.6, 21.8, -6.6, 21.8], sd)
	for x in [-6.6, -4.4, -2.2, 0.0, 2.2]:
		_r(x, 21.8, x + 1.4, 22.8, st)
	_r(-3.5, 21.8, 0.5, 24, st)
	_poly([-3.8, 24, 0.8, 24, -1.5, 25.8], Color("5a5a5e"))
	_windows(-5, 1.5, 17, 18.5, 2, WIN)
	_windows(-4, 0, 12.5, 13.8, 1, WIN)
	_r(-1.0, 6.3, 0.2, 8.2, DARK)
	# the round tower on the corner of the wall
	_r(7, 6.3, 11, 13, st)
	_r(10, 6.3, 11, 13, sd)
	_r(6.7, 13, 11.3, 13.8, sd)

## Elgin Cathedral, "the Lantern of the North": the roofless red-sandstone ruin of the west front, two tall square
## towers either side of a great arched doorway, and the empty window frame above it open to the sky.
static func _elgin_cathedral() -> void:
	_r(-22, 0, 22, 0.6, GRASS)
	var st := Color("b37a5e")
	var sd := st.darkened(0.18)
	var sl := st.lightened(0.1)
	# low ruined walls of the nave going off to the right
	_poly([8, 0.6, 22, 0.6, 22, 4, 19, 5.5, 15, 7, 11, 9, 8, 10], sd)
	for x in [12.0, 17.0]:
		_poly([x - 0.8, 2, x + 0.8, 2, x + 0.8, 4] + _arc(x, 4, 0.8, 0.8, 0, PI, 4), Color("8fb4d4"))
	# the gable wall between the towers, the doorway and the empty window
	_r(-7, 0.6, 7, 20, st)
	_poly([-7, 20, 7, 20, 5, 22.5, 1, 23, -2, 24.5, -5, 22], st)
	for k in 4:
		var w := 3.6 - k * 0.6
		_poly([-w, 0.6, w, 0.6, w, 5.5] + _arc(0, 5.5, w, w * 1.2, 0, PI, 8), sd.darkened(0.06 * k))
	_poly([-1.2, 0.6, 1.2, 0.6, 1.2, 5.5] + _arc(0, 5.5, 1.2, 1.4, 0, PI, 6), DARK)
	_poly([-3.5, 11, 3.5, 11, 3.5, 15] + _arc(0, 15, 3.5, 4.5, 0, PI, 10), Color("8fb4d4"))
	if _detail(1.2):
		_l(-1.2, 11, -1.2, 17.5, st, 0.3)
		_l(1.2, 11, 1.2, 17.5, st, 0.3)
	# the two towers, missing their spires, with ragged tops
	for x in [-10.0, 10.0]:
		_r(x - 3.5, 0.6, x + 3.5, 26, st)
		_r(x - 3.5, 0.6, x - 2.5, 26, sl)
		_r(x + 2.5, 0.6, x + 3.5, 26, sd)
		for y in [8.0, 16.0]:
			_r(x - 3.8, y, x + 3.8, y + 0.5, sd)
		_poly([x - 0.7, 18, x + 0.7, 18, x + 0.7, 21.5] + _arc(x, 21.5, 0.7, 0.8, 0, PI, 4), DARK)
		_poly([x - 0.6, 10, x + 0.6, 10, x + 0.6, 13] + _arc(x, 13, 0.6, 0.6, 0, PI, 4), DARK)
		_poly([x - 3.5, 26, x - 2, 27.5, x - 0.5, 26.8, x + 1, 28, x + 2.4, 27, x + 3.5, 27.4, x + 3.5, 26], st)
