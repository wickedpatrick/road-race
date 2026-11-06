class_name LandmarksHrA
extends RefCounted
## Croatian landmarks (Zagreb to Šibenik), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const STONE := Color("e6dcc4")
const STONE_D := Color("c9bb9b")
const LIME := Color("efe9da")
const ROOF := Color("c4562f")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const BRICK := Color("a8432f")
const GRASS := Color("5d8f42")
const WATER := Color("3f86b8")
const HR_RED := Color("d0102e")
const HR_BLUE := Color("17377f")
const GOLD := Color("e0b43a")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"st_mark_zagreb": _st_mark()
		"diocletian_peristyle": _peristyle()
		"rijeka_tower": _rijeka_tower()
		"osijek_cathedral": _osijek()
		"sea_organ": _sea_organ()
		"pula_arena": _arena()
		"brod_fortress": _brod()
		"dubovac": _dubovac()
		"st_james_sibenik": _st_james()
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

## An arched opening (round top) from y0 up to the spring line y1.
static func _archway(x: float, hw: float, y0: float, y1: float, col: Color) -> void:
	_poly([x + hw, y0, x + hw, y1] + _arc(x, y1, hw, hw, 0, PI, 6) + [x - hw, y0], col)

## A red-white chequered shield (Croatia's šahovnica), 5 x 5 squares, top-left corner at (x, y), square side s.
static func _chequer(x: float, y: float, s: float) -> void:
	for i in 5:
		for j in 5:
			_r(x + i * s, y - (j + 1) * s, x + (i + 1) * s, y - j * s, HR_RED if (i + j) % 2 == 0 else Color.WHITE)

## St Mark's Church in Zagreb's Upper Town: a small Gothic church whose steep roof of glazed tiles shows the arms
## of the Triune Kingdom (the chequerboard, three lion heads, the marten) on the left and Zagreb's white castle on red
## on the right; a slim bell tower with a green cap at the back.
static func _st_mark() -> void:
	# bell tower behind
	_r(7, 0, 11, 24, LIME)
	_poly([6.6, 24, 11.4, 24, 9, 30], Color("4f8a5c"))
	_windows(7, 11, 18, 21, 1, WIN)
	# the nave
	_r(-12, 0, 8, 10, LIME)
	_archway(-2, 1.5, 0, 4.5, WIN)
	for x in [-9.0, 5.0]:
		_archway(x, 0.8, 4, 7.5, WIN)
	# the roof
	_poly([-13, 10, 9, 10, 4, 22, -8, 22], Color("2c5d9a"))
	# left: the chequered arms with a blue top band; right: Zagreb's castle on red
	_chequer(-9.5, 19.5, 1.6)
	_r(-9.5, 19.5, -1.5, 21, Color("27458f"))
	_r(0, 11.5, 6.5, 20, HR_RED)
	_r(1, 12.5, 5.5, 16.5, Color.WHITE)
	for x in [1.0, 2.6, 4.2]:
		_r(x, 16.5, x + 1.3, 18, Color.WHITE)
	_archway(3.25, 0.8, 12.5, 14.2, DARK)

## Split, the Peristyle of Diocletian's Palace: Corinthian columns carrying round arches, the cathedral's
## Romanesque bell tower rising behind, storey on storey, to a pyramid top.
static func _peristyle() -> void:
	# the bell tower
	var tw := [[0, 6.0], [14, 5.2], [26, 4.6], [36, 4.0]]
	for k in 3:
		var y0: float = tw[k][0]
		var hw: float = tw[k][1]
		_r(-hw, 10 + y0, hw, 10 + tw[k + 1][0], STONE)
		_r(-hw, 10 + tw[k + 1][0] - 0.8, hw, 10 + tw[k + 1][0], STONE_D)
		for x in [-hw * 0.5, hw * 0.5]:
			_archway(x, hw * 0.3, 10 + y0 + 3, 10 + tw[k + 1][0] - 4, WIN)
	_poly([-4, 46, 4, 46, 0, 52], STONE_D)
	# colonnade
	_r(-20, 13, 20, 16, STONE)
	_r(-20, 0, 20, 1, STONE_D)
	for k in 6:
		var x := -17.0 + k * 6.8
		_r(x - 0.7, 1, x + 0.7, 10, Color("d8ccae"))
		_r(x - 1.1, 9.5, x + 1.1, 10.5, STONE_D)
	for k in 5:
		var x := -17.0 + k * 6.8 + 3.4
		_poly([x - 2.7, 10.5] + _arc(x, 10.5, 2.7, 2.4, PI, 0, 8) + [x + 2.7, 10.5, x + 3.4, 13, x - 3.4, 13], STONE)

