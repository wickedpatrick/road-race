class_name LandmarksRoA
extends RefCounted
## Romanian landmarks (București to Ploiești), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const STONE_D := Color("c8bea6")
const WHITE := Color("f3f0e8")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const GRASS := Color("5d8f42")
const TREE := Color("3f6f34")
const WATER := Color("3f86b8")
const WATER_L := Color("8cc0e0")
const GOLD := Color("e0b43a")
const BRONZE := Color("55705e")
const RO_BLUE := Color("002b7f")
const RO_YELLOW := Color("fcd116")
const RO_RED := Color("ce1126")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"casa_poporului": _casa_poporului()
		"cluj_st_michael": _st_michael()
		"iasi_palace_of_culture": _iasi_palace()
		"constanta_casino": _casino()
		"timisoara_cathedral": _timisoara_cathedral()
		"biserica_neagra": _black_church()
		"romanescu_bridge": _romanescu_bridge()
		"galati_shipyard": _shipyard()
		"vulturul_negru": _black_eagle()
		"ploiesti_pumpjack": _pumpjack()
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

## A pointed (Gothic) window.
static func _pointed(x: float, y0: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.5, y0, x + w * 0.5, y0, x + w * 0.5, y0 + h - w * 0.8, x, y0 + h, x - w * 0.5, y0 + h - w * 0.8], col)

## Romania's tricolour on a pole, the cloth's lower left corner at (x, y).
static func _flag(x: float, y: float, w: float) -> void:
	_l(x, y - w * 1.2, x, y + w * 0.7, DARK, w * 0.06)
	var h := w * 0.66
	_r(x, y, x + w / 3.0, y + h, RO_BLUE)
	_r(x + w / 3.0, y, x + w * 2.0 / 3.0, y + h, RO_YELLOW)
	_r(x + w * 2.0 / 3.0, y, x + w, y + h, RO_RED)

## The Palace of the Parliament in București: a vast cream block in stepped tiers, rows of tall windows, a
## colonnade in the middle of each tier and the flag on top, on its terrace above the boulevard.
static func _casa_poporului() -> void:
	var w := Color("ede3cc")
	var wd := w.darkened(0.12)
	_r(-48, 0, 48, 3, STONE_D)
	_r(-30, 3, 30, 4.2, wd)
	# the long first tier with its projecting wings
	_r(-44, 3, 44, 21, w)
	for sg in [-1.0, 1.0]:
		_r(sg * 44.0, 3, sg * 34.0, 23, wd)
		_r(sg * 44.6, 23, sg * 33.4, 24, w)
	_r(-44.6, 21, 44.6, 22.2, wd)
	# the second and third tiers and the top
	_r(-30, 22.2, 30, 31, w)
	_r(-30.5, 31, 30.5, 32, wd)
	_r(-18, 32, 18, 37.5, w)
	_r(-18.5, 37.5, 18.5, 38.3, wd)
	_r(-8, 38.3, 8, 41.5, w)
	_flag(-1.5, 41.5, 3.6)
	# windows: tall ones in rows, the colonnades in front
	var win := Color("7d8590")
	if _detail(0.5):
		for row in [[5.0, 9.5], [12.0, 16.0], [17.5, 20.0]]:
			_windows(-42, -15, row[0], row[1], 12, win)
			_windows(15, 42, row[0], row[1], 12, win)
		_windows(-28, -9, 24, 29, 8, win)
		_windows(9, 28, 24, 29, 8, win)
		_windows(-16, 16, 33.5, 36.5, 12, win)
		_windows(-6.5, 6.5, 39, 41, 5, win)
	else:
		_r(-42, 6, -15, 19, win.lightened(0.3))
		_r(15, 6, 42, 19, win.lightened(0.3))
	# the central porticos: columns under a cornice
	for tier in [[3.0, 21.0, 12.0, 11], [22.2, 31.0, 7.0, 7]]:
		var y0: float = tier[0]
		var y1: float = tier[1]
		var hw: float = tier[2]
		var n: int = tier[3]
		_r(-hw, y0, hw, y1, w.darkened(0.25))
		for k in n:
			var x: float = -hw + 0.8 + k * (hw * 2.0 - 1.6) / (n - 1)
			_r(x - 0.45, y0, x + 0.45, y1 - 1.0, WHITE)
		_r(-hw - 0.5, y1 - 1.0, hw + 0.5, y1, WHITE)

