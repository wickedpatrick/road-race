class_name LandmarksAtC
extends RefCounted
## Austrian landmarks, drawn with LandmarkPainter's helpers (metres from the base point, y up).

const WHITE := Color("f2efe6")
const PLASTER := Color("efe6cf")
const STONE := Color("d9d0bc")
const RUIN := Color("a39a88")
const OCHRE := Color("e6c27a")
const RED_ROOF := Color("8a4a30")
const SLATE := Color("4f5862")
const COPPER := Color("5f9e86")
const WATER := Color("4f8fc0")
const ROCK := Color("8f8a80")
const GRASS := Color("5d8f42")
const TREE := Color("3f6f34")
const WIN := Color("3a4048")
const GOLD := Color("e0b43a")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"lindwurm": _lindwurm()
		"bergisel": _bergisel()
		"landskron": _landskron()
		"schloss_bruck": _schloss_bruck()
		"duernstein": _duernstein()
		"schattenburg": _schattenburg()
		"ledererturm": _ledererturm()
		"steiner_tor": _steiner_tor()
		"dom_st_poelten": _dom_st_poelten()
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

## An arched opening (gate, door) of width w and height h, its foot at (x, y).
static func _arch(x: float, y: float, w: float, h: float, col: Color) -> void:
	var hw := w * 0.5
	_poly([x - hw, y, x + hw, y] + _arc(x, y + h - hw, hw, hw, 0, PI, 8), col)

## A baroque onion roof: a bulb on a base of width w at height y, its tip at y + h.
static func _onion(x: float, y: float, w: float, h: float, col: Color) -> void:
	var hw := w * 0.5
	_poly([x - hw, y, x + hw, y, x + hw * 0.8, y + h * 0.18, x + hw * 0.35, y + h * 0.3, x + hw * 0.65, y + h * 0.5,
		x + hw * 0.25, y + h * 0.72, x + hw * 0.08, y + h, x - hw * 0.08, y + h, x - hw * 0.25, y + h * 0.72,
		x - hw * 0.65, y + h * 0.5, x - hw * 0.35, y + h * 0.3, x - hw * 0.8, y + h * 0.18], col)
	_c(x, y + h * 0.3, hw * 0.3, col.darkened(0.15))

## A clock face at (x, y).
static func _clock(x: float, y: float, r: float) -> void:
	_c(x, y, r, Color("2e3238"))
	_c(x, y, r * 0.85, WHITE)
	_l(x, y, x, y + r * 0.6, Color("2e3238"), r * 0.12)
	_l(x, y, x + r * 0.45, y, Color("2e3238"), r * 0.12)

## Klagenfurt's Lindwurm fountain: the winged stone dragon with an open mouth and a curled tail, crouched on its
## rock over the basin, and Hercules with his club in front of it.
static func _lindwurm() -> void:
	var stone := Color("b9b2a3")
	_r(-6, 0, 6, 1.3, stone)
	_r(-5.6, 1.0, 5.6, 1.5, WATER)
	_poly([-4.2, 1.4, 4.2, 1.4, 3.2, 3.2, -0.5, 3.6, -3.4, 3.1], ROCK)
	var d := Color("6f8a6e")
	var dd := d.darkened(0.2)
	# the tail, curling up behind
	var tail := [-3, 3.6] + _arc(-4.3, 4.8, 1.3, 1.2, -PI * 0.4, PI * 1.1, 10)
	for k in range(0, tail.size() - 2, 2):
		_l(tail[k], tail[k + 1], tail[k + 2], tail[k + 3], dd, 0.45 - k * 0.012)
	# the wing, spread up from the back
	_poly([-1.4, 5.2, -3.2, 9.6, -2.0, 8.6, -1.2, 9.8, -0.2, 8.4, 0.8, 9.2, 1.0, 5.6], dd)
	if _detail(3.0):
		for x in [-2.0, -1.2, -0.2]:
			_l(0.4, 5.6, x, 8.6, d.lightened(0.1), 0.08)
	_r(-2.8, 3.1, -2.0, 4.0, dd) # legs
	_r(1.2, 3.1, 2.0, 4.0, dd)
	_poly([-3.6, 3.8, 2.4, 3.8, 3.0, 5.0, 1.0, 5.9, -2.6, 5.5, -3.9, 4.6], d)
	_poly([1.4, 5.0, 2.6, 5.2, 3.8, 7.4, 2.9, 7.8], d) # the neck
	_poly([2.7, 7.3, 3.1, 8.6, 4.4, 8.7, 5.8, 8.2, 3.8, 7.8], d) # the head and upper jaw
	_poly([3.0, 7.4, 5.4, 6.9, 3.8, 7.6], d) # the lower jaw, wide open
	_poly([3.8, 7.8, 5.6, 8.0, 5.3, 7.0, 3.9, 7.6], Color("8c3a2e")) # the mouth
	_c(3.7, 8.3, 0.18, Color("1e2023"))
	_poly([3.0, 8.5, 2.6, 9.4, 3.4, 8.7], dd) # a horn
	# Hercules with his club, on the basin's rim
	var b := Color("4a4038")
	_r(-5.3, 1.5, -5.0, 2.8, b)
	_r(-4.8, 1.5, -4.5, 2.8, b)
	_r(-5.4, 2.8, -4.4, 4.3, b)
	_c(-4.9, 4.65, 0.35, b)
	_l(-4.5, 4.0, -3.8, 5.6, b, 0.3)
	_l(-3.8, 5.6, -3.5, 6.2, b, 0.45)

