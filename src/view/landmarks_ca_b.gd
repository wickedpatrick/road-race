class_name LandmarksCaB
extends RefCounted
## Canadian landmarks of the Rockies and the prairies (Alberta, Saskatchewan), drawn with LandmarkPainter's
## helpers (metres from the base point, y up).

const WHITE := Color("f4f2ea")
const GRASS := Color("6f9a48")
const PINE := Color("2f5a36")
const FOREST := Color("2c4a34")
const WOOD := Color("7a5634")
const DARK := Color("2e3238")
const WIN := Color("3a4048")
const SNOW := Color("f4f7fa")
const SNOW_S := Color("c9d6e4")
const ROCK := Color("7f8798")
const TURQ := Color("2fb0bf")
const TURQ_L := Color("86dbd9")
const TURQ_D := Color("1d8c9e")
const COPPER := Color("5f9e86")
const RED := Color("c8282c")
const WHEAT := Color("e2c160")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"spirit_island": _spirit_island()
		"athabasca_glacier": _athabasca_glacier()
		"moraine_lake": _moraine_lake()
		"banff_springs_hotel": _banff_springs_hotel()
		"calgary_tower": _calgary_tower()
		"stampede_rodeo": _stampede_rodeo()
		"alberta_legislature": _alberta_legislature()
		"muttart_pyramids": _muttart_pyramids()
		"grain_elevator": _grain_elevator()
		"rcmp_mountie": _rcmp_mountie()
		"saskatchewan_legislature": _saskatchewan_legislature()
		"drumheller_dinosaur": _drumheller_dinosaur()
		"pysanka_egg": _pysanka_egg()
		"mac_the_moose": _mac_the_moose()
		"lake_louise": _lake_louise()
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

## Flat [x, y, ...] points turned by `a` radians around (0, 0), then moved to (ox, oy).
static func _rot(xy: Array, ox: float, oy: float, a: float) -> Array:
	var out := []
	for k in range(0, xy.size(), 2):
		var x: float = xy[k]
		var y: float = xy[k + 1]
		out.append_array([ox + x * cos(a) - y * sin(a), oy + x * sin(a) + y * cos(a)])
	return out

## A slim northern spruce: a short stem and a narrow, notched cone, `h` tall, shaded on its right.
static func _spruce(x: float, y: float, h: float, col: Color) -> void:
	_r(x - h * 0.03, y, x + h * 0.03, y + h * 0.12, WOOD)
	var right := []
	var left := []
	var n := 5
	for k in n:
		var t := float(k + 1) / n
		var yy := y + h - h * 0.9 * t
		var wd := h * 0.2 * t
		right.append_array([x + wd, yy])
		left = [x - wd, yy] + left
		if k < n - 1:
			right.append_array([x + wd * 0.45, yy - h * 0.02])
			left = [x - wd * 0.45, yy - h * 0.02] + left
	_poly([x, y + h] + right + left, col)
	_poly([x, y + h] + right + [x, y + h * 0.1], col.darkened(0.18))

## A mountain range: the ridge line [x, y, ...] filled down to the ground, each peak's right face in shadow.
static func _range(ridge: Array, col: Color) -> void:
	var pts := ridge.duplicate()
	pts.append_array([ridge[ridge.size() - 2], 0, ridge[0], 0])
	_poly(pts, col)
	for k in range(2, ridge.size() - 2, 2):
		var px: float = ridge[k]
		var py: float = ridge[k + 1]
		var nx: float = ridge[k + 2]
		var ny: float = ridge[k + 3]
		if py > ny and py > float(ridge[k - 1]):
			_poly([px, py, nx, ny, lerpf(px, nx, 0.6), ny - (py - ny) * 0.8, px + (nx - px) * 0.1, ny - (py - ny) * 0.5],
				col.darkened(0.15))

## A jagged snow cap on every summit of a ridge that rises above `line`.
static func _caps(ridge: Array, line: float) -> void:
	for k in range(2, ridge.size() - 2, 2):
		var px: float = ridge[k]
		var py: float = ridge[k + 1]
		var ly: float = ridge[k - 1]
		var ry: float = ridge[k + 3]
		if py <= line or py < ly or py < ry:
			continue
		var d := (py - line) * 0.6
		var tl := minf(d / maxf(py - ly, 0.01), 0.85)
		var tr := minf(d / maxf(py - ry, 0.01), 0.85)
		var lx := lerpf(px, ridge[k - 2], tl)
		var lyy := lerpf(py, ly, tl)
		var rx := lerpf(px, ridge[k + 2], tr)
		var ryy := lerpf(py, ry, tr)
		var mr := [lerpf(px, rx, 0.5), lerpf(py, ryy, 0.5) - d * 0.3]
		var mid := [px + (rx - px) * 0.1, py - d * 0.8]
		var ml := [lerpf(px, lx, 0.5), lerpf(py, lyy, 0.5) - d * 0.25]
		_poly([lx, lyy, px, py, rx, ryy] + mr + mid + ml, SNOW)
		_poly([px, py, rx, ryy] + mr + mid, SNOW_S)

## Still turquoise mountain-lake water from x0 to x1 up to `top`, with pale glints.
static func _lake(x0: float, x1: float, top: float) -> void:
	_r(x0, 0, x1, top, TURQ)
	_r(x0, top - 0.8, x1, top, TURQ_L)
	_r(x0, 0, x1, top * 0.3, TURQ_D)
	if _detail(1.0):
		var w := x1 - x0
		for p in [[0.1, 0.55], [0.35, 0.4], [0.6, 0.65], [0.8, 0.45], [0.25, 0.75], [0.7, 0.25]]:
			var gx: float = x0 + w * float(p[0])
			var gy: float = top * float(p[1])
			_r(gx, gy, gx + w * 0.07, gy + 0.25, TURQ_L)

## A red canoe on the water, (x, y) the middle of its waterline, with one paddler.
static func _canoe(x: float, y: float, s: float) -> void:
	_poly([x - 2.6 * s, y + 0.5 * s, x + 2.6 * s, y + 0.5 * s, x + 1.8 * s, y, x - 1.8 * s, y], RED)
	_c(x, y + 1.0 * s, 0.32 * s, Color("e8b890"))
	_r(x - 0.3 * s, y + 0.4 * s, x + 0.3 * s, y + 0.9 * s, Color("f2c230"))
	_l(x + 0.6 * s, y + 1.2 * s, x - 0.6 * s, y - 0.3 * s, WOOD, 0.12 * s)

## Strokes of one capital letter in a unit box (x right, y up), as polylines.
static func _letter(ch: String) -> Array:
	match ch:
		"S": return [[1, 0.85, 0.75, 1, 0.25, 1, 0, 0.8, 0, 0.62, 0.25, 0.5, 0.75, 0.5, 1, 0.38, 1, 0.15, 0.75, 0,
			0.25, 0, 0, 0.15]]
		"A": return [[0, 0, 0.5, 1, 1, 0], [0.22, 0.42, 0.78, 0.42]]
		"K": return [[0, 0, 0, 1], [1, 1, 0, 0.42], [0.35, 0.62, 1, 0]]
		"T": return [[0, 1, 1, 1], [0.5, 1, 0.5, 0]]
		"O": return [_arc(0.5, 0.5, 0.5, 0.5, 0, TAU, 14)]
		"N": return [[0, 0, 0, 1, 1, 0, 1, 1]]
	return []

## A word in stroke letters, each lw wide and lh tall, starting at (x, y), in `col`.
static func _word(word: String, x: float, y: float, lw: float, lh: float, gap: float, col: Color, w: float) -> void:
	for k in word.length():
		var lx := x + k * (lw + gap)
		for s in _letter(word[k]):
			var pts := []
			for j in range(0, s.size(), 2):
				pts.append_array([lx + float(s[j]) * lw, y + float(s[j + 1]) * lh])
			_pl(pts, col, w)

