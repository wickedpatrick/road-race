class_name LandmarksBaB
extends RefCounted
## Landmarks of Bosnia and Herzegovina (part two), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const STONE := Color("d8cdb4")
const STONE_D := Color("b3a688")
const RED_ROOF := Color("a8452f")
const WATER := Color("3f9aa0")
const WATER_L := Color("8fd0cf")
const FOAM := Color("eef6f4")
const ROCK := Color("9a958a")
const MOSS := Color("6d9a3e")
const GRASS := Color("5d8f42")
const TREE := Color("3f6f34")
const WOOD := Color("7a5534")
const WOOD_D := Color("53381f")
const WIN := Color("3a4048")
const DARK := Color("2e3238")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"doboj_fortress": _doboj()
		"plava_voda": _plava_voda()
		"strbacki_buk": _strbacki_buk()
		"arslanagic_bridge": _arslanagic()
		"livno_horses": _horses()
		"pliva_falls": _pliva()
		"sopotnica": _sopotnica()
		"visegrad_bridge": _visegrad()
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

static func _arc(cx: float, cy: float, rx: float, ry: float, a0: float, a1: float, n: int) -> Array:
	return LandmarkPainter._arc_pts(cx, cy, rx, ry, a0, a1, n)

static func _detail(min_pm: float) -> bool:
	return LandmarkPainter._pm > min_pm

## Falling water: a sheet of `col` with white streaks.
static func _fall(x0: float, x1: float, y0: float, y1: float) -> void:
	_r(x0, y0, x1, y1, WATER_L)
	if _detail(1.0):
		var n := int((x1 - x0) / 0.9)
		for k in n:
			var x := x0 + (k + 0.5) * (x1 - x0) / n
			_l(x, y1, x, y0 + (k % 3) * 0.4, FOAM, 0.18)
	_poly([x0 - 1.0, y0, x1 + 1.0, y0, x1, y0 + 1.0, x0, y0 + 1.0], FOAM)

## A wooden watermill hut with a shingle roof.
static func _mill(x: float, y: float, w: float) -> void:
	_r(x - w * 0.5, y, x + w * 0.5, y + w * 0.7, WOOD)
	_poly([x - w * 0.5 - 0.5, y + w * 0.7, x + w * 0.5 + 0.5, y + w * 0.7, x, y + w * 1.4], WOOD_D)
	_r(x - w * 0.15, y, x + w * 0.15, y + w * 0.4, DARK)

## Gradina fortress in Doboj: stone walls with square towers climbing a green hill above the town.
static func _doboj() -> void:
	_poly([-20, 0, -20, 4, -12, 9, -2, 13, 10, 12, 20, 5, 20, 0], GRASS)
	_poly([-14, 9, 12, 9, 12, 16, -10, 15], STONE_D)
	for k in 10:
		_r(-10 + k * 2.2, 15 + k * 0.1, -9 + k * 2.2, 16.2 + k * 0.1, STONE_D)
	for t in [[-13.0, 8.0, 18.5], [-1.0, 12.0, 23.0], [11.0, 10.0, 20.0]]:
		_r(t[0] - 2.2, t[1], t[0] + 2.2, t[2], STONE)
		for k in 3:
			_r(t[0] - 2.2 + k * 1.75, t[2], t[0] - 1.4 + k * 1.75, t[2] + 1.0, STONE)
		_r(t[0] - 0.4, t[2] - 4, t[0] + 0.4, t[2] - 2.5, WIN)
	# a flag on the keep, the town's roofs below
	_l(-1, 24, -1, 27, DARK, 0.15)
	_poly([-1, 27, 1.6, 26.4, -1, 25.8], Color("d64b3a"))
	for x in [-17.0, -8.0, 4.0, 15.0]:
		_r(x - 1.6, 0, x + 1.6, 2.4, Color("efe6d0"))
		_poly([x - 2.0, 2.4, x + 2.0, 2.4, x, 4.2], RED_ROOF)

