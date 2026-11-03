class_name LandmarksSk
extends RefCounted
## Slovak landmarks, drawn with LandmarkPainter's helpers (metres from the base point, y up).

const WHITE := Color("f2efe6")
const RED_ROOF := Color("b5432e")
const WATER := Color("4f8fc0")
const WATER_L := Color("9cc8e6")
const ROCK := Color("9a958a")
const GRASS := Color("5d8f42")
const WIN := Color("3a4048")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"bratislava_castle": _bratislava_castle()
		"ufo_bridge": _ufo_bridge()
		"elisabeth_cathedral": _elisabeth_cathedral()
		"spis_castle": _spis_castle()
		"tatras": _tatras()
		"leaning_clock_tower": _leaning_clock_tower()
		"trencin_castle": _trencin_castle()
		"crutch_breaker": _crutch_breaker()
		"komarno_fortress": _komarno_fortress()
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

## Bratislava Castle: the white square block on its green hill, a red hipped roof and four corner towers with
## their own small red roofs (the "upturned table"), the walls and the terraced garden below.
static func _bratislava_castle() -> void:
	_poly([-22, 0, 22, 0, 18, 5, 12, 7.5, -12, 7.5, -18, 5], GRASS)
	_poly([-20, 0, -12, 0, -14, 5.5, -18, 4.5], GRASS.darkened(0.12))
	_r(-15, 6.5, 15, 8, Color("d8d2c2")) # the bastion wall
	if _detail(1.2):
		for x in [-13.5, -9.0, -4.5, 0.0, 4.5, 9.0, 13.5]:
			_r(x - 0.6, 8, x + 0.6, 8.6, Color("d8d2c2"))
	var w := WHITE
	var ws := w.darkened(0.08)
	_r(-11, 8, 11, 20, w)
	_r(-11, 8, -8, 20, ws)
	_windows(-7.5, 7.5, 10, 12, 6, WIN)
	_windows(-7.5, 7.5, 14, 16, 6, WIN)
	_windows(-7.5, 7.5, 17.4, 18.8, 6, WIN)
	_poly([-1.2, 8, 1.2, 8, 1.2, 10.2] + _arc(0, 10.2, 1.2, 1.0, 0, PI, 6), WIN.darkened(0.2))
	_poly([-11.4, 20, 11.4, 20, 7.5, 24, -7.5, 24], RED_ROOF)
	_poly([-11.4, 20, -8.4, 20, -5.5, 24, -7.5, 24], RED_ROOF.lightened(0.12))
	for x in [-10.0, 10.0]:
		_r(x - 2.2, 8, x + 2.2, 23.4, w)
		_r(x - 2.2, 22.6, x + 2.2, 23.4, ws)
		_windows(x - 1.6, x + 1.6, 18.5, 20.5, 1, WIN)
		_windows(x - 1.6, x + 1.6, 13.5, 15.5, 1, WIN)
		_poly([x - 2.6, 23.4, x + 2.6, 23.4, x + 1.3, 25.4, x - 1.3, 25.4], RED_ROOF)
		_l(x, 25.4, x, 26.2, Color("6b5a3a"), 0.15)

## Most SNP (the UFO bridge): one leaning pylon of two legs on the Petržalka bank, the flying-saucer restaurant on
## top, the long deck over the Danube hung from a fan of cables on the city side.
static func _ufo_bridge() -> void:
	_r(-32, 0, 32, 1.6, WATER)
	if _detail(1.0):
		_l(-28, 0.8, -18, 0.8, WATER_L, 0.2)
		_l(2, 0.6, 14, 0.6, WATER_L, 0.2)
	var steel := Color("c9cdd2")
	var dark := Color("70767c")
	var deck_y := 5.0
	# the deck
	_r(-32, deck_y, 32, deck_y + 1.2, steel)
	_r(-32, deck_y - 0.4, 32, deck_y, dark)
	for x in [-24.0, -8.0]:
		_r(x - 0.6, 0, x + 0.6, deck_y - 0.4, dark)
	# the leaning pylon (two legs drawn as one A seen from the side), base at x=18
	var base := 18.0
	var top := Vector2(22.5, 24.5)
	_poly([base - 1.4, 0, base + 1.4, 0, top.x + 0.7, top.y, top.x - 0.7, top.y], steel)
	_poly([base - 1.4, 0, base - 0.2, 0, top.x - 0.2, top.y, top.x - 0.7, top.y], steel.lightened(0.1))
	# the cables: a fan from the pylon down to the deck over the river
	for k in 8:
		var y: float = top.y - 1.0 - k * 1.6
		var tx: float = lerpf(base, top.x, y / top.y)
		var dx: float = 14.0 - k * 4.2
		_l(tx, y, dx, deck_y + 1.2, dark, 0.12)
	_l(top.x - 0.4, top.y - 1.5, 31, deck_y + 1.2, dark, 0.15) # back stay
	# the UFO
	var ufo := Color("8c9296")
	_poly(_arc(top.x, top.y + 0.6, 4.6, 1.4, PI, TAU, 14), ufo.darkened(0.1))
	_poly(_arc(top.x, top.y + 0.6, 4.6, 1.8, 0, PI, 14), ufo)
	_r(top.x - 4.0, top.y + 0.3, top.x + 4.0, top.y + 0.9, Color("2e4660"))
	_poly(_arc(top.x, top.y + 2.0, 1.8, 0.9, 0, PI, 8), ufo.lightened(0.15))
	_l(top.x, top.y + 2.9, top.x, top.y + 4.4, dark, 0.15)

