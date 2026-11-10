class_name LandmarksItA
extends RefCounted
## Italian landmarks (Roma to Catania), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const TRAVERTINE := Color("d8cdb0")
const TRAVERTINE_D := Color("b9ad8f")
const MARBLE := Color("f1ede4")
const MARBLE_D := Color("d9d3c6")
const PINK := Color("eedfd6")
const PINK_D := Color("d6c3b8")
const TUFF := Color("8f8574")
const TUFF_D := Color("6f6656")
const GREEN_M := Color("3f6e55")
const RED_M := Color("b04a3c")
const TERRA := Color("b9643c")
const TERRA_D := Color("94492b")
const BRICK := Color("a8583b")
const BRICK_D := Color("844229")
const STONE := Color("c9bfa7")
const STONE_D := Color("a69c84")
const LAVA := Color("3b3836")
const WIN := Color("3a3a40")
const DARK := Color("2b2b30")
const GOLD := Color("e0b43a")
const GRASS := Color("6b8f45")
const ROCK := Color("8d8578")
const WATER := Color("4f86a8")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"it_roma_colosseum": _roma_colosseum()
		"it_milano_duomo": _milano_duomo()
		"it_napoli_maschio_angioino": _napoli_maschio_angioino()
		"it_torino_mole": _torino_mole()
		"it_palermo_teatro_massimo": _palermo_teatro_massimo()
		"it_genova_lanterna": _genova_lanterna()
		"it_bologna_due_torri": _bologna_due_torri()
		"it_firenze_duomo": _firenze_duomo()
		"it_bari_san_nicola": _bari_san_nicola()
		"it_catania_elefante": _catania_elefante()
		"it_venezia_rialto": _venezia_rialto()
		"it_verona_arena": _verona_arena()
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

## An arched opening: a rectangle under a half circle.
static func _arched(x: float, y0: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.5, y0, x + w * 0.5, y0, x + w * 0.5, y0 + h - w * 0.5] + _arc(x, y0 + h - w * 0.5, w * 0.5, w * 0.5, 0, PI, 6), col)

## A dome: a half ellipse on a base line.
static func _dome(x: float, y: float, rx: float, ry: float, col: Color) -> void:
	_poly(_arc(x, y, rx, ry, 0, PI, 12), col)

## A row of `n` arches between x0 and x1 on one storey (y0..y1), with pilasters between them.
static func _arcade(x0: float, x1: float, y0: float, y1: float, n: int, wall: Color, hole: Color) -> void:
	_r(x0, y0, x1, y1, wall)
	var step := (x1 - x0) / n
	for k in n:
		_arched(x0 + step * (k + 0.5), y0 + (y1 - y0) * 0.08, step * 0.62, (y1 - y0) * 0.78, hole)

## The Colosseum: the elliptical travertine wall with three storeys of 80 arches and the plain attic above, the
## outer ring whole on the left and broken off in steps on the right, where the inner ring shows.
static func _roma_colosseum() -> void:
	_r(-46, 0, 46, 1, TRAVERTINE_D)
	# the inner ring, lower, seen where the outer one is gone
	_arcade(-10, 44, 1, 13, 9, TRAVERTINE_D, TUFF_D)
	_arcade(-10, 40, 13, 24, 8, TRAVERTINE_D, TUFF_D)
	# the outer ring: three arcaded storeys and the attic, ending in steps on the right
	var ends := [44.0, 34.0, 22.0, 10.0]
	for k in 3:
		_arcade(-44, ends[k], 1 + k * 11.5, 12.5 + k * 11.5, 14 - k * 2, TRAVERTINE, DARK if k == 0 else TUFF)
		_r(-44, 12 + k * 11.5, ends[k], 13 + k * 11.5, TRAVERTINE_D)
	_r(-44, 35.5, ends[3], 47, TRAVERTINE)
	_windows(-42, ends[3] - 2, 39, 42, 9, TUFF)
	_r(-44, 46.5, ends[3], 48, TRAVERTINE_D)
	# the broken edge
	_poly([ends[3], 47, ends[3] + 4, 35.5, ends[3], 35.5], TRAVERTINE_D)

