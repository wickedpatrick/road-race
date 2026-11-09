class_name LandmarksRuC
extends RefCounted
## Russian landmarks (Yaroslavl to Ust-Luga), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const BRICK := Color("a8452f")
const BRICK_D := Color("7f3424")
const WHITE := Color("f2eee4")
const STONE := Color("dcd4c0")
const STONE_D := Color("aea38a")
const GOLD := Color("e0b43a")
const GOLD_D := Color("b8892a")
const GREEN := Color("3f8a5e")
const GREEN_D := Color("2c6646")
const SILVER := Color("c4cad2")
const CONCRETE := Color("bdbab2")
const CONCRETE_D := Color("8f8c84")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const GRASS := Color("5d8f42")
const WATER := Color("4f8fc0")
const WATER_D := Color("3c76a6")
const WOOD := Color("7a5634")
const WOOD_D := Color("5a3e26")
const RED := Color("c8352b")
const PALM := Color("3f7a3a")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"ru_elijah_church": _elijah_church()
		"ru_konigsberg_cathedral": _konigsberg_cathedral()
		"ru_sochi_seaport": _sochi_seaport()
		"ru_rinpoche_bagsha": _rinpoche_bagsha()
		"ru_vladimir_golden_gate": _vladimir_gate()
		"ru_chita_decembrist_church": _chita_church()
		"ru_novgorod_st_sophia": _novgorod_sophia()
		"ru_pskov_krom": _pskov_krom()
		"ru_vostochny_launch": _vostochny()
		"ru_ust_luga_port": _ust_luga_port()
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

static func _arch_win(x: float, y0: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.5, y0, x + w * 0.5, y0, x + w * 0.5, y0 + h - w * 0.5] + _arc(x, y0 + h - w * 0.5, w * 0.5, w * 0.5, 0, PI, 6), col)

## An onion dome on a slim drum: the drum from y up dh, the onion r wide, a gold cross on top.
static func _onion_drum(x: float, y: float, r: float, dh: float, wall: Color, dome: Color) -> void:
	_r(x - r * 0.6, y, x + r * 0.6, y + dh, wall)
	_arch_win(x, y + dh * 0.25, r * 0.3, dh * 0.5, WIN)
	var t := y + dh
	_poly([x - r * 0.65, t, x - r, t + r * 0.6, x - r * 0.85, t + r * 1.15, x - r * 0.35, t + r * 1.6, x, t + r * 2.1,
		x + r * 0.35, t + r * 1.6, x + r * 0.85, t + r * 1.15, x + r, t + r * 0.6, x + r * 0.65, t], dome)
	_l(x, t + r * 2.1, x, t + r * 3.0, GOLD, maxf(0.12, r * 0.1))
	_l(x - r * 0.35, t + r * 2.65, x + r * 0.35, t + r * 2.65, GOLD, maxf(0.1, r * 0.08))

## A helmet dome (Novgorod style): a low round dome with a point, on y, r wide.
static func _helmet(x: float, y: float, r: float, col: Color) -> void:
	_poly([x - r, y, x - r, y + r * 0.5, x - r * 0.7, y + r * 1.05, x - r * 0.25, y + r * 1.35, x, y + r * 1.7,
		x + r * 0.25, y + r * 1.35, x + r * 0.7, y + r * 1.05, x + r, y + r * 0.5, x + r, y], col)
	_l(x, y + r * 1.7, x, y + r * 2.4, GOLD, maxf(0.12, r * 0.09))
	_l(x - r * 0.3, y + r * 2.1, x + r * 0.3, y + r * 2.1, GOLD, maxf(0.1, r * 0.07))

