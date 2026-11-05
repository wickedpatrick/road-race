class_name LandmarksGbT2
extends RefCounted
## British landmarks of the towns between the map cities, drawn with LandmarkPainter's helpers (metres from the
## base point, y up).

const STONE := Color("cfc6b0")
const BRICK := Color("a54a34")
const COPPER := Color("5f9e86")
const GOLD := Color("e0b43a")
const WATER := Color("4f8fc0")
const WATER_L := Color("9cc8e6")
const ROCK := Color("8f8a80")
const GRASS := Color("5d8f42")
const TREE := Color("3f6f34")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const WOOD := Color("7a5634")
const PO_RED := Color("c8201e")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"out_of_order_phoneboxes": _out_of_order_phoneboxes()
		"chichester_market_cross": _chichester_market_cross()
		"south_devon_steam_train": _south_devon_steam_train()
		"forbury_lion": _forbury_lion()
		"concrete_cows": _concrete_cows()
		"colchester_castle": _colchester_castle()
		"tees_transporter_bridge": _tees_transporter_bridge()
		"aberystwyth_cliff_railway": _aberystwyth_cliff_railway()
		"gloucester_cathedral": _gloucester_cathedral()
		"loughborough_carillon": _loughborough_carillon()
		"moffat_ram": _moffat_ram()
		"dunblane_gold_postbox": _dunblane_gold_postbox()
		"carrbridge_packhorse_bridge": _carrbridge_packhorse_bridge()
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

## A round-headed (or pointed, when `pt` > 0) dark window or doorway from (x0, y0) to (x1, y1).
static func _arch_win(x0: float, y0: float, x1: float, y1: float, col: Color, pt: float = 0.0) -> void:
	var cx := (x0 + x1) * 0.5
	var hw := (x1 - x0) * 0.5
	if pt > 0.0:
		_poly([x0, y0, x1, y0, x1, y1 - pt, cx, y1, x0, y1 - pt], col)
	else:
		_poly([x0, y0, x1, y0, x1, y1 - hw] + _arc(cx, y1 - hw, hw, hw, 0, PI, 6) + [x0, y1 - hw], col)

## A Scots pine: a bare reddish trunk and a flat dark crown.
static func _pine(x: float, y: float, h: float) -> void:
	_l(x, y, x + h * 0.03, y + h * 0.75, Color("8a4f32"), h * 0.07)
	for p in [[-0.18, 0.5, 0.2, 0.09], [0.16, 0.62, 0.22, 0.1], [-0.08, 0.76, 0.26, 0.12], [0.08, 0.9, 0.2, 0.1]]:
		_ell(x + p[0] * h, y + p[1] * h, p[2] * h, p[3] * h * 1.4, 0.0, TREE.darkened(0.12))
	for p in [[-0.2, 0.53, 0.12], [0.15, 0.66, 0.12], [-0.06, 0.82, 0.14], [0.1, 0.94, 0.1]]:
		_c(x + p[0] * h, y + p[1] * h + 0.02 * h, p[2] * h * 0.7, TREE)

## A rectangle (u0, v0)-(u1, v1) of a box that pivots on (px, 0) and leans `a` radians to the right.
static func _lean_rect(px: float, a: float, u0: float, v0: float, u1: float, v1: float, col: Color) -> void:
	var xy := []
	for p in [[u0, v0], [u1, v0], [u1, v1], [u0, v1]]:
		xy.append_array([px + p[0] * cos(a) + p[1] * sin(a), -p[0] * sin(a) + p[1] * cos(a)])
	_poly(xy, col)

## One red K6 telephone box, its bottom right corner on (px, 0), tipped `a` radians to the right.
static func _phone_box(px: float, a: float) -> void:
	_lean_rect(px, a, -1.06, 0, 0.06, 2.46, PO_RED.darkened(0.45))
	_lean_rect(px, a, -1.0, 0, 0, 2.4, PO_RED)
	_lean_rect(px, a, -1.0, 0, -0.88, 2.4, PO_RED.darkened(0.2))
	_lean_rect(px, a, -1.06, 2.4, 0.06, 2.52, PO_RED.darkened(0.15))
	_lean_rect(px, a, -0.85, 2.52, -0.15, 2.64, PO_RED.darkened(0.15))
	_lean_rect(px, a, -0.86, 2.16, -0.14, 2.32, Color("f2efe6"))
	if _detail(3.0):
		for row in 3:
			for col in 2:
				var u := -0.78 + col * 0.32
				var v := 0.8 + row * 0.42
				_lean_rect(px, a, u, v, u + 0.24, v + 0.34, Color("d8dfe2"))
	else:
		_lean_rect(px, a, -0.82, 0.75, -0.18, 2.0, Color("d8dfe2"))