## The Bergisel ski jump: Zaha Hadid's slim concrete tower with the curved café head on top, the in-run sweeping down
## the hill to the take-off, the landing slope and the small stadium at the bottom.
static func _bergisel() -> void:
	_poly([-20, 0, 20, 0, 20, 2, 8, 6, 0, 11, -8, 15, -20, 16], GRASS)
	for p in [[-18, 15.6], [-16, 15.2], [-4, 12.4], [6, 6.6], [18, 2.6], [-12, 9]]:
		_c(p[0], p[1], 1.4, TREE)
	_poly([1, 10.4, 8, 6, 16, 3.3, 16, 4.1, 8, 6.8, 1.6, 11.0], Color("dfe7d6")) # the landing slope
	var conc := Color("c9cbcc")
	_r(-14.6, 14, -11.4, 39, conc)
	_r(-14.6, 14, -13.6, 39, conc.darkened(0.12))
	_poly([-9.2, 39.6, -6.2, 41.4, 2.6, 12.6, 0, 11.4], conc.darkened(0.05)) # the in-run
	_l(-4.6, 26, -4.6, 13.6, conc.darkened(0.2), 0.4)
	_poly([-19, 39.5, -9, 38.6, -5.5, 40.5, -7, 44, -13, 46, -18.6, 44.2], Color("e9ecee")) # the café head
	_poly([-18.4, 41.4, -7.0, 41.0, -6.6, 42.6, -17.8, 43.0], Color("4b6d88"))
	_r(11, 0, 20, 2.2, Color("9aa3ab")) # the stadium
	_poly([11, 2.2, 20, 2.2, 20, 3.4, 13, 3.4], Color("b8bfc5"))
	if _detail(1.5):
		for x in [12.0, 14.0, 16.0, 18.0]:
			_r(x, 0.6, x + 1.0, 1.4, Color("c0392b"))

## Burg Landskron by Villach: castle ruins on a wooded hill, a broken tower and walls, one wing roofed again, and an
## eagle of the bird show circling above with its wings spread.
static func _landskron() -> void:
	_poly([-22, 0, 22, 0, 18, 6, 10, 10.5, -8, 11.5, -16, 8], GRASS)
	for p in [[-17, 6.6], [-12, 8.8], [-5, 9.6], [4, 9.4], [12, 8.4], [17, 5.4], [-9, 5.0], [8, 5.6], [0, 6.2]]:
		_c(p[0], p[1], 2.0, TREE)
	_poly([-10, 11, 6, 11, 6, 15, 4.5, 16.4, 2.6, 14.6, 0.4, 17, -2.8, 15, -5, 17.8, -7, 15.4, -10, 16], RUIN)
	_poly([-13, 11, -8.6, 11, -8.6, 20.5, -9.6, 19.2, -10.6, 21.2, -11.8, 19.6, -13, 20.2], RUIN.darkened(0.1))
	if _detail(1.2):
		for p in [[-6.4, 12.4], [-2.4, 12.4], [1.6, 12.4], [-11.4, 15.6], [-10.4, 13]]:
			_r(p[0], p[1], p[0] + 0.9, p[1] + 1.6, WIN)
	_r(6, 11, 12.5, 17, STONE)
	_poly([5.5, 17, 13, 17, 9.25, 20.4], Color("b5432e"))
	_windows(6.5, 12, 13.6, 15.2, 3, WIN)
	# the eagle
	var e := Color("5a3d24")
	_poly([0, 22.8, -6.4, 24.4, -5.2, 23.4, -3.8, 22.2, -1.0, 22.0], e)
	_poly([0, 22.8, 6.4, 24.4, 5.2, 23.4, 3.8, 22.2, 1.0, 22.0], e)
	_poly([-0.6, 21.2, 0.6, 21.2, 0.5, 23.2, -0.5, 23.2], e.darkened(0.15))
	_c(0, 23.5, 0.45, WHITE)
	_poly([0.2, 23.6, 0.8, 23.3, 0.2, 23.3], GOLD)