## The Church of Elijah the Prophet in Yaroslavl: a whitewashed cube with red brick trim and five green onion domes,
## the tented bell tower at the side.
static func _elijah_church() -> void:
	_r(-22, 0, 22, 1.2, STONE_D)
	_r(-14, 1.2, 12, 18, WHITE)
	for i in 4:
		_arch_win(-10.0 + i * 6.0, 5, 2.0, 6, WIN)
		_r(-12.4 + i * 6.0, 1.2, -11.6 + i * 6.0, 18, BRICK)
	_r(-14, 16.8, 12, 18, BRICK)
	_poly([-14, 18, 12, 18, 12, 19, -14, 19], GREEN_D)
	# five domes: the middle one larger
	_onion_drum(-1, 19, 3.4, 6, WHITE, GREEN)
	for x in [-9.0, 7.0]:
		_onion_drum(x, 19, 2.2, 4, WHITE, GREEN)
	for x in [-5.5, 3.5]:
		_onion_drum(x, 19, 1.6, 7.5, WHITE, GREEN_D)
	# the bell tower with its green tent
	_r(14, 1.2, 20, 22, WHITE)
	_r(14, 21, 20, 22, BRICK)
	_arch_win(17, 18, 2.6, 6, WIN)
	_r(14.6, 22, 19.4, 25, WHITE)
	_poly([14.4, 25, 19.6, 25, 17.6, 36, 16.4, 36], GREEN)
	_l(15, 28, 19, 28, WHITE, 0.25)
	_l(15.4, 31, 18.6, 31, WHITE, 0.25)
	_onion_drum(17, 36, 0.9, 1.2, WHITE, GOLD)

## Kaliningrad Cathedral on Kneiphof island: a red brick Gothic church with a tall tower and a short spire, the
## stepped gable, and Kant's tomb as a small colonnade at its corner.
static func _konigsberg_cathedral() -> void:
	_r(-36, 0, 36, 1, GRASS)
	# the nave and the choir
	_r(-14, 1, 30, 22, BRICK)
	for i in 6:
		_arch_win(-9.0 + i * 6.5, 5, 2.4, 12, WIN)
	_poly([-14, 22, 30, 22, 30, 24, 8, 34, -14, 24], Color("7b3426"))
	_r(24, 1, 30, 22, BRICK_D)
	# the west tower
	_r(-24, 1, -12, 42, BRICK)
	_arch_win(-18, 6, 3.6, 10, WIN)
	_arch_win(-18, 22, 2.4, 8, WIN)
	_arch_win(-18, 33, 2.0, 6, WIN)
	_r(-24, 41, -12, 42, BRICK_D)
	_poly([-24.4, 42, -11.6, 42, -16, 48, -20, 48], Color("4f6a5a"))
	_poly([-19, 48, -17, 48, -18, 56], Color("4f6a5a"))
	# a clock face
	_c(-18, 37, 1.6, WHITE)
	_c(-18, 37, 0.3, DARK)
	# Kant's tomb: a small rose-granite colonnade
	_r(30, 1, 36, 2, Color("b88f86"))
	for i in 4:
		_r(30.4 + i * 1.6, 2, 31.0 + i * 1.6, 6, Color("c79e94"))
	_r(30, 6, 36, 7, Color("b88f86"))

## The Sochi Sea Terminal: a white neoclassical station of 1955 with arcades and a tall spire with a golden
## weather vane, palm trees in front.
static func _sochi_seaport() -> void:
	_r(-30, 0, 30, 1, STONE_D)
	_r(-24, 1, 24, 12, WHITE)
	for i in 11:
		_arch_win(-20.0 + i * 4.0, 2, 2.2, 7.5, WIN)
	_r(-24, 11.4, 24, 12.4, STONE)
	# the tower in tiers
	_r(-5, 12, 5, 22, WHITE)
	for x in [-2.5, 2.5]:
		_arch_win(x, 14, 1.6, 6, WIN)
	_r(-5.4, 21.6, 5.4, 22.6, STONE)
	_r(-3.4, 22.6, 3.4, 30, WHITE)
	_arch_win(0, 24, 1.8, 5, WIN)
	_r(-3.8, 29.6, 3.8, 30.6, STONE)
	_r(-2, 30.6, 2, 34, WHITE)
	_poly([-2, 34, 2, 34, 0.3, 48, -0.3, 48], Color("d8c48a"))
	_l(0, 48, 0, 50.5, GOLD, 0.2)
	_poly([0, 50.5, 1.6, 50.0, 0, 49.6], GOLD)
	# palms
	for x in [-28.0, -20.0, 20.0, 28.0]:
		_l(x, 0, x + 0.4, 9, WOOD, 0.5)
		for a in [0.3, 0.9, 1.6, 2.2, 2.8]:
			_l(x + 0.4, 9, x + 0.4 + cos(a) * 3.2, 9 + sin(a) * 1.6 - 0.8, PALM, 0.5)

