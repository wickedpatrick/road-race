class_name LandmarksDkB
extends RefCounted
## Danish landmarks (Vejle to Skagen), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const WHITE := Color("f3f0e8")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const GRASS := Color("5d8f42")
const GOLD := Color("e0b43a")
const TILE := Color("b14a32")
const TILE_D := Color("8c3826")
const WATER := Color("3f6f96")
const PATINA := Color("5f9e86")
const PATINA_D := Color("4b8270")
const SAND := Color("e2d3a6")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"dk_vejle_wave": _vejle_wave()
		"dk_roskilde_cathedral": _roskilde_cathedral()
		"dk_helsingor_kronborg": _helsingor_kronborg()
		"dk_koge_house": _koge_house()
		"dk_ronne_nylars": _ronne_nylars()
		"dk_skagen_church": _skagen_church()
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

static func _detail(min_pm: float) -> bool:
	return LandmarkPainter._pm > min_pm

## A pointed (Gothic) window: a rectangle under a pointed arch.
static func _pointed(x: float, y0: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.5, y0, x + w * 0.5, y0, x + w * 0.5, y0 + h - w * 0.8, x, y0 + h, x - w * 0.5, y0 + h - w * 0.8], col)

## An arched window or door: a rectangle under a half circle.
static func _arched(x: float, y0: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.5, y0, x + w * 0.5, y0, x + w * 0.5, y0 + h - w * 0.5] + _arc(x, y0 + h - w * 0.5, w * 0.5, w * 0.5, 0, PI, 6), col)

## A crow-stepped gable from x0 to x1 standing on y0 and rising to `top` in `steps` steps.
static func _stepped(x0: float, x1: float, y0: float, top: float, steps: int, col: Color) -> void:
	var mid := (x0 + x1) * 0.5
	var half := (x1 - x0) * 0.5
	for k in steps:
		var w := half * (1.0 - float(k) / steps)
		var ya := y0 + (top - y0) * float(k) / steps
		var yb := y0 + (top - y0) * float(k + 1) / steps
		_r(mid - w, ya, mid + w, yb, col)

## Bølgen, the Wave, on Vejle harbour: five white apartment buildings side by side whose roofs swell into crests, with
## floors of glass and balconies, the fjord in front.
static func _vejle_wave() -> void:
	var heights := [16.5, 22.0, 19.0, 23.5, 17.5]
	var w := 14.0
	for k in 5:
		var x0 := -35.0 + k * w
		var h: float = heights[k]
		var pts := [x0, 1.2, x0 + w, 1.2]
		for i in range(12, -1, -1):
			var t := float(i) / 12.0
			pts.append_array([x0 + t * w, h * (0.42 + 0.58 * pow(sin(PI * t), 0.45))])
		_poly(pts, WHITE)
		# the glass floors under the white roof
		if _detail(0.6):
			var y := 3.0
			while y + 1.5 < h * 0.93:
				# half the width of the white shape at the strip's top, less a margin
				var q := pow(clampf((y + 1.5 - h * 0.42) / (h * 0.58), 0.0, 1.0), 1.0 / 0.45)
				var hw := w * (0.5 - asin(q) / PI) - 0.9
				if hw > 0.5:
					_r(x0 + w * 0.5 - hw, y, x0 + w * 0.5 + hw, y + 1.5, Color("5c7488"))
				y += 2.9
		_l(x0, 1.2, x0, h * 0.42, Color("d6d3cb"), 0.2)
	_r(-36, 0, 36, 1.2, WATER)

## Roskilde Cathedral: the long red-brick Gothic church, its copper-green roof and two slender green spires on the
## twin towers of the west front, pointed windows, a side chapel and the round east end.
static func _roskilde_cathedral() -> void:
	var brick := Color("a24a33")
	var brick_d := Color("7f3626")
	# the nave and choir
	_r(-17, 0, 25, 21, brick)
	_poly([-17.5, 21, 25.5, 21, 24, 29, -16, 29], PATINA)
	_poly(_arc(25, 0, 5.5, 21, 0, PI * 0.5, 8) + [25, 0], brick_d)
	_poly([25, 21] + _arc(25, 21, 5.6, 7.0, 0, PI * 0.5, 6), PATINA)
	if _detail(0.7):
		for k in 9:
			_pointed(-13.5 + k * 4.2, 3.0, 1.6, 7.5, WIN)
			_pointed(-13.5 + k * 4.2, 12.0, 1.6, 6.5, WIN)
		for k in 8:
			_l(-15.0 + k * 4.2 + 2.1, 0, -15.0 + k * 4.2 + 2.1, 21, brick_d, 0.35)
	# a lower side chapel with a stepped gable
	_r(2, 0, 12, 13, brick_d)
	_stepped(2, 12, 13, 19, 5, brick_d)
	_pointed(7, 2.5, 2.4, 8.5, WIN)
	# the ridge turret
	_l(10, 29, 10, 36, PATINA_D, 0.5)
	_poly([9.4, 33, 10.6, 33, 10, 37.5], PATINA_D)
	# the west front: two square towers with tall green spires and a gable between them
	for tx in [-30.0, -21.0]:
		_r(tx, 0, tx + 6, 38, brick)
		_r(tx + 4.6, 0, tx + 6, 38, brick_d)
		_poly([tx - 0.3, 38, tx + 6.3, 38, tx + 3.0, 64], PATINA)
		_poly([tx + 3.0, 38, tx + 6.3, 38, tx + 3.0, 64], PATINA_D)
		_c(tx + 3.0, 64.4, 0.4, GOLD)
		if _detail(0.7):
			for y in [6.0, 16.0, 26.0]:
				_pointed(tx + 3.0, y, 1.5, 5.0, WIN)
			_pointed(tx + 1.8, 32.0, 1.0, 4.0, WIN)
			_pointed(tx + 4.2, 32.0, 1.0, 4.0, WIN)
	_r(-24, 0, -21, 30, brick)
	_stepped(-24.5, -20.5, 30, 35, 4, brick)
	_pointed(-22.5, 0, 2.6, 7.0, Color("4a3428"))

