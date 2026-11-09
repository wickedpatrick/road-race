class_name LandmarksSeA
extends RefCounted
## Swedish landmarks (Stockholm to Norrköping), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const WHITE := Color("f3f0e8")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const GRASS := Color("5d8f42")
const GOLD := Color("e0b43a")
const COPPER := Color("5f9e86")
const COPPER_D := Color("4c8571")
const WATER := Color("4f7fa6")
const SLATE := Color("4a4c55")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"se_stockholm_stadshuset": _stockholm_stadshuset()
		"se_goteborg_feskekorka": _goteborg_feskekorka()
		"se_malmo_torso": _malmo_torso()
		"se_uppsala_domkyrka": _uppsala_domkyrka()
		"se_linkoping_draken": _linkoping_draken()
		"se_orebro_slott": _orebro_slott()
		"se_vasteras_anundshog": _vasteras_anundshog()
		"se_helsingborg_karnan": _helsingborg_karnan()
		"se_jonkoping_match": _jonkoping_match()
		"se_norrkoping_strykjarnet": _norrkoping_strykjarnet()
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

## A round-arched window or door: a rectangle under a half circle.
static func _arched(x: float, y0: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.5, y0, x + w * 0.5, y0, x + w * 0.5, y0 + h - w * 0.5] + _arc(x, y0 + h - w * 0.5, w * 0.5, w * 0.5, 0, PI, 6), col)

## A pointed (Gothic) window: a rectangle under a pointed top.
static func _lancet(x: float, y0: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.5, y0, x + w * 0.5, y0, x + w * 0.5, y0 + h - w * 0.8, x, y0 + h, x - w * 0.5, y0 + h - w * 0.8], col)

## A small open crown (the Three Crowns of Sweden) standing on (x, y), `s` wide.
static func _crown(x: float, y: float, s: float, col: Color) -> void:
	var h := s * 0.5
	_poly([x - s * 0.5, y, x + s * 0.5, y, x + s * 0.6, y + h, x + s * 0.3, y + h * 0.55, x, y + h * 1.1,
		x - s * 0.3, y + h * 0.55, x - s * 0.6, y + h], col)

## Stockholm City Hall (1911–1923): a long red-brick hall on Lake Mälaren with an arcade at the water, a copper
## roof, a small corner turret and the tall square tower with its open lantern, green spire and three crowns.
static func _stockholm_stadshuset() -> void:
	var brick := Color("9b3b2a")
	var brick_d := Color("7e2f22")
	_r(-32, 0, 32, 0.7, WATER)
	# the long hall
	_r(-31, 0.7, 13, 17, brick)
	_r(-31, 16.3, 13, 17.2, brick_d)
	_poly([-31, 17.2, 13, 17.2, 11.5, 20.2, -29.5, 20.2], COPPER)
	for k in 9:
		_arched(-27.4 + k * 4.2, 0.7, 2.4, 5.2, Color("3b2b26"))
	_windows(-30, 12, 8.5, 11, 12, WIN)
	_windows(-30, 12, 12.6, 15, 12, WIN)
	# the corner turret with its spire
	_r(-31, 17, -27, 24.5, brick)
	_poly([-31.4, 24.5, -26.6, 24.5, -29, 30], COPPER)
	_l(-29, 30, -29, 31, GOLD, 0.15)
	# the tower
	_r(13, 0.7, 21, 38, brick)
	_l(14.6, 5, 14.6, 37, brick_d, 0.35)
	_l(19.4, 5, 19.4, 37, brick_d, 0.35)
	for k in 4:
		_r(16.3, 22 + k * 3.6, 17.7, 24.2 + k * 3.6, WIN)
	_arched(17, 0.7, 2.6, 5.5, Color("3b2b26"))
	# the cornice, the open lantern and the green spire
	_r(12.4, 38, 21.6, 39.2, brick_d)
	_r(13.6, 39.2, 20.4, 43.8, COPPER)
	for x in [14.9, 17.0, 19.1]:
		_r(x - 0.55, 39.9, x + 0.55, 43, DARK)
	_poly([13.2, 43.8, 20.8, 43.8, 17, 46.6], COPPER_D)
	_l(17, 46.4, 17, 47.4, GOLD, 0.2)
	# the three golden crowns
	_crown(15.9, 47.3, 1.5, GOLD)
	_crown(18.1, 47.3, 1.5, GOLD)
	_crown(17, 48.8, 1.5, GOLD)

