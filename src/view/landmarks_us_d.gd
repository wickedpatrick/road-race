class_name LandmarksUsD
extends RefCounted
## American landmarks, drawn with LandmarkPainter's helpers (metres from the base point, y up).

const WHITE := Color("f2efe6")
const DARK := Color("2e3238")
const WIN := Color("3a4048")
const SAND := Color("d9bf8c")
const DESERT := Color("c9a46a")
const SAGE := Color("8a9a5b")
const CACTUS := Color("3f7a3a")
const WATER := Color("4f8fc0")
const WATER_L := Color("9cc8e6")
const GOLD := Color("f2c53d")
const RED := Color("d0312d")
const WOOD := Color("7a5634")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"red_rocks": _red_rocks()
		"balloon_fiesta": _balloon_fiesta()
		"utah_capitol": _utah_capitol()
		"vegas_sign": _vegas_sign()
		"hoover_dam": _hoover_dam()
		"camelback_mountain": _camelback_mountain()
		"grand_canyon": _grand_canyon()
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

## A saguaro of height h at x: a ribbed column with one or two upturned arms.
static func _saguaro(x: float, h: float, arms: int) -> void:
	var w := h * 0.13
	var cd := CACTUS.darkened(0.2)
	_r(x - w * 0.5, 0, x + w * 0.5, h - w * 0.5, CACTUS)
	_c(x, h - w * 0.5, w * 0.5, CACTUS)
	_r(x + w * 0.15, 0, x + w * 0.5, h - w * 0.5, cd)
	var aw := w * 0.8
	# the left arm
	_r(x - w * 1.3, h * 0.42, x, h * 0.42 + aw, CACTUS)
	_r(x - w * 1.3, h * 0.42, x - w * 1.3 + aw, h * 0.75, CACTUS)
	_c(x - w * 1.3 + aw * 0.5, h * 0.75, aw * 0.5, CACTUS)
	if arms > 1: # the right arm
		_r(x, h * 0.55, x + w * 1.3, h * 0.55 + aw, cd)
		_r(x + w * 1.3 - aw, h * 0.55, x + w * 1.3, h * 0.85, cd)
		_c(x + w * 1.3 - aw * 0.5, h * 0.85, aw * 0.5, cd)

## A low desert shrub.
static func _shrub(x: float, r: float) -> void:
	_c(x, r * 0.5, r, SAGE)
	_c(x - r * 0.4, r * 0.7, r * 0.6, SAGE.lightened(0.12))

## Red Rocks Amphitheatre near Denver: two huge tilted slabs of red sandstone (Creation Rock and Ship Rock) with
## the stage and its roof between them and the stepped rows of seats rising towards the road.
static func _red_rocks() -> void:
	var rock := Color("b4482c")
	var rl := Color("cf6a43")
	var rd := Color("86321f")
	_r(-35, 0, 35, 2, Color("a87e58"))
	# Creation Rock on the left, leaning back over the stage
	_poly([-35, 0, -35, 14, -31, 24, -24, 30, -18, 31, -13, 26, -10, 16, -8, 8, -7, 0], rock)
	_poly([-35, 0, -35, 14, -31, 24, -27, 26, -28, 12, -26, 0], rd)
	_poly([-18, 31, -13, 26, -10, 16, -8, 8, -7, 0, -11, 0, -13, 12, -16, 24], rl)
	# Ship Rock on the right, the taller one, its prow over the stage
	_poly([7, 0, 8, 10, 10, 22, 13, 30, 17, 34, 22, 33, 28, 27, 33, 18, 35, 10, 35, 0], rock)
	_poly([7, 0, 8, 10, 10, 22, 13, 30, 15, 31, 13, 18, 11, 0], rl)
	_poly([28, 27, 33, 18, 35, 10, 35, 0, 29, 0, 30, 14], rd)
	if _detail(1.0): # the bedding lines of the sandstone
		_l(-30, 10, -14, 22, rd, 0.3)
		_l(-32, 5, -10, 12, rd, 0.3)
		_l(14, 26, 30, 18, rd, 0.3)
		_l(12, 16, 33, 8, rd, 0.3)
		_l(10, 6, 34, 2, rd, 0.3)
	# the stage and its roof between the rocks
	_r(-8, 2, 8, 6, DARK)
	_r(-8, 6, 8, 11, Color("3b3f46"))
	_l(-7.5, 6, -7.5, 13, Color("c9ccd0"), 0.35)
	_l(7.5, 6, 7.5, 13, Color("c9ccd0"), 0.35)
	_poly([-9, 13, 9, 13, 8, 14.5, -8, 14.5], Color("e8e8e4"))
	_r(-6, 4, 6, 5, Color("6a5a4a"))
	if _detail(1.0): # stage lights
		for k in 5:
			_c(-5 + k * 2.5, 12.3, 0.4, GOLD)
	# the stepped rows of seats in front
	var bench := Color("b8a58a")
	for k in 4:
		_r(-15 + k * 1.2, 0.3 + k * 0.4, 15 - k * 1.2, 0.6 + k * 0.4, bench.darkened(0.15 if k % 2 == 0 else 0.0))
	# pine trees on the slopes
	for t in [[-33.0, 2.0], [32.5, 2.0], [-25.0, 1.5]]:
		_poly([t[0] - 1.6, t[1], t[0] + 1.6, t[1], t[0], t[1] + 4.5], Color("3f6f34"))

