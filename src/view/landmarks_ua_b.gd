class_name LandmarksUaB
extends RefCounted
## Ukrainian landmarks (Poltava to Kropyvnytskyi), drawn with LandmarkPainter's helpers (metres from the base point,
## y up).

const WHITE := Color("f4f1e8")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const GRASS := Color("5d8f42")
const TREE := Color("3f6f34")
const TREE_L := Color("5a8a3e")
const WATER := Color("3f86b8")
const WATER_L := Color("8cc0e0")
const GOLD := Color("e0b43a")
const BRONZE := Color("5d6b4f")
const BRICK := Color("a8503a")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"poltava_white_arbour": _white_arbour()
		"khmelnytskyi_hetman": _hetman()
		"cherkasy_dam": _cherkasy_dam()
		"chernivtsi_residence": _residence()
		"zhytomyr_rocket": _rocket()
		"sumy_trinity": _sumy_trinity()
		"rivne_tunnel_of_love": _tunnel_of_love()
		"frankivsk_ratusha": _ratusha()
		"ternopil_castle": _ternopil_castle()
		"elizabeth_fortress": _elizabeth_fortress()
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

## A leafy tree: trunk and a few overlapping crowns.
static func _tree(x: float, y: float, s: float, col: Color) -> void:
	_r(x - s * 0.08, y, x + s * 0.08, y + s * 0.5, Color("5b4632"))
	_c(x, y + s * 0.75, s * 0.42, col)
	_c(x - s * 0.25, y + s * 0.6, s * 0.3, col.darkened(0.08))
	_c(x + s * 0.27, y + s * 0.62, s * 0.3, col.lightened(0.06))

## The White Arbour in Poltava: a round white colonnade under a low dome on the edge of the bluff, trees around it and
## the Vorskla valley falling away below.
static func _white_arbour() -> void:
	# the bluff falling to the right
	_poly([-22, 0, -22, 7, -6, 7.5, 10, 7, 16, 4, 22, 1.5, 22, 0], GRASS)
	_poly([10, 7, 16, 4, 22, 1.5, 22, 0, 12, 0], GRASS.darkened(0.12))
	_tree(-18, 7, 9, TREE)
	_tree(18, 1.5, 6, TREE_L)
	# the steps and the round floor
	_r(-9, 7, 9, 8, Color("d8d3c6"))
	_r(-8, 8, 8, 9, WHITE)
	# columns around the ring: those at the sides stand closer together
	for k in 7:
		var a := PI * (k + 0.5) / 7.0
		var x := -cos(a) * 7.0
		_r(x - 0.45, 9, x + 0.45, 17.5, WHITE)
		_r(x - 0.7, 9, x + 0.7, 9.6, Color("dcd7ca"))
		_r(x - 0.7, 17.0, x + 0.7, 17.6, Color("dcd7ca"))
	# the entablature and the low dome
	_r(-8, 17.6, 8, 19.4, WHITE)
	_r(-8.3, 19.4, 8.3, 20, Color("d8d3c6"))
	_poly(_arc(0, 20, 7.6, 3.6, 0, PI, 14), Color("e9e6dc"))
	_r(-0.6, 23.4, 0.6, 24.6, WHITE)

## The monument to Bohdan Khmelnytsky in Khmelnytskyi: the bronze hetman in his long coat and fur cap, the mace raised
## in his right hand, on a granite pedestal.
static func _hetman() -> void:
	var gran := Color("8d8a86")
	_r(-5, 0, 5, 1.2, gran.darkened(0.15))
	_r(-3.8, 1.2, 3.8, 8.2, gran)
	_r(-4.3, 8.2, 4.3, 9, gran.darkened(0.1))
	_r(-2.4, 3.6, 2.4, 5.2, GOLD.darkened(0.25))
	var b := BRONZE
	# boots and the long coat
	_r(-1.3, 9, -0.4, 10.6, b.darkened(0.2))
	_r(0.4, 9, 1.3, 10.6, b.darkened(0.2))
	_poly([-1.9, 10.4, 1.9, 10.4, 1.4, 15.8, -1.4, 15.8], b)
	_poly([-1.9, 10.4, -1.1, 10.4, -1.2, 15.8, -1.6, 15.8], b.darkened(0.15))
	_r(-1.5, 13.0, 1.5, 13.5, GOLD.darkened(0.35))
	# the cloak over the shoulders
	_poly([-1.6, 15.8, -2.5, 11.5, -1.9, 10.6, -1.0, 15.8], b.darkened(0.1))
	# the arms: the left at the sabre, the right raised with the mace
	_l(-1.4, 15.4, -1.9, 12.6, b, 0.55)
	_l(-1.9, 12.6, -1.5, 10.2, DARK, 0.18)
	_l(1.4, 15.4, 2.6, 17.4, b, 0.55)
	_l(2.6, 17.4, 3.0, 19.8, b, 0.45)
	_l(3.0, 19.4, 3.3, 21.4, b.darkened(0.25), 0.22)
	_c(3.35, 21.6, 0.45, b.darkened(0.25))
	# head, moustache and fur cap
	_c(0, 16.7, 0.75, b.lightened(0.08))
	_r(-0.5, 16.2, 0.5, 16.4, b.darkened(0.3))
	_poly([-0.85, 17.1, 0.85, 17.1, 0.6, 18.3, -0.7, 18.0], b.darkened(0.25))

