class_name LandmarksBgB
extends RefCounted
## Bulgarian landmarks (Dobrich to Pazardzhik), drawn with LandmarkPainter's helpers (metres from the base point, y up).

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
const BRONZE := Color("4f5a44")
const CONCRETE := Color("a9a69c")
const LEAD := Color("8a9096")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"stariya_dobrich": _stariya_dobrich()
		"shumen_founders_monument": _shumen_founders()
		"surva_kuker": _surva_kuker()
		"tsarevets_fortress": _tsarevets()
		"asenevtsi_monument": _asenevtsi()
		"haskovo_virgin_mary": _haskovo_virgin()
		"varosha_annunciation": _varosha()
		"yambol_bezisten": _bezisten()
		"pazardzhik_virgin_church": _pazardzhik_church()
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

## A National Revival house: stone ground floor, white upper floor jutting out on beams, dark timbers, a shallow tiled
## roof with wide eaves.
static func _revival_house(x0: float, x1: float, h0: float, h1: float) -> void:
	_r(x0, 0, x1, h0, STONE)
	_r(x0 - 0.6, h0, x1 + 0.6, h1, WHITE)
	_r(x0 - 0.6, h0, x1 + 0.6, h0 + 0.3, BEAM)
	for x in [x0 - 0.6, (x0 + x1) * 0.5, x1 + 0.6]:
		_l(x, h0, x, h1, BEAM, 0.2)
	_windows(x0 + 0.6, x1 - 0.6, h0 + 0.8, h1 - 0.8, 2, WIN)
	_poly([x0 - 1.8, h1, x1 + 1.8, h1, (x0 + x1) * 0.5, h1 + (x1 - x0) * 0.22], TILE)

## Old Dobrich: the craftsmen's lane of low whitewashed houses with tiled roofs, wooden shutters open on the workshops,
## a well with its sweep in front.
static func _stariya_dobrich() -> void:
	_r(-22, 0, 22, 0.6, Color("b8ab92"))
	for h in [[-21.0, -12.0, 4.6], [-11.0, -2.0, 5.2], [-1.0, 8.0, 4.4], [9.0, 19.0, 5.0]]:
		_r(h[0], 0.6, h[1], h[2], WHITE)
		_r(h[0], 0.6, h[1], 1.2, STONE_D)
		_poly([h[0] - 1.2, h[2], h[1] + 1.2, h[2], h[1] - 1.5, h[2] + 2.6, h[0] + 1.5, h[2] + 2.6], TILE)
		for k in 2:
			var x: float = h[0] + 1.6 + k * 4.2
			_r(x, 1.8, x + 2.2, 3.6, BEAM)
			_r(x - 0.8, 1.8, x, 3.6, Color("7a5a3a"))
			_r(x + 2.2, 1.8, x + 3.0, 3.6, Color("7a5a3a"))
	_r(-6.5, 3.8, -4.5, 4.8, Color("d8c060"))
	# the well and its sweep
	_r(19.6, 0.6, 21.4, 1.8, STONE_D)
	_l(20.5, 0.6, 20.5, 5, BEAM, 0.25)
	_l(17.5, 7.5, 22, 3.5, BEAM, 0.18)
	_l(17.6, 7.4, 17.6, 4.5, DARK, 0.06)

## The Founders of the Bulgarian State monument above Shumen: huge angular concrete figures of the khans standing in
## a ring on the plateau, a mosaic glowing between them.
static func _shumen_founders() -> void:
	_poly([-32, 0, 32, 0, 26, 4, -26, 4], GRASS)
	var c2 := Color("8f8c83")
	var figs := [[-28.0, -19.0, 18.0], [-19.0, -9.0, 24.0], [-8.0, 8.0, 30.0], [9.0, 19.0, 24.0], [20.0, 29.0, 19.0]]
	_r(-9, 4, 9, 12, Color("c79a3a"))
	for i in 4:
		_r(-8.0 + i * 4.0, 5, -5.5 + i * 4.0, 11, [Color("b8483a"), Color("2f6a9a"), Color("e0b43a"), Color("3f8a5a")][i])
	for f in figs:
		var mid: float = (f[0] + f[1]) * 0.5
		_poly([f[0], 4, f[1], 4, f[1] - 0.8, f[2] * 0.7, mid + 1.5, f[2], mid - 2.0, f[2] - 0.6, f[0] + 0.6, f[2] * 0.65], CONCRETE)
		_poly([mid - 1.4, f[2] - 4.0, mid + 1.4, f[2] - 4.0, mid + 1.0, f[2] - 1.0, mid - 1.2, f[2] - 1.2], c2)
		_l(f[0] + 1.2, f[2] * 0.45, f[1] - 1.2, f[2] * 0.5, c2, 0.35)
		_l(mid, 4, mid, f[2] * 0.4, c2, 0.25)

