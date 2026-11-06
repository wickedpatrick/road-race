class_name LandmarksRsA
extends RefCounted
## Serbian landmarks (Belgrade to Čačak), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const STONE := Color("cdbf9f")
const STONE_D := Color("a99a7a")
const BRICK := Color("a5452f")
const WATER := Color("4f8fc0")
const GRASS := Color("5d8f42")
const TREE := Color("3f6f34")
const WIN := Color("3a4048")
const GOLD := Color("e0b43a")
const DARK := Color("2e3238")
const BRONZE := Color("5d6b4f")
const WHITE := Color("f2efe6")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"pobednik": _pobednik()
		"petrovaradin_clock": _petrovaradin_clock()
		"nis_fortress": _nis_fortress()
		"yugo": _yugo()
		"subotica_hall": _subotica_hall()
		"weifert_brewery": _weifert_brewery()
		"begej_bridge": _begej_bridge()
		"kablar_meanders": _kablar_meanders()
		"petrova_crkva": _petrova_crkva()
		"zica": _zica()
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

## The Victor (Pobednik) on Belgrade's Kalemegdan: a stepped stone base, a tall Doric column and the bronze nude
## warrior on top, a falcon on his raised left hand and a sword held down in his right.
static func _pobednik() -> void:
	_r(-6, 0, 6, 3, STONE_D)
	_r(-4.5, 3, 4.5, 7, STONE)
	_r(-1.6, 7, 1.6, 31, STONE)
	for x in [-1.0, 0.0, 1.0]:
		_l(x, 7.5, x, 30.5, STONE_D, 0.12)
	_r(-2.4, 31, 2.4, 32.2, STONE_D)
	# the warrior
	var b := BRONZE
	_r(-0.7, 32.2, -0.2, 35, b)
	_r(0.2, 32.2, 0.7, 35, b)
	_r(-0.8, 35, 0.8, 37.6, b)
	_c(0, 38.3, 0.55, b)
	_l(0.7, 37.3, 1.8, 39.6, b, 0.35)
	_poly([1.4, 39.6, 2.4, 40, 1.9, 39.1], DARK)
	_l(-0.7, 37.2, -1.3, 35.2, b, 0.35)
	_l(-1.3, 35.4, -1.3, 32.6, Color("8a8f86"), 0.2)

## Petrovaradin Fortress above Novi Sad: the zigzag bastion walls on the rock and the clock tower whose big hand shows
## the hours, so boatmen on the Danube could read it from afar.
static func _petrovaradin_clock() -> void:
	_poly([-20, 0, 20, 0, 18, 10, 8, 14, -12, 13, -20, 8], Color("8a8a78"))
	_poly([-19, 8, -12, 13, 8, 14, 18, 10, 17, 16, 6, 15, 0, 17, -10, 15, -18, 14], Color("c2b394"))
	for x in [-14.0, -2.0, 10.0]:
		_poly([x - 3, 15, x + 3, 15, x, 12], Color("a99a7a"))
	# the clock tower
	_r(-3, 15, 3, 25, WHITE)
	_poly([-3.6, 25, 3.6, 25, 0, 28.5], BRICK)
	_r(-0.2, 28.5, 0.2, 30, DARK)
	_c(0, 21, 2.1, DARK)
	_c(0, 21, 1.8, WHITE)
	_l(0, 21, 0, 22.6, DARK, 0.25)   # the big hand: hours
	_l(0, 21, 0.9, 21.6, DARK, 0.18)  # the small hand: minutes
	_windows(-2.2, 2.2, 16, 18, 2, WIN)

## Niš Fortress: the Ottoman-era Istanbul Gate (Stambol kapija), a stone gatehouse with a round arch, flanked by
## low walls with merlons.
static func _nis_fortress() -> void:
	_r(-17, 0, 17, 9, STONE)
	for i in 12:
		var x := -17.0 + i * 2.9
		_r(x, 9, x + 1.6, 10.5, STONE)
	_r(-6, 0, 6, 15, Color("d6cbb0"))
	_poly([-6.5, 15, 6.5, 15, 6.5, 16, -6.5, 16], STONE_D)
	_poly([-2.6, 0, 2.6, 0, 2.6, 6] + _arc(0, 6, 2.6, 2.6, 0, PI, 8), DARK)
	_r(-4.5, 11, -3.5, 13, WIN)
	_r(3.5, 11, 4.5, 13, WIN)
	_r(-17, 0, 17, 0.6, Color("6a9a50"))

