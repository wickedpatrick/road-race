class_name LandmarksRuA
extends RefCounted
## Russian landmarks (Moscow to Samara), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const BRICK := Color("b0432f")
const BRICK_D := Color("85301f")
const WHITE := Color("f2eee4")
const STONE := Color("dcd4c0")
const STONE_D := Color("aea38a")
const GOLD := Color("e0b43a")
const GOLD_D := Color("b8892a")
const GREEN := Color("3f8a5e")
const GREEN_D := Color("2c6646")
const BLUE := Color("2f6fb8")
const BLUE_L := Color("6fa6dc")
const SILVER := Color("c4cad2")
const SILVER_D := Color("8f98a3")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const BRONZE := Color("4f4a3a")
const GRASS := Color("5d8f42")
const ROCK := Color("8d8a7f")
const ROCK_D := Color("6c695f")
const WATER := Color("4f8fc0")
const SKY_FIRE := Color("fff3c4")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"ru_st_basils": _st_basils()
		"ru_peter_paul_cathedral": _peter_paul()
		"ru_novosibirsk_opera": _novosibirsk_opera()
		"ru_europe_asia_obelisk": _europe_asia()
		"ru_kul_sharif": _kul_sharif()
		"ru_paraskeva_chapel": _paraskeva()
		"ru_nn_kremlin": _nn_kremlin()
		"ru_chelyabinsk_meteor": _meteor()
		"ru_salawat_yulayev": _salawat()
		"ru_samara_drama_theatre": _samara_theatre()
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

## A round-topped window (or door) from y0 up to the top of its arch.
static func _arch_win(x: float, y0: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.5, y0, x + w * 0.5, y0, x + w * 0.5, y0 + h - w * 0.5] + _arc(x, y0 + h - w * 0.5, w * 0.5, w * 0.5, 0, PI, 6), col)

## An onion dome sitting on y, r wide at the bulge, with a gold cross.
static func _onion(x: float, y: float, r: float, col: Color) -> void:
	_poly([x - r * 0.7, y, x - r, y + r * 0.6, x - r * 0.85, y + r * 1.15, x - r * 0.35, y + r * 1.6, x, y + r * 2.1,
		x + r * 0.35, y + r * 1.6, x + r * 0.85, y + r * 1.15, x + r, y + r * 0.6, x + r * 0.7, y], col)
	_l(x, y + r * 2.1, x, y + r * 3.0, GOLD, maxf(0.12, r * 0.1))
	_l(x - r * 0.35, y + r * 2.65, x + r * 0.35, y + r * 2.65, GOLD, maxf(0.1, r * 0.08))

## A crenellated wall top (swallowtail merlons) from x0 to x1 at height y.
static func _merlons(x0: float, x1: float, y: float, h: float, col: Color) -> void:
	var n := maxi(2, int((x1 - x0) / (h * 1.6)))
	var w := (x1 - x0) / n
	for k in n:
		var a := x0 + w * k + w * 0.15
		var b := x0 + w * (k + 1) - w * 0.15
		_poly([a, y, b, y, b, y + h, (a + b) * 0.5, y + h * 0.6, a, y + h], col)

