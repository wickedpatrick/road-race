class_name LandmarksRuB
extends RefCounted
## Russian landmarks (Krasnodar to Vladivostok), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const BRICK := Color("b0432f")
const BRICK_D := Color("85301f")
const WHITE := Color("f2eee4")
const STONE := Color("dcd4c0")
const STONE_D := Color("aea38a")
const GOLD := Color("e0b43a")
const CONCRETE := Color("bdbab2")
const CONCRETE_D := Color("8f8c84")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const BRONZE := Color("4f4a3a")
const GRASS := Color("5d8f42")
const ROCK := Color("8d8a7f")
const WATER := Color("4f8fc0")
const WATER_D := Color("3c76a6")
const WOOD := Color("7a5634")
const WOOD_D := Color("5a3e26")
const STEEL := Color("e9ecef")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"ru_krasnodar_arch": _krasnodar_arch()
		"ru_rostov_tractor_theatre": _tractor_theatre()
		"ru_omsk_tara_gate": _tara_gate()
		"ru_goto_predestinatsiya": _goto_predestinatsiya()
		"ru_volga_don_arch": _volga_don_arch()
		"ru_saratov_conservatory": _saratov_conservatory()
		"ru_tyumen_lovers_bridge": _lovers_bridge()
		"ru_irkutsk_wooden_house": _irkutsk_house()
		"ru_muravyov_amursky": _muravyov_amursky()
		"ru_golden_bridge": _golden_bridge()
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

static func _arch_win(x: float, y0: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.5, y0, x + w * 0.5, y0, x + w * 0.5, y0 + h - w * 0.5] + _arc(x, y0 + h - w * 0.5, w * 0.5, w * 0.5, 0, PI, 6), col)

## A gate arch opening: a rectangle with a round top, x centred, from y0 up h, w wide, in `col`.
static func _opening(x: float, y0: float, w: float, h: float, col: Color) -> void:
	_arch_win(x, y0, w, h, col)

## The Tsar's Gate in Krasnodar: a red brick triumphal arch with white trim, a tented roof over the passage and small
## tented corner towers with gilded spheres.
static func _krasnodar_arch() -> void:
	_r(-12, 0, 12, 1, STONE_D)
	_r(-10, 1, 10, 15, BRICK)
	_opening(0, 1, 7, 11, WIN)
	_poly([-3.5, 8.5, 3.5, 8.5, 3.5, 9.2, -3.5, 9.2], WHITE)
	for x in [-7.2, 7.2]:
		_r(x - 1.0, 3, x + 1.0, 9, BRICK_D)
		_arch_win(x, 4, 1.0, 4, WIN)
	_r(-10.5, 14.5, 10.5, 15.5, WHITE)
	# the attic and the tent roof
	_r(-6, 15.5, 6, 18, BRICK)
	_poly([-6.5, 18, 6.5, 18, 0, 22], Color("5a7a64"))
	_c(0, 22.4, 0.5, GOLD)
	for x in [-9.5, 9.5]:
		_r(x - 1.3, 15.5, x + 1.3, 18.5, BRICK)
		_poly([x - 1.5, 18.5, x + 1.5, 18.5, x, 21], Color("5a7a64"))
		_c(x, 21.3, 0.35, GOLD)

## The Rostov Drama Theatre of the 1930s, the "Tractor": a long white constructivist hall with a glazed front and
## two wedge-shaped wings like a tractor's wheels and bonnet seen from above.
static func _tractor_theatre() -> void:
	_r(-46, 0, 46, 1.2, STONE_D)
	# the long auditorium block
	_r(-30, 1.2, 30, 20, WHITE)
	_windows(-28, 28, 14, 18, 14, WIN)
	_r(-30, 19.4, 30, 20.4, Color("cfc9bd"))
	# the stage tower
	_r(14, 20, 30, 32, WHITE)
	_windows(16, 28, 26, 30, 4, WIN)
	# the glazed front: tall window strips
	_r(-12, 1.2, 12, 14, Color("9fb6c8"))
	for i in 9:
		_r(-11.5 + i * 2.8, 1.2, -11.0 + i * 2.8, 14, WHITE)
	_r(-14, 13, 14, 14.5, WHITE)
	# the wings like caterpillar tracks, rounded at the ends
	for s in [-1.0, 1.0]:
		var x0: float = 30.0 * s
		var x1: float = 45.0 * s
		var xa := minf(x0, x1)
		var xb := maxf(x0, x1)
		_r(xa, 1.2, xb, 11, Color("e4dfd3"))
		_c(x1 - 2.0 * s, 6, 4.9, Color("e4dfd3"))
		_windows(xa + 1.0, xb - 3.0, 4, 9, 4, WIN)