## St Michael's Church in Cluj: the Gothic hall church with its tall steep roof, the 80 m neo-Gothic tower at the
## west end, and in front Matthias Corvinus on horseback among his captains on a broad plinth.
static func _st_michael() -> void:
	var st := Color("cfc6b2")
	var sd := st.darkened(0.18)
	# nave and choir
	_r(-6, 0, 22, 20, st)
	_poly([-7, 20, 23, 20, 18, 34, -2, 34], Color("5a5650"))
	for x in [-1.0, 5.0, 11.0, 17.0]:
		_r(x - 0.5 + 2.5, 0, x + 0.5 + 2.5, 18, sd)
		_pointed(x, 5, 2.2, 10, WIN)
	_pointed(21, 4, 1.2, 9, WIN)
	# the west tower
	_r(-15, 0, -5, 52, st)
	_r(-15.5, 52, -4.5, 53.5, sd)
	_pointed(-10, 3, 3.5, 9, WIN)
	_pointed(-10, 28, 2.2, 7, WIN)
	_pointed(-10, 42, 2.4, 8, WIN)
	_c(-10, 37, 1.6, WHITE)
	_l(-10, 37, -10, 38.2, DARK, 0.2)
	for x in [-15.0, -5.0]:
		_poly([x - 0.8, 53.5, x + 0.8, 53.5, x, 58], sd)
	_poly([-14.5, 53.5, -5.5, 53.5, -10, 80], Color("4d6b5a"))
	_l(-10, 80, -10, 82, GOLD, 0.25)
	# Matthias Corvinus on his horse, on a plinth
	_r(4, 0, 22, 2.5, Color("a49f93"))
	_r(9, 2.5, 17, 6, Color("8f8a7e"))
	var b := BRONZE
	_poly([10, 9, 16, 9, 17, 11, 11, 11.3], b) # the horse's body
	_poly([16, 10.5, 18.5, 13, 19.5, 12.4, 17.5, 9.8], b) # neck and head
	for x in [10.6, 11.6, 15.2, 16.2]:
		_l(x, 9.2, x + (0.6 if x > 14.0 else -0.2), 6, b, 0.35)
	_poly([12.6, 11.2, 14.2, 11.2, 13.8, 14.6, 12.9, 14.6], b) # the rider
	_c(13.4, 15.2, 0.6, b)
	_l(14, 13.5, 15.5, 15.5, b, 0.25)
	for x in [5.5, 20.0]: # his captains at the corners
		_poly([x - 0.7, 2.5, x + 0.7, 2.5, x + 0.4, 6, x - 0.4, 6], b)
		_c(x, 6.5, 0.45, b)

