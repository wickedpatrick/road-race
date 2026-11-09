class_name LandmarksMtA
extends RefCounted
## Maltese landmarks, drawn with LandmarkPainter's helpers (metres from the base point, y up). Malta is built of
## its own honey-coloured Globigerina limestone, so most of them share that stone.

const HONEY := Color("dcc08a")
const HONEY_D := Color("bf9f68")
const HONEY_L := Color("ecd6a6")
const SEA := Color("2f7fb8")
const SEA_L := Color("7fb8de")
const ROCK := Color("b8a47c")
const GRASS := Color("8fa04e")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const RED := Color("c8352b")
const WOOD := Color("6d4a2c")
const GREEN_SH := Color("2f6b3f")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"st_johns_cocathedral": _st_johns()
		"sliema_fortizza": _fortizza()
		"mosta_rotunda": _mosta_rotunda()
		"mdina_gate": _mdina_gate()
		"marsaxlokk_luzzu": _luzzu_boats()
		"mellieha_red_tower": _red_tower()
		"gozo_cittadella": _cittadella()
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

## An arched opening: a rectangle under a half circle.
static func _arched(x: float, y0: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.5, y0, x + w * 0.5, y0, x + w * 0.5, y0 + h - w * 0.5] + _arc(x, y0 + h - w * 0.5, w * 0.5, w * 0.5, 0, PI, 6), col)

## A row of merlons along the top of a wall from x0 to x1 at height y.
static func _merlons(x0: float, x1: float, y: float, n: int, h: float, col: Color) -> void:
	var step := (x1 - x0) / n
	for k in n:
		if k % 2 == 0:
			_r(x0 + k * step, y, x0 + (k + 1) * step, y + h, col)

## The Maltese flag, white and red with the George Cross, on a pole whose foot is at (x, y).
static func _flag(x: float, y: float, h: float) -> void:
	_l(x, y, x, y + h, DARK, 0.15)
	_r(x, y + h - 1.6, x + 1.2, y + h, Color.WHITE)
	_r(x + 1.2, y + h - 1.6, x + 2.4, y + h, RED)
	if _detail(1.5):
		_r(x + 0.15, y + h - 0.5, x + 0.45, y + h - 0.2, Color("a8a8a8"))

## Valletta's St John's Co-Cathedral: the Knights' plain, almost military limestone facade by Girolamo Cassar,
## two square bell towers with spires and clocks, the central doorway under a balcony on columns.
static func _st_johns() -> void:
	_r(-20, 0, 20, 0.8, HONEY_D) # the square
	# the nave behind, with its long roof
	_r(-11, 0, 11, 22, HONEY_D)
	# the facade
	_r(-12, 0.8, 12, 20, HONEY)
	_poly([-12, 20, 12, 20, 0, 25], HONEY_L)
	_r(-12, 19.4, 12, 20.2, HONEY_D)
	_r(-12, 11.2, 12, 11.8, HONEY_D)
	# the two bell towers
	for sg in [-1.0, 1.0]:
		var x0: float = sg * 12.0
		var x1: float = sg * 18.0
		var lo := minf(x0, x1)
		var hi := maxf(x0, x1)
		_r(lo, 0.8, hi, 26, HONEY)
		_r(lo - 0.3, 25.6, hi + 0.3, 26.4, HONEY_D)
		_poly([lo, 26.4, hi, 26.4, (lo + hi) * 0.5, 33], Color("8f8a80"))
		_c((lo + hi) * 0.5, 21.5, 1.6, Color("f4f0e6"))
		if _detail(1.0):
			_l((lo + hi) * 0.5, 21.5, (lo + hi) * 0.5, 22.6, DARK, 0.15)
			_l((lo + hi) * 0.5, 21.5, (lo + hi) * 0.5 + 0.8, 21.5, DARK, 0.15)
		_arched((lo + hi) * 0.5, 14, 1.8, 3.6, WIN)
		_r((lo + hi) * 0.5 - 0.7, 5, (lo + hi) * 0.5 + 0.7, 8, WIN)
	# the doorway with its portico of columns and the balcony above
	_arched(0, 0.8, 4, 7.5, Color("5a3e26"))
	for x in [-4.0, -2.8, 2.8, 4.0]:
		_r(x - 0.35, 0.8, x + 0.35, 8.8, HONEY_L)
	_r(-5, 8.8, 5, 9.8, HONEY_D)
	if _detail(0.8):
		for k in 9:
			var x := -4.4 + k * 1.1
			_r(x - 0.18, 9.8, x + 0.18, 11, HONEY_L)
	_arched(0, 12.5, 2.4, 5, WIN)
	_windows(-10.5, -5.5, 13, 16.5, 2, WIN)
	_windows(5.5, 10.5, 13, 16.5, 2, WIN)