## Kingston's "Out of Order": twelve old red telephone boxes toppling over one another like dominoes.
static func _out_of_order_phoneboxes() -> void:
	var w := 1.0
	var h := 2.6
	var n := 12
	var ang: Array[float] = []
	for k in n:
		ang.append(deg_to_rad(48.0 * (1.0 - float(k) / (n - 1))))
	var px: Array[float] = [0.0]
	for k in n - 1:
		px.append(px[k] + h * sin(ang[k]) + w - h * cos(ang[k]) * tan(ang[k + 1]))
	var off := -(px[n - 1] - w * cos(ang[0])) * 0.5 # centre the row
	_r(-8.5, 0, 8.5, 0.12, Color("a9a59c"))
	for k in range(n - 1, -1, -1):
		_phone_box(px[k] + off, ang[k])

## Chichester Cross: the old octagonal market cross of pale stone, open pointed arches, buttresses with pinnacles,
## a clock above and the stone crown of flying ribs on top.
static func _chichester_market_cross() -> void:
	var st := Color("d6ccae")
	var sd := st.darkened(0.15)
	_r(-6, 0, 6, 0.5, Color("b9b2a0"))
	_r(-5.2, 0.5, 5.2, 1.0, Color("c6bfac"))
	# the octagon: the front face light, the slanting faces darker
	_r(-4.2, 1, -2, 7.6, sd)
	_r(2, 1, 4.2, 7.6, sd)
	_r(-2, 1, 2, 7.6, st)
	_arch_win(-1.3, 1, 1.3, 6.4, DARK, 1.4)
	_arch_win(-3.6, 1, -2.5, 5.8, DARK.lightened(0.05), 0.9)
	_arch_win(2.5, 1, 3.6, 5.8, DARK.lightened(0.05), 0.9)
	# the buttresses with their pinnacles
	for x in [-4.4, -2.0, 2.0, 4.4]:
		_r(x - 0.35, 1, x + 0.35, 8.6, st.lightened(0.05))
		_poly([x - 0.4, 8.6, x + 0.4, 8.6, x, 10.4], st.lightened(0.05))
	# the openwork parapet
	_r(-4.4, 7.6, 4.4, 8.4, st)
	if _detail(4.0):
		for k in 8:
			_c(-3.5 + k * 1.0, 8.0, 0.25, sd.darkened(0.2))
	# the clock stage
	_r(-2.2, 8.4, 2.2, 11.2, st)
	_r(-2.2, 8.4, -1.6, 11.2, sd)
	_c(0, 9.8, 1.0, Color("e9e4d6"))
	_c(0, 9.8, 0.85, Color("2b3a5c"))
	_l(0, 9.8, 0, 10.4, GOLD, 0.12)
	_l(0, 9.8, 0.4, 9.6, GOLD, 0.12)
	_r(-2.4, 11.0, 2.4, 11.4, sd)
	# the crown: ribs flying up to the lantern
	_pl([-2.1, 11.4, -1.6, 12.6, -0.6, 13.3, 0, 13.4], st, 0.3)
	_pl([2.1, 11.4, 1.6, 12.6, 0.6, 13.3, 0, 13.4], st, 0.3)
	_l(0, 11.4, 0, 13.4, st, 0.3)
	for x in [-2.2, 2.2]:
		_poly([x - 0.25, 11.4, x + 0.25, 11.4, x, 12.4], st)
	_r(-0.45, 13.2, 0.45, 14.0, st)
	_poly([-0.5, 14.0, 0.5, 14.0, 0, 14.7], sd)
	_l(0, 14.7, 0, 15, GOLD, 0.1)

