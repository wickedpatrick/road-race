class_name LandmarksFrA
extends RefCounted
## French landmarks (Paris to Rennes), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const WHITE := Color("f1ede2")
const CREAM := Color("e3d6b8")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const GOLD := Color("e0b43a")
const SLATE := Color("4f5866")
const WATER := Color("5b88b0")
const GRASS := Color("5d8f42")
const PINK_BRICK := Color("c9765e")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"fr_paris_eiffel": _paris_eiffel()
		"fr_marseille_bonne_mere": _marseille_bonne_mere()
		"fr_lyon_fourviere": _lyon_fourviere()
		"fr_toulouse_capitole": _toulouse_capitole()
		"fr_nice_negresco": _nice_negresco()
		"fr_nantes_elephant": _nantes_elephant()
		"fr_montpellier_arc": _montpellier_arc()
		"fr_strasbourg_cathedral": _strasbourg_cathedral()
		"fr_bordeaux_miroir": _bordeaux_miroir()
		"fr_lille_beffroi": _lille_beffroi()
		"fr_rennes_parlement": _rennes_parlement()
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

## A round-arched opening: a rectangle under a half circle.
static func _arched(x: float, y0: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.5, y0, x + w * 0.5, y0, x + w * 0.5, y0 + h - w * 0.5] + _arc(x, y0 + h - w * 0.5, w * 0.5, w * 0.5, 0, PI, 6), col)

## The Eiffel Tower (1889): four splayed iron legs joined by the arch under the first platform, the second
## platform, the long tapering shaft and the top with its antenna, in the brown "Eiffel tower" paint.
static func _paris_eiffel() -> void:
	var iron := Color("6e5a48")
	var iron_d := Color("54443a")
	# the legs up to the first platform, with the big arch between them
	_poly([-28, 0, -20, 0] + _arc(0, 16, 12, 11, PI, 0, 12) + [20, 0, 28, 0, 16, 36, -16, 36], iron)
	_r(-17, 34, 17, 37.5, iron_d)
	# up to the second platform
	_poly([-14, 37.5, 14, 37.5, 8.5, 62, -8.5, 62], iron)
	_poly([-6, 37.5, 6, 37.5, 2.5, 52, -2.5, 52], Color("a9b9c6"))
	_r(-9.5, 61, 9.5, 64, iron_d)
	# the shaft to the top
	_poly([-7.5, 64, 7.5, 64, 2.2, 108, -2.2, 108], iron)
	_r(-3, 108, 3, 111, iron_d)
	_poly([-2, 111, 2, 111, 0.6, 115, -0.6, 115], iron)
	_l(0, 115, 0, 120, iron_d, 0.4)
	if _detail(1.0):
		for k in 6: # the lattice
			var y := 66.0 + k * 7.0
			_l(-7.0 + k * 0.85, y, 7.0 - k * 0.85, y + 6.0, iron_d, 0.25)
			_l(7.0 - k * 0.85, y, -7.0 + k * 0.85, y + 6.0, iron_d, 0.25)

## Notre-Dame de la Garde (1864): the striped Romanesque-Byzantine basilica on its limestone rock above the port,
## a dome over the nave and the square bell tower carrying the gilded Virgin and Child.
static func _marseille_bonne_mere() -> void:
	var rock := Color("bdb39c")
	var stripe := Color("7d8a6e")
	_poly([-25, 0, 25, 0, 21, 14, 8, 20, -14, 20, -22, 12], rock)
	# the nave with its dome
	_r(-20, 20, 4, 32, WHITE)
	for k in 4:
		_r(-20, 22.5 + k * 2.6, 4, 23.3 + k * 2.6, stripe)
	_poly([-14, 32] + _arc(-8, 32, 6, 5.5, PI, 0, 10) + [-2, 32], WHITE)
	_c(-8, 38, 0.8, GOLD)
	# the bell tower
	_r(4, 20, 14, 46, WHITE)
	for k in 6:
		_r(4, 23 + k * 3.6, 14, 23.8 + k * 3.6, stripe)
	_arched(9, 38, 4.5, 6, DARK)
	_r(5.5, 46, 12.5, 50, WHITE)
	# the gilded statue
	_poly([7.8, 50, 10.2, 50, 9.7, 57, 8.3, 57], GOLD)
	_c(9, 58, 0.9, GOLD)

