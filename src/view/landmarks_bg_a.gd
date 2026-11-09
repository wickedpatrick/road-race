class_name LandmarksBgA
extends RefCounted
## Bulgarian landmarks (Sofia to Sliven), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const STONE := Color("ddd3bd")
const STONE_D := Color("b3a68a")
const MARBLE := Color("ece6d8")
const GOLD := Color("e0b43a")
const GOLD_D := Color("b8892a")
const GREEN_DOME := Color("4f9a7c")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const WATER := Color("4f8fc0")
const GRASS := Color("5d8f42")
const TREE := Color("3f6f34")
const BRONZE := Color("5d6b4f")
const CONCRETE := Color("a9a69c")
const WOOD := Color("8a6440")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"alexander_nevsky_cathedral": _alexander_nevsky()
		"plovdiv_roman_theatre": _plovdiv_theatre()
		"varna_dormition_cathedral": _varna_cathedral()
		"burgas_sea_bridge": _burgas_bridge()
		"ruse_liberty_monument": _ruse_liberty()
		"ruse_danube_bridge": _danube_bridge()
		"stara_zagora_defenders": _stara_zagora_defenders()
		"pleven_panorama": _pleven_panorama()
		"halkata_rock": _halkata()
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

## A round-topped window (or door) from y0 up to the top of its arch.
static func _arch_win(x: float, y0: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.5, y0, x + w * 0.5, y0, x + w * 0.5, y0 + h - w * 0.5] + _arc(x, y0 + h - w * 0.5, w * 0.5, w * 0.5, 0, PI, 6), col)

## A dome on a drum: the drum from y to y + dh, the dome above it, a gold cross on top.
static func _domed_drum(x: float, y: float, r: float, dh: float, wall: Color, dome: Color) -> void:
	_r(x - r, y, x + r, y + dh, wall)
	for i in 3:
		_arch_win(x - r * 0.5 + i * r * 0.5, y + dh * 0.25, r * 0.22, dh * 0.55, WIN)
	_r(x - r * 1.08, y + dh - 0.4, x + r * 1.08, y + dh, STONE_D)
	_poly(_arc(x, y + dh, r * 1.05, r * 1.15, 0, PI, 12), dome)
	_l(x, y + dh + r * 1.15, x, y + dh + r * 1.15 + 2.2, GOLD, 0.3)
	_l(x - 0.7, y + dh + r * 1.15 + 1.5, x + 0.7, y + dh + r * 1.15 + 1.5, GOLD, 0.22)

## The Alexander Nevsky Cathedral in Sofia: the neo-Byzantine cream stone church with its gilded main dome on a tall
## drum, green half-domes and side domes, and the bell tower with a small gold dome at the west end.
static func _alexander_nevsky() -> void:
	_r(-27, 0, 34, 16, STONE)
	_r(-27, 15.4, 34, 16.4, STONE_D)
	for i in 9:
		_arch_win(-22.0 + i * 6.5, 3, 2.0, 7.5, WIN)
	# green half-domes over the arms and the apse
	for x in [-14.0, 4.0, 22.0]:
		_r(x - 6, 16, x + 6, 19, STONE)
		_poly(_arc(x, 19, 6.3, 4.2, 0, PI, 12), GREEN_DOME)
	_r(30, 0, 36, 13, STONE)
	_poly(_arc(33, 13, 3.2, 2.8, 0, PI, 8), GREEN_DOME)
	# the side domes and the great gilded dome
	_domed_drum(-12, 19, 3.6, 5, STONE, GREEN_DOME)
	_domed_drum(20, 19, 3.6, 5, STONE, GREEN_DOME)
	_r(-9, 19, 13, 24, STONE)
	_domed_drum(2, 24, 7.2, 9, STONE, GOLD)
	_poly(_arc(2, 33, 7.6, 8.3, 0.15, PI * 0.45, 6) + [2.0, 33.0], GOLD_D.lerp(GOLD, 0.5))
	# the bell tower
	_r(-36, 0, -27, 36, STONE)
	_r(-36.6, 35.4, -26.4, 36.6, STONE_D)
	for y in [8.0, 18.0, 27.0]:
		_arch_win(-31.5, y, 3.2, 6.5, WIN)
	_r(-34.5, 36.6, -28.5, 41, STONE)
	_arch_win(-31.5, 37.4, 2.0, 3.2, WIN)
	_poly(_arc(-31.5, 41, 3.4, 4.2, 0, PI, 10), GOLD)
	_l(-31.5, 45.2, -31.5, 49.5, GOLD, 0.35)
	_l(-32.6, 48, -30.4, 48, GOLD, 0.28)
	_poly([-2.6, 0, 2.6, 0, 2.6, 9] + _arc(0, 9, 2.6, 2.6, 0, PI, 8), Color("4a3a2a"))

