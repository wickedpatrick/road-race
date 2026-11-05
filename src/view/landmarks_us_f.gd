class_name LandmarksUsF
extends RefCounted
## American landmarks of the northern Rockies and the Inland Northwest (Billings, Spokane), drawn with
## LandmarkPainter's helpers (metres from the base point, y up).

const WHITE := Color("f4f2ea")
const WATER := Color("3f7fb5")
const WATER_L := Color("9cc8e6")
const GRASS := Color("6f9a48")
const PINE := Color("2f5a36")
const WOOD := Color("7a5634")
const DARK := Color("2e3238")
const WIN := Color("3a4048")
const STEAM := Color(1, 1, 1, 0.75)
const RED := Color("c8282c")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"rimrocks": _rimrocks()
		"old_faithful": _old_faithful()
		"spokane_falls": _spokane_falls()
		"red_wagon": _red_wagon()
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

static func _pl(xy: Array, col: Color, w: float) -> void:
	LandmarkPainter._pl(xy, col, w)

static func _ell(cx: float, cy: float, rx: float, ry: float, rot: float, col: Color) -> void:
	LandmarkPainter._ell(cx, cy, rx, ry, rot, col)

static func _windows(x0: float, x1: float, y0: float, y1: float, n: int, col: Color) -> void:
	LandmarkPainter._windows(x0, x1, y0, y1, n, col)

static func _arc(cx: float, cy: float, rx: float, ry: float, a0: float, a1: float, n: int) -> Array:
	return LandmarkPainter._arc_pts(cx, cy, rx, ry, a0, a1, n)

static func _detail(min_pm: float) -> bool:
	return LandmarkPainter._pm > min_pm

## A tall, narrow pine (ponderosa or lodgepole): a brown stem and stacked dark triangles, `h` tall.
static func _pine(x: float, y: float, h: float, col: Color) -> void:
	_r(x - h * 0.035, y, x + h * 0.035, y + h * 0.3, WOOD)
	for k in 3:
		var y0 := y + h * (0.22 + k * 0.22)
		var w := h * (0.2 - k * 0.045)
		_poly([x - w, y0, x + w, y0, x, y0 + h * 0.38], col)
		_poly([x - w, y0, x, y0, x, y0 + h * 0.38], col.lightened(0.1))

