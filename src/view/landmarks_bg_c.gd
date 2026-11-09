class_name LandmarksBgC
extends RefCounted
## Bulgarian landmarks (Vratsa to Nesebar, the Rila Monastery and Shipka), drawn with LandmarkPainter's helpers
## (metres from the base point, y up).

const STONE := Color("d6cbb0")
const STONE_D := Color("a99a7a")
const WHITE := Color("f2efe6")
const BEAM := Color("5a3e2a")
const TILE := Color("b5553a")
const TILE_D := Color("8f3e2a")
const GOLD := Color("e0b43a")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const WATER := Color("4f8fc0")
const GRASS := Color("5d8f42")
const TREE := Color("3f6f34")
const BRICK := Color("b0603e")
const LIME := Color("d9d6cc")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"vratsata_gorge": _vratsata()
		"etara_watermill": _etara()
		"kazanlak_thracian_tomb": _thracian_tomb()
		"kazanlak_rose_harvest": _rose_harvest()
		"bansko_holy_trinity": _bansko_trinity()
		"rila_monastery": _rila_monastery()
		"shipka_memorial_church": _shipka_church()
		"pobiti_kamani": _pobiti_kamani()
		"nesebar_pantocrator": _pantocrator()
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

## A gold onion dome sitting on y, r wide at the bulge, with its cross.
static func _onion(x: float, y: float, r: float, col: Color) -> void:
	_poly([x - r * 0.75, y, x - r, y + r * 0.6, x - r * 0.8, y + r * 1.15, x - r * 0.3, y + r * 1.6, x, y + r * 2.1,
		x + r * 0.3, y + r * 1.6, x + r * 0.8, y + r * 1.15, x + r, y + r * 0.6, x + r * 0.75, y], col)
	_l(x, y + r * 2.1, x, y + r * 2.1 + r * 0.9, GOLD, maxf(0.1, r * 0.1))
	_l(x - r * 0.35, y + r * 2.6, x + r * 0.35, y + r * 2.6, GOLD, maxf(0.08, r * 0.08))

## The Vratsata gorge by Vratsa: two sheer grey limestone walls 400 m high with the road and the Leva river squeezed
## between them, bushes clinging to the ledges.
static func _vratsata() -> void:
	var rock := Color("bdb8ac")
	var rock_d := Color("8f8a7e")
	_poly([-60, 0, -10, 0, -8, 18, -11, 34, -7, 50, -12, 62, -26, 64, -45, 58, -60, 50], rock)
	_poly([60, 0, 10, 0, 8, 16, 12, 30, 7, 46, 10, 60, 24, 63, 44, 56, 60, 46], rock)
	_poly([-10, 0, -8, 18, -11, 34, -7, 50, -12, 62, -14, 60, -12, 46, -15, 30, -12, 14, -14, 0], rock_d)
	_poly([10, 0, 8, 16, 12, 30, 7, 46, 10, 60, 13, 56, 11, 44, 15, 28, 12, 12, 14, 0], rock_d)
	for i in 7:
		var y := 8.0 + i * 8.0
		_l(-58, y, -16, y + 2.0, rock_d, 0.6)
		_l(16, y + 1.0, 58, y - 1.0, rock_d, 0.6)
	for p in [[-30.0, 22.0], [-44.0, 38.0], [-22.0, 48.0], [26.0, 18.0], [38.0, 34.0], [22.0, 44.0]]:
		_c(p[0], p[1], 2.2, TREE)
	_r(-10, 0, 10, 2.5, Color("6f8f4a"))
	_r(-6, 0, 6, 1.2, Color("55595e"))
	_l(-6, 0.6, 6, 0.6, Color("f2efe6"), 0.12)
	_r(6, 0, 9, 1.0, WATER)

## The Etar open-air museum near Gabrovo: a Revival craftsman's house of dark timber and white plaster over the
## stream, and the water mill with its wooden wheel turning under the chute.
static func _etara() -> void:
	_r(-15, 0, 15, 1.2, WATER)
	_r(-15, 1.2, -4, 2, GRASS)
	_r(-14, 2, -4, 5.5, STONE)
	_r(-14.8, 5.5, -3.2, 9, WHITE)
	_r(-14.8, 5.5, -3.2, 5.8, BEAM)
	for x in [-14.8, -11.0, -7.0, -3.2]:
		_l(x, 5.5, x, 9, BEAM, 0.25)
	_windows(-13.5, -4.5, 6.4, 8.4, 3, WIN)
	_r(-11, 2, -9, 4.4, BEAM)
	_poly([-16.4, 9, -1.6, 9, -6, 11.5, -12, 11.5], TILE)
	# the mill house and wheel
	_r(2, 1.2, 12, 6.5, Color("8a6440"))
	for i in 5:
		_l(2, 1.8 + i * 1.1, 12, 1.8 + i * 1.1, Color("6a4a30"), 0.1)
	_poly([1, 6.5, 13, 6.5, 7, 9.5], Color("6e5a46"))
	_r(6, 2.5, 8, 4.5, DARK)
	_l(-3, 7.5, 0.2, 5.8, Color("6a4a30"), 0.6)
	_c(-0.5, 3.3, 2.6, Color("6a4a30"))
	_c(-0.5, 3.3, 2.0, Color("8a6440"))
	for k in 8:
		var a := k * TAU / 8.0
		_l(-0.5, 3.3, -0.5 + cos(a) * 2.6, 3.3 + sin(a) * 2.6, BEAM, 0.18)
	_l(0.0, 5.8, 0.2, 1.4, Color("9cc8e6"), 0.35)

