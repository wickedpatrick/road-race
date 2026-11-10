class_name LandmarksUaC
extends RefCounted
## Ukrainian landmarks (Kremenchuk to Yaremche), drawn with LandmarkPainter's helpers (metres from the base point,
## y up).

const WHITE := Color("f4f1e8")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const GRASS := Color("5d8f42")
const TREE := Color("3f6f34")
const TREE_L := Color("5a8a3e")
const FIR := Color("2f5a3a")
const WATER := Color("3f86b8")
const WATER_L := Color("8cc0e0")
const GOLD := Color("e0b43a")
const ROCK := Color("8f8a80")
const BRICK := Color("a5452f")
const ROOF := Color("9c4a32")
const WOOD := Color("6b4a2f")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"kraz_truck": _kraz()
		"lutsk_castle": _lutsk_castle()
		"oleksandriia_park": _oleksandriia()
		"uzhhorod_wooden_church": _wooden_church()
		"kamianets_fortress": _kamianets()
		"palanok_castle": _palanok()
		"sofiyivka_park": _sofiyivka()
		"izmail_cathedral": _izmail_cathedral()
		"naftusya_pump_room": _pump_room()
		"probiy_waterfall": _probiy()
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

static func _arched(x: float, y0: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.5, y0, x + w * 0.5, y0, x + w * 0.5, y0 + h - w * 0.5] + _arc(x, y0 + h - w * 0.5, w * 0.5, w * 0.5, 0, PI, 6), col)

static func _tree(x: float, y: float, s: float, col: Color) -> void:
	_r(x - s * 0.08, y, x + s * 0.08, y + s * 0.5, Color("5b4632"))
	_c(x, y + s * 0.75, s * 0.42, col)
	_c(x - s * 0.25, y + s * 0.6, s * 0.3, col.darkened(0.08))
	_c(x + s * 0.27, y + s * 0.62, s * 0.3, col.lightened(0.06))

## A spruce: a dark green triangle of three tiers on a short trunk.
static func _fir(x: float, y: float, h: float) -> void:
	_r(x - h * 0.04, y, x + h * 0.04, y + h * 0.15, Color("4d3a2a"))
	for k in 3:
		var y0 := y + h * (0.12 + k * 0.25)
		var hw := h * (0.3 - k * 0.07)
		_poly([x - hw, y0, x + hw, y0, x, y0 + h * 0.42], FIR.lightened(k * 0.05))

## A small onion cupola with a cross, its base at y.
static func _onion(x: float, y: float, r: float, col: Color) -> void:
	_poly([x - r, y, x - r * 1.15, y + r * 0.7, x - r * 0.6, y + r * 1.4, x, y + r * 2.0, x + r * 0.6, y + r * 1.4, x + r * 1.15, y + r * 0.7, x + r, y], col)
	_l(x, y + r * 2.0, x, y + r * 2.0 + 1.6, GOLD, 0.15)
	_l(x - 0.45, y + r * 2.0 + 1.1, x + 0.45, y + r * 2.0 + 1.1, GOLD, 0.12)

## A KrAZ heavy tipper from Kremenchuk: the long orange bonnet, the cab, the steel dump body and three axles, on a
## low plinth as the town shows it.
static func _kraz() -> void:
	var o := Color("e07b24")
	var od := o.darkened(0.2)
	_r(-10, 0, 10, 0.6, Color("9b9686"))
	# chassis and wheels
	_r(-8.8, 1.9, 8.8, 2.6, DARK)
	for wx in [-6.4, 3.4, 6.6]:
		_c(wx, 1.9, 1.35, Color("26292d"))
		_c(wx, 1.9, 0.6, Color("8f969c"))
	# the bonnet with its grille, the cab
	_poly([-9.6, 2.6, -5.0, 2.6, -5.0, 5.6, -9.2, 5.4], o)
	_r(-9.7, 2.8, -9.2, 5.0, Color("3a3d40"))
	for k in 4:
		_l(-9.6, 3.2 + k * 0.5, -9.25, 3.2 + k * 0.5, Color("8f969c"), 0.08)
	_poly([-5.0, 2.6, -1.6, 2.6, -1.6, 8.2, -4.4, 8.2, -5.0, 5.6], o)
	_poly([-4.6, 5.6, -2.0, 5.6, -2.0, 7.6, -4.2, 7.6], Color("8fb0c8"))
	_r(-9.2, 5.3, -5.0, 5.6, od)
	_c(-9.1, 3.9, 0.3, Color("fff2b0"))
	# the dump body, ribbed
	_poly([-1.0, 2.8, 9.4, 2.8, 9.6, 7.4, -1.2, 8.6], Color("b8bcc0"))
	for k in 5:
		var x := 0.6 + k * 2.0
		_l(x, 2.9, x, 7.8 - k * 0.2, Color("8f969c"), 0.16)
	_poly([-1.2, 8.6, 1.0, 8.6, 1.0, 9.4, -1.6, 9.4], Color("b8bcc0"))
	_l(-0.8, 2.6, 9.0, 2.6, od, 0.25)