## Milan Cathedral: the white-pink marble front with its Gothic pinnacles and spires, the bronze doors, the roof
## forest of spires behind and the main spire with the golden Madonnina on top.
static func _milano_duomo() -> void:
	# the front: a broad gable with buttresses ending in pinnacles
	_poly([-33, 0, 33, 0, 33, 30, 0, 46, -33, 30], PINK)
	_poly([-33, 30, 0, 46, 33, 30, 33, 31.5, 0, 47.5, -33, 31.5], PINK_D)
	for k in 6:
		var x := -33.0 + k * 13.2
		_r(x - 1, 0, x + 1, 34 + (6.0 if k in [2, 3] else 0.0), PINK_D)
		_poly([x - 1.2, 34 + (6.0 if k in [2, 3] else 0.0), x + 1.2, 34 + (6.0 if k in [2, 3] else 0.0), x, 41 + (6.0 if k in [2, 3] else 0.0)], MARBLE)
	# the five doors and the windows over them
	for x in [-26.4, -13.2, 0.0, 13.2, 26.4]:
		_r(x - 2.6, 0, x + 2.6, 9 if x == 0.0 else 7, Color("6b5430"))
		LandmarkPainter._windows(x - 3, x + 3, 13, 22, 1, WIN)
	_arched(0, 25, 5, 12, WIN)
	# the roof's spires behind the front
	for x in [-24.0, -16.0, 16.0, 24.0]:
		_poly([x - 1, 40, x + 1, 40, x, 58], PINK_D)
	# the octagonal lantern and the main spire
	_r(-6, 44, 6, 62, PINK)
	_poly([-6, 62, 6, 62, 2.2, 74, -2.2, 74], PINK_D)
	_poly([-2.2, 74, 2.2, 74, 0.6, 102, -0.6, 102], MARBLE)
	for s in [-1, 1]:
		_poly([s * 5.5, 62, s * 4.5, 62, s * 5, 76], MARBLE)
	# the Madonnina
	_poly([-0.9, 102, 0.9, 102, 0.3, 107.5, -0.3, 107.5], GOLD)
	_c(0, 108, 0.5, GOLD)

## Castel Nuovo (Maschio Angioino): grey tuff walls with five round towers on a battered base, and the white marble
## Renaissance triumphal arch of Alfonso of Aragon wedged between the two towers of the front.
static func _napoli_maschio_angioino() -> void:
	_r(-34, 0, 34, 1, Color("8a8a7a"))
	_r(-30, 1, 30, 26, TUFF)
	_poly([-30, 26, 30, 26, 30, 28, -30, 28], TUFF_D)
	for x in [-30.0, -12.0, 12.0, 30.0]:
		# the round towers: a sloping foot, the drum and the battlements
		_poly([x - 7.5, 1, x + 7.5, 1, x + 6, 10, x - 6, 10], TUFF_D)
		_r(x - 6, 10, x + 6, 33, TUFF)
		_r(x - 6.5, 33, x + 6.5, 35, TUFF_D)
		for k in 5:
			_r(x - 6 + k * 2.6, 35, x - 4.8 + k * 2.6, 36.5, TUFF_D)
		_l(x + 4.2, 11, x + 4.2, 32, TUFF_D, 0.8)
	# the arch: two tiers of white marble between the towers
	_r(-6, 1, 6, 34, MARBLE)
	_arched(0, 1, 6, 11, DARK)
	_r(-6, 13, 6, 18, MARBLE_D)
	_arched(0, 19, 4.5, 8, Color("bdb6a8"))
	_poly([-5, 30, 5, 30, 0, 34], MARBLE_D)
	for x in [-4.5, 4.5]:
		_r(x - 0.4, 2, x + 0.4, 12, MARBLE_D)

## The Mole Antonelliana: the square base with its colonnades, the tall ribbed dome rising steeply, the small temple
## and the slender spire to 167 m with a star on top.
static func _torino_mole() -> void:
	_r(-19, 0, 19, 32, Color("c9b998"))
	_windows(-17, 17, 4, 12, 7, WIN)
	_windows(-17, 17, 17, 27, 9, WIN)
	_r(-20, 32, 20, 34, Color("b2a27f"))
	# the colonnaded drum
	_r(-16, 34, 16, 46, Color("d6c7a6"))
	for k in 9:
		_r(-15.5 + k * 3.8, 34, -14.5 + k * 3.8, 46, Color("b2a27f"))
	# the high dome with its ribs
	_poly([-16, 46, 16, 46, 7, 92, -7, 92], Color("8f9496"))
	for x in [-11.0, -4.0, 4.0, 11.0]:
		_l(x, 46, x * 0.45, 92, Color("767b7e"), 0.6)
	# the little temple over the dome and the spire
	_r(-6, 92, 6, 104, Color("d6c7a6"))
	for k in 5:
		_r(-5.5 + k * 2.6, 92, -4.7 + k * 2.6, 104, Color("b2a27f"))
	_poly([-6.5, 104, 6.5, 104, 3, 112, -3, 112], Color("8f9496"))
	_poly([-3, 112, 3, 112, 0.5, 163, -0.5, 163], Color("c8c3b6"))
	_r(-1.2, 128, 1.2, 130, Color("b2a27f"))
	_r(-0.9, 145, 0.9, 147, Color("b2a27f"))
	# the star
	var pts := []
	for k in 10:
		var a := PI * 0.5 + k * TAU / 10.0
		var r := 2.4 if k % 2 == 0 else 1.0
		pts += [cos(a) * r, 165 + sin(a) * r]
	_poly(pts, GOLD)

