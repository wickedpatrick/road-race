class_name LandmarksSeB
extends RefCounted
## Swedish landmarks (Lund to Kalmar), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const WHITE := Color("f3f0e8")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const GRASS := Color("5d8f42")
const GOLD := Color("e0b43a")
const COPPER := Color("5f9e86")
const COPPER_D := Color("4c8571")
const WATER := Color("4f7fa6")
const SLATE := Color("4a4c55")
const FALU := Color("8f2f23") ## Falu red, the paint of Swedish wooden houses

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"se_lund_domkyrka": _lund_domkyrka()
		"se_umea_birches": _umea_birches()
		"se_gavle_bocken": _gavle_bocken()
		"se_sundsvall_stenstaden": _sundsvall_stenstaden()
		"se_karlstad_ostrabron": _karlstad_ostrabron()
		"se_ostersund_odjuret": _ostersund_odjuret()
		"se_lulea_gammelstad": _lulea_gammelstad()
		"se_kiruna_kyrka": _kiruna_kyrka()
		"se_visby_ringmuren": _visby_ringmuren()
		"se_kalmar_slott": _kalmar_slott()
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

## A small house of `w` x `h` metres with a pitched roof, its left corner at x.
static func _cottage(x: float, w: float, h: float, wall: Color, roof: Color) -> void:
	_r(x, 0, x + w, h, wall)
	_poly([x - 0.3, h, x + w + 0.3, h, x + w * 0.5, h + w * 0.42], roof)
	_l(x, 0, x, h, WHITE, 0.15)
	_l(x + w, 0, x + w, h, WHITE, 0.15)
	_r(x + w * 0.38, 0, x + w * 0.62, h * 0.62, Color("5a3a2a"))

## Lund Cathedral: the Romanesque sandstone west front with two square towers under green pyramid spires,
## round-arched windows and portal.
static func _lund_domkyrka() -> void:
	var stone := Color("cdbd98")
	var stone_d := Color("b2a27f")
	# the nave behind
	_r(-18, 0, 18, 16, stone_d)
	_poly([-18.5, 16, 18.5, 16, 17, 19, -17, 19], COPPER)
	_r(-5, 0, 5, 23, stone)
	_poly([-5.4, 23, 5.4, 23, 0, 27.5], stone)
	_arched(0, 0, 4.6, 9, Color("4a3e34"))
	_arched(0, 11, 2.4, 6, WIN)
	if _detail(1.2):
		for k in 5:
			_arched(-3.6 + k * 1.8, 18.5, 0.9, 2.4, WIN)
	for cx in [-9.0, 9.0]:
		_r(cx - 4, 0, cx + 4, 35, stone)
		_l(cx - 4, 0, cx - 4, 35, stone_d, 0.5)
		_l(cx + 4, 0, cx + 4, 35, stone_d, 0.5)
		for k in 3:
			_arched(cx, 12 + k * 7, 1.4, 3.6, WIN)
		_arched(cx - 1.2, 31, 0.9, 2.6, WIN)
		_arched(cx + 1.2, 31, 0.9, 2.6, WIN)
		_r(cx - 4.3, 34.6, cx + 4.3, 35.6, stone_d)
		_poly([cx - 4.2, 35.6, cx + 4.2, 35.6, cx, 48], COPPER)
		_poly([cx, 35.6, cx + 4.2, 35.6, cx, 48], COPPER_D)
		_l(cx, 48, cx, 49.6, GOLD, 0.2)

## Umeå, the city of birches: a row of white-trunked birches along a wide avenue in front of a yellow wooden
## villa and a red one.
static func _umea_birches() -> void:
	_r(-25, 0, 25, 0.6, Color("9a958a"))
	_cottage(-16, 12, 7, Color("e3c46a"), Color("5a5e66"))
	_windows(-15, -5, 2, 4.5, 4, WIN)
	_cottage(4, 10, 6.5, FALU, Color("4a4c55"))
	_windows(5, 13, 2, 4.2, 3, WHITE)
	var leaf := Color("8fbf4a")
	var leaf_d := Color("6fa23e")
	for k in 6:
		var x := -21.0 + k * 8.4
		var h := 15.0 + (k % 3) * 1.6
		_c(x - 1.6, h - 3.0, 3.0, leaf_d)
		_c(x + 1.4, h - 2.4, 2.8, leaf_d)
		_c(x, h, 3.2, leaf)
		_c(x - 0.8, h + 2.6, 2.0, leaf)
		_poly([x - 0.45, 0, x + 0.45, 0, x + 0.2, h - 1, x - 0.2, h - 1], Color("f2f0ea"))
		if _detail(0.9):
			for m in 4:
				var y := 1.4 + m * (h - 3.0) / 4.0
				_l(x - 0.4, y, x + 0.1, y + 0.2, DARK, 0.18)