## Lubart's Castle in Lutsk: brick walls with battlements on the hill, the tall entry tower with its gate, the Styr
## tower and the bishop's tower at the corners.
static func _lutsk_castle() -> void:
	var b := BRICK
	var bd := b.darkened(0.18)
	_poly([-32, 0, -32, 3, -20, 4.5, 20, 4.5, 32, 3, 32, 0], GRASS)
	# the walls with battlements
	_r(-28, 4, 28, 15, b)
	var x := -28.0
	while x < 28.0:
		_r(x, 15, x + 1.2, 16.4, b)
		x += 2.4
	_r(-28, 13.6, 28, 14.2, bd)
	# the bishop's tower (left), the Styr tower (right)
	_r(-30, 4, -22, 22, bd)
	var tx := -30.0
	while tx < -22.0:
		_r(tx, 22, tx + 1.0, 23.3, bd)
		tx += 2.0
	_arched(-26, 15, 1.4, 3, DARK)
	_r(20, 4, 29, 25, b)
	tx = 20.0
	while tx < 29.0:
		_r(tx, 25, tx + 1.0, 26.4, b)
		tx += 2.0
	_arched(24.5, 18, 1.4, 3.4, DARK)
	_arched(24.5, 10, 1.4, 3.4, DARK)
	# the entry tower: tall, the gate at its foot, a little turret on top
	_r(-8, 4, 3, 30, b)
	_r(-8, 4, -7, 30, bd)
	_r(-8.6, 29.4, 3.6, 30.6, bd)
	tx = -8.6
	while tx < 3.6:
		_r(tx, 30.6, tx + 1.0, 32, b)
		tx += 2.0
	_arched(-2.5, 4, 4.2, 7, Color("3a2e24"))
	_arched(-2.5, 15, 1.4, 3.6, DARK)
	_arched(-2.5, 22, 1.4, 3.6, DARK)
	_r(-4.5, 32, -0.5, 34.5, b)
	_poly([-5, 34.5, 0, 34.5, -2.5, 36.5], ROOF.darkened(0.1))

## Oleksandriia Park in Bila Tserkva: the white semicircular Echo colonnade on the green slope above the pond, old
## trees around it.
static func _oleksandriia() -> void:
	_poly([-30, 0, -30, 6, -12, 8, 12, 8, 30, 6, 30, 0], GRASS)
	_r(-30, 0, 30, 3, WATER)
	_r(-30, 2.4, 30, 3, WATER_L)
	_tree(-22.4, 5, 13, TREE)
	_tree(21.8, 5, 14, TREE_L)
	_tree(-15, 7, 9, TREE_L)
	_tree(15, 7, 10, TREE)
	# the colonnade: columns along a half circle seen from the front, the curved entablature over them
	_r(-12, 8, 12, 9, Color("dcd7ca"))
	for k in 11:
		var a := PI * k / 10.0
		var x := -cos(a) * 10.5
		var front := sin(a)
		var col := WHITE.darkened(0.12 * (1.0 - front))
		_r(x - 0.4, 9, x + 0.4, 15.5, col)
	_poly(_arc(0, 15.5, 11.2, 1.4, PI, 0, 12) + _arc(0, 17.3, 11.2, 1.4, 0, PI, 12), WHITE)
	_r(-11.2, 15.5, 11.2, 17.3, WHITE)
	_r(-11.4, 17.0, 11.4, 17.5, Color("dcd7ca"))
	# the reflection in the pond
	_r(-10, 0.6, 10, 1.4, WHITE.darkened(0.25))

