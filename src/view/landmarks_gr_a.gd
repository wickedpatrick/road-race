class_name LandmarksGrA
extends RefCounted
## Greek landmarks (Athens to Chania), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const MARBLE := Color("ece4d2")
const MARBLE_D := Color("cfc3a6")
const LIME := Color("f4f1e8")
const STONE := Color("d9c9a3")
const STONE_D := Color("b5a27a")
const ROCK := Color("b39d7c")
const ROOF := Color("c25a35")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const WATER := Color("2f86b8")
const WATER_L := Color("8ccbe8")
const GRASS := Color("8a9a4a")
const OLIVE := Color("6f7f45")
const WOOD := Color("7a5636")
const GR_BLUE := Color("0d5eaf")
const GOLD := Color("e0b43a")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"acropolis_parthenon": _parthenon()
		"evzone_guard": _evzone()
		"olympias_trireme": _trireme()
		"white_tower_thessaloniki": _white_tower()
		"rio_antirrio_bridge": _rio_antirrio()
		"knossos_palace": _knossos()
		"larisa_ancient_theatre": _larisa_theatre()
		"argo_volos": _argo()
		"ioannina_kale_mosque": _ioannina_kale()
		"chania_lighthouse": _chania_lighthouse()
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

## An arched opening (round top) from y0 up to the spring line y1.
static func _archway(x: float, hw: float, y0: float, y1: float, col: Color) -> void:
	_poly([x + hw, y0, x + hw, y1] + _arc(x, y1, hw, hw, 0, PI, 6) + [x - hw, y0], col)

## Gentle sea waves: a band of water with lighter crests.
static func _sea(x0: float, x1: float, y: float) -> void:
	_r(x0, 0, x1, y, WATER)
	if _detail(1.0):
		var x := x0 + 2.0
		while x < x1 - 3.0:
			_l(x, y * 0.5, x + 2.5, y * 0.5, WATER_L, 0.15)
			x += 7.0

## A Greek flag on a pole: nine blue and white stripes, the white cross in the blue canton.
static func _flag(x: float, y: float, w: float) -> void:
	_l(x, y - w * 1.6, x, y + w * 0.7, DARK, 0.18)
	var h := w * 2.0 / 3.0
	for k in 9:
		_r(x, y + h - (k + 1) * h / 9.0, x + w, y + h - k * h / 9.0, GR_BLUE if k % 2 == 0 else Color.WHITE)
	var cw := h * 5.0 / 9.0
	_r(x, y + h - cw, x + cw, y + h, GR_BLUE)
	_r(x + cw * 0.4, y + h - cw, x + cw * 0.6, y + h, Color.WHITE)
	_r(x, y + h - cw * 0.6, x + cw, y + h - cw * 0.4, Color.WHITE)

## The Acropolis of Athens: the rock with its walls, the Parthenon on top, eight Doric columns across the front under a
## low pediment, the honey-coloured marble partly ruined (a gap in the roof), the Erechtheion small to the left.
static func _parthenon() -> void:
	# the rock and the Cyclopean walls
	_poly([-40, 0, -34, 9, -24, 14, 26, 14, 34, 10, 40, 0], ROCK)
	_poly([-30, 10, -26, 14, 28, 14, 31, 10], STONE_D)
	_r(-26, 14, 28, 16, STONE)
	if _detail(1.0):
		_l(-36, 4, -20, 6, ROCK.darkened(0.15), 0.3)
		_l(10, 5, 34, 6, ROCK.darkened(0.15), 0.3)
		for k in 6:
			_c(-37.0 + k * 3.0, 1.5 + k * 1.2, 1.3, OLIVE)
	# the Erechtheion, low on the left
	_r(-24, 16, -14, 22, MARBLE_D)
	_poly([-25, 22, -13, 22, -19, 24], MARBLE_D)
	# the Parthenon: stylobate, eight columns, entablature, pediment
	var x0 := -12.0
	var x1 := 24.0
	_r(x0 - 1, 16, x1 + 1, 18, MARBLE)
	_r(x0, 18, x1, 29, Color("a99a7c")) # the cella in the shade behind the columns
	for k in 8:
		var x := x0 + 1.4 + k * (x1 - x0 - 2.8) / 7.0
		_r(x - 1.05, 18, x + 1.05, 29, MARBLE)
		if _detail(2.0):
			_l(x, 18.3, x, 28.7, MARBLE_D, 0.12)
		_r(x - 1.4, 28.6, x + 1.4, 29.2, MARBLE_D)
	_r(x0 - 0.5, 29.2, x1 + 0.5, 31.6, MARBLE)
	if _detail(1.5):
		for k in 14:
			var x := x0 + 0.5 + k * 2.6
			_r(x, 30.2, x + 0.5, 31.4, MARBLE_D)
	# the pediment, broken off on the right
	_poly([x0 - 0.5, 31.6, 6, 35.6, 16, 33.4, 17, 31.6], MARBLE)
	_poly([x0 + 2, 32.1, 6, 34.8, 12, 33.5, 12.5, 32.1], MARBLE_D)
	_r(18.5, 31.6, x1 + 0.5, 32.3, MARBLE_D)