## The Tara Gate in Omsk: the white stone gate of the 18th-century fortress, a round-arched passage under a hipped
## roof, with a small sentry lantern on top.
static func _tara_gate() -> void:
	_r(-8, 0, 8, 0.6, STONE_D)
	_r(-7, 0.6, 7, 7.5, WHITE)
	_opening(0, 0.6, 3.6, 5.6, WIN)
	for x in [-4.8, 4.8]:
		_r(x - 0.6, 0.6, x + 0.6, 7.5, STONE)
	_r(-7.4, 7.5, 7.4, 8.2, STONE)
	_poly([-7.6, 8.2, 7.6, 8.2, 3, 10.4, -3, 10.4], Color("5a6670"))
	_r(-1, 10.4, 1, 11.4, WHITE)
	_poly([-1.2, 11.4, 1.2, 11.4, 0, 12.2], Color("5a6670"))

## The Goto Predestinatsiya in Voronezh: a copy of Peter the Great's ship of the line of 1700 moored on the river,
## a dark wooden hull with a gilded stern, three masts and furled sails.
static func _goto_predestinatsiya() -> void:
	_r(-20, 0, 20, 1.5, WATER)
	_r(-20, 0.6, 20, 0.9, WATER_D)
	# the hull, the stern castle high on the left
	_poly([-17, 1.5, 14, 1.5, 18, 6, 16, 7, -14, 7, -16, 11, -19, 11, -18.5, 5], WOOD_D)
	_r(-15, 4.5, 14, 5.1, GOLD)
	for i in 8:
		_r(-11.0 + i * 3.0, 3.0, -10.0 + i * 3.0, 4.0, DARK)
	_r(-19, 9, -14, 11, WOOD)
	_r(-18.6, 9.4, -14.4, 10.6, GOLD)
	_l(15, 6.5, 21, 9.5, WOOD, 0.3)
	# the masts with yards and furled sails
	for m in [[-9.0, 31.0], [1.0, 36.0], [10.0, 28.0]]:
		var x: float = m[0]
		var h: float = m[1]
		_l(x, 7, x, h, WOOD_D, 0.45)
		for f in [0.45, 0.68, 0.88]:
			var y: float = 7.0 + (h - 7.0) * f
			var hw: float = 6.0 * (1.1 - f)
			_l(x - hw, y, x + hw, y, WOOD_D, 0.3)
			_r(x - hw, y - 0.6, x + hw, y, Color("efe7d4"))
	_l(-9, 31, 1, 36, DARK, 0.1)
	_l(1, 36, 10, 28, DARK, 0.1)
	_l(10, 28, 21, 9.5, DARK, 0.1)
	_poly([1, 36, 1, 38.4, 3.4, 37.6], Color("d8402c"))