## A horse standing side-on facing right, `s` times a real horse; (x, y) is the ground under its middle.
static func _horse(x: float, y: float, s: float, col: Color) -> void:
	var hoof := Color("1a1a1a")
	# legs: far pair darker, then the near pair
	for p in [[-0.62, -0.5], [0.55, 0.7]]:
		_l(x + p[0] * s, y + 1.0 * s, x + p[1] * s, y + 0.06 * s, col.darkened(0.25), 0.15 * s)
	for p in [[-0.75, -0.8], [0.68, 0.62]]:
		_l(x + p[0] * s, y + 1.05 * s, x + p[1] * s, y + 0.06 * s, col, 0.17 * s)
	for hx in [-0.5, 0.7, -0.8, 0.62]:
		_r(x + (hx - 0.09) * s, y, x + (hx + 0.09) * s, y + 0.1 * s, hoof)
	# the tail
	_poly([x - 0.95 * s, y + 1.45 * s, x - 1.12 * s, y + 1.4 * s, x - 1.25 * s, y + 0.65 * s, x - 1.05 * s,
		y + 0.75 * s], col.darkened(0.3))
	# body, neck and head
	_ell(x, y + 1.22 * s, 1.0 * s, 0.4 * s, 0.0, col)
	_poly([x + 0.55 * s, y + 1.05 * s, x + 0.95 * s, y + 1.25 * s, x + 1.3 * s, y + 2.05 * s, x + 1.15 * s,
		y + 2.15 * s, x + 0.7 * s, y + 1.6 * s], col)
	_poly([x + 1.1 * s, y + 2.15 * s, x + 1.3 * s, y + 2.15 * s, x + 1.75 * s, y + 1.72 * s, x + 1.7 * s,
		y + 1.6 * s, x + 1.5 * s, y + 1.62 * s, x + 1.2 * s, y + 1.85 * s], col)
	_poly([x + 1.12 * s, y + 2.12 * s, x + 1.15 * s, y + 2.32 * s, x + 1.22 * s, y + 2.15 * s], col)
	# the mane
	_poly([x + 1.15 * s, y + 2.15 * s, x + 0.7 * s, y + 1.62 * s, x + 0.62 * s, y + 1.52 * s, x + 1.05 * s,
		y + 2.0 * s], col.darkened(0.3))
	if _detail(6.0):
		_c(x + 1.38 * s, y + 1.98 * s, 0.035 * s, Color("dddddd"))

## Spirit Island in Maligne Lake: a tiny islet of a few spruces in still turquoise water, the forested shores
## closing in from both sides and snowy peaks behind.
static func _spirit_island() -> void:
	var ridge := [-30, 14, -25, 23, -19, 29, -14, 25, -8, 32, -3, 28, 3, 34, 8, 27, 14, 31, 20, 24, 25, 26, 30, 18]
	_range(ridge, ROCK)
	_caps(ridge, 22)
	# the forested slopes coming down to the water from both sides
	_poly([-30, 8, -30, 20, -22, 17, -14, 13, -6, 10.5, 2, 9], FOREST)
	_poly([30, 8, 30, 17, 22, 15, 14, 12, 6, 10.2, -2, 9], FOREST.darkened(0.1))
	if _detail(1.2):
		for k in 12:
			var x := -29.0 + k * 2.4
			var h := 2.6 + (k % 3) * 0.6
			_spruce(x, 18.6 - k * 0.8, h, FOREST.lightened(0.08))
		for k in 10:
			var x := 29.0 - k * 2.4
			_spruce(x, 15.8 - k * 0.6, 2.4 + (k % 2) * 0.7, FOREST.lightened(0.04))
	_lake(-30, 30, 9.5)
	# the island: a low rocky bank of moss with its handful of spruces, and its reflection
	_ell(6, 4.4, 4.6, 0.9, 0.0, TURQ_D)
	if _detail(1.0):
		for k in 4:
			_poly([3.4 + k * 1.4, 4.5, 4.4 + k * 1.4, 4.5, 3.9 + k * 1.4, 1.2 + (k % 2) * 0.8], TURQ_D.darkened(0.1))
	_ell(6, 5.0, 4.2, 0.8, 0.0, Color("7a7466"))
	_ell(6, 5.4, 3.8, 0.55, 0.0, Color("5f8a46"))
	var hs := [5.0, 7.5, 6.2, 8.4, 5.6, 4.2]
	for k in hs.size():
		_spruce(3.2 + k * 1.15, 5.3, hs[k], PINE)
	# a red canoe gliding past
	_canoe(-12, 2.6, 1.0)

## The snow coach (an Ice Explorer): a tall red-and-white bus on six huge tyres; (x, y) is under its middle.
static func _ice_explorer(x: float, y: float) -> void:
	var red := Color("c8302c")
	for wx in [-3.4, 0.2, 3.4]:
		_c(x + wx, y + 1.0, 1.0, DARK)
		_c(x + wx, y + 1.0, 0.45, Color("9a9a9a"))
	_r(x - 4.8, y + 1.1, x + 4.8, y + 1.7, DARK)
	_r(x - 5, y + 1.7, x + 4.4, y + 3.8, red)
	_poly([x + 4.4, y + 1.7, x + 5.3, y + 1.7, x + 5.3, y + 2.8, x + 4.7, y + 3.8, x + 4.4, y + 3.8], red)
	_r(x - 5, y + 3.8, x + 4.7, y + 4.3, WHITE)
	_r(x - 4.7, y + 2.65, x + 4.3, y + 3.55, Color("33495e"))
	_poly([x + 4.45, y + 2.65, x + 5.0, y + 2.75, x + 4.65, y + 3.55, x + 4.45, y + 3.55], Color("6f8fa8"))
	_r(x - 5, y + 2.0, x + 5.3, y + 2.25, WHITE)
	if _detail(1.5):
		for k in 7:
			var wx := x - 3.4 + k * 1.15
			_r(wx, y + 2.65, wx + 0.15, y + 3.55, WHITE)

## The Athabasca Glacier: a wide tongue of cracked blue-white ice flowing down from the Columbia Icefield
## between two snowy peaks, grey moraines along its sides, and the big red snow coach out on the ice.
static func _athabasca_glacier() -> void:
	var ridge := [-40, 16, -34, 26, -28, 36, -22, 41, -16, 35, -10, 31, -4, 29, 4, 30, 10, 33, 16, 38, 21, 42, 27, 35,
		33, 28, 40, 21]
	_range(ridge, Color("6f7484"))
	_caps(ridge, 25)
	# the icefield in the saddle
	_poly([-14, 32.5, -10, 31, -4, 29, 4, 30, 10, 33, 14, 35, 12, 25, -12, 25], SNOW)
	# the lateral moraines along both sides of the tongue
	var mor := Color("8a8478")
	_poly([-12, 26, -10, 21, -8.5, 16, -7.5, 10, -6.5, 6, -4, 3.5, -8, 3.5, -10, 6, -11, 10, -12.5, 16, -14, 21,
		-15.5, 26], mor)
	_poly([12, 26, 11, 20, 11.5, 14, 11, 9, 9.5, 6, 6, 3.5, 11, 3.5, 13, 8, 14, 14, 14, 20, 15.5, 26], mor.darkened(0.08))
	# the ice tongue, ending in a rounded snout
	var ice := Color("eaf3f8")
	var ice_s := Color("b9d5e8")
	var tongue := [-12, 26, 12, 26, 11, 20, 11.5, 14, 11, 9, 9.5, 6, 6, 4.2, 1, 3.8, -4, 4.2, -6.5, 6, -7.5, 10,
		-8.5, 16, -10, 21]
	_poly(tongue, ice)
	_poly([3, 26, 12, 26, 11, 20, 11.5, 14, 11, 9, 9.5, 6, 6, 4.2, 3, 3.9, 4.5, 10, 4, 18], ice_s)
	if _detail(0.7):
		var crev := Color("7fa6c4")
		for k in 5:
			var y := 7.0 + k * 3.8
			var hw := 7.5 + k * 0.7
			_pl(_arc(1.5, y + 3.0, hw, 2.6, PI * 1.15, PI * 1.85, 10), crev, 0.22)
	# the gravel flats, the meltwater pool and the road in front
	_r(-40, 0, 40, 3.6, Color("a39a88"))
	_ell(1, 2.6, 6, 0.8, 0.0, TURQ)
	_r(-40, 0, 40, 1.0, Color("55524e"))
	if _detail(1.0):
		for k in 10:
			_r(-38 + k * 8, 0.45, -35 + k * 8, 0.55, Color("e8d26a"))
	# the snow coach out on the ice
	_ice_explorer(0.5, 6.0)

