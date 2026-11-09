class_name LandmarksLvA
extends RefCounted
## Latvian landmarks (Rīga to Rēzekne), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const WHITE := Color("f3f0e8")
const CREAM := Color("efe3c4")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const GRASS := Color("5d8f42")
const TREE := Color("3f6f34")
const GOLD := Color("e0b43a")
const RED_ROOF := Color("a5452f")
const RED_ROOF_D := Color("7f3424")
const GRANITE := Color("8d8a84")
const PATINA := Color("5f9e86")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"lv_riga_freedom": _riga_freedom()
		"lv_daugavpils_fortress": _daugavpils_fortress()
		"lv_liepaja_amber": _liepaja_amber()
		"lv_jelgava_petrina": _jelgava_petrina()
		"lv_jurmala_villa": _jurmala_villa()
		"lv_ventspils_castle": _ventspils_castle()
		"lv_rezekne_mara": _rezekne_mara()
		"lv_valmiera_simon": _valmiera_simon()
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

## A five-pointed star of outer radius r centred at (x, y), drawn as five triangles over a pentagon.
static func _star(x: float, y: float, r: float, col: Color) -> void:
	var inner := r * 0.42
	var pent := []
	for k in 5:
		var a := PI * 0.5 + TAU * k / 5.0 + TAU / 10.0
		pent.append_array([x + cos(a) * inner, y + sin(a) * inner])
	_poly(pent, col)
	for k in 5:
		var a := PI * 0.5 + TAU * k / 5.0
		var a0 := a - TAU / 10.0
		var a1 := a + TAU / 10.0
		_poly([x + cos(a0) * inner, y + sin(a0) * inner, x + cos(a) * r, y + sin(a) * r, x + cos(a1) * inner, y + sin(a1) * inner], col)

## The Freedom Monument in Rīga (1935): stepped red granite base with sculpture groups, a tall travertine column
## and on top the copper woman ("Milda") holding up three golden stars.
static func _riga_freedom() -> void:
	var gran := Color("8a6f66")
	var gran_d := Color("6f5850")
	_r(-7, 0, 7, 1.2, gran_d)
	_r(-6.2, 1.2, 6.2, 2.4, gran)
	# the base with its sculpture groups at the corners
	_r(-4.8, 2.4, 4.8, 11, gran)
	_r(-4.8, 10.4, 4.8, 11, gran_d)
	var stone := Color("cfc6b4")
	for x in [-4.2, 4.2]:
		_r(x - 1.3, 2.4, x + 1.3, 8.6, stone)
		_c(x, 9.3, 0.9, stone)
		_l(x - 0.6, 3, x - 0.6, 8, Color("b5ac9a"), 0.25)
		_l(x + 0.6, 3, x + 0.6, 8, Color("b5ac9a"), 0.25)
	# the relief band and the inscription
	_r(-2.6, 7.6, 2.6, 9.6, Color("c9bfa9"))
	if _detail(1.5):
		_l(-2.0, 8.6, 2.0, 8.6, GOLD, 0.15)
	# the column, slightly narrowing
	var trav := Color("e8e0cc")
	_poly([-1.7, 11, 1.7, 11, 1.35, 35.5, -1.35, 35.5], trav)
	_l(0.9, 11.5, 0.7, 35, Color("d2c9b2"), 0.4)
	if _detail(1.0):
		for k in 6:
			var y := 13.0 + k * 3.8
			_l(-1.6 + k * 0.05, y, 1.6 - k * 0.05, y, Color("d6ccb4"), 0.12)
	_r(-1.8, 35.5, 1.8, 36.3, Color("d8cfba"))
	# Milda: a robed copper figure, arms up, three stars in an arc above her head
	_poly([-1.0, 36.3, 1.0, 36.3, 0.75, 39.6, 0.45, 40.6, -0.45, 40.6, -0.75, 39.6], PATINA)
	_c(0, 41.1, 0.48, PATINA)
	_l(-0.45, 40.3, -1.1, 42.2, PATINA, 0.32)
	_l(0.45, 40.3, 1.1, 42.2, PATINA, 0.32)
	_poly([-1.4, 42.0, 1.4, 42.0, 1.2, 42.4, -1.2, 42.4], Color("4f8a74"))
	for x in [-1.1, 0.0, 1.1]:
		_star(x, 43.0 + (0.25 if x == 0.0 else 0.0), 0.55, GOLD)

