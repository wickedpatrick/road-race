class_name LandmarksByB
extends RefCounted
## Belarusian landmarks (Orša to Braslaŭ), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const WHITE := Color("f3f0e8")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const BRICK := Color("a8432c")
const BRICK_D := Color("7f3424")
const STONE := Color("9a968c")
const ROOF := Color("b0482e")
const GREEN_ROOF := Color("4f7a62")
const GRASS := Color("5d8f42")
const HILL := Color("6a9a4a")
const TREE := Color("3f6f34")
const WOOD := Color("8a6440")
const WOOD_D := Color("5e4430")
const WATER := Color("5f9ac4")
const GOLD := Color("e0b43a")
const BRONZE := Color("5d5a44")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"by_orsa_collegium": _orsa_collegium()
		"by_mazyr_castle": _mazyr_castle()
		"by_lida_castle": _lida_castle()
		"by_maladziecna_oginski": _oginski()
		"by_polack_sophia": _polack_sophia()
		"by_navahrudak_castle": _navahrudak_castle()
		"by_niasviz_palace": _niasviz_palace()
		"by_mir_castle": _mir_castle()
		"by_kamianiec_tower": _kamianiec_tower()
		"by_bialowieza_wisent": _wisent()
		"by_braslau_lakes": _braslau_lakes()
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

static func _ell(cx: float, cy: float, rx: float, ry: float, rot: float, col: Color) -> void:
	LandmarkPainter._ell(cx, cy, rx, ry, rot, col)

static func _windows(x0: float, x1: float, y0: float, y1: float, n: int, col: Color) -> void:
	LandmarkPainter._windows(x0, x1, y0, y1, n, col)

static func _arc(cx: float, cy: float, rx: float, ry: float, a0: float, a1: float, n: int) -> Array:
	return LandmarkPainter._arc_pts(cx, cy, rx, ry, a0, a1, n)

static func _detail(min_pm: float) -> bool:
	return LandmarkPainter._pm > min_pm

## An arched window or door: a rectangle under a half circle.
static func _arched(x: float, y0: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.5, y0, x + w * 0.5, y0, x + w * 0.5, y0 + h - w * 0.5] + _arc(x, y0 + h - w * 0.5, w * 0.5, w * 0.5, 0, PI, 6), col)

## A row of merlons on top of a wall from x0 to x1 at height y.
static func _merlons(x0: float, x1: float, y: float, h: float, n: int, col: Color) -> void:
	var step := (x1 - x0) / n
	for k in n:
		_r(x0 + step * k + step * 0.15, y, x0 + step * k + step * 0.65, y + h, col)

## A square tower from y0 to y1 with a tent roof up to `top`.
static func _tower(x: float, w: float, y0: float, y1: float, top: float, wall: Color, roof: Color) -> void:
	_r(x - w * 0.5, y0, x + w * 0.5, y1, wall)
	_poly([x - w * 0.5 - 0.5, y1, x + w * 0.5 + 0.5, y1, x, top], roof)

## The Jesuit Collegium in Orša: a long white 17th-century school with a red tiled roof, two rows of windows and a
## raised middle with a curved Baroque gable.
static func _orsa_collegium() -> void:
	_r(-34, 0, 34, 13, WHITE)
	_r(-34.5, 12.4, 34.5, 13.2, Color("dcd6c8"))
	_poly([-34.5, 13.2, 34.5, 13.2, 31, 19, -31, 19], ROOF)
	_windows(-33, -8, 2.5, 5.5, 9, WIN)
	_windows(-33, -8, 8, 11, 9, WIN)
	_windows(8, 33, 2.5, 5.5, 9, WIN)
	_windows(8, 33, 8, 11, 9, WIN)
	# the raised middle
	_r(-7, 0, 7, 17, WHITE)
	for x in [-6.6, -2.4, 2.4, 6.6]:
		_r(x - 0.35, 0, x + 0.35, 16.5, Color("e2dccc"))
	_arched(0, 0, 3, 6, Color("6b5040"))
	_arched(-4.5, 8, 1.4, 3.5, WIN)
	_arched(4.5, 8, 1.4, 3.5, WIN)
	_arched(0, 8, 1.6, 4.5, WIN)
	_poly([-7, 17, 7, 17, 5.5, 20, 3, 22.5, -3, 22.5, -5.5, 20], WHITE)
	_c(-6, 18, 1.2, Color("e2dccc"))
	_c(6, 18, 1.2, Color("e2dccc"))
	_c(0, 19.5, 1.2, Color("b8c2c8"))
	_poly([-3.4, 22.5, 3.4, 22.5, 0, 24.5], ROOF)
	_l(0, 24.5, 0, 26, GOLD, 0.15)
	_l(-0.5, 25.4, 0.5, 25.4, GOLD, 0.12)