## Moraine Lake: still turquoise water under the jagged wall of the Ten Peaks, scree cones at their feet, the
## rockpile with its spruces on the left and a jam of bleached logs at the outlet on the right.
static func _moraine_lake() -> void:
	var hs := [30.0, 36.0, 33.0, 39.0, 34.0, 37.0, 32.0, 38.0, 33.0, 29.0]
	var ridge := [-40, 18]
	for k in 10:
		var px := -34.5 + k * 7.6
		ridge.append_array([px, hs[k]])
		if k < 9:
			ridge.append_array([px + 3.6, minf(hs[k], hs[k + 1]) - 6.0 - (k % 2) * 1.5])
	ridge.append_array([40, 18])
	var rock := Color("857c78")
	_range(ridge, rock)
	_caps(ridge, 27)
	if _detail(0.9):
		# snow lying in a few gullies
		for p in [[-25.5, 30, -24, 25], [-11, 33, -9.5, 27], [6, 31, 7.2, 26], [19.5, 32, 21, 27.5]]:
			_l(p[0], p[1], p[2], p[3], SNOW_S, 0.45)
	# grey scree cones at the foot of the wall
	var scree := Color("a8a096")
	for x in [-26.0, -10.0, 6.0, 22.0]:
		_poly([x - 6, 10, x + 6, 10, x + 1, 18.5, x - 1, 18.5], scree)
	# dark spruce forest along the shores
	_poly([-40, 9, -40, 17, -30, 14, -20, 11, -10, 10, 0, 9.6, 20, 11, 30, 13, 40, 15, 40, 9], FOREST)
	if _detail(1.2):
		for k in 16:
			var x := -39.0 + k * 5.2
			_spruce(x, 9.6, 3.4 + (k % 3) * 1.0, FOREST.lightened(0.06))
	_lake(-40, 40, 10)
	# the rockpile: a heap of grey boulders with spruces on top
	var boul := Color("8f8a80")
	_poly([-40, 0, -40, 13.5, -34, 14.5, -28, 11, -23, 6, -19, 0], boul)
	if _detail(0.8):
		for p in [[-37, 3, 1.6], [-33, 5, 1.4], [-29, 3, 1.3], [-24, 2, 1.2], [-35, 9, 1.5], [-30, 8, 1.2],
				[-26, 5.5, 1.0], [-38, 11.5, 1.2]]:
			_c(p[0], p[1], p[2], boul.darkened(0.12))
			_c(float(p[0]) - 0.3, float(p[1]) + 0.25, float(p[2]) * 0.8, boul.lightened(0.1))
	for p in [[-37, 13.5, 6.5], [-34.5, 14.0, 8.0], [-31.5, 12.2, 5.5], [-29, 10.5, 4.5]]:
		_spruce(p[0], p[1], p[2], PINE)
	# the log jam at the outlet
	var log := Color("c8b89a")
	for p in [[21, 1.2, 37, 2.4], [23, 2.6, 38, 1.0], [20, 2.0, 32, 3.6], [26, 3.2, 39, 3.0], [24, 0.8, 35, 0.5]]:
		_l(p[0], p[1], p[2], p[3], log.darkened(0.25), 0.9)
		_l(p[0], float(p[1]) + 0.15, p[2], float(p[3]) + 0.15, log, 0.6)
	_canoe(-6, 3.0, 1.0)

## The Banff Springs Hotel: a Scottish-baronial stone castle of many storeys, with steep copper roofs, dormers
## and round turrets, among dark pines with a grey mountain behind.
static func _banff_springs_hotel() -> void:
	var mtn := [-35, 14, -26, 24, -16, 34, -10, 41, -5, 38, 4, 33, 14, 30, 24, 26, 35, 20]
	_range(mtn, Color("8a93a3"))
	_caps(mtn, 34)
	_poly([-35, 0, -35, 16, -24, 13, -12, 15, 0, 12, 14, 14, 26, 12, 35, 15, 35, 0], FOREST)
	var st := Color("c4b08c")
	var sd := st.darkened(0.15)
	var roof := COPPER
	var rd := roof.darkened(0.2)
	# the wings: lower blocks either side, each with its hip roof
	for side in [-1.0, 1.0]:
		var x0: float = 6.0 * side
		var x1: float = 23.0 * side
		_r(minf(x0, x1), 2, maxf(x0, x1), 18, st if side < 0 else sd)
		_poly([minf(x0, x1) - 0.6, 18, maxf(x0, x1) + 0.6, 18, maxf(x0, x1) - 2, 23, minf(x0, x1) + 2, 23], roof)
		if _detail(0.9):
			for k in 5:
				_windows(minf(x0, x1) + 0.5, maxf(x0, x1) - 0.5, 4 + k * 2.8, 5.6 + k * 2.8, 6, WIN)
			for k in 3:
				var dx := minf(x0, x1) + 3.5 + k * 5.0
				_poly([dx - 1, 19.5, dx + 1, 19.5, dx, 21.5], st)
		# the round turret at the end of the wing
		var tx: float = 23.5 * side
		_r(tx - 2.4, 2, tx + 2.4, 21, st.lightened(0.05) if side < 0 else st)
		_poly([tx - 2.9, 21, tx + 2.9, 21, tx, 28], rd)
		_l(tx, 28, tx, 29.5, DARK, 0.15)
		if _detail(0.9):
			for k in 5:
				_r(tx - 0.5, 4 + k * 3.4, tx + 0.5, 5.6 + k * 3.4, WIN)
	# the central tower block
	_r(-7, 2, 7, 31, st)
	_r(2, 2, 7, 31, sd)
	_poly([-7.8, 31, 7.8, 31, 5, 37.5, -5, 37.5], roof)
	_poly([2, 31, 7.8, 31, 5, 37.5, 2, 37.5], rd)
	_r(-5, 37.5, 5, 38.2, rd)
	for x in [-4.0, 4.0]:
		_r(x - 0.5, 36, x + 0.5, 40, sd)
	if _detail(0.9):
		for k in 9:
			_windows(-6.5, 6.5, 4 + k * 3.0, 5.8 + k * 3.0, 5, WIN)
		for x in [-4.0, 0.0, 4.0]:
			_poly([x - 1, 32.5, x + 1, 32.5, x + 1, 34.2, x, 35.4, x - 1, 34.2], st)
			_r(x - 0.4, 32.8, x + 0.4, 34, WIN)
	# small corner turrets on the tower
	for x in [-7.0, 7.0]:
		_r(x - 1.1, 26, x + 1.1, 32, st.darkened(0.05))
		_poly([x - 1.4, 32, x + 1.4, 32, x, 35.5], rd)
	# the entrance arch
	_poly([1.8, 2] + _arc(0, 5, 1.8, 1.8, 0, PI, 8) + [-1.8, 2], Color("4a3a2a"))
	# pines in front
	for p in [[-33, 2, 9.0], [-29, 0.5, 11.0], [-25.5, 0.5, 7.5], [-14, 0.2, 6.5], [-10, 0.2, 5.0], [11, 0.2, 5.5],
			[15, 0.2, 7.0], [27, 0.5, 9.5], [31, 1.0, 11.5], [34, 2, 8.0]]:
		_spruce(p[0], p[1], p[2], PINE)