## The Roman theatre of Philippopolis in Plovdiv: marble rows of seats climbing the hillside in a bowl, the
## two-storey stage building with its columns in front.
static func _plovdiv_theatre() -> void:
	_poly([-32, 0, -32, 13, -24, 19, -10, 22, 10, 22, 24, 19, 32, 12, 32, 0], Color("8a9a5a"))
	# the cavea seen from the front: a bowl of marble rows curving down to the orchestra
	_poly(_arc(0, 19, 29, 16, PI, TAU, 24) + [29.0, 20.5, -29.0, 20.5], MARBLE)
	for i in 10:
		var rx := 9.0 + i * 2.2
		var ry := 3.4 + i * 1.4
		var pts := _arc(0, 19, rx, ry, PI, TAU, 18)
		var col := Color("c9c0aa") if i % 3 == 2 else Color("ddd5c2")
		for k in range(0, pts.size() - 2, 2):
			_l(pts[k], pts[k + 1], pts[k + 2], pts[k + 3], col, 0.35)
	for a in [PI * 1.2, PI * 1.38, PI * 1.62, PI * 1.8]:
		_l(cos(a) * 9.0, 19 + sin(a) * 3.4, cos(a) * 29.0, 19 + sin(a) * 16.0, STONE_D, 0.5)
	_r(-29, 19.8, 29, 20.6, STONE_D)
	_poly(_arc(0, 3.2, 9, 1.8, PI, TAU, 12), Color("e6dccb"))
	# the stage building (scaenae frons)
	_r(-20, 0, 20, 4.2, STONE)
	_r(-20, 4.2, 20, 4.8, STONE_D)
	_r(-16, 4.8, 16, 8.4, STONE)
	_r(-16, 8.4, 16, 9, STONE_D)
	for i in 15:
		var x := -19.0 + i * 2.7
		_r(x - 0.25, 0.3, x + 0.25, 4.2, Color.WHITE)
	for i in 11:
		var x := -15.0 + i * 3.0
		_r(x - 0.22, 4.8, x + 0.22, 8.4, Color.WHITE)
	_arch_win(0, 0, 2.4, 3.6, WIN)
	_arch_win(-9, 0, 1.6, 3.0, WIN)
	_arch_win(9, 0, 1.6, 3.0, WIN)

## The Dormition Cathedral in Varna: cream walls with red bands, a big gilded dome over the middle, two smaller gold
## domes and the bell tower over the west door with its own golden cupola.
static func _varna_cathedral() -> void:
	var wall := Color("eadcb8")
	var band := Color("b85a3c")
	_r(-12, 0, 20, 15, wall)
	for y in [5.0, 10.5]:
		_r(-12, y, 20, y + 0.5, band)
	_r(-12.5, 15, 20.5, 16, band)
	for i in 5:
		_arch_win(-8.0 + i * 6.5, 6.5, 1.6, 3.6, WIN)
		_arch_win(-8.0 + i * 6.5, 1, 1.6, 3.6, WIN)
	_domed_drum(4, 16, 5, 7, wall, GOLD)
	_domed_drum(-6, 16, 2.6, 3.5, wall, GOLD)
	_domed_drum(15, 16, 2.6, 3.5, wall, GOLD)
	# the bell tower
	_r(-20, 0, -12, 25, wall)
	for y in [8.0, 14.0, 20.0]:
		_r(-20, y, -12, y + 0.5, band)
	_arch_win(-16, 15, 2.6, 4.6, WIN)
	_arch_win(-16, 21, 2.0, 3.2, Color("6a5a40"))
	_r(-19, 25, -13, 28, wall)
	_poly(_arc(-16, 28, 3.6, 4.4, 0, PI, 10), GOLD)
	_l(-16, 32.4, -16, 37, GOLD, 0.3)
	_l(-17, 35.6, -15, 35.6, GOLD, 0.24)
	_poly([-17.6, 0, -14.4, 0, -14.4, 5] + _arc(-16, 5, 1.6, 1.6, 0, PI, 6), Color("5a3a28"))