## Mazyr's Castle Hill over the Pripyat: a green hill with a log palisade and the rebuilt wooden castle, its gate
## tower with a steep shingled roof in the middle.
static func _mazyr_castle() -> void:
	_poly([-23, 0, -17, 5, -9, 8.5, 9, 8.5, 17, 5, 23, 0], HILL)
	# the palisade of pointed logs
	_r(-15, 8.5, 15, 12, WOOD)
	if _detail(0.8):
		for k in 30:
			var x := -14.5 + k
			_l(x, 8.6, x, 11.9, WOOD_D, 0.08)
	for k in 30:
		var x := -15.0 + k
		_poly([x, 12, x + 1, 12, x + 0.5, 12.8], WOOD)
	# corner towers
	for x in [-14.0, 14.0]:
		_r(x - 2, 8.5, x + 2, 15, WOOD)
		_poly([x - 2.6, 15, x + 2.6, 15, x, 18.5], WOOD_D)
		_r(x - 0.5, 12.5, x + 0.5, 13.5, DARK)
	# the gate tower
	_r(-3.5, 8.5, 3.5, 19, WOOD)
	if _detail(0.8):
		for k in 9:
			_l(-3.5, 9.5 + k * 1.1, 3.5, 9.5 + k * 1.1, WOOD_D, 0.07)
	_r(-1.8, 8.5, 1.8, 12.5, Color("3a2a20"))
	_r(-4.2, 19, 4.2, 20, WOOD_D)
	_r(-3.0, 20, 3.0, 21.5, WOOD)
	_r(-1.8, 20.3, -0.6, 21.2, DARK)
	_r(0.6, 20.3, 1.8, 21.2, DARK)
	_poly([-4.4, 21.5, 4.4, 21.5, 0, 24], WOOD_D)

## Lida Castle (1320s): a long curtain wall of field stone below and red brick above, with the gate in the middle,
## a square corner tower with a tent roof on the left and the lower ruined one on the right.
static func _lida_castle() -> void:
	_r(-26, 0, 26, 5, STONE)
	if _detail(1.0):
		for k in 12:
			_c(-24.0 + k * 4.2, 2.5, 0.8, Color("85827a"))
			_c(-22.0 + k * 4.2, 1.2, 0.6, Color("aaa69c"))
	_r(-26, 5, 26, 12, BRICK)
	_merlons(-26, 26, 12, 1.0, 26, BRICK)
	for x in [-18.0, -12.0, 12.0, 18.0]:
		_arched(x, 6.5, 1.2, 3.5, Color("4a2a20"))
	# the gate
	_arched(0, 0, 4, 7, Color("2a2420"))
	_poly(_arc(0, 5, 2.6, 2.6, 0, PI, 10) + _arc(0, 5, 2.0, 2.0, PI, 0, 10), STONE)
	# the left tower, roofed
	_r(-31, 0, -21, 5, STONE)
	_r(-31, 5, -21, 18, BRICK)
	_arched(-26, 9, 1.4, 3.2, WIN)
	_arched(-26, 13.5, 1.4, 3.2, WIN)
	_poly([-31.6, 18, -20.4, 18, -26, 22], ROOF)
	# the right tower, open at the top
	_r(21, 0, 30, 5, STONE)
	_r(21, 5, 30, 14.5, BRICK)
	_poly([21, 14.5, 23, 14.5, 23.5, 16, 25, 15.2, 27, 16.4, 28.5, 15, 30, 15.5, 30, 14.5], BRICK)
	_arched(25.5, 9, 1.4, 3.2, WIN)