## The Rimrocks of Billings: a long wall of golden sandstone cliffs, layered and cracked, with pines along the
## flat top and a slope of fallen rock and sagebrush at the foot, the city's low houses and its one tall
## office tower in front.
static func _rimrocks() -> void:
	var face := Color("d9b273")
	var face_d := Color("b88b52")
	var face_l := Color("ecd09a")
	# the cliff top: a wavy rim, higher in the middle
	var top := [-45, 22, -38, 24, -30, 26.5, -20, 28, -8, 29, 4, 29.5, 16, 28.5, 26, 27, 36, 25, 45, 23]
	var face_poly := [-45, 8]
	face_poly.append_array(top)
	face_poly.append_array([45, 8])
	_poly(face_poly, face)
	# the grassy top with pines along the rim
	var cap := []
	for k in range(0, top.size(), 2):
		cap.append_array([top[k], top[k + 1]])
	for k in range(top.size() - 2, -1, -2):
		cap.append_array([top[k], top[k + 1] + 1.2])
	_poly(cap, Color("8a9a58"))
	for p in [[-36, 24.8, 4.5], [-33, 25.6, 3.5], [-17, 28.6, 5.0], [-14, 28.9, 4.0], [9, 29.5, 4.5], [24, 27.6, 5.0],
			[27, 27.2, 3.6], [40, 24.6, 4.0]]:
		_pine(p[0], p[1], p[2], PINE)
	# the strata: darker bands running level along the face, and a lit band under the rim
	for k in range(0, top.size() - 2, 2):
		var x0: float = top[k]
		var x1: float = top[k + 2]
		var y0: float = top[k + 1]
		var y1: float = top[k + 3]
		_poly([x0, y0 - 1.5, x1, y1 - 1.5, x1, y1, x0, y0], face_l)
		_poly([x0, y0 - 7.5, x1, y1 - 7.5, x1, y1 - 6.3, x0, y0 - 6.3], face_d)
		_poly([x0, 13, x1, 13, x1, 14.2, x0, 14.2], face_d)
	# shadowed gullies between the buttresses, of uneven width, and a few lit pillars
	if _detail(0.6):
		for g in [[-41.0, 1.2], [-34.5, 2.2], [-26.0, 1.0], [-21.0, 2.6], [-10.5, 1.4], [-1.0, 2.0], [8.0, 1.0], [13.5, 2.8],
				[23.0, 1.4], [31.5, 2.2], [38.5, 1.0]]:
			var x: float = g[0]
			var w: float = g[1]
			var ty: float = _rim_y(top, x + w * 0.5) - 0.6
			_poly([x, 9, x + w, 9, x + w * 0.8, ty, x + w * 0.3, ty], face_d.darkened(0.15))
			_poly([x + w, 9, x + w + 1.4, 9, x + w + 0.9, ty - 1.0, x + w * 0.8, ty], face_l.darkened(0.04))
		# notches bitten out of the rim
		for x in [-28.0, -5.0, 19.0, 33.0]:
			var y := _rim_y(top, x)
			_poly([x - 1.5, y + 0.05, x + 1.5, y + 0.05, x + 0.6, y - 2.0, x - 0.4, y - 2.2], face_d)
	# the talus slope at the foot, with sage and junipers
	_poly([-45, 0, -45, 11, -36, 9.5, -26, 10.5, -16, 9, -4, 10, 8, 9, 20, 10.5, 32, 9, 45, 10, 45, 0], Color("b49a72"))
	_poly([-45, 0, -45, 6, -30, 5, -12, 6.5, 6, 5, 24, 6, 45, 5.5, 45, 0], Color("9c9a68"))
	if _detail(0.8):
		for p in [[-40, 7.5], [-28, 8.5], [-20, 7], [-6, 8], [3, 7], [15, 8.2], [28, 7.2], [38, 8]]:
			_c(p[0], p[1], 1.1, Color("5d7444"))
			_c(p[0] + 0.9, p[1] + 0.3, 0.8, Color("6e8a52"))
	if _detail(0.8):
		for b in [[-33, 10, 1.6], [-14, 9.5, 1.2], [5, 9.6, 1.8], [27, 9.8, 1.3], [-24, 7, 1.0], [17, 6.8, 1.1]]:
			_ell(b[0], b[1], b[2], b[2] * 0.7, 0.2, Color("a88a62"))
			_ell(b[0] - b[2] * 0.2, b[1] + b[2] * 0.2, b[2] * 0.6, b[2] * 0.4, 0.2, Color("c8aa7a"))
	_r(-45, 0, 45, 1.5, GRASS)
	# the town in front: low houses and the tall office tower downtown
	var hc := [Color("e8e0cc"), Color("c97a5a"), Color("dcd2b0"), Color("9fb2c0"), Color("e6c48a")]
	var k2 := 0
	for x in [-38.0, -31.0, -25.0, 12.0, 19.0, 26.0, 33.0]:
		var c: Color = hc[k2 % hc.size()]
		k2 += 1
		_r(x, 0, x + 5, 3.2, c)
		_poly([x - 0.4, 3.2, x + 5.4, 3.2, x + 2.5, 4.8], c.darkened(0.3))
		_windows(x + 0.5, x + 4.5, 1.2, 2.4, 2, WIN)
	_r(-16, 0, -6, 6, Color("d7cfbf"))
	_windows(-15.5, -6.5, 1, 5, 5, WIN)
	_r(-4, 0, 3, 18, Color("8f9298"))
	_r(-4, 0, -2.8, 18, Color("76797f"))
	if _detail(1.0):
		for y in range(2, 18, 2):
			_r(-2.6, y, 2.6, y + 0.9, Color("4c5a6a"))
	_r(-4.4, 18, 3.4, 18.8, Color("6a6d73"))

## Height of the cliff rim (flat [x, y, ...] points) at x.
static func _rim_y(top: Array, x: float) -> float:
	for k in range(0, top.size() - 2, 2):
		if x <= top[k + 2]:
			return lerpf(top[k + 1], top[k + 3], inverse_lerp(top[k], top[k + 2], x))
	return top[-1]