## The dam road at Cherkasy: a long embankment with its lamps running out over the wide Kremenchuk Reservoir, the
## bridge spans in the middle and a sail on the water.
static func _cherkasy_dam() -> void:
	_r(-50, 0, 50, 6, WATER)
	_r(-50, 5.2, 50, 6, WATER_L)
	for k in 6:
		_r(-46 + k * 17, 2 + (k % 2), -40 + k * 17, 2.3 + (k % 2), WATER_L)
	# the embankment on both sides of the bridge
	_poly([-50, 6, -16, 6, -16, 9, -50, 9.6], Color("c9c2ad"))
	_poly([16, 6, 50, 6, 50, 9.6, 16, 9], Color("c9c2ad"))
	_poly([-50, 9.6, -16, 9, -16, 9.6, -50, 10.4], Color("6f7378"))
	_poly([16, 9, 50, 9.6, 50, 10.4, 16, 9.6], Color("6f7378"))
	# the bridge: a deck on piers over the gap
	_r(-16, 8.6, 16, 9.8, Color("a7a39a"))
	for k in 5:
		var x := -16.0 + k * 8.0
		_r(x - 0.6, 6, x + 0.6, 8.6, Color("8f8b82"))
		_poly(_arc(x + 4.0, 8.6, 3.4, 1.4, PI, TAU, 8), WATER.darkened(0.05))
	_l(-16, 10.6, 16, 10.6, DARK, 0.15)
	# lamp posts all the way
	for k in 13:
		var x := -48.0 + k * 8.0
		var y := 9.6 + absf(x) / 50.0 * 0.6
		_l(x, y, x, y + 4.0, DARK, 0.18)
		_l(x, y + 4.0, x + 0.8, y + 4.0, DARK, 0.15)
		_c(x + 0.9, y + 3.8, 0.3, Color("fff2b0"))
	# a sailing boat
	_poly([30, 3, 38, 3, 37, 2, 31, 2], WHITE)
	_poly([34, 3.2, 34, 10, 37.5, 3.2], WHITE)
	_poly([33.6, 3.2, 33.6, 8.5, 31, 3.2], Color("e8e2d0"))

## The Residence of the Bukovinian Metropolitans in Chernivtsi: red brick halls with white bands and roofs of green,
## yellow and brown glazed tiles in patterns, the gate tower in the middle and the seminary church's dome at the side.
static func _residence() -> void:
	var b := BRICK
	var band := Color("efe4cc")
	var roof := Color("3f7a55")
	var tile := Color("d9b24a")
	# the side halls
	for sg in [-1.0, 1.0]:
		var x0: float = minf(sg * 38.0, sg * 8.0)
		var x1: float = maxf(sg * 38.0, sg * 8.0)
		_r(x0, 0, x1, 16, b)
		for y in [5.0, 10.5]:
			_r(x0, y, x1, y + 0.6, band)
		_windows(x0 + 1, x1 - 1, 1.6, 4.4, 8, WIN)
		_windows(x0 + 1, x1 - 1, 6.6, 9.8, 8, WIN)
		_windows(x0 + 1, x1 - 1, 11.8, 15, 8, WIN)
		# the steep patterned roof
		_poly([x0 - 0.5, 16, x1 + 0.5, 16, x1 - 3, 23, x0 + 3, 23], roof)
		var k := 0
		var x := x0 + 1.5
		while x < x1 - 2.0:
			_poly([x, 17.4, x + 1.2, 18.8, x, 20.2, x - 1.2, 18.8], tile if k % 2 == 0 else Color("8a5a32"))
			x += 3.0
			k += 1
		_r(x0 + 3, 21.4, x1 - 3, 22.0, tile)
	# the seminary church's green dome on the right
	_r(26, 16, 34, 24, b)
	_r(26, 20, 34, 20.6, band)
	_poly(_arc(30, 24, 4.6, 5.2, 0, PI, 12), roof)
	_l(30, 29.2, 30, 32, GOLD, 0.25)
	_l(29, 31, 31, 31, GOLD, 0.2)
	# the gate tower
	_r(-7, 0, 7, 26, b)
	for y in [6.0, 13.0, 20.0]:
		_r(-7, y, 7, y + 0.6, band)
	_arched(0, 0, 4.4, 6, Color("4a3a2a"))
	_arched(0, 8, 2.6, 4, WIN)
	_arched(-3.6, 14.4, 1.4, 4, WIN)
	_arched(3.6, 14.4, 1.4, 4, WIN)
	_arched(0, 14.4, 1.4, 4, WIN)
	_r(-7.6, 26, 7.6, 27.2, band)
	_poly([-7.6, 27.2, 7.6, 27.2, 5, 31, -5, 31], roof)
	_poly(_arc(0, 31, 3.6, 4.0, 0, PI, 10), tile)
	_l(0, 35, 0, 37.5, GOLD, 0.25)