## St Elisabeth Cathedral in Košice: a big Gothic hall church with a steep roof of coloured glazed tiles in a
## diamond pattern, the tall north tower with its spire and the shorter south tower, the rose window.
static func _elisabeth_cathedral() -> void:
	var s := Color("c9b79a")
	var sd := s.darkened(0.15)
	# body
	_r(-12, 0, 12, 18, s)
	_poly([-12, 18, 12, 18, 0, 31], Color("7a5a3a"))
	if _detail(1.0): # glazed tiles: green and yellow diamonds
		for row in 5:
			var y: float = 19.5 + row * 2.4
			var half: float = 12.0 * (31.0 - y) / 13.0 - 1.0
			var n: int = int(half / 1.6)
			for k in range(-n, n + 1):
				var x: float = k * 1.6 + (0.8 if row % 2 == 1 else 0.0)
				if absf(x) > half: continue
				var col := Color("3f8a4a") if (k + row) % 2 == 0 else Color("d8b23a")
				_poly([x, y - 0.9, x + 0.7, y, x, y + 0.9, x - 0.7, y], col)
	# buttresses and tall windows
	for x in [-12.0, -6.0, 6.0, 12.0]:
		_r(x - 0.7, 0, x + 0.7, 15, sd)
		_poly([x - 0.7, 15, x + 0.7, 15, x, 17.5], sd)
	for x in [-9.0, 9.0]:
		_poly([x - 1.4, 3, x + 1.4, 3, x + 1.4, 11] + _arc(x, 11, 1.4, 2.4, 0, PI, 6), WIN)
	# the portal and rose window
	_poly([-3, 0, 3, 0, 3, 6] + _arc(0, 6, 3, 4, 0, PI, 10), sd)
	_poly([-1.8, 0, 1.8, 0, 1.8, 5.4] + _arc(0, 5.4, 1.8, 2.6, 0, PI, 8), WIN)
	_c(0, 13.5, 2.6, sd)
	_c(0, 13.5, 2.0, Color("4a6890"))
	if _detail(1.6):
		_l(-2.0, 13.5, 2.0, 13.5, sd, 0.2)
		_l(0, 11.5, 0, 15.5, sd, 0.2)
	_poly([-3.2, 18, 3.2, 18, 0, 22.5], s) # gable over the portal
	# the north tower (left, tall) and the south tower (right, short with a small cap)
	_r(-17, 0, -11.5, 30, s)
	_r(-17, 0, -15.8, 30, s.lightened(0.08))
	_windows(-16.2, -12.3, 20, 25, 1, WIN)
	_windows(-16.2, -12.3, 10, 14, 1, WIN)
	_r(-17.6, 30, -10.9, 31.2, sd)
	_r(-16.2, 31.2, -12.3, 36, s)
	for x in [-17.2, -11.3]:
		_poly([x - 0.5, 30, x + 0.5, 30, x, 33], sd)
	_poly([-16.6, 36, -11.9, 36, -14.25, 46.5], Color("4e6c58"))
	_c(-14.25, 46.8, 0.35, LandmarkPainter.GOLD)
	_l(-14.25, 46.8, -14.25, 48, LandmarkPainter.GOLD, 0.2)
	_r(11.5, 0, 16.5, 22, s)
	_windows(12.2, 15.8, 15, 19, 1, WIN)
	_poly([11.2, 22, 16.8, 22, 15.6, 25, 12.4, 25], Color("4e6c58"))
	_l(14, 25, 14, 27, Color("4e6c58"), 0.3)

