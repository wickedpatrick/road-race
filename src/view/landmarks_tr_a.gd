class_name LandmarksTrA
extends RefCounted
## Turkish landmarks (İstanbul to Mersin), drawn with LandmarkPainter's helpers (metres from the base point, y up).
## The shared Turkish shapes (domes, pencil minarets, the flag) live here for LandmarksTrB and LandmarksTrC too.

const STONE := Color("e3dccb")
const STONE_D := Color("c9bfa8")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const LEAD := Color("8a9097")
const WATER := Color("3f86b8")
const WATER_L := Color("8cc0e0")
const GRASS := Color("6f9a4a")
const TR_RED := Color("e30a17")
const WHITE := Color("f4f1ea")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"tr_hagia_sophia": _hagia_sophia()
		"tr_galata_tower": _galata()
		"tr_anitkabir": _anitkabir()
		"tr_izmir_clock_tower": _clock_tower()
		"tr_green_tomb": _green_tomb()
		"tr_gaziantep_castle": _gaziantep_castle()
		"tr_adana_taskopru": _taskopru()
		"tr_mevlana": _mevlana()
		"tr_hadrians_gate": _hadrians_gate()
		"tr_erciyes": _erciyes()
		"tr_kizkalesi": _kizkalesi()
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

## A dome: half an ellipse standing on y, with a small finial.
static func dome(cx: float, y: float, rx: float, ry: float, col: Color) -> void:
	_poly(_arc(cx, y, rx, ry, 0.0, PI, 14), col)
	_l(cx, y + ry, cx, y + ry + maxf(0.6, ry * 0.15), DARK, maxf(0.15, rx * 0.04))

## An arched opening: a rectangle under a half circle, its foot at (x, y0).
static func arched(x: float, y0: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.5, y0, x + w * 0.5, y0] + _arc(x, y0 + h - w * 0.5, w * 0.5, w * 0.5, 0.0, PI, 6) + [x - w * 0.5, y0 + h - w * 0.5], col)

## An Ottoman pencil minaret: a slim shaft with `balconies` rings and a tall lead cone, foot at (x, y0), h tall.
static func minaret(x: float, y0: float, h: float, w: float, col: Color, balconies: int) -> void:
	var top := y0 + h * 0.8
	_r(x - w * 0.6, y0, x + w * 0.6, y0 + h * 0.08, col.darkened(0.12))
	_r(x - w * 0.5, y0, x + w * 0.5, top, col)
	for k in balconies:
		var by := y0 + h * (0.5 + 0.28 * float(k + 1) / float(balconies + 1))
		_r(x - w * 0.85, by, x + w * 0.85, by + w * 0.35, col.darkened(0.18))
	_poly([x - w * 0.55, top, x + w * 0.55, top, x, y0 + h * 0.98], LEAD)
	_l(x, y0 + h * 0.97, x, y0 + h, DARK, maxf(0.1, w * 0.08))

## The Turkish flag, its cloth's lower left corner at (x, y), w wide, on a pole standing on the ground at `foot`.
static func flag(x: float, y: float, w: float, foot := 0.0) -> void:
	_l(x, foot, x, y + w * 0.7, DARK, w * 0.05)
	var h := w * 0.66
	_r(x, y, x + w, y + h, TR_RED)
	_c(x + w * 0.36, y + h * 0.5, h * 0.25, WHITE)
	_c(x + w * 0.4, y + h * 0.5, h * 0.2, TR_RED)
	_c(x + w * 0.58, y + h * 0.5, h * 0.09, WHITE)

## Hagia Sophia: the great shallow lead dome on its windowed drum, the half domes east and west, the ochre walls
## with their heavy buttresses, and the four minarets added in Ottoman times.
static func _hagia_sophia() -> void:
	var wall := Color("d9a77c")
	var wd := wall.darkened(0.15)
	_r(-30, 0, 30, 3, STONE_D)
	_r(-24, 3, 24, 22, wall)
	for x in [-24.0, -15.0, 11.0, 20.0]:
		_r(x, 3, x + 4.0, 25, wd)
	_r(-14, 22, 14, 28, wall)
	# the half domes and the drum
	dome(-12, 26, 9, 7, LEAD)
	dome(12, 26, 9, 7, LEAD)
	_r(-15, 28, 15, 33, wall)
	if _detail(0.6):
		_windows(-14, 14, 29.5, 32, 14, WIN)
		_windows(-22, -16, 8, 14, 3, WIN)
		_windows(16, 22, 8, 14, 3, WIN)
		for x in [-8.0, -3.0, 2.0, 7.0]:
			arched(x + 0.5, 5, 2.6, 6, WIN)
	dome(0, 33, 16, 11, LEAD)
	# the minarets, the western pair taller
	minaret(-36, 0, 56, 2.2, STONE, 2)
	minaret(-28, 0, 50, 2.0, STONE, 1)
	minaret(28, 0, 50, 2.0, wall, 1)
	minaret(36, 0, 56, 2.2, STONE, 2)