## Saint Basil's Cathedral on Red Square: a red brick church of nine chapels on one base, the central tent roof with
## a small gold dome, and the chapels' onion domes, each in its own stripes and chequers.
static func _st_basils() -> void:
	_r(-30, 0, 30, 3, STONE_D)
	_r(-28, 3, 28, 12, BRICK)
	for i in 9:
		_arch_win(-24.0 + i * 6.0, 4.5, 2.0, 5.5, WIN)
	_r(-28, 11.3, 28, 12.2, WHITE)
	# the central tower: an octagonal drum and the tent roof
	_r(-5, 12, 5, 30, BRICK)
	for x in [-3.0, 0.0, 3.0]:
		_arch_win(x, 20, 1.4, 4.5, WIN)
	_l(-5, 24, 5, 24, WHITE, 0.4)
	_poly([-5, 30, 5, 30, 1.2, 46, -1.2, 46], BRICK_D)
	for k in 4:
		var y := 32.0 + k * 3.5
		_l(-4.6 + k * 0.85, y, 4.6 - k * 0.85, y, GOLD_D, 0.3)
	_onion(0, 46, 1.6, GOLD)
	# the chapels round it, each tower with its onion in its own pattern
	var chapels := [[-22.0, 16.0, 3.6, Color("2f8a4f"), Color("f0d24a")], [-12.0, 22.0, 4.0, Color("d8402c"), Color("f2eee4")],
		[12.0, 22.0, 4.0, Color("3c6fc0"), Color("f2eee4")], [22.0, 16.0, 3.6, Color("e0a02a"), Color("2f8a4f")]]
	for ch in chapels:
		var x: float = ch[0]
		var top: float = ch[1]
		var r: float = ch[2]
		_r(x - r * 0.8, 12, x + r * 0.8, top, BRICK)
		_arch_win(x, top - 6.0, 1.2, 3.5, WIN)
		_r(x - r * 0.85, top - 0.6, x + r * 0.85, top, WHITE)
		_onion(x, top, r, ch[3])
		# stripes across the bulge
		for k in 3:
			var y: float = top + r * (0.45 + k * 0.42)
			var hw: float = r * (0.9 - absf(k - 1.0) * 0.12)
			_l(x - hw, y - r * 0.15, x + hw, y + r * 0.15, ch[4], r * 0.16)
	# the bell tower at the east end
	_r(26, 12, 30, 26, BRICK)
	_poly([25.6, 26, 30.4, 26, 28.6, 33, 27.4, 33], GREEN)
	_onion(28, 33, 0.8, GOLD)

## The Peter and Paul Cathedral: the low baroque church in the fortress and its bell tower in tiers, the gilded spire
## with the angel holding the cross 122 m up.
static func _peter_paul() -> void:
	var wall := Color("e8cf9a")
	_r(-22, 0, 22, 2, STONE_D)
	# the nave with its little dome
	_r(-8, 2, 22, 20, wall)
	for i in 5:
		_arch_win(-4.0 + i * 5.5, 5, 2.2, 8, WIN)
		_r(-6.6 + i * 5.5, 2, -5.8 + i * 5.5, 20, WHITE)
	_poly([-8, 20, 22, 20, 22, 22, -8, 22], Color("5f6a72"))
	_r(11, 22, 17, 27, wall)
	_poly(_arc(14, 27, 3.4, 3.8, 0, PI, 10), GREEN_D)
	_c(14, 31.2, 0.6, GOLD)
	_l(14, 31.2, 14, 35, GOLD, 0.3)
	# the bell tower in three tiers
	_r(-20, 2, -8, 30, wall)
	_arch_win(-14, 3, 3.5, 8, WIN)
	_r(-20, 28.8, -8, 30, WHITE)
	_r(-18.5, 30, -9.5, 42, wall)
	_arch_win(-14, 32, 2.6, 7, WIN)
	_r(-18.5, 41, -9.5, 42, WHITE)
	_r(-17, 42, -11, 52, wall)
	_arch_win(-14, 44, 2, 5.5, WIN)
	_poly(_arc(-14, 52, 3.4, 3.2, 0, PI, 10), GOLD_D)
	_r(-15, 54.5, -13, 60, GOLD)
	# the spire, the angel and the cross
	_poly([-15, 60, -13, 60, -13.8, 114, -14.2, 114], GOLD)
	_l(-14, 113, -14, 116, GOLD_D, 0.25)
	_poly([-14.4, 116, -13.6, 116, -13.8, 119, -14.2, 119], GOLD)
	_poly([-14, 118, -16.8, 119.5, -14.2, 117.6], GOLD)
	_poly([-14, 118, -11.2, 119.5, -13.8, 117.6], GOLD)
	_l(-14, 119, -14, 122, GOLD, 0.2)
	_l(-15, 121, -13, 121, GOLD, 0.18)