## Evzones at the Tomb of the Unknown Soldier: two guards in white fustanella kilts, red caps with long black
## tassels, white stockings and red tsarouchi shoes with black pompoms, one with a raised leg in the slow march;
## their sentry boxes behind them.
static func _evzone() -> void:
	_r(-6, 0, 6, 0.4, MARBLE_D)
	for sg in [-1.0, 1.0]:
		var bx: float = sg * 3.6
		# the sentry box: a little blue-and-white striped hut
		_r(bx - 1.2, 0.4, bx + 1.2, 4.6, LIME)
		_poly([bx - 1.6, 4.6, bx + 1.6, 4.6, bx, 6], GR_BLUE)
		_r(bx - 0.8, 0.4, bx + 0.8, 3.8, Color("c9c2b2"))
	for sg in [-1.0, 1.0]:
		var x: float = sg * 1.6
		var march: bool = sg > 0
		# legs: white stockings, one raised
		_r(x - 0.35, 0.4, x - 0.1, 2.2, Color.WHITE)
		if march:
			_l(x + 0.2, 2.2, x + 0.9, 1.3, Color.WHITE, 0.25)
			_c(x + 1.0, 1.25, 0.22, Color("b3261e"))
			_c(x + 1.2, 1.25, 0.15, DARK)
		else:
			_r(x + 0.1, 0.4, x + 0.35, 2.2, Color.WHITE)
			_c(x + 0.32, 0.5, 0.18, DARK)
		_c(x - 0.12, 0.5, 0.18, DARK)
		# the fustanella: a pleated white kilt
		_poly([x - 0.4, 3.4, x + 0.4, 3.4, x + 0.85, 2.1, x - 0.85, 2.1], Color.WHITE)
		if _detail(4.0):
			for k in 5:
				_l(x - 0.6 + k * 0.3, 2.15, x - 0.3 + k * 0.15, 3.3, Color("d8d8d8"), 0.05)
		# the jacket (dark blue for parade) with a rifle on the shoulder
		_r(x - 0.4, 3.4, x + 0.4, 4.7, Color("1d2b52"))
		_l(x + 0.45, 3.3, x + 0.45, 5.6, WOOD, 0.12)
		_c(x, 5.0, 0.32, Color("e8c3a0"))
		# the red fez with its long black tassel
		_r(x - 0.3, 5.25, x + 0.3, 5.6, Color("b3261e"))
		_l(x + 0.25, 5.5, x + 0.55, 4.6, DARK, 0.08)

## The trireme Olympias: a long low warship with a bronze ram, the eye painted on the bow, three tiers of oars
## dipping into the water, a square sail on the mast and the curled sternpost.
static func _trireme() -> void:
	_sea(-22, 22, 2.0)
	# the hull
	var hull := Color("6b4a2e")
	_poly([-19, 2.6, -17, 1.4, 15, 1.4, 19, 2.2, 21.5, 1.6, 19.5, 3.2, 17.5, 5.2, -15, 5.2, -19, 4.4], hull)
	_r(-15, 4.6, 17.5, 5.2, Color("2c4a6e"))
	_poly([19, 2.2, 22, 1.8, 19.5, 2.8], Color("b0803a")) # the bronze ram
	_c(17.0, 4.0, 0.45, Color.WHITE)
	_c(17.0, 4.0, 0.22, DARK)
	# the sternpost curling up and forward
	_l(-19, 4.4, -21, 7.5, hull, 0.5)
	_l(-21, 7.5, -19.8, 9.0, hull, 0.4)
	# three tiers of oars
	for tier in 3:
		var y := 2.4 + tier * 0.8
		var n := 16
		for k in n:
			var x := -14.0 + k * 1.9 + tier * 0.4
			_l(x, y, x - 1.2 - tier * 0.3, 0.6, Color("d9c08a"), 0.12)
	# the mast and the square sail
	_l(0, 5.2, 0, 14, WOOD, 0.35)
	_poly([-5, 13.2, 5, 13.2, 4.6, 7, -4.6, 7], Color("efe3c4"))
	_l(-5.4, 13.4, 5.4, 13.4, WOOD, 0.25)
	if _detail(1.5):
		_r(-4.6, 9.6, 4.6, 10.4, Color("b3261e"))