## The Galata Tower: a round stone tower over the Golden Horn, the arched gallery round its top storey and the
## pointed conical roof.
static func _galata() -> void:
	var st := Color("cfc3a8")
	var sd := st.darkened(0.14)
	_r(-8, 0, 8, 5, sd)
	_r(-6.5, 5, 6.5, 47, st)
	_r(-6.5, 5, -4.5, 47, sd)
	_r(4.5, 5, 6.5, 47, st.lightened(0.08))
	if _detail(0.6):
		for y in [12.0, 20.0, 28.0, 36.0]:
			arched(-1.5, y, 1.2, 2.6, WIN)
			arched(2.0, y + 3.5, 1.2, 2.6, WIN)
		arched(0, 0, 2.6, 4, WIN)
	# the gallery: a balcony ring, arches and the cornice
	_r(-7.6, 46.5, 7.6, 47.6, sd)
	_r(-6.8, 47.6, 6.8, 53, st)
	for k in 6:
		arched(-5.0 + k * 2.0, 48.3, 1.1, 3.6, WIN)
	_r(-7.2, 53, 7.2, 54, sd)
	_poly([-7.4, 54, 7.4, 54, 0, 66], Color("5d6f7e"))
	_l(0, 65.5, 0, 67, DARK, 0.2)

## Anıtkabir: Atatürk's mausoleum, a colonnaded hall of pale stone with square pillars on its high stepped podium,
## a flag beside it.
static func _anitkabir() -> void:
	var st := Color("e2d8c2")
	var sd := st.darkened(0.16)
	_r(-40, 0, 40, 2, sd)
	_r(-34, 2, 34, 4, st.darkened(0.08))
	_r(-30, 4, 30, 6, sd)
	_r(-26, 6, 26, 21, sd.darkened(0.25))
	# pillars all round the front
	var n := 12
	for k in n:
		var x := -25.0 + k * 50.0 / (n - 1)
		_r(x - 0.9, 6, x + 0.9, 21, st)
	_r(-27, 21, 27, 23.5, st)
	_r(-26, 23.5, 26, 26, st.darkened(0.05))
	if _detail(0.6):
		_l(-26, 23.4, 26, 23.4, sd, 0.2)
		_windows(-24, 24, 24.2, 25.4, 16, sd)
	flag(34, 22, 5)

## The Clock Tower of İzmir: an Ottoman tower of four slimmer and slimmer storeys with Moorish arches, the clock
## faces near the top, fountains round its foot.
static func _clock_tower() -> void:
	var st := Color("eadfc4")
	var sd := st.darkened(0.15)
	_r(-7, 0, 7, 0.8, sd)
	for sg in [-1.0, 1.0]:
		_r(sg * 6.6, 0.8, sg * 4.6, 2.0, sd)
		_r(sg * 6.2, 2.0, sg * 5.0, 2.4, WATER_L)
	_r(-3.4, 0.8, 3.4, 8, st)
	arched(0, 1.2, 2.6, 5.6, WIN)
	_r(-3.8, 8, 3.8, 8.8, sd)
	_r(-2.8, 8.8, 2.8, 14, st)
	if _detail(0.8):
		arched(-1.2, 9.6, 1.1, 3.4, WIN)
		arched(1.2, 9.6, 1.1, 3.4, WIN)
	_r(-3.2, 14, 3.2, 14.6, sd)
	_r(-2.3, 14.6, 2.3, 19.5, st)
	_c(0, 17, 1.6, WHITE)
	_c(0, 17, 1.3, Color("f8f4e0"))
	_l(0, 17, 0, 18.1, DARK, 0.15)
	_l(0, 17, 0.8, 17, DARK, 0.15)
	_r(-2.7, 19.5, 2.7, 20, sd)
	_r(-1.7, 20, 1.7, 22.2, st)
	if _detail(0.8):
		arched(0, 20.3, 1.1, 1.8, WIN)
	dome(0, 22.2, 1.9, 2.1, st.darkened(0.05))