## The monument to Michał Kleofas Ogiński in Maladziečna: the composer in bronze in a long coat, a sheet of music in
## his hand, on a granite pedestal with a stave carved on it.
static func _oginski() -> void:
	var gr := Color("8d8a84")
	_r(-2.2, 0, 2.2, 3.2, gr)
	_r(-2.5, 3.0, 2.5, 3.4, Color("a8a49c"))
	_r(-2.5, 0, 2.5, 0.4, Color("a8a49c"))
	if _detail(2.0):
		for k in 5:
			_l(-1.6, 1.2 + k * 0.25, 1.6, 1.2 + k * 0.25, Color("d8d4c8"), 0.03)
		for n in [[-1.1, 1.45], [-0.4, 1.95], [0.3, 1.7], [1.0, 2.2]]:
			_c(n[0], n[1], 0.11, Color("d8d4c8"))
	# the figure
	_poly([-0.9, 3.4, 0.9, 3.4, 0.75, 6.6, -0.75, 6.6], BRONZE)
	_poly([-0.75, 6.6, 0.75, 6.6, 0.9, 7.2, -0.9, 7.2], BRONZE)
	_poly([-1.0, 3.4, -0.3, 3.4, -0.6, 5.4], Color("4a4836"))
	_c(0, 7.75, 0.5, BRONZE)
	_c(0.05, 8.05, 0.42, Color("4a4836"))
	# the arm with the sheet of music
	_l(0.6, 6.7, 1.3, 5.6, BRONZE, 0.28)
	_poly([1.1, 5.3, 1.9, 5.5, 1.75, 6.5, 0.95, 6.3], Color("7a7656"))
	_l(-0.6, 6.7, -0.85, 5.2, BRONZE, 0.26)

## The St Sophia Cathedral in Polack: white Baroque on the high bank of the Dvina, the east end with its two
## three-tiered towers and a curved gable between them.
static func _polack_sophia() -> void:
	_poly([-24, 0, -20, 3.5, 20, 3.5, 24, 0], HILL)
	var trim := Color("e2dccc")
	_r(-17, 3.5, 17, 20, WHITE)
	_poly([-17.5, 20, 17.5, 20, 15, 23, -15, 23], GREEN_ROOF)
	for x in [-13.0, 13.0]:
		_arched(x, 7, 2, 6.5, WIN)
	# the curved apse front between the towers
	_poly([-6, 20, 6, 20, 5, 25, 2.5, 28, -2.5, 28, -5, 25], WHITE)
	_c(-6, 21, 1.1, trim)
	_c(6, 21, 1.1, trim)
	_arched(0, 7, 3, 9, WIN)
	_arched(0, 21, 1.6, 4, WIN)
	_poly([-2.8, 28, 2.8, 28, 0, 30], GREEN_ROOF)
	_l(0, 30, 0, 32, GOLD, 0.15)
	# the two towers
	for x in [-10.0, 10.0]:
		_r(x - 3.5, 3.5, x + 3.5, 26, WHITE)
		for y in [11.0, 18.5]:
			_r(x - 3.8, y, x + 3.8, y + 0.7, trim)
		_arched(x, 13, 1.5, 4, WIN)
		_arched(x, 20, 1.5, 4, WIN)
		_r(x - 3.8, 26, x + 3.8, 26.8, trim)
		_r(x - 2.6, 26.8, x + 2.6, 33, WHITE)
		_arched(x, 28, 1.3, 3.5, DARK)
		_r(x - 2.9, 33, x + 2.9, 33.7, trim)
		_r(x - 1.8, 33.7, x + 1.8, 38, WHITE)
		_arched(x, 34.5, 1.0, 2.6, DARK)
		_poly(_arc(x, 38, 2.1, 2.6, 0, PI, 10), GREEN_ROOF)
		_r(x - 0.5, 40.4, x + 0.5, 42, WHITE)
		_poly([x - 0.7, 42, x + 0.7, 42, x, 46.5], GREEN_ROOF)
		_l(x, 46.5, x, 49, GOLD, 0.15)
		_l(x - 0.6, 48.2, x + 0.6, 48.2, GOLD, 0.12)

