class_name LandmarksFiA
extends RefCounted
## Finnish landmarks (Helsinki to Joensuu), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const WHITE := Color("f4f2ec")
const WHITE_D := Color("dcd8cc")
const CREAM := Color("eee2c2")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const GRASS := Color("5d8f42")
const TREE := Color("2f5a33")
const PINE := Color("3b6b3a")
const GOLD := Color("e0b43a")
const COPPER := Color("5f9e86")
const COPPER_D := Color("4a8270")
const BRICK := Color("a5452f")
const BRICK_D := Color("7f3424")
const GRANITE := Color("8f8a84")
const GRANITE_D := Color("75706a")
const WATER := Color("5f8fae")
const CONCRETE := Color("c9c6be")
const CONCRETE_D := Color("aaa69c")
const ROOF_D := Color("3c3f44")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"fi_helsinki_cathedral": _helsinki_cathedral()
		"fi_espoo_cathedral": _espoo_cathedral()
		"fi_turku_castle": _turku_castle()
		"fi_tampere_nasinneula": _tampere_nasinneula()
		"fi_oulu_toripolliisi": _oulu_toripolliisi()
		"fi_jyvaskyla_saynatsalo": _jyvaskyla_saynatsalo()
		"fi_kuopio_puijo": _kuopio_puijo()
		"fi_lahti_ski_jumps": _lahti_ski_jumps()
		"fi_pori_juselius": _pori_juselius()
		"fi_joensuu_townhall": _joensuu_townhall()
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

## A dome: a half ellipse on a base line.
static func _dome(x: float, y: float, rx: float, ry: float, col: Color) -> void:
	_poly(_arc(x, y, rx, ry, 0, PI, 12), col)

## A spruce: a dark triangle in two tiers on a short trunk.
static func _spruce(x: float, y: float, h: float, col: Color) -> void:
	_l(x, y, x, y + h * 0.2, Color("4a3826"), h * 0.05)
	_poly([x - h * 0.28, y + h * 0.15, x + h * 0.28, y + h * 0.15, x, y + h * 0.7], col)
	_poly([x - h * 0.2, y + h * 0.45, x + h * 0.2, y + h * 0.45, x, y + h], col)

## Helsinki Cathedral above Senate Square: the broad flight of steps, the white cross-shaped church with its columned
## portico and pediment, the apostles on the roof line, the tall drum and green dome with a gold cross and the four
## small domes at the corners.
static func _helsinki_cathedral() -> void:
	# the steps
	for k in 5:
		var w := 22.0 - k * 1.2
		_r(-w, k * 0.9, w, k * 0.9 + 0.9, WHITE_D if k % 2 == 0 else Color("e6e2d6"))
	var base := 4.5
	# the body and the side wings
	_r(-17, base, 17, base + 15, WHITE)
	_r(-17, base + 14, 17, base + 15.2, WHITE_D)
	_windows(-16, -9, base + 4, base + 10, 3, WIN)
	_windows(9, 16, base + 4, base + 10, 3, WIN)
	# the portico: six columns under a pediment
	_r(-8, base, 8, base + 1, WHITE_D)
	_r(-6.5, base + 1, 6.5, base + 12, Color("cfcabd"))
	for k in 6:
		var x := -7.0 + k * 2.8
		_r(x - 0.5, base + 1, x + 0.5, base + 13.5, WHITE)
		_l(x + 0.35, base + 1.2, x + 0.35, base + 13.3, WHITE_D, 0.15)
	_r(-8.4, base + 13.5, 8.4, base + 15, WHITE_D)
	# the four small domes on their drums
	for x in [-13.5, 13.5]:
		_r(x - 2, base + 15.2, x + 2, base + 18.5, WHITE)
		_dome(x, base + 18.5, 2.2, 2.4, COPPER)
		_l(x, base + 20.9, x, base + 22.2, GOLD, 0.15)
	# the drum with its columns and windows
	var dy := base + 19.5
	_r(-7.5, base + 15, 7.5, dy, WHITE_D)
	_r(-6.5, dy, 6.5, dy + 8, WHITE)
	for k in 7:
		var x := -5.4 + k * 1.8
		_r(x - 0.25, dy, x + 0.25, dy + 8, WHITE_D)
	_windows(-5.4, 5.4, dy + 2, dy + 6, 3, WIN)
	_r(-7, dy + 8, 7, dy + 9, WHITE_D)
	# the dome, the lantern and the cross
	_dome(0, dy + 9, 7, 8.5, COPPER)
	_poly([2.0, dy + 9] + _arc(0, dy + 9, 7, 8.5, 0.3, 1.2, 4), COPPER_D)
	_r(-1.1, dy + 17.2, 1.1, dy + 19.5, WHITE)
	_dome(0, dy + 19.5, 1.3, 1.6, COPPER)
	_l(0, dy + 21, 0, dy + 24, GOLD, 0.2)
	_l(-0.8, dy + 23, 0.8, dy + 23, GOLD, 0.2)
	# the portico's pediment in front of the drum's base, the apostles on it and on the roof line clear of the domes
	_poly([-8.8, base + 15, 8.8, base + 15, 0, base + 19], WHITE)
	_poly([-7, base + 15.5, 7, base + 15.5, 0, base + 18.4], WHITE_D)
	for x in [-16.6, -10.0, -8.6, 0.0, 8.6, 10.0, 16.6]:
		var y := base + (19.0 if x == 0.0 else 15.2)
		_r(x - 0.3, y, x + 0.3, y + 1.6, Color("6f7d72"))
		_c(x, y + 1.9, 0.32, Color("6f7d72"))