## Feskekôrka in Göteborg (1874): a fish market hall built like a neo-Gothic church, a steep dark roof broken by
## tall pointed windows under small gables, and the canal in front.
static func _goteborg_feskekorka() -> void:
	var wall := Color("e6dcc2")
	var trim := Color("c9b994")
	_r(-15, 0, 15, 0.8, WATER)
	_r(-13, 0.8, 13, 7.5, wall)
	_r(-13, 0.8, 13, 1.6, trim)
	# the steep roof
	_poly([-13.6, 7.5, 13.6, 7.5, 11, 16.5, -11, 16.5], SLATE)
	_l(-11, 16.5, 11, 16.5, Color("3a3c44"), 0.4)
	# the tall pointed windows reaching up into the roof under little gables
	for k in 5:
		var x := -9.6 + k * 4.8
		_r(x - 1.5, 7.0, x + 1.5, 11.5, wall)
		_poly([x - 1.9, 11.5, x + 1.9, 11.5, x, 13.6], wall)
		_lancet(x, 2.6, 1.6, 9.6, Color("50606c"))
		if _detail(1.4):
			_l(x, 3, x, 11.6, wall, 0.12)
	# the end gables with a cross on top
	for x in [-13.0, 13.0]:
		_l(x, 7.5, x * 0.85, 16.5, trim, 0.4)
	_l(0, 16.5, 0, 18.6, DARK, 0.2)
	_l(-0.7, 17.9, 0.7, 17.9, DARK, 0.2)
	_r(-1.2, 0.8, 1.2, 4.2, Color("5a4632"))

## Turning Torso in Malmö (2005): nine white cubes stacked round a core, each turned a little further, so the
## tower twists through a quarter turn; a steel spine runs up its side.
static func _malmo_torso() -> void:
	var face := Color("e9edf0")
	var side := Color("b9c3cb")
	var glass := Color("6f8796")
	var h := 6.7
	for k in 9:
		var t := k / 8.0
		var y0 := k * h
		var y1 := y0 + h - 0.5
		var left := -5.2 + 2.2 * t
		var front := 7.6 - 3.4 * t # width of the face towards us
		var depth := 0.8 + 3.0 * t # the side turning into view
		_r(left, y0, left + front, y1, face)
		_poly([left + front, y0, left + front + depth, y0 + 0.4, left + front + depth, y1 + 0.4, left + front, y1], side)
		if _detail(0.9):
			for f in 4:
				var yy := y0 + 1.0 + f * 1.35
				_l(left + 0.4, yy, left + front - 0.4, yy, glass, 0.35)
	# the white steel spine up the left side, tied to every cube
	for k in 9:
		var t := k / 8.0
		var y0 := k * h
		var x0 := -6.8 + 2.0 * t
		_l(x0, y0, -6.8 + 2.0 * (k + 1) / 8.0, y0 + h, WHITE, 0.4)
		_l(x0 + 0.2, y0 + h * 0.5, -5.2 + 2.2 * t, y0 + h * 0.5, Color("cfd6db"), 0.25)
	_r(-2.6, 9 * h - 0.5, 0.8, 9 * h + 0.6, side)

## Uppsala Cathedral: the red-brick Gothic west front between two towers with slim green spires, a rose window
## over the portal, the nave reaching back on the right.
static func _uppsala_domkyrka() -> void:
	var brick := Color("a4473a")
	var brick_d := Color("843a30")
	# the nave behind, with buttresses and its copper roof
	_r(13, 0, 21.5, 20, brick_d)
	_poly([13, 20, 21.5, 20, 21.5, 24, 13, 28], COPPER)
	for x in [15.0, 18.0, 21.0]:
		_r(x - 0.5, 0, x + 0.5, 15, brick)
	# the middle of the front with its gable
	_r(-6, 0, 6, 25, brick)
	_poly([-6, 25, 6, 25, 0, 32], brick)
	_c(0, 19, 2.6, Color("5a4a46"))
	_c(0, 19, 1.9, Color("6e7d8c"))
	_lancet(0, 0, 4.2, 10.5, Color("3b2b26"))
	_lancet(-3.6, 11, 1.2, 5, WIN)
	_lancet(3.6, 11, 1.2, 5, WIN)
	# the two towers
	for cx in [-10.0, 10.0]:
		_r(cx - 4, 0, cx + 4, 37, brick)
		_l(cx - 4, 0, cx - 4, 37, brick_d, 0.4)
		for k in 4:
			_lancet(cx, 9 + k * 6.5, 1.3, 4, WIN)
		_r(cx - 4.4, 36.5, cx + 4.4, 37.8, brick_d)
		# the green spire with a small lantern
		_poly([cx - 3.6, 37.8, cx + 3.6, 37.8, cx + 1.8, 42, cx - 1.8, 42], COPPER)
		_r(cx - 1.3, 42, cx + 1.3, 45, COPPER_D)
		_poly([cx - 1.6, 45, cx + 1.6, 45, cx, 62], COPPER)
		_l(cx, 62, cx, 63.6, GOLD, 0.2)
		_c(cx, 63.6, 0.35, GOLD)