## The Palace of Culture in Iași: a grey-white neo-Gothic palace with pointed windows, little corner turrets and the
## tall clock tower in the middle with its steep spire.
static func _iasi_palace() -> void:
	var w := Color("ddd8cc")
	var wd := w.darkened(0.15)
	var roof := Color("4a5560")
	_r(-31, 0, 31, 2, STONE_D)
	_r(-30, 2, 30, 20, w)
	_poly([-30.5, 20, 30.5, 20, 27, 25, -27, 25], roof)
	# wings with turrets and their pointed caps
	for sg in [-1.0, 1.0]:
		_r(sg * 30.0, 2, sg * 22.0, 24, wd)
		for x in [sg * 30.0, sg * 22.0]:
			_r(x - 1.0, 24, x + 1.0, 28, wd)
			_poly([x - 1.3, 28, x + 1.3, 28, x, 33], roof)
		_poly([sg * 30.5, 24, sg * 21.5, 24, sg * 26.0, 30], roof)
	for x in [-27.0, -24.5, -18.0, -14.5, -11.0, 11.0, 14.5, 18.0, 24.5, 27.0]:
		_pointed(x, 5, 1.6, 4.5, WIN)
		_pointed(x, 12, 1.6, 5.5, WIN)
	# the clock tower
	_r(-5, 2, 5, 42, w)
	_r(-5.6, 42, 5.6, 43.5, wd)
	_pointed(0, 2, 4, 9, WIN)
	_pointed(0, 15, 2.5, 8, WIN)
	_c(0, 31, 2.6, WHITE)
	_c(0, 31, 2.6 * 0.15, DARK)
	_l(0, 31, 0, 33, DARK, 0.25)
	_l(0, 31, 1.4, 31, DARK, 0.2)
	_pointed(0, 36, 2.0, 5, WIN)
	for x in [-5.0, 5.0]:
		_r(x - 0.8, 43.5, x + 0.8, 46, wd)
		_poly([x - 1.1, 46, x + 1.1, 46, x, 50], roof)
	_poly([-4.6, 43.5, 4.6, 43.5, 0, 56], roof)

## The Constanța Casino: a white Art Nouveau pavilion on the seafront, a big arched window under a curved gable,
## rounded corner bays with little domes, the terrace railing and the sea below.
static func _casino() -> void:
	_r(-25, 0, 25, 2, WATER)
	if _detail(1.0):
		_l(-23, 1, -16, 1, WATER_L, 0.15)
		_l(12, 1.3, 20, 1.3, WATER_L, 0.15)
	_r(-24, 2, 24, 4, STONE_D)
	for k in 25:
		var x := -23.5 + k * 1.95
		_r(x - 0.15, 4, x + 0.15, 5.2, WHITE)
	_r(-24, 5.2, 24, 5.5, WHITE)
	var w := Color("f2ede2")
	var wd := w.darkened(0.12)
	# the main hall with its curved gable
	_poly([-12, 4, 12, 4, 12, 15] + _arc(0, 15, 12, 7, 0, PI, 12) + [-12, 15], w)
	_poly([-9, 6, 9, 6, 9, 13] + _arc(0, 13, 9, 6, 0, PI, 12) + [-9, 13], Color("6f8fa3"))
	for x in [-6.0, -3.0, 0.0, 3.0, 6.0]:
		_l(x, 6, x, 13.0 + 6.0 * sqrt(maxf(0.0, 1.0 - (x / 9.0) * (x / 9.0))), WHITE, 0.25)
	_l(-9, 11, 9, 11, WHITE, 0.25)
	# the rounded corner bays
	for sg in [-1.0, 1.0]:
		var cx: float = sg * 17.0
		_r(cx - 5, 4, cx + 5, 13, wd)
		_poly(_arc(cx, 13, 5, 3.5, 0, PI, 10), Color("8fa9a0"))
		_l(cx, 16.5, cx, 18.5, DARK, 0.2)
		for x in [cx - 3.0, cx, cx + 3.0]:
			_arched(x, 6, 1.6, 5, Color("6f8fa3"))
	_r(-1.5, 4, 1.5, 6, WIN)