## A Lemko wooden church in the Uzhhorod open-air museum: three log sections stepping up to the west tower, shingled
## roofs, little onion cupolas, a cottage beside it.
static func _wooden_church() -> void:
	var w := WOOD
	var sh := Color("4b3524")
	_poly([-15, 0, -15, 1, 15, 1, 15, 0], GRASS)
	# the cottage
	_r(7, 1, 14, 6, Color("d9cfb8"))
	_poly([6, 6, 15, 6, 10.5, 10.5], Color("a68a52"))
	_r(9, 2.5, 10.6, 4.5, WIN)
	# the sanctuary (right), the nave (middle) and the tower (left)
	_r(2, 1, 6, 9, w)
	_poly([1.4, 9, 6.6, 9, 5.2, 12, 2.8, 12], sh)
	_poly([2.8, 12, 5.2, 12, 4.0, 14.5], sh)
	_onion(4, 14.5, 0.8, sh)
	_r(-5, 1, 2, 12, w.lightened(0.06))
	_poly([-5.8, 12, 2.8, 12, 1, 16, -4, 16], sh)
	_poly([-4, 16, 1, 16, -1.5, 19], sh)
	_onion(-1.5, 19, 1.0, sh)
	_r(-11, 1, -5, 16, w)
	_poly([-11.8, 16, -4.2, 16, -5.5, 18, -10.5, 18], sh)
	_r(-10, 18, -6, 23, w.darkened(0.05))
	for k in 3:
		_r(-9.5 + k * 1.3, 19.5, -9.0 + k * 1.3, 22, DARK)
	_poly([-10.8, 23, -5.2, 23, -6.2, 25, -9.8, 25], sh)
	_r(-9.2, 25, -6.8, 27, w.darkened(0.05))
	_poly([-9.8, 27, -6.2, 27, -8, 29.5], sh)
	_onion(-8, 29.5, 1.2, sh)
	# log lines and the door
	for y in range(2, 12, 2):
		_l(-11, y, 6, y, w.darkened(0.25), 0.1)
	_r(-9, 1, -7, 5, DARK)

## Kamianets-Podilskyi Fortress: towers with red cones and walls high on the rock above the Smotrych canyon, the
## arched castle bridge leading to it from the old town on the left.
static func _kamianets() -> void:
	# the canyon's rock
	_poly([-40, 0, -40, 12, -30, 14, -20, 15, 0, 16, 20, 15, 34, 13, 40, 9, 40, 0], ROCK)
	_poly([-40, 0, -40, 6, -25, 8, -10, 5, 10, 6, 30, 4, 40, 3, 40, 0], ROCK.darkened(0.15))
	_poly([-36, 0, -30, 3, -20, 0], TREE)
	_poly([20, 0, 30, 4, 38, 0], TREE)
	# the castle bridge from the left
	_r(-40, 12, -24, 14, Color("cfc8b4"))
	for x in [-37.0, -31.0]:
		_arched(x, 4, 3.6, 8.5, ROCK.darkened(0.3))
	var w := Color("ddd3bd")
	var wd := w.darkened(0.15)
	# the walls
	_r(-24, 14, 32, 22, w)
	_r(-24, 21.4, 32, 22, wd)
	# the towers: round ones with red cones, a square one
	var towers := [[-24.0, 3.5, 30.0, 36.0], [-10.0, 3.0, 27.0, 33.0], [2.0, 4.0, 34.0, 41.0], [16.0, 3.0, 28.0, 34.0], [30.0, 3.5, 29.0, 35.0]]
	for t in towers:
		var tx: float = t[0]
		var tr: float = t[1]
		var top: float = t[2]
		var cone: float = t[3]
		_r(tx - tr, 14, tx + tr, top, w)
		_r(tx - tr, 14, tx - tr + 0.8, top, wd)
		_arched(tx, top - 6, 0.9, 2.2, DARK)
		_arched(tx, top - 12, 0.9, 2.2, DARK)
		_poly([tx - tr - 0.5, top, tx + tr + 0.5, top, tx, cone], ROOF)
		_l(tx, cone, tx, cone + 1.4, DARK, 0.15)

