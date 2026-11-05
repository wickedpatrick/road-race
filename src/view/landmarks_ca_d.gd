class_name LandmarksCaD
extends RefCounted
## Canadian landmarks of Ontario, Quebec and the Maritimes, drawn with LandmarkPainter's helpers (metres from the
## base point, y up).

const WHITE := Color("f4f2ea")
const WATER := Color("3f7fb5")
const WATER_L := Color("9cc8e6")
const GRASS := Color("6f9a48")
const PINE := Color("2f5a36")
const WOOD := Color("7a5634")
const DARK := Color("2e3238")
const WIN := Color("3a4048")
const SNOW := Color("f4f7fa")
const SNOW_S := Color("c9d6e4")
const RED := Color("d52b1e")
const COPPER := Color("6fae96")
const COPPER_D := Color("4c8a72")
const SKIN := Color("f0c8a0")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"peace_tower": _peace_tower()
		"rideau_skaters": _rideau_skaters()
		"fort_henry": _fort_henry()
		"biosphere_dome": _biosphere_dome()
		"olympic_stadium_tower": _olympic_stadium_tower()
		"chateau_frontenac": _chateau_frontenac()
		"montmorency_falls": _montmorency_falls()
		"hopewell_rocks": _hopewell_rocks()
		"peggys_cove_lighthouse": _peggys_cove_lighthouse()
		"bluenose_schooner": _bluenose_schooner()
		"confederation_bridge": _confederation_bridge()
		"green_gables": _green_gables()
		"thousand_islands": _thousand_islands()
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

## A dark evergreen: a brown stem and three stacked triangles, `h` tall.
static func _fir(x: float, y: float, h: float, col: Color) -> void:
	_r(x - h * 0.04, y, x + h * 0.04, y + h * 0.2, WOOD)
	for k in 3:
		var y0 := y + h * (0.15 + k * 0.25)
		var w := h * (0.3 - k * 0.07)
		_poly([x - w, y0, x + w, y0, x, y0 + h * 0.4], col)
		_poly([x - w, y0, x, y0, x, y0 + h * 0.4], col.lightened(0.1))

## A leafy tree: a trunk and a few overlapping round crowns, `h` tall.
static func _leafy(x: float, y: float, h: float, col: Color) -> void:
	_r(x - h * 0.05, y, x + h * 0.05, y + h * 0.45, WOOD)
	_c(x - h * 0.18, y + h * 0.58, h * 0.24, col.darkened(0.1))
	_c(x + h * 0.18, y + h * 0.6, h * 0.24, col.darkened(0.05))
	_c(x, y + h * 0.75, h * 0.26, col)

## A maple leaf about `s` tall centred on (x, y): the leaf in the middle of the Canadian flag.
static func _maple(x: float, y: float, s: float, col: Color) -> void:
	var half := [0.0, 0.5, 0.1, 0.3, 0.22, 0.36, 0.18, 0.1, 0.42, 0.2, 0.37, 0.06, 0.47, 0.0, 0.24, -0.16, 0.28, -0.27,
		0.04, -0.22, 0.04, -0.5]
	var pts := []
	for k in range(0, half.size(), 2):
		pts.append_array([x + half[k] * s, y + half[k + 1] * s])
	for k in range(half.size() - 2, -1, -2):
		pts.append_array([x - half[k] * s, y + half[k + 1] * s])
	_poly(pts, col)

## The Canadian flag, `w` wide, its lower left corner at (x, y), flying from a pole on its left.
static func _ca_flag(x: float, y: float, w: float) -> void:
	var h := w * 0.5
	_r(x, y, x + w, y + h, WHITE)
	_r(x, y, x + w * 0.25, y + h, RED)
	_r(x + w * 0.75, y, x + w, y + h, RED)
	if _detail(0.8):
		_maple(x + w * 0.5, y + h * 0.5, h * 0.75, RED)
	else:
		_r(x + w * 0.4, y + h * 0.25, x + w * 0.6, y + h * 0.75, RED)

## The Union Flag, `w` wide, its lower left corner at (x, y).
static func _union_flag(x: float, y: float, w: float) -> void:
	var h := w * 0.5
	_r(x, y, x + w, y + h, Color("24357a"))
	if _detail(1.0):
		var d := h * 0.12
		_poly([x, y, x + d * 2, y, x + w, y + h - d, x + w, y + h, x + w - d * 2, y + h, x, y + d], WHITE)
		_poly([x, y + h, x, y + h - d, x + w - d * 2, y, x + w, y, x + w, y + d, x + d * 2, y + h], WHITE)
		_l(x, y, x + w, y + h, RED, h * 0.06)
		_l(x, y + h, x + w, y, RED, h * 0.06)
	_r(x, y + h * 0.33, x + w, y + h * 0.67, WHITE)
	_r(x + w * 0.42, y, x + w * 0.58, y + h, WHITE)
	_r(x, y + h * 0.4, x + w, y + h * 0.6, RED)
	_r(x + w * 0.45, y, x + w * 0.55, y + h, RED)

## A pointed Gothic window: a slot with a triangular head, its foot at (x, y).
static func _gothic_win(x: float, y: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.5, y, x + w * 0.5, y, x + w * 0.5, y + h - w * 0.6, x, y + h, x - w * 0.5, y + h - w * 0.6], col)

## A round turret, r wide each side, from y0 to y1, with a pointed copper cone `cone` tall on top.
static func _turret(x: float, y0: float, y1: float, r: float, wall: Color, cone: float) -> void:
	_r(x - r, y0, x + r, y1, wall)
	_r(x + r * 0.3, y0, x + r, y1, wall.darkened(0.15))
	_poly([x - r * 1.2, y1, x + r * 1.2, y1, x, y1 + cone], COPPER)
	_poly([x, y1, x + r * 1.2, y1, x, y1 + cone], COPPER_D)
	if _detail(1.2):
		_r(x - r * 0.3, y1 - (y1 - y0) * 0.35, x + r * 0.2, y1 - (y1 - y0) * 0.15, WIN)

# --- Ottawa -------------------------------------------------------------------------------------------------