## The Thracian tomb of Kazanlak: the grassy mound, cut away to show the beehive chamber of brick inside with its
## frescoes, a funeral feast and a frieze of horses and chariots running round the dome.
static func _thracian_tomb() -> void:
	_poly(_arc(0, 0, 14, 9, 0, PI, 20), Color("6f9a4a"))
	_poly(_arc(0, 0, 12, 7.6, 0, PI, 18), Color("8aaa5a"))
	# the cut-away chamber
	_poly(_arc(2, 0.6, 4.2, 6.2, 0, PI, 16), Color("4a3428"))
	_poly(_arc(2, 0.6, 3.6, 5.6, 0, PI, 16), Color("e0c89a"))
	for k in 6:
		var x := -0.8 + k * 1.1
		var y := 4.2 - absf(x - 2.0) * 0.35
		_l(x, y, x + 0.6, y + 0.3, Color("8a3a2a"), 0.3)
		_l(x + 0.1, y - 0.2, x + 0.1, y - 0.6, Color("8a3a2a"), 0.12)
	_r(0.0, 1.4, 4.0, 2.6, Color("b85a3c"))
	_c(0.6, 3.0, 0.3, Color("5a3a28"))
	_c(3.4, 3.0, 0.3, Color("5a3a28"))
	# the corridor
	_r(-9, 0.6, -1.6, 2.6, Color("4a3428"))
	_r(-8.6, 0.8, -1.6, 2.2, Color("b88a5a"))
	_r(-14, 0, 14, 0.6, GRASS)

## The rose harvest in the Rose Valley at Kazanlak: rows of Damask rose bushes in bloom and a picker in folk dress,
## white blouse, red apron and headscarf, with her wicker basket.
static func _rose_harvest() -> void:
	_r(-8, 0, 8, 0.25, Color("7a6a4a"))
	for row in 2:
		var y0 := 0.25 + row * 0.15
		for i in 9:
			var x := -7.4 + i * 1.8 + row * 0.9
			_c(x, y0 + 0.55, 0.65, Color("3f7a34"))
			for k in 5:
				var a := k * 1.3 + i
				_c(x + cos(a) * 0.45, y0 + 0.6 + sin(a) * 0.35, 0.12, Color("e0608a"))
	# the picker
	var px := 1.6
	_poly([px - 0.38, 0.2, px + 0.38, 0.2, px + 0.24, 0.95, px - 0.24, 0.95], Color("2a2a2a"))
	_poly([px - 0.3, 0.3, px + 0.3, 0.3, px + 0.22, 0.95, px - 0.22, 0.95], Color("c23b2e"))
	_r(px - 0.24, 0.95, px + 0.24, 1.42, WHITE)
	_c(px, 1.6, 0.18, Color("e0b896"))
	_poly([px - 0.2, 1.62, px + 0.2, 1.62, px + 0.24, 1.78, px, 1.84, px - 0.24, 1.78], Color("c23b2e"))
	_l(px + 0.2, 1.3, px + 0.55, 1.0, WHITE, 0.09)
	_poly([px + 0.4, 0.75, px + 0.95, 0.75, px + 0.85, 1.05, px + 0.5, 1.05], Color("b8892a"))
	_c(px + 0.68, 1.06, 0.12, Color("e0608a"))