## Schloss Bruck in Lienz: the tall square keep and the Gothic castle in light stone with dark roofs, before the
## jagged grey peaks of the Lienz Dolomites.
static func _schloss_bruck() -> void:
	var rock := Color("a7a59f")
	_poly([-25, 0, -25, 14, -21, 22, -18, 17, -15, 27, -11, 20, -7, 31, -3, 22, 1, 26, 4, 19, 8, 29, 12, 21, 16, 25,
		20, 16, 25, 20, 25, 0], rock)
	_poly([-15, 27, -11, 20, -14, 19], rock.lightened(0.15))
	_poly([-7, 31, -3, 22, -6, 21], rock.lightened(0.15))
	_poly([8, 29, 12, 21, 9, 20], rock.lightened(0.15))
	_r(-25, 0, 25, 6, GRASS)
	for p in [[-21, 6], [-18, 5.4], [17, 6], [21, 5.6]]:
		_c(p[0], p[1], 2.2, TREE)
	_r(-12, 4, 6, 16, STONE)
	_r(-12, 4, -10.6, 16, STONE.darkened(0.08))
	_poly([-12.5, 16, 6.5, 16, 4.2, 20, -10.2, 20], SLATE)
	_windows(-10, 5, 7, 9, 6, WIN)
	_windows(-10, 5, 11.5, 13.5, 6, WIN)
	_arch(-3, 4, 2.4, 3.4, WIN)
	_r(6, 4, 13, 26, STONE.lightened(0.05))
	_r(6, 4, 7.2, 26, STONE.darkened(0.06))
	_windows(7, 12, 21, 23, 2, WIN)
	_windows(7, 12, 15, 17, 2, WIN)
	_windows(7, 12, 9, 11, 2, WIN)
	_poly([5.6, 26, 13.4, 26, 9.5, 30.5], SLATE)
	_r(-14.5, 4, -11, 18.5, STONE) # a small corner tower
	_poly([-15, 18.5, -10.5, 18.5, -12.75, 22], SLATE)

## Dürnstein: the castle ruin on its crag high over the Danube, the vineyards on the slope, and by the river the
## abbey with its blue-and-white Baroque tower and ornate spire.
static func _duernstein() -> void:
	_poly([-22, 2.5, 22, 2.5, 22, 10, 10, 14, 2, 18, -6, 20, -14, 25, -22, 22], GRASS)
	if _detail(1.2):
		for k in 9:
			var x := -20.0 + k * 4.0
			_l(x, 3.4, x + 3.0, 9.0 + maxf(0.0, -x) * 0.35, Color("86b35a"), 0.25)
	_poly([-19, 22.6, -15, 24.6, -9.6, 25.2, -8, 28.4, -11, 30.2, -15, 29.4, -18.4, 26.4], ROCK)
	_poly([-16.4, 28.6, -10.2, 28.6, -10.2, 31, -11.4, 32.6, -12.6, 31, -14, 33.4, -15.2, 31.2, -16.4, 32], RUIN)
	if _detail(1.2):
		_r(-14.6, 29.4, -13.8, 30.6, WIN)
		_r(-12.2, 29.4, -11.4, 30.6, WIN)
	_r(-22, 0, 22, 2.5, WATER)
	_r(-4, 2.5, 13, 9, WHITE)
	_poly([-4.4, 9, 13.4, 9, 11.6, 11.2, -2.6, 11.2], RED_ROOF)
	_windows(-3, 12, 4.5, 6.5, 7, WIN)
	var blue := Color("7fa8d6")
	_r(3.5, 2.5, 8.5, 18, blue)
	for x in [3.5, 8.0]:
		_r(x, 2.5, x + 0.5, 18, WHITE)
	_r(3.3, 12.6, 8.7, 13.2, WHITE)
	_r(3.3, 17.6, 8.7, 18.2, WHITE)
	_clock(6, 15.3, 1.1)
	_arch(6, 9.2, 1.4, 2.4, WIN)
	_onion(6, 18.2, 5.0, 7.0, blue.lightened(0.2))
	_l(6, 25.2, 6, 26.6, GOLD, 0.15)
	_l(5.4, 26.0, 6.6, 26.0, GOLD, 0.15)

