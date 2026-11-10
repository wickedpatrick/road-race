class_name LandmarksChA
extends RefCounted
## Swiss landmarks (Zürich to Luzern), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const SAND := Color("d8cdb4")
const SAND_D := Color("b5a98d")
const WHITE := Color("f2efe6")
const WHITE_D := Color("d6d1c4")
const RED := Color("b8402f")
const RED_D := Color("8e2f22")
const ROOF := Color("8c4a32")
const ROOF_D := Color("6e3726")
const SLATE := Color("5d646b")
const COPPER := Color("6fa58f")
const GOLD := Color("d9b13b")
const WOOD := Color("8a5a32")
const WOOD_D := Color("654024")
const WIN := Color("3a3a40")
const DARK := Color("2b2b30")
const WATER := Color("4f86a8")
const WATER_L := Color("7fb0cc")
const GRASS := Color("6b8f45")
const PAVE := Color("9a9285")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"ch_zuerich_grossmuenster": _zuerich_grossmuenster()
		"ch_geneve_jet_deau": _geneve_jet_deau()
		"ch_basel_rathaus": _basel_rathaus()
		"ch_lausanne_cathedrale": _lausanne_cathedrale()
		"ch_bern_zytglogge": _bern_zytglogge()
		"ch_winterthur_stadthaus": _winterthur_stadthaus()
		"ch_luzern_kapellbruecke": _luzern_kapellbruecke()
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

static func _arched(x: float, y0: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.5, y0, x + w * 0.5, y0, x + w * 0.5, y0 + h - w * 0.5] + _arc(x, y0 + h - w * 0.5, w * 0.5, w * 0.5, 0, PI, 6), col)

## The Grossmünster in Zürich: the Romanesque church of sandstone with its twin towers, each with an octagonal top
## storey and a small dome; the long nave and the round-arched portal between them.
static func _zuerich_grossmuenster() -> void:
	_r(-20, 0, 20, 0.6, PAVE)
	# the nave behind, with its roof
	_r(-14, 0.6, 14, 20, SAND)
	_poly([-14.5, 20, 14.5, 20, 9, 26, -9, 26], ROOF)
	_arched(0, 0.6, 4.0, 8.0, DARK)
	_arched(0, 11, 2.4, 5.0, WIN)
	for s in [-1, 1]:
		var x: float = s * 10.5
		# the square tower, two belfry storeys
		_r(x - 4, 0.6, x + 4, 40, SAND)
		_r(x - 4.3, 26, x + 4.3, 27, SAND_D)
		_r(x - 4.3, 33, x + 4.3, 34, SAND_D)
		_arched(x - 1.5, 28, 1.6, 4.0, WIN)
		_arched(x + 1.5, 28, 1.6, 4.0, WIN)
		_arched(x, 35, 2.0, 4.0, WIN)
		_arched(x, 10, 1.8, 4.0, WIN)
		# the octagonal top storey and its dome
		_r(x - 3.2, 40, x + 3.2, 48, SAND)
		_r(x - 3.4, 47.6, x + 3.4, 48.4, SAND_D)
		_arched(x, 41.5, 1.8, 4.5, WIN)
		_poly(_arc(x, 48.4, 3.2, 8.0, 0, PI, 10), SLATE)
		_r(x - 0.2, 56, x + 0.2, 60, DARK)
		_c(x, 60, 0.5, GOLD)

## The Jet d'Eau in Geneva: the 140 m jet of water from the harbour wall at the Eaux-Vives, the spray falling back
## downwind, the little lighthouse at the end of the jetty.
static func _geneve_jet_deau() -> void:
	_r(-20, 0, 20, 2, WATER)
	_r(-20, 1.6, 20, 2, WATER_L)
	# the jetty from the left with its lighthouse
	_r(-20, 2, 2, 3.2, Color("c9c3b4"))
	_r(-18, 3.2, -16, 9, WHITE)
	_r(-18.4, 9, -15.6, 9.6, DARK)
	_r(-17.6, 9.6, -16.4, 11, Color("e8c34a"))
	_poly([-18, 11, -16, 11, -17, 12.4], RED)
	# the jet: a narrow column widening as it rises, the plume bending and falling back to the right
	_poly([3.4, 3.2, 4.6, 3.2, 5.4, 60, 6.2, 130, 4.0, 138, 2.6, 130, 3.0, 60], Color(1, 1, 1, 0.92))
	_poly([4.0, 138, 6.2, 130, 10, 120, 14, 100, 16, 70, 13, 70, 11, 100, 8, 118], Color(1, 1, 1, 0.55))
	_poly([13, 70, 16, 70, 18, 40, 19, 12, 15, 12, 15, 40], Color(1, 1, 1, 0.35))
	_poly([15, 12, 19, 12, 19.5, 3, 14, 3], Color(1, 1, 1, 0.25))
	_c(4.0, 136, 2.6, Color(1, 1, 1, 0.8))