## The White Tower of Thessaloniki: a round stone tower on the waterfront, a smaller round turret on top with
## battlements, small windows in a spiral and a Greek flag; the sea in front.
static func _white_tower() -> void:
	_r(-13, 0, 13, 1.5, Color("b8b1a0"))
	_sea(-13, -9, 1.2)
	# the main drum
	_r(-8, 1.5, 8, 26, LIME)
	_r(-8, 1.5, -6.6, 26, Color("dcd8cc"))
	_r(6.6, 1.5, 8, 26, Color("dcd8cc"))
	_r(-8.4, 26, 8.4, 27.2, Color("dcd8cc"))
	for k in 9:
		_r(-8.2 + k * 1.95, 27.2, -7.2 + k * 1.95, 28.2, Color("dcd8cc"))
	for k in 6:
		_r(-1.0 + (k % 3 - 1) * 4.0, 5.0 + k * 3.3, 0.0 + (k % 3 - 1) * 4.0, 6.6 + k * 3.3, WIN)
	_archway(0, 1.1, 1.5, 3.4, DARK)
	# the turret on top
	_r(-3.6, 28.2, 3.6, 33, LIME)
	for k in 4:
		_r(-3.6 + k * 2.1, 33, -2.6 + k * 2.1, 34, LIME)
	_r(-0.5, 29.5, 0.5, 31.2, WIN)
	_flag(1.4, 36, 3.0)

## The Rio–Antirrio bridge: four tall pylons, each splaying into four legs at the top, fans of cables holding the
## long thin deck over the strait, the mountains of Aetolia behind.
static func _rio_antirrio() -> void:
	_poly([-55, 0, -40, 9, -24, 4, -10, 11, 6, 5, 20, 10, 36, 4, 55, 7, 55, 0], Color("9aa7a6"))
	_sea(-55, 55, 3.0)
	var deck := 8.0
	# piers in the water
	for k in 4:
		var x := -36.0 + k * 24.0
		_r(x - 1.6, 1, x + 1.6, deck, Color("bfc3c4"))
	# the deck and the approach viaducts
	_r(-55, deck, 55, deck + 1.2, Color("d7d9d8"))
	_r(-55, deck + 1.2, 55, deck + 1.5, Color("ffd23f"))
	# pylons: two legs below, splayed above, cables
	var cable := Color("f6f6f2")
	for k in 4:
		var x := -36.0 + k * 24.0
		var top := 34.0
		_poly([x - 2.0, deck + 1.5, x - 0.6, top - 6, x - 1.4, top, x - 0.9, top, x, top - 7, x + 0.9, top, x + 1.4, top, x + 0.6, top - 6, x + 2.0, deck + 1.5], Color("c7cacb"))
		for j in 6:
			var reach := 2.0 + j * 1.8
			_l(x, top - 3 - j * 1.1, x - reach, deck + 1.5, cable, 0.1)
			_l(x, top - 3 - j * 1.1, x + reach, deck + 1.5, cable, 0.1)
		if _detail(2.0):
			_c(x, top + 0.3, 0.3, Color("e04030"))

## Knossos: the restored north entrance of the Minoan palace, red columns tapering downwards with black capitals,
## the charging-bull fresco on the wall behind, ochre walls and stone steps, a cypress at the side.
static func _knossos() -> void:
	_r(-30, 0, 30, 1.5, STONE_D)
	for k in 4:
		_r(-14.0 + k * 1.2, 1.5 + k * 0.6, 14.0 - k * 1.2, 2.1 + k * 0.6, STONE)
	# the back wall and the upper storey
	_r(-24, 1.5, 24, 14, Color("d8a65c"))
	_r(-24, 14, 24, 15, Color("b78a48"))
	_r(-18, 15, 6, 22, Color("d8a65c"))
	_r(-18.6, 22, 6.6, 23, Color("b78a48"))
	# the bull fresco
	_r(10, 6, 22, 12.5, Color("8fb7c9"))
	var bull := Color("a0522d")
	_poly([12, 8.5, 13, 10, 18, 10.4, 20, 11.6, 20.6, 10.6, 19.6, 9.4, 18.5, 8.2, 13, 7.8], bull)
	_l(19.8, 11.5, 21, 12.2, LIME, 0.15)
	_l(13.2, 8.0, 12.0, 6.6, bull, 0.3)
	_l(17.6, 8.2, 18.6, 6.6, bull, 0.3)
	# red columns, wider at the top: four below, two on the upper storey
	for x in [-16.0, -10.0, -4.0, 2.0]:
		_minoan_column(x, 3.9, 14.0)
	for x in [-12.0, -6.0]:
		_minoan_column(x, 15.0, 22.0)
	# a cypress
	_poly([26, 1.5, 27.2, 1.5, 27.6, 6, 26.6, 13, 25.6, 6], Color("3d5a32"))

