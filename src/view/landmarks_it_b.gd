class_name LandmarksItB
extends RefCounted
## Italian landmarks (Messina to Cosenza), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const MARBLE := Color("f1ede4")
const MARBLE_D := Color("d9d3c6")
const STONE := Color("c9bfa7")
const STONE_D := Color("a69c84")
const LIME := Color("e3c98f")
const LIME_D := Color("c4a96f")
const WIN := Color("3a3a40")
const DARK := Color("2b2b30")
const GOLD := Color("e0b43a")
const BRONZE := Color("6e5a3a")
const BRONZE_D := Color("54452c")
const GRASS := Color("6b8f45")
const HILL := Color("7c8a4c")
const ROCK := Color("8d8578")
const WATER := Color("4f86a8")
const WHITE := Color("f4f3ef")
const STEEL := Color("e8ecef")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"it_messina_madonnina": _messina_madonnina()
		"it_trieste_miramare": _trieste_miramare()
		"it_reggio_bronzi": _reggio_bronzi()
		"it_perugia_fontana": _perugia_fontana()
		"it_ancona_arco_traiano": _ancona_arco_traiano()
		"it_pescara_ponte_del_mare": _pescara_ponte_del_mare()
		"it_salerno_arechi": _salerno_arechi()
		"it_bolzano_duomo": _bolzano_duomo()
		"it_lecce_santa_croce": _lecce_santa_croce()
		"it_pisa_torre": _pisa_torre()
		"it_cosenza_castello": _cosenza_castello()
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

## Battlements along a wall top from x0 to x1 at height y.
static func _merlons(x0: float, x1: float, y: float, h: float, col: Color) -> void:
	var n := int((x1 - x0) / 2.4)
	for k in n + 1:
		var x := x0 + k * (x1 - x0) / maxf(1.0, n)
		_r(x - 0.6, y, x + 0.6, y + h, col)

## The Madonna della Lettera at the mouth of Messina's harbour: the old fort's round tower on the pier and the tall
## stele on it, with the gilded statue of the Virgin blessing the ships on top.
static func _messina_madonnina() -> void:
	_r(-8, 0, 8, 2, WATER)
	_r(-7, 2, 7, 4, STONE_D)
	# the fort's tower
	_r(-5, 4, 5, 22, STONE)
	_r(-5.6, 22, 5.6, 24, STONE_D)
	_merlons(-5.4, 5.4, 24, 1.4, STONE_D)
	_windows(-3, 3, 12, 15, 2, WIN)
	# the stele: a stepped shaft narrowing upwards
	_poly([-2.6, 25, 2.6, 25, 2.0, 40, -2.0, 40], MARBLE)
	_r(-2.3, 40, 2.3, 41.5, MARBLE_D)
	_poly([-1.7, 41.5, 1.7, 41.5, 1.3, 52, -1.3, 52], MARBLE)
	_r(-1.6, 52, 1.6, 53.2, MARBLE_D)
	# the golden Madonna with a raised hand
	_poly([-1.0, 53.2, 1.0, 53.2, 0.55, 58.5, -0.55, 58.5], GOLD)
	_c(0, 59.2, 0.55, GOLD)
	_l(0.4, 57.5, 1.4, 59.5, GOLD, 0.3)
	_l(0, 60, 0, 60.8, GOLD, 0.08)

## Miramare Castle: the white limestone castle on its point over the Gulf of Trieste, the square crenellated tower,
## the long front with its tall windows and the terrace down to the sea.
static func _trieste_miramare() -> void:
	_r(-32, 0, 32, 2, WATER)
	_poly([-30, 2, 30, 2, 26, 5, -28, 5], ROCK)
	_r(-26, 5, 24, 7, MARBLE_D)
	# the long front
	_r(-24, 7, 12, 24, WHITE)
	_windows(-22, 10, 10, 15, 8, WIN)
	_windows(-22, 10, 17, 21, 8, WIN)
	_r(-24, 23, 12, 24.5, MARBLE_D)
	for k in 13:
		_r(-24 + k * 3.0, 24.5, -23 + k * 3.0, 26, WHITE)
	# the tower at the seaward end
	_r(12, 5, 22, 33, WHITE)
	_windows(13.5, 20.5, 12, 17, 2, WIN)
	_windows(13.5, 20.5, 22, 27, 2, WIN)
	_r(11.5, 33, 22.5, 34.5, MARBLE_D)
	_merlons(12, 22, 34.5, 1.6, WHITE)
	_l(17, 36, 17, 40, DARK, 0.12)
	_r(17, 38.2, 19.2, 39.8, Color("d6c35a"))