## The Calgary Tower: a slim, slightly tapering concrete shaft topped by its round pod, a ring of dark
## windows under the red cap and the torch on top, with a few downtown blocks at its foot.
static func _calgary_tower() -> void:
	# downtown blocks at the foot
	_r(-12, 0, -7, 14, Color("8da0b4"))
	_windows(-11.5, -7.5, 2, 12, 3, Color("c8d6e2"))
	_r(-9, 0, -4, 9, Color("b7a58a"))
	_r(6, 0, 12, 17, Color("6f8399"))
	_windows(6.5, 11.5, 2, 15, 4, Color("aac2d6"))
	_r(4, 0, 8, 7, Color("c9bfae"))
	# the shaft: two tapering halves, the lit side and the shadow side
	var con := Color("d9d4ca")
	var top := 48.0
	_poly([-2.6, 0, 0, 0, 0, top, -1.9, top], con)
	_poly([0, 0, 2.6, 0, 1.9, top, 0, top], con.darkened(0.18))
	if _detail(1.0):
		for k in 6:
			var y := 6.0 + k * 7.0
			_r(-0.3, y, 0.3, y + 3.5, WIN)
	# the pod: a flared skirt, the dark window band, the red cap and the torch
	_poly([-1.9, top, 1.9, top, 5.6, top + 3.2, -5.6, top + 3.2], Color("8c8478"))
	_r(-5.8, top + 3.2, 5.8, top + 6.2, Color("2f3a44"))
	if _detail(1.0):
		for k in 9:
			var x := -5.2 + k * 1.3
			_l(x, top + 3.3, x, top + 6.1, Color("8c8478"), 0.15)
	_r(-6.0, top + 6.2, 6.0, top + 6.8, Color("8c8478"))
	_poly([-6.0, top + 6.8, 6.0, top + 6.8, 5.0, top + 9.2, -5.0, top + 9.2], RED)
	_poly([0, top + 6.8, 6.0, top + 6.8, 5.0, top + 9.2, 0, top + 9.2], RED.darkened(0.15))
	_poly([-2.6, top + 9.2, 2.6, top + 9.2, 1.4, top + 10.4, -1.4, top + 10.4], Color("b8b2a6"))
	_r(-0.35, top + 10.4, 0.35, top + 15, Color("b8b2a6"))
	_poly([-0.9, top + 15, 0.9, top + 15, 0.5, top + 16, -0.5, top + 16], Color("6b6b6b"))
	_poly([-0.4, top + 16, 0.4, top + 16, 0, top + 17.6], Color("f2a03a"))

## A cowboy on a bucking bronco at the Calgary Stampede: the horse with its hind legs kicked high and its head
## down, the rider leaning back with one arm flung up and his hat, the arena fence and the crowd behind.
static func _stampede_rodeo() -> void:
	# the grandstand crowd and the white arena fence
	_r(-10, 3, 10, 7.5, Color("8a6a4a"))
	if _detail(3.0):
		var cols := [Color("d23b33"), Color("f2c230"), Color("2f6fa6"), Color("f4f2ea"), Color("49a85a")]
		for k in 26:
			_c(-9.5 + k * 0.75, 4.2 + (k % 3) * 1.1, 0.32, cols[k % cols.size()])
	_r(-10, 0, 10, 3, Color("b48a5c"))
	for x in [-9.5, -5.0, 5.0, 9.5]:
		_r(x - 0.15, 0.8, x + 0.15, 3.6, WHITE)
	_r(-10, 2.4, 10, 2.7, WHITE)
	_r(-10, 3.3, 10, 3.6, WHITE)
	# the bronco: tilted body, front legs braced on the ground, hind legs kicked out
	var brown := Color("7a4a2a")
	var a := 0.42
	var bx := 0.0
	var by := 5.6
	_l(1.8, 6.8, 4.0, 5.2, brown.darkened(0.2), 0.45)
	_l(4.0, 5.2, 5.4, 5.8, brown.darkened(0.2), 0.4)
	_l(2.4, 6.4, 4.4, 6.5, brown, 0.5)
	_l(4.4, 6.5, 5.8, 7.4, brown, 0.45)
	_r(5.3, 5.4, 5.8, 6.0, DARK)
	_r(5.6, 7.1, 6.1, 7.7, DARK)
	_l(-2.0, 4.6, -2.6, 1.1, brown.darkened(0.2), 0.45)
	_l(-1.4, 4.4, -1.6, 1.1, brown, 0.5)
	_r(-2.9, 0.8, -2.3, 1.2, DARK)
	_r(-1.9, 0.8, -1.3, 1.2, DARK)
	# the tail flying up
	_poly([2.5, 7.3, 3.1, 6.9, 4.3, 7.5, 5.4, 8.9, 4.7, 9.0, 3.7, 8.3], brown.darkened(0.35))
	_poly(_rot(_arc(0, 0, 3.0, 1.35, 0, TAU, 20), bx, by, a), brown)
	# the neck and the head thrust down to the ground
	_poly([-1.2, 6.8, -1.6, 5.0, -3.4, 3.6, -4.3, 4.7, -2.6, 6.9], brown)
	_poly([-3.5, 4.7, -4.4, 5.0, -5.3, 3.4, -5.1, 2.3, -4.5, 2.2, -3.4, 3.6], brown)
	_poly([-5.3, 3.0, -5.1, 2.3, -4.5, 2.2, -4.6, 2.9], brown.darkened(0.3))
	_l(-2.2, 7.0, -4.0, 5.0, DARK, 0.35)
	_poly([-3.8, 4.8, -3.7, 5.5, -3.4, 4.8], brown)
	if _detail(3.0):
		_c(-4.4, 3.9, 0.12, DARK)
	# the rider: boots in the stirrups, jeans, red shirt, leaning back
	var shirt := Color("c8302c")
	var jeans := Color("3b5a8a")
	var skin := Color("e8b890")
	var hat := Color("e9dcc0")
	_pl([0.2, 7.3, -0.9, 6.3, -1.0, 5.2], jeans, 0.55)
	_r(-1.4, 4.8, -0.6, 5.3, Color("5a3a22"))
	_poly([-0.2, 7.0, 0.6, 7.0, 1.6, 9.6, 0.8, 9.9], shirt)
	_c(1.3, 10.4, 0.5, skin)
	# the hat
	_ell(1.3, 10.85, 0.95, 0.18, 0.15, hat)
	_poly([0.85, 10.85, 1.75, 11.0, 1.6, 11.6, 1.0, 11.5], hat)
	# one arm flung up, the other holding the rein
	_pl([1.4, 9.4, 2.5, 10.5, 3.1, 12.0], shirt, 0.35)
	_c(3.1, 12.1, 0.25, skin)
	_pl([0.9, 9.2, -0.4, 8.4, -1.2, 7.8], shirt, 0.35)
	_l(-1.2, 7.8, -4.6, 3.0, DARK, 0.06)