## Spiš Castle: the long white ruin across a limestone hilltop, broken walls, the round keep on the summit and the
## Romanesque palace beside it, the outer bailey stepping down the slope.
static func _spis_castle() -> void:
	var hill := Color("7f9a52")
	var rock := Color("d9d4c4")
	_poly([-28, 0, 28, 0, 22, 6, 12, 10.5, 4, 13, -6, 12.5, -16, 9, -24, 4], hill)
	_poly([-6, 12.5, 4, 13, 9, 11.5, 6, 9, -2, 9.5], rock) # the white rock under the keep
	_poly([18, 7.5, 22, 6, 24, 3.5, 20, 4], rock.darkened(0.08))
	var wall := Color("ece6d6")
	var wd := wall.darkened(0.14)
	# outer bailey walls along the slope, ragged tops
	_poly([-24, 4, -16, 9, -16, 11, -19, 9.6, -21, 8.4, -24, 6.2], wall)
	_poly([-16, 9, -6, 12.5, -6, 15, -9, 14.2, -11, 13.4, -14, 12.6, -16, 11], wall)
	_poly([4, 13, 12, 10.5, 22, 6, 22, 9.2, 19, 10.4, 16, 11.6, 13, 12.4, 10, 14.2, 7, 15.0, 4, 15.6], wall)
	for x in [-20.0, -12.5, 15.0, 20.0]:
		var y: float = 7.0 if absf(x) > 18.0 else 11.0
		_r(x - 1.0, y - 2.0, x + 1.0, y + 3.0, wd)
	if _detail(1.2):
		for p in [[-18, 9.0], [-10, 12.6], [8, 12.6], [17, 9.6]]:
			_r(p[0] - 0.3, p[1] - 0.6, p[0] + 0.3, p[1] + 0.4, WIN)
	# the palace block and the round keep on top
	_poly([-5, 12.5, 3, 12.8, 3, 20.5, 1.8, 21.4, 0.6, 20.2, -1.6, 21.0, -3.2, 19.8, -5, 20.6], wall)
	_windows(-4.4, 2.4, 16, 18, 4, WIN)
	_r(-2.2, 20, 2.2, 25.2, wall)
	_r(-2.2, 20, -1.2, 25.2, wall.lightened(0.05))
	_r(2.2 - 0.8, 20, 2.2, 25.2, wd)
	_r(-2.5, 24.6, 2.5, 25.6, wd)
	if _detail(1.0):
		for x in [-2.0, -0.6, 0.8]:
			_r(x, 25.6, x + 0.8, 26.0, wd)
		_r(-0.4, 22, 0.4, 23.4, WIN)

## The High Tatras over Štrbské Pleso: a jagged row of granite peaks with snow, dark spruce forest below and the
## mountain lake in front.
static func _tatras() -> void:
	var granite := Color("7b7f86")
	var gd := granite.darkened(0.2)
	var snow := Color("f4f6f8")
	var far := [-35, 6, -30, 14, -26, 11, -21, 22, -17, 17, -13, 26, -9, 21, -5, 31, -1, 24, 3, 34, 7, 27, 11, 30,
		15, 22, 19, 25, 24, 15, 29, 18, 35, 8]
	_poly([-35, 4] + far + [35, 4], granite)
	# shadowed east faces
	for k in range(2, far.size() - 2, 4):
		var px: float = far[k]
		var py: float = far[k + 1]
		_poly([px, py, far[k + 2], far[k + 3], px + 1.2, 5], gd)
	# snow on the peaks and in the gullies
	for k in range(2, far.size() - 2, 4):
		var px: float = far[k]
		var py: float = far[k + 1]
		if py < 20.0: continue
		var d: float = (py - 15.0) * 0.18
		_poly([px, py, px + d, py - d * 2.0, px + d * 0.3, py - d * 1.4, px - d * 0.4, py - d * 2.2], snow)
		if _detail(1.2):
			_l(px + 0.2, py - d * 2.0, px + 0.6, py - d * 3.6, snow, 0.3)
	# spruce forest
	var tree := Color("2f5a3a")
	_poly([-35, 0, 35, 0, 35, 8, 22, 9.5, 10, 7.5, -4, 9, -18, 7, -35, 9.5], tree)
	if _detail(1.0):
		for k in 18:
			var x: float = -33.0 + k * 3.9
			var y: float = 7.5 + float((k * 7) % 3) * 0.7
			_poly([x - 1.1, y - 1.0, x + 1.1, y - 1.0, x, y + 2.4], tree.darkened(0.1))
	# the lake
	_poly([-20, 0.2, 20, 0.2, 16, 3.2, -14, 3.6], WATER)
	if _detail(1.0):
		_l(-12, 1.8, -2, 1.8, WATER_L, 0.25)
		_l(4, 1.2, 12, 1.2, WATER_L, 0.25)