## The Teatro Massimo: the wide steps flanked by two bronze lions, the Corinthian portico under a pediment and the
## great dome behind it.
static func _palermo_teatro_massimo() -> void:
	for k in 4:
		_r(-24 + k * 1.5, k * 1.0, 24 - k * 1.5, k * 1.0 + 1.0, STONE_D if k % 2 == 0 else STONE)
	_r(-34, 4, 34, 26, STONE)
	_windows(-32, -14, 9, 20, 4, WIN)
	_windows(14, 32, 9, 20, 4, WIN)
	_r(-34, 25, 34, 27, STONE_D)
	# the portico
	_r(-12, 4, 12, 24, Color("b8ad93"))
	for k in 6:
		var x := -10.0 + k * 4.0
		_r(x - 0.8, 4, x + 0.8, 23, STONE)
	_r(-13, 23, 13, 25.5, STONE_D)
	_poly([-13.5, 25.5, 13.5, 25.5, 0, 32], STONE)
	_poly([-11, 26.2, 11, 26.2, 0, 30.8], STONE_D)
	# the drum and dome
	_r(-17, 27, 17, 33, STONE_D)
	_dome(0, 33, 16, 11, Color("6f8a8a"))
	for x in [-9.0, 0.0, 9.0]:
		_l(x, 33, x * 0.4, 43.5, Color("5c7474"), 0.4)
	_r(-1.5, 43.5, 1.5, 45.5, STONE)
	# the lions on their plinths
	for s in [-1, 1]:
		_r(s * 26 - 3, 0, s * 26 + 3, 4, STONE_D)
		_poly([s * 26 - 2.5, 4, s * 26 + 2.5, 4, s * 26 + 2.2, 6, s * 26 - 1.0 * s, 7.5, s * 26 - 2.5, 6], Color("6b5a3a"))

## The Lanterna of Genoa: the old lighthouse on its rock by the harbour, two square brick-and-stone stages with
## battlements, the lantern on top, the red-and-white flag of St George.
static func _genova_lanterna() -> void:
	_poly([-12, 0, 12, 0, 8, 9, -7, 10], ROCK)
	_poly([-7, 10, 8, 9, 4, 11, -4, 11], Color("a09888"))
	# lower stage
	_r(-4.5, 11, 4.5, 48, Color("ddd6c4"))
	_windows(-3, 3, 20, 23, 1, WIN)
	_windows(-3, 3, 34, 37, 1, WIN)
	_r(-5.5, 48, 5.5, 50, Color("b8af9a"))
	for k in 5:
		_r(-5.5 + k * 2.4, 50, -4.3 + k * 2.4, 51.5, Color("b8af9a"))
	# upper stage
	_r(-3.8, 51.5, 3.8, 73, Color("ddd6c4"))
	_windows(-2.5, 2.5, 60, 63, 1, WIN)
	_r(-4.8, 73, 4.8, 75, Color("b8af9a"))
	for k in 4:
		_r(-4.8 + k * 2.6, 75, -3.6 + k * 2.6, 76.5, Color("b8af9a"))
	# the lantern
	_r(-2.2, 76.5, 2.2, 81, Color("d8e4ea"))
	_dome(0, 81, 2.6, 2.4, Color("4a5258"))
	_l(0, 83.4, 0, 88, DARK, 0.15)
	_r(0, 85.5, 3, 88, Color("ffffff"))
	_r(1.2, 85.5, 1.8, 88, Color("c8322b"))
	_r(0, 86.5, 3, 87, Color("c8322b"))