## The Peace Tower: the Parliament's tall Gothic clock tower of pale sandstone over the long Centre Block, with
## the clock faces, a steep green copper roof and the maple-leaf flag on top; the lawn in front.
static func _peace_tower() -> void:
	var stone := Color("d6c9a4")
	var stone_d := Color("b9aa84")
	var stone_l := Color("e6dcbc")
	_r(-22, 0, 22, 1.4, GRASS)
	_poly([-3, 0, 3, 0, 2.2, 1.4, -2.2, 1.4], Color("d8d0bc"))
	# the Centre Block: two long wings with copper mansard roofs, taller pavilions at the ends
	for s in [-1.0, 1.0]:
		var xa: float = 4.0 * s
		var xb: float = 21.0 * s
		_r(minf(xa, xb), 1.4, maxf(xa, xb), 12, stone)
		_r(minf(xa, xb), 11, maxf(xa, xb), 12, stone_l)
		_poly([xa, 12, xb - 0.6 * s, 12, xb - 1.6 * s, 15, xa, 15], COPPER)
		# the end pavilion
		var p0: float = 15.0 * s
		var p1: float = 21.5 * s
		_r(minf(p0, p1), 1.4, maxf(p0, p1), 14, stone_d)
		_poly([p0, 14, p1, 14, (p0 + p1) * 0.5 + 1.2 * s, 20, (p0 + p1) * 0.5 - 1.2 * s, 20], COPPER)
		_poly([(p0 + p1) * 0.5, 14, p1, 14, (p0 + p1) * 0.5 + 1.2 * s, 20, (p0 + p1) * 0.5, 20], COPPER_D)
		if _detail(0.9):
			for k in 5:
				var wx: float = (5.5 + k * 2.0) * s
				_gothic_win(wx, 3, 0.9, 2.8, WIN)
				_gothic_win(wx, 7.5, 0.9, 2.6, WIN)
			_gothic_win((p0 + p1) * 0.5, 3, 1.4, 4, WIN)
			_gothic_win((p0 + p1) * 0.5, 8.5, 1.4, 3.6, WIN)
			# little pinnacles along the roof line
			for k in 4:
				var px: float = (6.0 + k * 2.6) * s
				_poly([px - 0.35, 15, px + 0.35, 15, px, 17], COPPER_D)
	# the tower: a tall square shaft with buttressed corners
	var top := 41.0
	_r(-4.4, 1.4, 4.4, top, stone)
	_r(1.8, 1.4, 4.4, top, stone_d)
	_r(-4.4, 1.4, -3.5, top, stone_d.lightened(0.1))
	_r(3.5, 1.4, 4.4, top, stone_d.darkened(0.08))
	# the arched entrance and the Gothic window above it
	_gothic_win(0, 1.4, 3.6, 6.5, Color("5a4632"))
	_gothic_win(0, 1.4, 2.6, 5.6, Color("3a2c20"))
	_gothic_win(0, 10, 2.2, 7, WIN)
	if _detail(0.9):
		_l(0, 10, 0, 16, stone_l, 0.2)
		for y in [20.0, 24.5]:
			_gothic_win(-1.3, y, 1.0, 3.4, WIN)
			_gothic_win(1.3, y, 1.0, 3.4, WIN)
		_r(-4.4, 18.5, 4.4, 19, stone_l)
		_r(-4.4, 29, 4.4, 29.5, stone_l)
	# the clock
	_c(0, 32.6, 2.6, stone_l)
	_c(0, 32.6, 2.2, WHITE)
	_l(0, 32.6, 0, 34.2, DARK, 0.25)
	_l(0, 32.6, 1.1, 32.0, DARK, 0.25)
	if _detail(1.0):
		for k in 12:
			var a := TAU * k / 12.0
			_c(cos(a) * 1.8, 32.6 + sin(a) * 1.8, 0.12, DARK)
	# the belfry: tall slits, then a crown of corner pinnacles
	for x in [-2.2, 0.0, 2.2]:
		_gothic_win(x, 36, 1.0, 4.2, WIN)
	_r(-4.8, top - 0.6, 4.8, top + 0.2, stone_l)
	for x in [-4.4, 4.4]:
		_r(x - 0.6, top, x + 0.6, top + 2, stone_d)
		_poly([x - 0.6, top + 2, x + 0.6, top + 2, x, top + 4], COPPER_D)
	# the steep copper roof with its little dormers, and the flag on top
	_poly([-3.9, top, 3.9, top, 0.4, top + 12, -0.4, top + 12], COPPER)
	_poly([0, top, 3.9, top, 0.4, top + 12, 0, top + 12], COPPER_D)
	if _detail(0.9):
		for y in [top + 1.5, top + 5.5]:
			_poly([-1.0, y, 1.0, y, 1.0, y + 1.4, 0, y + 2.4, -1.0, y + 1.4], COPPER_D.darkened(0.1))
			_r(-0.5, y + 0.2, 0.5, y + 1.4, stone_l)
	_l(0, top + 12, 0, 58, Color("8a8a84"), 0.2)
	_ca_flag(0.1, 55.4, 4.6)

## A skater on blades whose skates touch the ice at (x, y), `h` tall, gliding towards f (1 right, -1 left):
## leaning forward, one leg pushing back, arms swinging, in a bobble hat and scarf.
static func _skater(x: float, y: float, h: float, f: float, coat: Color, hat: Color) -> void:
	var legs := Color("2f3a52")
	var hip := Vector2(x - 0.04 * h * f, y + 0.46 * h)
	var sh := Vector2(x + 0.1 * h * f, y + 0.78 * h)
	# the skates
	_l(x - 0.1 * h * f, y + 0.02 * h, x + 0.14 * h * f, y + 0.02 * h, Color("b8c0c8"), 0.03 * h)
	_l(x - 0.36 * h * f, y + 0.14 * h, x - 0.14 * h * f, y + 0.08 * h, Color("b8c0c8"), 0.03 * h)
	# the legs: one under the body, one pushing back
	_l(x, y + 0.06 * h, hip.x, hip.y, legs, 0.09 * h)
	_l(x - 0.26 * h * f, y + 0.12 * h, hip.x, hip.y, legs.lightened(0.1), 0.09 * h)
	# the arms, one swinging forward and one back
	_l(sh.x, sh.y - 0.03 * h, sh.x + 0.2 * h * f, sh.y - 0.16 * h, coat.darkened(0.15), 0.07 * h)
	_l(sh.x, sh.y - 0.03 * h, hip.x - 0.16 * h * f, hip.y + 0.1 * h, coat.darkened(0.15), 0.07 * h)
	# the body in its winter coat
	_poly([hip.x - 0.1 * h, hip.y - 0.04 * h, hip.x + 0.1 * h, hip.y - 0.04 * h, sh.x + 0.09 * h, sh.y,
		sh.x - 0.09 * h, sh.y], coat)
	# head, scarf and hat
	var hd := Vector2(sh.x + 0.05 * h * f, sh.y + 0.11 * h)
	_c(hd.x, hd.y, 0.075 * h, SKIN)
	_poly(_arc(hd.x, hd.y + 0.01 * h, 0.08 * h, 0.08 * h, 0, PI, 6), hat)
	_c(hd.x, hd.y + 0.1 * h, 0.03 * h, WHITE)
	_l(sh.x - 0.08 * h, sh.y + 0.01 * h, sh.x + 0.08 * h, sh.y + 0.01 * h, hat.lightened(0.2), 0.04 * h)
	_l(sh.x - 0.06 * h * f, sh.y, sh.x - 0.16 * h * f, sh.y - 0.1 * h, hat.lightened(0.2), 0.035 * h)

## Skating on the Rideau Canal in winter: the long frozen canal between snowy banks, skaters in bright coats and
## bobble hats, and a little wooden BeaverTails hut with the big brown pastry on its roof.
static func _rideau_skaters() -> void:
	# the far bank: snow, bare trees and old lamp posts
	_r(-30, 6.5, 30, 9.5, SNOW)
	_r(-30, 6.5, 30, 7.2, SNOW_S)
	if _detail(0.8):
		for x in [-27.0, -20.0, -11.0, -3.0, 9.0]:
			var tr := Color("6b5a4c")
			_l(x, 9, x, 16, tr, 0.35)
			_l(x, 12, x - 2, 15, tr, 0.2)
			_l(x, 13.5, x + 2.2, 16.5, tr, 0.2)
			_l(x, 15, x - 1.2, 17.5, tr, 0.15)
		for x in [-24.0, -7.0, 4.0]:
			_l(x, 9, x, 14, DARK, 0.2)
			_c(x, 14.3, 0.45, Color("f8e8a8"))
	# the ice of the canal, with skate marks
	_r(-30, 0, 30, 6.5, Color("dbeaf2"))
	_r(-30, 4.5, 30, 6.5, Color("c8dde9"))
	if _detail(0.9):
		for p in [[-26, 1.2, 10], [-12, 3.0, 12], [4, 1.8, 9], [-20, 4.8, 7], [10, 5.2, 8]]:
			_l(p[0], p[1], p[0] + p[2], p[1] + 0.3, Color("eef6fa"), 0.15)
	# the BeaverTails hut on the ice
	var hx := 21.0
	var wd := Color("8a5a34")
	_r(hx - 6, 2, hx + 6, 9, wd)
	if _detail(1.0):
		for k in 6:
			_l(hx - 6, 2.8 + k * 1.1, hx + 6, 2.8 + k * 1.1, wd.darkened(0.2), 0.1)
	_r(hx - 4.5, 4.5, hx + 4.5, 7.6, Color("3a2a20"))
	_r(hx - 4.5, 4.5, hx + 4.5, 5.0, Color("d9c3a0"))
	for k in 6:
		var x0 := hx - 6.5 + k * 13.0 / 6.0
		_poly([x0, 9, x0 + 13.0 / 6.0, 9, x0 + 13.0 / 6.0, 8.2, x0, 8.2], RED if k % 2 == 0 else WHITE)
	_poly([hx - 7, 9, hx + 7, 9, hx + 5.5, 10.6, hx - 5.5, 10.6], Color("5a3a24"))
	# the vendor at the counter
	_c(hx - 1, 6.4, 0.6, SKIN)
	_poly(_arc(hx - 1, 6.5, 0.65, 0.65, 0, PI, 6), WHITE)
	# the big pastry on the roof: a flat brown oval, sugared and cinnamon-dotted
	_ell(hx, 13.2, 6.2, 2.4, 0.12, Color("8a5426"))
	_ell(hx - 0.2, 13.4, 5.6, 1.9, 0.12, Color("b9783a"))
	if _detail(0.9):
		for p in [[-3.6, -0.2], [-1.5, -0.6], [0, 0.4], [1.4, -0.1], [3.2, 0.9], [-2.4, 0.3], [1.6, 1.0]]:
			_c(hx + p[0], 13.4 + p[1], 0.3, Color("6a3a1a"))
			_c(hx + p[0] + 0.6, 13.2 + p[1], 0.18, WHITE)
	_l(hx - 2, 10.6, hx - 2, 11.2, Color("5a3a24"), 0.3)
	_l(hx + 2, 10.6, hx + 2, 11.2, Color("5a3a24"), 0.3)
	# the near snowbank
	_poly([-30, 0, -30, 1.4, -18, 0.8, -6, 1.1, 8, 0.6, 30, 1.0, 30, 0], SNOW)
	# the skaters
	_skater(-24, 2.4, 8.6, 1, Color("d63a3a"), Color("2a5aa8"))
	_skater(-14, 3.8, 7.4, 1, Color("2a7a4a"), RED)
	_skater(-5, 1.2, 9.0, -1, Color("2d6ab0"), Color("f2c230"))
	_skater(4, 3.6, 7.2, 1, Color("8a3aa0"), WHITE)
	_skater(11.5, 1.6, 8.2, -1, Color("f2a024"), Color("2a3a5a"))

