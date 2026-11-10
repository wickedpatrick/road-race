class_name LandmarksFrB
extends RefCounted
## French landmarks (Reims to Annecy), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const WHITE := Color("f1ede2")
const CREAM := Color("e3d6b8")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const GOLD := Color("e0b43a")
const SLATE := Color("4f5866")
const WATER := Color("5b88b0")
const GRASS := Color("5d8f42")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"fr_reims_cathedral": _reims_cathedral()
		"fr_dijon_palais": _dijon_palais()
		"fr_grenoble_bulles": _grenoble_bulles()
		"fr_clermont_cathedral": _clermont_cathedral()
		"fr_brest_recouvrance": _brest_recouvrance()
		"fr_tours_cathedral": _tours_cathedral()
		"fr_limoges_gare": _limoges_gare()
		"fr_perpignan_castillet": _perpignan_castillet()
		"fr_orleans_jeanne": _orleans_jeanne()
		"fr_rouen_gros_horloge": _rouen_gros_horloge()
		"fr_caen_abbaye": _caen_abbaye()
		"fr_avignon_pont": _avignon_pont()
		"fr_metz_pompidou": _metz_pompidou()
		"fr_poitiers_notre_dame": _poitiers_notre_dame()
		"fr_nimes_maison_carree": _nimes_maison_carree()
		"fr_toulon_tour_royale": _toulon_tour_royale()
		"fr_le_havre_saint_joseph": _le_havre_saint_joseph()
		"fr_amiens_cathedral": _amiens_cathedral()
		"fr_annecy_palais_ile": _annecy_palais_ile()
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

## A pointed (Gothic) opening.
static func _lancet(x: float, y0: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.5, y0, x + w * 0.5, y0, x + w * 0.5, y0 + h - w * 0.8, x, y0 + h, x - w * 0.5, y0 + h - w * 0.8], col)

## Reims Cathedral (13th century): the coronation church's west front of pale limestone, three deep portals
## under pointed gables, the great rose window, the gallery of kings and two flat-topped towers.
static func _reims_cathedral() -> void:
	var stone := Color("d9d0bc")
	var stone_d := Color("b5ab95")
	_r(-24, 0, 24, 40, stone)
	for x in [-16.0, 0.0, 16.0]:
		var w := 11.0 if x == 0.0 else 8.0
		_lancet(x, 0, w, 15 if x == 0.0 else 12, DARK)
		_poly([x - w * 0.6, 12 if x != 0.0 else 15, x + w * 0.6, 12 if x != 0.0 else 15, x, 22 if x != 0.0 else 25], stone_d)
	_c(0, 31, 6, stone_d)
	_c(0, 31, 4.6, Color("4a5a7a"))
	_r(-24, 40, 24, 44, stone_d) # the gallery of kings
	if _detail(1.0):
		for k in 15:
			_r(-22.5 + k * 3.1, 40.6, -21.5 + k * 3.1, 43.2, stone)
	for x in [-24.0, 10.0]:
		_r(x, 44, x + 14, 66, stone)
		_lancet(x + 4, 48, 2.6, 14, DARK)
		_lancet(x + 10, 48, 2.6, 14, DARK)
		_r(x - 0.5, 66, x + 14.5, 67.5, stone_d)
	_r(-10, 44, 10, 50, stone)
	_poly([-10, 50, 10, 50, 0, 57], SLATE)