## The Rinpoche Bagsha datsan on the hill above Ulan-Ude: a white temple of three tiers under golden Tibetan roofs with
## upturned corners, the Dharma wheel on top.
static func _rinpoche_bagsha() -> void:
	_poly([-26, 0, 26, 0, 20, 4, -20, 4], GRASS)
	_r(-14, 4, 14, 14, WHITE)
	for i in 6:
		_r(-11.5 + i * 4.5, 6, -9.5 + i * 4.5, 11, RED)
	_r(-14, 13.4, 14, 14, RED)
	_poly([-17, 14, 17, 14, 18.5, 15.8, 12, 16.6, -12, 16.6, -18.5, 15.8], GOLD)
	_r(-9, 16.6, 9, 22, WHITE)
	_r(-9, 21.4, 9, 22, RED)
	for i in 3:
		_r(-6.0 + i * 5.0, 17.6, -4.0 + i * 5.0, 20.6, RED)
	_poly([-11.5, 22, 11.5, 22, 12.8, 23.6, 8, 24.4, -8, 24.4, -12.8, 23.6], GOLD)
	_r(-4.5, 24.4, 4.5, 27.5, WHITE)
	_poly([-6.5, 27.5, 6.5, 27.5, 7.4, 28.8, 0, 30, -7.4, 28.8], GOLD)
	# the wheel with two deer
	_c(0, 31.4, 1.4, GOLD)
	_c(0, 31.4, 0.8, GOLD_D)
	_poly([-1.4, 30, -3.2, 30, -2.6, 31.4], GOLD)
	_poly([1.4, 30, 3.2, 30, 2.6, 31.4], GOLD)
	# prayer flags on a line
	for k in 8:
		var cols := [Color("2f6fb8"), WHITE, RED, Color("2f8a4f"), Color("f0d24a")]
		_r(-24.0 + k * 1.4, 5.2 - k * 0.1, -23.2 + k * 1.4, 6.2 - k * 0.1, cols[k % 5])

## The Golden Gate of Vladimir, 1164: a white stone gate tower with a huge round arch, buttressed corners and the gate
## church on top under a golden dome.
static func _vladimir_gate() -> void:
	_r(-13, 0, 13, 0.8, STONE_D)
	_r(-11, 0.8, 11, 16, WHITE)
	_arch_win(0, 0.8, 6.4, 13.5, WIN)
	for x in [-11.0, 11.0]:
		_r(x - 1.6, 0.8, x + 1.6, 12, STONE)
		_poly([x - 1.6, 12, x + 1.6, 12, x, 14], STONE_D)
	_r(-11, 15.4, 11, 16.4, STONE_D)
	# the gate church
	_r(-6, 16.4, 6, 22, WHITE)
	for x in [-3.0, 0.0, 3.0]:
		_arch_win(x, 17.4, 1.0, 3.2, WIN)
	_poly([-6.6, 22, 6.6, 22, 5.5, 23.2, -5.5, 23.2], Color("6d8a7c"))
	_r(-2.4, 23.2, 2.4, 25.4, WHITE)
	_poly(_arc(0, 25.4, 2.7, 3.0, 0, PI, 12), GOLD)
	_l(0, 28.4, 0, 30.6, GOLD, 0.2)
	_l(-0.7, 29.8, 0.7, 29.8, GOLD, 0.16)