## The Alberta Legislature in Edmonton: a sandstone Beaux-Arts building with a columned portico, long wings
## and a tall dome on its drum, the reflecting pool with fountains in front.
static func _alberta_legislature() -> void:
	var st := Color("dcc89c")
	var sd := st.darkened(0.14)
	var lt := st.lightened(0.15)
	# the dome on its drum, behind the front
	_r(-6.5, 18, 6.5, 26, st)
	_r(1.5, 18, 6.5, 26, sd)
	if _detail(0.9):
		for k in 7:
			var x := -5.6 + k * 1.85
			_r(x, 19, x + 0.5, 25, sd if x < 1.5 else st.darkened(0.25))
	_r(-7.2, 26, 7.2, 27, lt)
	var dome := Color("c9b48a")
	_poly([-6.8, 27] + _arc(0, 27, 6.8, 7.5, PI, 0, 16) + [6.8, 27], dome)
	_poly([0, 27] + _arc(0, 27, 6.8, 7.5, PI * 0.5, 0, 8) + [6.8, 27], dome.darkened(0.15))
	if _detail(0.9):
		for f in [-0.7, -0.38, 0.0, 0.38, 0.7]:
			var rib := []
			for j in 7:
				var th := PI * 0.5 * j / 6.0
				rib.append_array([6.8 * float(f) * cos(th), 27 + 7.4 * sin(th)])
			_pl(rib, dome.darkened(0.22), 0.2)
	# the lantern
	_r(-1.4, 34, 1.4, 37, lt)
	_poly([-1.7, 37, 1.7, 37, 0, 39], dome.darkened(0.1))
	_l(0, 39, 0, 41, DARK, 0.12)
	# the wings
	_r(-27, 2.5, 27, 16, st)
	_r(-27, 16, 27, 17.2, lt)
	_r(-27, 2.5, 27, 3.2, sd)
	if _detail(0.8):
		for k in 3:
			_windows(-26, -10, 5 + k * 3.8, 7 + k * 3.8, 8, WIN)
			_windows(10, 26, 5 + k * 3.8, 7 + k * 3.8, 8, WIN)
	# the central block and its portico
	_r(-10, 2.5, 10, 19, st)
	_r(-10.5, 19, 10.5, 20, lt)
	_poly([-9.5, 17.6, 9.5, 17.6, 0, 21.5], lt)
	_poly([-7.5, 18.1, 7.5, 18.1, 0, 20.8], sd)
	_r(-9.5, 16.4, 9.5, 17.6, lt)
	_r(-9, 3.2, 9, 16.4, sd.darkened(0.2))
	for k in 8:
		var x := -8.4 + k * 2.4
		_r(x - 0.55, 3.2, x + 0.55, 16.4, lt)
	_r(-10, 2.5, 10, 3.2, lt)
	# steps, the lawn, the pool and its fountains
	_r(-12, 1.8, 12, 2.5, Color("cfc4ac"))
	_r(-30, 0, 30, 1.8, GRASS)
	_r(-14, 0.2, 14, 1.4, Color("5fa0c8"))
	for x in [-9.0, -3.0, 3.0, 9.0]:
		_poly([x - 0.3, 1.2, x + 0.3, 1.2, x, 4.2], Color(1, 1, 1, 0.8))
	# the flag on the dome is too small; a flag on a pole on the lawn instead
	_l(-22, 1.8, -22, 9.5, DARK, 0.12)
	_r(-22, 7.4, -18.8, 9.4, Color("1f4aa0"))

## The Muttart Conservatory in Edmonton: four glass pyramids, two big and two small, with their diamond
## lattice of glazing bars, in the river-valley park under the downtown towers.
static func _muttart_pyramids() -> void:
	# downtown behind
	for p in [[-20, 3, 13, "8a9db0"], [-15, 3, 18, "9fb0c0"], [-9, 4, 15, "7d8fa3"], [-3, 3, 21, "b3c0cc"],
			[3, 4, 17, "8a9db0"], [9, 3, 23, "6f8399"], [14, 4, 16, "a3b3c2"], [19, 3, 12, "8a9db0"]]:
		var x: float = p[0]
		var w: float = p[1]
		var h: float = p[2]
		_r(x, 4, x + w, h, Color(p[3]))
		if _detail(1.5):
			for k in int(h / 3.0) - 1:
				_windows(x + 0.3, x + w - 0.3, 5 + k * 3, 6.2 + k * 3, 2, Color("d8e2ea"))
	# the river-valley park
	_poly([-25, 0, -25, 7, -12, 5.5, 0, 6.5, 12, 5, 25, 6.5, 25, 0], Color("5f8a46"))
	_r(-25, 0, 25, 1.2, GRASS)
	# the pyramids, back pair first
	for p in [[-14, 11.0, 18.0], [8, 10.5, 19.0], [-22, 6.0, 11.0], [19, 6.0, 11.5]]:
		var cx: float = p[0]
		var hw: float = p[1]
		var h: float = p[2]
		var glass := Color("9cc0d4")
		var y0 := 1.2
		_poly([cx - hw, y0, cx, y0, cx, y0 + h], glass.lightened(0.12))
		_poly([cx, y0, cx + hw, y0, cx, y0 + h], glass.darkened(0.12))
		if _detail(0.9):
			var bar := Color("e8eef2")
			for k in range(1, 6):
				var t := float(k) / 6.0
				var yy := y0 + h * t
				var ww := hw * (1.0 - t)
				_l(cx - ww, yy, cx + ww, yy, bar, 0.1)
			for k in range(1, 6):
				var t := float(k) / 6.0
				_l(cx - hw + 2.0 * hw * t, y0, cx, y0 + h, bar, 0.08)
		_l(cx, y0, cx, y0 + h, Color("e8eef2"), 0.15)
		_pl([cx - hw, y0, cx, y0 + h, cx + hw, y0], Color("dfe6ea"), 0.2)

## A prairie grain elevator by Saskatoon: the tall red wooden bin house with its headhouse on top and the town's
## name in big white letters, the driveway shed, the railway siding with a grain car, and wheat fields.
static func _grain_elevator() -> void:
	# wheat to the horizon
	_r(-15, 0, 15, 3.2, WHEAT)
	_r(-15, 3.0, 15, 3.4, WHEAT.darkened(0.1))
	if _detail(1.5):
		for k in 30:
			var x := -14.6 + k * 1.0
			_l(x, 2.2, x + 0.15, 3.0, WHEAT.darkened(0.2), 0.1)
	var red := Color("b02a24")
	var rd := red.darkened(0.2)
	# the driveway shed on the left and the annex on the right
	_r(-9, 3, -4, 9, rd)
	_poly([-9.4, 9, -4, 9, -4, 11, -6.7, 11.5], Color("6b6b6b"))
	_r(-8.4, 3, -5.0, 7, Color("4a2a20"))
	_r(4, 3, 7.5, 13, rd)
	_poly([4, 13, 7.9, 13, 4, 15.5], Color("6b6b6b"))
	# the bin house and the headhouse
	_r(-4, 3, 4, 21, red)
	_r(2.2, 3, 4, 21, rd)
	_poly([-4.4, 21, 4.4, 21, 3.4, 22.2, -3.4, 22.2], Color("6b6b6b"))
	_r(-2.4, 22.2, 2.4, 25.2, red)
	_r(1.2, 22.2, 2.4, 25.2, rd)
	_poly([-2.9, 25.2, 2.9, 25.2, 0, 27.2], Color("6b6b6b"))
	_r(-0.8, 23.2, 0.4, 24.4, WHITE)
	if _detail(0.9):
		for k in 6:
			var y := 4.5 + k * 2.5
			_l(-4, y, 4, y, rd, 0.06)
		# the town's name across the top
		_word("SASKATOON", -3.7, 17.5, 0.62, 1.6, 0.18, WHITE, 0.16)
	else:
		_r(-3.6, 17.5, 3.6, 19.1, WHITE)
	_r(-4, 20.2, 4, 20.5, WHITE)
	# the railway siding with a hopper car
	_r(-15, 0, 15, 1.4, Color("8a7a66"))
	if _detail(1.0):
		for k in 20:
			var x := -14.6 + k * 1.5
			_r(x, 0.3, x + 0.6, 0.9, WOOD)
	_r(-15, 0.9, 15, 1.1, Color("5a5a5a"))
	var car := Color("8a6a3e")
	_poly([7, 1.6, 14.5, 1.6, 14.5, 5.0, 7, 5.0], car)
	_poly([7, 1.6, 9.0, 1.6, 8.0, 1.2], car.darkened(0.2))
	_poly([12.5, 1.6, 14.5, 1.6, 13.5, 1.2], car.darkened(0.2))
	for wx in [7.8, 8.9, 12.6, 13.7]:
		_c(wx, 1.35, 0.35, DARK)
	if _detail(1.5):
		for k in 6:
			_l(7.4 + k * 1.3, 1.8, 7.4 + k * 1.3, 4.8, car.darkened(0.15), 0.08)