# --- Kingston -----------------------------------------------------------------------------------------------

## A British guard of 1867 standing to attention, `h` tall, feet at (x, y): red tunic with white cross belts,
## grey trousers, a tall black shako and a musket at the shoulder.
static func _guard(x: float, y: float, h: float) -> void:
	var red := Color("c22a26")
	_r(x - 0.12 * h, y, x - 0.02 * h, y + 0.46 * h, Color("3c3f48"))
	_r(x + 0.02 * h, y, x + 0.12 * h, y + 0.46 * h, Color("3c3f48"))
	_r(x - 0.15 * h, y, x - 0.01 * h, y + 0.04 * h, DARK)
	_r(x + 0.01 * h, y, x + 0.15 * h, y + 0.04 * h, DARK)
	_r(x - 0.15 * h, y + 0.44 * h, x + 0.15 * h, y + 0.8 * h, red)
	_r(x - 0.2 * h, y + 0.5 * h, x - 0.14 * h, y + 0.79 * h, red.darkened(0.1))
	_r(x + 0.14 * h, y + 0.5 * h, x + 0.2 * h, y + 0.79 * h, red.darkened(0.1))
	if _detail(1.0):
		_l(x - 0.13 * h, y + 0.78 * h, x + 0.13 * h, y + 0.48 * h, WHITE, 0.035 * h)
		_l(x + 0.13 * h, y + 0.78 * h, x - 0.13 * h, y + 0.48 * h, WHITE, 0.035 * h)
	_r(x - 0.15 * h, y + 0.44 * h, x + 0.15 * h, y + 0.48 * h, WHITE)
	_c(x, y + 0.85 * h, 0.07 * h, SKIN)
	_r(x - 0.08 * h, y + 0.88 * h, x + 0.08 * h, y + 1.0 * h, Color("1c1c22"))
	_r(x - 0.1 * h, y + 0.87 * h, x + 0.1 * h, y + 0.89 * h, Color("1c1c22"))
	_c(x, y + 1.02 * h, 0.025 * h, WHITE)
	# the musket with its bayonet
	_l(x + 0.22 * h, y + 0.3 * h, x + 0.22 * h, y + 1.12 * h, WOOD, 0.04 * h)
	_l(x + 0.22 * h, y + 1.12 * h, x + 0.22 * h, y + 1.28 * h, Color("c8ccd0"), 0.02 * h)

## A black iron cannon on its wooden carriage, the muzzle to the right; (x, y) is the middle of the wheels' base.
static func _cannon(x: float, y: float, s: float) -> void:
	_poly([x - 1.6 * s, y + 0.3 * s, x + 0.6 * s, y + 0.3 * s, x + 0.9 * s, y + 1.3 * s, x - 1.2 * s, y + 1.5 * s], WOOD)
	_l(x - 1.4 * s, y + 1.5 * s, x + 2.6 * s, y + 2.0 * s, Color("26282c"), 0.7 * s)
	_c(x - 1.5 * s, y + 1.48 * s, 0.42 * s, Color("26282c"))
	_c(x + 2.6 * s, y + 2.0 * s, 0.3 * s, Color("26282c"))
	_c(x, y + 0.75 * s, 0.75 * s, WOOD.darkened(0.25))
	_c(x, y + 0.75 * s, 0.25 * s, Color("26282c"))
	if _detail(1.0):
		for k in 6:
			var a := TAU * k / 6.0
			_l(x, y + 0.75 * s, x + cos(a) * 0.7 * s, y + 0.75 * s + sin(a) * 0.7 * s, WOOD.darkened(0.4), 0.08 * s)

## Fort Henry in Kingston: the grey limestone walls of the old fort over its grassy glacis, the arched gate, a
## row of cannon on the ramparts, the Union Flag on its staff, red-coated guards at the gate and a field gun.
static func _fort_henry() -> void:
	var lime := Color("bdb6a4")
	var lime_d := Color("9c9584")
	var lime_l := Color("d4cfbf")
	# the walls: a long front with a jutting bastion each side
	_r(-28, 2, 28, 15, lime)
	_poly([-35, 2, -26, 2, -26, 17, -33, 17], lime_d)
	_poly([35, 2, 26, 2, 26, 17, 33, 17], lime_d)
	_r(-26, 2, -24, 15, lime_d.darkened(0.1))
	_r(24, 2, 26, 15, lime_d.darkened(0.1))
	if _detail(0.9):
		for k in 9:
			var y := 3.4 + k * 1.4
			_l(-28, y, 28, y, lime_d, 0.08)
			_l(-33.5, y, -26, y, lime_d.darkened(0.15), 0.08)
			_l(26, y, 33.5, y, lime_d.darkened(0.15), 0.08)
	# the parapet with its gun embrasures, grass on top
	_r(-28, 15, 28, 16.6, lime_l)
	_poly([-33, 17, -26, 17, -26, 18.2, -33, 18.2], lime_l)
	_poly([26, 17, 33, 17, 33, 18.2, 26, 18.2], lime_l)
	_r(-28, 16.6, 28, 17.3, GRASS)
	for x in [-20.0, -11.0, 11.0, 20.0]:
		_r(x - 1.2, 15.4, x + 1.2, 16.6, lime_d.darkened(0.3))
		_l(x, 16.2, x + (0.0 if absf(x) < 1 else signf(x) * 0.2), 17.4, Color("26282c"), 0.6)
		_c(x, 16.0, 0.5, Color("26282c"))
	# the gate: an arch in a raised stone frame, heavy wooden doors
	_r(-6, 2, 6, 18, lime_l)
	_poly([-6.6, 18, 6.6, 18, 6.6, 19, -6.6, 19], lime_d)
	_poly([-3.4, 2, 3.4, 2, 3.4, 8.5] + _arc(0, 8.5, 3.4, 3.4, 0, PI, 10) + [-3.4, 8.5], Color("3a2a20"))
	_poly([-2.9, 2, 2.9, 2, 2.9, 8.5] + _arc(0, 8.5, 2.9, 2.9, 0, PI, 10) + [-2.9, 8.5], Color("6b4628"))
	_l(0, 2, 0, 11.4, Color("3a2a20"), 0.15)
	if _detail(1.0):
		for y in [4.0, 6.5, 9.0]:
			_l(-2.9, y, 2.9, y, Color("3a2a20"), 0.12)
		_r(-2.5, 13.5, 2.5, 15.5, lime_d)
	# the flag staff over the gate
	_l(0, 19, 0, 31.5, Color("e8e8e0"), 0.25)
	_union_flag(0.1, 27, 8.4)
	# windows of the barracks peeping over the parapet: the casemate arches
	if _detail(0.9):
		for x in [-23.0, -17.0, -11.0, 11.0, 17.0, 23.0]:
			_poly([x - 1.1, 9, x + 1.1, 9, x + 1.1, 11] + _arc(x, 11, 1.1, 1.1, 0, PI, 6) + [x - 1.1, 11], WIN)
	# the grassy glacis
	_poly([-35, 0, -35, 3.2, -20, 2.4, 0, 2.6, 20, 2.4, 35, 3.2, 35, 0], GRASS)
	_r(-35, 0, 35, 0.8, GRASS.darkened(0.1))
	# the guards at the gate and a field gun on the grass
	_guard(-9.5, 1.0, 7.6)
	_guard(8.5, 1.0, 7.6)
	_cannon(-20, 0.8, 1.6)
	_cannon(16, 0.8, 1.6)

# --- Montréal -----------------------------------------------------------------------------------------------