## Old Faithful in Yellowstone erupting: a column of boiling water shooting up from its pale sinter mound, spray
## falling back and steam billowing off the top, lodgepole pines behind and the boardwalk with watching visitors.
static func _old_faithful() -> void:
	# the forest behind
	for p in [[-21, 9.0], [-18, 11.0], [-15, 8.0], [-12, 10.0], [12, 9.0], [15, 11.5], [18, 8.5], [21, 10.0]]:
		_pine(p[0], 2, p[1], PINE.darkened(0.1))
	# the sinter mound: pale grey, stained orange where the hot water runs off
	_poly([-22, 0, -22, 2, -14, 3.2, -6, 4.6, -2, 5.2, 2, 5.2, 6, 4.6, 14, 3.2, 22, 2, 22, 0], Color("d8d6cc"))
	_poly([-22, 0, -22, 1.2, -12, 2.0, 0, 2.6, 12, 2.0, 22, 1.2, 22, 0], Color("bdb8a8"))
	if _detail(0.8):
		_poly([-6, 4.6, -3, 5.0, -8, 2.2, -12, 2.2], Color("d99a52"))
		_poly([4, 4.8, 7, 4.4, 13, 2.3, 9, 2.4], Color("c98a4a"))
	# the column of water: narrow at the vent, widening upwards, shaded on the right, a bright core
	var vent := 5.0
	var top := 38.0
	_poly([-1.8, vent, 1.8, vent, 3.4, 18, 5.0, top - 4, 3.5, top, -3.5, top, -5.0, top - 4, -3.4, 18], Color("dce8ee"))
	_poly([0.6, vent, 1.8, vent, 3.4, 18, 5.0, top - 4, 3.5, top, 1.4, top], Color("bccdd8"))
	_poly([-0.9, vent, 0.6, vent, 1.4, 18, 1.6, top - 3, -2.4, top - 3, -2.0, 18], WHITE)
	if _detail(0.9):
		for k in 6:
			var y := vent + 4.0 + k * 5.0
			var w := 2.0 + k * 0.5
			_l(-w, y, -w + 0.4, y + 3.5, Color("b8ccd8"), 0.25)
			_l(w * 0.5, y + 1.5, w * 0.5 - 0.3, y + 4.5, Color("dce8ee"), 0.25)
	# spray falling back down at both sides
	var drops := [[-6, 30], [-7.5, 24], [-8.5, 17], [-9, 11], [6.5, 32], [7.5, 26], [8.5, 19], [9.5, 12], [-6, 36], [6.5, 37],
		[-10, 6], [10.5, 7]]
	for d in drops:
		_c(d[0], d[1], 0.6, Color(1, 1, 1, 0.85))
		if _detail(1.0):
			_c(d[0] * 1.08, d[1] - 2.5, 0.4, Color(1, 1, 1, 0.7))
	# the steam plume on top, billowing and drifting right with the wind: grey underside, white tops
	var puffs := [[0, 39, 6.5, 4.5], [-4.5, 43, 5.5, 4.2], [4.5, 43.5, 6.5, 4.8], [0, 47, 6.0, 4.5], [8, 48, 6.5, 4.5],
		[3, 51.5, 6.0, 4.0], [11, 52.5, 6.0, 3.6], [16, 54, 5.0, 2.6], [-3, 50, 4.5, 3.4]]
	for p in puffs:
		_ell(p[0], p[1] - 0.6, p[2], p[3], 0, Color("c4ccd2"))
	for p in puffs:
		_ell(p[0] - p[2] * 0.12, p[1] + p[3] * 0.15, p[2] * 0.85, p[3] * 0.82, 0, Color("eef2f4"))
	for p in puffs:
		_ell(p[0] - p[2] * 0.25, p[1] + p[3] * 0.35, p[2] * 0.5, p[3] * 0.5, 0, Color.WHITE)
	# steam at the vent
	_ell(-2, 6.5, 4.0, 1.8, 0, STEAM)
	_ell(2.5, 7.0, 3.5, 1.6, 0, STEAM)
	# the boardwalk in front with its railing and visitors
	var plank := Color("8a6a48")
	_r(-22, 0, 22, 0.9, plank)
	_l(-22, 2.0, 22, 2.0, plank.darkened(0.2), 0.18)
	if _detail(0.8):
		for k in 12:
			var x := -21.0 + k * 3.8
			_l(x, 0.9, x, 2.0, plank.darkened(0.2), 0.15)
	var coats := [Color("d23b33"), Color("2f6fa6"), Color("f2c230"), Color("49a85a"), Color("7a4a9a")]
	var k3 := 0
	for x in [-17.0, -15.8, -11.0, 10.5, 12.0, 16.5]:
		var c: Color = coats[k3 % coats.size()]
		k3 += 1
		_r(x - 0.3, 0.9, x + 0.3, 2.3, c)
		_c(x, 2.6, 0.32, Color("e6c2a0"))