## The Palace of the Dukes of Burgundy in Dijon: the classical wings around the courtyard with the 15th-century
## Tower of Philip the Good (46 m) rising behind, and a roof of the Burgundian glazed tiles in coloured lozenges.
static func _dijon_palais() -> void:
	var stone := Color("e2d5b5")
	# the tower
	_r(6, 0, 16, 42, Color("cdbd98"))
	for k in 4:
		_r(9.5, 8 + k * 8, 12.5, 12 + k * 8, WIN)
	_r(5.4, 42, 16.6, 44, stone)
	for k in 5:
		_r(5.4 + k * 2.4, 44, 6.6 + k * 2.4, 46, stone)
	# the palace front with the glazed roof
	_r(-25, 0, 6, 16, stone)
	_windows(-24, 5, 3, 7, 7, WIN)
	_windows(-24, 5, 9.5, 13.5, 7, WIN)
	_poly([-25.5, 16, 6.5, 16, 4, 24, -23, 24], Color("7a3b2a"))
	if _detail(0.8):
		var cols := [Color("d4a72c"), Color("2f6b45"), Color("1f1f1f")]
		for row in 3:
			for k in 9:
				var x := -22.0 + k * 3.2 + row * 1.6
				var y := 17.6 + row * 2.2
				_poly([x, y, x + 1.1, y + 1, x, y + 2, x - 1.1, y + 1], cols[(k + row) % 3])
	_r(16, 0, 25, 14, stone)
	_windows(16.5, 24.5, 4, 10, 3, WIN)
	_poly([15.5, 14, 25.5, 14, 23.5, 19, 17.5, 19], SLATE)

## The Bastille cable car in Grenoble (1934): the round "bubble" cabins on their cables between the town on the
## Isère and the fort on the rock above.
static func _grenoble_bulles() -> void:
	var rock := Color("8e8a7c")
	_r(-30, 0, 30, 2, WATER)
	_poly([10, 2, 30, 2, 30, 30, 22, 34, 16, 26], rock)
	_poly([19, 30, 30, 30, 30, 36, 19, 36], Color("9b8f72")) # the fort
	for k in 4:
		_r(19 + k * 3.3, 36, 20.6 + k * 3.3, 37.4, Color("9b8f72"))
	_r(-30, 2, -20, 10, CREAM) # the lower station
	_r(-30.4, 10, -19.6, 11, SLATE)
	_l(-22, 9, 20, 32, DARK, 0.18)
	_l(-22, 8, 20, 31, DARK, 0.12)
	var cols := [Color("d9e3ea"), Color("e7c84a"), Color("d9e3ea"), Color("d9e3ea"), Color("e7c84a")]
	for k in 5:
		var t := 0.12 + k * 0.17
		var x := -22.0 + 42.0 * t
		var y := 9.0 + 23.0 * t
		_l(x, y, x, y - 2.0, DARK, 0.12)
		_c(x, y - 3.4, 1.7, cols[k])
		_c(x - 0.5, y - 3.1, 0.7, Color("6b8aa3"))

## Clermont-Ferrand Cathedral: Gothic in nearly black Volvic lava stone, the west front with the two spires added
## by Viollet-le-Duc in the 19th century.
static func _clermont_cathedral() -> void:
	var lava := Color("3f3c3a")
	var lava_l := Color("5a5653")
	_r(-18, 0, 18, 34, lava)
	_lancet(0, 0, 7, 13, Color("1d1c1b"))
	_lancet(-11, 0, 5, 10, Color("1d1c1b"))
	_lancet(11, 0, 5, 10, Color("1d1c1b"))
	_c(0, 23, 5, lava_l)
	_c(0, 23, 3.6, Color("6a4a7a"))
	_poly([-8, 34, 8, 34, 0, 41], lava_l)
	for x in [-18.0, 8.0]:
		_r(x, 34, x + 10, 50, lava)
		_lancet(x + 5, 38, 3, 9, Color("1d1c1b"))
		_poly([x, 50, x + 10, 50, x + 5, 78], lava_l)
		if _detail(1.0):
			_l(x + 2, 50, x + 5, 74, lava, 0.25)
			_l(x + 8, 50, x + 5, 74, lava, 0.25)