## Rijeka's City Tower: a Baroque gate tower over the Korzo, a big clock face, a domed top with a lantern,
## the double-headed eagle over the arch.
static func _rijeka_tower() -> void:
	_r(-5, 0, 5, 24, Color("f0dca4"))
	_archway(0, 2.4, 0, 5.5, DARK)
	_r(-5.5, 9, 5.5, 10, STONE_D)
	_c(0, 13, 1.4, DARK)
	_c(0, 18.5, 2.8, Color.WHITE)
	_c(0, 18.5, 2.8 * 0.15, DARK)
	_l(0, 18.5, 0, 20.6, DARK, 0.25)
	_l(0, 18.5, 1.6, 18.5, DARK, 0.25)
	_r(-5.5, 23, 5.5, 24.2, STONE_D)
	_poly([-4.5, 24.2] + _arc(0, 24.2, 4.5, 4.5, PI, 0, 10) + [4.5, 24.2], Color("4f7a6a"))
	_r(-0.9, 28.5, 0.9, 30.5, Color("4f7a6a"))
	_poly([-0.9, 30.5, 0.9, 30.5, 0, 32], GOLD)

## Osijek's Co-Cathedral of Sts Peter and Paul: a red-brick neo-Gothic church with a single 90 m tower with a
## pointed spire, buttresses and tall lancet windows.
static func _osijek() -> void:
	_r(-15, 0, 15, 22, BRICK)
	_poly([-15.5, 22, 15.5, 22, 0, 32], Color("6b3a2e"))
	for x in [-11.0, -7.0, 7.0, 11.0]:
		_poly([x - 1, 4, x + 1, 4, x + 1, 15, x, 17, x - 1, 15], WIN)
	# tower
	_r(-4.5, 0, 4.5, 58, BRICK.lightened(0.06))
	for y in [20.0, 36.0, 50.0]:
		_r(-4.8, y, 4.8, y + 0.8, STONE_D)
	_poly([-2, 0, 2, 0, 2, 7, 0, 10, -2, 7], DARK)
	for y in [26.0, 42.0, 52.0]:
		_poly([-1, y, 1, y, 1, y + 3.5, 0, y + 5, -1, y + 3.5], WIN)
	for x in [-4.5, 4.5]:
		_poly([x - 0.7, 58, x + 0.7, 58, x, 62], BRICK)
	_poly([-4.2, 58, 4.2, 58, 0, 88], Color("5e3328"))
	_l(0, 88, 0, 90, GOLD, 0.3)
	_l(-0.8, 89.2, 0.8, 89.2, GOLD, 0.3)

## Zadar's Sea Organ and Greeting to the Sun: white marble steps going down into the sea with the organ's slits,
## and the big ring of glass solar panels set in the quay.
static func _sea_organ() -> void:
	_r(-24, 0, 24, 3, WATER)
	for k in 5:
		var y := 0.6 * k
		_r(-24 + k * 1.2, y, 0 - k * 0.6, y + 0.6, Color("eeeae0").darkened(0.03 * k))
	for k in 7:
		_r(-22 + k * 3.0, 1.0, -21.4 + k * 3.0, 1.5, DARK)
	# the quay and the Greeting to the Sun, a flat disc seen from the side, plus a glow
	_r(0, 2.9, 24, 3.4, STONE_D)
	LandmarkPainter._ell(12, 4.2, 10, 1.4, 0, Color("1d2a4a"))
	LandmarkPainter._ell(12, 4.2, 8.6, 1.0, 0, Color("6fb9e8"))
	for k in 6:
		_c(5 + k * 2.8, 4.2, 0.35, Color("ffe680"))
	# a sailing boat in the channel
	_r(-15, 3, -9, 3.8, Color.WHITE)
	_poly([-12.2, 3.8, -12.2, 9.5, -9.5, 3.8], Color("f4f1e8"))