## The Riace Bronzes: the two Greek bronze warriors standing side by side on low marble plinths, one with a helmet
## pushed up on his head, each with a shield on his bent left arm.
static func _reggio_bronzi() -> void:
	for s in [-1, 1]:
		var x: float = s * 2.6
		_r(x - 1.4, 0, x + 1.4, 0.8, MARBLE_D)
		_r(x - 1.2, 0.8, x + 1.2, 0.95, MARBLE)
		# legs, body, arms and head
		_l(x - 0.25, 0.95, x - 0.3, 1.95, BRONZE, 0.28)
		_l(x + 0.25, 0.95, x + 0.15, 1.95, BRONZE, 0.28)
		_poly([x - 0.45, 1.95, x + 0.45, 1.95, x + 0.55, 2.75, x - 0.55, 2.75], BRONZE)
		_l(x + 0.55, 2.7, x + 0.65, 1.95, BRONZE_D, 0.18)
		_l(x - 0.55, 2.7, x - 0.85, 2.25, BRONZE_D, 0.18)
		_c(x, 2.95, 0.22, BRONZE)
		if s > 0:
			_poly([x - 0.25, 3.1, x + 0.25, 3.1, x + 0.1, 3.45, x - 0.15, 3.4], BRONZE_D) # the helmet
		else:
			_c(x, 3.05, 0.2, BRONZE_D) # the curly hair
		# the shield seen edge-on, an oval behind the arm
		_poly(_arc(x - 0.95, 2.3, 0.18, 0.5, 0, TAU, 10), BRONZE_D)

## The Fontana Maggiore in Perugia: the two polygonal marble basins with their carved panels in white and pink, the
## bronze bowl on a column above them and the group of nymphs on top.
static func _perugia_fontana() -> void:
	var pink := Color("e7c9bc")
	for k in 3:
		_r(-8 + k * 0.6, k * 0.35, 8 - k * 0.6, k * 0.35 + 0.35, STONE_D if k % 2 == 0 else STONE)
	# the lower basin with its panels
	_r(-7, 1, 7, 3.2, MARBLE)
	for k in 10:
		var x := -6.6 + k * 1.4
		_r(x, 1.3, x + 1.1, 2.9, pink if k % 2 == 0 else MARBLE_D)
	_r(-7.2, 3.2, 7.2, 3.5, MARBLE_D)
	# the upper basin on columns
	for x in [-3.5, -1.5, 1.5, 3.5]:
		_r(x - 0.2, 3.5, x + 0.2, 4.6, MARBLE_D)
	_r(-4.5, 4.6, 4.5, 6.0, pink)
	_r(-4.6, 6.0, 4.6, 6.25, MARBLE_D)
	# the bronze bowl and the nymphs
	_r(-0.35, 6.25, 0.35, 7.1, BRONZE)
	_poly([-1.6, 7.1, 1.6, 7.1, 0.9, 7.7, -0.9, 7.7], BRONZE)
	for x in [-0.4, 0.0, 0.4]:
		_l(x, 7.7, x, 8.5, BRONZE_D, 0.22)
	_c(0, 8.65, 0.2, BRONZE_D)
	_l(-0.6, 7.6, -0.9, 7.0, Color("9cc4dc"), 0.08)
	_l(0.6, 7.6, 0.9, 7.0, Color("9cc4dc"), 0.08)

## The Arch of Trajan on Ancona's harbour mole: a tall narrow marble arch on a high base reached by steps, with
## pairs of columns on each side and the attic with its inscription.
static func _ancona_arco_traiano() -> void:
	_r(-7, 0, 7, 1.2, STONE_D)
	for k in 4:
		_r(-6 + k * 0.6, 1.2 + k * 0.5, 6 - k * 0.6, 1.7 + k * 0.5, STONE if k % 2 == 0 else STONE_D)
	# the base and the arch
	_r(-5, 3.2, 5, 7.5, MARBLE_D)
	_r(-4.4, 7.5, 4.4, 15.5, MARBLE)
	_arched(0, 7.5, 3.6, 7.2, DARK)
	for x in [-3.7, -2.6, 2.6, 3.7]:
		_r(x - 0.3, 7.5, x + 0.3, 15, MARBLE_D)
	_r(-4.8, 15.5, 4.8, 16.2, MARBLE_D)
	# the attic and its inscription
	_r(-4.4, 16.2, 4.4, 18.6, MARBLE)
	for y in [16.8, 17.5]:
		_l(-3, y, 3, y, STONE_D, 0.12)
	_r(-4.6, 18.6, 4.6, 19, MARBLE_D)