## The Recouvrance Bridge in Brest (1954): a vertical-lift bridge over the mouth of the Penfeld, the steel deck
## hanging from cables between two tall concrete towers with the counterweights inside.
static func _brest_recouvrance() -> void:
	var concrete := Color("c4c0b6")
	var steel := Color("3d6b7a")
	_r(-45, 0, 45, 6, WATER)
	for x in [-33.0, 25.0]:
		_r(x, 0, x + 8, 64, concrete)
		_r(x + 2.5, 8, x + 5.5, 58, Color("9e9a90"))
		_r(x - 0.5, 62, x + 8.5, 64, Color("a8a49a"))
	_r(-45, 12, -33, 14, steel)
	_r(33, 12, 45, 14, steel)
	_r(-25, 12, 25, 14.5, steel)
	if _detail(0.8):
		for k in 9:
			var x := -24.0 + k * 6.0
			_l(x, 14.5, x + 3, 12, Color("2b4f5a"), 0.2)
		_l(-29, 62, -24, 14.5, DARK, 0.15)
		_l(29, 62, 24, 14.5, DARK, 0.15)
	_r(-45, 14, 45, 14.4, Color("a8a49a"))

## Saint-Gatien Cathedral in Tours: a Flamboyant Gothic west front with three portals and a rose, and two towers
## crowned by small Renaissance domes and lanterns.
static func _tours_cathedral() -> void:
	var stone := Color("e4dcc8")
	var stone_d := Color("c2b8a0")
	_r(-12, 0, 12, 34, stone)
	_lancet(0, 0, 7, 16, DARK)
	_poly([-5, 16, 5, 16, 0, 26], stone_d)
	_c(0, 28, 3.6, Color("4a5a7a"))
	for x in [-20.0, 12.0]:
		_r(x, 0, x + 8, 48, stone)
		_lancet(x + 4, 0, 4, 9, DARK)
		_lancet(x + 4, 30, 2.4, 10, DARK)
		_r(x + 0.5, 48, x + 7.5, 52, stone_d)
		_poly([x + 0.5, 52] + _arc(x + 4, 52, 3.5, 4, PI, 0, 8) + [x + 7.5, 52], SLATE)
		_r(x + 3.2, 56, x + 4.8, 59, stone)
		_poly([x + 3, 59, x + 5, 59, x + 4, 62], SLATE)
	if _detail(1.0):
		for x in [-9.0, -5.0, 5.0, 9.0]:
			_lancet(x, 18, 1.6, 12, stone_d)

## Limoges-Bénédictins station (1929): the station hall with its copper dome over the tracks and the slender
## 67 m clock tower at its corner.
static func _limoges_gare() -> void:
	var stone := Color("e8dfc8")
	var copper := Color("4f9c84")
	_r(-30, 0, 10, 16, stone)
	_arched(-10, 0, 14, 16, Color("4f6b80"))
	_windows(-29, -18, 4, 12, 3, WIN)
	_windows(-2, 9, 4, 12, 3, WIN)
	_poly([-24, 16] + _arc(-10, 16, 14, 13, PI, 0, 14) + [4, 16], copper)
	_l(-10, 29, -10, 32, copper, 0.6)
	# the clock tower
	_r(12, 0, 19, 46, stone)
	_r(11.5, 46, 19.5, 48, CREAM)
	_c(15.5, 42, 2.4, WHITE)
	_c(15.5, 42, 2.0, Color("2a3a4a"))
	_r(12.5, 48, 18.5, 52, stone)
	_poly([12, 52] + _arc(15.5, 52, 3.5, 5, PI, 0, 8) + [19, 52], copper)
	_l(15.5, 57, 15.5, 60, copper, 0.4)
	_r(19, 0, 30, 12, stone)
	_windows(20, 29, 4, 9, 3, WIN)