## A Minoan column from y0 up to the lintel at y1: red, tapering downwards, a black cushion capital.
static func _minoan_column(x: float, y0: float, y1: float) -> void:
	_poly([x - 0.55, y0, x + 0.55, y0, x + 0.85, y1 - 1.2, x - 0.85, y1 - 1.2], Color("b8261c"))
	_r(x - 1.2, y1 - 1.2, x + 1.2, y1 - 0.4, DARK)
	_r(x - 1.0, y1 - 0.4, x + 1.0, y1, Color("4d3b2a"))

## The Ancient Theatre of Larissa: the curved rows of marble seats cut into the Frourio hill, the stage front with
## its doorways, a few columns, the old town's houses and the Agios Achillios church on the hill above.
static func _larisa_theatre() -> void:
	_poly([-32, 0, -28, 14, -16, 20, 16, 20, 28, 14, 32, 0], GRASS)
	# rows of seats: arcs of marble
	for k in 9:
		var ry := 3.0 + k * 1.7
		var rx := 9.0 + k * 2.4
		var col := MARBLE if k % 2 == 0 else MARBLE_D
		_l(-rx, 1.2 + k * 1.7, -rx * 0.55, 1.0 + ry, col, 0.7)
		_l(-rx * 0.55, 1.0 + ry, rx * 0.55, 1.0 + ry, col, 0.7)
		_l(rx * 0.55, 1.0 + ry, rx, 1.2 + k * 1.7, col, 0.7)
	# stairways
	if _detail(1.5):
		for x in [-12.0, 0.0, 12.0]:
			_l(x * 0.6, 3, x * 1.2, 16, STONE_D, 0.3)
	# the orchestra and the stage front
	_poly([-8, 0, 8, 0, 6, 2.5, -6, 2.5], Color("d9cdb2"))
	_r(-18, 0, 18, 3.4, MARBLE_D)
	for x in [-10.0, 0.0, 10.0]:
		_archway(x, 1.0, 0, 2.0, DARK)
	for x in [-16.0, -13.0, 13.0, 16.0]:
		_r(x - 0.35, 3.4, x + 0.35, 7.5, MARBLE)
	# the hill: a church dome and houses above
	_r(-6, 20, 4, 24, LIME)
	_poly([-6.6, 24, 4.6, 24, -1, 26.5], ROOF)
	_r(6, 20, 9, 22.5, LIME)
	_poly([5.6, 22.5, 9.4, 22.5, 7.5, 23.8], ROOF)

## The Argo in Volos harbour: the replica of the Argonauts' galley with its painted eye, a ram, a single row of
## oars and a striped square sail; the harbour's quay and Mount Pelion behind.
static func _argo() -> void:
	_poly([-18, 2, -10, 16, -2, 20, 6, 17, 18, 12, 18, 2], Color("6f8a52"))
	_sea(-18, 18, 2.4)
	var hull := Color("3f3328")
	_poly([-14, 3.2, -12, 1.6, 10, 1.6, 13, 2.6, 15.5, 2.0, 13.6, 3.8, 12, 5.4, -12, 5.4], hull)
	_r(-12, 4.8, 12, 5.4, Color("b3261e"))
	_c(11.4, 4.0, 0.42, Color.WHITE)
	_c(11.4, 4.0, 0.2, DARK)
	_l(-14, 3.2, -16, 7.0, hull, 0.45)
	_l(-16, 7.0, -14.6, 8.4, hull, 0.35)
	for k in 12:
		var x := -10.0 + k * 1.8
		_l(x, 3.4, x - 1.3, 1.0, Color("c7a46a"), 0.14)
	_l(0, 5.4, 0, 15, WOOD, 0.3)
	_poly([-4.6, 14.2, 4.6, 14.2, 4.2, 7.4, -4.2, 7.4], Color("efe3c4"))
	for k in 3:
		_r(-4.4 + k * 3.2, 7.4, -3.0 + k * 3.2, 14.2, Color("b3261e"))
	_l(-5, 14.4, 5, 14.4, WOOD, 0.22)