## Sliema's Il-Fortizza: the Victorian Sliema Point Battery on the rocks of the promenade, a low castellated fort
## with a round corner tower, now a restaurant, the sea breaking in front.
static func _fortizza() -> void:
	_r(-18, 0, 18, 2.2, SEA)
	if _detail(1.0):
		_l(-17, 1.1, -9, 1.1, SEA_L, 0.18)
		_l(6, 0.6, 15, 0.6, SEA_L, 0.18)
	# the rocks
	_poly([-15, 1.4, -11, 3.6, -4, 4.2, 6, 4.0, 12, 3.4, 16, 1.6, 12, 0.8, -12, 0.8], ROCK)
	_poly([-9, 3.4, -2, 4.2, 8, 4.0, 10, 3.2], ROCK.darkened(0.12))
	# the main block with crenellations
	_r(-12, 4, 6, 12, HONEY)
	_merlons(-12, 6, 12, 15, 1.1, HONEY)
	_r(-12, 11.6, 6, 12.1, HONEY_D)
	# the round tower at the corner
	_r(6, 4, 13, 14, HONEY_L)
	_merlons(6, 13, 14, 7, 1.2, HONEY_L)
	_r(6, 4, 7, 14, HONEY_D)
	# arched openings and windows
	for x in [-9.0, -5.0, -1.0, 3.0]:
		_arched(x, 5, 2, 3.6, WIN)
	_windows(-11, 5, 9.2, 10.6, 6, WIN)
	_arched(9.5, 7, 1.6, 3.2, WIN)
	# a café's umbrellas on the terrace
	for x in [-14.0, -11.5]:
		_l(x, 4, x, 6.2, DARK, 0.12)
		_poly([x - 1.3, 6.2, x + 1.3, 6.2, x, 7.1], Color("e8e4dc"))
	_flag(9.5, 15.2, 4.5)

