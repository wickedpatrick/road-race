class_name LandmarksFiB
extends RefCounted
## Finnish landmarks (Lappeenranta to Inari), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const WHITE := Color("f4f2ec")
const WHITE_D := Color("dcd8cc")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const GRASS := Color("5d8f42")
const TREE := Color("2f5a33")
const PINE := Color("3b6b3a")
const GOLD := Color("e0b43a")
const COPPER := Color("5f9e86")
const BRICK := Color("a5452f")
const BRICK_D := Color("7f3424")
const STONE := Color("a8a49c")
const STONE_D := Color("8a867e")
const WATER := Color("5f8fae")
const WATER_D := Color("4c7a98")
const CONCRETE := Color("c9c6be")
const CONCRETE_D := Color("aaa69c")
const LOG := Color("7a5236")
const LOG_D := Color("5e3e28")
const SNOW := Color("eef2f5")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"fi_lappeenranta_church": _lappeenranta_church()
		"fi_hameenlinna_castle": _hameenlinna_castle()
		"fi_vaasa_replot_bridge": _vaasa_replot_bridge()
		"fi_seinajoki_lakeuden_risti": _seinajoki_lakeuden_risti()
		"fi_rovaniemi_candle_bridge": _rovaniemi_candle_bridge()
		"fi_kajaani_castle": _kajaani_castle()
		"fi_kotka_langinkoski": _kotka_langinkoski()
		"fi_savonlinna_olavinlinna": _savonlinna_olavinlinna()
		"fi_kemi_sampo": _kemi_sampo()
		"fi_inari_pielpajarvi": _inari_pielpajarvi()
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

## A spruce: a dark triangle in two tiers on a short trunk.
static func _spruce(x: float, y: float, h: float, col: Color) -> void:
	_l(x, y, x, y + h * 0.2, Color("4a3826"), h * 0.05)
	_poly([x - h * 0.28, y + h * 0.15, x + h * 0.28, y + h * 0.15, x, y + h * 0.7], col)
	_poly([x - h * 0.2, y + h * 0.45, x + h * 0.2, y + h * 0.45, x, y + h], col)

## Crenellations along the top of a wall: n merlons from x0 to x1 at height y, h high.
static func _merlons(x0: float, x1: float, y: float, h: float, n: int, col: Color) -> void:
	var step := (x1 - x0) / n
	for k in n:
		_r(x0 + step * k, y, x0 + step * (k + 0.55), y + h, col)

## An onion dome on a drum, with an Orthodox cross (a slanted foot bar) on top.
static func _onion(x: float, y: float, r: float, col: Color) -> void:
	_poly([x - r, y, x + r, y] + _arc(x, y, r, r * 1.1, 0, PI, 10), col)
	_poly([x - r * 0.55, y + r * 0.85, x + r * 0.55, y + r * 0.85, x, y + r * 2.0], col)
	var top := y + r * 2.0
	_l(x, top, x, top + r * 1.3, GOLD, r * 0.12)
	_l(x - r * 0.45, top + r * 0.9, x + r * 0.45, top + r * 0.9, GOLD, r * 0.1)
	_l(x - r * 0.3, top + r * 0.35, x + r * 0.3, top + r * 0.55, GOLD, r * 0.08)

## The Orthodox church in Lappeenranta's fortress (1785): a small pale yellow church with white corners and a green
## roof, the bell tower over the entrance with its green onion dome and cross, the fortress wall in front.
static func _lappeenranta_church() -> void:
	var yellow := Color("ecd99a")
	var green := Color("4f8a5c")
	_poly([-11, 0, 11, 0, 11, 1, -11, 1], GRASS)
	# the nave and the apse
	_r(-3, 1, 9, 9, yellow)
	_poly([-3.4, 9, 9.4, 9, 7.5, 12, -1.5, 12], green)
	_r(9, 1, 10.5, 7.5, yellow)
	_windows(-2, 8, 4, 7, 3, WIN)
	for x in [-3.0, 8.6]:
		_r(x, 1, x + 0.4, 9, WHITE)
	# the small dome over the nave
	_r(2, 12, 4.6, 13.5, yellow)
	_onion(3.3, 13.5, 1.3, green)
	# the bell tower over the entrance
	_r(-9, 1, -3, 12, yellow)
	_r(-9, 1, -8.6, 12, WHITE)
	_r(-3.4, 1, -3, 12, WHITE)
	_arched(-6, 1, 2, 3.6, Color("5b4636"))
	_r(-9.4, 12, -2.6, 12.6, WHITE)
	_r(-8, 12.6, -4, 16, yellow)
	_arched(-6, 13, 1.4, 2.4, WIN)
	_poly([-8.4, 16, -3.6, 16, -6, 17], green)
	_onion(-6, 17, 1.5, green)
	# the low stone wall of the fortress
	_r(-11, 1, 11, 2.2, STONE)
	_l(-11, 2.2, 11, 2.2, STONE_D, 0.2)

