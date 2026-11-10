class_name LandmarksEeB
extends RefCounted
## Estonian landmarks (Valga to Kärdla), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const LIME := Color("c9c2b0")
const LIME_D := Color("a69f8e")
const CREAM := Color("efe2b8")
const WHITE := Color("f3f0e8")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const ROOF_D := Color("4a4d52")
const TILE := Color("a4452f")
const GRASS := Color("5d8f42")
const GRASS_D := Color("4b7a35")
const TREE := Color("3f6f34")
const SPRUCE := Color("2f5a33")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"ee_valga_church": _valga_church()
		"ee_voru_munamagi": _voru_munamagi()
		"ee_haapsalu_castle": _haapsalu_castle()
		"ee_paide_tower": _paide_tower()
		"ee_rapla_church": _rapla_church()
		"ee_polva_taevaskoja": _polva_taevaskoja()
		"ee_kardla_kopu": _kardla_kopu()
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

static func _ell(cx: float, cy: float, rx: float, ry: float, rot: float, col: Color) -> void:
	LandmarkPainter._ell(cx, cy, rx, ry, rot, col)

static func _arc(cx: float, cy: float, rx: float, ry: float, a0: float, a1: float, n: int) -> Array:
	return LandmarkPainter._arc_pts(cx, cy, rx, ry, a0, a1, n)

static func _detail(min_pm: float) -> bool:
	return LandmarkPainter._pm > min_pm

## An arched window or door: a rectangle under a half circle.
static func _arched(x: float, y0: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.5, y0, x + w * 0.5, y0, x + w * 0.5, y0 + h - w * 0.5] + _arc(x, y0 + h - w * 0.5, w * 0.5, w * 0.5, 0, PI, 6), col)

## A pointed (Gothic) window: a rectangle under a pointed top.
static func _pointed(x: float, y0: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.5, y0, x + w * 0.5, y0, x + w * 0.5, y0 + h - w * 0.7, x, y0 + h, x - w * 0.5, y0 + h - w * 0.7], col)

## A row of merlons on top of a wall from x0 to x1 at height y.
static func _merlons(x0: float, x1: float, y: float, h: float, n: int, col: Color) -> void:
	var step := (x1 - x0) / n
	for k in n:
		_r(x0 + step * k + step * 0.15, y, x0 + step * k + step * 0.65, y + h, col)

## A spruce: a dark narrow cone of three tiers on a short trunk.
static func _spruce(x: float, y: float, h: float) -> void:
	_r(x - h * 0.03, y, x + h * 0.03, y + h * 0.15, Color("4a3a2a"))
	for k in 3:
		var y0 := y + h * (0.12 + k * 0.26)
		var hw := h * (0.24 - k * 0.06)
		_poly([x - hw, y0, x + hw, y0, x, y0 + h * 0.42], SPRUCE)

## St John's Church in Valga: a pale yellow Neoclassical church on an oval plan, its long rounded roof, and the
## tower over the entrance with a small dome and a slim spire.
static func _valga_church() -> void:
	# the oval nave: rounded ends, a hipped roof rounded the same way
	_poly([-13, 0, 13, 0, 13, 9] + _arc(9, 9, 4, 3.4, 0, PI * 0.5, 4).slice(2) + _arc(-9, 9, 4, 3.4, PI * 0.5, PI, 4), CREAM)
	_poly([-13.4, 12.2, 13.4, 12.2, 9, 18.5, -9, 18.5], Color("7c7f78"))
	_r(-13.4, 11.8, 13.4, 12.4, Color("e2d3a6"))
	for x in [-9.0, -5.5, 5.5, 9.0]:
		_arched(x, 3.5, 1.6, 5, WIN)
	# the tower in front
	_r(-3.4, 0, 3.4, 22, CREAM)
	_r(-3.4, 0, -2.6, 22, Color("e2d3a6"))
	_arched(0, 0, 2.2, 4.4, Color("6b5040"))
	_arched(0, 8, 1.4, 3, WIN)
	_r(-3.8, 21.6, 3.8, 22.4, Color("e2d3a6"))
	_r(-2.6, 22.4, 2.6, 26.5, CREAM)
	_arched(0, 23, 1.2, 2.6, WIN)
	_poly(_arc(0, 26.5, 2.8, 2.6, 0, PI, 10), Color("5f7f6c"))
	_r(-0.5, 28.8, 0.5, 30.4, Color("5f7f6c"))
	_poly([-0.6, 30.4, 0.6, 30.4, 0, 37], Color("5f7f6c"))
	_l(0, 37, 0, 38, DARK, 0.12)