## The Burgas pier: the long wooden walkway on piles from the Sea Garden's trees out into the Black Sea, its lamps
## and the round shelter at the far end, gulls overhead.
static func _burgas_bridge() -> void:
	_r(-40, 0, 40, 2.4, WATER)
	_poly([-40, 0, -40, 4, -32, 3.6, -28, 2.4, -28, 0], Color("d9c48a"))
	for x in [-38.0, -34.5, -31.0]:
		_r(x - 0.2, 3.5, x + 0.2, 5, WOOD)
		_c(x, 6.6, 2.2, TREE)
	# the walkway
	_r(-30, 3.2, 34, 3.8, WOOD)
	for i in 22:
		var x := -28.0 + i * 3.0
		_r(x - 0.15, 0, x + 0.15, 3.2, Color("6a4a30"))
	_l(-30, 4.8, 34, 4.8, Color("e8e2d2"), 0.12)
	for i in 8:
		var x := -26.0 + i * 8.0
		_l(x, 3.8, x, 6.6, DARK, 0.12)
		_c(x, 6.7, 0.3, Color("f6f0c8"))
	# the shelter at the end
	_r(28, 3.8, 38, 4.4, WOOD)
	for x in [28.6, 33.0, 37.4]:
		_r(x - 0.2, 4.4, x + 0.2, 8, Color.WHITE)
	_poly([27, 8, 39, 8, 36, 10, 30, 10], Color("2f6a9a"))
	_l(33, 10, 33, 12, DARK, 0.1)
	for g in [[-6.0, 11.0], [4.0, 12.5], [12.0, 10.5]]:
		_l(g[0] - 0.8, g[1] + 0.3, g[0], g[1], DARK, 0.12)
		_l(g[0], g[1], g[0] + 0.8, g[1] + 0.3, DARK, 0.12)

## The Monument of Liberty in Ruse: a tall column on a stone pedestal guarded by two bronze lions, topped by a bronze
## woman holding up a sword.
static func _ruse_liberty() -> void:
	_r(-6, 0, 6, 1.2, STONE_D)
	_r(-4, 1.2, 4, 7, Color("c8c0aa"))
	_r(-4.4, 6.6, 4.4, 7.4, STONE_D)
	# the lions on either side
	for s in [-1.0, 1.0]:
		var x: float = s * 4.8
		_r(x - 1.4, 1.2, x + 1.4, 2.4, BRONZE)
		_poly([x + 0.4 * s, 2.2, x + 1.7 * s, 2.2, x + 1.5 * s, 3.6, x + 0.6 * s, 3.4], Color("4a5640"))
		_c(x + 1.25 * s, 3.1, 0.55, BRONZE)
		_l(x - 1.4 * s, 2.2, x - 2.0 * s, 2.9, BRONZE, 0.2)
	# the column
	_r(-1.4, 7.4, 1.4, 8.4, STONE)
	_r(-1.0, 8.4, 1.0, 21, STONE)
	for x in [-0.5, 0.0, 0.5]:
		_l(x, 8.6, x, 20.8, STONE_D, 0.08)
	_r(-1.5, 21, 1.5, 22, STONE_D)
	# the woman with the sword
	_poly([-0.9, 22, 0.9, 22, 0.5, 25, -0.5, 25], BRONZE)
	_c(0, 25.6, 0.45, BRONZE)
	_l(0.4, 24.6, 1.2, 26.6, BRONZE, 0.3)
	_l(1.2, 26.4, 1.5, 28, Color("8a8f86"), 0.18)
	_l(-0.4, 24.4, -1.1, 23.2, BRONZE, 0.28)

## The Danube Bridge (Friendship Bridge) between Ruse and Giurgiu: steel trusses on stone piers over the wide river,
## the road on top and the railway below, and the tall concrete towers at the Bulgarian end.
static func _danube_bridge() -> void:
	_r(-75, 0, 75, 4, WATER)
	_r(-75, 0, -60, 7, GRASS)
	_r(60, 0, 75, 5, GRASS)
	var steel := Color("5f7a8a")
	for i in 5:
		var x0 := -56.0 + i * 23.0
		var x1 := x0 + 21.0
		_r(x1 - 0.2, 0, x1 + 2.2, 9, STONE_D)
		_l(x0, 9.5, x1, 9.5, steel, 0.5)
		_l(x0, 14.5, x1, 14.5, steel, 0.5)
		for k in 7:
			var a := x0 + k * 3.0
			_l(a, 9.5, a + 1.5, 14.5, steel, 0.25)
			_l(a + 1.5, 14.5, a + 3.0, 9.5, steel, 0.25)
	_r(-59, 0, -56, 9, STONE_D)
	_r(-58, 14.5, 59, 15.2, Color("4a4e52"))
	# the towers at the Bulgarian end
	for x in [-66.0, -60.5]:
		_r(x - 2, 7, x + 2, 28, Color("cfc8b4"))
		_windows(x - 1.4, x + 1.4, 12, 26, 2, WIN)
		_r(x - 2.4, 28, x + 2.4, 29.2, STONE_D)
		_poly([x - 1.4, 29.2, x + 1.4, 29.2, x, 31.5], Color("b84a3a"))
	_r(-68, 14.5, -58, 15.2, Color("4a4e52"))