## The Gävle Goat: the giant Yule goat of golden straw with red ribbons, its horns curling back, behind a low fence.
static func _gavle_bocken() -> void:
	var straw := Color("d9b25a")
	var straw_d := Color("b8913e")
	var red := Color("c8322b")
	# the legs
	for x in [-4.6, -2.6, 2.2, 4.2]:
		_r(x - 0.7, 0, x + 0.7, 6.5, straw if x < 0 else straw_d)
		_r(x - 0.75, 1.2, x + 0.75, 1.8, red)
	# the body and the neck
	_poly([-5.6, 5.8, 5.0, 5.8, 5.6, 9.6, -5.2, 10.2], straw)
	_poly([3.0, 8.8, 5.6, 8.8, 6.0, 12.4, 4.0, 12.4], straw)
	# the head with its beard, the horns curling back
	_poly([3.6, 12.0, 6.8, 12.0, 6.9, 13.8, 3.8, 14.2], straw)
	_poly([6.2, 12.0, 6.9, 12.0, 6.6, 10.8], straw_d)
	_l(4.2, 14.0, 2.8, 15.2, straw_d, 0.55)
	_l(2.8, 15.2, 1.8, 14.2, straw_d, 0.55)
	_l(5.0, 14.0, 3.8, 15.6, straw_d, 0.55)
	_l(3.8, 15.6, 2.6, 15.0, straw_d, 0.55)
	# the red ribbons round the body and neck, the tail
	for x in [-3.6, -0.4, 2.8]:
		_poly([x - 0.4, 5.8, x + 0.4, 5.8, x + 0.4, 10.0, x - 0.4, 10.1], red)
	_r(3.1, 10.4, 5.7, 11.0, red)
	_l(-5.4, 9.6, -6.6, 10.6, straw_d, 0.5)
	if _detail(1.2):
		for k in 5:
			_l(-4.8 + k * 2.0, 6.4, -4.4 + k * 2.0, 9.4, straw_d, 0.12)
	# the fence round it
	_l(-7, 1.4, 7, 1.4, DARK, 0.15)
	for k in 8:
		_l(-7 + k * 2.0, 0, -7 + k * 2.0, 1.7, DARK, 0.15)

## Stenstaden in Sundsvall: three ornate stone town palaces of the 1890s side by side, a corner tower with a dome,
## a stepped gable and a mansard roof.
static func _sundsvall_stenstaden() -> void:
	var ochre := Color("d8b98a")
	var grey := Color("c9c3b8")
	var brick := Color("b25e45")
	var roof := Color("4a4c55")
	# left: ochre palace with a corner tower and dome
	_r(-24, 0, -8, 17, ochre)
	_r(-24, 16.4, -8, 17.4, Color("bfa275"))
	_windows(-23, -9, 3, 6, 5, WIN)
	_windows(-23, -9, 8, 11, 5, WIN)
	_windows(-23, -9, 12.6, 15.4, 5, WIN)
	_r(-25, 0, -19.5, 21, ochre)
	_poly([-25.4, 21] + LandmarkPainter._arc_pts(-22.25, 21, 3.15, 3.4, PI, 0, 8) + [-19.1, 21], COPPER)
	_l(-22.25, 24.4, -22.25, 26, DARK, 0.2)
	# middle: grey stone with a stepped gable
	_r(-8, 0, 7, 18, grey)
	_r(-6, 18, 5, 20, grey)
	_r(-4, 20, 3, 22, grey)
	_r(-2, 22, 1, 24, grey)
	_windows(-7, 6, 3, 6.5, 4, WIN)
	_windows(-7, 6, 8.5, 12, 4, WIN)
	_windows(-7, 6, 13.5, 16.5, 4, WIN)
	_arched(-0.5, 19, 1.4, 2.4, WIN)
	# right: red brick with a mansard roof and dormers
	_r(7, 0, 24, 16, brick)
	_poly([6.6, 16, 24.4, 16, 23, 20.5, 8, 20.5], roof)
	_windows(8, 23, 3, 6, 5, Color("e8e0cc"))
	_windows(8, 23, 9, 12.5, 5, Color("e8e0cc"))
	for x in [11.0, 15.5, 20.0]:
		_r(x - 0.9, 16.6, x + 0.9, 19, Color("e8e0cc"))
	# the shop fronts at street level
	_r(-24, 0, 24, 2.2, Color("6b5a4a"))