## Le Castillet in Perpignan (14th century): a brick gate tower with stepped crenellations and machicolations,
## the narrower lookout turret on top.
static func _perpignan_castillet() -> void:
	var brick := Color("b5553a")
	var brick_d := Color("8f412c")
	_r(-12, 0, 10, 20, brick)
	_arched(-1, 0, 5, 7, DARK)
	_windows(-11, 9, 11, 14, 4, Color("3a2a22"))
	_r(-12.6, 20, 10.6, 21.4, brick_d)
	for k in 8:
		_r(-12.6 + k * 3.0, 21.4, -11.2 + k * 3.0, 23, brick)
	_r(-5, 21.4, 4, 26, brick)
	for k in 4:
		_r(-5 + k * 2.4, 26, -3.8 + k * 2.4, 27.6, brick)
	_r(10, 0, 13, 16, brick_d)

## Joan of Arc on the Place du Martroi in Orléans (1855): the bronze rider on her horse, sword raised, on a tall
## stone pedestal.
static func _orleans_jeanne() -> void:
	var bronze := Color("4a5a4c")
	_r(-4, 0, 4, 5.5, CREAM)
	_r(-4.4, 5.5, 4.4, 6, WHITE)
	# the horse
	_poly([-3, 7.6, 2, 7.6, 3, 8.6, 2.5, 9.6, -2.6, 9.4], bronze)
	_poly([2, 9, 3.6, 10.6, 4.2, 10.2, 3.6, 9.2, 2.8, 8.4], bronze)
	for x in [-2.4, -1.4, 1.0, 1.8]:
		_l(x, 6, x, 7.8, bronze, 0.3)
	_l(-3, 9, -3.8, 7.6, bronze, 0.3)
	# the rider
	_r(-0.6, 9.4, 0.6, 11.4, bronze)
	_c(0, 11.9, 0.45, bronze)
	_l(0.4, 10.9, 1.8, 12.8, bronze, 0.22)
	_l(1.8, 12.8, 0.6, 13.0, bronze, 0.12)

## The Gros-Horloge in Rouen: a Renaissance arch over the Rue du Gros-Horloge with the gilded one-hand clock face
## on a blue starry ground, beside the Gothic belfry.
static func _rouen_gros_horloge() -> void:
	var stone := Color("d8cfba")
	_r(-12, 0, -2, 18, Color("cfc5ad")) # the belfry
	_poly([-12.4, 18, -1.6, 18, -7, 20], SLATE)
	_r(-2, 0, 10, 14, stone)
	_arched(4, 0, 7, 9, Color("6d7f8e"))
	_r(-1, 9.5, 9, 14, stone)
	_c(4, 11.5, 2.6, GOLD)
	_c(4, 11.5, 2.1, Color("1f3a7a"))
	_l(4, 11.5, 5.2, 12.8, GOLD, 0.25)
	_poly([-2.4, 14, 10.4, 14, 4, 17], SLATE)
	_r(10, 0, 12, 12, Color("c4b89c"))

## The Abbaye aux Hommes in Caen: the Romanesque abbey church of Saint-Étienne founded by William the Conqueror,
## its plain west front between two tall towers with Gothic spires.
static func _caen_abbaye() -> void:
	var stone := Color("e6dcc2")
	var stone_d := Color("c7bc9f")
	_r(-10, 0, 10, 30, stone)
	_arched(0, 0, 4, 7, DARK)
	for k in 2:
		_arched(-4, 12 + k * 8, 2.2, 5, WIN)
		_arched(0, 12 + k * 8, 2.2, 5, WIN)
		_arched(4, 12 + k * 8, 2.2, 5, WIN)
	_poly([-10, 30, 10, 30, 0, 35], stone_d)
	for x in [-18.0, 10.0]:
		_r(x, 0, x + 8, 44, stone)
		for k in 3:
			_arched(x + 4, 18 + k * 8, 2, 5, WIN)
		_r(x - 0.4, 44, x + 8.4, 45.5, stone_d)
		_poly([x + 0.5, 45.5, x + 7.5, 45.5, x + 4, 70], stone_d)
		_poly([x - 0.2, 45.5, x + 1.8, 45.5, x + 0.8, 51], stone_d)
		_poly([x + 6.2, 45.5, x + 8.2, 45.5, x + 7.2, 51], stone_d)