## Espoo Cathedral: the medieval whitewashed stone church with its steep dark roof and stepped east gable, the west
## tower with its tall black spire.
static func _espoo_cathedral() -> void:
	_poly([-15, 0, 15, 0, 15, 1.2, -15, 1.2], GRASS)
	# the nave
	_r(-5, 1, 13, 9, WHITE)
	_poly([-5.5, 9, 13.5, 9, 12, 16.5, -4, 16.5], ROOF_D)
	# the stepped gable on the east end
	_poly([11.6, 9, 14, 9, 14, 11, 13.4, 11, 13.4, 12.6, 12.8, 12.6, 12.8, 14.2, 12.2, 14.2, 12.2, 16.8, 11.6, 16.8], WHITE)
	for x in [-1.0, 4.0, 9.0]:
		_arched(x, 3, 1.6, 4.0, WIN)
	# the sacristy on the side
	_r(13, 1, 15, 6, WHITE_D)
	# the west tower
	_r(-11, 1, -5, 15, WHITE)
	_r(-11, 1, -10, 15, WHITE_D)
	_arched(-8, 1, 2.2, 4.0, Color("5b4636"))
	_r(-8.6, 10, -7.4, 12.2, WIN)
	_r(-11.4, 15, -4.6, 15.8, WHITE_D)
	_poly([-11.4, 15.8, -4.6, 15.8, -8, 24.5], ROOF_D)
	_l(-8, 24.5, -8, 25.8, GOLD, 0.15)
	_c(-8, 25.9, 0.25, GOLD)
	# trees by the churchyard
	for p in [[-14.0, 6.0], [14.5, 5.5]]:
		_c(p[0], 1.2 + p[1] * 0.5, p[1] * 0.5, TREE)

## Turku Castle: the long grey stone main castle on its low mound by the Aura, white-rendered upper storeys, the two
## square towers with their steep roofs and the low bailey in front.
static func _turku_castle() -> void:
	var stone := Color("bdb8ae")
	var stone_d := Color("9f9a90")
	var render := Color("e9e4d8")
	var roof := Color("5a4e46")
	_r(-30, 0, 30, 1.2, Color("8e8a80"))
	# the bailey in front, lower and longer
	_r(-29, 1.2, 4, 7, stone)
	_poly([-29.5, 7, 4.5, 7, 3, 9.5, -28, 9.5], roof)
	_windows(-27, 2, 3, 5, 9, WIN)
	# the main castle
	_r(-8, 1.2, 27, 18, render)
	_r(-8, 1.2, 27, 6, stone)
	_r(-8, 1.2, -6.8, 18, stone_d)
	_windows(-6, 26, 8, 10.5, 9, WIN)
	_windows(-6, 26, 12.5, 15, 9, WIN)
	_poly([-8.6, 18, 27.6, 18, 25.5, 22, -6.5, 22], roof)
	# the two square towers with steep roofs
	for t in [[-3.5, 30.0], [19.5, 28.0]]:
		var x: float = t[0]
		var top: float = t[1]
		_r(x - 3, 1.2, x + 3, top - 5, render)
		_r(x - 3, 1.2, x + 3, 6, stone)
		_r(x - 0.6, top - 9, x + 0.6, top - 7, WIN)
		_poly([x - 3.4, top - 5, x + 3.4, top - 5, x, top], roof)
	# the gate
	_arched(8, 1.2, 2.6, 4.2, Color("4a3e36"))