## The Basilica of Notre-Dame de Fourvière (1872–1896): a white stone church with four octagonal corner towers
## with battlements, a gabled front with a colonnade and the gilded Virgin on the old chapel's bell tower beside it.
static func _lyon_fourviere() -> void:
	_r(-22, 0, 22, 2, GRASS)
	_r(-14, 2, 14, 22, WHITE)
	_poly([-10, 22, 10, 22, 0, 28], WHITE)
	for x in [-11.0, -7.0, -3.0, 1.0, 5.0, 9.0]:
		_r(x, 4, x + 1.6, 16, CREAM)
	_r(-12, 16, 12, 17, CREAM)
	for x in [-19.0, 13.0]:
		_r(x, 2, x + 6, 30, WHITE)
		for k in 3:
			_r(x + k * 2.2, 30, x + k * 2.2 + 1.4, 31.6, WHITE)
		_windows(x, x + 6, 18, 24, 2, WIN)
	_arched(0, 2, 4, 7, DARK)
	# the chapel's bell tower with the Virgin
	_r(18.5, 2, 22, 26, CREAM)
	_poly([18.2, 26, 22.3, 26, 20.25, 30], SLATE)
	_poly([19.6, 30, 20.9, 30, 20.6, 34, 19.9, 34], GOLD)
	_c(20.25, 34.6, 0.6, GOLD)

## The Capitole de Toulouse (1750s front): a long pink-brick facade with white stone, eight pink marble
## columns in the middle under a pediment, and the flags on the roof.
static func _toulouse_capitole() -> void:
	_r(-35, 0, 35, 18, PINK_BRICK)
	_r(-35, 17, 35, 19, CREAM)
	_r(-35, 0, 35, 1.2, CREAM)
	_windows(-34, -12, 4, 8, 7, WIN)
	_windows(12, 34, 4, 8, 7, WIN)
	_windows(-34, -12, 11, 15, 7, WIN)
	_windows(12, 34, 11, 15, 7, WIN)
	# the middle with its columns
	_r(-12, 0, 12, 19, CREAM)
	for k in 8:
		_r(-10.6 + k * 2.9, 6, -9.4 + k * 2.9, 17, Color("b7616a"))
	_arched(0, 0, 3.6, 5.5, DARK)
	_poly([-13, 19, 13, 19, 0, 23.5], CREAM)
	for x in [-6.0, 0.0, 6.0]:
		_l(x, 23.5 - absf(x) * 0.35, x, 27 - absf(x) * 0.35, DARK, 0.15)
		_r(x, 25.6 - absf(x) * 0.35, x + 1.8, 27 - absf(x) * 0.35, Color("1f4aa0") if x < 0 else (Color("d4a72c") if x == 0 else Color("c8102e")))

## The Hotel Negresco (1913) on the Promenade des Anglais: a white Belle Époque front with balconies and the
## pink-and-green dome over its corner rotunda.
static func _nice_negresco() -> void:
	_r(-25, 0, 25, 1.5, Color("cfc4ae"))
	_r(-25, 1.5, 12, 24, WHITE)
	_r(-25, 23, 12, 25, CREAM)
	for k in 5:
		_windows(-24, 11, 4 + k * 4, 6.4 + k * 4, 10, WIN)
		_r(-25, 3.6 + k * 4, 12, 3.9 + k * 4, CREAM)
	# the corner rotunda and its dome
	_r(12, 1.5, 24, 24, WHITE)
	_windows(12.5, 23.5, 5, 21, 3, WIN)
	_poly([11.5, 24] + _arc(18, 24, 6.5, 8, PI, 0, 12) + [24.5, 24], Color("e39aa3"))
	_l(18, 24, 18, 32, Color("5f9e86"), 0.6)
	_c(18, 32.6, 0.9, Color("5f9e86"))
	_l(18, 33.4, 18, 34.5, DARK, 0.2)
	# the flags over the door
	_l(-8, 25, -8, 30, DARK, 0.15)
	_r(-8, 28, -5.6, 29.6, Color("c8102e"))