## A kuker from Pernik's Surva festival: a shaggy goat-fur costume, a red sash hung with big bronze bells, and the tall
## mask with horns, mirrors and coloured tassels.
static func _surva_kuker() -> void:
	var fur := Color("2a2622")
	_poly([-0.75, 0, 0.75, 0, 0.6, 1.9, -0.6, 1.9], fur)
	for i in 6:
		var x := -0.6 + i * 0.24
		_l(x, 0.1, x + 0.05, 1.8, Color("4a423a"), 0.05)
	_r(-0.62, 0.95, 0.62, 1.12, Color("c23b2e"))
	for x in [-0.4, 0.0, 0.4]:
		_poly([x - 0.16, 0.95, x + 0.16, 0.95, x + 0.2, 0.62, x - 0.2, 0.62], Color("b8892a"))
	# the mask
	_poly([-0.6, 1.9, 0.6, 1.9, 0.5, 2.7, -0.5, 2.7], Color("d8c8a8"))
	_c(-0.22, 2.35, 0.1, DARK)
	_c(0.22, 2.35, 0.1, DARK)
	_poly([-0.25, 2.05, 0.25, 2.05, 0, 2.18], Color("c23b2e"))
	_c(0, 2.85, 0.12, Color("bfe0f0"))
	_l(-0.45, 2.6, -1.1, 3.5, Color("e8dcc0"), 0.12)
	_l(0.45, 2.6, 1.1, 3.5, Color("e8dcc0"), 0.12)
	_poly([-0.5, 2.7, 0.5, 2.7, 0.3, 3.1, -0.3, 3.1], Color("c23b2e"))
	for k in 5:
		var x := -0.5 + k * 0.25
		_l(x, 2.7, x * 1.3, 2.25, [Color("e0b43a"), Color("2f6a9a"), Color("c23b2e"), Color("3f8a5a"), Color("e0b43a")][k], 0.06)

## Tsarevets in Veliko Tarnovo: the walled hill above the Yantra, Baldwin's Tower at the gate end and the Patriarch's
## Church of the Ascension crowning the top.
static func _tsarevets() -> void:
	_r(-45, 0, 45, 3, WATER)
	_poly([-45, 3, -45, 10, -34, 20, -20, 28, 0, 31, 22, 27, 36, 18, 45, 10, 45, 3], Color("6f8f4a"))
	_poly([-42, 8, -30, 18, -18, 25, 0, 28, 18, 24, 32, 16, 42, 9, 40, 6, 30, 13, 16, 20, 0, 23, -16, 21, -28, 14, -40, 5], Color("8a8a6a"))
	# the walls with merlons along the slope
	var wall := [[-40.0, 8.0], [-30.0, 17.0], [-18.0, 24.0], [-6.0, 27.0], [6.0, 27.0], [18.0, 24.0], [30.0, 17.0], [40.0, 9.0]]
	for i in wall.size() - 1:
		var a: Array = wall[i]
		var b: Array = wall[i + 1]
		_poly([a[0], a[1], b[0], b[1], b[0], b[1] + 2.4, a[0], a[1] + 2.4], STONE)
		for k in 4:
			var t := (k + 0.5) / 4.0
			var x: float = lerpf(a[0], b[0], t)
			var y: float = lerpf(a[1], b[1], t) + 2.4
			_r(x - 0.6, y, x + 0.6, y + 0.9, STONE)
	# Baldwin's Tower
	_r(-40, 6, -33, 22, STONE)
	for k in 3:
		_r(-40 + k * 2.6, 22, -38.8 + k * 2.6, 23.4, STONE)
	_r(-37.2, 15, -35.8, 18, WIN)
	# the Patriarch's church
	var brick := Color("b0603e")
	_r(-6, 29, 8, 37, brick)
	for y in [31.0, 33.0, 35.0]:
		_l(-6, y, 8, y, Color("e0d0b0"), 0.25)
	_poly([-6.6, 37, 8.6, 37, 7, 38.6, -5, 38.6], Color("7a4a32"))
	_r(-0.5, 37, 3.5, 41.5, brick)
	_poly(_arc(1.5, 41.5, 2.3, 2.0, 0, PI, 8), Color("7a4a32"))
	_l(1.5, 43.5, 1.5, 45.2, GOLD, 0.2)
	_r(-12, 29, -7, 42, brick)
	_poly([-12.5, 42, -6.5, 42, -9.5, 45.5], Color("7a4a32"))
	_arch_win(-9.5, 37, 1.6, 3, WIN)
	_arch_win(1.0, 31, 1.2, 3, WIN)
	_arch_win(5.0, 31, 1.2, 3, WIN)