## Häme Castle in Hämeenlinna: the red-brick keep with its steep roofs and white blind arches, the grey stone base,
## the round corner towers of the outer wall and the lake in front.
static func _hameenlinna_castle() -> void:
	_r(-26, 0, 26, 2, WATER)
	_poly([-24, 2, 24, 2, 22, 4, -22, 4], GRASS)
	# the outer wall with its round towers
	_r(-22, 4, 22, 9, BRICK)
	_merlons(-22, 22, 9, 1, 14, BRICK)
	for x in [-20.0, 20.0]:
		_r(x - 2.5, 4, x + 2.5, 12, BRICK)
		_poly([x - 2.9, 12, x + 2.9, 12, x, 16], Color("4a3a32"))
	# the keep: a tall square brick block on a stone base
	_r(-12, 4, 12, 9, STONE)
	_r(-11, 9, 11, 21, BRICK)
	_r(-11, 9, -9.8, 21, BRICK_D)
	if _detail(1.0):
		for k in 6:
			_arched(-8.0 + k * 3.2, 15, 1.4, 4.0, Color("efe6d4"))
	_windows(-9, 9, 11, 13, 6, WIN)
	# the two steep roofs with the gables
	_poly([-11.6, 21, 0, 21, -5.8, 29], Color("4a3a32"))
	_poly([0, 21, 11.6, 21, 5.8, 29], Color("4a3a32"))
	_poly([-9.5, 21, -2, 21, -5.8, 27], BRICK)
	_poly([2, 21, 9.5, 21, 5.8, 27], BRICK)
	# the gate in the outer wall
	_arched(0, 4, 3, 4.6, Color("3b2a24"))

## The Replot Bridge over the Kvarken: the long low deck on piers over the sea, the two A-shaped concrete pylons
## and the fans of white stay cables to the deck.
static func _vaasa_replot_bridge() -> void:
	_r(-45, 0, 45, 3, WATER)
	_l(-45, 1.5, 45, 1.5, WATER_D, 0.2)
	var deck := 9.0
	# the piers
	for k in 9:
		var x := -40.0 + k * 10.0
		if absf(x) < 18: continue
		_r(x - 0.6, 0, x + 0.6, deck, CONCRETE_D)
	# the pylons: two A-frames reaching up from the water past the deck
	for px in [-15.0, 15.0]:
		var top := 38.0
		_poly([px - 3.2, 0, px - 2.2, 0, px - 0.2, top - 2, px - 0.6, top], CONCRETE)
		_poly([px + 2.2, 0, px + 3.2, 0, px + 0.6, top, px + 0.2, top - 2], CONCRETE)
		_r(px - 0.6, top - 6, px + 0.6, top, CONCRETE)
		_r(px - 2.6, deck - 1.4, px + 2.6, deck - 0.6, CONCRETE_D)
		# the stay cables in a fan both ways
		if _detail(0.6):
			for k in 5:
				var y := top - 1.0 - k * 1.2
				_l(px, y, px - 4.0 - k * 2.6, deck + 0.4, Color("f2f2ee"), 0.09)
				_l(px, y, px + 4.0 + k * 2.6, deck + 0.4, Color("f2f2ee"), 0.09)
	# the deck with its railings
	_r(-45, deck, 45, deck + 1.2, Color("8e8a84"))
	_r(-45, deck + 1.2, 45, deck + 1.6, WHITE_D)