## The Two Towers of Bologna: the tall slender Asinelli tower with its battlements and the short Garisenda leaning
## beside it, both of brick, with the old houses at their feet.
static func _bologna_due_torri() -> void:
	# the houses at the foot
	_r(-15, 0, 15, 9, Color("c98a5a"))
	_windows(-14, 14, 3, 6, 8, WIN)
	_r(-15, 9, 15, 10, TERRA_D)
	# Asinelli: straight and very tall
	_r(-3.5, 0, 3.5, 92, BRICK)
	_l(2.6, 10, 2.6, 90, BRICK_D, 0.6)
	_r(-4.6, 92, 4.6, 94, BRICK_D)
	for k in 4:
		_r(-4.6 + k * 2.6, 94, -3.2 + k * 2.6, 96, BRICK_D)
	_r(-1.5, 96, 1.5, 97.5, BRICK)
	for y in [30.0, 55.0, 75.0]:
		_r(-0.5, y, 0.5, y + 1.5, DARK)
	# Garisenda: shorter, leaning to the right
	var lean := 0.075
	_poly([6, 0, 12.5, 0, 12.5 + 48 * lean, 48, 6 + 48 * lean, 48], Color("b46448"))
	_l(11.5, 4, 11.5 + 44 * lean, 46, BRICK_D, 0.5)

## Florence Cathedral: the marble front and side in white, green and pink, Brunelleschi's great red-tiled dome with
## its white ribs and lantern on the octagonal drum, and Giotto's bell tower beside it.
static func _firenze_duomo() -> void:
	# the nave's side wall in coloured marble
	_r(-48, 0, 16, 26, MARBLE)
	for k in 8:
		_r(-46 + k * 7.6, 2, -45 + k * 7.6, 24, GREEN_M)
	_r(-48, 12, 16, 13, GREEN_M)
	_r(-48, 24, 16, 26, GREEN_M)
	for k in 7:
		_arched(-42 + k * 7.6, 15, 2, 7, WIN)
	_poly([-48, 26, 16, 26, 16, 30, -48, 30], TERRA)
	# the drum with its round windows, the dome and the lantern
	_r(-24, 26, 6, 46, MARBLE)
	_r(-24, 44, 6, 46, GREEN_M)
	for x in [-18.0, -9.0, 0.0]:
		_c(x, 36, 2.2, GREEN_M)
		_c(x, 36, 1.4, WIN)
	_poly(_arc(-9, 46, 17, 46, 0, PI, 16), TERRA)
	for x in [-14.0, -4.0]:
		_l(x, 46, -9 + (x + 9) * 0.25, 90, MARBLE, 0.9)
	_l(-9, 46, -9, 92, MARBLE, 1.0)
	_r(-12, 91, -6, 101, MARBLE)
	_poly([-12.5, 101, -5.5, 101, -9, 110], MARBLE_D)
	_l(-9, 110, -9, 114, GOLD, 0.3)
	_c(-9, 112, 0.7, GOLD)
	# Giotto's campanile: square, in bands of marble, the big windows near the top
	_r(30, 0, 44, 82, MARBLE)
	for y in [8.0, 18.0, 32.0, 48.0, 64.0, 80.0]:
		_r(30, y, 44, y + 1, GREEN_M)
	for y in [20.0, 34.0]:
		_r(31, y, 43, y + 6, PINK)
	_arched(37, 50, 3, 12, WIN)
	_arched(37, 66, 4, 13, WIN)
	_r(29, 82, 45, 84, MARBLE_D)
	_l(30, 5, 30, 82, GREEN_M, 0.6)
	_l(44, 5, 44, 82, GREEN_M, 0.6)

## The Basilica of San Nicola in Bari: the plain Romanesque front of pale limestone under its gable, the portal with
## its little porch on columns, the three windows and the two unequal towers at its sides.
static func _bari_san_nicola() -> void:
	var lime := Color("e6dcc2")
	var lime_d := Color("c7bb9c")
	_r(-24, 0, 24, 1, lime_d)
	# the towers: the left one taller
	_r(-24, 0, -15, 34, lime)
	_r(-24, 34, -15, 36, lime_d)
	_r(15, 0, 24, 27, lime)
	_r(15, 27, 24, 29, lime_d)
	_arched(-19.5, 26, 2, 5, WIN)
	_arched(19.5, 20, 2, 4, WIN)
	# the front
	_poly([-15, 0, 15, 0, 15, 22, 0, 31, -15, 22], lime)
	_poly([-15, 22, 0, 31, 15, 22, 15, 23, 0, 32, -15, 23], lime_d)
	for x in [-7.5, 7.5]:
		_l(x, 0, x, 25, lime_d, 0.6)
	# the porch on two columns over the portal, the windows
	_arched(0, 0, 4, 8, Color("5a4630"))
	for x in [-3.2, 3.2]:
		_r(x - 0.4, 0, x + 0.4, 8.5, lime_d)
	_poly([-4, 8.5, 4, 8.5, 0, 11], lime_d)
	for x in [-11.0, 11.0]:
		_arched(x, 4, 1.8, 5, WIN)
	_arched(0, 15, 2.6, 6, WIN)
	_c(0, 25, 1.5, WIN)