## A Mountie of the RCMP in the red serge coat, dark breeches with the yellow stripe, tall brown boots and the
## brown flat-brimmed Stetson, on a black horse, carrying a lance with its red-and-white pennon.
static func _rcmp_mountie() -> void:
	_r(-2.4, 0, 2.4, 0.15, GRASS.darkened(0.1))
	var horse := Color("1e1c1c")
	_horse(-0.2, 0.05, 1.0, horse)
	# saddle cloth
	_poly([-0.55, 1.55, 0.35, 1.55, 0.3, 1.05, -0.5, 1.05], Color("1f3a7a"))
	_r(-0.55, 1.5, 0.35, 1.6, Color("e0b43a"))
	# rider: the leg with breeches and boot
	var serge := Color("c8202a")
	var navy := Color("1c2440")
	var boot := Color("5a3418")
	_poly([-0.25, 1.75, 0.15, 1.75, 0.2, 1.4, 0.05, 1.1, -0.15, 1.1, -0.1, 1.45], navy)
	_l(0.05, 1.7, 0.0, 1.2, Color("e0b43a"), 0.03)
	_poly([-0.15, 1.15, 0.07, 1.15, 0.1, 0.72, 0.2, 0.68, 0.2, 0.62, -0.12, 0.62], boot)
	# the red serge coat with its belt
	_poly([-0.3, 1.7, 0.22, 1.7, 0.2, 2.45, -0.22, 2.45], serge)
	_r(-0.3, 1.78, 0.22, 1.86, boot)
	if _detail(10.0):
		for k in 3:
			_c(-0.0, 1.95 + k * 0.15, 0.018, Color("e0b43a"))
	# the arm holding the lance
	_pl([0.15, 2.38, 0.38, 2.05, 0.5, 2.1], serge, 0.11)
	_c(0.52, 2.1, 0.05, Color("e8c8a0"))
	# the head and the brown Stetson with its flat brim and pinched crown
	_c(0.0, 2.6, 0.12, Color("e8c8a0"))
	var hat := Color("7a5428")
	_r(-0.3, 2.68, 0.3, 2.72, hat)
	_poly([-0.13, 2.72, 0.13, 2.72, 0.09, 2.92, 0.0, 2.85, -0.09, 2.92], hat)
	_r(-0.13, 2.72, 0.13, 2.76, hat.darkened(0.3))
	# the lance and its pennon
	_l(0.52, 1.2, 0.52, 4.0, Color("8a6a40"), 0.04)
	_poly([0.52, 3.95, 1.25, 3.85, 0.52, 3.75], RED)
	_poly([0.52, 3.75, 1.25, 3.85, 0.52, 3.55], WHITE)

## The Saskatchewan Legislature in Regina: a long cream Tyndall-stone building with a columned front and a
## copper-green dome on its drum, mirrored in Wascana Lake, with trees along the shore.
static func _saskatchewan_legislature() -> void:
	var st := Color("e6dbbd")
	var sd := st.darkened(0.14)
	var lt := st.lightened(0.15)
	var by := 7.5
	# the drum and dome
	_r(-5.5, by + 13, 5.5, by + 20, st)
	_r(1.5, by + 13, 5.5, by + 20, sd)
	if _detail(0.9):
		for k in 6:
			var x := -4.6 + k * 1.8
			_r(x, by + 14, x + 0.5, by + 19.5, st.darkened(0.3))
	_r(-6.2, by + 20, 6.2, by + 21, lt)
	_poly([-5.8, by + 21] + _arc(0, by + 21, 5.8, 6.5, PI, 0, 16) + [5.8, by + 21], COPPER)
	_poly([0, by + 21] + _arc(0, by + 21, 5.8, 6.5, PI * 0.5, 0, 8) + [5.8, by + 21], COPPER.darkened(0.18))
	_r(-1.2, by + 27.4, 1.2, by + 30, lt)
	_poly([-1.5, by + 30, 1.5, by + 30, 0, by + 32.2], COPPER)
	_l(0, by + 32.2, 0, by + 33.5, DARK, 0.12)
	# the long wings, end pavilions and centre block
	_r(-32, by, 32, by + 10, st)
	_r(-32, by + 10, 32, by + 11, lt)
	for x in [-32.0, 26.0]:
		_r(x, by, x + 6, by + 12, lt)
		_r(x - 0.3, by + 12, x + 6.3, by + 12.8, sd)
	_r(-9, by, 9, by + 13.5, st)
	_r(-9.5, by + 13.5, 9.5, by + 14.3, lt)
	_poly([-6, by + 11.5, 6, by + 11.5, 0, by + 14.0], sd)
	_r(-6, by + 1.2, 6, by + 11.5, sd.darkened(0.25))
	for k in 6:
		var x := -5.3 + k * 2.12
		_r(x - 0.45, by + 1.2, x + 0.45, by + 11.5, lt)
	if _detail(0.8):
		for k in 2:
			_windows(-25.5, -9.5, by + 2 + k * 4, by + 4 + k * 4, 7, WIN)
			_windows(9.5, 25.5, by + 2 + k * 4, by + 4 + k * 4, 7, WIN)
			_windows(-31.5, -26.5, by + 2 + k * 4.5, by + 4 + k * 4.5, 2, WIN)
			_windows(26.5, 31.5, by + 2 + k * 4.5, by + 4 + k * 4.5, 2, WIN)
	# the shore lawn with trees
	_r(-35, by - 1.5, 35, by, GRASS)
	for x in [-34.0, -21.0, -14.0, 14.0, 21.0, 34.0]:
		_r(x - 0.3, by - 0.5, x + 0.3, by + 2.5, WOOD)
		_c(x, by + 3.8, 2.0, Color("4f7d3a"))
		_c(x - 0.6, by + 4.3, 1.3, Color("5f8f46"))
	# Wascana Lake, with the building's reflection
	var lake := Color("4f8fc0")
	_r(-35, 0, 35, by - 1.5, lake)
	var refl := Color("8fb4cc")
	_r(-30, by - 4.5, 30, by - 1.5, refl)
	_poly([-5.5, by - 4.5, 5.5, by - 4.5, 4.0, 0.3, -4.0, 0.3], refl)
	_r(-30, by - 4.5, 30, by - 4.2, lake)
	if _detail(1.0):
		for p in [[-28, 1.0], [-14, 2.8], [10, 1.4], [22, 3.0]]:
			_r(p[0], p[1], p[0] + 5, p[1] + 0.25, Color("d6e8f2"))

## A tall sandstone hoodoo with its dark capstone; (x, y) is its foot.
static func _hoodoo(x: float, y: float, h: float, w: float) -> void:
	var tan := Color("d2b48a")
	_poly([x - w, y, x + w, y, x + w * 0.45, y + h * 0.6, x + w * 0.55, y + h, x - w * 0.55, y + h,
		x - w * 0.4, y + h * 0.6], tan)
	_poly([x, y, x + w, y, x + w * 0.45, y + h * 0.6, x + w * 0.55, y + h, x, y + h], tan.darkened(0.12))
	_ell(x, y + h + w * 0.25, w * 0.95, w * 0.35, 0.0, Color("6a5a4a"))