## The Rotunda of Mosta: a round church modelled on the Pantheon, a huge pale dome with ribs and a lantern on a
## drum, a portico of columns under a pediment and two bell towers either side of it.
static func _mosta_rotunda() -> void:
	_r(-23, 0, 23, 0.8, HONEY_D)
	# the drum and the dome
	_r(-15, 0.8, 15, 18, HONEY)
	_windows(-13, 13, 11, 14.5, 8, WIN)
	_r(-15.4, 17.4, 15.4, 18.4, HONEY_D)
	_poly(_arc(0, 18.4, 14.5, 13, 0, PI, 18), Color("d9d4c6"))
	if _detail(0.8):
		for x in [-9.0, -4.5, 0.0, 4.5, 9.0]:
			var top := 18.4 + 13.0 * sqrt(maxf(0.0, 1.0 - pow(x / 14.5, 2)))
			_l(x * 0.98, 18.6, x * 0.3, top - 0.6, Color("b9b3a3"), 0.25)
	# the lantern
	_r(-1.6, 31, 1.6, 34.5, HONEY_L)
	_poly(_arc(0, 34.5, 1.8, 1.6, 0, PI, 6), Color("d9d4c6"))
	_l(0, 36, 0, 38.5, DARK, 0.2)
	_l(-0.8, 37.6, 0.8, 37.6, DARK, 0.2)
	# the bell towers
	for sg in [-1.0, 1.0]:
		var cx: float = sg * 18.5
		_r(cx - 3, 0.8, cx + 3, 22, HONEY)
		_r(cx - 3.3, 21.6, cx + 3.3, 22.4, HONEY_D)
		_r(cx - 2.2, 22.4, cx + 2.2, 26, HONEY_L)
		_poly(_arc(cx, 26, 2.2, 2.2, 0, PI, 8), Color("d9d4c6"))
		_l(cx, 28.2, cx, 29.6, DARK, 0.15)
		_arched(cx, 22.8, 1.4, 2.6, WIN)
		_arched(cx, 14, 1.8, 3.6, WIN)
		_c(cx, 18.6, 1.2, Color("f4f0e6"))
	# the portico: columns and a pediment
	_r(-9, 0.8, 9, 2, HONEY_L)
	for k in 6:
		var x := -7.5 + k * 3.0
		_r(x - 0.55, 2, x + 0.55, 13, HONEY_L)
	_r(-9, 13, 9, 14.4, HONEY_D)
	_poly([-9.6, 14.4, 9.6, 14.4, 0, 18.2], HONEY_L)
	_poly([-7.6, 15, 7.6, 15, 0, 17.4], HONEY)
	_r(-1.4, 0.8, 1.4, 7, Color("5a3e26"))

## The Main Gate of Mdina (1724): a Baroque archway in the bastion walls of the Silent City, the arms of
## Grand Master Vilhena over it, reached by a stone bridge across the dry, green moat; the cathedral dome behind.
static func _mdina_gate() -> void:
	# the cathedral's dome and a bell tower peeping over the walls
	_poly(_arc(8, 17, 4.5, 4.5, 0, PI, 10), Color("c46b3e"))
	_r(7.3, 21.4, 8.7, 23.2, HONEY_L) # the lantern
	_r(2.5, 14, 13.5, 17, HONEY_L)
	_r(-13, 14, -9.5, 22, HONEY_L)
	_poly([-13.4, 22, -9.1, 22, -11.25, 25], Color("8f8a80"))
	# the moat and the walls
	_r(-18, 0, 18, 3, GRASS)
	_poly([-18, 3, -18, 16, 18, 16, 18, 3], HONEY)
	if _detail(1.0):
		for y in [6.0, 9.0, 12.0]:
			_l(-18, y, -6, y, HONEY_D, 0.12)
			_l(6, y, 18, y, HONEY_D, 0.12)
	_r(-18, 15.4, 18, 16.2, HONEY_D)
	# the gate: pilasters, the arch, a cornice and the scrolled crest with the arms
	_r(-5, 3, 5, 18, HONEY_L)
	for x in [-4.4, -3.4, 3.4, 4.4]:
		_r(x - 0.3, 3, x + 0.3, 15, HONEY)
	_arched(0, 4.5, 4.4, 8.5, Color("3d3127"))
	_r(-5.5, 15, 5.5, 16, HONEY_D)
	_poly([-4, 18, -2.2, 21, 2.2, 21, 4, 18], HONEY_L)
	_c(0, 18.6, 1.5, Color("b8442e"))
	if _detail(1.0):
		_r(-0.6, 18.4, 0.6, 18.8, Color("f4f0e6"))
		_c(-3.8, 18.4, 0.6, HONEY_D)
		_c(3.8, 18.4, 0.6, HONEY_D)
	# the bridge over the moat, with its parapets
	_poly([-2.6, 4.5, 2.6, 4.5, 4.5, 0, -4.5, 0], HONEY_D)
	_poly([-2.6, 4.5, -2.2, 4.5, -4.0, 0, -4.5, 0], HONEY_L)
	_poly([2.2, 4.5, 2.6, 4.5, 4.5, 0, 4.0, 0], HONEY_L)
	_poly([-3.4, 5.3, -2.6, 5.3, -4.5, 1.0, -5.2, 1.0], HONEY)
	_poly([2.6, 5.3, 3.4, 5.3, 5.2, 1.0, 4.5, 1.0], HONEY)
	# a palm by the moat
	_l(-12, 3, -12.5, 10, WOOD, 0.35)
	for a in [0.4, 1.2, 2.0, 2.8]:
		_l(-12.5, 10, -12.5 + cos(a) * 3.2, 10 + sin(a) * 1.6 - 0.8, GREEN_SH, 0.35)