## The Orthodox Metropolitan Cathedral in Timișoara: a cream and brick church crowded with towers, the 83 m main
## tower in the middle, its roofs of glazed tiles in green, yellow and red lozenges.
static func _timisoara_cathedral() -> void:
	var w := Color("e8d6b4")
	var br := Color("b8643f")
	var tg := Color("3f7a52")
	_r(-24, 0, 24, 2, STONE_D)
	_r(-22, 2, 22, 26, w)
	for y in [8.0, 16.0, 24.0]:
		_r(-22, y, 22, y + 0.8, br)
	for x in [-17.0, -11.0, 11.0, 17.0]:
		_arched(x, 4, 2.2, 8, WIN)
		_arched(x, 15, 1.8, 6, WIN)
	_arched(0, 2, 5, 11, Color("5a3a2a"))
	# glazed roof with lozenges
	_poly([-23, 26, 23, 26, 18, 32, -18, 32], tg)
	if _detail(0.5):
		for k in 9:
			var x := -16.0 + k * 4.0
			_poly([x, 27, x + 1.3, 29, x, 31, x - 1.3, 29], RO_YELLOW if k % 2 else RO_RED)
	# side towers
	for x in [-19.0, 19.0, -11.0, 11.0]:
		var hgt: float = 42.0 if absf(x) > 15.0 else 48.0
		_r(x - 2.5, 26, x + 2.5, hgt, w)
		_r(x - 2.5, hgt - 6, x + 2.5, hgt - 5.3, br)
		_arched(x, hgt - 5, 1.4, 3.5, WIN)
		_poly([x - 3.0, hgt, x + 3.0, hgt, x, hgt + 9], tg)
		_poly([x - 1.5, hgt + 2, x + 1.5, hgt + 2, x, hgt + 6], RO_YELLOW)
		_l(x, hgt + 9, x, hgt + 10.5, GOLD, 0.25)
	# the main tower
	_r(-5, 26, 5, 60, w)
	for y in [36.0, 48.0]:
		_r(-5, y, 5, y + 0.8, br)
	_arched(0, 50, 2.6, 7, WIN)
	_arched(0, 39, 2.2, 6, WIN)
	_poly([-6, 60, 6, 60, 3.5, 66, -3.5, 66], tg)
	_poly([-3.5, 66, 3.5, 66, 0, 81], tg)
	_poly([-2, 63, 2, 63, 0, 66], RO_RED)
	_poly([-1.4, 70, 1.4, 70, 0, 75], RO_YELLOW)
	_l(0, 81, 0, 84, GOLD, 0.3)
	_l(-1, 83, 1, 83, GOLD, 0.25)

## The Black Church in Brașov: a big Gothic hall church of soot-darkened stone, a towering steep roof with buttresses
## below, and the heavy square west tower with its small steep cap.
static func _black_church() -> void:
	var st := Color("6a6660")
	var sd := Color("4e4a45")
	var roof := Color("8a4a36")
	# the nave and its roof
	_r(-10, 0, 27, 22, st)
	_poly([-11, 22, 28, 22, 22, 46, -5, 46], roof)
	if _detail(0.6):
		for k in 6:
			var y := 26.0 + k * 3.5
			_l(-9.0 + k * 1.0, y, 26.0 - k * 1.0, y, roof.darkened(0.15), 0.15)
	for x in [-6.0, 1.0, 8.0, 15.0, 22.0]:
		_poly([x + 2.5, 0, x + 4.5, 0, x + 3.5, 18], sd)
		_pointed(x, 4, 2.4, 12, Color("2a2c30"))
	# the west tower
	_r(-28, 0, -10, 52, st)
	for y in [14.0, 30.0, 44.0]:
		_r(-28.5, y, -9.5, y + 0.9, sd)
	_pointed(-19, 0, 5, 11, Color("2a2420"))
	_pointed(-19, 33, 3, 8, Color("2a2c30"))
	_c(-19, 24, 2.2, Color("d8cfb8"))
	_l(-19, 24, -19, 25.6, DARK, 0.25)
	_l(-19, 24, -18, 24, DARK, 0.2)
	_r(-28.5, 52, -9.5, 53.5, sd)
	_poly([-27.5, 53.5, -10.5, 53.5, -19, 63], roof)
	_l(-19, 63, -19, 66, GOLD, 0.3)