## The Spokane Falls in Riverfront Park: white water tumbling over dark basalt ledges, and above them on the bank
## the Pavilion (a tall cone of white steel cables strung from a ring to its mast, lit with little lights) and the
## old brick clock tower of the Great Northern station.
static func _spokane_falls() -> void:
	var bank := Color("6f9a48")
	# the park lawn above the falls
	_r(-42, 10, 42, 14, bank)
	# the Pavilion: a cone of cables from a ring on the ground to the top of its mast
	var cx := -18.0
	var apex := 48.0
	var rx := 16.0
	var base := 14.0
	var cab := Color("e6e8ea")
	_l(cx, base, cx, apex + 3, Color("b5bcc4"), 0.45)
	var n := 22
	for k in n + 1:
		var a := PI * k / n # the front half of the ring, left to right
		var bx := cx - cos(a) * rx
		var by := base - sin(a) * 1.2
		_l(bx, by, cx, apex, cab, 0.18)
	# the back of the ring through the front lines, and rings of cable round the cone
	for t in [0.25, 0.5, 0.72]:
		var y: float = lerpf(base, apex, t)
		var r: float = rx * (1.0 - t)
		_pl(_arc(cx, y, r, 1.2 * (1.0 - t), PI, TAU, 14), Color("c8ccd0"), 0.15)
	_pl(_arc(cx, base, rx, 1.2, PI, TAU, 20), Color("9aa2aa"), 0.35)
	if _detail(1.0):
		for k in 9:
			var t := 0.12 + k * 0.09
			var y: float = lerpf(base, apex, t)
			_c(cx - rx * (1.0 - t) * 0.6, y, 0.3, Color("ffe9a0"))
			_c(cx + rx * (1.0 - t) * 0.3, y + 1.0, 0.3, Color("ffe9a0"))
	_c(cx, apex + 3, 0.35, Color("e85a4a"))
	# the clock tower: a tall square brick tower, its clock near the top and a pointed roof
	var tx := 16.0
	var brick := Color("a5583a")
	var brick_d := Color("7f3e28")
	_r(tx - 3.0, base, tx + 3.0, 40, brick)
	_r(tx + 1.6, base, tx + 3.0, 40, brick_d)
	if _detail(1.0):
		for y in [20.0, 26.0, 32.0]:
			_r(tx - 1.6, y, tx - 0.4, y + 3.0, WIN)
			_r(tx + 0.4, y, tx + 1.4, y + 3.0, WIN)
		for y in [18.0, 24.0, 30.0, 36.0]:
			_r(tx - 3.0, y, tx + 3.0, y + 0.4, Color("d8c8a8"))
	_r(tx - 3.6, 40, tx + 3.6, 41, Color("d8c8a8"))
	_r(tx - 3.2, 41, tx + 3.2, 46, brick)
	_r(tx + 1.8, 41, tx + 3.2, 46, brick_d)
	_c(tx - 0.3, 43.5, 1.9, Color("f4f0e0"))
	_c(tx - 0.3, 43.5, 1.9 * 0.18, DARK)
	_l(tx - 0.3, 43.5, tx - 0.3, 44.9, DARK, 0.2)
	_l(tx - 0.3, 43.5, tx + 0.7, 43.5, DARK, 0.2)
	_r(tx - 3.6, 46, tx + 3.6, 46.8, Color("d8c8a8"))
	_poly([tx - 3.4, 46.8, tx + 3.4, 46.8, tx, 51], Color("5c6a5a"))
	_l(tx, 51, tx, 52, DARK, 0.15)
	# trees of the park between them
	for p in [[-1.0, 3.5], [3.0, 2.8], [6.5, 3.2], [26.0, 3.0], [30.0, 3.8], [36.0, 3.0], [-38.0, 3.2]]:
		_r(p[0] - 0.25, base, p[0] + 0.25, base + 1.6, WOOD)
		_c(p[0], base + 1.6 + p[1] * 0.6, p[1], Color("4f7a3a"))
	# the falls: the river comes over a basalt lip, drops onto a ledge and again into the pool below
	var rock := Color("4a4644")
	var rock_l := Color("6a6460")
	_poly([-42, 0, -42, 11.5, -36, 11, -30, 11.8, -24, 11.2, -10, 11.6, 0, 11.0, 10, 11.6, 22, 11.2, 32, 11.8, 42, 11.5, 42, 0], rock)
	# the river at the top of the falls
	_poly([-36, 10.6, 30, 10.6, 30, 11.6, -36, 11.6], WATER)
	# the middle ledge
	_poly([-42, 0, -42, 6.5, -34, 6, -20, 6.6, -4, 6.0, 10, 6.6, 26, 6.0, 42, 6.5, 42, 0], rock_l.darkened(0.1))
	if _detail(0.9): # columnar basalt
		for k in 21:
			var x := -41.0 + k * 4.0
			_l(x, 6.2, x + 0.3, 2.0, rock.darkened(0.2), 0.2)
			_l(x + 2.0, 11.0, x + 2.2, 7.0, rock.darkened(0.25), 0.2)
	# white water: broad curtains over the upper lip, narrower chutes over the ledge, each widening as it falls
	var foam := Color("f2f8fa")
	var spray := Color("cfe6ee")
	for f in [[-34.0, -24.0], [-20.0, -3.0], [3.0, 16.0], [20.0, 28.0]]:
		var x0: float = f[0]
		var x1: float = f[1]
		_poly([x0, 10.8, x1, 10.8, x1 + 1.2, 6.8, x0 - 1.2, 6.8], spray)
		_poly([x0 + 0.4, 10.8, x1 - 0.4, 10.8, x1 - 0.2, 7.2, x0 + 0.2, 7.2], foam)
		_ell((x0 + x1) * 0.5, 6.9, (x1 - x0) * 0.6, 0.8, 0, Color(1, 1, 1, 0.9))
		if _detail(0.8):
			var m := int((x1 - x0) / 1.6)
			for k in m:
				var x := x0 + (k + 0.5) * (x1 - x0) / m
				_l(x, 10.6, x + 0.1, 7.4, spray.darkened(0.08), 0.18)
	for f in [[-30.0, -22.0], [-12.0, 0.0], [8.0, 14.0], [22.0, 30.0]]:
		var x0: float = f[0]
		var x1: float = f[1]
		_poly([x0, 6.4, x1, 6.4, x1 + 1.6, 1.6, x0 - 1.6, 1.6], spray)
		_poly([x0 + 0.5, 6.4, x1 - 0.5, 6.4, x1 + 0.4, 1.8, x0 - 0.4, 1.8], foam)
		if _detail(0.8):
			var m := int((x1 - x0) / 1.6)
			for k in m:
				var x := x0 + (k + 0.5) * (x1 - x0) / m
				_l(x, 6.2, x * 1.01, 2.0, spray.darkened(0.08), 0.18)
	# the pool below and the spray rising off it
	_r(-42, 0, 42, 2.0, WATER)
	if _detail(1.0):
		for p in [[-38, 0.8], [-17, 1.0], [2, 0.6], [33, 1.1]]:
			_r(p[0], p[1], p[0] + 5, p[1] + 0.25, WATER_L)
	for x in [-30.0, -24.0, -10.0, -3.0, 9.0, 14.0, 24.0, 29.0]:
		_c(x, 2.2, 2.2, Color(1, 1, 1, 0.75))
		_c(x + 1.5, 3.6, 1.5, Color(1, 1, 1, 0.5))