## Basel's town hall on the Marktplatz: the red sandstone front with its painted walls, three arches below, the gilt
## spire over the slim tower on the right and the merlons along the top.
static func _basel_rathaus() -> void:
	_r(-18, 0, 18, 0.6, PAVE)
	_r(-15, 0.6, 9, 24, RED)
	_r(-15.4, 11, 9.4, 12, RED_D)
	for x in [-10.0, -3.0, 4.0]:
		_arched(x, 0.6, 5.0, 9.0, DARK)
	_windows(-14, 8, 14, 20, 6, WIN)
	_r(-6, 13.5, 0, 20.5, GOLD) # the clock and its painted frame
	_c(-3, 17, 2.2, Color("2c4f8a"))
	_c(-3, 17, 0.5, GOLD)
	# merlons along the top
	for k in 8:
		var x := -15.0 + k * 3.0
		_r(x, 24, x + 1.6, 26, RED)
	# the tower on the right with its gilt spire
	_r(9, 0.6, 15, 30, RED)
	_r(8.6, 30, 15.4, 31, RED_D)
	_arched(12, 2, 3.0, 6.0, DARK)
	_arched(12, 20, 2.0, 5.0, WIN)
	_poly([9, 31, 15, 31, 12, 40], GOLD)
	_r(11.8, 40, 12.2, 42, DARK)

## The Cathedral of Notre-Dame in Lausanne: the Gothic church high above the town, the square lantern tower over the
## crossing with its steep spire and the unfinished west front with its one belfry.
static func _lausanne_cathedrale() -> void:
	_r(-35, 0, 35, 0.6, PAVE)
	# the nave with its buttresses and pointed windows
	_r(-26, 0.6, 26, 22, SAND)
	_poly([-26.5, 22, 26.5, 22, 22, 30, -18, 30], ROOF)
	for x in [-20.0, -12.0, 4.0, 14.0, 22.0]:
		_r(x - 0.8, 0.6, x + 0.8, 20, SAND_D)
		_arched(x + 3.5, 8, 2.2, 9.0, WIN)
	# the west belfry on the left, square with a short pointed roof
	_r(-34, 0.6, -24, 48, SAND)
	_r(-34.4, 30, -23.6, 31, SAND_D)
	_arched(-29, 0.6, 5.0, 10.0, DARK)
	_arched(-31, 36, 2.0, 8.0, WIN)
	_arched(-27, 36, 2.0, 8.0, WIN)
	_poly([-34.5, 48, -23.5, 48, -29, 56], SLATE)
	# the lantern tower over the crossing and its tall spire
	_r(-6, 22, 4, 40, SAND)
	_arched(-3.5, 28, 2.0, 9.0, WIN)
	_arched(1.5, 28, 2.0, 9.0, WIN)
	for x in [-6.0, 4.0]:
		_poly([x - 1.0, 40, x + 1.0, 40, x, 46], SAND_D)
	_poly([-5.5, 40, 3.5, 40, -1, 74], SLATE)
	_r(-1.2, 74, -0.8, 75, GOLD)