## The suspension footbridge in Craiova's Romanescu Park: two crenellated brick turrets on either bank of the lake,
## the cables sagging between them and the deck, trees all round.
static func _romanescu_bridge() -> void:
	_c(-26, 8, 5, TREE)
	_c(25, 9, 6, TREE)
	_r(-30, 0, 30, 4, Color("4f7f8a"))
	if _detail(1.0):
		_l(-10, 2, -2, 2, WATER_L, 0.15)
		_l(5, 1, 12, 1, WATER_L, 0.15)
	var br := Color("b05a3c")
	var bd := br.darkened(0.2)
	var deck := 7.0
	for sg in [-1.0, 1.0]:
		var x: float = sg * 18.0
		_r(x - 2.5, 0, x + 2.5, 18, br)
		for k in 3:
			var mx: float = x - 2.2 + k * 2.2
			_r(mx - 0.5, 18, mx + 0.5, 19.5, br)
		_arched(x, deck, 2.6, 4.5, bd.darkened(0.3))
		_arched(x, 13, 1, 2.2, WIN)
		# the bank and the anchor ramp
		_poly([sg * 30.0, 0, sg * 30.0, deck + 1.0, sg * 20.5, deck + 1.0, sg * 20.5, 0], GRASS)
	# the deck with its railing
	_r(-20.5, deck, 20.5, deck + 0.6, Color("6b5040"))
	_l(-20.5, deck + 1.6, 20.5, deck + 1.6, DARK, 0.12)
	# the cables
	var pts: Array = []
	for k in 21:
		var x := -18.0 + k * 1.8
		var y := deck + 1.6 + 9.0 * pow(x / 18.0, 2)
		pts.append(Vector2(x, y))
	for k in 20:
		_l(pts[k].x, pts[k].y, pts[k + 1].x, pts[k + 1].y, DARK, 0.2)
		if k % 2 == 0:
			_l(pts[k].x, pts[k].y, pts[k].x, deck + 0.6, DARK, 0.08)
	for sg in [-1.0, 1.0]:
		_l(sg * 18.0, deck + 10.6, sg * 26.0, deck + 1.0, DARK, 0.2)

## The Galați shipyard on the Danube: a blue and red cargo ship on the slipway, a big red and white gantry crane
## striding over it and the river in front.
static func _shipyard() -> void:
	_r(-35, 0, 35, 3, Color("587e8c"))
	_r(-35, 3, 35, 4, STONE_D)
	# the ship's hull, bow to the right
	var hull := Color("2a4f7a")
	_poly([-26, 4, 20, 4, 27, 14, -28, 14], hull)
	_poly([-27.6, 11, 26, 11, 27, 14, -28, 14], RO_RED.darkened(0.2))
	_r(-28, 14, 27, 15, Color("d8d8d0"))
	# the superstructure at the stern
	_r(-26, 15, -15, 24, WHITE)
	_windows(-25, -16, 21, 22.5, 5, WIN)
	_windows(-25, -16, 17.5, 19, 5, WIN)
	_r(-22, 24, -19, 28, Color("d04030"))
	# hatches on deck
	for x in [-11.0, -2.0, 7.0, 16.0]:
		_r(x - 3.5, 15, x + 3.5, 16.5, Color("7a8a5a"))
	# the gantry crane
	var cr := Color("c8302a")
	for x in [-31.0, 31.0]:
		_poly([x - 1.5, 4, x + 1.5, 4, x + 0.6, 34, x - 0.6, 34], cr)
	_r(-33, 34, 33, 37.5, cr)
	if _detail(0.6):
		for k in 22:
			var x := -32.0 + k * 3.0
			_l(x, 34.4, x + 1.5, 37.1, WHITE, 0.25)
	_r(3, 31, 9, 34, WHITE)
	_l(6, 31, 6, 20, DARK, 0.15)
	_r(4.8, 19, 7.2, 20, DARK)
	_r(-33, 37.5, 33, 38, WHITE)