## A Saab 35 Draken in Linköping: the double-delta fighter seen from the side on a museum pylon, grey with the
## blue and yellow roundel on its tall fin.
static func _linkoping_draken() -> void:
	var metal := Color("8f989e")
	var metal_d := Color("6c757b")
	_r(-4, 0, 4, 1.0, Color("b9b4a8"))
	_poly([-1.2, 1.0, 1.2, 1.0, 0.8, 6.4, -0.8, 6.4], Color("9a958a"))
	# the wing seen edge-on under the fuselage, sweeping back
	_poly([-7, 6.5, 13.5, 6.3, 13.5, 5.6, 3, 5.6], metal_d)
	# the fuselage with its pointed nose and the exhaust
	_poly([-16.5, 7.3, -11, 8.5, 10, 8.7, 14.5, 8.3, 15.2, 7.5, 14.5, 6.4, -11, 6.2], metal)
	_l(-16.5, 7.3, -17.0, 7.3, DARK, 0.12)
	_r(14.6, 6.6, 15.4, 8.1, Color("3a3a3a"))
	# the canopy and the air intake beside it
	_poly([-9.5, 8.5, -7.3, 9.9, -4.2, 9.9, -2.6, 8.6], Color("4f6577"))
	_poly([-6.8, 6.6, -3.5, 6.6, -3.5, 8.2, -6.0, 8.2], metal_d)
	# the tall swept fin and the roundel
	_poly([7.5, 8.7, 10.0, 13.6, 11.8, 13.6, 13.8, 8.5], metal)
	_c(11.1, 10.9, 1.0, Color("1d5aa6"))
	_c(11.1, 10.9, 0.45, Color("f2c230"))

## Örebro Castle: a pale block with four round corner towers under dark conical roofs, on its islet in the
## Svartån.
static func _orebro_slott() -> void:
	var wall := Color("ddd5c4")
	var wall_d := Color("c4baa6")
	var roof := Color("4b4a4f")
	_r(-25, 0, 25, 2, WATER)
	_r(-24, 1.6, 24, 2.6, Color("9a958a"))
	# the main block
	_r(-17, 2.6, 17, 17.5, wall)
	_poly([-17.5, 17.5, 17.5, 17.5, 15.5, 21, -15.5, 21], roof)
	_windows(-15, 15, 6, 8.5, 8, WIN)
	_windows(-15, 15, 11, 13.5, 8, WIN)
	_arched(0, 2.6, 3.2, 5.6, Color("4a3e34"))
	# the round corner towers (the near pair; the far ones peep over the roof)
	for cx in [-11.0, 11.0]:
		_r(cx - 2.2, 17, cx + 2.2, 22.5, wall_d)
		_poly([cx - 2.6, 22.5, cx + 2.6, 22.5, cx, 25.2], roof)
	for cx in [-20.0, 20.0]:
		_r(cx - 4, 2.6, cx + 4, 20, wall)
		_l(cx + (2.4 if cx < 0 else -2.4), 3, cx + (2.4 if cx < 0 else -2.4), 19.5, wall_d, 0.7)
		_windows(cx - 3, cx + 3, 8, 10.5, 2, WIN)
		_windows(cx - 3, cx + 3, 13.5, 16, 2, WIN)
		_poly([cx - 4.6, 20, cx + 4.6, 20, cx, 27.6], roof)
		_l(cx, 27.6, cx, 28, GOLD, 0.15)

## Anundshög by Västerås: the great grassy burial mound, a rune stone before it and a ship setting of standing
## stones beside it.
static func _vasteras_anundshog() -> void:
	_r(-30, 0, 30, 0.6, Color("6b9a4c"))
	# the mound
	_poly([-25, 0] + _arc(-10, 0, 15, 10.5, PI, 0, 18) + [5, 0], GRASS)
	_poly(_arc(-10, 0, 15, 10.5, PI * 0.62, PI * 0.38, 6) + [-10, 7], Color("6aa04d"))
	# the rune stone
	var stone := Color("8e8a82")
	_poly([-28.5, 0, -26.2, 0, -26.4, 4.6, -27.3, 5.2, -28.3, 4.4], stone)
	if _detail(1.2):
		_l(-27.9, 0.8, -27.6, 4.3, Color("a8463a"), 0.12)
		_l(-26.8, 0.8, -26.7, 4.3, Color("a8463a"), 0.12)
	# the ship setting: stones along a boat-shaped outline, the stem and stern stones tallest
	var n := 13
	for k in n:
		var t := float(k) / (n - 1)
		var x := 7.5 + t * 21.0
		var bow := 1.0 - pow(2.0 * t - 1.0, 2.0)
		var hgt := 1.0 + 0.5 * (1.0 - bow) + (1.4 if k == 0 or k == n - 1 else 0.0)
		var y0 := 0.3 + bow * 2.2 # the far side of the ship sits higher on the ground
		_poly([x - 0.45, y0, x + 0.45, y0, x + 0.3, y0 + hgt, x - 0.3, y0 + hgt * 0.92], Color("9c978d"))
		if k > 0 and k < n - 1:
			_poly([x - 0.5, 0, x + 0.5, 0, x + 0.35, hgt * 0.9, x - 0.35, hgt * 0.85], stone)