## The Albuquerque International Balloon Fiesta: striped hot-air balloons floating over the desert, the pink
## Sandia Mountains behind.
static func _balloon_fiesta() -> void:
	# the Sandia Mountains
	_poly([-30, 0, -30, 12, -24, 15, -16, 20, -9, 22, -2, 25, 6, 24, 14, 20, 22, 17, 30, 13, 30, 0], Color("b9788a"))
	_poly([-2, 25, 6, 24, 14, 20, 22, 17, 30, 13, 30, 0, 4, 0], Color("a3687a"))
	_r(-30, 0, 30, 3, DESERT)
	if _detail(1.0):
		_r(-30, 3, 30, 4, Color("8a9a5b"))
	_shrub(-25, 1.0)
	_shrub(19, 1.2)
	# the balloons, back to front
	_balloon(18, 34, 5, [Color("2a7fd4"), GOLD, Color("2a7fd4")])
	_balloon(-19, 37, 4.2, [Color("7a3fb0"), Color("f08a24"), Color("7a3fb0")])
	_balloon(-7, 22, 5.2, [RED, GOLD, Color("2f9e57")])
	_balloon(8, 13, 6.5, [Color("f08a24"), RED, GOLD])
	_balloon(-21, 12, 3.6, [Color("2f9e57"), WHITE, Color("2f9e57")])
	_balloon(24, 18, 3.2, [Color("e04f8c"), WHITE, Color("e04f8c")])

## A hot-air balloon with its envelope centre at (x, y), radius r, in vertical gores of three colours, and its
## wicker basket below.
static func _balloon(x: float, y: float, r: float, cols: Array) -> void:
	var a: Color = cols[0]
	var b: Color = cols[1]
	var m: Color = cols[2]
	var neck := y - r * 1.45
	_poly([x - r * 0.97, y - r * 0.2, x - r * 0.25, neck, x + r * 0.25, neck, x + r * 0.97, y - r * 0.2], a)
	_c(x, y, r, a)
	_poly([x - r * 0.62, y - r * 0.4, x - r * 0.16, neck, x + r * 0.16, neck, x + r * 0.62, y - r * 0.4], b)
	_ell(x, y, r * 0.66, r, 0, b)
	_poly([x - r * 0.28, y - r * 0.5, x - r * 0.07, neck, x + r * 0.07, neck, x + r * 0.28, y - r * 0.5], m)
	_ell(x, y, r * 0.3, r, 0, m)
	_ell(x - r * 0.45, y + r * 0.35, r * 0.18, r * 0.35, -0.4, Color(1, 1, 1, 0.3))
	# the ropes and the basket
	var by := neck - r * 0.45
	_l(x - r * 0.25, neck, x - r * 0.16, by, DARK, 0.1)
	_l(x + r * 0.25, neck, x + r * 0.16, by, DARK, 0.1)
	_r(x - r * 0.2, by - r * 0.28, x + r * 0.2, by, WOOD)
	_r(x - r * 0.2, by - 0.05, x + r * 0.2, by, WOOD.darkened(0.3))