## Palanok Castle above Mukachevo: the volcanic hill rising out of the plain, the white walls climbing it in tiers with
## red roofs, the upper castle's tower on top.
static func _palanok() -> void:
	_poly([-28, 0, -24, 4, -16, 10, -8, 14, 8, 14, 16, 10, 24, 4, 28, 0], GRASS)
	_poly([8, 14, 16, 10, 24, 4, 28, 0, 14, 0], GRASS.darkened(0.12))
	_tree(-21, 2.5, 6, TREE)
	_tree(20, 3, 6, TREE)
	var w := Color("eee6d2")
	# the lower walls
	_poly([-17, 9, 17, 9, 17, 13, -17, 13], w)
	_r(-17, 12.4, 17, 13, w.darkened(0.15))
	for x in [-17.0, 17.0]:
		_r(x - 1.8, 8, x + 1.8, 15, w)
		_poly([x - 2.2, 15, x + 2.2, 15, x, 18], ROOF)
	# the middle and upper castle
	_r(-11, 13, 11, 20, w)
	_poly([-11.6, 20, 11.6, 20, 9, 23, -9, 23], ROOF)
	_windows(-10, 10, 15, 18, 7, WIN)
	_r(-6, 20, 6, 26, w)
	_poly([-6.6, 26, 6.6, 26, 4.6, 28.5, -4.6, 28.5], ROOF)
	_windows(-5, 5, 22, 24.5, 4, WIN)
	_r(-1.8, 26, 1.8, 32, w)
	_poly([-2.3, 32, 2.3, 32, 0, 35.5], ROOF)
	_l(0, 35.5, 0, 37, DARK, 0.15)
	_r(0, 36, 1.4, 37, Color("0057b7"))

## Sofiyivka Park in Uman: grey rocks piled over a waterfall into the pond, the little white Flora pavilion with its
## columns on the cliff, trees all around.
static func _sofiyivka() -> void:
	_r(-30, 0, 30, 3.5, WATER)
	_r(-30, 2.9, 30, 3.5, WATER_L)
	_tree(-23, 3.5, 12, TREE)
	_tree(22.4, 3.5, 13, TREE_L)
	_tree(11, 8, 10, TREE)
	# the rocks
	_poly([-20, 3.5, -18, 10, -12, 14, -4, 13, 2, 16, 8, 12, 12, 8, 14, 3.5], ROCK)
	_poly([-12, 14, -8, 9, -4, 13], ROCK.darkened(0.15))
	_poly([2, 16, 4, 9, 8, 12], ROCK.darkened(0.15))
	_poly([-18, 3.5, -14, 6, -10, 3.5], ROCK.darkened(0.25))
	# the waterfall
	_poly([-3, 12.5, 1, 12.5, 2.4, 3.5, -4.4, 3.5], Color("dceef6"))
	for k in 4:
		_l(-2.4 + k * 1.2, 12, -3.4 + k * 1.8, 3.8, WATER_L, 0.18)
	_c(-1, 3.6, 2.6, WHITE)
	# the pavilion of Flora on the cliff
	_r(-15, 13.3, -6, 14, Color("dcd7ca"))
	for k in 4:
		var x := -14.0 + k * 2.4
		_r(x - 0.3, 14, x + 0.3, 18.5, WHITE)
	_r(-15.2, 18.5, -5.8, 19.5, WHITE)
	_poly(_arc(-10.5, 19.5, 4.3, 2.4, 0, PI, 10), Color("e3ddcf"))