## Suur Munamägi: the forested hill, highest in the Baltic states, with the white observation tower and its glass
## lookout on top rising above the spruces.
static func _voru_munamagi() -> void:
	# the hill
	_poly([-20, 0, 20, 0, 14, 5, 6, 9, -6, 9.4, -14, 5.5], GRASS_D)
	# the tower
	_r(-2, 9, 2, 28, WHITE)
	_r(-2, 9, -1.2, 28, Color("d8d4ca"))
	if _detail(0.8):
		for y in [13.0, 17.0, 21.0, 25.0]:
			_r(-0.4, y, 0.4, y + 1.4, WIN)
	_r(-3.6, 27.6, 3.6, 28.4, Color("d8d4ca"))
	_r(-3.4, 28.4, 3.4, 32.6, Color("7fb0cc"))
	for x in [-1.7, 0.0, 1.7]:
		_r(x - 0.1, 28.4, x + 0.1, 32.6, Color("e8e6e0"))
	_r(-3.8, 32.6, 3.8, 33.4, Color("d8d4ca"))
	_poly([-3.6, 33.4, 3.6, 33.4, 0, 34], Color("8a8c86"))
	# spruces all round the hilltop, the tower's foot hidden among them
	for t in [[-17.0, 1.5, 7.0], [-12.0, 4.0, 8.5], [-7.0, 6.5, 9.0], [-3.5, 8.0, 7.5], [3.5, 8.0, 7.5],
			[7.5, 6.5, 9.0], [12.0, 4.0, 8.0], [17.0, 1.2, 7.0], [-9.5, 0.5, 8.0], [10.0, 0.5, 8.0], [0.0, 0.5, 7.0]]:
		_spruce(t[0], t[1], t[2])

## Haapsalu Castle: the ruined walls of the bishops' castle, the tall square watchtower, and the cathedral with its
## steep roof and the round baptistery tower where the White Lady appears.
static func _haapsalu_castle() -> void:
	# the ruined curtain wall
	_poly([14, 0, 29, 0, 29, 8, 26, 9, 22, 6.5, 18, 8.5, 14, 8], LIME_D)
	_poly([-29, 0, -14, 0, -14, 9, -20, 9.5, -26, 7.5, -29, 9], LIME_D)
	# the watchtower
	_r(-25, 0, -18, 30, LIME)
	_r(-25, 0, -24, 30, LIME_D)
	_r(-25.4, 30, -17.6, 30.8, LIME_D)
	_merlons(-25.4, -17.6, 30.8, 1.2, 4, LIME)
	for y in [12.0, 19.0, 25.0]:
		_r(-21.9, y, -21.1, y + 2.4, WIN)
	# the cathedral
	_r(-14, 0, 8, 14, LIME)
	_poly([-14.4, 14, 8.4, 14, 5, 22, -11, 22], ROOF_D)
	for x in [-10.5, -5.5, -0.5, 4.5]:
		_pointed(x, 4, 1.6, 7, WIN)
	_pointed(-12.2, 0, 1.6, 3, Color("4a4038"))
	# the round baptistery tower with its glowing window
	_r(8, 0, 13, 17, LIME)
	_r(12, 0, 13, 17, LIME_D)
	_poly([7.6, 17, 13.4, 17, 10.5, 22.5], ROOF_D)
	_pointed(10.5, 9, 1.4, 3.8, Color("f2ead0"))

## The Vallitorn in Paide: the octagonal tower of the Order castle on its grassy rampart hill, three of its faces
## turned to the road, slit windows and a low pointed roof.
static func _paide_tower() -> void:
	_poly([-12, 0, 12, 0, 8, 6, 3, 7.5, -3, 7.5, -8, 6], GRASS)
	_poly([-12, 0, -8, 6, -5, 6.8, -8, 0], GRASS_D)
	# three faces of the octagon
	var lit := Color("d4ccb8")
	var mid := Color("bdb5a1")
	var dark := Color("a29a87")
	_r(-6, 6.5, -2.6, 26, dark)
	_r(-2.6, 6.5, 2.6, 26, lit)
	_r(2.6, 6.5, 6, 26, mid)
	_r(-6.3, 25.6, 6.3, 26.6, LIME_D)
	for y in [11.0, 16.0, 21.0]:
		_r(-0.35, y, 0.35, y + 2.2, WIN)
		_r(3.9, y + 1, 4.5, y + 3, WIN)
	_r(-1, 6.5, 1, 9.5, Color("5a4a3a"))
	_poly([-6.3, 26.6, 6.3, 26.6, 0, 30], TILE)
	_poly([-6.3, 26.6, 0, 30, -2.6, 26.6], Color("7f3424"))