## The Novosibirsk Opera and Ballet Theatre: the long grey building with its columned portico and the huge silver dome.
static func _novosibirsk_opera() -> void:
	var wall := Color("c9c2b4")
	_r(-50, 0, 50, 2, STONE_D)
	_r(-48, 2, 48, 22, wall)
	_windows(-46, -16, 6, 11, 8, WIN)
	_windows(-46, -16, 14, 19, 8, WIN)
	_windows(16, 46, 6, 11, 8, WIN)
	_windows(16, 46, 14, 19, 8, WIN)
	_r(-48, 21, 48, 22.5, STONE_D)
	# the portico
	_r(-15, 2, 15, 4, STONE)
	for i in 8:
		_r(-13.5 + i * 3.7, 4, -12.3 + i * 3.7, 19, STONE)
	_poly([-16, 19, 16, 19, 16, 21, 0, 25, -16, 21], STONE)
	# the drum and the silver dome
	_r(-27, 22.5, 27, 32, wall)
	_windows(-25, 25, 25, 30, 14, WIN)
	_poly(_arc(0, 32, 28, 27, 0, PI, 24), SILVER)
	for k in 6:
		var a := PI * (k + 1) / 7.0
		_l(cos(a) * 28, 32 + sin(a) * 27 * 0.15, cos(a) * 5, 57, SILVER_D, 0.35)
	_r(-2.2, 58, 2.2, 61, wall)
	_poly(_arc(0, 61, 2.4, 1.6, 0, PI, 8), SILVER_D)

## The Europe-Asia obelisk on the Moscow road out of Yekaterinburg: a granite post on a stepped plinth, a white line
## on the ground crossing from one continent into the other.
static func _europe_asia() -> void:
	var granite := Color("8c7f78")
	var granite_d := Color("6a5e58")
	_r(-8, 0, 8, 0.4, Color("9a9a92"))
	_r(-0.25, 0, 0.25, 0.45, WHITE)
	_r(-6, 0.4, 6, 1.4, granite_d)
	_r(-4.5, 1.4, 4.5, 2.6, granite)
	_r(-3.2, 2.6, 3.2, 4.0, granite_d)
	_poly([-2.2, 4, 2.2, 4, 1.3, 22, -1.3, 22], granite)
	_poly([0, 4, 2.2, 4, 1.3, 22, 0, 22], granite_d)
	_poly([-1.3, 22, 1.3, 22, 0, 25], granite)
	_poly([-1.6, 10, 1.6, 10, 1.5, 13, -1.5, 13], GOLD)
	_r(-0.05, 10, 0.05, 13, GOLD_D)
	# the two continents' names on boards either side
	_r(-7.2, 0.4, -7.0, 3.2, DARK)
	_r(-7.8, 2.4, -5.4, 3.5, BLUE)
	_r(7.0, 0.4, 7.2, 3.2, DARK)
	_r(5.4, 2.4, 7.8, 3.5, BLUE)

## Kul Sharif Mosque in the Kazan kremlin: white walls, the pointed turquoise-blue dome and four slender minarets with
## blue tips and crescents.
static func _kul_sharif() -> void:
	_r(-24, 0, 24, 2, STONE_D)
	_r(-20, 2, 20, 16, WHITE)
	for i in 5:
		_arch_win(-14.0 + i * 7.0, 4, 3.0, 9, BLUE_L)
	_r(-20, 15, 20, 16.5, BLUE)
	# the drum and the dome, pointed like a helmet
	_r(-9, 16.5, 9, 24, WHITE)
	for x in [-6.0, -2.0, 2.0, 6.0]:
		_arch_win(x, 18, 1.4, 4.5, BLUE_L)
	_poly([-10, 24, -9.5, 28, -7, 32, -3.5, 35, 0, 38.5, 3.5, 35, 7, 32, 9.5, 28, 10, 24], BLUE)
	_l(-8.6, 27, 8.6, 27, Color("f2f2ea"), 0.3)
	_l(0, 38.5, 0, 42, GOLD, 0.25)
	_c(0, 42.6, 0.7, GOLD)
	# four minarets
	for m in [[-21.0, 54.0, 1.6], [-13.0, 46.0, 1.3], [13.0, 46.0, 1.3], [21.0, 54.0, 1.6]]:
		var x: float = m[0]
		var h: float = m[1]
		var w: float = m[2]
		_poly([x - w, 0, x + w, 0, x + w * 0.75, h - 8, x - w * 0.75, h - 8], WHITE)
		for f in [0.35, 0.62, 0.82]:
			_r(x - w * 1.3, h * f - 0.8, x + w * 1.3, h * f, BLUE)
		_r(x - w * 0.7, h - 8, x + w * 0.7, h - 4, WHITE)
		_poly([x - w * 0.85, h - 4, x + w * 0.85, h - 4, x, h + 1.5], BLUE)
		_l(x, h + 1.5, x, h + 3, GOLD, 0.2)
		_c(x, h + 3.4, 0.5, GOLD)