## Daugavpils Fortress: grassy ramparts with a bastion, the classical gate in the middle and the red-brick arsenal
## (the Rothko centre) behind them, the Latvian flag over the gate.
static func _daugavpils_fortress() -> void:
	var brick := Color("a5452f")
	# the arsenal behind
	_r(4, 4, 28, 14, brick)
	_poly([3.5, 14, 28.5, 14, 26.5, 16.5, 5.5, 16.5], Color("5b4a44"))
	for k in 8:
		_arched(6.0 + k * 3.0, 6.5, 1.2, 4.6, WIN)
	_r(-26, 4, -6, 11, Color("b75b3f"))
	_poly([-26.5, 11, -5.5, 11, -7.5, 13.2, -24.5, 13.2], Color("5b4a44"))
	_windows(-25, -7, 6, 9, 6, WIN)
	# the ramparts and a bastion's point
	_poly([-30, 0, 30, 0, 30, 4.5, 22, 6.5, -22, 6.5, -30, 4.5], GRASS)
	_poly([-30, 0, -18, 0, -24, 2.8], Color("4f7d39"))
	_l(-29, 4.5, 29, 4.5, Color("6fa050"), 0.3)
	# the gate: a pale classical front with a big arch and pilasters
	var gate := Color("e9dcb8")
	_r(-6, 0, 6, 13, gate)
	_r(-6.5, 12.6, 6.5, 13.6, Color("d6c79f"))
	_poly([-6.5, 13.6, 6.5, 13.6, 0, 17], gate)
	_poly([-5.2, 14.1, 5.2, 14.1, 0, 16.4], Color("d6c79f"))
	_arched(0, 0, 5, 9.5, Color("3b3631"))
	for x in [-5.2, -3.6, 3.6, 5.2]:
		_r(x - 0.35, 0, x + 0.35, 12.6, WHITE)
	# the flag: carmine, white, carmine
	_l(0, 17, 0, 21.5, DARK, 0.15)
	var carmine := Color("9e3039")
	_r(0.1, 19.6, 3.4, 21.3, carmine)
	_r(0.1, 20.25, 3.4, 20.65, WHITE)

## The Great Amber concert hall in Liepāja (2015): a leaning, faceted volume of amber-coloured glass rising to the
## right, its panes lit from within, on a light plaza.
static func _liepaja_amber() -> void:
	_r(-28, 0, 28, 1, Color("c9c4b8"))
	var amber := Color("e09a2b")
	var amber_d := Color("b8731a")
	var amber_l := Color("f4bc55")
	_poly([-25, 1, 26, 1, 27, 23, 12, 29.5, -14, 22, -26, 13], amber)
	_poly([12, 29.5, 27, 23, 26, 1, 15, 1], amber_d)
	_poly([-26, 13, -14, 22, -6, 14, -24, 7], amber_l)
	# the panes
	if _detail(0.8):
		var line := Color(1, 1, 1, 0.22)
		for k in 9:
			var x := -22.0 + k * 5.0
			var top := 13.0 + (x + 26.0) * 0.35 if x < -14.0 else 22.0 + (x + 14.0) * 0.29
			_l(x, 1.2, x, minf(top, 29.0) - 0.6, line, 0.12)
		for k in 6:
			var y := 4.0 + k * 3.8
			_l(-25.0 + minf(y, 13.0) * 0.08, y, 26.4, y, line, 0.12)
	# the glass doors and the lit foyer
	_r(-8, 1, 8, 4.5, Color("ffd890"))
	_windows(-7.5, 7.5, 1, 4.2, 6, Color("8a5a20"))
	_r(-10, 4.5, 10, 5.2, Color("8a5a20"))