## The wooden church of St Michael the Archangel in Chita, where Decembrists were married: a log church with a small
## tent-roofed bell tower and green onion domes.
static func _chita_church() -> void:
	_r(-9, 0, 9, 0.6, STONE_D)
	_r(-7, 0.6, 5, 8, WOOD)
	for k in 8:
		_l(-7, 1.2 + k * 0.85, 5, 1.2 + k * 0.85, WOOD_D, 0.15)
	for x in [-4.0, 0.0, 3.0]:
		_r(x - 0.6, 3.5, x + 0.6, 6, WHITE)
		_r(x - 0.4, 3.7, x + 0.4, 5.8, WIN)
	_poly([-7.4, 8, 5.4, 8, -1, 11], GREEN_D)
	_onion_drum(-1, 10.5, 1.1, 1.0, WOOD, GREEN)
	# the bell tower over the porch
	_r(5, 0.6, 9, 11, WOOD)
	_r(5.4, 8, 8.6, 10, WIN)
	_poly([4.6, 11, 9.4, 11, 7.4, 17.5, 6.6, 17.5], GREEN_D)
	_onion_drum(7, 17.5, 0.7, 0.6, WOOD, GREEN)

## St Sophia's Cathedral in Veliky Novgorod (1045-1050): massive white walls with round gables, five silver helmet
## domes and the golden one in the middle.
static func _novgorod_sophia() -> void:
	_r(-18, 0, 18, 1, STONE_D)
	_r(-16, 1, 16, 17, WHITE)
	for i in 5:
		var x := -12.8 + i * 6.4
		_poly(_arc(x, 17, 3.2, 2.6, 0, PI, 8) + [x - 3.2, 17], WHITE)
		_arch_win(x, 6, 1.4, 6, WIN)
		_r(x - 3.3, 1, x - 3.0, 17, STONE)
	# the drums and the helmet domes
	for d in [[-9.0, 19.0, 2.4, SILVER], [9.0, 19.0, 2.4, SILVER], [-4.5, 20.0, 2.0, SILVER], [4.5, 20.0, 2.0, SILVER]]:
		var x: float = d[0]
		var y: float = d[1]
		var r: float = d[2]
		_r(x - r * 0.7, 17, x + r * 0.7, y + 3.0, WHITE)
		_helmet(x, y + 3.0, r, d[3])
	_r(-3.2, 17, 3.2, 25, WHITE)
	_arch_win(-1.4, 20, 0.8, 3.4, WIN)
	_arch_win(1.4, 20, 0.8, 3.4, WIN)
	_helmet(0, 25, 3.6, GOLD)

## The Pskov Krom: grey stone walls and towers above the river, and the white Trinity Cathedral with its tall gilded
## dome rising over them.
static func _pskov_krom() -> void:
	var stone := Color("bdb6a6")
	var stone_d := Color("958e7e")
	_r(-36, 0, 36, 1.6, WATER)
	_poly([-36, 1.6, 36, 1.6, 36, 6, -36, 6], GRASS)
	# the wall with towers
	_r(-34, 6, 34, 16, stone)
	_l(-34, 16, 34, 16, stone_d, 0.5)
	for x in [-30.0, -10.0, 26.0]:
		_r(x - 3, 6, x + 3, 21, stone)
		_r(x - 0.6, 12, x + 0.6, 14, DARK)
		_poly([x - 3.5, 21, x + 3.5, 21, x, 27], WOOD)
	# the cathedral: white body, a big gilded dome on a tall drum, four smaller domes
	_r(0, 16, 20, 38, WHITE)
	for i in 4:
		_arch_win(3.0 + i * 4.7, 20, 1.6, 7, WIN)
		_arch_win(3.0 + i * 4.7, 30, 1.2, 4, WIN)
	_poly([0, 38, 20, 38, 18, 41, 2, 41], GREEN_D)
	for x in [3.5, 16.5]:
		_onion_drum(x, 41, 1.7, 4, WHITE, GOLD_D)
	_onion_drum(10, 41, 4.2, 16, WHITE, GOLD)
	# the belfry beside it
	_r(-8, 16, -2, 30, WHITE)
	for x in [-6.4, -3.6]:
		_arch_win(x, 24, 1.4, 4.5, WIN)
	_poly([-8.4, 30, -1.6, 30, -5, 34], GREEN_D)