## The Black Eagle Palace in Oradea: a cream Art Nouveau corner block with three rounded, swirling gables, the arched
## entrance to the glass-roofed passage in the middle and the black eagle spreading its wings on top.
static func _black_eagle() -> void:
	var w := Color("f1e8d4")
	var orn := Color("b9a27a")
	_r(-22, 0, 22, 18, w)
	_r(-22, 18, 22, 19, orn)
	# three rounded gables
	for x in [-14.0, 0.0, 14.0]:
		var rw: float = 7.0 if x == 0.0 else 5.0
		var rh: float = 7.0 if x == 0.0 else 4.5
		_poly([x - rw, 19] + _arc(x, 19, rw, rh, 0, PI, 12) + [x + rw, 19], w)
		_poly(_arc(x, 19, rw * 0.55, rh * 0.5, 0, PI, 8), orn)
	# the eagle on the middle gable
	var e := Color("1c1c1e")
	_c(0, 27.6, 0.7, e)
	_poly([0, 26.5, -4.5, 28.8, -3.5, 27, -5, 27.2, -1, 25.5], e)
	_poly([0, 26.5, 4.5, 28.8, 3.5, 27, 5, 27.2, 1, 25.5], e)
	_poly([-0.8, 25.8, 0.8, 25.8, 0, 24], e)
	# windows with green ironwork
	for row in [[4.0, 7.5], [9.5, 12.5], [14.0, 16.5]]:
		for x in [-19.0, -16.0, -13.0, -9.5, 9.5, 13.0, 16.0, 19.0]:
			_arched(x, row[0], 1.6, row[1] - row[0], WIN)
	_r(-22, 3, 22, 3.5, orn)
	# the passage's entrance and its glass roof showing behind
	_arched(0, 0, 7, 11, Color("3e4a52"))
	_poly(_arc(0, 7.5, 2.8, 2.8, 0, PI, 8), Color("7fa8b8"))
	_l(-2.8, 7.5, 2.8, 7.5, Color("2f6a52"), 0.2)
	for x in [-6.5, 6.5]:
		_r(x - 0.5, 0, x + 0.5, 12, orn)

## Ploiești's oil: a pumpjack nodding in front of the National Oil Museum's columned front, and an old wooden derrick.
static func _pumpjack() -> void:
	# the museum, small behind on the left
	var w := Color("e9e0cb")
	_r(-20, 0, -4, 10, w)
	_poly([-21, 10, -3, 10, -12, 13.5], w.darkened(0.1))
	for k in 5:
		var x := -18.0 + k * 3.0
		_r(x - 0.35, 1, x + 0.35, 9, WHITE)
	_r(-20.5, 9, -3.5, 10, w.darkened(0.15))
	_r(-20.5, 0, -3.5, 1, w.darkened(0.15))
	# the wooden derrick on the right
	var wood := Color("6f4e30")
	_l(10, 0, 15, 24, wood, 0.4)
	_l(20, 0, 15, 24, wood, 0.4)
	for k in 5:
		var y := 4.0 + k * 4.0
		var hw := 5.0 * (1.0 - y / 24.0)
		_l(15 - hw, y, 15 + hw, y, wood, 0.25)
		if k < 4:
			var hw2 := 5.0 * (1.0 - (y + 4.0) / 24.0)
			_l(15 - hw, y, 15 + hw2, y + 4.0, wood, 0.15)
	_r(14, 23.4, 16, 24, wood)
	# the pumpjack in the middle
	var pj := Color("3a3d42")
	_r(-6, 0, 10, 1, Color("8a8478"))
	_poly([-1, 1, 1, 1, 0.4, 7.5, -0.4, 7.5], pj) # the samson post
	_poly([4.5, 1, 5.5, 1, 0.6, 7.3, -0.2, 7.0], pj)
	_poly([-5, 7.0, 6, 8.6, 6, 9.4, -5, 7.8], pj) # the walking beam, tilted
	_poly([-5, 6.2, -3.4, 6.6, -3.4, 9.4, -5.2, 9.0, -6, 7.6], Color("c8a030")) # the horse head
	_l(-5.5, 6.4, -5.5, 1.5, DARK, 0.12)
	_r(-6, 1, -5, 1.6, pj)
	_c(5, 4.0, 2.2, RO_RED.darkened(0.2)) # the crank weight
	_l(6, 8.8, 5.6, 4.6, pj, 0.25)