## The Ponte del Mare at Pescara: the white footbridge curving over the river mouth, hung by fans of cables from the
## leaning pylon.
static func _pescara_ponte_del_mare() -> void:
	_r(-60, 0, 60, 2, WATER)
	# the deck rising gently in the middle on thin piers
	var deck := []
	for k in 13:
		var x := -58.0 + k * 116.0 / 12.0
		deck.append(Vector2(x, 4 + 4.5 * (1.0 - pow(x / 58.0, 2))))
	for k in 12:
		var a: Vector2 = deck[k]
		var b: Vector2 = deck[k + 1]
		_poly([a.x, a.y - 0.9, b.x, b.y - 0.9, b.x, b.y, a.x, a.y], WHITE)
	for x in [-45.0, -25.0, 25.0, 45.0]:
		_r(x - 0.4, 0, x + 0.4, 4 + 4.5 * (1.0 - pow(x / 58.0, 2)) - 0.9, STEEL)
	# the pylon leaning back from the middle and its cables
	_poly([3, 8.5, 5, 8.5, -6, 50, -7.5, 50], WHITE)
	for k in 9:
		var t := 0.35 + k * 0.08
		var top := Vector2(4 - 11.0 * t, 8.5 + 41.5 * t)
		var dx := -50.0 + k * 5.0
		_l(top.x, top.y, dx, 4 + 4.5 * (1.0 - pow(dx / 58.0, 2)), STEEL, 0.12)
		var dx2 := 12.0 + k * 5.0
		_l(top.x, top.y, dx2, 4 + 4.5 * (1.0 - pow(dx2 / 58.0, 2)), STEEL, 0.12)

## The Castello di Arechi high over Salerno: the grey stone walls and square towers along the green hilltop, the
## round tower at the end.
static func _salerno_arechi() -> void:
	_poly([-30, 0, 30, 0, 29, 6, 27, 9.5, 8, 14, -12, 13, -24, 9, -28, 5], HILL)
	var wall := Color("a49c8a")
	var wall_d := Color("847c6a")
	_poly([-22, 9, 20, 11, 20, 18, -22, 16], wall)
	_merlons(-22, 20, 17, 1.2, wall_d)
	for x in [-18.0, -2.0, 12.0]:
		_r(x - 3, 10, x + 3, 24, wall)
		_r(x - 3.4, 24, x + 3.4, 25, wall_d)
		_merlons(x - 3, x + 3, 25, 1.2, wall_d)
		_windows(x - 1, x + 1, 18, 20.5, 1, DARK)
	_r(20, 9, 27, 21, wall)
	_poly(_arc(23.5, 21, 3.5, 1.2, 0, PI, 6), wall_d)
	_arched(-10, 10, 2.2, 4, DARK)

## Bolzano Cathedral: the sandstone Gothic church under its steep roof of green, yellow and black glazed tiles in a
## diamond pattern, and the tall openwork spire beside the west front.
static func _bolzano_duomo() -> void:
	var sand := Color("c7a77f")
	var sand_d := Color("a7875f")
	_r(-24, 0, 14, 20, sand)
	for x in [-18.0, -10.0, -2.0, 6.0]:
		_arched(x, 5, 2.4, 11, WIN)
	_r(-24, 19.5, 14, 20.5, sand_d)
	# the steep tiled roof with its diamonds
	_poly([-25, 20.5, 15, 20.5, 15, 22, -5, 38, -25, 22], Color("2f5a3a"))
	for k in 9:
		var x := -21.0 + k * 4.0
		var y := 23.0 if k % 2 == 0 else 27.0
		if x > 12.0 or (x < -5 and y > 22 + (x + 25) * 0.8) or (x >= -5 and y > 38 - (x + 5) * 0.8):
			continue
		_poly([x, y - 1.6, x + 1.6, y, x, y + 1.6, x - 1.6, y], Color("d9b53a"))
	# the tower and its openwork spire
	_r(16, 0, 26, 40, sand)
	_arched(21, 30, 3, 7, WIN)
	_arched(21, 18, 2, 5, WIN)
	_r(15.5, 40, 26.5, 41.5, sand_d)
	for x in [16.5, 25.5]:
		_poly([x - 0.6, 41.5, x + 0.6, 41.5, x, 45], sand_d)
	_poly([17, 41.5, 25, 41.5, 22.2, 62, 19.8, 62], sand)
	for y in [46.0, 51.0, 56.0]:
		var hw: float = 4.0 - (y - 41.5) * 0.19
		_r(21 - hw * 0.6, y, 21 + hw * 0.6, y + 2.2, Color("7a6a55"))
	_poly([19.8, 62, 22.2, 62, 21, 65], sand_d)
	_l(21, 65, 21, 66.5, GOLD, 0.15)