## The Yugo (Zastava Koral) from Kragujevac: a little boxy three-door hatchback, red, with the square headlamps.
static func _yugo() -> void:
	var body := Color("c0392b")
	_poly([-2.4, 0.35, 2.4, 0.35, 2.45, 1.05, 1.6, 1.15, 0.9, 1.75, -1.6, 1.8, -2.35, 1.2], body)
	_poly([0.75, 1.15, 1.45, 1.13, 0.85, 1.65], Color("9cc8e6"))
	_poly([-1.45, 1.16, 0.6, 1.15, 0.6, 1.66, -1.45, 1.7], Color("9cc8e6"))
	_l(-0.4, 1.15, -0.4, 1.68, body, 0.07)
	_r(2.25, 0.75, 2.45, 0.95, Color("f6f0c8"))
	_r(-2.4, 0.45, 2.45, 0.6, DARK)
	for x in [-1.5, 1.5]:
		_c(x, 0.33, 0.33, Color("1e2023"))
		_c(x, 0.33, 0.17, Color("b0b4b8"))

## Subotica Town Hall: the Hungarian Art Nouveau palace with its glazed Zsolnay-tile roofs in green and gold, gabled
## wings and the tall central tower.
static func _subotica_hall() -> void:
	var wall := Color("e8d9a6")
	_r(-28, 0, 28, 16, wall)
	_windows(-26, 26, 3, 7, 14, WIN)
	_windows(-26, 26, 10, 14, 14, WIN)
	_poly([-28, 16, 28, 16, 25, 21, -25, 21], Color("3f8a5a"))
	for x in [-20.0, 0.0, 20.0]:
		_poly([x - 5, 16, x + 5, 16, x + 5, 20, x, 26, x - 5, 20], wall)
		_poly([x - 5.5, 20, x, 26.5, x + 5.5, 20, x + 4.5, 20, x, 25, x - 4.5, 20], Color("c8932a"))
		_r(x - 1.2, 19, x + 1.2, 22, WIN)
	# the tower
	_r(-3, 16, 3, 33, wall)
	_r(-3, 30, 3, 31, Color("c8932a"))
	_c(0, 28, 1.3, Color("3f8a5a"))
	_poly([-3.4, 33, 3.4, 33, 0, 40], Color("3f8a5a"))
	_l(0, 40, 0, 40.5, GOLD, 0.2)

## The Weifert brewery in Pančevo: red-brick halls with arched windows, a malt house roof and the tall chimney.
static func _weifert_brewery() -> void:
	_r(-22, 0, 4, 14, BRICK)
	_poly([-22.5, 14, 4.5, 14, 0, 18, -18, 18], Color("6b4a3a"))
	for i in 6:
		var x := -19.0 + i * 4
		_poly([x - 1, 3, x + 1, 3, x + 1, 9] + _arc(x, 9, 1, 1.2, 0, PI, 5), WIN)
	_r(4, 0, 18, 20, Color("b8573c"))
	_poly([3.5, 20, 18.5, 20, 11, 25], Color("6b4a3a"))
	_r(9.5, 22, 12.5, 25, Color("b8573c"))
	_windows(6, 16, 5, 16, 3, WIN)
	_r(-14, 14, -11.6, 30, Color("8f3a28"))
	_r(-14.4, 28.6, -11.2, 30, DARK)
	_r(-21, 6, -16, 8, WHITE)