## The Great Elephant of the Machines de l'île (2007): a 12 m walking machine of wood and steel, its trunk
## raised, passengers on the deck under a canopy on its back.
static func _nantes_elephant() -> void:
	var wood := Color("8a6a48")
	var wood_d := Color("6b5038")
	var steel := Color("5c5f62")
	for x in [-8.0, -4.0, 3.0, 7.0]: # the legs
		_r(x - 1.1, 0, x + 1.1, 5.5, steel)
		_r(x - 1.4, 0, x + 1.4, 0.6, DARK)
	_poly([-10, 5, 9, 5, 10, 9, 6, 11.5, -8, 11.5, -10.5, 9], wood)
	_l(-9, 7, 9, 7, wood_d, 0.25)
	# the head, ear and raised trunk
	_poly([7, 6, 11, 6, 12, 10, 9, 12, 6.5, 11], wood)
	_poly([7, 7, 9.5, 6.5, 9.5, 11.5, 6.5, 12], wood_d)
	_poly([11, 7, 12, 8, 12.6, 11, 12, 13.8, 11.2, 13.6, 11.4, 11, 10.5, 8.5], wood)
	_l(10.8, 6.2, 11.8, 5.2, WHITE, 0.25) # tusk
	# the deck with passengers and a canopy
	_r(-8, 11.5, 5, 12.1, wood_d)
	for x in [-6.0, -3.0, 0.0, 3.0]:
		_c(x, 12.8, 0.35, Color("c06040"))
	_l(-8, 12, -8, 14, steel, 0.15)
	_l(5, 12, 5, 14, steel, 0.15)
	_r(-8.4, 13.8, 5.4, 14.2, Color("d9c7a3"))

## The Arc de Triomphe of the Porte du Peyrou (1693): a pale stone gate with a single round arch, pilasters and
## a heavy attic, in honour of Louis XIV.
static func _montpellier_arc() -> void:
	_r(-10, 0, 10, 13, CREAM)
	_arched(0, 0, 7, 10, Color("6d7f8e"))
	for x in [-9.0, -6.0, 5.0, 8.0]:
		_r(x, 0.5, x + 1, 12, WHITE)
	_r(-10.6, 12.6, 10.6, 13.6, WHITE)
	_r(-10, 13.6, 10, 17, CREAM)
	_r(-6, 14.3, 6, 16.3, Color("d1c1a0"))
	_r(-10.6, 17, 10.6, 17.8, WHITE)

## Strasbourg Cathedral: the pink-sandstone west front with its rose window and lacework of tracery, the single
## north tower and its openwork spire (142 m, 1439), the south tower never built.
static func _strasbourg_cathedral() -> void:
	var sand := Color("b5776a")
	var sand_d := Color("94584d")
	_r(-20, 0, 20, 42, sand)
	_poly([-20, 42, -8, 42, -8, 48, -20, 48], sand)
	_r(-8, 42, 6, 46, sand)
	_c(-1, 30, 5.5, sand_d)
	_c(-1, 30, 3.5, Color("4a5a7a"))
	for x in [-14.0, -1.0, 12.0]:
		_poly([x - 3, 0, x + 3, 0, x + 3, 9, x, 13, x - 3, 9], DARK)
	if _detail(1.1):
		for x in [-17.0, -11.0, 9.0, 15.0]:
			_l(x, 14, x, 40, sand_d, 0.35)
	# the north tower and spire on the left
	_r(-20, 42, -6, 70, sand)
	_l(-16, 46, -16, 68, sand_d, 0.4)
	_l(-10, 46, -10, 68, sand_d, 0.4)
	_poly([-20, 70, -6, 70, -8, 76, -18, 76], sand_d)
	_poly([-18, 76, -8, 76, -11.5, 104, -14.5, 104], sand)
	if _detail(1.0):
		for k in 6:
			var y := 79.0 + k * 4.0
			var hw := 5.0 - k * 0.65
			_l(-13 - hw, y, -13 + hw, y, sand_d, 0.25)
	_l(-13, 104, -13, 110, sand_d, 0.4)
	_l(-14.2, 108.4, -11.8, 108.4, sand_d, 0.3)