## The Vostochny Cosmodrome north of Svobodny: a Soyuz rocket on the launch pad between the service masts, its four
## side boosters flared at the bottom, the taiga behind.
static func _vostochny() -> void:
	var white := Color("eef0f2")
	# the taiga
	for k in 9:
		var x := -20.0 + k * 5.0
		if absf(x) < 8.0:
			continue
		_poly([x - 2.2, 0, x + 2.2, 0, x, 8.0 + (k % 3) * 1.5], Color("2f5a36"))
	_r(-14, 0, 14, 3, CONCRETE)
	_r(-14, 2.6, 14, 3, CONCRETE_D)
	# the service masts
	for x in [-9.0, 9.0]:
		_r(x - 0.8, 3, x + 0.8, 48, RED)
		for k in 10:
			_l(x - 0.8, 3.0 + k * 4.5, x + 0.8, 7.5 + k * 4.5, WHITE, 0.15)
		_l(x, 38, x * 0.25, 40, CONCRETE_D, 0.4)
	# the rocket: core stage, upper stage, fairing, four boosters
	_r(-1.5, 6, 1.5, 34, white)
	_r(-1.5, 22, 1.5, 23, Color("ff8c1a"))
	_r(-1.4, 34, 1.4, 42, white)
	_r(-1.4, 37, 1.4, 38, Color("2f6fb8"))
	_poly([-1.8, 42, 1.8, 42, 1.8, 49, 0, 54, -1.8, 49], white)
	for s in [-1.0, 1.0]:
		_poly([1.5 * s, 25, 1.5 * s, 6, 4.2 * s, 6, 3.4 * s, 18], white)
		_poly([1.5 * s, 25, 2.2 * s, 23, 2.4 * s, 25], white)
		_r(minf(2.2 * s, 4.2 * s), 5, maxf(2.2 * s, 4.2 * s), 6, DARK)
	_r(-1.5, 3, 1.5, 6, DARK)

## The port of Ust-Luga: the rail ferry at its berth with the stern ramp down, rail wagons waiting, and gantry cranes
## over the quay.
static func _ust_luga_port() -> void:
	_r(-40, 0, 40, 2, WATER)
	_r(-40, 1, 40, 1.3, WATER_D)
	_r(-40, 2, -6, 4, CONCRETE)
	# the ferry: a white hull with a blue stripe, the bridge forward
	_poly([-4, 2, 34, 2, 38, 7, 36, 8.5, -4, 8.5], WHITE)
	_r(-4, 4, 36, 5, Color("2f6fb8"))
	_r(18, 8.5, 32, 13, WHITE)
	_windows(19, 31, 10.5, 12, 7, WIN)
	_r(24, 13, 26, 16, RED)
	_poly([-4, 3, -4, 8.5, -8, 4], CONCRETE_D)
	# wagons on the quay
	for i in 4:
		var x := -36.0 + i * 7.5
		_r(x, 4.4, x + 6.6, 8, Color("6f4a3a") if i % 2 == 0 else Color("3f5f7a"))
		_c(x + 1.2, 4.4, 0.6, DARK)
		_c(x + 5.4, 4.4, 0.6, DARK)
	# gantry cranes
	for x in [-30.0, -16.0]:
		_l(x - 4, 4, x - 2, 30, Color("e0a02a"), 0.6)
		_l(x + 4, 4, x + 2, 30, Color("e0a02a"), 0.6)
		_r(x - 3, 28, x + 12, 30, Color("e0a02a"))
		_r(x - 1.5, 30, x + 1.5, 33, Color("e0a02a"))
		_l(x + 9, 28, x + 9, 22, DARK, 0.12)