## The Holy Trinity Church in Bansko: a long stone church behind its wall, a broad red roof and the tall stone bell
## tower with a clock, under the snowy peaks of Pirin.
static func _bansko_trinity() -> void:
	_poly([-22, 0, -22, 16, -12, 30, -4, 22, 6, 34, 16, 24, 22, 28, 22, 0], Color("7f8a96"))
	_poly([-12, 30, -14.5, 26.5, -10, 27.5], WHITE)
	_poly([6, 34, 3, 29.5, 9, 30], WHITE)
	_poly([22, 28, 19.5, 25.5, 22, 25], WHITE)
	_r(-22, 0, 22, 2.4, STONE_D)
	var wall := Color("cfc2a6")
	_r(-18, 0, 12, 9, wall)
	_poly([-19.5, 9, 13.5, 9, 10, 13, -16, 13], TILE)
	for i in 5:
		_arch_win(-15.0 + i * 5.5, 3, 1.4, 4, WIN)
	_r(-22, 0, 22, 1.6, Color("bdb092"))
	# the bell tower
	_r(13, 0, 19, 26, Color("bfb194"))
	for y in [6.0, 12.0, 18.0]:
		_l(13, y, 19, y, STONE_D, 0.25)
	_c(16, 20.5, 1.6, WHITE)
	_l(16, 20.5, 16, 21.6, DARK, 0.15)
	_l(16, 20.5, 16.8, 20.2, DARK, 0.12)
	_arch_win(16, 23, 1.6, 2.6, WIN)
	_r(12.6, 26, 19.4, 26.8, STONE_D)
	_poly([12.8, 26.8, 19.2, 26.8, 16, 32], Color("6a7076"))
	_l(16, 32, 16, 33.5, GOLD, 0.2)

## The Rila Monastery: the striped black, white and red arcades of the church with its domes, the wooden galleries of
## the cells around the courtyard, and Hrelyo's stone tower, under the forested Rila mountains.
static func _rila_monastery() -> void:
	_poly([-45, 0, -45, 24, -30, 36, -14, 30, 2, 42, 18, 32, 32, 38, 45, 26, 45, 0], Color("4f6f3a"))
	_poly([-30, 36, -33, 33, -27, 33.5], WHITE)
	_poly([2, 42, -1.5, 38, 5, 38.5], WHITE)
	# the cell wings with their galleries
	_r(-44, 0, 44, 14, WHITE)
	for f in 3:
		var y := 1.0 + f * 4.4
		_r(-44, y + 3.2, 44, y + 3.6, BEAM)
		for i in 22:
			var x := -42.0 + i * 4.0
			_arch_win(x, y, 2.6, 3.0, Color("6a4a30") if f > 0 else Color("8a7a60"))
	_poly([-45.5, 14, 45.5, 14, 43, 16, -43, 16], Color("6a5a4a"))
	# Hrelyo's tower
	_r(18, 0, 26, 24, Color("a99a7a"))
	for y in [5.0, 10.0, 15.0, 20.0]:
		_l(18, y, 26, y, Color("8a7a5a"), 0.3)
	_r(17.5, 24, 26.5, 25, Color("8a7a5a"))
	_poly([18, 25, 26, 25, 22, 28], TILE_D)
	_r(21.4, 17, 22.6, 19.5, WIN)
	# the church
	_r(-22, 0, 10, 13, Color("e8dcc0"))
	_r(-22, 0, 10, 6, Color("f4f1ea"))
	for i in 9:
		var x := -20.0 + i * 3.5
		var stripes := [DARK, WHITE, Color("b33a2e")]
		for k in 5:
			var a0 := PI * k / 5.0
			var a1 := PI * (k + 1) / 5.0
			_poly([x, 4.2] + _arc(x, 4.2, 1.6, 1.6, a0, a1, 2), stripes[k % 3])
		_r(x - 1.3, 0, x + 1.3, 4.2, Color("4a3a30"))
		_r(x + 1.4, 0, x + 1.9, 5.6, WHITE)
	_poly([-23, 13, 11, 13, 9, 15, -21, 15], Color("6a6e72"))
	for d in [[-16.0, 2.4, 3.0], [-6.0, 3.6, 4.4], [4.0, 2.4, 3.0]]:
		_r(d[0] - d[1], 15, d[0] + d[1], 15 + d[2], Color("e8dcc0"))
		for k in 3:
			_l(d[0] - d[1] + (k + 0.5) * d[1] * 2.0 / 3.0, 15.6, d[0] - d[1] + (k + 0.5) * d[1] * 2.0 / 3.0, 14.4 + d[2], DARK, 0.25)
		_poly(_arc(d[0], 15 + d[2], d[1] * 1.08, d[1] * 0.95, 0, PI, 10), Color("5a5e62"))
		_l(d[0], 15 + d[2] + d[1] * 0.95, d[0], 16.5 + d[2] + d[1], GOLD, 0.25)