## The Zytglogge in Bern: the medieval gate tower with its astronomical clock over the arch, the big clock face above,
## the steep roof with the bell turret and the gilt figure that strikes the hours.
static func _bern_zytglogge() -> void:
	_r(-8, 0, 8, 0.6, PAVE)
	_r(-6, 0.6, 6, 32, SAND)
	_r(-6.3, 31.5, 6.3, 32.5, SAND_D)
	_arched(0, 0.6, 5.0, 8.0, DARK)
	# the astronomical clock over the passage
	_r(-3.4, 10, 3.4, 16.6, Color("2c4f8a"))
	_c(0, 13.3, 2.6, Color("d6b25a"))
	_c(0, 13.3, 1.6, Color("2c4f8a"))
	_c(0, 13.3, 0.5, GOLD)
	# the big clock face higher up
	_r(-4.6, 19, 4.6, 28, RED_D)
	_c(0, 23.5, 3.8, Color("2a2a2e"))
	_c(0, 23.5, 3.3, GOLD)
	_c(0, 23.5, 2.9, Color("2a2a2e"))
	_l(0, 23.5, 0, 26, GOLD, 0.35)
	_l(0, 23.5, 1.8, 23.5, GOLD, 0.35)
	_windows(-5, 5, 29, 31, 3, WIN)
	# the steep roof, the bell turret and its pointed cap
	_poly([-6.6, 32.5, 6.6, 32.5, 3.0, 44, -3.0, 44], ROOF)
	_r(-1.8, 44, 1.8, 48, SAND)
	_r(-1.0, 45, 1.0, 47.5, DARK)
	_poly([-2.4, 48, 2.4, 48, 0, 53.5], ROOF_D)
	_c(0, 53.6, 0.35, GOLD)

## The Stadthaus of Winterthur by Gottfried Semper: the classical front on its high flight of steps, the portico of
## columns with the pediment, the round-arched windows of the wings.
static func _winterthur_stadthaus() -> void:
	_r(-25, 0, 25, 0.6, PAVE)
	_r(-24, 0.6, 24, 18, WHITE)
	_r(-24.4, 18, 24.4, 19.2, WHITE_D)
	_poly([-24, 19.2, 24, 19.2, 20, 21.5, -20, 21.5], SLATE)
	for x in [-20.0, -15.5, 15.5, 20.0]:
		_arched(x, 3, 2.4, 6.0, WIN)
		_arched(x, 10.5, 2.4, 6.0, WIN)
	# the steps and the portico
	for k in 4:
		_r(-11.0 + k * 0.6, 0.6 + k * 0.8, 11.0 - k * 0.6, 1.4 + k * 0.8, WHITE_D)
	_r(-9, 3.8, 9, 16, WHITE_D)
	_r(-8.6, 4.2, 8.6, 15.4, WIN)
	for k in 6:
		var x := -8.0 + k * 3.2
		_r(x - 0.55, 3.8, x + 0.55, 15.8, WHITE)
	_r(-10, 15.8, 10, 17.4, WHITE)
	_poly([-10.5, 17.4, 10.5, 17.4, 0, 24], WHITE)
	_poly([-8, 18.2, 8, 18.2, 0, 22.6], WHITE_D)

## The Kapellbrücke in Lucerne: the covered wooden footbridge across the Reuss with its red tiled roof and flower
## boxes, and the octagonal stone Water Tower standing in the river beside it.
static func _luzern_kapellbruecke() -> void:
	_r(-45, 0, 45, 3, WATER)
	_r(-45, 2.6, 45, 3, WATER_L)
	# piles under the deck
	for k in 15:
		_r(-43.0 + k * 6.0, 0, -42.4 + k * 6.0, 4.5, WOOD_D)
	_r(-45, 4.5, 45, 5.2, WOOD_D)
	# the open sides, the flower boxes and the posts
	_r(-45, 5.2, 45, 8.2, Color("4a3826"))
	_r(-45, 5.2, 45, 6.2, WOOD)
	for k in 30:
		_r(-44.6 + k * 3.0, 6.2, -44.0 + k * 3.0, 8.2, WOOD)
	for k in 15:
		_r(-43.5 + k * 6.0, 6.2, -41.0 + k * 6.0, 7.0, Color("c8403a"))
	_poly([-45, 8.2, 45, 8.2, 45, 9.4, -45, 9.4], ROOF)
	_poly([-45, 9.4, 45, 9.4, 45, 10.4, -45, 10.4], ROOF_D)
	# the Water Tower: octagonal stone, then the brick top storey and the pointed roof
	_r(12, 0, 22, 28, SAND)
	_r(12, 0, 13.5, 28, SAND_D)
	_r(20.5, 0, 22, 28, SAND_D)
	_r(13.5, 12, 15, 15, WIN)
	_r(18, 20, 19.5, 23, WIN)
	_r(11.6, 28, 22.4, 33, RED)
	_windows(12.6, 21.4, 29, 32, 3, WIN)
	_poly([11.2, 33, 22.8, 33, 17, 39.6], ROOF)