## The Utah State Capitol in Salt Lake City: a long granite building with a Corinthian colonnade, the copper dome
## on its drum, and the snowy Wasatch peaks behind.
static func _utah_capitol() -> void:
	var gr := Color("cfcbc2")
	var gd := gr.darkened(0.15)
	var gl := gr.lightened(0.1)
	# the Wasatch Range behind
	_poly([-30, 10, -24, 22, -18, 28, -12, 24, -6, 32, 0, 27, 6, 33, 13, 26, 19, 30, 25, 22, 30, 18, 30, 10], Color("7f8aa0"))
	_poly([-18, 28, -16, 25.5, -14.5, 26.5, -12, 24, -14, 23, -20, 25], WHITE)
	_poly([-6, 32, -3.5, 29, -2, 30, 0, 27, -8, 29.5], WHITE)
	_poly([6, 33, 8.5, 30, 10.5, 30.5, 13, 26, 4, 29.5], WHITE)
	_poly([19, 30, 21.5, 26.5, 23, 27, 25, 22, 16, 27], WHITE)
	# the lawn and the steps
	_r(-30, 0, 30, 2, Color("5d8f42"))
	_poly([-7, 2, 7, 2, 5.5, 4, -5.5, 4], gd)
	# the long building
	_r(-27, 2, 27, 14, gr)
	_r(-27, 2, 27, 4, gd)
	_r(-27, 13, 27, 14.5, gl)
	_windows(-26, -9, 6, 11, 7, WIN)
	_windows(9, 26, 6, 11, 7, WIN)
	# the wings' end pavilions
	for s in [-1.0, 1.0]:
		_r(s * 27 - 3, 2, s * 27 + (3 if s < 0 else -3), 15.5, gl)
	# the central portico with its columns and pediment
	_r(-8, 4, 8, 15, gl)
	for k in 7:
		var x := -7.0 + k * (14.0 / 6.0)
		_r(x - 0.45, 4, x + 0.45, 14.5, gr if k % 2 else gl)
	_r(-8.5, 14.5, 8.5, 16, gd)
	_poly([-8.5, 16, 8.5, 16, 0, 19.5], gl)
	_poly([-6.5, 16.5, 6.5, 16.5, 0, 18.8], gr)
	# the drum with its colonnade, the copper dome and the lantern
	_r(-7, 19, 7, 21, gd)
	_r(-6, 21, 6, 26.5, gl)
	for k in 9:
		var x := -5.4 + k * 1.35
		_r(x - 0.25, 21, x + 0.25, 26.5, gd)
	_r(-6.5, 26.5, 6.5, 27.5, gd)
	var cu := Color("8c9a86")
	_poly(_arc(0, 27.5, 6, 7.5, 0, PI, 14), cu)
	_poly([-6, 27.5] + _arc(0, 27.5, 6, 7.5, PI, PI * 0.6, 6) + [0, 27.5], cu.lightened(0.15))
	if _detail(1.0):
		for a in [0.7, 1.15, 1.6, 2.05, 2.45]:
			_l(0, 35, cos(a) * 6, 27.5 + sin(a) * 1.2, cu.darkened(0.2), 0.15)
	_r(-1.2, 34.8, 1.2, 38, gl)
	_poly([-1.4, 38, 1.4, 38, 0, 40], cu)

## The "Welcome to Fabulous Las Vegas" sign: a white diamond edged with red and light bulbs on two posts, white
## circles for WELCOME, the blue line of "Fabulous", big red LAS VEGAS, and a gold star on top.
static func _vegas_sign() -> void:
	_poly([-4, 0, 4, 0, 3.4, 0.5, -3.4, 0.5], Color("b9b4a8"))
	_r(-4.5, 0, 4.5, 0.3, Color("6f9a4a"))
	# the two posts
	for x in [-1.5, 1.5]:
		_r(x - 0.35, 0.3, x + 0.35, 5, Color("e2ddd2"))
		_r(x + 0.1, 0.3, x + 0.35, 5, Color("b9b4a8"))
	# the diamond
	var yc := 7.2
	_poly([-4.5, yc, 0, 10.4, 4.5, yc, 0, 4.0], RED)
	_poly([-4.0, yc, 0, 10.0, 4.0, yc, 0, 4.4], WHITE)
	if _detail(1.5): # the light bulbs round the edge
		for k in 9:
			var t := (k + 0.5) / 9.0
			for s in [-1.0, 1.0]:
				_c(s * 4.25 * (1 - t), yc + 3.0 * t, 0.12, GOLD)
				_c(s * 4.25 * (1 - t), yc - 3.0 * t, 0.12, GOLD)
	# WELCOME in seven circles
	for k in 7:
		var x := -1.8 + k * 0.6
		_c(x, 8.75, 0.27, RED)
		_c(x, 8.75, 0.2, WHITE)
		if _detail(2.0):
			_c(x, 8.75, 0.08, RED)
	# "to Fabulous"
	_pl([-1.6, 7.9, -1.0, 8.15, -0.4, 7.85, 0.3, 8.15, 0.9, 7.85, 1.6, 8.1], Color("2a5fb8"), 0.12)
	# LAS VEGAS in red letters
	var x0 := -3.2
	for ch in "LAS VEGAS":
		if ch != " ":
			_letter(ch, x0, 6.45, 0.48, 0.85)
		x0 += 0.73
	# NEVADA
	_l(-1.1, 5.3, 1.1, 5.3, Color("2a5fb8"), 0.18)
	# the star on top
	var st := []
	for k in 16:
		var a := PI * 0.5 + TAU * k / 16.0
		var rr := 1.0 if k % 2 == 0 else 0.45
		st.append_array([cos(a) * rr, 11.0 + sin(a) * rr])
	_poly([-0.6, 10.0, 0.6, 10.0, 0, 11.0], RED)
	_poly(st, GOLD)
	_c(0, 11.0, 0.3, Color("ffe68a"))