## Plava Voda in Travnik: a clear blue spring pool with little wooden bridges and mills, the fortress wall above.
static func _plava_voda() -> void:
	_poly([-18, 6, -10, 12, 0, 14, 10, 13, 18, 7, 18, 6], Color("6f9f4e"))
	_r(-4, 12, 4, 16, STONE)
	for k in 4:
		_r(-4 + k * 2.2, 16, -3 + k * 2.2, 16.8, STONE)
	_r(-18, 0, 18, 6, GRASS)
	_poly([-16, 0.3, 16, 0.3, 13, 4, -13, 4], Color("2f86c4"))
	if _detail(1.0):
		_l(-10, 1.6, 10, 1.6, Color("9fd3f2"), 0.25)
		_l(-7, 2.8, 7, 2.8, Color("9fd3f2"), 0.2)
	# a little wooden footbridge
	_r(-6, 3.2, 2, 3.7, WOOD)
	for x in [-6.0, -4.0, -2.0, 0.0, 2.0]:
		_l(x, 3.7, x, 4.8, WOOD_D, 0.15)
	_l(-6, 4.8, 2, 4.8, WOOD_D, 0.15)
	_mill(-13, 4, 3.2)
	_mill(12, 4, 3.6)
	for x in [-17.0, 16.5]:
		_c(x, 8, 2.2, Color("3f6f34"))

## Štrbački buk on the Una: a broad stepped waterfall over travertine ledges with green banks.
static func _strbacki_buk() -> void:
	_r(-25, 0, 25, 3, WATER)
	_poly([-25, 3, -25, 18, -18, 19, -17, 3], TREE)
	_poly([25, 3, 25, 17, 18, 18, 17, 3], TREE)
	# three steps of falls
	_r(-17, 12, 17, 14, WATER)
	_fall(-16, 16, 8, 12)
	_r(-17, 7, 17, 8, MOSS)
	_fall(-14, 14, 3, 7)
	if _detail(1.0):
		for x in [-9.0, -2.0, 6.0]:
			_r(x, 7, x + 1.6, 8.6, MOSS.darkened(0.1))
	_r(-25, 14, 25, 15, MOSS)
	_poly([-18, 15, 18, 15, 12, 20, -12, 20], Color("4f8a46"))

## Arslanagić bridge near Trebinje: two big stone arches and two small ones over the Trebišnjica.
static func _arslanagic() -> void:
	_r(-25, 0, 25, 2.5, WATER)
	var deck := [-25.0, 2.5, -25.0, 9.5, -12.0, 11.0, 0.0, 13.5, 12.0, 11.0, 25.0, 9.5, 25.0, 2.5]
	_poly(deck, STONE)
	# the arches, seen through to the river
	var shade := WATER.darkened(0.35)
	for a in [[-8.5, 7.0, 8.0], [8.5, 7.0, 7.4], [-19.5, 2.8, 4.0], [19.5, 2.8, 3.6]]:
		_poly(_arc(a[0], 2.5, a[1], a[2], 0, PI, 14), shade)
	_l(-25, 9.5, 0, 13.5, STONE_D, 0.25)
	_l(0, 13.5, 25, 9.5, STONE_D, 0.25)
	if _detail(1.0):
		_l(-20, 1.2, 20, 1.2, WATER_L, 0.2)

## The wild horses of Livno on the Cincar hills: a grey ridge, a herd grazing on the meadow.
static func _horses() -> void:
	_poly([-15, 0, -15, 6, -8, 10, 0, 8, 6, 11, 15, 7, 15, 0], Color("8c8a7f"))
	_poly([-15, 0, -15, 3, 15, 4, 15, 0], Color("8faa5a"))
	var cols := [Color("6a4127"), Color("2f2622"), Color("a46b3c"), Color("e7dfd0")]
	for k in 4:
		_horse(-10.0 + k * 6.4, 0.3 + (k % 2) * 0.6, 0.7 + (k % 2) * 0.15, cols[k], k % 2 == 0)

static func _horse(x: float, y: float, s: float, col: Color, grazing: bool) -> void:
	var d := col.darkened(0.25)
	_r(x - 2.0 * s, y + 2.2 * s, x + 2.0 * s, y + 3.6 * s, col) # body
	_c(x - 2.0 * s, y + 2.9 * s, 0.7 * s, col)
	_c(x + 2.0 * s, y + 2.9 * s, 0.7 * s, col)
	for dx in [-1.7, -1.1, 1.2, 1.8]:
		_r(x + (dx - 0.18) * s, y, x + (dx + 0.18) * s, y + 2.4 * s, d)
	if grazing: # neck down to the grass
		_poly([x + 1.6 * s, y + 3.5 * s, x + 2.5 * s, y + 3.0 * s, x + 3.3 * s, y + 0.8 * s, x + 2.7 * s, y + 0.5 * s], col)
		_c(x + 3.1 * s, y + 0.6 * s, 0.5 * s, col)
	else:
		_poly([x + 1.4 * s, y + 3.3 * s, x + 2.2 * s, y + 2.8 * s, x + 3.0 * s, y + 4.9 * s, x + 2.2 * s, y + 5.2 * s], col)
		_poly([x + 2.2 * s, y + 5.2 * s, x + 3.0 * s, y + 4.9 * s, x + 3.8 * s, y + 4.4 * s, x + 3.6 * s, y + 5.1 * s], col)
		_l(x + 1.5 * s, y + 3.6 * s, x + 2.3 * s, y + 5.3 * s, d, 0.3 * s)
	_l(x - 2.6 * s, y + 3.2 * s, x - 3.1 * s, y + 1.4 * s, d, 0.3 * s) # tail