## Östra bron in Karlstad: the long low stone bridge of twelve round arches over the Klarälven, lamps along its
## parapet.
static func _karlstad_ostrabron() -> void:
	var stone := Color("b8b0a0")
	var stone_d := Color("9a9282")
	_r(-35, 0, 35, 2.4, WATER)
	_r(-34, 2.0, 34, 8.2, stone)
	# the twelve arches
	var span := 68.0 / 12.0
	for k in 12:
		var cx := -34.0 + span * (k + 0.5)
		_poly([cx - span * 0.38, 2.0] + _arc(cx, 4.4, span * 0.38, 2.6, PI, 0, 10) + [cx + span * 0.38, 2.0], Color("5d7f99"))
		_l(cx - span * 0.38, 2.0, cx + span * 0.38, 2.0, WATER, 0.3)
		_poly([cx - span * 0.5, 2.0, cx - span * 0.38, 2.0, cx - span * 0.43, 3.0], stone_d)
	# the deck and parapet with lamps
	_r(-35, 8.2, 35, 9.0, stone_d)
	_r(-35, 9.0, 35, 9.8, stone)
	for k in 7:
		var x := -30.0 + k * 10.0
		_l(x, 9.8, x, 11.6, DARK, 0.18)
		_c(x, 11.8, 0.3, Color("f2e6b0"))

## The Storsjö Monster by Östersund: its humped back and long neck rising from the lake, the snowy mountains of
## western Jämtland beyond the water.
static func _ostersund_odjuret() -> void:
	# the mountains beyond
	_poly([-30, 3, -22, 10, -15, 7.5, -6, 13.5, 3, 9.5, 12, 15.5, 21, 10, 30, 12.5, 30, 3], Color("8c9bab"))
	_poly([-8.2, 11.8, -6, 13.5, -3.6, 11.9, -5.2, 12.4], WHITE)
	_poly([9.6, 13.6, 12, 15.5, 14.6, 13.8, 12.4, 14.5], WHITE)
	_poly([28.2, 11.8, 30, 12.5, 30, 11.6], WHITE)
	# the far shore with forest
	_r(-30, 2.8, 30, 4.0, Color("4a6e3c"))
	# the lake
	_r(-30, 0, 30, 3.0, WATER)
	# the humps and the neck with its head
	var skin := Color("3d5a48")
	for hx in [-14.0, -8.5, -3.5]:
		_poly([hx - 2.4, 1.2] + _arc(hx, 1.2, 2.4, 2.0, PI, 0, 8) + [hx + 2.4, 1.2], skin)
	_poly([0.5, 1.2, 3.2, 1.2, 4.4, 6.5, 5.6, 9.0, 4.2, 9.4, 2.6, 6.8], skin)
	_poly([3.8, 8.6, 8.0, 9.2, 8.4, 10.2, 5.0, 10.8, 3.6, 9.8], skin)
	_c(5.4, 10.0, 0.25, Color("f2e6b0"))
	for x in [-16.4, -11.0, -6.0, 0.4, 3.4]:
		_l(x, 1.2, x + 1.0, 1.2, Color("dce8ef"), 0.25)

## Gammelstad church town by Luleå: the white stone church with its steep roof and stepped gable among rows of
## little Falu-red cottages.
static func _lulea_gammelstad() -> void:
	var white := Color("efede6")
	# the church
	_r(-7, 0, 11, 11, white)
	_poly([-7.4, 11, 11.4, 11, 11.4, 12, 2, 21, -7.4, 12], Color("3f4148"))
	# the stepped gable at the west end
	_poly([-9, 0, -5, 0, -5, 20.5, -6, 20.5, -6, 22, -8, 22, -8, 20.5, -9, 20.5], white)
	for k in 3:
		_r(-9.4, 12 + k * 3, -4.6, 12.6 + k * 3, Color("d8d4c8"))
	_arched(-7, 0, 1.8, 3.8, Color("4a3e34"))
	for x in [-1.5, 3.0, 7.5]:
		_arched(x, 3.5, 1.4, 4.4, WIN)
	# the cottages of the church town
	_cottage(-24, 5, 3.6, FALU, Color("4a3e34"))
	_cottage(-18, 4.4, 3.4, FALU, Color("4a3e34"))
	_cottage(-13.2, 4.6, 3.6, FALU, Color("4a3e34"))
	_cottage(12.6, 4.6, 3.6, FALU, Color("4a3e34"))
	_cottage(18.2, 5.6, 3.8, FALU, Color("4a3e34"))