## One luzzu, a Maltese fishing boat: double-ended, painted in bright bands, high stem posts, the Eye of Osiris on
## the bow. `x` is its middle, `s` its scale, `dir` 1 when the bow points right.
static func _luzzu(x: float, y: float, s: float, dir: float, hull: Color, band: Color) -> void:
	var L := 7.0 * s
	var H := 2.4 * s
	_poly([x - L, y + H * 1.1, x - L * 0.8, y, x + L * 0.8, y, x + L, y + H * 1.1], hull)
	_poly([x - L * 0.98, y + H * 1.05, x + L * 0.98, y + H * 1.05, x + L * 1.02, y + H * 1.35, x - L * 1.02, y + H * 1.35], band)
	_l(x - L * 0.85, y + H * 0.5, x + L * 0.85, y + H * 0.5, Color("e8c43a"), 0.25 * s)
	# the stem posts
	_l(x + dir * L, y + H * 1.1, x + dir * L * 1.04, y + H * 2.0, band, 0.35 * s)
	_l(x - dir * L, y + H * 1.1, x - dir * L * 1.02, y + H * 1.8, band, 0.35 * s)
	# the eye on the bow
	var ex := x + dir * L * 0.72
	_poly([ex - 0.7 * s, y + H * 0.85, ex, y + H * 1.05, ex + 0.7 * s, y + H * 0.85, ex, y + H * 0.65], Color.WHITE)
	_c(ex, y + H * 0.85, 0.22 * s, DARK)
	# a small wheelhouse / awning
	_r(x - L * 0.25, y + H * 1.35, x + L * 0.1, y + H * 2.0, Color("f0ebe0"))

## The luzzu boats of Marsaxlokk: two painted fishing boats on the blue harbour, a church front on the quay behind.
static func _luzzu_boats() -> void:
	# the quay and the parish church behind
	_r(-15, 3, 15, 4, HONEY_D)
	_r(-5, 4, 5, 10, HONEY)
	_poly([-5, 10, 5, 10, 0, 12], HONEY_L)
	for sg in [-1.0, 1.0]:
		_r(sg * 5 - 1.4, 4, sg * 5 + 1.4, 12.5, HONEY_L)
		_poly([sg * 5 - 1.4, 12.5, sg * 5 + 1.4, 12.5, sg * 5, 13.8], Color("8f8a80"))
	_arched(0, 4, 1.6, 3.2, WIN)
	_windows(-14, -7, 5, 7, 3, WIN)
	_windows(7, 14, 5, 7, 3, WIN)
	_r(-15, 4, -7, 8, HONEY_L.darkened(0.04))
	_r(7, 4, 15, 8, HONEY_L.darkened(0.04))
	# the harbour water
	_r(-15, 0, 15, 3, SEA)
	if _detail(1.0):
		_l(-14, 2.2, -8, 2.2, SEA_L, 0.15)
		_l(8, 2.6, 14, 2.6, SEA_L, 0.15)
	_luzzu(7, 1.4, 0.85, -1.0, Color("2e6fb8"), Color("e8c43a"))
	_luzzu(-4, 0.1, 1.2, 1.0, Color("2a9a5a"), RED)