## The Lakeuden Risti church in Seinäjoki (Alvar Aalto, 1960): the tall white bell tower narrowing to its top, where
## its outline forms a cross, beside the low white church with its sloping roof.
static func _seinajoki_lakeuden_risti() -> void:
	_poly([-17, 0, 17, 0, 17, 1, -17, 1], GRASS)
	# the church: a white hall with a roof rising toward the altar
	_poly([-16, 1, 4, 1, 4, 13, -16, 9], WHITE)
	_poly([-16.4, 9, 4.4, 13, 4.4, 13.8, -16.4, 9.8], Color("4a4e52"))
	_windows(-14, 2, 4, 7, 6, WIN)
	_r(-3, 1, 0, 4.5, Color("5b4636"))
	# the tower: a slab tapering upward, the cross cut out near the top
	var x := 10.0
	_poly([x - 4.5, 1, x + 4.5, 1, x + 2.2, 64, x - 2.2, 64], WHITE)
	_poly([x + 1.5, 1, x + 4.5, 1, x + 2.2, 64, x + 0.8, 64], WHITE_D)
	# the bell openings and the cross formed by the gaps at the top
	_r(x - 0.4, 48, x + 0.4, 61, Color("8fa7bd"))
	_r(x - 2.0, 56, x + 2.0, 57, Color("8fa7bd"))
	_r(x - 1.0, 40, x + 1.0, 44, WIN)
	_r(x - 1.0, 33, x + 1.0, 37, WIN)

## The Lumberjack's Candle Bridge in Rovaniemi: the deck over the Kemijoki on two concrete pylons, the stay cables
## and the flame-shaped lights burning on the top of each pylon, the snowy far bank.
static func _rovaniemi_candle_bridge() -> void:
	_r(-40, 0, 40, 3, WATER)
	_poly([-40, 3, 40, 3, 40, 4.5, -40, 4.5], SNOW)
	for x in [-36.0, -31.0, 31.0, 36.0]:
		_spruce(x, 4.5, 6.0, TREE)
	var deck := 8.0
	_r(-40, deck, 40, deck + 1.2, Color("8e8a84"))
	_r(-40, deck + 1.2, 40, deck + 1.5, WHITE_D)
	for px in [-14.0, 14.0]:
		var top := 22.0
		_r(px - 1.0, 0, px + 1.0, top, CONCRETE)
		_r(px + 0.3, 0, px + 1.0, top, CONCRETE_D)
		if _detail(0.6):
			for k in 4:
				var y := top - 1.5 - k * 1.6
				_l(px, y, px - 5.0 - k * 4.0, deck + 1.4, Color("e6e6e2"), 0.08)
				_l(px, y, px + 5.0 + k * 4.0, deck + 1.4, Color("e6e6e2"), 0.08)
		# the candle flame on top
		_r(px - 0.7, top, px + 0.7, top + 0.8, DARK)
		_poly([px - 0.8, top + 0.8, px + 0.8, top + 0.8, px + 0.4, top + 2.6, px, top + 3.8, px - 0.4, top + 2.6], Color("f2a03a"))
		_poly([px - 0.35, top + 0.9, px + 0.35, top + 0.9, px, top + 2.8], Color("ffe48a"))

## The Kajaani Castle ruins: low grey stone walls and the stump of a round tower on an islet in the river, with the
## road bridge passing over them.
static func _kajaani_castle() -> void:
	_r(-22, 0, 22, 2.5, WATER)
	for k in 6:
		_c(-18.0 + k * 7.0, 2.2, 0.5, Color("e8f2f4"))
	# the islet and the ruined walls
	_poly([-14, 2, 14, 2, 12, 3.4, -12, 3.4], Color("6f7a5a"))
	_poly([-12, 3.4, -4, 3.4, -4, 7.5, -6, 8.2, -9, 7.0, -12, 7.8], STONE)
	_poly([2, 3.4, 12, 3.4, 12, 6.8, 9, 7.6, 6, 6.4, 2, 7.2], STONE)
	_r(-3, 3.4, 1, 5.5, STONE_D)
	# the round tower stump
	_r(-10, 3.4, -6, 10, STONE_D)
	_poly([-10, 10, -9, 10.8, -8, 10.2, -7, 11, -6, 10], STONE_D)
	_windows(4, 11, 4.5, 5.6, 3, Color("3d3a36"))
	# the bridge over it on two piers
	_r(-22, 9.5, 22, 10.8, CONCRETE)
	_r(-22, 10.8, 22, 11.3, WHITE_D)
	for x in [-16.0, 16.0]:
		_r(x - 0.8, 0, x + 0.8, 9.5, CONCRETE_D)