## Kronborg at Helsingør: the sandstone Renaissance castle with green copper roofs and spires, the tall tiered spire of
## the trumpeters' tower, curly dormer gables, on its grassy bastions above the moat.
static func _helsingor_kronborg() -> void:
	var stone := Color("ddd0ae")
	var stone_d := Color("bfb08c")
	# the bastions and the moat
	_poly([-42, 0, 42, 0, 38, 6, -38, 6], GRASS)
	_poly([-42, 0, -34, 0, -38, 5], Color("4f7d39"))
	_poly([42, 0, 34, 0, 38, 5], Color("4f7d39"))
	_r(-42, 0, 42, 1.4, WATER)
	# the main range
	_r(-28, 6, 26, 24, stone)
	_poly([-28.6, 24, 26.6, 24, 24, 31, -26, 31], PATINA)
	if _detail(0.7):
		for row in 3:
			_windows(-27, 25, 8.0 + row * 5.4, 11.2 + row * 5.4, 14, WIN)
		for y in [12.6, 18.0]:
			_l(-28, y, 26, y, stone_d, 0.25)
	# curly dormer gables on the roof
	for gx in [-17.0, -6.0, 5.0]:
		_r(gx - 2.0, 24, gx + 2.0, 28, stone)
		_r(gx - 1.3, 28, gx + 1.3, 30.5, stone)
		_poly([gx - 0.8, 30.5, gx + 0.8, 30.5, gx, 32], stone)
		_c(gx - 2.0, 28.2, 0.45, stone_d)
		_c(gx + 2.0, 28.2, 0.45, stone_d)
		_r(gx - 0.6, 25, gx + 0.6, 27.2, WIN)
	# the left corner tower with its onion-like spire
	_r(-33, 6, -26, 33, stone)
	_r(-27.6, 6, -26, 33, stone_d)
	_poly([-33.4, 33, -25.6, 33, -27.4, 36.5, -31.6, 36.5], PATINA)
	_c(-29.5, 37.2, 1.7, PATINA)
	_poly([-30.3, 38.4, -28.7, 38.4, -29.5, 44], PATINA_D)
	# the trumpeters' tower: square, then a green tiered spire with lanterns
	_r(9, 6, 17, 34, stone)
	_r(15.4, 6, 17, 34, stone_d)
	_poly([8.6, 34, 17.4, 34, 15.5, 37, 10.5, 37], PATINA)
	_r(11.2, 37, 14.8, 39.5, PATINA_D)
	_poly([10.6, 39.5, 15.4, 39.5, 14.0, 41.5, 12.0, 41.5], PATINA)
	_r(12.3, 41.5, 13.7, 43.2, PATINA_D)
	_poly([11.9, 43.2, 14.1, 43.2, 13.0, 47.5], PATINA)
	_c(13.0, 47.7, 0.3, GOLD)
	if _detail(0.7):
		for y in [10.0, 16.0, 22.0, 28.0]:
			_arched(11.5, y, 1.2, 2.6, WIN)
			_arched(14.5, y, 1.2, 2.6, WIN)
	# the right tower with a slim pointed spire
	_r(26, 6, 32, 30, stone)
	_r(30.6, 6, 32, 30, stone_d)
	_poly([25.6, 30, 32.4, 30, 29, 42], PATINA)
	_poly([29, 30, 32.4, 30, 29, 42], PATINA_D)
	# the gate
	_arched(-4, 6, 3.0, 5.0, Color("4a3e30"))