## One block letter of LAS VEGAS, w wide and h high from (x, y), drawn in red strokes.
static func _letter(ch: String, x: float, y: float, w: float, h: float) -> void:
	var lines := {
		"L": [[0, 1, 0, 0, 1, 0]],
		"A": [[0, 0, 0.5, 1, 1, 0], [0.25, 0.45, 0.75, 0.45]],
		"S": [[1, 1, 0, 1, 0, 0.5, 1, 0.5, 1, 0, 0, 0]],
		"V": [[0, 1, 0.5, 0, 1, 1]],
		"E": [[1, 1, 0, 1, 0, 0, 1, 0], [0, 0.5, 0.75, 0.5]],
		"G": [[1, 1, 0, 1, 0, 0, 1, 0, 1, 0.45, 0.5, 0.45]],
	}
	for pl in lines[ch]:
		var pts := []
		for k in range(0, pl.size(), 2):
			pts.append_array([x + pl[k] * w, y + pl[k + 1] * h])
		_pl(pts, RED, 0.14)

## The Hoover Dam on the Colorado: the pale curved concrete wall wedged in a dark canyon, the road on its crest,
## the four intake towers standing in Lake Mead behind it, and the power house at its foot.
static func _hoover_dam() -> void:
	var rock := Color("8a5a3c")
	var rd := Color("6b4430")
	var con := Color("e3dccd")
	var cd := con.darkened(0.12)
	# Lake Mead behind, between the canyon walls
	_r(-40, 36, 40, 41, WATER)
	if _detail(1.0):
		_r(-25, 39, 25, 39.5, WATER_L)
	# the four intake towers in the lake
	for x in [-20.0, -12.0, 12.0, 20.0]:
		_r(x - 1.6, 36, x + 1.6, 46, con)
		_r(x + 0.6, 36, x + 1.6, 46, cd)
		_r(x - 1.9, 46, x + 1.9, 47, cd)
		_r(x - 0.9, 47, x + 0.9, 48.5, con)
		if _detail(1.0):
			_r(x - 0.4, 38, x + 0.4, 45, cd)
	# the curved dam face, wider at its crest
	_poly([-30, 38, 30, 38, 10, 4, -10, 4], con)
	_poly([-30, 38, -14, 38, -6, 4, -10, 4], con.lightened(0.06))
	_poly([14, 38, 30, 38, 10, 4, 6, 4], cd)
	if _detail(1.0): # the faint lifts of the concrete pour
		for y in [12.0, 20.0, 28.0]:
			var hw: float = 10.0 + (y - 4.0) / 34.0 * 20.0
			_l(-hw, y, hw, y, cd, 0.15)
	# the road along the crest
	_r(-31, 38, 31, 40, Color("c9c2b2"))
	_r(-31, 40, 31, 40.6, Color("f0ebdf"))
	# the canyon walls on both sides
	_poly([-40, 0, -40, 50, -34, 48, -30, 42, -31, 30, -24, 20, -16, 10, -12, 4, -12, 0], rock)
	_poly([-40, 0, -40, 50, -36, 49, -34, 30, -28, 18, -24, 0], rd)
	_poly([40, 0, 40, 50, 35, 47, 31, 41, 32, 30, 25, 20, 17, 10, 12, 4, 12, 0], rock)
	_poly([40, 0, 40, 50, 37, 48, 36, 30, 29, 16, 26, 0], rd)
	# the power house at the foot and the river
	_r(-12, 0, 12, 3, Color("3f8a86"))
	_r(-10, 3, 10, 8, con)
	_r(-10, 7.5, 10, 8, cd)
	_windows(-9, 9, 4.5, 7, 9, WIN)
	if _detail(1.0):
		_r(-12, 1, 12, 1.4, Color("7fbcb6"))