## Drumheller's giant T. rex: the huge green dinosaur standing tall with its jaws gaping (the lookout), tiny arms
## and its tail down on the ground, in the striped badlands with hoodoos.
static func _drumheller_dinosaur() -> void:
	# the badlands: banded hills of tan, grey and rust
	var bands := [Color("cdb48c"), Color("9a8f86"), Color("b87a52"), Color("d8c49c"), Color("8a7f78")]
	var hill := [-23, 0, -23, 14, -18, 17, -13, 15, -6, 19, 2, 16, 9, 18, 16, 15, 23, 17, 23, 0]
	_poly(hill, bands[0])
	if _detail(0.8):
		for k in 4:
			var y := 3.0 + k * 3.2
			_poly([-23, y, 23, y + 0.6, 23, y + 1.6, -23, y + 1.0], bands[k + 1])
	_r(-23, 0, 23, 2.5, Color("c9ae84"))
	_hoodoo(-19, 1.5, 7.0, 1.4)
	_hoodoo(-15.5, 1.5, 5.0, 1.1)
	_hoodoo(18.5, 1.5, 8.0, 1.5)
	# the dinosaur: tail, far leg, body, near leg, neck and head
	var g := Color("5f8a46")
	var gd := g.darkened(0.25)
	var belly := Color("b8c47a")
	_poly([5.5, 15.5, 10, 12.5, 14.5, 7.5, 18, 2.2, 15.8, 2.2, 11.5, 7.0, 6, 10.5], g)
	_poly([0.5, 9, 3.5, 9, 3.0, 3.5, 3.8, 1.8, 0.2, 1.8, 1.0, 4.0], gd)
	_ell(2.0, 13.5, 6.5, 4.6, -0.55, g)
	_ell(0.6, 11.8, 4.0, 2.0, -0.7, belly)
	# the neck and the open-jawed head
	_poly([-3.0, 18.0, -1.0, 21.5, -4.5, 24.5, -7.0, 21.5, -5.5, 16.5], g)
	_poly([-3.2, 25.0, -5.0, 26.6, -9.5, 26.0, -12.0, 24.3, -11.8, 23.2, -6.0, 22.6, -3.8, 22.0], g)
	_poly([-4.2, 21.6, -11.2, 21.0, -11.0, 20.0, -6.5, 19.6, -3.6, 20.2], g)
	_poly([-5.0, 22.4, -11.5, 22.8, -11.0, 21.2, -5.0, 21.4], Color("7a2a2a"))
	if _detail(0.8):
		for k in 5:
			var x := -10.8 + k * 1.3
			_poly([x, 22.9, x + 0.5, 22.9, x + 0.25, 22.2], WHITE)
			_poly([x + 0.3, 21.1, x + 0.8, 21.1, x + 0.55, 21.8], WHITE)
	_c(-6.5, 24.6, 0.45, Color("f2e06a"))
	_c(-6.4, 24.6, 0.2, DARK)
	# the tiny arms
	_pl([-3.2, 15.5, -4.6, 14.2, -5.0, 14.8], g, 0.55)
	# the near leg: a big thigh and a shin to the foot
	_ell(3.8, 9.5, 3.2, 4.2, -0.3, g)
	_poly([3.2, 7.0, 6.0, 7.2, 5.4, 3.0, 6.8, 1.8, 2.0, 1.8, 3.5, 3.4], g)
	_poly([2.0, 1.8, 6.8, 1.8, 7.4, 1.4, 1.4, 1.4], gd)
	if _detail(1.0):
		for k in 6:
			var t := float(k) / 5.0
			var sx := lerpf(-2.5, 8.0, t)
			var sy := lerpf(17.5, 14.5, t)
			_l(sx, sy, sx + 0.6, sy - 1.8, gd, 0.3)

## The Vegreville pysanka: the giant Ukrainian Easter egg of bronze, silver and gold tiles in stars and zigzags,
## leaning on its turntable pedestal in the park.
static func _pysanka_egg() -> void:
	_r(-7, 0, 7, 0.6, GRASS)
	# the pedestal and turntable
	_poly([-3.6, 0.6, 3.6, 0.6, 3.0, 1.6, -3.0, 1.6], Color("b9b4a8"))
	_r(-2.6, 1.6, 2.6, 2.0, Color("8a8478"))
	_r(-0.5, 2.0, 0.5, 3.2, Color("6b6b6b"))
	var a := -0.32
	var ox := 0.3
	var oy := 7.6
	var rx := 3.7
	var ry := 4.9
	# the egg as horizontal bands in its own frame (wider at the bottom)
	var cols := [Color("2a2a3a"), Color("c8902a"), Color("2a2a3a"), Color("d8d8d8"), Color("b0602a"), Color("d8d8d8"),
		Color("2a2a3a"), Color("c8902a"), Color("2a2a3a")]
	var n := cols.size()
	for b in n:
		var y0 := -ry + 2.0 * ry * b / n
		var y1 := -ry + 2.0 * ry * (b + 1) / n
		var right := []
		var left := []
		for j in 5:
			var y := lerpf(y0, y1, j / 4.0)
			var wd := _egg_w(y, rx, ry)
			right.append_array([wd, y])
			left = [-wd, y] + left
		_poly(_rot(right + left, ox, oy, a), cols[b])
	if _detail(0.9):
		var gold := Color("f2c84a")
		var silver := Color("eef0f2")
		# zigzag triangles on the dark bands
		for b in [2, 6]:
			var yc: float = -ry + 2.0 * ry * (b + 0.5) / n
			var hb := ry / n
			var wd := _egg_w(yc, rx, ry)
			var m := int(wd * 1.2) + 1
			for k in m:
				var x0 := -wd + 2.0 * wd * k / m
				var x1 := -wd + 2.0 * wd * (k + 1) / m
				_poly(_rot([x0, yc - hb * 0.7, x1, yc - hb * 0.7, (x0 + x1) * 0.5, yc + hb * 0.7], ox, oy, a),
					silver if b == 6 else gold)
		# eight-pointed stars on the bronze middle band, and dots on the gold bands
		for k in 3:
			var sx := -2.2 + k * 2.2
			var st := []
			for j in 16:
				var rr := 0.75 if j % 2 == 0 else 0.32
				var an := TAU * j / 16.0
				st.append_array([sx + cos(an) * rr, sin(an) * rr])
			_poly(_rot(st, ox, oy, a), gold)
			_poly(_rot(_arc(sx, 0, 0.22, 0.22, 0, TAU, 8), ox, oy, a), Color("2a2a3a"))
		for b in [1, 7]:
			var yc: float = -ry + 2.0 * ry * (b + 0.5) / n
			var wd := _egg_w(yc, rx, ry)
			var m := int(wd * 1.4) + 1
			for k in m:
				var p: Array = _rot([-wd + 2.0 * wd * (k + 0.5) / m, yc], ox, oy, a)
				_c(p[0], p[1], 0.18, Color("7a2a1a"))
	# a sheen on the upper left
	_poly(_rot(_arc(-1.9, 1.6, 0.45, 1.3, 0, TAU, 12), ox, oy, a), Color(1, 1, 1, 0.12))

## The egg's half-width at height y (from -ry to ry): an ellipse a little fuller at the bottom.
static func _egg_w(y: float, rx: float, ry: float) -> float:
	var t := clampf(y / ry, -1.0, 1.0)
	return rx * sqrt(maxf(0.0, 1.0 - t * t)) * (1.0 - 0.13 * t)