## Kiruna Church (1912): the dark red wooden church whose roof sweeps down almost to the ground like a Sámi hut,
## its tall gable front and roof lantern, the free-standing bell tower beside it.
static func _kiruna_kyrka() -> void:
	var red := Color("8a3324")
	var red_d := Color("6e2819")
	# the bell tower
	_r(12.5, 0, 16.5, 20, red)
	_r(12.2, 20, 16.8, 25, red_d)
	_r(13.6, 21, 15.4, 24, DARK)
	_poly([12, 25, 17, 25, 14.5, 33.6], red_d)
	_l(14.5, 33.6, 14.5, 34, GOLD, 0.15)
	# the church: the great roof sweeping low on both sides
	var cx := -3.0
	_poly([cx - 14, 0, cx + 14, 0, cx, 29], red_d)
	_poly([cx, 29, cx + 14, 0, cx + 9, 0, cx, 25.5], red)
	# the gable front with its door and windows
	_poly([cx - 7.5, 0, cx + 7.5, 0, cx + 7.5, 6, cx, 21, cx - 7.5, 6], Color("9c3d2b"))
	for k in 9:
		var dx := -6.6 + k * 1.65
		_l(cx + dx, 0.2, cx + dx, 6.0 + (7.5 - absf(dx)) * 2.0 - 0.6, red_d, 0.15)
	_r(cx - 1.4, 0, cx + 1.4, 4.4, DARK)
	_poly([cx - 1.6, 4.4, cx + 1.6, 4.4, cx, 5.6], red_d)
	for dx in [-4.4, 4.4]:
		_r(cx + dx - 0.7, 2, cx + dx + 0.7, 5, Color("e8d9a8"))
	_c(cx, 11, 1.4, Color("e8d9a8"))
	# the roof lantern
	_r(cx - 1.0, 26.5, cx + 1.0, 29.5, red)
	_poly([cx - 1.4, 29.5, cx + 1.4, 29.5, cx, 32.4], red_d)
	_l(cx, 32.4, cx, 33.2, GOLD, 0.15)

## Visby's ring wall: the grey limestone wall with its tall towers under steep roofs and the small saddle towers
## between them, a black church spire of St Mary's behind.
static func _visby_ringmuren() -> void:
	var lime := Color("c2bba9")
	var lime_d := Color("a39b88")
	var roof := Color("3c3a3e")
	# St Mary's spire behind the wall
	_r(-1.6, 6, 1.6, 13, Color("d8d2c2"))
	_poly([-2.0, 13, 2.0, 13, 1.2, 15.2, 0, 19.6, -1.2, 15.2], Color("25262a"))
	# the wall
	_r(-30, 0, 30, 8, lime)
	_r(-30, 7.4, 30, 8.2, lime_d)
	if _detail(1.0):
		for k in 14:
			_r(-28.5 + k * 4.2, 3.5, -28.1 + k * 4.2, 5.5, DARK)
	# the small saddle towers on the wall
	for x in [-15.0, 3.5, 18.5]:
		_r(x - 1.5, 8, x + 1.5, 10.5, lime)
		_poly([x - 1.8, 10.5, x + 1.8, 10.5, x, 12.2], roof)
	# the tall towers
	for x in [-24.0, -7.5, 11.0, 26.0]:
		_r(x - 2.6, 0, x + 2.6, 14, lime)
		_l(x + 2.6, 0, x + 2.6, 14, lime_d, 0.6)
		_r(x - 0.5, 9, x + 0.5, 11, DARK)
		_poly([x - 3.0, 14, x + 3.0, 14, x, 19.6], roof)
	# the gate through the wall
	_arched(-16, 0, 3.0, 5.0, Color("4a3e34"))

## Kalmar Castle: the pale Renaissance castle over the water, two round towers with green conical roofs and the
## tall gate tower with its spire between them.
static func _kalmar_slott() -> void:
	var wall := Color("e3dccb")
	var wall_d := Color("c8bfa9")
	_r(-27, 0, 27, 2, WATER)
	_r(-26, 1.6, 26, 3, Color("8e8a7e"))
	_r(-17, 3, 17, 18, wall)
	_poly([-17.5, 18, 17.5, 18, 15.5, 21.5, -15.5, 21.5], Color("8a3a2c"))
	_windows(-15, 15, 7, 9.5, 8, WIN)
	_windows(-15, 15, 12, 14.5, 8, WIN)
	for cx in [-20.5, 20.5]:
		_r(cx - 4, 3, cx + 4, 20, wall)
		_l(cx + (2.6 if cx < 0 else -2.6), 3.5, cx + (2.6 if cx < 0 else -2.6), 19.5, wall_d, 0.7)
		_windows(cx - 3, cx + 3, 9, 11.5, 2, WIN)
		_poly([cx - 4.6, 20, cx + 4.6, 20, cx, 27.8], COPPER)
		_poly([cx, 20, cx + 4.6, 20, cx, 27.8], COPPER_D)
		_l(cx, 27.8, cx, 28.6, GOLD, 0.15)
	# the gate tower
	_r(-3, 3, 3, 23, wall)
	_arched(0, 3, 2.6, 5, Color("4a3e34"))
	_r(-1, 15, 1, 17.5, WIN)
	_poly([-3.4, 23, 3.4, 23, 2, 25, -2, 25], COPPER)
	_r(-1.2, 25, 1.2, 26.6, COPPER_D)
	_poly([-1.4, 26.6, 1.4, 26.6, 0, 29.6], COPPER)
	_l(0, 29.6, 0, 30, GOLD, 0.15)