## The Biosphère: Buckminster Fuller's huge geodesic sphere of steel struts on Île Sainte-Hélène, the triangles
## crowding together towards its edge, trees and water round its foot.
static func _biosphere_dome() -> void:
	var cx := 0.0
	var cy := 26.0
	var rr := 24.5
	var base := 2.4
	_r(-28, 0, 28, 2.6, GRASS)
	# the glass skin, faintly lit
	var ab := asin((base - cy) / rr)
	var shell := _arc(cx, cy, rr, rr, ab, PI - ab, 40)
	_poly(shell, Color("c6dcea"))
	_poly(_arc(cx - 3, cy + 2, rr * 0.8, rr * 0.86, ab + 0.3, PI - ab - 0.5, 24), Color("d8e8f2"))
	_ell(cx - 9, cy + 10, 5, 3.4, 0.6, Color(1, 1, 1, 0.35))
	# the struts: a triangle lattice wrapped round the sphere, so it bunches up at the rim
	var strut := Color("7d8b98")
	var g := 0.11 if _detail(1.2) else 0.18
	for fam in 3:
		var th := PI / 6.0 + fam * PI / 3.0
		var d := Vector2(cos(th), sin(th))
		var n := Vector2(-d.y, d.x)
		var s := -1.0 + fmod(1.0, g) * 0.5
		while s < 1.0:
			var hc := sqrt(maxf(0.0, 1.0 - s * s))
			var run := []
			for k in 17:
				var t := lerpf(-hc, hc, k / 16.0)
				var p := n * s + d * t
				var rho := p.length()
				var q: Vector2 = p * (sin(rho * PI * 0.5) / rho) if rho > 0.001 else p
				var wx := cx + q.x * rr
				var wy := cy + q.y * rr
				if wy >= base:
					run.append_array([wx, wy])
				else:
					if run.size() >= 4:
						_pl(run, strut, 0.16)
					run = []
			if run.size() >= 4:
				_pl(run, strut, 0.16)
			s += g
	_pl(shell, strut.darkened(0.2), 0.3)
	# the low hall inside the foot of the sphere
	_r(-14, base, 14, base + 3.2, Color("e2e0d8"))
	_r(-14, base + 3.2, 14, base + 3.6, Color("8a8e92"))
	_windows(-12, 12, base + 0.6, base + 2.6, 8, Color("5a7a90"))
	# trees and the river round the foot
	_r(-28, 0, 28, 1.0, WATER)
	for p in [[-26.0, 7.0], [-22.5, 9.0], [-19.0, 6.5], [19.5, 8.0], [23.0, 6.0], [26.0, 9.0]]:
		_leafy(p[0], 1.0, p[1], Color("4f8a3e"))

## The Olympic Stadium: the white concrete oval with its curved ribs and the Montréal Tower, the tallest leaning
## tower in the world, arching out over it with cables holding up the roof.
static func _olympic_stadium_tower() -> void:
	var conc := Color("e8e6df")
	var conc_d := Color("c4c2ba")
	_r(-45, 0, 45, 1.4, Color("b8b4aa"))
	# the stadium shell: a long low oval
	var top := [-34, 1.4, -32, 8, -27, 13, -18, 17, -6, 19, 8, 19.4, 22, 18, 34, 14, 41, 8, 44, 1.4]
	_poly(top, conc)
	# the roof over the field, a pale disk
	_ell(5, 18.6, 27, 2.0, 0, Color("d8cdb2"))
	_ell(5, 18.9, 24, 1.3, 0, Color("e8e0c8"))
	# the ribs: concrete claws rising round the shell, with dark glass between them at the foot
	for k in 13:
		var t := (k + 0.5) / 13.0
		var xb := lerpf(-31.0, 42.0, t)
		var xt := xb * 0.88 + 5.0 * 0.12
		var yt := _prof_y(top, xt) - 0.5
		var pts := []
		for j in 7:
			var u := j / 6.0
			pts.append_array([lerpf(xb, xt, u * u), 1.4 + (yt - 1.4) * sin(u * PI * 0.5)])
		_pl(pts, conc_d, 0.6)
		if _detail(0.9) and k < 12:
			_r(xb + 1.4, 1.4, xb + 4.0, 3.4, Color("5d6f80"))
	# the cables from the tower to the roof
	for k in 7:
		_l(-22, 44 - k * 2.5, -12 + k * 6.5, 19.2, Color("707880"), 0.12)
	# the tower: a curving concrete spine leaning far over the stadium
	var back := [-44, 1.4, -41.5, 12, -37.5, 23, -32, 34, -25.5, 44, -18.5, 52]
	var front := [-12.5, 49.5, -18, 41, -23.5, 31, -27.5, 20, -29.5, 10, -30, 1.4]
	_poly(back + front, conc)
	_poly([-36.2, 1.4, -34.0, 12, -30.4, 23, -25.6, 34, -19.6, 43.5, -14.5, 50.5,
		-12.5, 49.5, -18, 41, -23.5, 31, -27.5, 20, -29.5, 10, -30, 1.4], conc_d)
	if _detail(0.9):
		for k in range(0, back.size() - 2, 2):
			var y0: float = back[k + 1]
			if k > 0:
				_l(back[k], y0, front[front.size() - 2 - k], front[front.size() - 1 - k], conc_d.darkened(0.1), 0.12)
		# the funicular on the back of the tower
		_pl([-43.2, 1.4, -40.7, 12, -36.7, 23, -31.2, 34, -24.7, 44, -18, 51], Color("5a5f66"), 0.3)
		_poly([-34.8, 27.2, -32.6, 30.3, -34.4, 31.5, -36.5, 28.4], Color("d23b33"))
	# the observatory at the top, glazed and tilted
	_poly([-19.5, 51, -12.5, 48.5, -9.8, 52.0, -17, 55.8], conc_d)
	_poly([-18.4, 51.8, -12.8, 49.6, -11.0, 52.0, -16.6, 54.6], Color("4f6478"))
	_l(-17, 55.6, -16.2, 56, Color("707880"), 0.3)

# --- Québec -------------------------------------------------------------------------------------------------