## The Shipka Memorial Church of the Nativity: a Russian-style church of red brick and white trim with five gilded
## onion domes and the tall bell tower over the entrance crowned by the largest.
static func _shipka_church() -> void:
	var red := Color("b8483a")
	_r(-15, 0, 15, 1, STONE_D)
	_r(-11, 1, 13, 13, red)
	for x in [-11.0, -3.0, 5.0, 13.0]:
		_r(x - 0.4, 1, x + 0.4, 13, WHITE)
	_r(-11, 12.4, 13, 13.4, WHITE)
	for x in [-7.0, 1.0, 9.0]:
		_arch_win(x, 5, 1.6, 4.4, WIN)
		_poly([x - 2.2, 13.4, x + 2.2, 13.4, x, 15.6], WHITE)
	# five domes on drums
	for d in [[-6.0, 1.3], [8.0, 1.3], [1.0, 2.0], [-3.0, 1.0], [5.0, 1.0]]:
		var h: float = 15.6 if d[1] > 1.6 else 13.4
		_r(d[0] - d[1] * 0.75, 13.4, d[0] + d[1] * 0.75, h + 2.0, red)
		_r(d[0] - d[1] * 0.8, h + 1.6, d[0] + d[1] * 0.8, h + 2.0, WHITE)
		_onion(d[0], h + 2.0, d[1] * 1.3, GOLD)
	# the bell tower
	_r(-15, 1, -10, 22, red)
	_r(-15.4, 21.4, -9.6, 22.2, WHITE)
	_poly([-14.4, 1, -10.6, 1, -10.6, 5] + _arc(-12.5, 5, 1.9, 1.9, 0, PI, 6), Color("5a3a28"))
	_arch_win(-12.5, 15, 1.8, 4, WIN)
	_r(-14.4, 22.2, -10.6, 26, red)
	_arch_win(-12.5, 22.8, 1.4, 2.6, WIN)
	_poly([-14.6, 26, -10.4, 26, -11.4, 28.4, -13.6, 28.4], WHITE)
	_onion(-12.5, 28.4, 1.8, GOLD)

## Pobiti Kamani near Devnya: hollow stone columns standing out of the sand like a petrified forest.
static func _pobiti_kamani() -> void:
	_r(-22, 0, 22, 1, Color("d9c48a"))
	var cols := [[-19.0, 1.2, 4.5], [-15.5, 0.9, 6.5], [-12.0, 1.4, 3.6], [-8.5, 1.0, 7.4], [-5.0, 1.3, 5.2], [-1.5, 0.8, 3.0],
		[2.0, 1.2, 6.8], [5.5, 1.5, 5.6], [9.0, 0.9, 4.0], [12.5, 1.3, 7.0], [16.0, 1.0, 4.8], [19.5, 1.2, 3.4]]
	for c in cols:
		var x: float = c[0]
		var r: float = c[1]
		var h: float = c[2]
		_poly([x - r, 0.5, x + r, 0.5, x + r * 0.85, h, x + r * 0.3, h + 0.5, x - r * 0.4, h + 0.3, x - r * 0.9, h - 0.2], LIME)
		_poly([x + r * 0.35, 0.5, x + r, 0.5, x + r * 0.85, h, x + r * 0.3, h + 0.5], Color("b8b4a8"))
		_c(x - r * 0.2, h * 0.6, r * 0.3, Color("a8a49a"))
	_r(-22, 0, 22, 0.6, Color("cdb67a"))
	for x in [-20.5, 7.5, 21.0]:
		_c(x, 1.0, 0.8, Color("7a8a4a"))

## The Church of Christ Pantocrator in Nesebar: bands of red brick and white stone, blind arches, rows of green
## ceramic rosettes, the bell tower over the west end and a dome on its drum.
static func _pantocrator() -> void:
	_r(-10, 0, 10, 0.5, STONE_D)
	_r(-7, 0.5, 9, 9, WHITE)
	for y in [1.5, 3.0, 4.5, 6.0, 7.5]:
		_r(-7, y, 9, y + 0.5, BRICK)
	for i in 5:
		var x := -5.0 + i * 3.2
		var pts := _arc(x, 6.4, 1.3, 1.3, 0, PI, 6)
		for k in range(0, pts.size() - 2, 2):
			_l(pts[k], pts[k + 1], pts[k + 2], pts[k + 3], BRICK, 0.35)
		_l(x - 1.3, 1, x - 1.3, 6.4, BRICK, 0.35)
		_l(x + 1.3, 1, x + 1.3, 6.4, BRICK, 0.35)
		_arch_win(x, 2.6, 0.9, 2.6, WIN)
		_c(x + 1.6, 8.2, 0.32, Color("3f8a5a"))
	_poly([-7.5, 9, 9.5, 9, 8.5, 10, -6.5, 10], TILE)
	_r(0, 10, 3.6, 12.4, WHITE)
	_r(0, 11, 3.6, 11.4, BRICK)
	_poly(_arc(1.8, 12.4, 2.0, 1.5, 0, PI, 8), TILE)
	# the bell tower over the west end
	_r(-10, 0.5, -6.5, 15, WHITE)
	for y in [3.0, 6.5, 10.0, 13.5]:
		_r(-10, y, -6.5, y + 0.5, BRICK)
	_arch_win(-8.25, 11, 1.2, 2.2, WIN)
	_arch_win(-8.25, 7.4, 1.2, 2.2, WIN)
	_poly([-10.4, 15, -6.1, 15, -8.25, 16], TILE)