## Kärnan in Helsingborg: the tall light-brick keep with narrow windows, a crenellated top and a small stair turret.
static func _helsingborg_karnan() -> void:
	var wall := Color("e2d9c6")
	var wall_d := Color("c9bea6")
	_r(-7.5, 0, 7.5, 1.0, Color("a8a294"))
	_r(-6, 1, 6, 30, wall)
	_r(2.4, 1, 6, 30, wall_d)
	for k in 5:
		_arched(-1.6, 5 + k * 5, 0.9, 2.2, WIN)
		_arched(4.2, 7 + k * 5, 0.7, 1.8, WIN)
	_arched(-1.6, 1, 2.2, 3.4, Color("4a3e34"))
	# the battlements
	_r(-6.4, 30, 6.4, 31, wall_d)
	for k in 6:
		var x := -6.0 + k * 2.4
		_r(x, 31, x + 1.3, 33, wall)
	# the stair turret on the roof
	_r(-4.6, 31, -2.2, 34.4, wall_d)
	_poly([-5.0, 34.4, -1.8, 34.4, -3.4, 35.8], Color("6f5e4e"))

## The match factory in Jönköping: a long yellow two-storey factory under a red roof, its brick chimney, and a
## giant matchbox with a match leaning on it.
static func _jonkoping_match() -> void:
	var wood := Color("dcb75e")
	var roof := Color("9a3f2c")
	_r(-21, 0, 10, 11, wood)
	_poly([-21.6, 11, 10.6, 11, 9, 14, -20, 14], roof)
	_windows(-20, 9, 2, 4.8, 10, WIN)
	_windows(-20, 9, 6.6, 9.4, 10, WIN)
	_r(-5.6, 0, -3.4, 4.0, Color("6a4a2e"))
	# the chimney
	_r(11.5, 0, 14, 21.5, Color("a4473a"))
	_r(11.2, 21, 14.3, 22, Color("843a30"))
	# the matchbox and the match
	_r(14.5, 0, 21.5, 4.4, Color("2f5d9e"))
	_r(14.5, 4.4, 21.5, 5.4, Color("6b4a2c"))
	_r(15.5, 1.0, 20.5, 3.4, Color("f2e3b0"))
	_c(18, 2.2, 0.8, Color("c8322b"))
	_l(16.2, 5.4, 20.6, 15.5, Color("e8d7a8"), 0.5)
	_c(20.7, 15.8, 0.6, Color("c8322b"))

## Strykjärnet in Norrköping (1917): the wedge-shaped mill seen from its narrow prow, two fronts of windows running
## back along the river arms, the rapids white below.
static func _norrkoping_strykjarnet() -> void:
	var wall := Color("e6dcbf")
	var wall_d := Color("cbbf9f")
	_r(-20, 0, 20, 2.2, WATER)
	for x in [-16.0, -9.0, -2.5, 6.0, 13.0]:
		_l(x, 1.2, x + 2.2, 1.0, Color("dce8ef"), 0.3)
	# the two fronts narrowing to the prow
	_poly([-19, 2.2, -1.6, 2.2, -1.6, 21.5, -19, 18.5], wall_d)
	_poly([1.6, 2.2, 19, 2.2, 19, 18.5, 1.6, 21.5], wall)
	_r(-1.6, 2.2, 1.6, 21.5, wall)
	_poly([-19, 18.5, -1.6, 21.5, 1.6, 21.5, 19, 18.5, 19, 19.6, 1.6, 22.8, -1.6, 22.8, -19, 19.6], SLATE)
	if _detail(0.8):
		for f in 6:
			var t := float(f) / 6.0
			for k in 6:
				var u := (k + 0.5) / 6.0
				var xr := 1.6 + u * 17.4
				var yr := 4.0 + t * (16.0 - 2.2 * u)
				_r(xr - 0.7, yr, xr + 0.7, yr + 1.4, WIN)
				_r(-xr - 0.7, yr, -xr + 0.7, yr + 1.4, WIN)
			_r(-0.6, 4.0 + t * 16.0, 0.6, 5.4 + t * 16.0, WIN)