## Academia Petrina in Jelgava (1775): a long white two-storey building, the central bay with its pediment and the
## tower over it in tiers: a square base, an octagonal lantern with clock faces and a slim cap.
static func _jelgava_petrina() -> void:
	var roof := Color("5a5e62")
	_r(-21, 0, 21, 11.5, WHITE)
	_r(-21.5, 11.2, 21.5, 12, Color("d8d4ca"))
	_poly([-21.5, 12, 21.5, 12, 19, 15, -19, 15], roof)
	_windows(-20, -6, 2, 5, 5, WIN)
	_windows(-20, -6, 7, 10, 5, WIN)
	_windows(6, 20, 2, 5, 5, WIN)
	_windows(6, 20, 7, 10, 5, WIN)
	# the central bay
	_r(-5.5, 0, 5.5, 13, Color("ece6d8"))
	_arched(0, 0, 2.2, 4.2, Color("6b5040"))
	_windows(-4.5, 4.5, 6.5, 10, 3, WIN)
	for x in [-5.0, -1.8, 1.8, 5.0]:
		_r(x - 0.3, 0.5, x + 0.3, 12.6, Color("ddd6c6"))
	_poly([-6, 13, 6, 13, 0, 16], Color("ece6d8"))
	# the tower
	_r(-3, 15, 3, 19.5, WHITE)
	_r(-3.3, 19.5, 3.3, 20.2, Color("d8d4ca"))
	_poly([-2.4, 20.2, 2.4, 20.2, 2.4, 24.5, -2.4, 24.5], WHITE)
	_c(0, 22.4, 0.9, Color("2f3a46"))
	_l(0, 22.4, 0, 23.1, GOLD, 0.12)
	_l(0, 22.4, 0.5, 22.4, GOLD, 0.12)
	_poly(_arc(0, 24.5, 2.6, 1.8, 0, PI, 10), roof)
	_r(-0.7, 26.3, 0.7, 27.4, WHITE)
	_poly([-0.9, 27.4, 0.9, 27.4, 0, 29.6], roof)

## A wooden summer villa in Jūrmala: pale boards, a glazed veranda with carved trim, a steep gable and a turret with a
## pointed cap, pines either side.
static func _jurmala_villa() -> void:
	# the pines
	for x in [-10.2, 10.2]:
		_l(x, 0, x, 12, Color("8a5a3a"), 0.45)
		_poly([x - 1.8, 10, x + 1.8, 10, x + 1.0, 13, x + 1.6, 13, x, 17, x - 1.6, 13, x - 1.0, 13], TREE)
	var wood := Color("e8d9a8")
	var trim := Color("f6f3ea")
	var roof := Color("7b4a3a")
	# the house
	_r(-6, 0, 6, 9, wood)
	if _detail(1.2):
		for k in 8:
			_l(-6, 0.6 + k * 1.05, 6, 0.6 + k * 1.05, Color("d3c290"), 0.08)
	_poly([-6.6, 9, 6.6, 9, 0, 14], roof)
	_poly([-4.6, 9.3, 4.6, 9.3, 0, 12.8], wood)
	_c(0, 10.8, 0.7, trim)
	_windows(-5, 5, 5, 7.6, 3, WIN)
	# the glazed veranda on the left
	_r(-9.5, 0, -6, 6, trim)
	_r(-9.2, 2, -6.3, 5.4, Color("8fb4c4"))
	for x in [-8.5, -7.5, -6.6]:
		_l(x, 2, x, 5.4, trim, 0.12)
	_poly([-10, 6, -6, 6, -6, 7.4], roof)
	# the turret on the right
	_r(4.2, 0, 7.4, 12, wood)
	_windows(4.4, 7.2, 8.5, 10.5, 1, WIN)
	_poly([3.8, 12, 7.8, 12, 5.8, 17.5], roof)
	_l(5.8, 17.5, 5.8, 18, DARK, 0.1)
	# the porch
	_r(-1.2, 0, 1.2, 3, Color("8a6040"))