## The chapel of St Paraskeva on Karaulnaya Hill above Krasnoyarsk: a small white chapel with a tent roof and a gold
## dome on a grassy hilltop.
static func _paraskeva() -> void:
	_poly([-8, 0, 8, 0, 5, 4, 2, 5.2, -2, 5.2, -5, 4], GRASS)
	_r(-2.4, 5, 2.4, 11, WHITE)
	_arch_win(0, 5, 1.2, 2.6, WIN)
	_arch_win(-1.4, 7.6, 0.6, 1.8, WIN)
	_arch_win(1.4, 7.6, 0.6, 1.8, WIN)
	_r(-2.8, 11, 2.8, 11.6, STONE)
	_poly([-2.8, 11.6, 2.8, 11.6, 0.6, 17.5, -0.6, 17.5], Color("4f9a7c"))
	_onion(0, 17.5, 0.8, GOLD)

## The Nizhny Novgorod kremlin: red brick walls with swallowtail merlons running down the slope to the Volga, square
## towers under green tent roofs, the Dmitrievskaya tower the tallest.
static func _nn_kremlin() -> void:
	# the slope and the river at its foot
	_poly([-46, 0, 46, 0, 46, 2, 20, 2, -10, 10, -46, 14], GRASS)
	_r(30, 0, 46, 1.2, WATER)
	var walls := [[-46.0, 14.0, -26.0, 13.0], [-26.0, 13.0, -6.0, 8.6], [-6.0, 8.6, 18.0, 2.4], [18.0, 2.4, 30.0, 1.6]]
	for w in walls:
		var x0: float = w[0]
		var y0: float = w[1]
		var x1: float = w[2]
		var y1: float = w[3]
		_poly([x0, y0, x1, y1, x1, y1 + 9, x0, y0 + 9], BRICK)
		_l(x0, y0 + 9, x1, y1 + 9, BRICK_D, 0.4)
		var n := 6
		for k in n:
			var a := x0 + (x1 - x0) * (k + 0.2) / n
			var b := x0 + (x1 - x0) * (k + 0.8) / n
			var ya := lerpf(y0, y1, (k + 0.2) / n) + 9.0
			var yb := lerpf(y0, y1, (k + 0.8) / n) + 9.0
			_poly([a, ya, b, yb, b, yb + 1.6, (a + b) * 0.5, (ya + yb) * 0.5 + 1.0, a, ya + 1.6], BRICK)
	for t in [[-26.0, 13.0, 4.0, 18.0], [-6.0, 8.6, 5.5, 26.0], [18.0, 2.4, 4.0, 18.0], [30.0, 1.6, 3.4, 16.0]]:
		var x: float = t[0]
		var y: float = t[1]
		var hw: float = t[2]
		var h: float = t[3]
		_r(x - hw, y, x + hw, y + h, BRICK)
		_r(x - hw, y + h * 0.4, x + hw, y + h * 0.4 + 0.5, BRICK_D)
		_arch_win(x, y + h * 0.55, hw * 0.4, h * 0.2, WIN)
		_merlons(x - hw, x + hw, y + h, 1.4, BRICK)
		_poly([x - hw - 0.3, y + h + 1.4, x + hw + 0.3, y + h + 1.4, x, y + h + 1.4 + hw * 2.2], GREEN_D)
	# the Dmitrievskaya tower's spire and its eagle-less flag pole
	_l(-6, 8.6 + 26 + 1.4 + 5.5 * 2.2, -6, 8.6 + 26 + 1.4 + 5.5 * 2.2 + 3, GOLD, 0.25)

## The Chelyabinsk meteor of 15 February 2013: a smoky trail across the morning sky ending in a white-hot fireball
## above the city's blocks.
static func _meteor() -> void:
	# the city's blocks
	for b in [[-34.0, -24.0, 12.0], [-22.0, -14.0, 18.0], [-12.0, -2.0, 10.0], [0.0, 8.0, 15.0], [10.0, 20.0, 9.0], [22.0, 32.0, 14.0]]:
		_r(b[0], 0, b[1], b[2], Color("b8b3a8"))
		_windows(b[0] + 1.0, b[1] - 1.0, 2, b[2] - 2.0, 4, WIN)
	_r(-36, 0, 36, 0.6, Color("e6e9ec"))
	# the smoke trail, widening behind the head
	_poly([-36, 60, -30, 63, 12, 38, 14, 34], Color("d9dde3"))
	_poly([-36, 60, -33, 61.6, 12, 37.4, 13, 35.4], Color("eef0f2"))
	_poly([-10, 50, -6, 48.5, 12, 37.8, 13, 35.8], Color("ffd98a"))
	# the fireball
	_c(14.5, 35, 3.4, Color("ffb347"))
	_c(14.5, 35, 2.3, SKY_FIRE)
	_c(14.5, 35, 1.2, Color("ffffff"))