## The Monument to the Asen Dynasty in Veliko Tarnovo: a tall sword in the middle and the four bronze tsars on
## horseback around it, the inner two on plinths, on a stone platform in the Yantra's bend.
static func _asenevtsi() -> void:
	_r(-12, 0, 12, 2, STONE_D)
	_r(-10, 2, 10, 3, STONE)
	# the sword
	_poly([-0.9, 3, 0.9, 3, 0.7, 20, 0, 23.5, -0.7, 20], Color("b0b4b8"))
	_l(0, 4, 0, 20, Color("8a8f94"), 0.15)
	_r(-2.8, 6, 2.8, 7, Color("8a8f94"))
	_r(-0.6, 3, 0.6, 6, BRONZE)
	# four riders on their horses, rearing outwards
	for x in [-8.5, -4.5, 4.5, 8.5]:
		var s := 1.0 if x > 0.0 else -1.0
		var y := 3.0 if absf(x) > 6.0 else 7.0
		var hx: float = x + 0.6 * s
		if y > 3.0: # the inner riders stand higher, on stone plinths
			_r(hx - 2.0, 3, hx + 2.0, y, STONE)
			_r(hx - 2.2, y - 0.4, hx + 2.2, y, STONE_D)
		_poly([hx - 1.9 * s, y + 1.6, hx + 1.3 * s, y + 2.4, hx + 1.1 * s, y + 3.6, hx - 1.9 * s, y + 2.8], BRONZE)
		_poly([hx + 0.9 * s, y + 2.6, hx + 1.7 * s, y + 4.6, hx + 2.6 * s, y + 4.9, hx + 2.5 * s, y + 4.2, hx + 1.8 * s, y + 3.3], BRONZE)
		_l(hx - 1.6 * s, y + 1.8, hx - 1.8 * s, y, BRONZE, 0.45)
		_l(hx - 1.0 * s, y + 1.8, hx - 0.8 * s, y, BRONZE, 0.45)
		_l(hx + 1.0 * s, y + 2.6, hx + 1.8 * s, y + 1.6, BRONZE, 0.4)
		_l(hx + 0.6 * s, y + 2.5, hx + 1.4 * s, y + 1.3, BRONZE, 0.4)
		_l(hx - 1.9 * s, y + 2.6, hx - 2.4 * s, y + 1.5, BRONZE, 0.3)
		_poly([hx - 0.6 * s, y + 3.2, hx + 0.2 * s, y + 3.4, hx + 0.1 * s, y + 5.4, hx - 0.6 * s, y + 5.2], BRONZE)
		_c(hx - 0.2 * s, y + 5.9, 0.45, BRONZE)
		_l(hx, y + 4.8, hx + 1.0 * s, y + 6.4, BRONZE, 0.22)

## The Holy Mother of God above Haskovo: the white statue of the Virgin with the Child in her arms, 14 metres tall,
## standing on the round chapel on Yamacite hill.
static func _haskovo_virgin() -> void:
	_r(-8, 0, 8, 1.2, GRASS)
	_r(-6, 1.2, 6, 12, Color("e8e2d4"))
	_poly(_arc(0, 12, 6.6, 1.6, 0, PI, 12), Color("b8b0a0"))
	_arch_win(0, 1.2, 2.2, 4.5, Color("6a4a30"))
	for x in [-3.8, 3.8]:
		_arch_win(x, 5.5, 1.1, 3.0, WIN)
	_r(-2.6, 13, 2.6, 15.5, Color("d8d2c2"))
	# the Virgin
	var w := Color("f4f1ea")
	var sh := Color("d8d2c4")
	_poly([-3, 15.5, 3, 15.5, 2.2, 24, 1.8, 29, -1.8, 29, -2.2, 24], w)
	_poly([0.6, 15.5, 3, 15.5, 2.2, 24, 1.4, 27], sh)
	_poly([-1.9, 29, 1.9, 29, 1.7, 31.5, 0, 33.6, -1.7, 31.5], w)
	_c(0, 31.6, 1.2, Color("e6dfd0"))
	_poly([-1.9, 31.5, -1.4, 33.4, 0, 34, 1.4, 33.4, 1.9, 31.5, 1.6, 29.5, -1.6, 29.5], sh)
	_c(0, 32, 0.95, Color("efe8da"))
	# the Child held in front
	_c(-1.0, 26.8, 0.8, w)
	_poly([-2.2, 23.5, 0.4, 23.5, 0.2, 26.2, -2.0, 26.2], Color("ebe5d8"))
	_l(-2.4, 24.5, 1.6, 26.5, sh, 0.5)
	_l(-1, 27.6, -1, 29, GOLD, 0.1)