## The imperial fishing lodge at Langinkoski: the two-storey brown log house with white window frames, a steep roof
## and a glazed veranda, spruces round it and the white water of the rapids in front.
static func _kotka_langinkoski() -> void:
	_r(-16, 0, 16, 2.2, WATER)
	for k in 9:
		_c(-15.0 + k * 3.7, 1.8, 0.7, Color("e8f2f4"))
	_poly([-16, 2.2, 16, 2.2, 16, 3, -16, 3], GRASS)
	for x in [-14.0, -11.5, 12.0, 14.5]:
		_spruce(x, 3, 9.0, TREE)
	# the house
	_r(-8, 3, 7, 11, LOG)
	if _detail(1.2):
		for k in 9:
			_l(-8, 3.8 + k * 0.85, 7, 3.8 + k * 0.85, LOG_D, 0.08)
	for x in [-6.0, -3.0, 0.0, 3.0]:
		_r(x - 0.6, 4.5, x + 0.6, 6.4, WHITE)
		_r(x - 0.4, 4.7, x + 0.4, 6.2, WIN)
		_r(x - 0.6, 8.0, x + 0.6, 9.8, WHITE)
		_r(x - 0.4, 8.2, x + 0.4, 9.6, WIN)
	# the veranda on the right
	_r(4.5, 3, 7.5, 7.5, WHITE)
	_windows(4.6, 7.4, 4, 7, 2, Color("8fa7bd"))
	# the roof with a gable
	_poly([-8.8, 11, 7.8, 11, 6, 14.5, -7, 14.5], Color("5a4c44"))
	_poly([-3.5, 11, 1.5, 11, -1, 15], LOG)
	_r(-1.4, 12, -0.6, 13.2, WHITE)

## Olavinlinna in Savonlinna: the grey stone castle on its rock in the strait, three round towers with conical
## roofs, the curtain walls between them and the water all round.
static func _savonlinna_olavinlinna() -> void:
	_r(-32, 0, 32, 2.5, WATER)
	_l(-32, 1.3, 32, 1.3, WATER_D, 0.2)
	_poly([-28, 2.5, 28, 2.5, 25, 5, -25, 5], Color("7d7a70"))
	# the curtain walls
	_r(-24, 5, 24, 13, STONE)
	_r(-24, 5, 24, 6, STONE_D)
	_windows(-20, 20, 9, 10.5, 8, Color("3d3a36"))
	# the buildings inside, with red roofs
	_r(-6, 13, 10, 16, STONE)
	_poly([-6.4, 16, 10.4, 16, 8.5, 19, -4.5, 19], Color("8a4434"))
	# the three round towers
	for t in [[-20.0, 4.0, 24.0], [-1.0, 3.6, 28.0], [19.0, 4.4, 26.0]]:
		var x: float = t[0]
		var r: float = t[1]
		var top: float = t[2]
		_r(x - r, 5, x + r, top, STONE)
		_r(x - r, 5, x - r + 1.0, top, STONE_D)
		_r(x + r - 0.8, 5, x + r, top, Color("bab6ae"))
		_r(x - 0.4, top - 6, x + 0.4, top - 4.5, Color("3d3a36"))
		_r(x - r - 0.3, top - 0.6, x + r + 0.3, top, STONE_D)
		_poly([x - r - 0.4, top, x + r + 0.4, top, x, top + r * 1.4], Color("4b4a46"))