## A steam train on the South Devon Railway: a Great Western green tank engine with a copper-capped chimney and a
## brass safety valve, pulling a chocolate-and-cream carriage, a puff of steam above.
static func _south_devon_steam_train() -> void:
	var gw := Color("2e6b3f")
	var blk := Color("22262a")
	_r(-11, 0, 11, 0.16, Color("6a6560"))
	if _detail(2.0):
		for k in 22:
			_r(-10.8 + k, 0, -10.4 + k, 0.1, WOOD)
	# the carriage behind
	_r(-0.8, 0.9, 10.8, 2.4, Color("5a3a28"))
	_r(-0.8, 2.4, 10.8, 3.7, Color("ece0bd"))
	_poly([-0.9, 3.7, 10.9, 3.7, 10.4, 4.15, -0.4, 4.15], Color("8d8f8f"))
	_windows(-0.4, 10.4, 2.65, 3.45, 6, WIN)
	if _detail(2.0):
		for x in [-0.2, 3.6, 7.4]:
			_r(x + 1.0, 0.95, x + 1.5, 2.3, Color("4a2e20"))
	for x in [0.6, 1.9, 8.1, 9.4]:
		_c(x, 0.5, 0.42, blk)
		_c(x, 0.5, 0.15, Color("6a6560"))
	_l(-2.0, 1.1, -0.8, 1.1, blk, 0.15)
	# the engine
	_r(-10.7, 0.7, -1.8, 1.15, blk)
	_r(-11.0, 0.75, -10.6, 1.45, PO_RED)
	_r(-11.4, 0.95, -11.0, 1.25, blk)
	_r(-10.2, 1.15, -4.3, 2.6, gw)
	_r(-10.6, 1.15, -9.7, 2.65, blk) # smokebox
	_r(-9.5, 1.6, -4.5, 3.1, gw.lightened(0.06)) # the pannier tanks
	if _detail(2.0):
		_l(-9.5, 1.75, -4.5, 1.75, GOLD, 0.06)
		_l(-9.5, 2.95, -4.5, 2.95, GOLD, 0.06)
	_r(-10.35, 2.65, -9.95, 3.7, blk)
	_r(-10.5, 3.55, -9.8, 3.9, Color("c87533"))
	_r(-7.2, 3.1, -6.6, 3.5, GOLD)
	_poly([-7.3, 3.5, -6.5, 3.5, -6.9, 3.85], GOLD)
	_r(-4.5, 1.15, -1.9, 3.9, gw)
	_r(-4.7, 3.9, -1.7, 4.2, blk)
	_r(-3.9, 2.8, -2.8, 3.5, Color("d8dfe2"))
	for x in [-9.0, -7.3, -5.6]:
		_c(x, 0.75, 0.72, blk)
		_c(x, 0.75, 0.55, gw.darkened(0.2))
		_c(x, 0.75, 0.15, Color("b8b8b0"))
	_l(-9.0, 0.6, -5.6, 0.6, Color("b8b8b0"), 0.12)
	# steam
	for p in [[-10.1, 4.2, 0.4], [-9.6, 4.6, 0.45], [-8.9, 4.5, 0.4], [-8.3, 4.7, 0.3]]:
		_c(p[0], p[1], p[2], Color(0.95, 0.95, 0.95, 0.85))

## The Forbury Lion in Reading: a huge cast-iron lion striding on a tall stone plinth, the memorial of the soldiers
## of Maiwand.
static func _forbury_lion() -> void:
	var st := Color("cbc4b2")
	_r(-5.0, 0, 5.0, 0.6, st.darkened(0.1))
	_r(-4.4, 0.6, 4.4, 1.1, st.darkened(0.05))
	_r(-3.8, 1.1, 3.8, 4.6, st)
	_r(-3.8, 1.1, -3.2, 4.6, st.darkened(0.1))
	if _detail(2.0):
		_r(-2.2, 2.0, 2.2, 3.6, st.darkened(0.08))
	_r(-4.2, 4.6, 4.2, 5.1, st.lightened(0.05))
	var li := Color("4b4a44")
	var ld := li.darkened(0.25)
	# far legs, darker
	_r(-2.9, 5.1, -2.1, 6.8, ld)
	_r(2.1, 5.1, 2.9, 6.8, ld)
	# the tail, swinging down with its tuft
	_pl([3.7, 7.6, 4.8, 7.0, 5.3, 6.0, 5.2, 5.6], li, 0.25)
	_c(5.2, 5.5, 0.3, ld)
	# body and near legs
	_ell(0.6, 7.2, 3.4, 1.15, 0.0, li)
	_r(-2.4, 5.1, -1.5, 7.0, li)
	_r(2.4, 5.1, 3.3, 7.0, li)
	_r(-2.7, 5.1, -1.3, 5.4, li)
	_r(2.1, 5.1, 3.5, 5.4, li)
	_ell(0.6, 7.6, 3.0, 0.5, 0.0, li.lightened(0.08))
	# the mane and head, looking ahead with the mouth a little open
	_c(-2.6, 8.2, 1.6, ld)
	_c(-2.8, 8.5, 1.2, li.darkened(0.12))
	_poly([-3.4, 9.1, -4.9, 8.7, -5.2, 8.1, -4.6, 7.7, -5.0, 7.5, -4.2, 7.2, -3.2, 7.5], li)
	_c(-3.9, 8.7, 0.12, Color("d8d0b0"))
	_c(-5.1, 8.2, 0.12, DARK)