## Ventspils Castle of the Livonian Order: a whitewashed square block round a courtyard, a red tiled roof, small
## windows and the corner tower with its pyramid roof.
static func _ventspils_castle() -> void:
	var wall := Color("e7e2d6")
	var shade := Color("d1cbbd")
	_r(-17, 0, 15, 13, wall)
	_r(-17, 0, 15, 1.2, Color("b9b2a2"))
	_poly([-17.5, 13, 15.5, 13, 13, 17.5, -15, 17.5], RED_ROOF)
	_l(-15, 17.5, 13, 17.5, RED_ROOF_D, 0.25)
	_windows(-13, 13, 4, 6, 9, WIN)
	_windows(-13, 13, 8.5, 10.5, 9, WIN)
	_arched(2, 0, 3, 4.5, Color("5b4636"))
	# the tower
	_r(-17.5, 0, -10.5, 19.5, shade)
	_r(-17.5, 0, -10.5, 1.2, Color("b9b2a2"))
	_windows(-16.5, -11.5, 13, 15, 2, WIN)
	_windows(-16.5, -11.5, 8, 10, 2, WIN)
	_poly([-18, 19.5, -10, 19.5, -14, 23.6], RED_ROOF)
	_l(-14, 23.6, -14, 24, DARK, 0.1)

## Latgales Māra in Rēzekne: a woman in bronze raising a cross high over her head, on a tall stepped granite pillar.
static func _rezekne_mara() -> void:
	_r(-3.6, 0, 3.6, 0.8, GRANITE)
	_r(-2.8, 0.8, 2.8, 1.8, Color("9b9890"))
	_poly([-1.6, 1.8, 1.6, 1.8, 1.3, 9.6, -1.3, 9.6], Color("a29f98"))
	_r(-1.6, 9.6, 1.6, 10.2, GRANITE)
	if _detail(2.0):
		_l(-0.8, 4, 0.8, 4, Color("7d7a74"), 0.1)
		_l(-0.8, 4.6, 0.8, 4.6, Color("7d7a74"), 0.1)
	# the figure, dress wide at the hem
	var bronze := Color("3f4a3e")
	_poly([-1.0, 10.2, 1.0, 10.2, 0.45, 12.6, 0.35, 13.2, -0.35, 13.2, -0.45, 12.6], bronze)
	_c(0, 13.6, 0.36, bronze)
	_l(0.3, 13.0, 0.8, 14.4, bronze, 0.22)
	_l(-0.3, 13.0, -0.1, 12.0, bronze, 0.2)
	# the cross held up in her right hand
	_l(0.85, 13.6, 0.85, 15.9, bronze, 0.2)
	_l(0.3, 15.2, 1.4, 15.2, bronze, 0.2)

## St Simon's Church in Valmiera (1283): a stone nave with tall pointed windows under a steep red roof, the square
## west tower and its slim dark spire.
static func _valmiera_simon() -> void:
	var stone := Color("d5cfc0")
	var stone_d := Color("bdb6a5")
	# the nave
	_r(-13.5, 0, 5, 13, stone)
	_poly([-14, 13, 5, 13, 5, 23, -4.5, 23], RED_ROOF)
	for x in [-11.0, -7.0, -3.0, 1.0]:
		_arched(x, 3, 1.6, 7.5, WIN)
	_poly([-14, 13, -14, 0, -13.5, 0, -13.5, 13], stone_d)
	# the tower
	_r(5, 0, 13.5, 33, stone)
	_r(5, 0, 6, 33, stone_d)
	_arched(9.25, 0, 2.6, 5, Color("5b4636"))
	_arched(9.25, 15, 1.4, 3.6, WIN)
	_arched(9.25, 26, 1.6, 4.4, WIN)
	_r(4.6, 32.6, 13.9, 33.6, stone_d)
	# the spire
	_poly([4.8, 33.6, 13.7, 33.6, 11.2, 36.5, 7.3, 36.5], Color("2f3a36"))
	_poly([7.3, 36.5, 11.2, 36.5, 9.25, 50.5], Color("2f3a36"))
	_l(9.25, 50.5, 9.25, 51.8, GOLD, 0.15)
	_c(9.25, 51.0, 0.3, GOLD)