## The Pont Saint-Bénézet in Avignon (12th century): four arches left of the bridge over the Rhône, ending in
## mid-river, with the little Chapel of Saint Nicholas on a pier.
static func _avignon_pont() -> void:
	var stone := Color("d6c8a6")
	var stone_d := Color("b3a37f")
	_r(-40, 0, 40, 3, WATER)
	_r(-40, 0, -32, 12, stone) # the bank
	var xs := [-32.0, -16.0, 0.0, 16.0]
	var top := 10.0
	_r(-32, top - 2.5, 30, top, stone)
	for k in xs.size():
		var x: float = xs[k]
		_poly([x + 1, 0, x + 1, 4] + _arc(x + 8, 4, 7, 4.5, PI, 0, 10) + [x + 15, 4, x + 15, 0, x + 17, 0, x + 17, top - 2.5, x - 1, top - 2.5, x - 1, 0], stone)
		_r(x + 15, 0, x + 17, top - 2.5, stone_d)
	_r(28, 0, 30, top, stone_d) # the broken end
	# the chapel on the second pier
	_r(-19, top, -11, 14.5, stone)
	_poly([-19.5, 14.5, -10.5, 14.5, -15, 16.5], stone_d)
	_r(-14, 14, -12.5, 17.5, stone)
	_arched(-15, top, 1.6, 2.6, DARK)

## The Centre Pompidou-Metz (2010): a white hexagonal roof of woven timber billowing like a Chinese hat over
## three long gallery tubes that poke out of it, and the 77 m spire rising through the middle.
static func _metz_pompidou() -> void:
	var membrane := Color("f4f1ea")
	var shade := Color("d9d4c8")
	var glass := Color("8fa5b5")
	_r(-45, 0, 45, 1.2, Color("9a9a92")) # the forecourt
	# the gallery tubes under the roof, their glass ends facing the town
	_r(-30, 10, 14, 17, Color("dedad2"))
	_r(-36, 10, -30, 17, glass)
	_r(-8, 18, 40, 24, Color("dedad2"))
	_r(40, 18, 45, 24, glass)
	_r(-26, 24, 18, 30, Color("dedad2"))
	_r(-31, 24, -26, 30, glass)
	# the wavy roof: low at the edges, lifted in the middle
	_poly([-44, 4, -36, 9, -24, 15] + _arc(0, 15, 24, 14, PI, 0, 14) + [24, 15, 36, 9, 44, 4, 36, 7, 24, 12, 0, 18, -24, 12, -36, 7], membrane)
	if _detail(1.5):
		for k in 9:
			var x := -32.0 + k * 8.0
			_l(x - 4, 9 + absf(x) * -0.05 + 4, x + 4, 9 + 8, shade, 0.15)
	_r(-1, 10, 1, 77, Color("e9e5dc")) # the spire
	_r(-0.4, 30, 0.4, 77, shade)
	_r(-14, 0, 14, 10, glass) # the glazed hall under the roof
	for k in 6:
		_r(-13 + k * 5, 0, -12.6 + k * 5, 10, shade)