## The Intercession Cathedral in Izmail: the classical church with its columned portico, the green dome on its drum,
## smaller domes at the corners and the bell tower with a spire over the entrance.
static func _izmail_cathedral() -> void:
	var w := Color("efe6cf")
	var wd := w.darkened(0.14)
	var dome := Color("4f8f78")
	# the body
	_r(-12, 0, 21, 16, w)
	_r(-12.4, 15.6, 21.4, 16.6, wd)
	for x in [-1.0, 6.0, 13.0, 18.0]:
		_arched(x, 4, 1.8, 7, WIN)
	# the corner domes and the main dome
	for x in [-6.0, 17.0]:
		_r(x - 2.2, 16.6, x + 2.2, 20, w)
		_poly(_arc(x, 20, 2.4, 2.8, 0, PI, 10), dome)
		_l(x, 22.8, x, 24.6, GOLD, 0.18)
	_r(1.5, 16.6, 12.5, 26, w)
	for k in 3:
		_arched(4 + k * 3, 18, 1.2, 5, WIN)
	_r(1.1, 26, 12.9, 27, wd)
	_poly(_arc(7, 27, 6.2, 7, 0, PI, 14), dome)
	_r(6.2, 33.8, 7.8, 35.5, dome.darkened(0.1))
	_l(7, 35.5, 7, 38.5, GOLD, 0.25)
	_l(6, 37.5, 8, 37.5, GOLD, 0.2)
	# the bell tower over the west portico
	_r(-20, 0, -12, 28, w)
	_poly([-21, 13, -11, 13, -16, 16.5], wd)
	for x in [-19.0, -17.0, -15.0, -13.0]:
		_r(x - 0.35, 0.5, x + 0.35, 12.5, WHITE)
	_r(-20.5, 12.5, -11.5, 13, wd)
	_arched(-16, 18, 2.4, 6, WIN)
	_r(-20.4, 27.6, -11.6, 28.4, wd)
	_r(-18.5, 28.4, -13.5, 33, w)
	_arched(-16, 29.2, 1.6, 3.2, WIN)
	_poly(_arc(-16, 33, 2.8, 2.6, 0, PI, 8), dome)
	_poly([-16.6, 35.4, -15.4, 35.4, -16, 41], dome.darkened(0.1))
	_l(-16, 41, -16, 43, GOLD, 0.2)

## The Naftusya pump room in Truskavets: a pale pavilion with a colonnade and a glass front under a shallow dome, the
## round drinking fountain before it and spa guests' lamps along the path.
static func _pump_room() -> void:
	var w := Color("f0ead8")
	var wd := w.darkened(0.14)
	_r(-20, 0, 20, 1, Color("c9c2ad"))
	_tree(-15.4, 1, 8, TREE)
	_tree(15.4, 1, 8, TREE_L)
	# the hall
	_r(-12, 1, 12, 11, w)
	_r(-9, 2, 9, 9.5, Color("8fb0c8"))
	for k in 7:
		var x := -9.0 + k * 3.0
		_r(x - 0.45, 1, x + 0.45, 10.4, WHITE)
	_r(-12.4, 10.4, 12.4, 11.6, wd)
	_r(-7, 11.6, 7, 13.4, w)
	_poly(_arc(0, 13.4, 6.4, 3.2, 0, PI, 12), Color("8d9a94"))
	_l(0, 16.6, 0, 18, DARK, 0.15)
	# the drinking fountain in front
	_r(-3, 1, 3, 2, Color("b9b4a8"))
	_r(-0.4, 2, 0.4, 4, Color("b9b4a8"))
	_c(0, 4.3, 0.9, WATER_L)
	for x in [-13.4, 13.4]:
		_l(x, 1, x, 5, DARK, 0.15)
		_c(x, 5.2, 0.4, Color("fff2b0"))

## The Probiy waterfall in Yaremche: the Prut tumbling white through a cleft in grey rock, a wooden footbridge across
## above it and spruces on both banks.
static func _probiy() -> void:
	_r(-18, 0, 18, 3, WATER)
	_r(-18, 2.4, 18, 3, WHITE)
	# the rocks on both sides of the cleft
	_poly([-18, 3, -18, 12, -12, 14, -5, 12, -3, 3], ROCK)
	_poly([18, 3, 18, 11, 12, 13, 5, 11, 3, 3], ROCK)
	_poly([-12, 14, -9, 8, -5, 12], ROCK.darkened(0.15))
	_poly([12, 13, 9, 7, 5, 11], ROCK.darkened(0.15))
	_poly([-18, 3, -14, 6, -10, 3], ROCK.darkened(0.25))
	# the falls
	_poly([-5, 12, 5, 11, 3, 3, -3, 3], Color("dceef6"))
	for k in 5:
		_l(-4 + k * 2, 11.5, -2.4 + k * 1.2, 3.2, WATER_L, 0.25)
	_c(-1.6, 3.4, 1.8, WHITE)
	_c(1.8, 3.2, 1.5, WHITE)
	# the footbridge
	_r(-8, 13.2, 8, 14, WOOD)
	_l(-8, 15.6, 8, 15.6, WOOD.darkened(0.2), 0.25)
	for k in 9:
		_l(-8 + k * 2, 14, -8 + k * 2, 15.6, WOOD.darkened(0.2), 0.15)
	# spruces on the banks
	_fir(-15, 12, 9)
	_fir(-10, 13.5, 7)
	_fir(14, 11, 10)
	_fir(10, 12.6, 7)