## The rocket at the Korolyov Museum of Cosmonautics in Zhytomyr: the white core stage with its pointed nose, the four
## flaring boosters at its foot and the launch frame, the museum's low hall beside it.
static func _rocket() -> void:
	# the museum hall
	_r(3, 0, 10, 5, Color("d9d6cf"))
	_r(3, 3.6, 10, 4.2, Color("6b7f96"))
	_r(2.6, 5, 10.4, 5.6, Color("b9b4a8"))
	# the launch frame
	_r(-6, 0, 6, 1.2, Color("8f8b82"))
	for x in [-5.0, 5.0]:
		_l(x, 1.2, x * 0.55, 6, Color("8f8b82"), 0.35)
	var w := Color("f2f2ee")
	var g := Color("c8ccd0")
	# the boosters: cones narrowing upwards, the nozzles at the foot
	for sg in [-1.0, 1.0]:
		_poly([sg * 1.6, 2, sg * 3.6, 2, sg * 1.7, 20, sg * 1.5, 20], w if sg < 0.0 else g)
		_poly([sg * 3.6, 2, sg * 3.6, 3.4, sg * 2.4, 3.4], g)
		_r(minf(sg * 2.2, sg * 3.2), 1.2, maxf(sg * 2.2, sg * 3.2), 2, DARK)
	# the core stage, the upper stage and the nose
	_r(-1.6, 2, 1.6, 30, w)
	_r(0.6, 2, 1.6, 30, g)
	_r(-1.8, 30, 1.8, 30.6, DARK)
	_r(-1.3, 30.6, 1.3, 36, w)
	_r(0.4, 30.6, 1.3, 36, g)
	_poly([-1.3, 36, 1.3, 36, 0, 42], Color("dfe3e6"))
	_r(-1.6, 12, 1.6, 12.6, Color("c8102e"))
	_r(-0.6, 20, 0.6, 26, Color("0057b7"))