## Mac the Moose in Moose Jaw: the giant brown moose statue with its huge palmate antlers, droopy nose and
## bell, standing tall on its stone plinth.
static func _mac_the_moose() -> void:
	_r(-8, 0, 8, 0.4, GRASS)
	_r(-6.5, 0.4, 5.5, 1.4, Color("a8a296"))
	_r(-6.5, 1.4, 5.5, 1.6, Color("c8c2b4"))
	var fur := Color("5e3c22")
	var fd := fur.darkened(0.25)
	var leg := Color("8a7058")
	var y0 := 1.6
	# far legs, then the body, then the near legs
	_l(-2.4, y0 + 3.5, -2.2, y0, leg.darkened(0.2), 0.5)
	_pl([3.0, y0 + 3.5, 3.6, y0 + 1.8, 3.2, y0], leg.darkened(0.2), 0.5)
	_poly([-4.4, y0 + 3.2, -4.6, y0 + 5.2, -3.4, y0 + 6.8, -1.8, y0 + 6.3, 1.0, y0 + 5.9, 3.4, y0 + 5.8,
		4.4, y0 + 5.0, 4.2, y0 + 3.4, 2.8, y0 + 2.8, -1.0, y0 + 2.9, -3.4, y0 + 2.9], fur)
	_poly([-1.0, y0 + 2.9, 2.8, y0 + 2.8, 4.2, y0 + 3.4, 3.0, y0 + 3.6, -1.0, y0 + 3.4], fd)
	_l(-3.5, y0 + 3.4, -3.6, y0, leg, 0.6)
	_pl([2.3, y0 + 3.4, 2.7, y0 + 1.8, 2.3, y0], leg, 0.6)
	for hx in [-3.6, -2.2, 2.3, 3.2]:
		_r(hx - 0.35, y0, hx + 0.35, y0 + 0.35, DARK)
	# the short tail
	_poly([4.3, y0 + 5.2, 4.7, y0 + 4.9, 4.5, y0 + 4.3], fd)
	# the neck, the long droopy head and the bell
	_poly([-3.4, y0 + 4.0, -3.2, y0 + 6.8, -4.9, y0 + 7.15, -5.8, y0 + 5.2], fur)
	_poly([-4.9, y0 + 7.1, -5.8, y0 + 7.3, -7.4, y0 + 6.0, -7.7, y0 + 5.0, -7.1, y0 + 4.7, -6.0, y0 + 5.3,
		-4.9, y0 + 5.8], fur)
	_ell(-7.25, y0 + 5.3, 0.5, 0.55, 0.0, fur.darkened(0.12))
	_poly([-5.6, y0 + 5.4, -5.0, y0 + 5.5, -5.4, y0 + 4.0, -5.8, y0 + 4.3], fd)
	_c(-5.9, y0 + 6.4, 0.16, DARK)
	_poly([-4.8, y0 + 7.0, -4.2, y0 + 7.5, -4.6, y0 + 6.7], fd)
	# the palmate antlers, the far one behind first
	var ant := Color("d8c49a")
	_poly([-5.0, y0 + 7.1, -4.0, y0 + 8.0, -3.2, y0 + 9.6, -3.5, y0 + 10.1, -3.0, y0 + 10.0, -2.6, y0 + 9.5,
		-2.6, y0 + 10.2, -2.2, y0 + 9.6, -2.6, y0 + 8.4, -3.6, y0 + 7.3], ant.darkened(0.2))
	_poly([-5.4, y0 + 7.2, -6.6, y0 + 7.9, -7.8, y0 + 9.0, -8.4, y0 + 10.0, -8.0, y0 + 10.2, -7.7, y0 + 9.7,
		-7.4, y0 + 10.5, -7.0, y0 + 9.8, -6.6, y0 + 10.6, -6.2, y0 + 9.8, -5.8, y0 + 10.3, -5.6, y0 + 9.3,
		-4.9, y0 + 8.0], ant)

## Lake Louise: the turquoise lake between dark forested mountainsides, the Victoria Glacier hanging on the
## white peak at its far end, red canoes on the water and the long Fairmont Château on the near shore.
static func _lake_louise() -> void:
	var ridge := [-40, 26, -32, 32, -24, 30, -16, 36, -10, 38, -4, 37, 2, 42, 8, 40, 14, 38, 22, 33, 30, 36, 40, 30]
	_range(ridge, Color("8f97a6"))
	_caps(ridge, 34)
	# Mount Victoria at the end of the valley: a broad white wall of snow with dark rock bands
	_poly([-17, 18, -13, 28, -7, 33, -1, 36, 4, 40.5, 9, 37.5, 15, 34, 20, 27, 23, 18], SNOW)
	_poly([4, 40.5, 9, 37.5, 15, 34, 20, 27, 23, 18, 6, 18, 5, 30], SNOW_S)
	var band := Color("6f7380")
	_poly([-13, 27.5, -6, 29, 2, 30.5, 10, 30, 18, 28, 19, 26.5, 10, 28.3, 2, 28.8, -6, 27.5, -12.5, 26.2], band)
	_poly([-15, 22.5, -6, 23.5, 4, 24.5, 14, 23.5, 21, 22, 21.5, 20.5, 14, 22, 4, 22.8, -6, 22, -15, 21], band)
	if _detail(0.9):
		_pl([-9, 31.5, -2, 33, 5, 34.5, 12, 33], Color("9ab6cc"), 0.3)
	# the forested sides closing in like a V, and the valley floor between them
	_poly([-40, 8, -40, 28, -30, 24, -20, 19.5, -12, 15, -4, 11, 4, 10], FOREST)
	_poly([40, 8, 40, 26, 30, 22, 20, 18, 12, 14, 4, 11, -4, 10], FOREST.darkened(0.1))
	_poly([-17, 18, 23, 18, 12, 14, 4, 9.5, -4, 9.5, -12, 15], Color("34503a"))
	_poly([-15, 18, 21, 18, 16, 16.8, -11, 16.8], Color("8f8a84"))
	if _detail(1.2):
		for k in 9:
			_spruce(-38 + k * 3.6, 25.5 - k * 1.9, 3.6, FOREST.lightened(0.08))
			_spruce(38 - k * 3.6, 23.5 - k * 1.7, 3.6, FOREST.lightened(0.04))
	_lake(-40, 40, 10)
	# the reflection of the glacier
	_poly([-12, 9.2, 18, 9.2, 4, 2.0], Color(1, 1, 1, 0.3))
	_canoe(-18, 3.6, 1.0)
	_canoe(-9, 1.6, 1.0)
	# the Château on the near right shore
	var cream := Color("efe6d2")
	var roof := Color("4f6a68")
	_poly([16, 0, 40, 0, 40, 4, 16, 3], GRASS)
	_r(18, 3, 36, 13, cream)
	_r(24, 3, 30, 16, cream.lightened(0.04))
	_r(32, 3, 38, 11, cream.darkened(0.08))
	_poly([17.6, 13, 36.4, 13, 35.6, 14.6, 18.4, 14.6], roof)
	_poly([23.6, 16, 30.4, 16, 29.4, 18.2, 24.6, 18.2], roof)
	_poly([31.6, 11, 38.4, 11, 37.4, 12.8, 32.6, 12.8], roof)
	if _detail(0.9):
		for k in 4:
			_windows(18.5, 23.6, 4 + k * 2.3, 5.2 + k * 2.3, 4, WIN)
			_windows(30.4, 35.8, 4 + k * 2.3, 5.2 + k * 2.3, 4, WIN)
			_windows(24.4, 29.6, 4 + k * 2.8, 5.4 + k * 2.8, 4, WIN)
	for p in [[-37, 0, 9.0], [-33.5, 0, 7.0], [14.5, 1.0, 7.5], [38.5, 2.0, 9.0]]:
		_spruce(p[0], p[1], p[2], PINE)