## Banská Bystrica's clock tower on SNP square: a slim white tower leaning out of true, the clock face, the
## gallery and the baroque onion cap.
static func _leaning_clock_tower() -> void:
	var lean := 0.035 # the top stands about a metre off
	var w := Color("efe8d8")
	var wd := w.darkened(0.12)
	var pts := func(x: float, y: float) -> Array: return [x + y * lean, y]
	var body := []
	for p in [[-3, 0], [3, 0], [3, 22], [-3, 22]]:
		body.append_array(pts.call(p[0], p[1]))
	_poly(body, w)
	var side := []
	for p in [[2, 0], [3, 0], [3, 22], [2, 22]]:
		side.append_array(pts.call(p[0], p[1]))
	_poly(side, wd)
	var xo := 22.0 * lean
	# cornices and windows
	for y in [7.0, 14.0]:
		var o: float = y * lean
		_r(-3.3 + o, y - 0.4, 3.3 + o, y + 0.2, wd)
	for y in [3.0, 9.5]:
		var o: float = y * lean
		_r(-0.6 + o, y, 0.6 + o, y + 2.4, WIN)
	# the clock
	_c(17.5 * lean, 17.5, 1.9, Color("2e3238"))
	_c(17.5 * lean, 17.5, 1.6, Color("f8f4e8"))
	_l(17.5 * lean, 17.5, 17.5 * lean, 18.8, Color("2e3238"), 0.15)
	_l(17.5 * lean, 17.5, 17.5 * lean + 0.9, 17.5, Color("2e3238"), 0.15)
	# gallery and lantern
	_r(-3.6 + xo, 22, 3.6 + xo, 22.8, wd)
	var top_o := 23.0 * lean
	_r(-2.4 + top_o, 22.8, 2.4 + top_o, 26.5, w)
	_windows(-2.0 + top_o, 2.0 + top_o, 23.6, 25.6, 2, WIN)
	# the onion cap
	var cap := Color("3e4a44")
	var ox := 27.0 * lean
	_poly([-2.8 + ox, 26.5, 2.8 + ox, 26.5, 2.0 + ox, 28.0] + _arc(ox, 28.6, 2.2, 2.0, 0, PI, 10) + [-2.0 + ox, 28.0], cap)
	_r(-0.5 + ox, 30.4, 0.5 + ox, 32.4, cap)
	_poly(_arc(ox, 32.4, 0.9, 1.2, 0, PI, 6), cap)
	_l(ox, 33.4, ox + 0.05, 35.6, LandmarkPainter.GOLD, 0.2)
	_l(ox - 0.6, 34.8, ox + 0.6, 34.8, LandmarkPainter.GOLD, 0.15)

## Trenčín Castle: walls and palaces climbing a steep limestone rock above the town, the tall square Matúš Tower
## on top with its dark roof, battlements below.
static func _trencin_castle() -> void:
	var rock := Color("a7a08f")
	var rd := rock.darkened(0.18)
	_poly([-21, 0, 21, 0, 17, 5, 12, 9, 8, 15, 2, 19, -6, 18, -12, 13, -17, 6], rock)
	_poly([2, 19, 8, 15, 12, 9, 17, 5, 21, 0, 12, 0, 9, 6, 5, 12], rd)
	_poly([-21, 0, -17, 6, -14, 4, -16, 0], GRASS)
	var wall := Color("e6dfcd")
	var wd := wall.darkened(0.14)
	# the lower walls with battlements
	_r(-17, 5, 16, 8, wall)
	_r(-17, 5, 16, 5.6, wd)
	if _detail(1.0):
		for k in 17:
			var x: float = -16.6 + k * 1.95
			_r(x, 8, x + 1.0, 8.8, wall)
	for x in [-15.0, 14.0]:
		_r(x - 1.6, 5, x + 1.6, 11, wall)
		_poly([x - 2.0, 11, x + 2.0, 11, x, 13.5], RED_ROOF)
	# the palaces on the rock
	_r(-11, 12, -1, 20, wall)
	_windows(-10.4, -1.6, 15, 17.4, 4, WIN)
	_poly([-11.5, 20, -0.5, 20, -2.5, 23, -9.5, 23], RED_ROOF)
	_r(3, 13, 11, 19, wall.darkened(0.05))
	_windows(3.6, 10.4, 15, 17, 3, WIN)
	_poly([2.6, 19, 11.4, 19, 7, 22], RED_ROOF.darkened(0.1))
	# the Matúš Tower
	_r(-1.2, 17, 4.2, 31, wall)
	_r(3.0, 17, 4.2, 31, wd)
	_windows(-0.6, 3.2, 26, 28, 2, WIN)
	_windows(-0.6, 3.2, 21, 23, 1, WIN)
	_r(-1.8, 31, 4.8, 32, wd)
	_poly([-1.8, 32, 4.8, 32, 1.5, 36], Color("4a4a4a"))
	_l(1.5, 36, 1.5, 37.5, Color("4a4a4a"), 0.15)