## Feldkirch's Schattenburg: a compact white medieval castle on its knoll, the tall keep with a steep red-brown roof,
## the hall with its wooden gallery and the curtain wall.
static func _schattenburg() -> void:
	_poly([-15, 0, 15, 0, 12, 5, -12, 5], GRASS)
	var w := Color("eee8dc")
	_r(-12, 5, 12, 10, w.darkened(0.05))
	for x in range(-12, 12, 2):
		_r(x, 10, x + 1, 10.8, w.darkened(0.05))
	_r(-10, 10, 4, 16, w)
	_poly([-10.6, 16, 4.6, 16, 2.6, 19.4, -8.6, 19.4], RED_ROOF)
	_r(-8.6, 12.6, 2.6, 13.8, Color("7a5434")) # the wooden gallery
	if _detail(1.2):
		for x in [-8.2, -5.4, -2.6, 0.2, 2.2]:
			_r(x, 10, x + 0.3, 12.6, Color("7a5434"))
	_windows(-9, 3, 14.4, 15.6, 6, WIN)
	_r(4, 5, 10, 20.5, w)
	_r(4, 5, 5, 20.5, w.darkened(0.08))
	_windows(5, 9.4, 17, 18.6, 2, WIN)
	_windows(5, 9.4, 12, 13.6, 2, WIN)
	_poly([3.5, 20.5, 10.5, 20.5, 7, 25.8], RED_ROOF)
	_arch(-5, 5, 2.4, 3.2, WIN)

## Wels's Ledererturm: the square gate tower of the old town walls, light plaster, a clock face, a Baroque onion
## roof and the arched passage at its foot.
static func _ledererturm() -> void:
	_r(-3.5, 0, 3.5, 18, PLASTER)
	_r(-3.5, 0, -2.7, 18, PLASTER.darkened(0.08))
	_arch(0, 0, 3.6, 4.6, WIN)
	_r(-3.7, 6, 3.7, 6.4, PLASTER.darkened(0.12))
	_windows(-2.4, 2.4, 8.4, 10.2, 2, WIN)
	_windows(-1.2, 1.2, 11.6, 13, 1, WIN)
	_clock(0, 15.4, 1.4)
	_r(-3.9, 18, 3.9, 18.6, PLASTER.darkened(0.12))
	_onion(0, 18.6, 7.0, 6.0, Color("4d6b5a"))
	_l(0, 24.6, 0, 26, GOLD, 0.12)
	_c(0, 25.4, 0.22, GOLD)

## Krems's Steiner Tor: the ochre gate tower with white corners, the arched passage, four small corner turrets round
## the upper stage and the Baroque spire on top.
static func _steiner_tor() -> void:
	_r(-4, 0, 4, 15, OCHRE)
	for x in [-4.0, 3.4]:
		_r(x, 0, x + 0.6, 15, WHITE)
	_arch(0, 0, 3.6, 5.6, WIN)
	_r(-4.2, 7.2, 4.2, 7.7, WHITE)
	_windows(-2.4, 2.4, 9.4, 11.4, 2, WIN)
	_r(-4.3, 14.8, 4.3, 15.4, WHITE)
	_r(-3, 15.4, 3, 19.4, WHITE)
	_clock(0, 17.4, 1.2)
	for x in [-3.3, 3.3]: # the turrets at the back, peeking out
		_r(x - 0.6, 15.4, x + 0.6, 18.6, OCHRE.darkened(0.15))
		_poly([x - 0.8, 18.6, x + 0.8, 18.6, x, 20.6], SLATE.darkened(0.1))
	for x in [-4.6, 4.6]: # the front ones on the corners
		_r(x - 0.8, 13.6, x + 0.8, 17.6, OCHRE)
		_poly([x - 1.0, 17.6, x + 1.0, 17.6, x, 20], SLATE)
	_onion(0, 19.4, 4.6, 5.6, SLATE)
	_l(0, 25, 0, 26, GOLD, 0.12)

## St. Pölten Cathedral: the Baroque church with its ochre-and-white façade and the one tall tower crowned by a
## green onion cupola.
static func _dom_st_poelten() -> void:
	var o := Color("e9cf8e")
	_r(-12, 0, 3, 16, o)
	for x in [-12.0, -7.0, -2.0]:
		_r(x, 0, x + 0.7, 16, WHITE)
	_poly([-12.5, 16, 3.5, 16, 1.4, 21, -10.4, 21], RED_ROOF)
	_windows(-11, 2, 7, 12, 3, WIN)
	_arch(-4.5, 0, 2.4, 4, WIN)
	_r(2.5, 0, 9.5, 30, o)
	_r(2.5, 0, 3.2, 30, WHITE)
	_r(8.8, 0, 9.5, 30, WHITE)
	for y in [10.0, 20.0, 29.4]:
		_r(2.2, y, 9.8, y + 0.6, WHITE)
	_arch(6, 0, 2.6, 4.6, WIN)
	_arch(6, 13, 1.6, 4, WIN)
	_clock(6, 24.6, 1.6)
	_onion(6, 30, 7.6, 10.4, COPPER)
	_l(6, 40.4, 6, 43.6, GOLD, 0.15)
	_l(5.2, 42.6, 6.8, 42.6, GOLD, 0.15)