## Place de la Bourse in Bordeaux (1730–1775): the pale palaces around the square on the Garonne, reflected in
## the Water Mirror before them.
static func _bordeaux_miroir() -> void:
	var stone := Color("e4d9bf")
	var roof := Color("5c6470")
	# the mirror (flat, with the palace upside down in it)
	_r(-40, 0, 40, 4, Color("8aa5b8"))
	_r(-14, 0.6, 14, 3.4, Color("c9c4b4"))
	_r(-38, 2.5, -16, 3.4, Color("c9c4b4"))
	_r(16, 2.5, 38, 3.4, Color("c9c4b4"))
	# the wings and the middle pavilion
	for x in [-38.0, 16.0]:
		_r(x, 4, x + 22, 15, stone)
		_poly([x - 0.5, 15, x + 22.5, 15, x + 20.5, 19, x + 1.5, 19], roof)
		_windows(x + 1, x + 21, 6, 9, 8, WIN)
		_windows(x + 1, x + 21, 10.5, 13.5, 8, WIN)
	_r(-14, 4, 14, 16, stone)
	_poly([-14.5, 16, 14.5, 16, 12, 21, -12, 21], roof)
	_poly([-6, 16, 6, 16, 0, 18.5], stone)
	for k in 5:
		_arched(-9.6 + k * 4.8, 4, 2.6, 5, WIN)
	_windows(-13, 13, 10.5, 14, 7, WIN)
	_poly([-1.5, 21, 1.5, 21, 0, 22], roof)

## The belfry of Lille City Hall (1932): a 104 m brick tower in the Flemish style, narrowing in steps to the
## clock and the stone lantern under a pointed cap.
static func _lille_beffroi() -> void:
	var brick := Color("a65a3a")
	var stone := Color("d8ccb0")
	_r(-12, 0, 12, 12, brick)
	_windows(-11, 11, 3, 9, 6, WIN)
	_r(-6, 0, 6, 58, brick)
	_l(-3, 12, -3, 56, Color("8a4930"), 0.4)
	_l(3, 12, 3, 56, Color("8a4930"), 0.4)
	_r(-6.6, 58, 6.6, 60, stone)
	_r(-5, 60, 5, 70, brick)
	_c(0, 65, 3, stone)
	_c(0, 65, 2.4, Color("1d2a3a"))
	_l(0, 65, 0, 66.8, stone, 0.2)
	_l(0, 65, 1.3, 65, stone, 0.2)
	_r(-4, 70, 4, 78, stone)
	for x in [-3.0, -0.5, 2.0]:
		_r(x, 71.5, x + 1, 76.5, WIN)
	_poly([-4.4, 78, 4.4, 78, 0, 88], Color("5f7a6e"))
	_l(0, 88, 0, 90, DARK, 0.2)

## The Parliament of Brittany in Rennes (1655): a long stone palace with a ground floor of rusticated granite,
## tall windows and the steep slate roof with gilded dormers.
static func _rennes_parlement() -> void:
	var granite := Color("b9b4a8")
	var tufa := Color("e6dcc4")
	_r(-30, 0, 30, 6, granite)
	_r(-30, 6, 30, 16, tufa)
	_windows(-29, 29, 8, 14, 11, WIN)
	for k in 6:
		_r(-30, k * 1.0, 30, k * 1.0 + 0.12, Color("9a958a"))
	_r(-6, 6, 6, 17.5, tufa)
	_poly([-7, 17.5, 7, 17.5, 0, 20.5], tufa)
	_poly([-30.5, 16, 30.5, 16, 27, 25, -27, 25], SLATE)
	if _detail(1.0):
		for k in 8:
			var x := -24.0 + k * 6.85
			_r(x - 0.9, 17.5, x + 0.9, 20, Color("3e4650"))
			_poly([x - 1.2, 20, x + 1.2, 20, x, 21.6], GOLD)