## The Crutch Breaker in Piešťany: a bronze man on a stone pedestal snapping his crutch over his knee.
static func _crutch_breaker() -> void:
	var stone := Color("b9b4a8")
	_r(-2.2, 0, 2.2, 2.6, stone)
	_r(-2.6, 2.4, 2.6, 2.9, stone.lightened(0.1))
	var b := Color("4e5a4a")
	var bl := b.lightened(0.15)
	# legs: one standing, one knee raised
	_poly([-0.9, 2.9, -0.2, 2.9, -0.1, 5.2, -0.8, 5.2], b)
	_poly([0.0, 5.2, 0.6, 5.0, 1.5, 4.9, 1.4, 4.3, 0.4, 4.4, 0.0, 4.6], b)
	_poly([1.4, 4.3, 1.5, 4.9, 1.7, 3.4, 1.4, 3.4], b)
	# torso, head
	_poly([-0.9, 5.2, 0.6, 5.2, 0.5, 7.0, -0.8, 7.0], bl)
	_c(-0.15, 7.5, 0.45, bl)
	# arms down to the crutch bent over the knee
	_l(-0.6, 6.7, 0.0, 5.6, b, 0.22)
	_l(0.4, 6.7, 1.7, 5.7, b, 0.22)
	_l(-1.3, 4.0, 0.9, 5.4, Color("7a5a3a"), 0.16)
	_l(0.9, 5.4, 2.4, 4.0, Color("7a5a3a"), 0.16)
	_l(-1.3, 4.0, -1.6, 3.8, Color("7a5a3a"), 0.16)

## Komárno Fortress: low brick bastion walls with white stone edges, earth ramparts on top, the gate with its
## arched passage and the Danube in front.
static func _komarno_fortress() -> void:
	_r(-24, 0, 24, 1.6, WATER)
	if _detail(1.0):
		_l(-20, 0.8, -10, 0.8, WATER_L, 0.2)
		_l(6, 0.8, 18, 0.8, WATER_L, 0.2)
	var brick := Color("a5583a")
	var bd := brick.darkened(0.18)
	var edge := Color("e2dccb")
	# ramparts with grass on top
	_poly([-22, 1.6, 22, 1.6, 20, 8.6, -20, 8.6], brick)
	_r(-20.5, 8.6, 20.5, 10, GRASS)
	# the pointed bastions sticking out
	for x in [-14.0, 14.0]:
		_poly([x - 5, 1.6, x + 5, 1.6, x + 4.2, 8.6, x, 10.2, x - 4.2, 8.6], bd)
		_poly([x - 4.2, 8.6, x, 10.2, x + 4.2, 8.6, x, 9.4], edge)
		_l(x, 1.6, x, 10.2, edge, 0.2)
	_l(-20, 8.6, 20, 8.6, edge, 0.3)
	if _detail(1.4):
		for x in [-18.0, -9.0, 9.0, 18.0]:
			_r(x - 0.5, 5.0, x + 0.5, 5.8, WIN) # gun ports
	# the gate block
	_r(-5, 1.6, 5, 12, edge)
	_r(-5.4, 12, 5.4, 13, edge.darkened(0.12))
	_poly([-2, 1.6, 2, 1.6, 2, 6] + _arc(0, 6, 2, 2, 0, PI, 8), WIN.darkened(0.2))
	_windows(-4.4, 4.4, 9, 10.6, 3, WIN)
	_poly([-5.6, 13, 5.6, 13, 0, 15.8], RED_ROOF)
	_l(0, 15.8, 0, 17.4, Color("6b5a3a"), 0.15)
	_poly([0, 17.4, 1.4, 17.0, 0, 16.6], Color("d23a3a"))