## The Basilica di Santa Croce in Lecce: the honey-coloured Baroque front of local stone, the columns and the
## balcony of carved figures across the middle, the great round rose window and the pediment.
static func _lecce_santa_croce() -> void:
	_r(-17, 0, 17, 1, LIME_D)
	# lower order: three portals between columns
	_r(-16, 1, 16, 13, LIME)
	for x in [-15.0, -9.0, -3.5, 3.5, 9.0, 15.0]:
		_r(x - 0.5, 1, x + 0.5, 13, LIME_D)
	_arched(0, 1, 3.6, 7.5, Color("5a4228"))
	_arched(-6.3, 1, 2.4, 5.5, Color("5a4228"))
	_arched(6.3, 1, 2.4, 5.5, Color("5a4228"))
	# the balcony on its carved brackets
	_r(-17, 13, 17, 14.6, LIME_D)
	for k in 14:
		var x := -15.5 + k * 2.4
		_c(x, 15.4, 0.6, LIME_D)
	_r(-17, 14.6, 17, 15.2, Color("b39a60"))
	# upper order with the rose window
	_r(-11, 15.2, 11, 26, LIME)
	for x in [-10.0, -6.5, 6.5, 10.0]:
		_r(x - 0.45, 15.2, x + 0.45, 26, LIME_D)
	_c(0, 20.6, 4.4, LIME_D)
	_c(0, 20.6, 3.6, Color("6a5236"))
	for k in 12:
		var a := k * TAU / 12.0
		_l(0, 20.6, cos(a) * 3.6, 20.6 + sin(a) * 3.6, LIME_D, 0.25)
	_c(0, 20.6, 1.0, LIME)
	_arched(-8.3, 18, 1.6, 4, Color("6a5236"))
	_arched(8.3, 18, 1.6, 4, Color("6a5236"))
	# the pediment and the curved scrolls beside it
	_poly([-11.5, 26, 11.5, 26, 0, 31], LIME_D)
	_poly([-10, 26.5, 10, 26.5, 0, 30.2], LIME)
	for s in [-1.0, 1.0]:
		_poly([s * 11.0, 15.2] + _arc(s * 16.5, 22, 5.5, 6.8, PI if s > 0 else 0.0, PI * 1.5 if s > 0 else -PI * 0.5, 6), LIME)
		_c(s * 15.8, 16.0, 0.7, LIME_D)
	_l(0, 31, 0, 32.5, LIME_D, 0.25)

## The Leaning Tower of Pisa: the white marble bell tower of six open arcaded galleries over the blind-arcaded base,
## the smaller bell chamber on top, leaning to the south.
static func _pisa_torre() -> void:
	_r(-14, 0, 14, 0.8, GRASS)
	var lean := 0.07
	var h := 8.0
	# storeys: base, six galleries, bell chamber; each one shifted by the lean
	for k in 8:
		var y0 := 0.8 + k * 6.6
		var y1 := y0 + (8.0 if k == 0 else 6.6)
		if k > 0:
			y0 += 1.4
			y1 += 1.4
		var w := 7.5 if k < 7 else 5.2
		var dx0 := y0 * lean
		var dx1 := y1 * lean
		_poly([-w + dx0, y0, w + dx0, y0, w + dx1, y1, -w + dx1, y1], MARBLE)
		_poly([-w - 0.3 + dx1, y1 - 0.5, w + 0.3 + dx1, y1 - 0.5, w + 0.3 + dx1, y1, -w - 0.3 + dx1, y1], MARBLE_D)
		var n := 6 if k < 7 else 4
		var col := MARBLE_D if k == 0 else WIN
		for j in n:
			var x := -w + (j + 0.5) * 2.0 * w / n + (y0 + 0.4) * lean
			_arched(x, y0 + 0.5, 2.0 * w / n * 0.55, (y1 - y0) * 0.7, col)
		h = y1
	_poly(_arc(h * lean, h, 3, 1.2, 0, PI, 6), MARBLE_D)

## The Swabian Castle of Cosenza on the Pancrazio hill above the old town: the long grey walls with the square
## towers at the ends and the round tower, over the old roofs on the slope.
static func _cosenza_castello() -> void:
	_poly([-30, 0, 30, 0, 24, 8, -24, 9], HILL)
	# the old town's roofs on the slope
	for k in 6:
		var x := -26.0 + k * 9.0
		_r(x, 0, x + 6, 3 + (k % 3), Color("d6c3a0"))
		_poly([x - 0.4, 3 + (k % 3), x + 6.4, 3 + (k % 3), x + 3, 4.5 + (k % 3)], Color("a5583b"))
	var wall := Color("9c9484")
	var wall_d := Color("7d7565")
	_r(-20, 8, 18, 17, wall)
	_windows(-16, 14, 12, 14.5, 6, DARK)
	_r(-20.5, 17, 18.5, 18, wall_d)
	_r(-26, 7, -18, 23, wall)
	_r(-26.5, 23, -17.5, 24, wall_d)
	_r(16, 7, 24, 21, wall)
	_r(15.5, 21, 24.5, 22, wall_d)
	_r(-2, 8, 6, 20, wall)
	_poly(_arc(2, 20, 4, 1.5, 0, PI, 6), wall_d)