## A Friesian cow (white with black patches), standing at (x, 0), `s` its size, `f` 1 facing right or -1 left, the
## head down to graze when `graze`.
static func _cow(x: float, s: float, f: float, graze: bool) -> void:
	var wh := Color("f1efe8")
	var bk := Color("26272a")
	for dx in [-0.8, 0.6]:
		_r(x + (dx - 0.12) * s * f, 0, x + (dx + 0.12) * s * f, 0.95 * s, wh.darkened(0.12))
	_l(x - f * 1.15 * s, 1.5 * s, x - f * 1.35 * s, 0.7 * s, bk, 0.07 * s)
	_ell(x, 1.25 * s, 1.15 * s, 0.48 * s, 0.0, wh)
	_c(x - 0.3 * s * f, 1.4 * s, 0.32 * s, bk)
	_ell(x + 0.55 * s * f, 1.15 * s, 0.3 * s, 0.22 * s, 0.3, bk)
	_ell(x - 0.85 * s * f, 1.05 * s, 0.22 * s, 0.25 * s, 0.0, bk)
	for dx in [-0.65, 0.8]:
		_r(x + (dx - 0.12) * s * f, 0, x + (dx + 0.12) * s * f, 0.95 * s, wh)
		_r(x + (dx - 0.12) * s * f, 0, x + (dx + 0.12) * s * f, 0.12 * s, bk)
	var hx := x + 1.35 * s * f
	var hy := (0.55 if graze else 1.6) * s
	_l(x + 0.95 * s * f, 1.3 * s, hx, hy + 0.1 * s, wh, 0.4 * s)
	_ell(hx + 0.1 * s * f, hy, 0.32 * s, 0.22 * s, (-0.9 if graze else -0.3) * f, bk)
	_ell(hx - 0.1 * s * f, hy + 0.22 * s, 0.14 * s, 0.07 * s, 0.4 * f, bk)
	if _detail(3.0):
		_c(hx + 0.15 * s * f, hy, 0.07 * s, wh)

## Milton Keynes' Concrete Cows: black-and-white Friesian cows and calves made of concrete, standing in a field.
static func _concrete_cows() -> void:
	_poly([-7, 0, 7, 0, 6.5, 0.4, 3, 0.6, -3, 0.5, -6.5, 0.3], GRASS)
	_cow(-4.6, 1.0, 1.0, false)
	_cow(-0.3, 1.0, -1.0, true)
	_cow(4.4, 1.0, -1.0, false)
	_cow(1.9, 0.62, 1.0, false)
	_cow(-6.0, 0.58, 1.0, true)

## Colchester Castle: the biggest Norman keep there is, of brownish stone with bands of red Roman tiles, round
## corner towers and small arched windows, the little domed summer-house on its corner tower.
static func _colchester_castle() -> void:
	_r(-22, 0, 22, 1.2, GRASS)
	var st := Color("ab906c")
	var sd := st.darkened(0.15)
	var tile := Color("9a4a35")
	_r(-18, 1.2, 18, 15, st)
	# the corner towers, the right one round
	_r(-21, 1.2, -15, 17.5, sd)
	_r(-19.6, 1.2, -16.4, 17.5, st.lightened(0.04))
	_r(15, 1.2, 21, 16.5, sd)
	_r(16.4, 1.2, 19.6, 16.5, st.lightened(0.06))
	_r(17.6, 1.2, 18.6, 16.5, st.lightened(0.12))
	# flat buttresses down the long front
	for x in [-10.0, -3.0, 4.0, 11.0]:
		_r(x - 0.7, 1.2, x + 0.7, 15.4, st.lightened(0.05))
	# the bands of Roman tiles
	for y in [4.0, 7.5, 11.0]:
		_r(-21, y, 21, y + 0.35, tile)
	# windows and the great round-arched door
	for x in [-13.5, -6.5, 0.5, 7.5, 14.0]:
		_arch_win(x - 0.5, 8.5, x + 0.5, 10.4, DARK)
		_arch_win(x - 0.4, 12.0, x + 0.4, 13.6, DARK)
	_arch_win(-7.8, 1.2, -4.6, 6.6, Color("4a3426"))
	if _detail(1.5):
		_pl(_arc(-6.2, 5.0, 1.9, 1.9, 0, PI, 8), st.lightened(0.15), 0.3)
	# the tops are a little ragged
	for x in range(-18, 18, 3):
		_r(x, 15, x + 1.6, 15.5, st)
	# the domed summer-house on the left tower
	_r(-19.4, 17.5, -16.6, 19.4, Color("ddd5c4"))
	_r(-18.6, 17.5, -17.4, 19.0, WIN)
	_poly([-19.7, 19.4, -16.3, 19.4] + _arc(-18, 19.4, 1.7, 1.9, 0, PI, 8), Color("6f7d7a"))
	_l(-18, 21.2, -18, 21.9, GOLD, 0.15)