## The Château Frontenac: the great brick castle hotel with its steep green copper roofs, central tower and
## pointed turrets, high on Cap Diamant over the St. Lawrence, with the Dufferin Terrace kiosks along the edge
## and the old lower town and a ferry below.
static func _chateau_frontenac() -> void:
	var brick := Color("b0684c")
	var brick_d := Color("8c4e38")
	var stone := Color("c8bfae")
	# the river
	_r(-35, 0, 35, 5, WATER)
	if _detail(0.9):
		for p in [[-30, 1.5], [-6, 2.8], [18, 1.2]]:
			_r(p[0], p[1], p[0] + 7, p[1] + 0.3, WATER_L)
	# the ferry
	_poly([-28, 1.6, -18, 1.6, -17, 3.2, -29, 3.2], WHITE)
	_r(-26, 3.2, -20, 4.8, Color("e8e4dc"))
	_r(-24.5, 4.8, -23, 6.2, Color("2a4a8a"))
	_r(-28.5, 1.6, -17.5, 2.2, Color("2a4a8a"))
	# the cliff, rocky and wooded
	var rock := Color("7a6e60")
	_poly([-35, 5, -35, 22, -24, 23, -12, 23.5, 4, 23.5, 20, 23, 35, 22, 35, 5], rock)
	_poly([-35, 5, -35, 12, -28, 15, -20, 13, -12, 16, -2, 14, 8, 17, 18, 14, 28, 16, 35, 13, 35, 5], rock.darkened(0.12))
	if _detail(0.8):
		for p in [[-30, 18, 2.4], [-22, 20, 2.0], [-9, 19, 2.6], [6, 20.5, 2.2], [16, 18.5, 2.6], [29, 19, 2.2],
				[-16, 16.5, 1.8], [24, 15.5, 1.8]]:
			_c(p[0], p[1], p[2], Color("4f7a3e"))
			_c(p[0] + p[2] * 0.4, p[1] + p[2] * 0.3, p[2] * 0.7, Color("5f8a46"))
	# the lower town at the foot: little stone houses with steep roofs
	var hc := [Color("e8dcc4"), Color("c8b8a0"), Color("dcc9a4"), Color("e4e0d4")]
	for k in 7:
		var x0 := -14.0 + k * 4.2
		var c: Color = hc[k % hc.size()]
		_r(x0, 5, x0 + 3.8, 9, c)
		_poly([x0 - 0.2, 9, x0 + 4.0, 9, x0 + 1.9, 11], Color("5a5a5e") if k % 2 == 0 else Color("a8402e"))
		if _detail(1.2):
			_r(x0 + 0.7, 6.4, x0 + 1.5, 7.8, WIN)
			_r(x0 + 2.3, 6.4, x0 + 3.1, 7.8, WIN)
	# the Dufferin Terrace: a boardwalk along the cliff edge with its green-roofed kiosks
	_r(-35, 23, 35, 24.2, Color("9a8a74"))
	_r(-35, 24.2, 35, 24.6, Color("e8e4da"))
	for x in [-31.0, -27.0, 26.0, 31.0]:
		_r(x - 0.9, 24.6, x + 0.9, 26.4, WHITE)
		_poly([x - 1.3, 26.4, x + 1.3, 26.4, x, 28.4], COPPER)
	# the château: wings either side, a tall central tower, turrets with pointed roofs
	var y0 := 24.6
	# the left wing
	_r(-24, y0, -8, 36, brick)
	_poly([-24.6, 36, -7.6, 36, -9.2, 41, -23, 41], COPPER)
	_windows(-23, -9, y0 + 2, y0 + 4, 6, WIN)
	_windows(-23, -9, y0 + 5.5, y0 + 7.5, 6, WIN)
	_windows(-23, -9, y0 + 9, y0 + 10.5, 6, WIN)
	# the right wing
	_r(8, y0, 23, 34, brick)
	_poly([7.6, 34, 23.6, 34, 22, 38.5, 9.2, 38.5], COPPER)
	_windows(9, 22, y0 + 2, y0 + 4, 5, WIN)
	_windows(9, 22, y0 + 5.5, y0 + 7.5, 5, WIN)
	if _detail(1.0):
		for x in [-20.0, -15.5, -11.0]:
			_r(x - 0.6, 37, x + 0.6, 38.6, WHITE)
			_poly([x - 0.9, 38.6, x + 0.9, 38.6, x, 39.8], COPPER_D)
		for x in [12.0, 16.5, 20.0]:
			_r(x - 0.6, 35, x + 0.6, 36.4, WHITE)
			_poly([x - 0.9, 36.4, x + 0.9, 36.4, x, 37.5], COPPER_D)
		for x in [-17.5, 15.0]:
			_r(x - 0.5, 39.5 if x < 0 else 37.5, x + 0.5, 43.5 if x < 0 else 40.5, brick_d)
	# the central tower with its tall steep hip roof
	_r(-7, y0, 7, 42, brick)
	_r(3.5, y0, 7, 42, brick_d)
	_r(-7, y0, 7, y0 + 1.6, stone)
	_poly([-1.6, y0, 1.6, y0, 1.6, y0 + 2.4, 0, y0 + 3.4, -1.6, y0 + 2.4], DARK)
	for k in 5:
		_windows(-6, 6, y0 + 4.2 + k * 2.6, y0 + 5.6 + k * 2.6, 4, WIN)
	_poly([-7.6, 42, 7.6, 42, 2.2, 50, -2.2, 50], COPPER)
	_poly([0, 42, 7.6, 42, 2.2, 50, 0, 50], COPPER_D)
	_l(0, 50, 0, 52, COPPER_D, 0.2)
	if _detail(1.0):
		for x in [-3.6, 0.0, 3.6]:
			_r(x - 0.7, 43.2, x + 0.7, 45, WHITE)
			_poly([x - 1.0, 45, x + 1.0, 45, x, 46.2], COPPER_D)
	# corner turrets
	_turret(-7, 34, 42, 1.4, brick, 5)
	_turret(7, 34, 42, 1.4, brick_d, 5)
	_turret(-24, y0, 38, 2.0, brick, 7)
	_turret(23, y0, 35.5, 1.8, brick_d, 6)

## Montmorency Falls: a white waterfall plunging down a tall dark cliff, higher than Niagara, with the little
## suspension bridge across its crest, a wooden stair zig-zagging up the cliff and the manor on top.
static func _montmorency_falls() -> void:
	var rock := Color("6a5e52")
	var rock_d := Color("554a40")
	var rock_l := Color("847666")
	var crest := 50.0
	# the cliff either side of the gorge, its rim dipping a little towards the edges
	var lt := [-30, 46.5, -25, 48.5, -19, 50.4, -12, 51, -5, crest + 1]
	var rt := [5, crest + 1, 12, 51, 19, 50.2, 25, 48.6, 30, 47.2]
	_poly([-30, 3] + lt + [-6.6, 22, -8.4, 3], rock)
	_poly([8.4, 3, 6.6, 22] + rt + [30, 3], rock_d)
	if _detail(0.8):
		for k in 7:
			var y := 8.0 + k * 5.6
			_l(-30, y, -7.0 + k * 0.25, y + 0.4, rock_d, 0.25)
			_l(7.0 - k * 0.25, y + 0.4, 30, y, rock.darkened(0.25), 0.25)
		# gullies and lit ribs down the face, a few bushes clinging to the ledges
		for g in [[-24.0, 8.0, 30.0], [-15.0, 22.0, 44.0], [-20.0, 4.0, 18.0], [21.0, 6.0, 36.0]]:
			var x: float = g[0]
			_poly([x, g[1], x + 1.4, g[1], x + 0.9, g[2], x + 0.4, g[2]], rock_l if x < 0 else rock_d.darkened(0.15))
		for p in [[-27, 24], [-19, 36], [-11, 14], [-22, 9], [11, 30], [24, 17], [27, 40]]:
			_c(p[0], p[1], 1.2, Color("4f7a3e"))
			_c(p[0] + 0.8, p[1] + 0.4, 0.8, Color("5f8a46"))
	# the clifftop: grass along the rim
	for edge in [lt, rt]:
		var cap: Array = _rev(edge)
		for k in range(0, edge.size(), 2):
			cap.append_array([edge[k], edge[k + 1] - 0.9])
		_poly(cap, GRASS)
	# the wooden staircase on the right cliff
	var st := Color("a07a4a")
	_pl([26, 3, 14, 12, 26, 21, 14, 30, 26, 39, 16, 47, 17, 50.6], st, 0.45)
	# the waterfall, widening as it falls, with streaks
	_poly([-5, crest + 1, 5, crest + 1, 6.8, 22, 8.6, 3, -8.6, 3, -6.8, 22], Color("dfeaf2"))
	if _detail(0.8):
		for k in 7:
			var t := (k + 0.5) / 7.0
			var xt := lerpf(-4.0, 4.0, t)
			var xb := lerpf(-7.6, 7.6, t)
			_l(xt, crest, xb, 4, Color("a8c4d8") if k % 2 == 0 else WHITE, 0.4)
	# the lip of the falls
	_r(-4.8, crest, 4.8, crest + 1.2, Color("b8d0e0"))
	# the pool below, with spray
	_r(-30, 0, 30, 3.5, WATER)
	_ell(0, 3.5, 11, 2.6, 0, Color(1, 1, 1, 0.8))
	_ell(-6, 5, 5, 2.2, 0, Color(1, 1, 1, 0.55))
	_ell(6, 5.5, 5, 2.4, 0, Color(1, 1, 1, 0.55))
	if _detail(0.9):
		_l(-26, 1.4, -14, 1.4, WATER_L, 0.3)
		_l(14, 2.0, 26, 2.0, WATER_L, 0.3)
	# firs on the clifftop
	for p in [[-28.0, 47.0, 6.0], [-25.0, 48.6, 7.5], [-21.0, 49.8, 5.5], [-14.0, 50.8, 6.5], [-11.0, 51.0, 5.0],
			[11.0, 51.0, 5.5], [25.5, 48.6, 6.5], [28.5, 47.6, 5.0]]:
		_fir(p[0], p[1], p[2], PINE)
	# the Manoir Montmorency: a white house with a red roof
	_r(14, crest + 1.5, 22, crest + 5.5, WHITE)
	_poly([13.4, crest + 5.5, 22.6, crest + 5.5, 21, crest + 7.6, 15, crest + 7.6], Color("b03a2e"))
	_windows(14.5, 21.5, crest + 3, crest + 4.6, 4, WIN)
	# the suspension bridge over the crest: two small towers, sagging cables and hangers
	var dy := crest + 3.4
	_r(-10, dy - 0.7, 10, dy, Color("4a4a4e"))
	_l(-10, dy + 0.9, 10, dy + 0.9, Color("6a6a6e"), 0.15)
	for x in [-7.5, 7.5]:
		_r(x - 0.5, crest + 1, x + 0.5, dy + 3.4, Color("5a5a5e"))
	var cab := []
	for k in 11:
		var t := k / 10.0
		var x := lerpf(-7.5, 7.5, t)
		var s := (t - 0.5) * 2.0
		cab.append_array([x, dy + 0.6 + 2.6 * s * s])
	_pl(cab, Color("3a3a3e"), 0.18)
	_l(-9, crest + 1, -7.5, dy + 3.2, Color("3a3a3e"), 0.15)
	_l(9, crest + 1, 7.5, dy + 3.2, Color("3a3a3e"), 0.15)
	if _detail(1.0):
		for j in range(2, cab.size() - 2, 2):
			_l(cab[j], dy, cab[j], cab[j + 1], Color("3a3a3e"), 0.08)