## Strokes of one capital letter in a unit box (x right, y up), as polylines.
static func _letter(ch: String) -> Array:
	match ch:
		"R": return [[0, 0, 0, 1, 0.7, 1, 0.9, 0.85, 0.9, 0.65, 0.7, 0.5, 0, 0.5], [0.45, 0.5, 1, 0]]
		"A": return [[0, 0, 0.5, 1, 1, 0], [0.22, 0.4, 0.78, 0.4]]
		"D": return [[0, 0, 0, 1, 0.55, 1, 0.9, 0.8, 1, 0.5, 0.9, 0.2, 0.55, 0, 0, 0]]
		"I": return [[0.5, 0, 0.5, 1]]
		"O": return [_arc(0.5, 0.5, 0.5, 0.5, 0, TAU, 12)]
		"F": return [[0, 0, 0, 1, 1, 1], [0, 0.5, 0.75, 0.5]]
		"L": return [[0, 1, 0, 0, 0.9, 0]]
		"Y": return [[0, 1, 0.5, 0.5, 1, 1], [0.5, 0.5, 0.5, 0]]
		"E": return [[1, 1, 0, 1, 0, 0, 1, 0], [0, 0.5, 0.75, 0.5]]
	return []

## The giant Red Wagon in Riverfront Park: a toy wagon as big as a room on its four big black wheels, with a
## stair at the back and its long handle coming down to the grass as a slide, a child sliding down it.
static func _red_wagon() -> void:
	_r(-10, 0, 10, 0.4, GRASS)
	var body := RED
	var body_d := Color("962024")
	var x0 := -9.0
	var x1 := 2.0
	var y0 := 1.3
	var y1 := 3.8
	# the wheels behind the body
	for wx in [x0 + 1.6, x1 - 1.6]:
		_c(wx, 1.2, 1.2, DARK)
		_c(wx, 1.2, 0.55, Color("e8e8e0"))
		_c(wx, 1.2, 0.22, body)
	# the body: a deep red box, its rim rolled over, white lettering band
	_r(x0, y0, x1, y1, body)
	_r(x0, y0, x1, y0 + 0.35, body_d)
	_r(x0 - 0.15, y1, x1 + 0.15, y1 + 0.35, body.lightened(0.15))
	# "RADIO FLYER" in white letters along the side
	var lx := x0 + 1.0
	var lh := 0.9
	var lw := 0.42
	for ch in "RADIO FLYER":
		if ch != " ":
			for st in _letter(ch):
				var pts := []
				for j in range(0, st.size(), 2):
					pts.append_array([lx + st[j] * lw, y0 + 0.8 + st[j + 1] * lh])
				if _detail(1.6):
					_pl(pts, WHITE, 0.13)
			if not _detail(1.6):
				_r(lx, y0 + 0.8, lx + lw, y0 + 0.8 + lh, WHITE)
		lx += lw + 0.32
	# the stair up the back, with its handrail
	var st := Color("8a8e94")
	for k in 4:
		var y := 0.4 + k * 0.85
		_r(x0 - 2.6 + k * 0.6, y, x0 - 0.1, y + 0.2, st)
	_l(x0 - 2.6, 0.4, x0 - 0.8, y1, st.darkened(0.2), 0.14)
	_l(x0 - 2.7, 0.4, x0 - 2.7, 1.4, st, 0.1)
	_l(x0 - 2.7, 1.4, x0 - 0.4, y1 + 1.0, st, 0.1)
	_l(x0 - 0.4, y1 + 1.0, x0 - 0.4, y1 + 0.3, st, 0.1)
	# the front axle and the handle: a long slide from the wagon down to the grass, a T grip at the end
	var hx0 := x1 - 0.2
	var hy0 := y1 - 0.1
	var hx1 := 9.6
	var hy1 := 0.6
	_l(x1 - 1.6, 1.2, x1 + 0.6, 2.2, DARK, 0.3)
	_l(hx0, hy0, hx1, hy1, Color("d8d8d0"), 0.55)
	_l(hx0, hy0 + 0.3, hx1, hy1 + 0.3, body, 0.25)
	_l(hx0, hy0 - 0.3, hx1, hy1 - 0.25, body_d, 0.18)
	_r(hx1 - 0.2, 0.4, hx1 + 0.2, 1.4, DARK)
	_r(hx1 - 0.2, 1.2, hx1 + 0.9, 1.5, DARK)
	# a child whooshing down the slide
	var t := 0.45
	var kx := lerpf(hx0, hx1, t)
	var ky := lerpf(hy0, hy1, t) + 0.35
	_l(kx - 0.2, ky, kx + 0.7, ky - 0.2, Color("2f6fa6"), 0.22)
	_l(kx - 0.1, ky, kx - 0.25, ky + 0.75, Color("f2c230"), 0.32)
	_c(kx - 0.3, ky + 1.05, 0.25, Color("e6c2a0"))
	_l(kx - 0.2, ky + 0.6, kx + 0.4, ky + 0.95, Color("e6c2a0"), 0.1)