## Notre-Dame-la-Grande in Poitiers (12th century): the Romanesque west front crowded with carved arcades, a big
## arched door, and the two round corner turrets capped with scaly pine-cone roofs.
static func _poitiers_notre_dame() -> void:
	var stone := Color("dccca6")
	var stone_d := Color("bba984")
	_r(-12, 0, 12, 20, stone)
	_poly([-12, 20, 12, 20, 0, 27], stone) # the gable
	_c(0, 22.5, 1.6, stone_d) # the mandorla with Christ
	_arched(0, 0, 6, 9, DARK)
	_arched(-7.5, 0, 3, 6.5, stone_d)
	_arched(7.5, 0, 3, 6.5, stone_d)
	for k in 5:
		_arched(-8 + k * 4, 11, 2.6, 4.5, stone_d)
	_r(-12, 10, 12, 10.6, stone_d)
	_r(-12, 16, 12, 16.5, stone_d)
	for x in [-14.5, 14.5]:
		_r(x - 2.5, 0, x + 2.5, 22, stone)
		for k in 3:
			_arched(x, 8 + k * 4.5, 1.2, 3, stone_d)
		_r(x - 2.8, 22, x + 2.8, 23, stone_d)
		_poly([x - 2.6, 23, x + 2.6, 23, x + 1.6, 28, x, 31, x - 1.6, 28], stone)
		if _detail(1.0):
			for k in 3:
				_l(x - 2.2 + k * 0.3, 24 + k * 2, x + 2.2 - k * 0.3, 24 + k * 2, stone_d, 0.15)

## The Maison Carrée in Nîmes (around 2 AD): a Roman temple on a high podium, steps up to a porch of six Corinthian
## columns under a low pediment.
static func _nimes_maison_carree() -> void:
	var stone := Color("e4d8bc")
	var stone_d := Color("c2b48f")
	_r(-8, 0, 8, 3.2, stone_d) # the podium
	for k in 6:
		_r(-4 + k * 0.3, 3.2 - k * 0.5, 4 - k * 0.3, 3.7 - k * 0.5, stone)
	_r(-7.5, 3.2, 7.5, 4, stone)
	_r(-6.8, 4, 6.8, 12.5, Color("8a7d64")) # the shade of the porch
	for k in 6:
		var x := -6.2 + k * 2.48
		_r(x - 0.5, 4, x + 0.5, 12, stone)
		_r(x - 0.75, 11.6, x + 0.75, 12.5, stone_d)
	_r(-7.5, 12.5, 7.5, 14.2, stone) # the entablature
	_r(-7.5, 13.2, 7.5, 13.5, stone_d)
	_poly([-7.8, 14.2, 7.8, 14.2, 0, 17], stone)
	_poly([-6.3, 14.6, 6.3, 14.6, 0, 16.4], stone_d)

## The Tour Royale in Toulon (1524): a squat round artillery tower with 7 m walls at the mouth of the roadstead, a
## low parapet with gun ports, on the rocks by the sea.
static func _toulon_tour_royale() -> void:
	var stone := Color("d9cba8")
	var stone_d := Color("b5a47c")
	_r(-30, 0, 30, 2, WATER)
	_poly([-30, 2, -22, 4, -12, 3, 12, 3, 22, 4, 30, 2], Color("8f8676")) # the rocks
	_poly([-22, 3, 22, 3, 20, 16, -20, 16], stone) # the battered round wall
	_r(-20.5, 16, 20.5, 17, stone_d)
	_r(-19, 17, 19, 20, stone)
	for k in 6:
		_r(-15 + k * 6, 17.6, -13.6 + k * 6, 19.2, DARK) # gun ports
	for k in 7:
		_l(-18 + k * 6, 3, -17 + k * 5.7, 16, stone_d, 0.2)
	_r(-1, 20, 1, 22, stone_d) # the flagstaff base
	_l(0, 22, 0, 26, DARK, 0.15)
	_poly([0, 26, 3, 25.2, 0, 24.4], Color("2850a0"))

## The Church of St Joseph in Le Havre (Auguste Perret, 1957): a square concrete base and the 107 m octagonal
## lantern tower above it, its walls pierced by thousands of small coloured panes.
static func _le_havre_saint_joseph() -> void:
	var concrete := Color("cfcabd")
	var concrete_d := Color("a8a294")
	_r(-22, 0, 22, 18, concrete)
	for k in 8:
		_r(-20 + k * 5.2, 3, -17 + k * 5.2, 15, concrete_d)
	_arched(0, 0, 5, 7, DARK)
	_r(-8, 18, 8, 30, concrete)
	_poly([-8, 30, 8, 30, 6.5, 100, -6.5, 100], concrete) # the tapering lantern
	var cols := [Color("e0b43a"), Color("c8462b"), Color("3a6fb0"), Color("4c9a5a")]
	if _detail(0.6):
		for k in 14:
			var y := 33.0 + k * 4.7
			var w := 7.4 - k * 0.07
			for j in 4:
				_r(-w + j * w * 0.5 + 0.4, y, -w + j * w * 0.5 + w * 0.5 - 0.4, y + 3.6, cols[(k + j) % 4])
	else:
		_r(-6, 32, 6, 97, Color("c9a65a"))
	_poly([-6.5, 100, 6.5, 100, 0, 107], concrete_d)