## The Holy Trinity Cathedral in Sumy: the yellow church with its columned portico, the tall drum ringed with columns
## and the great gilded dome, the bell tower's gilded cupola on the left.
static func _sumy_trinity() -> void:
	var y := Color("e9cf7a")
	var yd := y.darkened(0.15)
	# the bell tower
	_r(-20, 0, -13, 24, y)
	_r(-20.4, 23.6, -12.6, 24.4, WHITE)
	_arched(-16.5, 15, 2.2, 6, WIN)
	_arched(-16.5, 5, 1.6, 5, WIN)
	_poly(_arc(-16.5, 24.4, 3.0, 4.2, 0, PI, 10), GOLD)
	_l(-16.5, 28.6, -16.5, 31.2, GOLD, 0.22)
	_l(-17.3, 30.4, -15.7, 30.4, GOLD, 0.18)
	# the church body and portico
	_r(-13, 0, 19, 17, y)
	_r(-13.4, 16.4, 19.4, 17.4, WHITE)
	for x in [-10.0, 15.0]:
		_arched(x, 4, 1.8, 7, WIN)
	_poly([-6.5, 17.4, 12.5, 17.4, 3, 21.5], y)
	_poly([-6.5, 17.4, 12.5, 17.4, 12, 17.9, -6, 17.9], WHITE)
	for k in 6:
		var x := -5.0 + k * 3.6
		_r(x - 0.45, 1, x + 0.45, 16.4, WHITE)
	_r(-6.5, 0, 12.5, 1, WHITE)
	_arched(3, 1, 2.4, 6, Color("4a3a2a"))
	# the drum with its columns and the gilded dome
	_r(-6, 21.5, 12, 23, yd)
	_r(-5, 23, 11, 31, y)
	for k in 7:
		var x := -4.0 + k * 2.33
		_r(x - 0.3, 23, x + 0.3, 31, WHITE)
	for k in 3:
		_arched(-1.0 + k * 4.0, 24.5, 1.1, 4.5, WIN)
	_r(-5.5, 31, 11.5, 32, WHITE)
	_poly(_arc(3, 32, 8, 8.5, 0, PI, 16), GOLD)
	_r(1.8, 40.3, 4.2, 42.4, GOLD.darkened(0.1))
	_l(3, 42.4, 3, 45.5, GOLD, 0.25)
	_l(2, 44.5, 4, 44.5, GOLD, 0.2)

## The Tunnel of Love near Klevan: a railway line running into a long arch of trees, the green walls narrowing into the
## distance to a bright spot of light.
static func _tunnel_of_love() -> void:
	_poly([-25, 0, -25, 12, -20, 17, -10, 20, 10, 20, 20, 17, 25, 12, 25, 0], TREE.darkened(0.1))
	for c in [[-20.0, 13.0, 5.0], [-12.0, 17.0, 5.5], [0.0, 18.5, 6.0], [12.0, 17.0, 5.5], [20.0, 13.0, 5.0]]:
		_c(c[0], c[1], c[2], TREE)
	# the tunnel's rings getting smaller and lighter towards the far end
	var cols := [Color("2f5a28"), Color("3c6d31"), Color("4f823d"), Color("6a9a4c"), Color("8fb866"), Color("d6e8a8")]
	for k in 6:
		var s := 1.0 - k * 0.17
		var cy := 0.6 + k * 0.9
		var rx := 14.0 * s
		var ry := 14.0 * s
		_poly([-rx, cy] + _arc(0, cy, rx, ry, PI, 0, 16) + [rx, cy], cols[k])
	_poly([-13, 0, 13, 0, 1.6, 5.2, -1.6, 5.2], Color("8b7d62"))
	# the rails and sleepers converging
	for k in 7:
		var t := float(k) / 7.0
		var hw := lerpf(9.0, 1.4, t)
		var yy := lerpf(0.3, 5.0, t)
		_l(-hw, yy, hw, yy, Color("5b4632"), lerpf(0.5, 0.12, t))
	for sg in [-1.0, 1.0]:
		_l(sg * 6.5, 0, sg * 0.9, 5.2, Color("6f7378"), 0.28)

## The town hall of Ivano-Frankivsk: the white 1930s constructivist hall with its tower rising in steps to a spire,
## tall narrow windows and the clock.
static func _ratusha() -> void:
	var w := Color("ecebe5")
	var wd := w.darkened(0.12)
	# the low wings around the tower
	_r(-15, 0, 15, 10, w)
	_r(-15.4, 9.6, 15.4, 10.4, wd)
	_windows(-14, -6, 2, 8, 4, WIN)
	_windows(6, 14, 2, 8, 4, WIN)
	_r(-11, 10.4, 11, 14, w)
	_windows(-10, 10, 11, 13.2, 8, WIN)
	# the tower in steps
	_r(-5, 0, 5, 36, w)
	_r(-5, 0, -4.2, 36, wd)
	_r(-3.2, 0, 3.2, 4, Color("4a3a2a"))
	for k in 3:
		_r(-2.6 + k * 2.2, 15, -1.8 + k * 2.2, 29, Color("5f7890"))
	_c(0, 32.5, 1.9, wd)
	_c(0, 32.5, 1.6, WHITE)
	_l(0, 32.5, 0, 33.8, DARK, 0.18)
	_l(0, 32.5, 0.9, 32.5, DARK, 0.18)
	_r(-5.4, 35.6, 5.4, 36.4, wd)
	_r(-3.5, 36.4, 3.5, 41, w)
	_r(-1.8, 37.2, 1.8, 40.2, Color("5f7890"))
	_r(-2.1, 41, 2.1, 44, wd)
	_poly([-1.4, 44, 1.4, 44, 0, 49], Color("8f969c"))
	_l(0, 49, 0, 51.5, DARK, 0.15)