## The Defenders of Stara Zagora on the Bunarja hill: a huge concrete group of fighters and the carved Samara Flag
## rising above them, on terraced steps.
static func _stara_zagora_defenders() -> void:
	_poly([-24, 0, 24, 0, 18, 3, -18, 3], GRASS)
	_r(-14, 3, 14, 4, Color("c8c2b2"))
	_r(-11, 4, 11, 5, Color("c8c2b2"))
	# the fighters, angular concrete blocks
	var figs := [[-17.0, 13.0, -9.0, 16.0], [-9.0, 18.0, -3.0, 20.0], [3.0, 19.0, 9.0, 17.0], [9.0, 14.0, 16.0, 12.0]]
	for f in figs:
		_poly([f[0], 5, f[2], 5, f[2] - 0.6, f[3], (f[0] + f[2]) * 0.5, f[3] + 2.0, f[0] + 0.6, f[1]], CONCRETE)
		_c((f[0] + f[2]) * 0.5, maxf(f[1], f[3]) + 1.2, 1.2, Color("9c998f"))
		_l(f[0] + 1, 7, f[2] - 1, 9, Color("8a877e"), 0.25)
	# the flag on its staff
	_r(-0.5, 5, 0.5, 29, Color("9c998f"))
	_poly([0.5, 28.5, 5, 27.4, 9, 28.2, 13, 26.6, 13.6, 21.6, 9.4, 23, 5.4, 22.2, 0.5, 23.5], Color("c2bdb0"))
	_poly([0.5, 28.5, 5, 27.4, 9, 28.2, 13, 26.6, 13.1, 25.4, 9, 26.8, 5, 26.0, 0.5, 27.0], Color("d4d0c4"))
	for x in [4.0, 8.0, 11.5]:
		_l(x, 23.6, x + 0.4, 27.2, Color("a9a69c"), 0.25)
	_l(6.8, 23.6, 6.8, 27.0, Color("8a877e"), 0.3)
	_l(5.6, 25.8, 8.0, 25.6, Color("8a877e"), 0.3)

## The Pleven Panorama: the round stone hall on Skobelev Park's hill, its ribbed drum and glass lantern on top, and
## the entrance block with the dates of 1877.
static func _pleven_panorama() -> void:
	_r(-22, 0, 22, 1.5, GRASS)
	var wall := Color("e2dccb")
	_r(-15, 1.5, 15, 15, wall)
	_poly(_arc(0, 15, 15, 3, 0, PI, 16), Color("b8b2a2"))
	for i in 9:
		var x := -13.0 + i * 3.25
		_r(x - 0.35, 1.5, x + 0.35, 15, Color("cbc4b0"))
	_r(-15, 9, 15, 9.6, STONE_D)
	_r(-4, 17, 4, 20, Color("9cc8e6"))
	_l(-4, 18.5, 4, 18.5, DARK, 0.12)
	_poly(_arc(0, 20, 4.2, 2.4, 0, PI, 10), Color("6a7a80"))
	# the entrance
	_r(-5, 1.5, 5, 7.5, Color("cfc8b4"))
	_poly([-5.5, 7.5, 5.5, 7.5, 0, 9.5], STONE_D)
	_r(-1.6, 1.5, 1.6, 5.5, WIN)
	for x in [-19.0, 19.0]:
		_c(x, 4.5, 2.6, TREE)

## Halkata, the Ring, on the Blue Rocks above Sliven: a bluish rock ridge with pines, and the stone ring standing on
## its crest with the sky showing through.
static func _halkata() -> void:
	var rock := Color("7f8f9c")
	var rock_d := Color("5f6d7a")
	_poly([-20, 0, -20, 8, -12, 13, -4, 15, 4, 14, 12, 11, 20, 7, 20, 0], rock_d)
	_poly([-18, 6, -10, 11, -3, 13.5, 2, 12.5, -6, 10, -14, 7], rock)
	for x in [-16.0, -10.0, 9.0, 15.0]:
		_poly([x - 1.2, 9.0 - absf(x) * 0.2, x + 1.2, 9.0 - absf(x) * 0.2, x, 12.5 - absf(x) * 0.2], TREE)
	# the ring
	var pts := _arc(0, 19.5, 5, 5.5, 0, TAU, 28)
	for i in range(0, pts.size() - 2, 2):
		_l(pts[i], pts[i + 1], pts[i + 2], pts[i + 3], rock, 2.2)
	_poly([-3, 13.5, 3, 13.5, 2.4, 15.2, -2.4, 15.2], rock)
	var hi := _arc(0, 19.5, 6, 6.5, PI * 0.25, PI * 0.75, 6)
	for i in range(0, hi.size() - 2, 2):
		_l(hi[i], hi[i + 1], hi[i + 2], hi[i + 3], Color("a5b4c0"), 0.5)