## The Pliva waterfall in Jajce: the river drops off a travertine cliff into the Vrbas, the old town and its
## fortress on the hill above.
static func _pliva() -> void:
	_r(-20, 0, 20, 3, WATER)
	_poly([-20, 3, -20, 30, -6, 30, -4, 22, -6, 14, -8, 3], Color("cbbf9c"))
	_poly([20, 3, 20, 14, 10, 15, 5, 3], Color("cbbf9c"))
	_poly([-8, 3, -6, 14, -4, 22, 4, 21, 6, 13, 5, 3], WATER_L)
	if _detail(1.0):
		for x in [-5.0, -3.0, -1.0, 1.0, 3.0]:
			_l(x, 21, x * 1.2, 4, FOAM, 0.25)
	_poly([-10, 3, 7, 3, 4, 5.5, -7, 5.5], FOAM)
	_poly([-4, 22, 4, 21, 5, 23, -4, 24], WATER)
	_r(5, 14, 20, 15.5, GRASS)
	# houses and the fortress on the hill
	for h in [[-17.0, 30.0], [-12.0, 30.0], [10.0, 15.5], [15.0, 15.5]]:
		_r(h[0] - 1.6, h[1], h[0] + 1.6, h[1] + 2.6, Color("efe6d0"))
		_poly([h[0] - 2.0, h[1] + 2.6, h[0] + 2.0, h[1] + 2.6, h[0], h[1] + 4.2], RED_ROOF)
	_r(-9, 30, -5, 36, STONE_D)
	for k in 3:
		_r(-9 + k * 1.5, 36, -8.2 + k * 1.5, 37, STONE_D)

## The Sopotnica waterfalls near Goražde: thin threads of water over mossy steps, a wooden mill at the side.
static func _sopotnica() -> void:
	_r(-15, 0, 15, 2, WATER)
	_poly([-15, 2, -15, 24, 15, 24, 15, 2], TREE.darkened(0.15))
	for k in 5:
		var y := 2.0 + k * 4.2
		var w := 9.0 - k * 1.2
		_poly([-w - 1.5, y, w + 1.5, y, w, y + 2.2, -w, y + 2.2], MOSS.lightened(0.05 * (k % 2)))
		if _detail(0.8):
			for j in 5:
				var x := -w + (j + 0.5) * (2.0 * w) / 5.0
				_l(x, y + 4.2, x, y + 0.4, FOAM, 0.3)
	_mill(11, 2, 4)
	_c(8.2, 3.6, 1.4, WOOD)
	_c(8.2, 3.6, 0.35, WOOD_D)

## The Mehmed Paša Sokolović Bridge in Višegrad: eleven stone arches over the green Drina, the kapija terrace
## jutting out in the middle.
static func _visegrad() -> void:
	_r(-40, 0, 40, 2.5, Color("3f8f7a"))
	if _detail(1.0):
		_l(-36, 1.2, 36, 1.2, WATER_L, 0.25)
	_poly([-40, 2.5, -40, 11.0, 0, 12.5, 40, 11.0, 40, 2.5], STONE)
	var shade := Color("3f8f7a").darkened(0.35)
	for k in 11:
		var x := -33.0 + k * 6.6
		var h := 6.5 - absf(k - 5) * 0.35
		_poly(_arc(x, 2.5, 2.4, h, 0, PI, 12), shade)
		if _detail(1.0):
			_poly([x + 2.6, 2.5, x + 4.0, 2.5, x + 3.3, 4.2], STONE_D) # the cutwaters
	# the parapet and the kapija
	_l(-40, 11.0, 0, 12.5, STONE_D, 0.3)
	_l(0, 12.5, 40, 11.0, STONE_D, 0.3)
	_r(-3, 12.4, 3, 14.2, STONE)
	_r(-3, 14.2, 3, 14.8, STONE_D)
	_poly([-40, 2.5, -40, 15, -34, 13, -32, 2.5], GRASS)
	_poly([40, 2.5, 40, 16, 34, 13, 32, 2.5], GRASS)