## Ternopil Castle on the pond: the long two-storey castle of the Tarnowskis with its round corner tower, trees and a
## white pleasure boat on the water.
static func _ternopil_castle() -> void:
	_r(-30, 0, 30, 4, WATER)
	_r(-30, 3.4, 30, 4, WATER_L)
	_r(-30, 4, 30, 5, Color("9b9686"))
	_tree(-24, 5, 10, TREE)
	_tree(23.6, 5, 11, TREE_L)
	var w := Color("efe2c4")
	var roof := Color("9c4a32")
	_r(-18, 5, 16, 15, w)
	_r(-18.4, 9.6, 16.4, 10.2, w.darkened(0.12))
	_windows(-12, 15, 6, 8.8, 9, WIN)
	_windows(-12, 15, 11, 13.8, 9, WIN)
	_poly([-18.6, 15, 16.6, 15, 14.6, 19, -16.6, 19], roof)
	_r(-1, 15, 3, 21, w)
	_poly([-1.4, 21, 3.4, 21, 1, 23.6], roof)
	# the round tower at the corner
	_r(-21, 5, -13, 19, w.darkened(0.04))
	_r(-21, 5, -19.6, 19, w.darkened(0.12))
	_arched(-17, 12, 1.4, 3.4, WIN)
	_arched(-17, 7, 1.4, 3.4, WIN)
	_poly([-21.6, 19, -12.4, 19, -17, 25.5], roof)
	_l(-17, 25.5, -17, 27.5, DARK, 0.18)
	# the boat
	_poly([4, 1.4, 14, 1.4, 15.5, 2.8, 2.6, 2.8], WHITE)
	_r(6, 2.8, 12, 4.4, WHITE)
	_r(6.4, 3.4, 11.6, 4.0, Color("5f7890"))
	_r(5.8, 4.4, 12.2, 4.8, Color("c8102e"))

## The Fortress of St Elizabeth in Kropyvnytskyi: grassy star-shaped ramparts with their pointed bastions above the
## moat, the brick gate with its arch and pediment, trees on the walls.
static func _elizabeth_fortress() -> void:
	_r(-35, 0, 35, 2.4, WATER)
	_r(-35, 1.8, 35, 2.4, WATER_L)
	# the ramparts: pointed bastions coming forward, the curtain walls between them
	_poly([-35, 2.4, -35, 8, -29, 9, -26, 12.5, -20, 9, -10, 9.4, -6, 12.5, 6, 12.5, 10, 9.4, 20, 9, 26, 12.5, 29, 9, 35, 8, 35, 2.4], GRASS)
	_poly([-26, 2.4, -26, 12.5, -20, 9, -16, 2.4], GRASS.darkened(0.12))
	_poly([26, 2.4, 26, 12.5, 29, 9, 33, 2.4], GRASS.darkened(0.12))
	_poly([-35, 2.4, -26, 2.4, -26, 4.2, -35, 4.2], GRASS.darkened(0.2))
	_l(-35, 8, -29, 9, GRASS.lightened(0.15), 0.3)
	_l(-29, 9, -26, 12.5, GRASS.lightened(0.15), 0.3)
	_l(-26, 12.5, -20, 9, GRASS.lightened(0.15), 0.3)
	_l(20, 9, 26, 12.5, GRASS.lightened(0.15), 0.3)
	_l(26, 12.5, 29, 9, GRASS.lightened(0.15), 0.3)
	for x in [-31.0, -14.0, 14.0, 31.0]:
		_tree(x, 9.0, 6.0, TREE)
	# the gate
	var b := Color("b5533a")
	_r(-6, 2.4, 6, 13.5, b)
	_r(-6.4, 13.5, 6.4, 14.3, Color("e8dcc4"))
	_poly([-6.4, 14.3, 6.4, 14.3, 0, 18], b)
	_poly([-5.2, 14.6, 5.2, 14.6, 0, 17.4], b.darkened(0.12))
	_c(0, 15.7, 0.7, Color("e8dcc4"))
	for x in [-4.6, 4.6]:
		_r(x - 0.6, 2.4, x + 0.6, 13.5, Color("e8dcc4"))
	_arched(0, 2.4, 5.0, 8.0, Color("3a2e24"))
	_r(-3, 2.4, 3, 2.9, Color("8b7d62"))