## The arch over the first lock of the Volga-Don Canal in Volgograd: a white colonnaded triumphal arch either side of
## the lock, a ship coming through below.
static func _volga_don_arch() -> void:
	_r(-25, 0, 25, 2, CONCRETE)
	_r(-8, 0, 8, 1.6, WATER)
	for x in [-14.0, 14.0]:
		_r(x - 6, 2, x + 6, 22, WHITE)
		for i in 4:
			_r(x - 5.0 + i * 3.0, 3, x - 4.0 + i * 3.0, 19, STONE)
		_r(x - 6.5, 19, x + 6.5, 22, STONE)
		_r(x - 4, 22, x + 4, 26, WHITE)
		_poly([x - 2, 26, x + 2, 26, x, 30], STONE_D)
	# the span over the lock
	_poly([-8, 22, 8, 22, 8, 12] + _arc(0, 12, 8, 5, 0, PI, 12) + [-8, 12], WHITE)
	_r(-8, 21.5, 8, 22, STONE_D)
	_r(-6, 22, 6, 24, WHITE)
	# a river ship passing through
	_poly([-6, 1.6, 6, 1.6, 7, 3.4, -7, 3.4], Color("f0f0ea"))
	_r(-4, 3.4, 3, 5.6, Color("f0f0ea"))
	_windows(-3.6, 2.6, 4.2, 5.0, 5, WIN)
	_r(-1.2, 5.6, 0.2, 7.2, Color("d8402c"))

## The Saratov Conservatory: a pale building like a Gothic castle, a pointed gable with a rose window, pinnacles and
## the square tower by the entrance.
static func _saratov_conservatory() -> void:
	var wall := Color("ece4d2")
	_r(-22, 0, 22, 1, STONE_D)
	_r(-20, 1, 20, 18, wall)
	for i in 8:
		_arch_win(-17.5 + i * 5.0, 4, 1.6, 5, WIN)
		_arch_win(-17.5 + i * 5.0, 11, 1.6, 5, WIN)
	_poly([-20, 18, 20, 18, 20, 19, -20, 19], BRICK_D)
	# the middle gable with a rose window
	_r(-6, 1, 6, 22, wall)
	_poly([-6.4, 22, 6.4, 22, 0, 29], wall)
	_c(0, 23.5, 2.1, STONE_D)
	_c(0, 23.5, 1.5, WIN)
	_opening(0, 1, 3.4, 7, WIN)
	# pinnacles
	for x in [-20.0, -6.0, 6.0, 20.0]:
		_poly([x - 0.7, 18, x + 0.7, 18, x, 23], STONE_D)
	# the tower
	_r(12, 1, 18, 30, wall)
	_arch_win(15, 20, 1.8, 6, WIN)
	for k in 3:
		_r(12.0 + k * 2.2, 30, 13.2 + k * 2.2, 31.5, wall)
	_poly([12.6, 31.5, 17.4, 31.5, 15, 36], BRICK_D)

## The Lovers' Bridge in Tyumen: a slender white footbridge over the Tura with a single leaning pylon and fan of cables,
## padlocks glinting on its rails.
static func _lovers_bridge() -> void:
	_r(-40, 0, 40, 3, WATER)
	_poly([-40, 0, -28, 0, -28, 7, -40, 9], GRASS)
	_poly([40, 0, 28, 0, 28, 7, 40, 9], GRASS)
	# the deck
	_r(-34, 7, 34, 8, STEEL)
	_r(-34, 8, 34, 8.2, CONCRETE_D)
	for x in [-14.0, 6.0, 22.0]:
		_r(x - 0.5, 0, x + 0.5, 7, CONCRETE)
	# the pylon and the fan of cables
	_poly([-20, 8, -18.6, 8, -12.6, 29, -14, 29], STEEL)
	for k in 6:
		_l(-13.4, 28.0 - k * 0.6, -10.0 + k * 7.0, 8, Color("c9ced4"), 0.15)
		_l(-13.6, 27.5 - k * 0.6, -30.0 + k * 2.2, 8, Color("c9ced4"), 0.15)
	# the railings with padlocks
	for k in 30:
		_c(-33.0 + k * 2.2, 9.1, 0.25, GOLD if k % 3 == 0 else Color("d8402c"))