## The Tees Transporter Bridge in Middlesbrough: a huge blue steel frame high over the river, a gondola hanging on
## cables that carries cars and people across.
static func _tees_transporter_bridge() -> void:
	var bl := Color("3d6fa8")
	var bd := bl.darkened(0.25)
	_r(-32, 0, 32, 2.2, WATER)
	if _detail(1.0):
		_r(-20, 0.8, -12, 1.1, WATER_L)
		_r(8, 1.4, 20, 1.7, WATER_L)
	_r(-32, 0, -24, 2.6, Color("8f8a80"))
	_r(24, 0, 32, 2.6, Color("8f8a80"))
	# the towers: two pairs of legs on each bank
	for side in [-1.0, 1.0]:
		var x: float = side * 25.0
		_l(x - 3.2, 2.6, x - 0.9, 35, bl, 0.9)
		_l(x + 3.2, 2.6, x + 0.9, 35, bl, 0.9)
		for y in [8.0, 16.0, 24.0]:
			var d0: float = 3.2 - 2.3 * (y - 2.6) / 32.4
			var d1: float = 3.2 - 2.3 * (y + 8.0 - 2.6) / 32.4
			_l(x - d0, y, x + d1, minf(y + 8.0, 35.0), bd, 0.3)
			_l(x + d0, y, x - d1, minf(y + 8.0, 35.0), bd, 0.3)
		_r(x - 3.6, 2.4, x + 3.6, 3.2, Color("6a6560"))
	# the long truss on top, deepest over the towers
	var top := [-32.0, 36.6, -25.0, 41.0, 25.0, 41.0, 32.0, 36.6]
	_r(-32, 34.6, 32, 35.6, bl)
	_pl(top, bl, 0.9)
	_l(-32, 35, -32, 36.6, bl, 0.6)
	_l(32, 35, 32, 36.6, bl, 0.6)
	if _detail(0.6):
		var k := -32.0
		var up := true
		while k < 31.0:
			var y0 := 35.6
			var x1 := k + 2.0
			var y1 := 41.0 if absf(x1) <= 25.0 else 41.0 - (absf(x1) - 25.0) / 7.0 * 4.4
			if up:
				_l(k, y0, x1, y1, bd, 0.3)
			else:
				var yk := 41.0 if absf(k) <= 25.0 else 41.0 - (absf(k) - 25.0) / 7.0 * 4.4
				_l(k, yk, x1, y0, bd, 0.3)
			up = not up
			k = x1
	# the anchor ties down to the ground at both ends
	_l(-31.5, 2.6, -31.5, 34.6, bd, 0.4)
	_l(31.5, 2.6, 31.5, 34.6, bd, 0.4)
	# the trolley and the gondola on its cables
	_r(-9, 34.0, -3, 34.6, DARK)
	for x in [-8.5, -7.0, -5.0, -3.5]:
		_l(x, 34.0, x, 5.3, Color("50565c"), 0.12)
	_r(-10.5, 4.6, -1.5, 5.3, bl)
	_r(-9.5, 5.3, -6.5, 7.2, Color("e8e4d8"))
	_r(-9.1, 6.2, -6.9, 6.9, WIN)
	_r(-5.5, 5.3, -3.0, 6.3, PO_RED)
	_r(-10.5, 3.9, -1.5, 4.6, bd)