## The Green Tomb in Bursa: Mehmed I's octagonal mausoleum in turquoise tiles, its tall portal and the dome
## on a low drum, on a stone terrace among cypresses.
static func _green_tomb() -> void:
	var tile := Color("2f9c8f")
	var td := tile.darkened(0.2)
	_r(-13, 0, 13, 2, STONE_D)
	_poly([-11.5, 2, -6.5, 2, -6.5, 20, -11.5, 18.5], td)
	_poly([6.5, 2, 11.5, 2, 11.5, 18.5, 6.5, 20], td)
	_r(-6.5, 2, 6.5, 20, tile)
	# the portal: a deep arched niche framed in white marble
	_r(-3.4, 2, 3.4, 15, WHITE)
	arched(0, 2, 5.2, 11.5, Color("1f6e66"))
	if _detail(0.6):
		arched(-9, 7, 1.6, 5, WIN)
		arched(9, 7, 1.6, 5, WIN)
		_r(-6.5, 18.5, 6.5, 19.2, WHITE)
	_r(-8, 20, 8, 21.5, td)
	dome(0, 21.5, 8, 7, tile.lightened(0.08))
	for x in [-12.5, 12.5]:
		_poly([x - 1.0, 0, x + 1.0, 0, x, 9], Color("2f5a3a"))

## Gaziantep Castle: round towers and stone walls ringing the top of a steep mound in the old city.
static func _gaziantep_castle() -> void:
	var st := Color("b9a582")
	var sd := st.darkened(0.18)
	_poly([-30, 0, 30, 0, 22, 12, -22, 12], Color("9b8361"))
	_poly([-26, 2, 26, 2, 21, 10, -21, 10], Color("a88f6c"))
	_r(-20, 12, 20, 21, st)
	for k in 13:
		var x := -19.5 + k * 3.2
		_r(x, 21, x + 1.6, 22.2, st)
	for x in [-20.0, -8.0, 6.0, 20.0]:
		_r(x - 3.4, 12, x + 3.4, 25, sd if x < 0.0 else st.darkened(0.08))
		for k in 3:
			_r(x - 3.4 + k * 2.6, 25, x - 2.2 + k * 2.6, 26.4, sd)
		if _detail(0.6):
			_r(x - 0.4, 17, x + 0.4, 19.5, DARK)
	arched(-1, 12, 3.2, 6, DARK)
	_l(-1, 18, -1, 23, DARK, 0.15)

## Taşköprü in Adana: the Roman stone bridge striding over the Seyhan on round arches, with a low parapet.
static func _taskopru() -> void:
	var st := Color("cdbb98")
	var sd := st.darkened(0.15)
	_r(-40, 0, 40, 3, WATER)
	_r(-40, 2.2, 40, 2.6, WATER_L)
	_r(-40, 3, 40, 11, st)
	var n := 8
	for k in n:
		var x := -35.0 + k * 10.0
		arched(x, 2, 7, 7.6, WATER.darkened(0.25))
		if _detail(0.6):
			_poly(_arc(x, 5.5, 4.3, 4.3, 0.0, PI, 8) + _arc(x, 5.5, 3.5, 3.5, PI, 0.0, 8), sd)
	_r(-40, 11, 40, 12.2, sd)
	_r(-40, 12.2, 40, 13, st)
	for x in [-30.0, -10.0, 10.0, 30.0]:
		_l(x, 13, x, 15.5, DARK, 0.2)
		_c(x, 15.7, 0.35, Color("f3e3a0"))