## The Varosha quarter of Blagoevgrad: the Church of the Annunciation with its slim clock tower and spire, between
## Revival houses with white upper floors on dark beams.
static func _varosha() -> void:
	_revival_house(-18, -10, 3.5, 7.5)
	_revival_house(10, 18, 3.5, 8)
	var wall := Color("e9dcc0")
	_r(-8, 0, 8, 9, wall)
	_poly([-8.8, 9, 8.8, 9, 6, 11.5, -6, 11.5], TILE_D)
	for x in [-5.0, -1.5, 1.5, 5.0]:
		_arch_win(x, 3, 1.2, 3.6, WIN)
	_poly([-1.4, 0, 1.4, 0, 1.4, 2.4] + _arc(0, 2.4, 1.4, 1.4, 0, PI, 6), BEAM)
	# the tower
	_r(-2.2, 9, 2.2, 19, wall)
	_c(0, 15.5, 1.2, WHITE)
	_c(0, 15.5, 1.0, Color("2e5a8a"))
	_l(0, 15.5, 0, 16.2, WHITE, 0.12)
	_l(0, 15.5, 0.5, 15.3, WHITE, 0.1)
	_arch_win(0, 10.5, 1.2, 3, WIN)
	_r(-2.6, 19, 2.6, 19.7, STONE_D)
	_poly([-2.2, 19.7, 2.2, 19.7, 0, 23.4], Color("7a8288"))
	_l(0, 23.4, 0, 24, GOLD, 0.15)

## The Bezisten in Yambol: the 15th-century covered market, a long hall of stone and brick bands under a row of small
## lead domes, arched doors at the ends.
static func _bezisten() -> void:
	_r(-20, 0, 20, 7, STONE)
	for y in [1.5, 3.5, 5.5]:
		_r(-20, y, 20, y + 0.4, Color("b0603e"))
	_r(-20.4, 7, 20.4, 7.6, STONE_D)
	for i in 8:
		var x := -16.5 + i * 4.7
		_r(x - 1.6, 7.6, x + 1.6, 8.4, STONE)
		_poly(_arc(x, 8.4, 2.0, 2.3, 0, PI, 10), LEAD)
		_l(x, 10.7, x, 11.4, DARK, 0.12)
	for x in [-20.0, 20.0]:
		_arch_win(x - 3.0 * signf(x), 0, 2.8, 4.6, Color("5a3e2a"))
	_windows(-12, 12, 3.8, 5.2, 6, WIN)
	_poly([-2, 0, 2, 0, 2, 3.6] + _arc(0, 3.6, 2, 2, 0, PI, 8), Color("5a3e2a"))

## The Church of the Holy Mother of God in Pazardzhik: built low and half sunk into the ground as Ottoman rule
## demanded, stone and brick walls, an arcade along the front and a broad tiled roof; a wooden bell tower beside it.
static func _pazardzhik_church() -> void:
	_r(-16, 0, 16, 0.8, Color("8a7a5a"))
	var wall := Color("d9c9a8")
	_r(-12, 0.8, 12, 8, wall)
	for y in [3.0, 5.5]:
		_r(-12, y, 12, y + 0.35, Color("a5503a"))
	_poly([-13.5, 8, 13.5, 8, 10, 11.5, -10, 11.5], TILE)
	_l(-10, 11.5, 10, 11.5, TILE_D, 0.3)
	# the arcade porch
	_r(-12, 0.8, 12, 1.2, STONE_D)
	for i in 7:
		var x := -10.0 + i * (20.0 / 6.0)
		_r(x - 0.3, 1.2, x + 0.3, 5.6, WHITE)
	for i in 6:
		var x := -10.0 + (i + 0.5) * (20.0 / 6.0)
		_poly(_arc(x, 4.6, 1.4, 1.0, 0, PI, 6), Color("4a3a30"))
	_r(-11.8, 5.6, 11.8, 6.4, wall)
	_l(0, 11.5, 0, 13, GOLD, 0.18)
	_l(-0.5, 12.5, 0.5, 12.5, GOLD, 0.14)
	# the wooden bell tower
	_r(13, 0.8, 13.4, 13, BEAM)
	_r(15.6, 0.8, 16, 13, BEAM)
	_l(13.2, 4, 15.8, 9, BEAM, 0.15)
	_poly([12.5, 13, 16.5, 13, 14.5, 15.5], TILE)
	_poly(_arc(14.5, 11.2, 0.8, 1.0, 0, PI, 6), Color("b8892a"))