## The Little Bridge (Mali most) in Zrenjanin: a slim iron arch footbridge over the still water of the old Begej.
static func _begej_bridge() -> void:
	_r(-17, 0, 17, 2, WATER)
	_r(-17, 0, -12, 4, GRASS)
	_r(12, 0, 17, 4, GRASS)
	var arc := _arc(0, 2, 13, 5.5, 0, PI, 16)
	for i in range(0, arc.size() - 2, 2):
		_l(arc[i], arc[i + 1], arc[i + 2], arc[i + 3], Color("2f5a7a"), 0.45)
	_l(-13, 4.6, 13, 4.6, Color("2f5a7a"), 0.3)
	for x in range(-10, 11, 2):
		var top := 2.0 + 5.5 * sqrt(max(0.0, 1.0 - pow(x / 13.0, 2)))
		_l(x, 4.6, x, top, Color("2f5a7a"), 0.12)
	_r(-14, 4, 14, 4.3, Color("8a7a60"))

## The Ovčar-Kablar gorge near Čačak: two steep wooded mountains with the West Morava winding in tight loops at
## their feet.
static func _kablar_meanders() -> void:
	_poly([-60, 0, -40, 34, -26, 52, -12, 30, 0, 12, 0, 0], Color("4f7a3a"))
	_poly([0, 0, 0, 14, 14, 40, 26, 58, 44, 30, 60, 0], Color("44702f"))
	_poly([-26, 52, -30, 44, -22, 46], Color("8a8a78"))
	_poly([26, 58, 22, 48, 31, 50], Color("8a8a78"))
	_r(-60, 0, 60, 8, GRASS)
	# the river loops
	var pts := []
	for i in 41:
		var x := -56.0 + i * 2.8
		pts.append(x)
		pts.append(4.0 + 3.2 * sin(i * 0.55))
	for i in range(0, pts.size() - 2, 2):
		_l(pts[i], pts[i + 1], pts[i + 2], pts[i + 3], WATER, 1.6)
	for x in [-45.0, -20.0, 18.0, 40.0]:
		_c(x, 30.0 - abs(x) * 0.25, 3, TREE)

## St Peter's Church (Petrova crkva) near Novi Pazar: a small rough-stone rotunda under a round drum and dome, with a
## low apse; the oldest church in Serbia.
static func _petrova_crkva() -> void:
	var s := Color("bfa889")
	_r(-7, 0, 7, 6, s)
	_poly([-7.4, 6, 7.4, 6, 5, 7.6, -5, 7.6], Color("8a6a4a"))
	_r(-3, 6, 3, 10, s)
	_poly(_arc(0, 10, 3.2, 3, 0, PI, 10), Color("8a6a4a"))
	_l(0, 13, 0, 14, DARK, 0.15)
	_l(-0.5, 13.6, 0.5, 13.6, DARK, 0.12)
	_poly([-1, 0, 1, 0, 1, 2.6] + _arc(0, 2.6, 1, 1, 0, PI, 6), DARK)
	_r(-0.4, 7.4, 0.4, 9, WIN)
	for i in 8:
		_l(-7, 1 + i * 0.7, 7, 1 + i * 0.7, Color(0, 0, 0, 0.06), 0.08)

## Žiča Monastery near Kraljevo: the church painted deep red, its tall bell tower over the entrance and the dome over
## the crossing.
static func _zica() -> void:
	var red := Color("b33a2e")
	var roof := Color("6a6e72")
	_r(-14, 0, 12, 10, red)
	_poly([-14.5, 10, 12.5, 10, 10, 13, -12, 13], roof)
	_r(-3, 10, 4, 17, red)
	_poly(_arc(0.5, 17, 3.8, 3.4, 0, PI, 10), roof)
	_l(0.5, 20.4, 0.5, 22.4, GOLD, 0.2)
	_l(-0.3, 21.6, 1.3, 21.6, GOLD, 0.15)
	# the bell tower at the west end
	_r(-14, 0, -8, 21, red)
	_poly([-14.5, 21, -7.5, 21, -11, 25], roof)
	_l(-11, 25, -11, 26.5, GOLD, 0.2)
	_poly([-12.2, 15, -9.8, 15, -9.8, 18] + _arc(-11, 18, 1.2, 1.2, 0, PI, 5), WIN)
	_poly([-12.2, 0, -9.8, 0, -9.8, 4] + _arc(-11, 4, 1.2, 1.2, 0, PI, 5), DARK)
	_windows(-6, 10, 4, 7, 4, WIN)
	_r(12, 0, 14.5, 7, red)