## The Mevlana Museum in Konya: the low lodge with its grey domes and, over Rumi's tomb, the fluted turquoise
## drum with its conical cap.
static func _mevlana() -> void:
	var st := Color("ece5d6")
	var sd := st.darkened(0.14)
	var tq := Color("33b0a0")
	_r(-15, 0, 15, 1.2, sd)
	_r(-14, 1.2, 14, 10, st)
	for x in [-11.0, -6.0, -1.0, 11.0]:
		dome(x, 10, 2.4, 2.2, LEAD)
	if _detail(0.6):
		for x in [-11.0, -6.0, -1.0, 11.0]:
			arched(x, 3, 1.4, 4, WIN)
	_r(1.5, 10, 9, 11.5, sd)
	# the green dome: a fluted drum, a cone above
	_r(2.4, 11.5, 8.0, 19.5, tq)
	if _detail(0.5):
		for k in 6:
			_l(3.0 + k * 0.95, 11.5, 3.0 + k * 0.95, 19.5, tq.darkened(0.2), 0.18)
	_r(2.1, 19.5, 8.3, 20.3, tq.darkened(0.15))
	_poly([2.3, 20.3, 8.1, 20.3, 5.2, 28.5], tq.lightened(0.05))
	_l(5.2, 28.3, 5.2, 30, DARK, 0.15)
	minaret(-15 + 1.2, 0, 26, 1.3, st, 1)

## Hadrian's Gate in Antalya: three marble arches between columns under a richly carved attic, a tower on each
## side.
static func _hadrians_gate() -> void:
	var mb := Color("e6dfd0")
	var md := mb.darkened(0.15)
	var tw := Color("b49572")
	_r(-12, 0, -8, 15, tw)
	_r(8, 0, 12, 13.5, tw)
	for x in [-12.0, 8.0]:
		for k in 3:
			_r(x + k * 1.5, 13.5 if x > 0.0 else 15.0, x + k * 1.5 + 0.8, (13.5 if x > 0.0 else 15.0) + 0.9, tw)
	_r(-8, 0, 8, 1, md)
	_r(-8, 1, 8, 9, mb)
	for x in [-5.0, 0.0, 5.0]:
		arched(x, 1, 3.6, 7.4, Color("4d4a44"))
	for x in [-7.5, -2.5, 2.5, 7.5]:
		_r(x - 0.4, 1, x + 0.4, 9, md)
		_r(x - 0.6, 8.6, x + 0.6, 9.2, WHITE)
	_r(-8.4, 9.2, 8.4, 10.2, mb.lightened(0.1))
	_r(-8, 10.2, 8, 12, md)
	if _detail(0.8):
		for k in 16:
			_r(-7.8 + k, 10.5, -7.4 + k, 11.6, mb)

## Mount Erciyes behind Kayseri: the volcano's snowy twin-peaked cone over the plateau.
static func _erciyes() -> void:
	var rock := Color("7f7366")
	_poly([-60, 0, -34, 10, -12, 32, 2, 48, 9, 44, 16, 42, 34, 18, 60, 0], rock)
	_poly([-60, 0, -40, 6, -20, 0], Color("94876f"))
	_poly([28, 0, 44, 8, 60, 0], Color("94876f"))
	_poly([-12, 32, -4, 38, 2, 48, 9, 44, 16, 42, 22, 32, 15, 34, 9, 30, 4, 35, -3, 30, -7, 33], WHITE)
	_poly([-7, 33, -3, 30, -1, 24, 2, 31], Color("e4e8ec"))
	_r(-60, 0, 60, 1.5, Color("b5a26a"))

## Kızkalesi: the Maiden's Castle, its walls and towers rising straight from a rock islet out in the sea.
static func _kizkalesi() -> void:
	var st := Color("cfc1a0")
	var sd := st.darkened(0.16)
	_r(-30, 0, 30, 4, WATER)
	_r(-30, 3.3, 30, 3.8, WATER_L)
	_poly([-18, 2, 18, 2, 16, 5, -16, 5], Color("8e8068"))
	_r(-14, 5, 14, 13, st)
	for k in 10:
		_r(-13.6 + k * 2.9, 13, -12.2 + k * 2.9, 14, st)
	for x in [-14.0, -4.5, 4.5, 14.0]:
		_r(x - 1.8, 5, x + 1.8, 16.5, sd if absf(x) > 10.0 else st.darkened(0.06))
		_r(x - 2.1, 16.5, x + 2.1, 17.3, sd)
		if _detail(0.6):
			_r(x - 0.25, 10, x + 0.25, 12, DARK)
	arched(0, 5, 2.2, 4, DARK)