## Its Kale in Ioannina: the walled citadel on a promontory in Lake Pamvotis, the Fethiye mosque with its dome and
## slender minaret, Ali Pasha's tomb with its iron cage, cypresses, the lake and the mountains beyond.
static func _ioannina_kale() -> void:
	_poly([-32, 0, -24, 14, -12, 20, 0, 15, 12, 22, 24, 16, 32, 8, 32, 0], Color("8a95a0"))
	_sea(-32, 32, 3.0)
	# the walls on the promontory
	_poly([-26, 2, -22, 3.4, 22, 3.4, 26, 2, 26, 1, -26, 1], Color("6b7f4a"))
	_r(-22, 3.4, 22, 9, STONE)
	for k in 15:
		_r(-22 + k * 3.0, 9, -20.6 + k * 3.0, 10, STONE)
	_r(-22, 3.4, -18, 12, STONE_D)
	_r(18, 3.4, 22, 12, STONE_D)
	# the mosque: a block, a lead dome, the minaret
	_r(-8, 10, 6, 17, LIME)
	_poly(_arc(-1, 17, 6, 4.5, 0, PI, 10), Color("8d9399"))
	_c(-1, 21.8, 0.4, GOLD)
	_archway(-1, 1.3, 10, 13.5, WIN)
	_r(9, 10, 10.6, 29, LIME)
	_r(8.6, 25, 11, 25.8, Color("dcd8cc"))
	_poly([9, 29, 10.6, 29, 9.8, 32.5], Color("8d9399"))
	# Ali Pasha's tomb cage and cypresses
	_r(-14, 10, -10, 12.5, Color("44474d"))
	if _detail(2.0):
		for k in 5:
			_l(-13.6 + k * 0.85, 10, -13.6 + k * 0.85, 12.5, Color("8d9399"), 0.08)
	for x in [-17.0, 14.0, 16.0]:
		_poly([x - 0.8, 10, x + 0.8, 10, x + 0.2, 16.5, x - 0.2, 16.5], Color("3d5a32"))

## Chania's Venetian lighthouse: the long stone breakwater curving out into the sea, the slim tapering
## lighthouse with its gallery and lantern at the end, the harbour's sea all around and a domed mosque on the quay.
static func _chania_lighthouse() -> void:
	_sea(-25, 25, 3.0)
	# the quay on the left with the Mosque of the Janissaries
	_r(-25, 0, -12, 4, STONE)
	_r(-24, 4, -15, 9, Color("efe1c4"))
	_poly(_arc(-19.5, 9, 4, 3.6, 0, PI, 10), Color("efe1c4"))
	for x in [-22.0, -19.5, -17.0]:
		_archway(x, 0.7, 4.6, 7, Color("8a6c4a"))
	_c(-19.5, 12.8, 0.35, GOLD)
	_c(-24.2, 13.0, 1.0, Color("efe1c4"))
	# the breakwater
	_poly([-12, 2.2, 14, 2.2, 14, 3.6, -12, 3.6], STONE_D)
	if _detail(1.2):
		for k in 9:
			_l(-11.0 + k * 2.8, 2.3, -11.0 + k * 2.8, 3.5, STONE.darkened(0.25), 0.1)
	# the lighthouse: a tapering stone shaft in three stages, gallery and lantern
	var x := 16.0
	_r(x - 3.4, 2.2, x + 3.4, 5.0, STONE)
	_poly([x - 2.2, 5, x + 2.2, 5, x + 1.5, 19, x - 1.5, 19], Color("e7d6b0"))
	_r(x - 2.0, 10.4, x + 2.0, 11.0, STONE_D)
	_r(x - 1.8, 15.2, x + 1.8, 15.8, STONE_D)
	_r(x - 2.4, 19, x + 2.4, 19.8, STONE_D)
	_r(x - 1.1, 19.8, x + 1.1, 22.4, Color("ffe9a3"))
	_poly([x - 1.4, 22.4, x + 1.4, 22.4, x, 24.6], STONE_D)
	for k in 3:
		_r(x - 0.35, 7.0 + k * 4.4, x + 0.35, 8.2 + k * 4.4, WIN)