## Näsinneula in Tampere: the slender concrete shaft rising from the trees by Lake Näsijärvi, the round observation
## deck and revolving restaurant at the top, the antenna mast above.
static func _tampere_nasinneula() -> void:
	_r(-9, 0, 9, 1.5, WATER)
	_poly([-9, 1.5, 9, 1.5, 9, 3.5, -9, 3.5], GRASS)
	for x in [-7.0, -4.5, 4.5, 7.0]:
		_spruce(x, 3, 5.0, PINE)
	# the shaft, tapering slightly
	_poly([-1.8, 3, 1.8, 3, 1.3, 62, -1.3, 62], CONCRETE)
	_poly([0.6, 3, 1.8, 3, 1.3, 62, 0.4, 62], CONCRETE_D)
	if _detail(1.0):
		for k in 8:
			var y := 8.0 + k * 6.5
			_l(-1.6 + k * 0.03, y, 1.6 - k * 0.03, y, CONCRETE_D, 0.1)
	# the top: the restaurant ring, the observation deck and the roof
	_poly([-2.2, 62, 2.2, 62, 6.5, 65, -6.5, 65], CONCRETE_D)
	_r(-6.8, 65, 6.8, 68.5, Color("3c5268"))
	_r(-6.8, 68.5, 6.8, 69.2, CONCRETE)
	_r(-5.8, 69.2, 5.8, 72, Color("4a6580"))
	_r(-6.2, 72, 6.2, 72.8, CONCRETE)
	_poly([-5.2, 72.8, 5.2, 72.8, 1.2, 74.5, -1.2, 74.5], CONCRETE_D)
	# the antenna
	_r(-0.45, 74.5, 0.45, 80, Color("d2cfc8"))
	_l(0, 80, 0, 83.5, Color("c43b32"), 0.18)
	_c(0, 83.6, 0.3, Color("e8453a"))

## Toripolliisi in Oulu: the stout bronze policeman with his cap and his hands behind his back on a low granite
## base, red wooden storehouses with white trim behind him on the market square.
static func _oulu_toripolliisi() -> void:
	_r(-11, 0, 11, 0.6, Color("9a968e"))
	# the red storehouses
	var red := Color("9c3a2c")
	for x0 in [-10.5, 2.5]:
		_r(x0, 0.6, x0 + 8, 5.2, red)
		_poly([x0 - 0.4, 5.2, x0 + 8.4, 5.2, x0 + 4, 7.4], Color("4f4a46"))
		_r(x0 + 2.8, 0.6, x0 + 5.2, 3.6, Color("6e2a20"))
		_l(x0, 5.2, x0 + 8, 5.2, WHITE, 0.15)
		_l(x0 + 0.1, 0.6, x0 + 0.1, 5.2, WHITE, 0.12)
		_l(x0 + 7.9, 0.6, x0 + 7.9, 5.2, WHITE, 0.12)
	# the low granite base
	_r(-1.4, 0.6, 1.4, 1.1, GRANITE)
	# the policeman: a round body in a long coat, legs apart, cap
	var bronze := Color("5a4b34")
	var bronze_l := Color("72603f")
	_r(-0.75, 1.1, -0.25, 2.0, bronze)
	_r(0.25, 1.1, 0.75, 2.0, bronze)
	_poly([-1.2, 1.9, 1.2, 1.9, 1.05, 3.6, 0.6, 4.2, -0.6, 4.2, -1.05, 3.6], bronze)
	_poly([0.3, 2.2, 1.05, 2.2, 0.95, 3.5, 0.5, 4.0], bronze_l)
	_c(0, 4.55, 0.48, bronze)
	_r(-0.55, 4.85, 0.55, 5.1, bronze)
	_poly([-0.5, 5.1, 0.5, 5.1, 0.42, 5.35, -0.42, 5.35], bronze_l)
	_r(-0.1, 3.0, 0.1, 3.9, bronze_l)