## The Red Tower (St Agatha's Tower, 1649) on the Marfa ridge above Mellieħa: a square fort with four corner
## turrets, painted red, the Maltese flag flying over it.
static func _red_tower() -> void:
	_poly([-12, 0, -9, 2.5, -3, 3.4, 4, 3.2, 9, 2.4, 12, 0], GRASS)
	var red := Color("b8442e")
	var red_d := red.darkened(0.2)
	var red_l := red.lightened(0.12)
	_r(-6, 3, 6, 16, red)
	_r(-6.3, 15.6, 6.3, 16.4, red_d)
	_merlons(-6, 6, 16.4, 9, 0.8, red)
	# the corner turrets
	for sg in [-1.0, 1.0]:
		_r(sg * 7.5 - 1.5, 3, sg * 7.5 + 1.5, 18.5, red_l)
		_r(sg * 7.5 - 1.8, 18.2, sg * 7.5 + 1.8, 19.0, red_d)
		_merlons(sg * 7.5 - 1.5, sg * 7.5 + 1.5, 19.0, 3, 0.7, red_l)
		_r(sg * 7.5 - 0.3, 11, sg * 7.5 + 0.3, 13, WIN)
	# the base batter and the door up its stair
	_poly([-9, 3, 9, 3, 7.5, 5.5, -7.5, 5.5], red_d)
	_arched(0, 7, 1.8, 3.4, WIN)
	_l(-4, 3.4, -0.9, 7, HONEY_D, 0.4)
	_r(-3, 12.4, -1.6, 14, WIN)
	_r(1.6, 12.4, 3, 14, WIN)
	_flag(0, 17.2, 7.5)

## The Cittadella of Victoria: the walled old town on its hill in the middle of Gozo, sloping bastion walls
## around the top, the cathedral's facade with its bell tower inside, the town's houses at the foot.
static func _cittadella() -> void:
	# the hill
	_poly([-30, 0, -24, 4, -16, 9, -10, 11, 10, 11, 18, 8, 25, 3.5, 30, 0], ROCK)
	_poly([-30, 0, -24, 2.4, -14, 4, 14, 4, 24, 2.2, 30, 0], GRASS)
	# houses at the foot
	for k in 7:
		var x := -26.0 + k * 8.0
		var w := 3.2 + (k % 3) * 0.8
		_r(x, 0, x + w, 2.6 + (k % 2) * 1.2, HONEY_L if k % 2 else HONEY)
	# the bastion walls with their batter
	_poly([-20, 10, 20, 10, 18.5, 19, -18.5, 19], HONEY)
	_poly([-20, 10, -16, 10, -15, 19, -18.5, 19], HONEY_D)
	_poly([14, 10, 20, 10, 18.5, 19, 15, 19], HONEY_L)
	_r(-19, 19, 19, 19.8, HONEY_D)
	if _detail(1.0):
		for y in [12.5, 15.0, 17.5]:
			_l(-18.5, y, 18.5, y, HONEY_D, 0.1)
	# the cathedral: a facade with a pediment and a small bell tower
	_r(-5, 19.8, 5, 29, HONEY_L)
	_poly([-5.6, 29, 5.6, 29, 0, 32.4], HONEY)
	_arched(0, 19.8, 2, 4, Color("5a3e26"))
	_arched(0, 25, 1.4, 2.4, WIN)
	for x in [-4.2, -2.6, 2.6, 4.2]:
		_r(x - 0.25, 19.8, x + 0.25, 28.2, HONEY)
	_r(7, 19.8, 10.5, 31, HONEY_L)
	_poly([6.6, 31, 10.9, 31, 8.75, 33.6], Color("8f8a80"))
	_arched(8.75, 26.5, 1.4, 2.6, WIN)
	# the old houses inside the walls
	_r(-15, 19.8, -7, 23.5, HONEY)
	_r(12, 19.8, 17, 22.6, HONEY)
	_windows(-14, -8, 21, 22.6, 3, WIN)
	_flag(-16, 23.5, 6)