## The cliff railway up Constitution Hill in Aberystwyth: two little stepped cars climbing a steep green hill, the
## stations at the bottom and the top.
static func _aberystwyth_cliff_railway() -> void:
	_poly([-15, 0, -15, 2.5, -10, 3, 3, 15, 9, 21.5, 15, 22.5, 15, 0], Color("6f9a4a"))
	_poly([3, 15, 9, 21.5, 15, 22.5, 15, 18, 10, 17], GRASS)
	_poly([-15, 0, -15, 1.8, -12, 1.8, -12, 0], Color("4f8fc0"))
	if _detail(1.0):
		_poly([7, 13, 10, 15.5, 12, 13], ROCK)
		_poly([-2, 4, 1, 7, 2, 4.5], ROCK)
	# two tracks up the hill
	var ax := -9.0
	var ay := 2.4
	var bx := 9.0
	var by := 20.4
	for o in [0.0, 1.4]:
		_l(ax + o, ay - o, bx + o, by - o, Color("5a4a3a"), 0.6)
		_l(ax + o, ay - o, bx + o, by - o, Color("8a8d92"), 0.15)
	# the stations
	_r(-14.2, 1.8, -8.8, 6.0, Color("ece6d6"))
	_poly([-14.6, 6.0, -8.4, 6.0, -11.5, 7.8], Color("8a3a2a"))
	_windows(-13.6, -10.5, 3.2, 4.8, 2, WIN)
	_r(8.6, 21, 14.6, 25.0, Color("ece6d6"))
	_poly([8.2, 25, 15, 25, 11.6, 26], Color("8a3a2a"))
	_windows(11, 14, 22.2, 23.8, 2, WIN)
	# the stepped cars, one going up and one coming down
	for p in [[0.28, 0.0], [0.62, 1.4]]:
		var t: float = p[0]
		var o: float = p[1]
		var cx: float = lerpf(ax, bx, t) + o
		var cy: float = lerpf(ay, by, t) - o
		for k in 3:
			var x := cx + k * 1.2
			var y := cy + k * 1.2
			_r(x - 0.7, y + 0.2, x + 0.6, y + 2.2, Color("f1e9d2"))
			_r(x - 0.7, y + 0.2, x + 0.6, y + 0.7, Color("7a2a2a"))
			_r(x - 0.5, y + 1.0, x + 0.4, y + 1.8, WIN)
			_r(x - 0.8, y + 2.2, x + 0.7, y + 2.45, Color("7a2a2a"))

## Gloucester Cathedral: a long pale nave and its tall central tower, covered in stone panelling, with four lacy
## pinnacles and an openwork crown on top.
static func _gloucester_cathedral() -> void:
	var st := Color("ddd3b6")
	var sd := st.darkened(0.12)
	var lead := Color("8d9296")
	_r(-22, 0, 22, 1, GRASS)
	# the nave and choir
	_r(-21, 1, 21, 16, sd)
	_poly([-21.3, 16, 21.3, 16, 20, 19, -20, 19], lead)
	for x in [-18.0, -13.5, -9.5, 9.5, 13.5, 18.0]:
		_arch_win(x - 1.1, 5, x + 1.1, 13, WIN, 1.2)
	for x in [-20.0, -16.0, -11.5, -7.5, 7.5, 11.5, 16.0, 20.0]:
		_r(x - 0.5, 1, x + 0.5, 16.8, st)
		_poly([x - 0.55, 16.8, x + 0.55, 16.8, x, 18.6], st)
	_arch_win(-1.6, 1, 1.6, 7, Color("4a3426"), 1.6)
	# the great tower
	_r(-6, 16, 6, 44, st)
	_r(-6, 16, -4.8, 44, sd)
	_r(4.8, 16, 6, 44, sd)
	_r(-6.3, 30, 6.3, 30.6, sd)
	for x in [-2.6, 2.6]:
		_arch_win(x - 1.4, 20, x + 1.4, 29, WIN, 1.4)
		_arch_win(x - 1.4, 32, x + 1.4, 42.5, WIN, 1.4)
	if _detail(1.0):
		for x in [-4.4, -0.8, 0.8, 4.4]:
			_l(x, 18, x, 43.5, sd, 0.18)
		for y in [24.5, 37.0]:
			_l(-1.2, y, 1.2, y, sd, 0.15)
	# the openwork crown and the four corner pinnacles
	_r(-6.2, 44, 6.2, 44.6, sd)
	_r(-6, 44.6, 6, 46.6, st)
	if _detail(1.5):
		for k in 6:
			_arch_win(-4.6 + k * 1.6, 44.9, -3.8 + k * 1.6, 46.3, Color("9fc6e6"), 0.4)
	for x in [-1.6, 1.6]:
		_r(x - 0.3, 46.6, x + 0.3, 48, st)
		_poly([x - 0.35, 48, x + 0.35, 48, x, 49.5], st)
	for x in [-5.6, 5.6]:
		_r(x - 0.8, 44, x + 0.8, 48.5, st.lightened(0.04))
		_poly([x - 0.9, 48.5, x + 0.9, 48.5, x, 52], st.lightened(0.04))
		if _detail(1.5):
			for y in [49.3, 50.3, 51.1]:
				_l(x - 0.5, y, x + 0.5, y, sd, 0.12)