## The Pula Arena: the oval Roman amphitheatre seen from outside, two storeys of arches and the attic with its
## square openings, and the four towers that once held the awnings.
static func _arena() -> void:
	var s := Color("ddd2b8")
	_r(-33, 0, 33, 30, s)
	_r(-33, 12.5, 33, 13.3, STONE_D)
	_r(-33, 25, 33, 25.8, STONE_D)
	for k in 12:
		var x := -30.0 + k * 5.45
		_archway(x, 1.8, 1.5, 8.5, Color("6b6a72"))
		_archway(x, 1.8, 14.5, 21.5, Color("8fb4d6"))
		_r(x - 1, 26.8, x + 1, 28.6, Color("8fb4d6"))
	for x in [-33.0, -14.0, 14.0, 33.0]:
		_r(x - 2.2, 0, x + 2.2, 31.5, s.darkened(0.06))

## Brod Fortress: a low star fortress of brick ramparts behind a moat, bastion corners, the barracks roofs and the
## chapel's little tower inside.
static func _brod() -> void:
	_r(-30, 0, 30, 1.5, WATER)
	_poly([-28, 1.5, 28, 1.5, 24, 8, -24, 8], BRICK)
	for x in [-26.0, 0.0, 26.0]:
		_poly([x - 5, 1.5, x + 5, 1.5, x + 3, 9, x - 3, 9], BRICK.lightened(0.08))
	_r(-28, 8, 28, 8.6, GRASS)
	_r(-16, 8.6, 16, 12, Color("f0e3bf"))
	_poly([-17, 12, 17, 12, 15, 14.5, -15, 14.5], ROOF)
	_windows(-15, 15, 9.5, 11, 10, WIN)
	_r(-1.2, 12, 1.2, 15.5, Color("f0e3bf"))
	_poly([-1.5, 15.5, 1.5, 15.5, 0, 16], DARK)

## Dubovac Castle above Karlovac: a tower-house of grey stone with a crenellated round tower, on a green hill.
static func _dubovac() -> void:
	_poly([-17, 0, 17, 0, 10, 6, -10, 6], GRASS)
	var s := Color("bdb4a2")
	_r(-10, 6, 6, 18, s)
	_poly([-11, 18, 7, 18, -2, 23], ROOF)
	_windows(-9, 5, 11, 14, 4, WIN)
	_archway(-2, 1.4, 6, 9, DARK)
	# round keep with merlons
	_r(5, 6, 13, 26, s.lightened(0.05))
	for k in 4:
		_r(5 + k * 2.2, 26, 6.2 + k * 2.2, 28, s.lightened(0.05))
	_r(8.2, 18, 9.8, 20.5, WIN)
	_l(9, 28, 9, 30, DARK, 0.2)
	_poly([9, 30, 12, 29.3, 9, 28.6], HR_RED)

## Šibenik's Cathedral of St James: all white stone, a trefoil front, a ribbed stone dome over the crossing, and
## the frieze of carved heads around the apse.
static func _st_james() -> void:
	var s := Color("f0ead8")
	_r(-14, 0, 14, 16, s)
	# trefoil front
	_poly([-14, 16] + _arc(-9, 16, 5, 5, PI, 0, 8) + [-4, 16], s)
	_poly([4, 16] + _arc(9, 16, 5, 5, PI, 0, 8) + [14, 16], s)
	_poly([-6, 16] + _arc(0, 16, 6, 9, PI, 0, 12) + [6, 16], s)
	_c(0, 18, 2.2, STONE_D)
	_c(0, 18, 1.5, WIN)
	_archway(0, 2, 0, 6, DARK)
	# the dome on a drum
	_r(-4, 24, 4, 29, s.darkened(0.04))
	_poly([-4.5, 29] + _arc(0, 29, 4.5, 5.5, PI, 0, 12) + [4.5, 29], STONE)
	for x in [-2.5, 0.0, 2.5]:
		_l(x, 29, x * 0.4, 34.3, STONE_D, 0.2)
	_r(-0.4, 34.3, 0.4, 36, s)
	# the heads frieze
	if LandmarkPainter._pm > 2.0:
		for k in 12:
			_c(-12.5 + k * 2.27, 3.5, 0.45, STONE_D)