## The castle ruins of Navahrudak on Castle Hill: what is left of the tall Shchytaŭka tower and of the Church Tower,
## a scrap of wall between them, and the grassy mound raised for Mickiewicz alongside.
static func _navahrudak_castle() -> void:
	_poly([-23, 0, -18, 4, -8, 6.5, 8, 6.5, 14, 4, 16, 0], HILL)
	var st := Color("a49a8a")
	# the Shchytaŭka tower, broken at the top
	_poly([-12, 6.5, -5, 6.5, -5, 17, -6, 18.5, -7.5, 17.5, -9, 19.5, -10.5, 18, -12, 18.8], st)
	_r(-12, 11, -5, 12.5, BRICK)
	_arched(-8.5, 8, 1.4, 3, DARK)
	_arched(-8.5, 14, 1.0, 2.4, DARK)
	# the wall and the Church Tower, lower and more broken
	_poly([-5, 6.5, 4, 6.5, 4, 9, 2, 8.4, -1, 9.6, -5, 9.2], st)
	_poly([4, 6.5, 9, 6.5, 9, 12.5, 8, 13.5, 6.8, 12.2, 5.6, 14, 4, 12.8], st)
	_r(4, 9.5, 9, 10.5, BRICK)
	_arched(6.5, 7.2, 1.0, 2.2, DARK)
	# the Mickiewicz mound
	_poly([13, 0, 23, 0, 19, 8, 17, 8], Color("7aa858"))
	_poly([17, 8, 19, 8, 18.6, 8.6, 17.4, 8.6], Color("8ab868"))
	_l(18, 8.6, 18, 10.5, DARK, 0.1)

## Nesvizh Castle: the Radziwiłł palace in pale ochre with red roofs, the gate tower with its clock and green Baroque
## cap in the middle, round corner towers, and the moat in front.
static func _niasviz_palace() -> void:
	var wall := Color("efdba8")
	var trim := Color("f8f2e2")
	# the moat
	_r(-40, 0, 40, 2.2, WATER)
	_r(-40, 2.2, 40, 3.0, GRASS)
	# the wings
	_r(-34, 3, 34, 15, wall)
	_r(-34.5, 14.5, 34.5, 15.3, trim)
	_poly([-34.5, 15.3, 34.5, 15.3, 31, 20, -31, 20], ROOF)
	_windows(-32, -8, 5, 8, 8, WIN)
	_windows(-32, -8, 10.5, 13.5, 8, WIN)
	_windows(8, 32, 5, 8, 8, WIN)
	_windows(8, 32, 10.5, 13.5, 8, WIN)
	# the round corner towers
	for x in [-36.0, 36.0]:
		_r(x - 3.2, 3, x + 3.2, 18, wall)
		_r(x - 3.5, 17.6, x + 3.5, 18.4, trim)
		_poly(_arc(x, 18.4, 3.5, 4.5, 0, PI, 10), ROOF)
		_l(x, 22.9, x, 24.5, DARK, 0.12)
		_arched(x, 9, 1.3, 3, WIN)
	# the gate tower
	_r(-5.5, 3, 5.5, 23, wall)
	_arched(0, 3, 3.6, 6.5, Color("4a3a30"))
	_r(-5.8, 22.5, 5.8, 23.4, trim)
	_r(-4, 23.4, 4, 29, wall)
	_c(0, 26.2, 1.8, trim)
	_c(0, 26.2, 1.5, Color("2a3036"))
	_l(0, 26.2, 0, 27.4, GOLD, 0.15)
	_l(0, 26.2, 0.9, 26.2, GOLD, 0.15)
	_arched(-2.5, 14, 1.4, 3.5, WIN)
	_arched(2.5, 14, 1.4, 3.5, WIN)
	_poly([-4.4, 29, 4.4, 29, 3.2, 31, 1.4, 32, -1.4, 32, -3.2, 31], GREEN_ROOF)
	_r(-1, 32, 1, 33.5, trim)
	_poly([-1.3, 33.5, 1.3, 33.5, 0, 35.5], GREEN_ROOF)
	_l(0, 35.5, 0, 36, GOLD, 0.12)