## The Loughborough Carillon: a tall red-brick tower with a stone balcony and an open bell chamber full of bells,
## crowned with a green copper cupola.
static func _loughborough_carillon() -> void:
	var st := Color("dcd4c0")
	_r(-5, 0, 5, 0.8, Color("b9b2a0"))
	_r(-4.4, 0.8, 4.4, 4.0, st)
	_arch_win(-1.0, 0.8, 1.0, 3.6, Color("4a3426"))
	_r(-3.4, 4.0, 3.4, 32, BRICK)
	if _detail(1.5):
		for y in range(5, 31, 2):
			_r(-3.4, float(y), -2.8, float(y) + 1.0, st)
			_r(2.8, float(y), 3.4, float(y) + 1.0, st)
	_r(-3.6, 14, 3.6, 14.6, st)
	_r(-3.6, 24, 3.6, 24.6, st)
	_r(-0.6, 9, 0.6, 12, WIN)
	_r(-0.6, 18, 0.6, 22, WIN)
	_r(-0.6, 27, 0.6, 30, WIN)
	# the balcony
	_r(-4.6, 32, 4.6, 32.8, st)
	_r(-4.6, 32.8, 4.6, 34.2, st.darkened(0.06))
	if _detail(1.5):
		for k in 9:
			_r(-4.2 + k * 1.0, 33.0, -3.8 + k * 1.0, 34.0, st.darkened(0.25))
	# the bell chamber
	_r(-3.0, 34.2, 3.0, 40.0, st)
	for x in [-1.4, 1.4]:
		_arch_win(x - 0.9, 34.8, x + 0.9, 39.4, DARK)
		_c(x, 37.4, 0.55, Color("b8862e"))
		_c(x, 36.0, 0.35, Color("b8862e"))
	_r(-3.3, 40, 3.3, 40.6, st.darkened(0.08))
	# the copper cupola and its little finial
	_poly([-3.0, 40.6, 3.0, 40.6, 2.8, 41.8, 1.6, 43.4, 0.4, 44.4, -0.4, 44.4, -1.6, 43.4, -2.8, 41.8], COPPER)
	_poly([-3.0, 40.6, -1.0, 40.6, -0.6, 43.6, -1.6, 43.4, -2.8, 41.8], COPPER.lightened(0.15))
	_l(0, 44.4, 0, 45.6, GOLD, 0.2)
	_c(0, 45.6, 0.25, GOLD)

## The Moffat Ram: a bronze ram with curly horns standing on a fountain of rough rocks in the middle of the town.
static func _moffat_ram() -> void:
	_r(-3.8, 0, 3.8, 0.6, Color("b9b2a0"))
	_r(-3.4, 0.6, 3.4, 1.0, WATER)
	var rk := Color("9a9488")
	_poly([-3.0, 1.0, -2.8, 2.4, -2.2, 3.4, -1.4, 4.3, 0.4, 4.6, 1.8, 4.2, 2.6, 3.0, 3.0, 1.0], rk)
	_poly([-3.0, 1.0, -2.8, 2.4, -2.2, 3.4, -1.0, 2.4, -0.6, 1.0], rk.darkened(0.15))
	_poly([0.6, 1.0, 1.4, 3.2, 2.6, 3.0, 3.0, 1.0], rk.lightened(0.08))
	if _detail(3.0):
		_l(-0.2, 3.8, -0.4, 1.0, WATER_L, 0.12)
		_l(1.6, 3.4, 1.9, 1.0, WATER_L, 0.12)
	var br := Color("6b5a3a")
	var bd := br.darkened(0.3)
	var hn := Color("b08a4e")
	# far legs, near legs: thin, as a sheep's are
	_r(-1.3, 4.4, -0.95, 5.6, bd)
	_r(1.3, 4.4, 1.65, 5.6, bd)
	_ell(0.3, 6.0, 1.9, 0.75, 0.0, br)
	for p in [[-1.2, 6.4, 0.45], [-0.4, 6.6, 0.5], [0.5, 6.6, 0.5], [1.3, 6.4, 0.45], [1.9, 6.0, 0.4], [-1.5, 5.8, 0.4]]:
		_c(p[0], p[1], p[2], br)
	if _detail(3.0):
		for p in [[-0.8, 6.3], [0.1, 6.4], [0.9, 6.2], [-0.3, 5.8], [0.6, 5.7], [1.5, 5.9]]:
			_c(p[0], p[1], 0.22, br.lightened(0.12))
	_r(-1.0, 4.4, -0.6, 5.7, br)
	_r(1.6, 4.4, 2.0, 5.7, br)
	_l(2.2, 6.1, 2.4, 5.5, br, 0.25)
	# the neck and the long face, looking ahead and a little down
	_poly([-1.2, 6.8, -2.0, 7.6, -2.6, 7.6, -3.3, 6.6, -3.2, 6.3, -2.8, 6.3, -1.6, 5.6], br)
	_c(-3.0, 6.5, 0.22, bd)
	# the big curled horn on the side of the head
	_c(-2.0, 7.1, 0.62, hn)
	_c(-2.0, 7.1, 0.4, hn.darkened(0.3))
	_c(-1.95, 7.05, 0.24, hn)
	_c(-1.95, 7.05, 0.1, hn.darkened(0.3))
	_c(-2.65, 7.05, 0.09, DARK)