# --- The Maritimes ------------------------------------------------------------------------------------------

## One flowerpot rock at x: a pillar of red sandstone worn thin at the foot by the tides, dark with seaweed up
## to the high-tide line, wider above and crowned with firs; `top` its height, `w` its half-width at the top.
static func _flowerpot(x: float, top: float, w: float) -> void:
	var red := Color("b0644a")
	var red_d := Color("8c4a36")
	var hw := [0.58, 0.46, 0.5, 0.66, 0.86, 0.98, 1.0]
	var ys := [0.0, 0.18, 0.32, 0.5, 0.7, 0.88, 1.0]
	var left := []
	var right := []
	for k in hw.size():
		var y: float = 1.0 + (top - 1.0) * float(ys[k])
		var h: float = w * float(hw[k])
		left.append_array([x - h, y])
		right.append_array([x + h * 1.05, y])
	var pts := []
	for k in range(left.size() - 2, -1, -2):
		pts.append_array([left[k], left[k + 1]])
	pts.append_array(right)
	_poly(pts, red)
	# the shadowed right flank and the level bands of sandstone
	var sh := []
	for k in range(0, right.size(), 2):
		sh.append_array([x + (right[k] - x) * 0.45, right[k + 1]])
	for k in range(right.size() - 2, -1, -2):
		sh.append_array([right[k], right[k + 1]])
	_poly(sh, red_d)
	if _detail(0.9):
		for k in range(3, 7):
			var y := 1.0 + (top - 1.0) * k / 7.0
			_l(x - w * 0.9, y, x + w * 0.95, y + 0.2, red_d.darkened(0.1), 0.18)
	# the seaweed up to the high-tide mark
	var tide := 1.0 + (top - 1.0) * 0.26
	_poly([x - w * 0.6, 1.0, x + w * 0.62, 1.0, x + w * 0.5, tide, x - w * 0.48, tide], Color("7a5e42"))
	_poly([x + w * 0.1, 1.0, x + w * 0.62, 1.0, x + w * 0.5, tide, x + w * 0.1, tide], Color("664c36"))
	# the grassy cap and its trees
	_poly([x - w * 1.02, top - 0.2, x + w * 1.07, top - 0.2, x + w * 0.9, top + 0.6, x - w * 0.85, top + 0.6], GRASS)
	_fir(x - w * 0.55, top + 0.3, w * 1.5, PINE)
	_fir(x + w * 0.1, top + 0.4, w * 2.0, PINE.lightened(0.05))
	_fir(x + w * 0.65, top + 0.3, w * 1.4, PINE)

## The Hopewell Rocks at low tide: red sandstone flowerpot rocks with firs on their heads, standing on the wet
## brown floor of the Bay of Fundy with tiny people walking between them.
static func _hopewell_rocks() -> void:
	# the far water of the bay, and the wooded cliff on the left
	_r(-30, 3, 30, 5.5, Color("6a8a9a"))
	_poly([-30, 2, -30, 20, -26, 20.5, -22, 19, -20, 14, -19, 6, -18, 2], Color("a85e44"))
	_poly([-30, 19.6, -22, 18.6, -22, 20.4, -30, 21], GRASS)
	for x in [-29.0, -26.5, -24.0]:
		_fir(x, 20, 5.5, PINE)
	# the sea floor: wet brown mud with shiny puddles
	_r(-30, 0, 30, 3.2, Color("8a6650"))
	_r(-30, 2.6, 30, 3.2, Color("9a7660"))
	if _detail(0.8):
		for p in [[-14, 0.8, 6], [2, 1.8, 5], [16, 0.6, 7], [-26, 2.0, 4]]:
			_ell(p[0], p[1], p[2] * 0.5, 0.25, 0, Color("b8a8a0"))
	# the flowerpots
	_flowerpot(-9, 18, 3.6)
	_flowerpot(5, 14, 2.8)
	_flowerpot(19, 16.5, 3.2)
	# tiny walkers on the sea floor
	if _detail(1.0):
		var cols := [Color("d63a3a"), Color("2d6ab0"), Color("f2c230"), Color("2a7a4a")]
		var k := 0
		for x in [-2.0, -0.8, 11.5, 26.0]:
			var c: Color = cols[k]
			k += 1
			_r(x - 0.2, 0.6, x + 0.2, 1.4, DARK)
			_r(x - 0.28, 1.4, x + 0.28, 2.4, c)
			_c(x, 2.7, 0.28, SKIN)

## Peggy's Cove: the white octagonal lighthouse with its red lantern, standing on the bare, rounded granite of
## the Nova Scotia shore, the Atlantic breaking white on the rocks.
static func _peggys_cove_lighthouse() -> void:
	# the sea
	_r(-20, 0, 20, 9, WATER)
	if _detail(0.8):
		for p in [[-18, 7.5, 5], [-6, 8.2, 4], [8, 7.8, 6], [12, 4.5, 5]]:
			_l(p[0], p[1], p[0] + p[2], p[1], WATER_L, 0.25)
	# the granite: big pale rounded slabs
	var gr := Color("cfc9bc")
	var gr_d := Color("a9a294")
	_poly([-20, 0, -20, 7, -16, 9.5, -11, 10.5, -6, 11.2, -1, 11.6, 4, 11.4, 8, 10.2, 11, 8, 14, 5.2, 17, 2.5, 20, 1.2, 20, 0], gr)
	_poly([2, 0, 3, 6, 6, 9.5, 8, 10.2, 11, 8, 14, 5.2, 17, 2.5, 20, 1.2, 20, 0], gr_d)
	_poly([-20, 0, -20, 4, -15, 5.5, -9, 4.6, -6, 2.4, -4, 0], gr_d.lightened(0.1))
	if _detail(0.9):
		_pl([-12, 10.2, -10, 7, -11, 4], gr_d.darkened(0.15), 0.18)
		_pl([6, 9.6, 8, 6.5, 7, 3], gr_d.darkened(0.25), 0.18)
		_pl([-3, 11.4, -2, 9], gr_d.darkened(0.1), 0.15)
	# surf breaking on the rocks
	_ell(17, 2.6, 3, 1.3, 0.3, Color(1, 1, 1, 0.85))
	_ell(13, 5.2, 2, 0.9, 0.6, Color(1, 1, 1, 0.75))
	# the tower: white, tapering, one face in shade
	var base := 11.2
	var top := 25.0
	_poly([-2.6, base, 2.6, base, 1.9, top, -1.9, top], Color("f6f6f2"))
	_poly([0.9, base, 2.6, base, 1.9, top, 0.65, top], Color("d9dad6"))
	_r(-0.6, base, 0.6, base + 2.2, RED)
	_r(-0.4, base + 7, 0.4, base + 8.2, WIN)
	_r(-0.35, top - 4.5, 0.35, top - 3.4, WIN)
	# the gallery, the lantern and its red roof
	_r(-2.8, top, 2.8, top + 0.7, RED)
	if _detail(1.0):
		for k in 7:
			_l(-2.6 + k * 0.866, top + 0.7, -2.6 + k * 0.866, top + 1.5, DARK, 0.08)
		_l(-2.7, top + 1.5, 2.7, top + 1.5, DARK, 0.1)
	_r(-1.6, top + 0.7, 1.6, top + 3.4, RED)
	_r(-1.2, top + 1.1, 1.2, top + 3.0, Color("f8e9a0"))
	if _detail(1.0):
		_l(0, top + 1.1, 0, top + 3.0, RED, 0.12)
	_poly([-2.0, top + 3.4, 2.0, top + 3.4, 1.1, top + 5.0, -1.1, top + 5.0], RED)
	_poly(_arc(0, top + 5.0, 1.1, 0.6, 0, PI, 6), RED.darkened(0.2))
	_c(0, top + 5.9, 0.35, DARK)
	_l(0, top + 6.2, 0, top + 7.4, DARK, 0.1)
	# a pair of gulls
	if _detail(0.9):
		_pl([-12, 22, -11, 22.6, -10, 22], WHITE.darkened(0.3), 0.2)
		_pl([-8.5, 25, -7.6, 25.5, -6.7, 25], WHITE.darkened(0.3), 0.2)