## Camelback Mountain in Phoenix: the red-brown rock shaped like a resting camel, its head to the left and the big
## hump to the right, with saguaros and desert shrubs in front.
static func _camelback_mountain() -> void:
	var m := Color("a5583a")
	var ml := Color("c07450")
	var md := Color("7f4230")
	_poly([-40, 0, -40, 4, -36, 8, -32, 13, -28, 16, -25, 15.5, -22, 12, -17, 11, -12, 13, -6, 18, 0, 25, 6, 30,
		12, 32, 18, 31, 24, 27, 30, 20, 35, 12, 40, 6, 40, 0], m)
	# the sunlit faces and the shadowed gullies
	_poly([-36, 8, -32, 13, -28, 16, -27, 12, -31, 6], ml)
	_poly([0, 25, 6, 30, 12, 32, 9, 24, 2, 14, -4, 10], ml)
	_poly([18, 31, 24, 27, 30, 20, 35, 12, 40, 6, 40, 0, 26, 0, 22, 14], md)
	_poly([-25, 15.5, -22, 12, -17, 11, -19, 6, -24, 8], md)
	if _detail(1.0): # the Praying Monk rock on the head
		_poly([-29.5, 15.8, -29, 18, -28.2, 18.2, -27.8, 16], md)
	# the desert plain in front
	_r(-40, 0, 40, 3, DESERT)
	for x in [-33.0, -14.0, 3.0, 27.0, 36.0]:
		_shrub(x, 1.2)
	_saguaro(-24, 11, 2)
	_saguaro(-6, 8, 1)
	_saguaro(15, 12, 2)
	_saguaro(32, 7, 1)

## The Grand Canyon from the South Rim: walls striped in red, orange and cream, flat-topped temples rising from the
## depths, the dark inner gorge and the green Colorado River at the bottom, with juniper on the rims in front.
static func _grand_canyon() -> void:
	var bands := [Color("e8d3a8"), Color("d58a52"), Color("c0603b"), Color("e0a56a"), Color("a9452e"), Color("c97a4a")]
	# the far rim, its strata running level
	_r(-45, 36, 45, 37, Color("6f8a52"))
	var y := 36.0
	for k in bands.size():
		var nh := 3.5
		_r(-45, y - nh, 45, y, bands[k])
		y -= nh
	_r(-45, 0, 45, y, Color("8a5a4a"))
	# the temples, stepped stacks of the same strata
	_temple(-19, 4, 24, 20)
	_temple(17, 4, 21, 22)
	_temple(0, 4, 13, 14)
	# the dark inner gorge and the river
	_poly([-14, 0, -10, 6, -4, 7, 4, 7, 10, 6, 14, 0], Color("5a3f45"))
	_poly([-5, 0, -3, 3.4, 3, 3.4, 5, 0], Color("4a8a6a"))
	if _detail(1.0):
		_l(-1.5, 2, 1.5, 2, Color("8ac0a0"), 0.2)
	# the near rims in front, left and right
	_poly([-45, 0, -45, 22, -40, 21, -36, 18, -34, 12, -30, 8, -24, 4, -18, 0], Color("b36a42"))
	_poly([-45, 22, -40, 21, -36, 18, -38, 18, -45, 19], Color("e8d3a8"))
	_poly([45, 0, 45, 18, 41, 17, 38, 13, 34, 8, 28, 3, 24, 0], Color("9c5638"))
	_poly([45, 18, 41, 17, 38, 13, 40, 14, 45, 15], Color("e0c39a"))
	for t in [[-41.0, 21.0, 2.0], [-38.0, 19.5, 1.4], [42.5, 17.5, 1.6]]:
		_r(t[0] - 0.2, t[1], t[0] + 0.2, t[1] + t[2] * 0.8, WOOD)
		_c(t[0], t[1] + t[2] * 1.3, t[2], Color("4f6b3a"))

## A canyon temple centred at x from y0 to top y1, `w` wide at its foot: stacked strata narrowing upwards.
static func _temple(x: float, y0: float, y1: float, w: float) -> void:
	var cols := [Color("b9583a"), Color("a9452e"), Color("d58a52"), Color("c0603b"), Color("e8d3a8")]
	var n := cols.size()
	var dh := (y1 - y0) / n
	for k in n:
		var a := y0 + k * dh
		var hw0 := w * 0.5 * (1.0 - k * 0.12)
		var hw1 := w * 0.5 * (1.0 - (k + 1) * 0.12 + 0.07)
		_poly([x - hw0, a, x + hw0, a, x + hw1, a + dh, x - hw1, a + dh], cols[k])
		_poly([x + hw1 * 0.4, a, x + hw0, a, x + hw1, a + dh, x + hw1 * 0.4, a + dh], Color(0, 0, 0, 0.13))