## The gold postbox in Dunblane: a round pillar box painted gold for Andy Murray, the town's tennis champion.
static func _dunblane_gold_postbox() -> void:
	var g := Color("d9a520")
	var gd := g.darkened(0.25)
	_r(-1.2, 0, 1.2, 0.12, Color("a9a59c"))
	_r(-0.46, 0.12, 0.46, 0.3, gd)
	_r(-0.38, 0.3, 0.38, 1.45, g)
	_r(-0.38, 0.3, -0.28, 1.45, gd)
	_r(0.28, 0.3, 0.38, 1.45, gd)
	_r(-0.12, 0.3, 0.0, 1.45, g.lightened(0.25))
	_r(-0.47, 1.45, 0.47, 1.56, gd)
	_poly([-0.42, 1.56, 0.42, 1.56] + _arc(0, 1.56, 0.42, 0.26, 0, PI, 10), g)
	_r(-0.22, 1.2, 0.22, 1.26, DARK)
	_r(-0.14, 0.85, 0.14, 1.05, Color("f2efe6"))
	_c(0, 0.62, 0.08, gd)
	if _detail(30.0):
		_poly([-0.06, 0.66, 0.06, 0.66, 0.08, 0.72, 0.0, 0.69, -0.08, 0.72], gd.darkened(0.2))

## The old packhorse bridge at Carrbridge: one high, thin stone arch over the rushing river Dulnain, its walls long
## gone, Scots pines on the banks.
static func _carrbridge_packhorse_bridge() -> void:
	_r(-12, 0, 12, 1.4, Color("5a7f9a"))
	if _detail(1.0):
		for p in [[-3.0, 0.6, 1.2], [1.5, 0.9, 0.9], [4.0, 0.4, 0.8]]:
			_ell(p[0], p[1], p[2], 0.2, 0.0, Color("e8eef2"))
	# the rocky banks
	_poly([-12, 0, -12, 5.2, -9, 5.0, -6.6, 3.6, -5.2, 1.2, -6, 0], ROCK)
	_poly([12, 0, 12, 5.4, 9, 5.2, 6.6, 3.6, 5.2, 1.2, 6, 0], ROCK.darkened(0.08))
	_poly([-12, 5.2, -9, 5.0, -8, 5.6, -12, 6.0], GRASS)
	_poly([12, 5.4, 9, 5.2, 8, 5.8, 12, 6.2], GRASS)
	_pine(-10.5, 5.6, 7.0)
	_pine(10.8, 5.8, 6.4)
	# the arch: a thin ring of rubble stone, steep and high
	var st := Color("85806f")
	var outer := _arc(0, 2.0, 7.4, 9.6, 0, PI, 18)
	var inner := _arc(0, 2.0, 5.6, 8.2, PI, 0, 18)
	_poly([7.4, 2.0] + outer + [-7.4, 2.0, -5.6, 2.0] + inner + [5.6, 2.0], st)
	_poly([-7.4, 2.0, -8.0, 3.2, -9.0, 4.8, -6.4, 3.4, -5.6, 2.0], st.darkened(0.1))
	_poly([7.4, 2.0, 8.0, 3.2, 9.0, 5.0, 6.4, 3.4, 5.6, 2.0], st.darkened(0.1))
	if _detail(1.5):
		for k in 9:
			var a := PI * (k + 0.5) / 9.0
			_l(cos(a) * 5.7, 2.0 + sin(a) * 8.3, cos(a) * 7.3, 2.0 + sin(a) * 9.5, st.darkened(0.2), 0.12)
	# a few loose stones on the top where the parapet was
	for p in [[-1.2, 11.6], [0.6, 11.7], [-2.6, 11.3]]:
		_r(p[0], p[1], p[0] + 0.6, p[1] + 0.35, st.lightened(0.1))