## The Bluenose: the black Nova Scotia racing schooner on the dime, heeling slightly under full sail: two tall
## masts with gaff mainsail and foresail, topsails and jibs on the long bowsprit.
static func _bluenose_schooner() -> void:
	var sail := Color("efe6cf")
	var sail_d := Color("d8ccb0")
	# the sea
	_r(-22, 0, 22, 3, WATER)
	# the hull: long and low, a raking bow on the right, a counter stern on the left
	_poly([-19, 4.2, -15, 2.2, 12, 2.2, 18.5, 4.8, 19.5, 6.6, -19.6, 5.8], Color("1e1f24"))
	_poly([-15, 2.2, 12, 2.2, 14, 3.0, -16.2, 3.0], Color("a8322a"))
	_l(-19.4, 5.8, 19.4, 6.6, WHITE, 0.2)
	# the bowsprit
	_l(19, 6.4, 22, 7.6, WOOD, 0.3)
	# the masts: the mainmast aft is the taller
	var mx := -4.0
	var fx := 7.0
	_l(mx, 6, mx, 39.5, WOOD, 0.4)
	_l(fx, 6.2, fx, 35, WOOD, 0.4)
	# the mainsail: a gaff sail running back past the stern on its boom
	_poly([mx + 0.3, 8, -20.5, 7.6, -19.0, 30.5, mx + 0.3, 28], sail)
	_poly([-12, 7.8, -20.5, 7.6, -19.0, 30.5, -12, 29.3], sail_d)
	_l(mx, 7.8, -21, 7.4, WOOD, 0.3)
	_l(mx, 28, -19.4, 30.8, WOOD, 0.25)
	# the main topsail
	_poly([mx + 0.2, 28.4, mx + 0.2, 39, -16.5, 30.8], sail)
	# the foresail between the masts
	_poly([fx + 0.3, 8.2, mx + 0.8, 8.0, mx + 1.4, 26.5, fx + 0.3, 25], sail)
	_l(fx, 8.0, mx + 0.6, 7.8, WOOD, 0.25)
	_l(fx, 25, mx + 1.2, 26.7, WOOD, 0.22)
	# the fore topsail
	_poly([fx + 0.2, 25.4, fx + 0.2, 34.5, mx + 1.8, 27], sail_d)
	# the jibs on the bowsprit
	_poly([fx + 0.5, 30.5, 21.5, 7.6, fx + 1.0, 8.4], sail)
	_poly([fx + 0.5, 30.5, fx + 1.0, 8.4, fx + 6.0, 8.0], sail_d)
	if _detail(1.0):
		# reef points and seams
		for k in 3:
			var y := 11.0 + k * 5.5
			_l(mx - 0.4, y, -20.2, y - 0.2 + k * 0.6, sail_d.darkened(0.08), 0.1)
			_l(fx - 0.3, y, mx + 1.0, y, sail_d.darkened(0.08), 0.1)
		# the stays
		_l(mx, 39.5, fx, 35, DARK, 0.08)
		_l(fx, 35, 22, 7.6, DARK, 0.08)
	# the flag at the main peak
	_poly([mx, 39.5, mx - 2.4, 38.8, mx, 38.1], RED)
	# waves at the bow and along the side
	_poly([16, 2.4, 20, 2.2, 22, 3.0, 22, 3.6, 19, 3.2, 17, 3.6], Color(1, 1, 1, 0.85))
	_pl([-22, 2.4, -19, 2.9, -16, 2.6], Color(1, 1, 1, 0.75), 0.3)
	if _detail(0.8):
		for p in [[-14, 0.8], [-2, 1.4], [8, 0.6]]:
			_l(p[0], p[1], p[0] + 5, p[1], WATER_L, 0.25)

## The Confederation Bridge: thirteen kilometres of concrete curving away over the Northumberland Strait to the
## red cliffs of Prince Edward Island, its piers growing smaller and closer into the distance.
static func _confederation_bridge() -> void:
	var conc := Color("d8d6ce")
	var conc_d := Color("aeaca4")
	# the sea, darker near
	_r(-50, 0, 50, 8, WATER)
	_r(-50, 5, 50, 8, WATER.lightened(0.15))
	# PEI on the horizon: red cliffs under green fields
	_poly([30, 7.6, 34, 9.2, 42, 9.8, 50, 9.6, 50, 7.6], Color("5f8a46"))
	_poly([30, 7.6, 31, 8.2, 50, 8.4, 50, 7.6], Color("b0503a"))
	if _detail(0.8):
		for p in [[-44, 1.4, 6], [-24, 3.2, 5], [-6, 0.8, 7], [14, 2.4, 5], [28, 4.2, 4]]:
			_l(p[0], p[1], p[0] + p[2], p[1], WATER_L, 0.25)
	# the bridge: sampled along its length, from the near shore on the left to the far island on the right
	var n := 18
	var xs := []
	var wl := []
	var dk := []
	var sc := []
	for k in n + 1:
		var u := float(k) / n
		var e := 1.0 - pow(1.0 - u, 1.7)
		xs.append(lerpf(-50, 34, e) + sin(e * PI) * 6.0)
		wl.append(lerpf(0.6, 7.8, e))
		sc.append(lerpf(1.0, 0.1, e))
		dk.append(float(wl[k]) + 17.0 * float(sc[k]) + sin(e * PI) * 2.0)
	# the girders: deep over each pier, shallow mid-span
	for k in n:
		var x0: float = xs[k]
		var x1: float = xs[k + 1]
		var y0: float = dk[k]
		var y1: float = dk[k + 1]
		var s0: float = sc[k]
		var s1: float = sc[k + 1]
		var mid := []
		for j in 7:
			var t := j / 6.0
			var dep := lerpf(s0, s1, t) * (1.2 + 3.2 * pow(absf(t - 0.5) * 2.0, 2.0))
			mid.append_array([lerpf(x0, x1, t), lerpf(y0, y1, t) - dep])
		_poly([x0, y0, x1, y1] + _rev(mid), conc_d)
	# the piers with their ice shields at the waterline
	for k in n + 1:
		var x: float = xs[k]
		var w: float = wl[k]
		var s: float = sc[k]
		var y: float = dk[k] - 4.0 * s
		_r(x - 1.3 * s, w, x + 1.3 * s, y, conc)
		_r(x + 0.3 * s, w, x + 1.3 * s, y, conc_d)
		_poly([x - 2.6 * s, w, x + 2.6 * s, w, x + 1.3 * s, w + 3.0 * s, x - 1.3 * s, w + 3.0 * s], conc_d.darkened(0.1))
	# the deck with its parapet
	var top := []
	var bot := []
	for k in n + 1:
		var s: float = sc[k]
		top.append_array([xs[k], dk[k] + 1.1 * s])
		bot.append_array([xs[k], dk[k] - 0.6 * s])
	_poly(top + _rev(bot), conc)
	_pl(top, WHITE, 0.25)
	# a lorry and a car on the near end
	if _detail(0.8):
		_r(-46, dk[0] + 1.0, -41, dk[0] + 3.6, Color("c8323a"))
		_r(-41, dk[0] + 1.0, -39.6, dk[0] + 2.6, Color("e8e4dc"))
		_r(-34, dk[1] + 1.0, -31.6, dk[1] + 2.2, Color("2d6ab0"))

## Height of a profile (flat [x, y, ...] points, x rising) at x.
static func _prof_y(xy: Array, x: float) -> float:
	for k in range(0, xy.size() - 2, 2):
		var x0: float = xy[k]
		var x1: float = xy[k + 2]
		if x >= x0 and x <= x1:
			return lerpf(xy[k + 1], xy[k + 3], (x - x0) / (x1 - x0))
	return xy[1]

## Points of a flat [x, y, ...] list in reverse order.
static func _rev(xy: Array) -> Array:
	var out := []
	for k in range(xy.size() - 2, -1, -2):
		out.append_array([xy[k], xy[k + 1]])
	return out