## Catania's Elephant Fountain (u Liotru): the elephant of black lava stone on its white marble base over a basin,
## with the Egyptian obelisk on its back topped by an orb and a cross.
static func _catania_elefante() -> void:
	_r(-5, 0, 5, 0.8, MARBLE_D)
	_r(-4.4, 0.8, 4.4, 1.3, WATER)
	_r(-1.8, 0.8, 1.8, 4, MARBLE)
	_r(-2.2, 4, 2.2, 4.4, MARBLE_D)
	# the elephant: body, legs, head and trunk
	for x in [-1.4, -0.6, 0.6, 1.4]:
		_r(x - 0.3, 4.4, x + 0.3, 5.6, LAVA)
	_poly(_arc(0, 5.6, 1.9, 1.3, 0, PI, 10), LAVA)
	_r(-1.9, 5.4, 1.9, 5.8, LAVA)
	_c(1.9, 6.4, 0.75, LAVA)
	_poly([2.3, 6.4, 2.75, 5.7, 2.9, 4.6, 2.6, 4.6, 2.4, 5.6], LAVA)
	_poly([1.7, 6.9, 1.2, 5.9, 1.6, 5.7], Color("4c4845"))
	# the saddle cloth and the obelisk
	_r(-1, 6.6, 1, 7.2, MARBLE)
	_poly([-0.55, 7.2, 0.55, 7.2, 0.35, 12.2, -0.35, 12.2], Color("8f8679"))
	_poly([-0.35, 12.2, 0.35, 12.2, 0, 12.6], Color("8f8679"))
	_c(0, 12.9, 0.35, GOLD)
	_l(0, 13.2, 0, 13.9, GOLD, 0.08)
	_l(-0.25, 13.6, 0.25, 13.6, GOLD, 0.08)

## The Rialto Bridge over the Grand Canal: the single white stone arch, the steps over it with the two rows of shops
## under their roofs and the high arcade in the middle.
static func _venezia_rialto() -> void:
	var ist := Color("ece6d8")
	var ist_d := Color("cfc7b5")
	_r(-26, 0, 26, 2, WATER)
	# the arch and the deck rising to the middle
	var top := []
	for k in 13:
		var x := -24.0 + k * 4.0
		top += [x, 3 + 5.5 * (1.0 - pow(x / 24.0, 2))]
	_poly([-25, 0, -25, 3] + top + [25, 3, 25, 0] + _arc(0, 0, 14, 7.5, 0, PI, 12), ist)
	_poly(_arc(0, 0, 14, 7.5, 0, PI, 12), WATER)
	_l(-14, 0.2, -12, 4, ist_d, 0.3)
	_l(14, 0.2, 12, 4, ist_d, 0.3)
	# the shops on both sides with their lead roofs
	for s in [-1, 1]:
		var x0: float = s * 3.5
		var x1: float = s * 18.0
		_poly([x0, 7.6 - absf(x0) * 0.03, x1, 6.0, x1, 9.5, x0, 11.5], ist)
		for k in 5:
			var x: float = s * (5.5 + k * 2.6)
			_arched(x, 7.0, 1.3, 2.6, WIN)
		_poly([x0, 11.5, x1, 9.5, x1, 10.4, x0, 12.4], Color("7d8389"))
	# the central arcade
	_r(-3.5, 8.3, 3.5, 13, ist)
	_arched(0, 8.3, 3.2, 4, WIN)
	_poly([-4.2, 13, 4.2, 13, 0, 15], Color("7d8389"))

## The Arena of Verona: the low inner ring of pink limestone with two storeys of arches all round, and the "Ala",
## the last four arches of the outer ring, standing three storeys high on the left.
static func _verona_arena() -> void:
	var pink := Color("dcc1a8")
	var pink_d := Color("bfa186")
	_r(-50, 0, 50, 1, pink_d)
	_arcade(-46, 46, 1, 11, 18, pink, Color("5e4d40"))
	_r(-46, 10.5, 46, 11.5, pink_d)
	_arcade(-46, 46, 11.5, 20, 18, pink, Color("7a6656"))
	_r(-46, 19.5, 46, 21, pink_d)
	# the Ala: four arches of the outer ring, three storeys, in front on the left
	for k in 3:
		_arcade(-40, -22, 1 + k * 10.5, 11 + k * 10.5, 4, Color("e6cfb8"), Color("5e4d40") if k == 0 else Color("9db4c8"))
		_r(-40.5, 10.5 + k * 10.5, -21.5, 11.5 + k * 10.5, pink_d)
	_poly([-40, 32.5, -22, 32.5, -22, 30, -24, 32.5], pink_d)