## Kirkestræde 20 in Køge (1527): a small half-timbered house, dark timbers over pale infill, a red tiled roof and a
## chimney.
static func _koge_house() -> void:
	var infill := Color("efe2c2")
	var timber := Color("3b2c22")
	_r(-6.6, 0, 6.6, 0.5, Color("8f8a80"))
	_r(-6.3, 0.5, 6.3, 4.4, infill)
	# sill, top plate, posts and braces
	_r(-6.4, 0.5, 6.4, 0.85, timber)
	_r(-6.4, 4.1, 6.4, 4.45, timber)
	for k in 8:
		var x := -6.3 + k * 1.8
		_r(x - 0.14, 0.5, x + 0.14, 4.4, timber)
	_l(-6.2, 0.85, -4.6, 4.1, timber, 0.16)
	_l(6.2, 0.85, 4.6, 4.1, timber, 0.16)
	_r(-6.4, 2.35, 6.4, 2.6, timber)
	# small windows and a door
	for x in [-3.6, 0.0, 3.6]:
		_r(x - 0.6, 2.75, x + 0.6, 3.85, WIN)
	_r(1.3, 0.85, 2.4, 3.4, Color("5f4a38"))
	# the roof and the chimney
	_poly([-7.0, 4.4, 7.0, 4.4, 5.2, 9.6, -5.2, 9.6], TILE)
	if _detail(1.2):
		for k in 4:
			var y := 5.4 + k * 1.1
			var inset := 7.0 - (y - 4.4) * (1.8 / 5.2)
			_l(-inset, y, inset, y, TILE_D, 0.1)
	_r(2.4, 8.6, 3.4, 10.8, Color("a5452f"))

## Nylars Round Church on Bornholm: a whitewashed round nave under a dark cone roof, the lower chancel and apse to the
## east and a porch to the west, small round-headed windows.
static func _ronne_nylars() -> void:
	var white := Color("f2efe6")
	var shade := Color("d8d4c8")
	var roof := Color("4a4542")
	_r(-13, 0, 13, 0.6, Color("8f8a80"))
	# the porch
	_r(-11.5, 0.6, -6, 5.2, white)
	_poly([-11.9, 5.2, -5.8, 5.2, -8.8, 8.2], white)
	_poly([-12.1, 5.0, -8.8, 8.4, -8.8, 8.0, -11.7, 5.0], roof)
	_arched(-8.8, 0.6, 1.4, 2.8, Color("4a3e30"))
	# the chancel and the apse
	_r(6, 0.6, 11.5, 6.4, white)
	_poly([5.8, 6.4, 11.7, 6.4, 8.75, 9.4], roof)
	_r(11.5, 0.6, 13.2, 5.4, shade)
	_poly([11.3, 5.4, 13.6, 5.4, 11.3, 7.4], roof)
	# the round nave with its shaded side and the cone roof
	_r(-6, 0.6, 6, 10.5, white)
	_r(3.2, 0.6, 6, 10.5, shade)
	_poly([-6.7, 10.5, 6.7, 10.5, 0, 17.6], roof)
	_poly([0, 17.6, 6.7, 10.5, 3.0, 10.5], Color("3a3634"))
	for x in [-3.0, 1.5]:
		_arched(x, 4.0, 0.8, 1.8, WIN)
	_arched(-1.0, 7.6, 0.6, 1.4, WIN)
	_c(0, 17.8, 0.25, DARK)

## The Sand-Covered Church near Skagen: only the whitewashed tower with its crow-stepped gables is left, the dune
## drifted up against it, tufts of marram grass on the sand.
static func _skagen_church() -> void:
	var white := Color("f2efe6")
	var shade := Color("dcd7ca")
	_r(-3.6, 0, 3.6, 16.5, white)
	_r(1.6, 0, 3.6, 16.5, shade)
	# the roof behind and the stepped gable in front
	_poly([-3.4, 16.5, 3.4, 16.5, 0, 21.5], TILE)
	_stepped(-3.6, 3.6, 16.5, 23.2, 5, white)
	if _detail(0.8):
		_arched(-1.2, 17.2, 0.8, 1.6, WIN)
		_arched(1.2, 17.2, 0.8, 1.6, WIN)
		_arched(0, 11.0, 1.0, 2.4, WIN)
		_arched(0, 6.5, 0.9, 1.8, WIN)
	# the dune and the marram grass
	_poly([-8, 0, 8, 0, 8, 1.2, 4.5, 2.2, 2.0, 3.4, -1.0, 4.6, -4.0, 4.4, -6.5, 3.0, -8, 1.8], SAND)
	_poly([-8, 0, 8, 0, 8, 0.6, -8, 0.6], Color("cdbd8e"))
	if _detail(1.0):
		var grass := Color("8a9a5a")
		for gx in [-6.5, -4.6, -2.2, 0.4, 3.0, 5.6]:
			var gy := 1.2 + 3.2 * (1.0 - absf(gx + 2.0) / 7.0)
			_l(gx, gy, gx - 0.4, gy + 0.9, grass, 0.08)
			_l(gx, gy, gx + 0.1, gy + 1.1, grass, 0.08)
			_l(gx, gy, gx + 0.5, gy + 0.8, grass, 0.08)