## Notre-Dame d'Amiens (from 1220): France's largest Gothic cathedral, the west front with three deep portals, the
## rose window and two unequal towers, and the slender 112 m spire over the crossing behind.
static func _amiens_cathedral() -> void:
	var stone := Color("e0d6bf")
	var stone_d := Color("bcb093")
	_r(-28, 0, 28, 42, stone_d) # the nave behind
	_poly([-28, 42, 28, 42, 0, 50], SLATE)
	_r(-1, 44, 1, 80, Color("6b7380")) # the crossing spire
	_poly([-2.5, 76, 2.5, 76, 0, 112], Color("6b7380"))
	_r(-18, 0, 18, 46, stone)
	for x in [-11.0, 0.0, 11.0]:
		_lancet(x, 0, 8 if x == 0.0 else 6.5, 15, DARK)
		_poly([x - 4, 15, x + 4, 15, x, 21], stone_d)
	_r(-18, 22, 18, 23, stone_d)
	for k in 9:
		_lancet(-14 + k * 3.5, 24, 1.6, 5, WIN) # the gallery of kings
	_c(0, 36, 6, stone_d)
	_c(0, 36, 5, WIN)
	if _detail(1.0):
		for k in 8:
			var a := k * PI / 4.0
			_l(0, 36, cos(a) * 5, 36 + sin(a) * 5, stone_d, 0.3)
	_r(-18, 46, -8, 62, stone) # the south tower (left), the taller
	_r(8, 46, 18, 58, stone)
	_lancet(-13, 48, 3, 11, WIN)
	_lancet(13, 47, 3, 9, WIN)
	_r(-18.5, 61, -7.5, 62.5, stone_d)
	_r(7.5, 57, 18.5, 58.5, stone_d)

## The Palais de l'Île in Annecy (12th century): a stone house on an islet in the Thiou canal, its pointed end
## cutting the water like a ship's bow, with a little turret, between the quays.
static func _annecy_palais_ile() -> void:
	var wall := Color("ddd2bb")
	var wall_d := Color("b9ab8c")
	var roof := Color("6c5446")
	_r(-18, 0, 18, 2.5, WATER)
	_r(-18, 2.5, -12, 5, Color("a59d8c")) # the quays
	_r(12, 2.5, 18, 5, Color("a59d8c"))
	_poly([-10, 2.5, 6, 2.5, 10, 6, 10, 2.5, 6, 2.5], wall_d) # the islet's stone base
	_poly([-10, 2.5, 6, 2.5, 11, 8, 11, 12, 6, 12, -10, 12], wall) # the bow-shaped house
	_poly([-10.5, 12, 6.5, 12, 11.5, 12, 8, 15.5, -7, 15.5], roof)
	for k in 4:
		_r(-8 + k * 3.5, 7.5, -6.6 + k * 3.5, 10, WIN)
	_arched(-3, 2.5, 2, 3.5, DARK)
	_r(-11, 2.5, -7, 14, wall) # the turret
	_poly([-11.5, 14, -6.5, 14, -9, 18], roof)
	_r(-9.6, 10, -8.4, 12, WIN)
	if _detail(1.0):
		for k in 6:
			_c(-6 + k * 2.5, 4.5, 0.25, Color("e05a4a")) # flower boxes