## The church of St Mary Magdalene in Rapla: grey stone walls under a steep roof and the two slender spires over
## the west front that are seen across the fields.
static func _rapla_church() -> void:
	var stone := Color("b9b4a8")
	var stone_d := Color("9d988c")
	# the nave behind
	_r(-14, 0, 14, 13, stone_d)
	_poly([-14.4, 13, 14.4, 13, 0, 22], ROOF_D)
	# the west front between the towers
	_r(-4, 0, 4, 16, stone)
	_poly([-4, 16, 4, 16, 0, 20], stone)
	_pointed(0, 0, 2.6, 5.6, Color("4a4038"))
	_c(0, 11, 1.4, WIN)
	# the twin towers and spires
	for x in [-6.5, 6.5]:
		_r(x - 2.6, 0, x + 2.6, 30, stone)
		_r(x - 2.6, 0, x - 1.8, 30, stone_d)
		_pointed(x, 8, 1, 3.6, WIN)
		_pointed(x, 17, 1, 3.6, WIN)
		_pointed(x - 0.9, 24.5, 0.8, 3, WIN)
		_pointed(x + 0.9, 24.5, 0.8, 3, WIN)
		_r(x - 2.9, 29.6, x + 2.9, 30.4, stone_d)
		_poly([x - 2.6, 30.4, x + 2.6, 30.4, x, 45], Color("4f5a58"))
		_l(x, 45, x, 46, DARK, 0.15)

## Suur Taevaskoda by Põlva: a red sandstone cliff over the dark Ahja river, its layers and caves showing, pines
## and spruces along the top.
static func _polva_taevaskoja() -> void:
	var sand := Color("c8714a")
	var sand_d := Color("a85a39")
	var sand_l := Color("dc8c62")
	_r(-30, 0, 30, 1.6, Color("3e5c6e"))
	_poly([-26, 1.6, 22, 1.6, 23, 6, 21, 12, 22, 17, 18, 20, 10, 21.5, 0, 22, -10, 21, -18, 19.5, -24, 16, -25, 9], sand)
	_poly([-26, 1.6, -25, 9, -24, 16, -18, 19.5, -20, 12, -22, 5], sand_d)
	# the layers of the rock
	if _detail(0.6):
		for y in [5.0, 9.0, 13.0, 17.0]:
			_l(-22 + y * 0.1, y, 20 - y * 0.05, y + 0.4, sand_l, 0.25)
	# the caves
	_poly(_arc(-6, 1.6, 3.2, 5, 0, PI, 10), Color("3a2a22"))
	_poly(_arc(7, 4, 1.6, 2.4, 0, PI, 8), Color("3a2a22"))
	# the bank and the forest on top
	_poly([22, 1.6, 30, 1.6, 30, 6, 23, 6], GRASS)
	_poly([-30, 1.6, -26, 1.6, -25, 9, -30, 9], GRASS)
	for x in [-22.0, -16.0, -9.0, -3.0, 4.0, 11.0, 17.0]:
		_spruce(x, 19.5 + (2.0 if absf(x) < 12 else 0.0), 6.5)
	for x in [-12.5, 0.5, 14.0]:
		_c(x, 24.5, 1.8, TREE)
	_c(27, 8.5, 2.4, TREE)

## The Kõpu lighthouse on Hiiumaa: the massive white tower, square and tapering, with its great corner
## buttresses, on its hill, and the lantern on top.
static func _kardla_kopu() -> void:
	_poly([-9, 0, 9, 0, 6, 3, -6, 3], GRASS)
	# the tower and its buttresses
	_poly([-6.6, 3, 6.6, 3, 3.2, 30, -3.2, 30], WHITE)
	_poly([-6.6, 3, -3.6, 3, -2.2, 30, -3.2, 30], Color("d8d4ca"))
	_poly([3.6, 3, 6.6, 3, 3.2, 30, 2.2, 30], Color("e4e0d6"))
	if _detail(0.8):
		for y in [9.0, 16.0, 23.0]:
			_r(-0.4, y, 0.4, y + 1.6, WIN)
	# the gallery, the lantern and its cap
	_r(-3.8, 30, 3.8, 30.8, DARK)
	_l(-3.8, 31.8, 3.8, 31.8, DARK, 0.12)
	_r(-1.8, 30.8, 1.8, 34.4, Color("e8d47a"))
	for x in [-0.9, 0.0, 0.9]:
		_r(x - 0.08, 30.8, x + 0.08, 34.4, DARK)
	_poly([-2.2, 34.4, 2.2, 34.4, 0, 37.2], Color("c0392b"))
	_l(0, 37.2, 0, 38, DARK, 0.12)