## Mir Castle: Gothic red brick with white plastered niches, the tall gate tower in the middle, two corner towers
## with their caps, the walls between them and the red roofs of the palace showing over the top.
static func _mir_castle() -> void:
	var white := Color("efe8da")
	# the palace roofs behind the walls
	_poly([-18, 13, 18, 13, 15, 19, -15, 19], ROOF)
	# the curtain walls
	_r(-24, 0, 24, 14, BRICK)
	if _detail(0.8):
		for k in 8:
			var x := -21.0 + k * 6.0
			if absf(x) < 5.0: continue
			_r(x - 1.0, 5, x + 1.0, 9, white)
			_r(x - 0.6, 5.6, x + 0.6, 8.4, BRICK_D)
	_merlons(-24, 24, 14, 0.8, 24, BRICK)
	# the corner towers
	for x in [-24.0, 24.0]:
		_r(x - 4.5, 0, x + 4.5, 24, BRICK)
		for y in [6.0, 12.0, 18.0]:
			_r(x - 3.2, y, x - 0.6, y + 3.2, white)
			_r(x + 0.6, y, x + 3.2, y + 3.2, white)
			_r(x - 2.6, y + 0.6, x - 1.2, y + 2.6, BRICK_D)
			_r(x + 1.2, y + 0.6, x + 2.6, y + 2.6, BRICK_D)
		_r(x - 5, 24, x + 5, 25, BRICK_D)
	# the left one with a tent roof, the right one with a Baroque helm
	_poly([-29.5, 25, -18.5, 25, -24, 31], ROOF)
	_poly([18.5, 25, 29.5, 25, 27.5, 27.5, 25.2, 28.5, 25.6, 30, 24, 31.5, 22.4, 30, 22.8, 28.5, 20.5, 27.5], ROOF)
	_l(24, 31.5, 24, 33, DARK, 0.12)
	# the gate tower
	_r(-5, 0, 5, 27, BRICK)
	_arched(0, 0, 3.4, 6.5, Color("2a2420"))
	for y in [9.0, 15.0, 21.0]:
		_r(-3.6, y, 3.6, y + 3.4, white)
		_arched(-1.6, y + 0.5, 1.2, 2.4, BRICK_D)
		_arched(1.6, y + 0.5, 1.2, 2.4, BRICK_D)
	_r(-5.5, 27, 5.5, 28, BRICK_D)
	_poly([-5.8, 28, 5.8, 28, 0, 34], ROOF)
	_l(0, 34, 0, 35.5, DARK, 0.12)

## The Kamianiec Tower (13th century): a round red brick keep almost 30 m high, shaded as a cylinder, with narrow
## arched windows, a white band of blind arches near the top and a crenellated parapet.
static func _kamianiec_tower() -> void:
	var r := 6.8
	_r(-r, 0, r, 27, BRICK)
	_r(-r, 0, -r + 1.6, 27, BRICK_D)
	_r(r - 1.2, 0, r, 27, BRICK_D)
	_r(-r + 1.6, 0, -r + 2.6, 27, Color("b85238"))
	# the white band of blind arches
	_r(-r, 22, r, 25, BRICK)
	for k in 5:
		var x := -4.8 + k * 2.4
		_arched(x, 22.4, 1.4, 2.4, Color("e8dcc8"))
	# the narrow windows
	for w in [[0.0, 3.0], [-2.0, 9.0], [2.5, 13.5], [-1.0, 18.0]]:
		_arched(w[0], w[1], 0.8, 2.4, Color("2a2420"))
	# the parapet
	_r(-r - 0.3, 27, r + 0.3, 28.5, BRICK)
	_merlons(-r - 0.3, r + 0.3, 28.5, 1.8, 7, BRICK)
	_poly([-3, 28.5, 3, 28.5, 0, 31.8], Color("8a3a28"))