## Green Gables on Prince Edward Island: the white clapboard farmhouse of Anne of Green Gables, its gables and
## shutters painted green, with a red chimney, a white picket fence, leafy trees and the red PEI earth.
static func _green_gables() -> void:
	var white := Color("f6f4ec")
	var white_d := Color("dcd9ce")
	var green := Color("3d7a46")
	var roof := Color("4a6a50")
	_r(-18, 0, 18, 2.4, GRASS)
	_poly([-4, 0, 2, 0, 0.6, 2.4, -2.6, 2.4], Color("b5523a"))
	# trees behind the house
	_leafy(-14.5, 2, 13, Color("4f8a3e"))
	_leafy(14.5, 2, 12, Color("5a9446"))
	# the kitchen wing on the right
	_r(5, 2.4, 13, 7.6, white_d)
	_poly([4.6, 7.6, 13.6, 7.6, 13.6, 8.0, 9.2, 10.6, 4.6, 10.6], roof)
	_windows(6, 12.5, 4, 6.2, 2, WIN)
	# the main house
	_r(-10, 2.4, 5.5, 9.4, white)
	if _detail(1.1):
		for k in 9:
			_l(-10, 3.0 + k * 0.72, 5.5, 3.0 + k * 0.72, white_d, 0.06)
	_poly([-11, 9.4, 6.5, 9.4, 4.5, 14.2, -9, 14.2], roof)
	_poly([-11, 9.4, -9.6, 9.4, -8.2, 14.2, -9, 14.2], roof.lightened(0.15))
	# the two front gables, trimmed in green
	for gx in [-5.5, 1.5]:
		_poly([gx - 3, 9.4, gx + 3, 9.4, gx, 14.0], white)
		_pl([gx - 3.4, 9.1, gx, 14.4, gx + 3.4, 9.1], green, 0.5)
		_r(gx - 0.7, 10.2, gx + 0.7, 12.0, WIN)
		_r(gx - 1.2, 10.2, gx - 0.7, 12.0, green)
		_r(gx + 0.7, 10.2, gx + 1.2, 12.0, green)
	# windows with green shutters, and the green front door under a little porch roof
	for wx in [-8.2, -5.5, 2.5]:
		_r(wx - 0.7, 3.4, wx + 0.7, 7.4, WIN)
		if _detail(0.9):
			_l(wx - 0.7, 5.4, wx + 0.7, 5.4, white, 0.12)
		_r(wx - 1.3, 3.4, wx - 0.7, 7.4, green)
		_r(wx + 0.7, 3.4, wx + 1.3, 7.4, green)
	_r(-2.4, 2.4, -0.6, 6.8, green)
	_poly([-3.2, 6.8, 0.2, 6.8, -1.5, 8.0], green.darkened(0.15))
	# the red brick chimneys
	_r(-7.6, 13.0, -6.6, 15.6, Color("a8402e"))
	_r(3.0, 12.4, 4.0, 15.0, Color("a8402e"))
	# the white picket fence
	var fc := Color("faf8f2")
	_r(-18, 0.9, -4.5, 1.2, fc)
	_r(2.5, 0.9, 18, 1.2, fc)
	_r(-18, 1.9, -4.5, 2.2, fc)
	_r(2.5, 1.9, 18, 2.2, fc)
	for k in 36:
		var x := -17.6 + k * 1.0
		if x > -4.6 and x < 2.4:
			continue
		_poly([x - 0.18, 0, x + 0.18, 0, x + 0.18, 2.5, x, 2.8, x - 0.18, 2.5], fc)
	# flowers along the fence
	if _detail(1.0):
		for k in 14:
			var x := -16.5 + k * 2.5
			if x > -5 and x < 3:
				continue
			_c(x, 0.6, 0.35, Color("e85a8a") if k % 2 == 0 else Color("f2c230"))

## The Thousand Islands at Gananoque: little pink granite islands with pines on the St. Lawrence, a cottage on
## one, a house that fills a whole islet, a tiny footbridge between two, a wooden runabout speeding by and Boldt
## Castle far off on the American shore.
static func _thousand_islands() -> void:
	var gran := Color("b89a8a")
	var gran_d := Color("957a6c")
	# the far shore with Boldt Castle
	_r(-35, 9, 35, 10.6, Color("5a7a50"))
	var ca := Color("a8a49a")
	_r(14, 10, 22, 14, ca)
	_r(16.5, 10, 19.5, 16.5, ca.darkened(0.08))
	_poly([16.2, 16.5, 19.8, 16.5, 18, 18.6], Color("8a3a30"))
	for x in [14.0, 22.0]:
		_r(x - 0.8, 10, x + 0.8, 15.2, ca.darkened(0.12))
		_poly([x - 1.0, 15.2, x + 1.0, 15.2, x, 16.8], Color("8a3a30"))
	if _detail(1.0):
		_windows(14.5, 21.5, 11.5, 12.8, 5, WIN)
	# the river
	_r(-35, 0, 35, 9, WATER)
	if _detail(0.8):
		for p in [[-32, 7, 6], [-6, 6.5, 5], [26, 7.2, 6], [-22, 1.6, 7], [24, 2.6, 6]]:
			_l(p[0], p[1], p[0] + p[2], p[1], WATER_L, 0.22)
	# the big island on the left: rock, pines and a cottage with a dock
	_poly([-34, 3, -33, 5.5, -29, 7.2, -23, 7.6, -17, 6.6, -13, 4.6, -12, 3], gran)
	_poly([-34, 3, -12, 3, -13, 4.6, -20, 4.4, -28, 4.8, -33, 4.2], gran_d)
	_poly([-31, 6.6, -24, 7.6, -18, 6.8, -24, 7.0], GRASS)
	_fir(-31, 6.2, 10, PINE)
	_fir(-28.4, 6.8, 13, PINE)
	_fir(-15.5, 5.6, 9, PINE)
	_r(-25, 7.0, -18.5, 10.6, WHITE)
	_poly([-25.6, 10.6, -17.9, 10.6, -21.75, 13.2], Color("b03a2e"))
	_r(-23, 7.0, -21.6, 9.4, Color("3a6a8a"))
	_r(-20.6, 8.4, -19.2, 9.6, WIN)
	_r(-13, 3.2, -9, 3.7, WOOD)
	# Just Room Enough: one little house filling a whole islet
	_ell(2, 3.2, 4.2, 1.0, 0, gran_d)
	_poly([-1.8, 3.4, 5.8, 3.4, 4.8, 4.4, -0.8, 4.4], gran)
	_r(-0.4, 4.2, 4.4, 7.6, Color("f2ecd8"))
	_poly([-1.0, 7.6, 5.0, 7.6, 2.0, 10.2], Color("3d6a4a"))
	_r(1.4, 4.2, 2.6, 6.2, Color("3d6a4a"))
	_fir(5.2, 4.0, 5, PINE)
	# two rocks with a tiny footbridge between them
	_poly([20, 3, 21, 5.4, 24, 6.0, 26, 5, 27, 3], gran)
	_poly([29, 3, 29.8, 4.6, 32, 5.0, 34, 3], gran_d)
	_fir(23.5, 5.6, 9, PINE)
	_fir(32, 4.6, 6, PINE)
	_pl([26.4, 4.6, 27.8, 5.3, 29.4, 4.4], Color("6b4628"), 0.3)
	# the wooden runabout and its wake
	var bx := 11.0
	var by := 0.8
	_poly([bx - 6, by + 0.3, bx + 3.6, by + 0.3, bx + 6.6, by + 2.3, bx - 6.3, by + 2.3], Color("8a4a24"))
	_l(bx - 6.3, by + 2.3, bx + 6.6, by + 2.3, Color("e8d8b0"), 0.3)
	_l(bx - 5.8, by + 1.3, bx + 4.6, by + 1.3, Color("6a3418"), 0.15)
	_poly([bx - 0.8, by + 2.3, bx + 2.4, by + 2.3, bx + 1.2, by + 3.8, bx - 0.3, by + 3.8], Color("b8d8ea"))
	_c(bx - 2.8, by + 3.1, 0.7, SKIN)
	_poly(_arc(bx - 2.8, by + 3.2, 0.75, 0.7, 0, PI, 5), WHITE)
	_r(bx - 3.6, by + 2.3, bx - 2.0, by + 2.6, Color("2a4a8a"))
	_pl([bx - 6, by + 0.8, bx - 12, by + 1.7, bx - 18, by + 2.4], Color(1, 1, 1, 0.8), 0.4)
	_pl([bx - 6, by + 0.4, bx - 12, by + 0.1, bx - 17, by - 0.2], Color(1, 1, 1, 0.7), 0.35)
	_poly([bx + 4.4, by + 0.3, bx + 6.8, by + 1.0, bx + 5.6, by + 1.4], Color(1, 1, 1, 0.9))