## A carved wooden house of Irkutsk's 130th Quarter: dark logs, white-painted carved window frames and shutters, a
## fretwork gable over the attic window.
static func _irkutsk_house() -> void:
	_r(-11, 0, 11, 0.8, STONE_D)
	_r(-10, 0.8, 10, 8, WOOD_D)
	for k in 8:
		_l(-10, 1.4 + k * 0.85, 10, 1.4 + k * 0.85, WOOD, 0.18)
	# windows with carved frames and blue shutters
	for x in [-6.5, -2.2, 2.2, 6.5]:
		_r(x - 1.3, 2.6, x + 1.3, 6.4, WHITE)
		_r(x - 0.9, 3, x + 0.9, 5.6, WIN)
		_poly([x - 1.6, 6.4, x + 1.6, 6.4, x, 7.4], WHITE)
		_r(x - 2.0, 2.8, x - 1.4, 5.8, Color("3d6fa8"))
		_r(x + 1.4, 2.8, x + 2.0, 5.8, Color("3d6fa8"))
	# the roof and the carved gable
	_poly([-11, 8, 11, 8, 0, 13.6], WOOD)
	_poly([-9.6, 8.2, 9.6, 8.2, 0, 13.0], WOOD_D)
	_r(-1.2, 9, 1.2, 11.2, WHITE)
	_r(-0.8, 9.3, 0.8, 10.8, WIN)
	for k in 10:
		_c(-9.0 + k * 2.0, 8.3, 0.35, WHITE)
	_l(-11, 8, 0, 13.6, WHITE, 0.25)
	_l(11, 8, 0, 13.6, WHITE, 0.25)

## The monument to Count Muravyov-Amursky on the Amur cliff in Khabarovsk: the governor in a long coat on a tall
## granite column, the river below.
static func _muravyov_amursky() -> void:
	_r(-20, 0, 20, 1.5, WATER)
	_poly([-20, 1.5, 6, 1.5, 10, 8, 14, 10, 20, 10.5, 20, 12, -20, 12], ROCK)
	_r(-20, 11.5, 20, 12.5, GRASS)
	# the column
	_r(-3.2, 12.5, 3.2, 14, Color("6e6660"))
	_r(-2.4, 14, 2.4, 24, Color("8a817a"))
	_r(-2.9, 24, 2.9, 25, Color("6e6660"))
	# the figure in a long coat, hand at his side
	_poly([-1.6, 25, 1.6, 25, 1.1, 30, -1.1, 30], BRONZE)
	_poly([-1.1, 30, 1.1, 30, 0.9, 31.4, -0.9, 31.4], BRONZE)
	_c(0, 32.1, 0.7, BRONZE)
	_l(1.0, 30.6, 1.8, 28.4, BRONZE, 0.35)
	_l(-1.0, 30.6, -1.3, 28, BRONZE, 0.35)

## The Golden Bridge over the Golden Horn bay in Vladivostok: two tall A-shaped pylons, fans of white cables and the
## deck high above the water.
static func _golden_bridge() -> void:
	_r(-55, 0, 55, 4, WATER)
	_r(-55, 2.5, 55, 2.9, WATER_D)
	# the deck
	_r(-55, 22, 55, 24, CONCRETE)
	_r(-55, 21.4, 55, 22, CONCRETE_D)
	for x in [-50.0, 50.0]:
		_r(x - 1.2, 0, x + 1.2, 22, CONCRETE)
	# two pylons: an A frame with a slim top
	for x in [-26.0, 26.0]:
		_poly([x - 4.5, 0, x - 2.8, 0, x - 0.3, 60, x - 0.9, 60], CONCRETE)
		_poly([x + 4.5, 0, x + 2.8, 0, x + 0.3, 60, x + 0.9, 60], CONCRETE)
		_r(x - 0.9, 60, x + 0.9, 68, CONCRETE)
		_r(x - 3.4, 24, x + 3.4, 25, CONCRETE_D)
		# fans of cables to the deck both sides
		for k in 8:
			var y := 66.0 - k * 2.6
			_l(x, y, x - 4.0 - k * 3.0, 24, STEEL, 0.2)
			_l(x, y, x + 4.0 + k * 3.0, 24, STEEL, 0.2)