## Säynätsalo Town Hall (Alvar Aalto, 1952): red brick round a raised grass courtyard, the grassy steps on the left,
## the tall council chamber with its steep single-pitch roof, wooden window bands and the library wing below.
static func _jyvaskyla_saynatsalo() -> void:
	var brick := Color("9f4632")
	var brick_d := Color("7d3627")
	var wood := Color("6a5038")
	_poly([-20, 0, 20, 0, 20, 1, -20, 1], GRASS)
	# the library wing on the right
	_r(4, 1, 19, 7.5, brick)
	_r(4, 3.5, 19, 5.5, wood)
	_windows(5, 18, 3.8, 5.2, 6, Color("d9cfa8"))
	_r(3.6, 7.5, 19.4, 8.2, brick_d)
	# the courtyard wall and the grass steps
	_r(-18, 1, 4, 4.5, brick)
	for k in 5:
		_poly([-18 + k * 1.6, 1.0 + k * 0.7, -16.4 + k * 1.6, 1.0 + k * 0.7, -16.4 + k * 1.6, 1.7 + k * 0.7, -18 + k * 1.6, 1.7 + k * 0.7], Color("6aa04a"))
	_r(-10, 4.5, 4, 5.0, Color("6aa04a"))
	# the office wing behind the courtyard
	_r(-10, 5, 4, 10.5, brick)
	_r(-10, 7.2, 4, 8.8, wood)
	_windows(-9, 3, 7.4, 8.6, 6, Color("d9cfa8"))
	_r(-10.4, 10.5, 4.4, 11.1, brick_d)
	# the council chamber: a tall brick block under a steep single-pitch roof
	_r(-4, 5, 4, 15.5, brick)
	_r(-4, 5, -3, 15.5, brick_d)
	_poly([-4.4, 15.5, 4.4, 15.5, 4.4, 19.5], brick_d)
	_poly([-4.6, 15.3, 4.6, 19.3, 4.6, 19.8, -4.6, 15.8], Color("3e3a38"))
	if _detail(1.2):
		for k in 3:
			_r(-2.5 + k * 2.0, 12.5, -1.6 + k * 2.0, 14.0, wood)

## Puijo Tower in Kuopio: the wooded hill above Lake Kallavesi, the concrete tower with its tall shaft and the wide
## glazed top with the observation deck.
static func _kuopio_puijo() -> void:
	_r(-22, 0, 22, 2, WATER)
	# the hill
	_poly(_arc(0, 2, 22, 20, PI, 0, 16), Color("4f7f3c"))
	for p in [[-17.0, 2.0], [-13.0, 7.5], [-8.0, 12.0], [-3.5, 15.5], [4.0, 15.0], [9.0, 11.5], [14.0, 7.0], [18.0, 3.0]]:
		_spruce(p[0], p[1], 6.0, TREE)
	# the shaft
	var top := 22.0 + 30.0
	_poly([-2.0, 20, 2.0, 20, 1.6, top, -1.6, top], CONCRETE)
	_poly([0.6, 20, 2.0, 20, 1.6, top, 0.5, top], CONCRETE_D)
	# the top: three glazed rings widening upward, a flat roof and the mast
	_poly([-1.6, top, 1.6, top, 4.8, top + 2.2, -4.8, top + 2.2], CONCRETE_D)
	_r(-5.2, top + 2.2, 5.2, top + 5.0, Color("3f5870"))
	_r(-5.6, top + 5.0, 5.6, top + 5.6, CONCRETE)
	_r(-5.4, top + 5.6, 5.4, top + 8.2, Color("4e6a85"))
	_r(-5.9, top + 8.2, 5.9, top + 8.9, CONCRETE)
	_r(-0.35, top + 8.9, 0.35, top + 11.5, Color("d2cfc8"))