## Salawat Yulayev's monument in Ufa: the Bashkir hero on a rearing horse, a whip raised, on a granite plinth at the
## top of the cliff over the Belaya.
static func _salawat() -> void:
	_poly([-18, 0, 18, 0, 16, 6, 10, 10, 4, 11, -6, 11, -12, 9, -17, 5], ROCK)
	_poly([-17, 5, -12, 9, -6, 11, -10, 11, -16, 8], GRASS)
	_poly([4, 11, 10, 10, 16, 6, 14, 8, 8, 11.4], GRASS)
	_r(-4.5, 11, 4.5, 15, Color("9a8f86"))
	_r(-5, 14.6, 5, 15.4, Color("b5aba2"))
	# the horse, rearing to the right
	_ell(0, 19.5, 4.2, 1.9, 0.45, BRONZE)
	_l(-2.6, 18, -3.4, 15.2, BRONZE, 0.8)
	_l(-1.6, 17.6, -1.4, 15.2, BRONZE, 0.8)
	_l(2.6, 21, 4.6, 19.6, BRONZE, 0.7)
	_l(3.2, 20.4, 4.8, 18.4, BRONZE, 0.7)
	_poly([2.6, 20.6, 4.0, 22.2, 4.6, 25, 3.6, 25.4, 2.0, 22.4], BRONZE)
	_poly([3.6, 25.4, 4.6, 25, 6.0, 24.2, 6.2, 23.4, 4.8, 23.6], BRONZE)
	_poly([-3.6, 18.4, -5.6, 16.6, -6.2, 17.2, -4.2, 19.4], BRONZE)
	# the rider, the whip up
	_poly([-0.6, 20.6, 0.8, 20.8, 1.2, 23.8, -0.2, 24], BRONZE)
	_c(0.6, 24.8, 0.65, BRONZE)
	_l(0.6, 23.2, -1.6, 26.4, BRONZE, 0.35)
	_l(-1.6, 26.4, -2.4, 28.8, DARK, 0.15)
	_l(0.8, 23, 2.6, 22.4, BRONZE, 0.3)
	_l(-0.2, 21, 1.4, 19.2, BRONZE, 0.4)

## The Samara Drama Theatre: a red brick building of 1888 with fairy-tale turrets, tented roofs and white trim on the
## square above the Volga.
static func _samara_theatre() -> void:
	_r(-26, 0, 26, 1.5, STONE_D)
	_r(-20, 1.5, 20, 16, BRICK)
	_windows(-18, -6, 4, 8, 4, WIN)
	_windows(6, 18, 4, 8, 4, WIN)
	_windows(-18, -6, 10, 14, 4, WIN)
	_windows(6, 18, 10, 14, 4, WIN)
	_l(-20, 9, 20, 9, WHITE, 0.4)
	_r(-20, 15.5, 20, 16.4, WHITE)
	_poly([-20, 16.4, 20, 16.4, 14, 21, -14, 21], Color("5a6b5f"))
	# the entrance block with its high gable
	_r(-6, 1.5, 6, 22, BRICK)
	_arch_win(0, 1.5, 3.2, 6, WIN)
	_arch_win(0, 11, 2.4, 6, WIN)
	_poly([-6.5, 22, 6.5, 22, 0, 28], BRICK_D)
	_l(0, 28, 0, 30, GOLD, 0.2)
	# the corner turrets with their tents
	for x in [-23.0, 23.0]:
		_r(x - 3, 1.5, x + 3, 24, BRICK)
		_arch_win(x, 6, 1.4, 4, WIN)
		_arch_win(x, 14, 1.4, 4, WIN)
		_l(x - 3, 19, x + 3, 19, WHITE, 0.4)
		_poly([x - 3.4, 24, x + 3.4, 24, x, 32], Color("4f6a5a"))
		_l(x, 32, x, 34, GOLD, 0.2)