## A wisent of the Białowieża Forest: the dark brown European bison, a high shaggy hump, the heavy head held low
## with short horns and a beard.
static func _wisent() -> void:
	var fur := Color("4a3424")
	var mane := Color("6b4c32")
	var leg := Color("33241a")
	for x in [-1.25, -0.75, 1.0, 1.45]:
		_r(x - 0.16, 0, x + 0.16, 1.0, leg)
	# the whole animal in one outline: the rump, the back sloping up to the hump, the head held low
	_poly([1.85, 0.95, 1.9, 1.55, 1.2, 1.75, 0.2, 1.9, -0.6, 2.35, -1.25, 2.3, -1.7, 1.85, -2.05, 1.55,
		-2.4, 0.95, -2.25, 0.7, -1.85, 0.5, -1.45, 0.75, -0.6, 0.8, 1.2, 0.85], fur)
	# the shaggy shoulders and the beard, a lighter brown
	_poly([-0.3, 2.1, -0.6, 2.35, -1.25, 2.3, -1.7, 1.85, -1.75, 1.2, -1.55, 0.7, -1.1, 0.8, -0.5, 1.2], mane)
	_poly([-2.2, 0.75, -1.85, 0.5, -1.95, 0.25, -2.15, 0.45], mane)
	# the horn, the eye, the tail
	_l(-1.95, 1.6, -2.05, 1.95, Color("e8dcc0"), 0.07)
	_l(-2.05, 1.95, -1.9, 2.1, Color("e8dcc0"), 0.06)
	_c(-2.05, 1.25, 0.05, Color("111111"))
	_l(1.88, 1.5, 2.05, 0.8, fur, 0.08)

## The Braslaw Lakes from Castle Hill: blue water with wooded islands, forested hills on the far shore, and the
## little white church with its red roof on a green rise of the near shore.
static func _braslau_lakes() -> void:
	# the far hills under forest
	_poly([-30, 6, -30, 12, -24, 15, -16, 13.5, -8, 16.5, 2, 14, 10, 17, 18, 14.5, 25, 15.5, 30, 13, 30, 6], Color("35602c"))
	_poly([-30, 6, -30, 9, -20, 10.5, -10, 9.5, 0, 11, 12, 10, 22, 11.5, 30, 9.5, 30, 6], TREE)
	# the water
	_r(-30, 0, 30, 7, WATER)
	if _detail(0.6):
		for k in 7:
			var y := 1.2 + (k % 3) * 1.6
			_l(-27 + k * 8.5, y, -24 + k * 8.5, y, Color(1, 1, 1, 0.5), 0.12)
	# wooded islands
	for isl in [[-8.0, 4.2, 3.5], [6.0, 2.4, 2.5], [18.0, 4.6, 4.5]]:
		var x: float = isl[0]
		var y: float = isl[1]
		var w: float = isl[2]
		_ell(x, y, w, 0.6, 0.0, Color("6a8a4a"))
		_c(x - w * 0.4, y + 1.1, w * 0.35, TREE)
		_c(x + w * 0.15, y + 1.4, w * 0.42, Color("35602c"))
		_c(x + w * 0.6, y + 0.9, w * 0.28, TREE)
	# the near shore with the church
	_poly([-30, 0, -30, 9, -26, 11, -20, 11.5, -15, 8, -12, 3, -10, 0], HILL)
	_r(-25, 11, -19, 16, WHITE)
	_poly([-25.6, 16, -18.4, 16, -22, 18.5], ROOF)
	for x in [-23.5, -20.5]:
		_r(x - 0.4, 12.2, x + 0.4, 14.4, WIN)
	_r(-27.6, 11, -24.6, 20, WHITE)
	_r(-26.6, 17.5, -25.6, 19, WIN)
	_poly([-28, 20, -24.2, 20, -26.1, 24], ROOF)
	_l(-26.1, 24, -26.1, 25.5, GOLD, 0.15)
	_l(-26.6, 25, -25.6, 25, GOLD, 0.12)