## The icebreaker Sampo at its quay in Kemi: the black hull with the red waterline and the raked ice bow, the white
## superstructure with the bridge windows, the yellow funnel and the masts, ice on the water.
static func _kemi_sampo() -> void:
	_r(-25, 0, 25, 2, Color("cfdbe2"))
	for k in 8:
		_poly([-24.0 + k * 6.2, 2, -21.5 + k * 6.2, 2, -22.5 + k * 6.2, 2.6], SNOW)
	# the hull
	_poly([-21, 1.2, 17, 1.2, 23, 7, -22, 7], Color("23262a"))
	_poly([-21, 1.2, 17, 1.2, 17.8, 2.0, -21.2, 2.0], Color("a8322b"))
	_r(-22, 7, 23, 7.5, WHITE_D)
	# the superstructure
	_r(-12, 7.5, 8, 11.5, WHITE)
	_windows(-11, 7, 8.6, 10, 9, WIN)
	_r(-6, 11.5, 6, 14.5, WHITE)
	_r(-5.5, 12.6, 5.5, 13.8, WIN)
	_r(-6.4, 14.5, 6.4, 15.0, WHITE_D)
	# the funnel and the masts
	_poly([-11, 11.5, -6.5, 11.5, -7, 17, -10.2, 17], Color("e8b93a"))
	_r(-10.3, 16.2, -7, 17, DARK)
	_l(3, 15, 3, 21, DARK, 0.2)
	_l(1.5, 19.5, 4.5, 19.5, DARK, 0.15)
	_l(17, 7.5, 17, 12, DARK, 0.15)
	_l(-18, 7.5, -18, 11, DARK, 0.15)

## The Pielpajärvi wilderness church near Inari: a small grey-brown log church with a steep shingle roof and a tiny
## bell turret, pines and snow round it, and a reindeer in front.
static func _inari_pielpajarvi() -> void:
	_r(-14, 0, 14, 1.5, SNOW)
	for p in [[-12.5, 10.0], [-10.0, 8.0], [11.0, 9.0], [13.0, 11.0]]:
		_spruce(p[0], 1, p[1], PINE)
	var wood := Color("8a6a4c")
	var wood_d := Color("6c513a")
	# the church
	_r(-6, 1.5, 6, 7, wood)
	if _detail(1.2):
		for k in 6:
			_l(-6, 2.3 + k * 0.8, 6, 2.3 + k * 0.8, wood_d, 0.07)
	_r(-1, 1.5, 1, 4.6, Color("4a3626"))
	for x in [-4.0, 4.0]:
		_r(x - 0.5, 4, x + 0.5, 5.6, WIN)
	_poly([-7, 7, 7, 7, 0, 12.5], Color("5c4a3a"))
	_poly([-6.6, 7.3, 6.6, 7.3, 6.0, 7.8, -6.0, 7.8], SNOW)
	# the bell turret on the ridge
	_r(2.6, 9.5, 3.6, 11.8, wood_d)
	_poly([2.3, 11.8, 3.9, 11.8, 3.1, 13.4], Color("5c4a3a"))
	_l(3.1, 13.4, 3.1, 14.2, DARK, 0.1)
	# a reindeer in front: body, legs, neck and head, antlers
	var fur := Color("6f5a48")
	var rx := -9.5
	_r(rx - 1.5, 1.6, rx + 1.3, 2.9, fur)
	for lx in [rx - 1.2, rx - 0.6, rx + 0.5, rx + 1.0]:
		_l(lx, 0.4, lx, 1.8, fur, 0.18)
	_poly([rx + 0.9, 2.5, rx + 1.5, 2.5, rx + 2.1, 3.7, rx + 1.6, 3.9], fur)
	_poly([rx + 1.6, 3.5, rx + 2.6, 3.5, rx + 2.6, 3.9, rx + 1.8, 4.0], fur)
	_r(rx - 1.1, 1.6, rx + 0.9, 1.9, Color("e9e2d4"))
	_l(rx + 1.9, 3.9, rx + 1.3, 5.2, Color("8a7258"), 0.1)
	_l(rx + 1.6, 4.6, rx + 0.9, 4.9, Color("8a7258"), 0.08)
	_l(rx + 2.1, 3.9, rx + 2.6, 5.1, Color("8a7258"), 0.1)
	_l(rx + 2.4, 4.6, rx + 3.0, 4.8, Color("8a7258"), 0.08)