## The Lahti ski jumps on the Salpausselkä ridge: three white jumps side by side, the biggest with its tall inrun
## tower and lift, the landing slopes running down to the stadium.
static func _lahti_ski_jumps() -> void:
	_poly([-35, 0, 35, 0, 35, 6, 20, 8, -20, 8, -35, 5], Color("5e8a45"))
	for x in [-32.0, -28.0, 27.0, 31.0]:
		_spruce(x, 5.0, 7.0, TREE)
	# each jump: a tower on legs, the inrun sloping down, the landing slope to the stadium
	for j in [[-18.0, 22.0, 0.55], [-6.0, 34.0, 0.75], [10.0, 52.0, 1.0]]:
		var x: float = j[0]
		var top: float = j[1]
		var s: float = j[2]
		# the landing slope
		_poly([x - 2 * s, top * 0.36, x + 1 * s, top * 0.36, x + 24 * s, 1, x + 17 * s, 1], Color("e8ece8"))
		# the inrun on its frame
		_l(x - 6 * s, top - 1, x + 1 * s, top * 0.38, CONCRETE_D, 0.9 * s)
		_l(x - 6 * s, top, x - 6 * s, 2, CONCRETE, 1.4 * s)
		_l(x - 2.5 * s, top * 0.7, x - 2.5 * s, 2, CONCRETE, 0.8 * s)
		_l(x - 6 * s, top - 1.5, x + 0.6 * s, top * 0.39, WHITE, 0.6 * s)
		# the cabin on the top
		_r(x - 8 * s, top, x - 4 * s, top + 3 * s, WHITE)
		_r(x - 7.4 * s, top + 1 * s, x - 4.6 * s, top + 2.2 * s, Color("3f5870"))
	# the stadium stand at the foot
	_r(14, 1, 34, 3, Color("8c8c90"))
	_r(14, 3, 34, 3.6, Color("c43b32"))

## The Juselius Mausoleum in Pori: the grey granite neo-Gothic chapel with its pointed doorway, buttresses and rose
## window, the tall stone spire on the roof, pines round it in the cemetery.
static func _pori_juselius() -> void:
	_poly([-10, 0, 10, 0, 10, 1, -10, 1], GRASS)
	for x in [-8.5, 8.5]:
		_spruce(x, 1, 9.0, PINE)
	# the steps and the body
	_r(-6.5, 1, 6.5, 2, GRANITE_D)
	_r(-6, 2, 6, 11, GRANITE)
	for x in [-6.0, 5.0]:
		_poly([x, 2, x + 1, 2, x + 1, 11.5, x + 0.5, 12.2, x, 11.5], GRANITE_D)
	# the gable front
	_poly([-6, 11, 6, 11, 0, 16.5], GRANITE)
	_l(-6, 11, 0, 16.5, GRANITE_D, 0.3)
	_l(6, 11, 0, 16.5, GRANITE_D, 0.3)
	# the pointed door and the rose window
	_poly([-1.6, 2, 1.6, 2, 1.6, 6.2, 0, 8.4, -1.6, 6.2], Color("3d3530"))
	_c(0, 12.6, 1.3, Color("3d4a5a"))
	_c(0, 12.6, 0.5, Color("c7a446"))
	# the spire
	_r(-0.9, 16, 0.9, 17.5, GRANITE_D)
	_poly([-0.9, 17.5, 0.9, 17.5, 0, 23.4], GRANITE)
	_l(0, 23.4, 0, 24, DARK, 0.1)

## Joensuu Town Hall (Eliel Saarinen, 1914): the long pale rendered building under a dark steep roof, the arched
## ground floor, the tall square tower with its clock and the slender spire.
static func _joensuu_townhall() -> void:
	var wall := Color("e7dcc4")
	var wall_d := Color("cdbf9f")
	var roof := Color("4b4643")
	_r(-22, 0, 22, 0.8, Color("a8a49a"))
	# the main block
	_r(-21, 0.8, 14, 12, wall)
	_r(-21, 0.8, 14, 2.6, wall_d)
	for k in 7:
		_arched(-18.0 + k * 4.6, 0.8, 2.2, 3.8, Color("5a4c40"))
	_windows(-20, 13, 6, 8.6, 9, WIN)
	_poly([-21.6, 12, 14.6, 12, 12, 18, -19, 18], roof)
	# the gable with its round window
	_poly([-6, 12, 2, 12, -2, 17.5], wall)
	_c(-2, 14, 0.9, WIN)
	# the tower
	_r(14, 0.8, 20, 25, wall)
	_r(14, 0.8, 15, 25, wall_d)
	_arched(17, 0.8, 2.4, 4.4, Color("5a4c40"))
	_r(16.2, 9, 17.8, 12, WIN)
	_r(16.2, 15, 17.8, 18, WIN)
	_c(17, 22, 1.5, Color("f6f3ea"))
	_l(17, 22, 17, 23.1, DARK, 0.12)
	_l(17, 22, 17.8, 22, DARK, 0.12)
	_poly([13.6, 25, 20.4, 25, 18.6, 28, 15.4, 28], roof)
	_r(15.6, 28, 18.4, 30, wall_d)
	_poly([15.4, 30, 18.6, 30, 17, 35.6], roof)
	_l(17, 35.6, 17, 36, GOLD, 0.1)
