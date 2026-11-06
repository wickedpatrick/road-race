class_name LandmarksUsT2
extends RefCounted
## American town landmarks (2): the northern and southern Plains, Navajo Nation and the Umatilla Reservation,
## drawn with LandmarkPainter's helpers (metres from the base point, y up).

const WHITE := Color("f4f2ea")
const WATER := Color("3f7fb5")
const WATER_L := Color("9cc8e6")
const GRASS := Color("6f9a48")
const PRAIRIE := Color("c9b56a")
const PINE := Color("2f5a36")
const WOOD := Color("7a5634")
const DARK := Color("2e3238")
const WIN := Color("3a4048")
const SKY := Color("9fc6e6")
const RED := Color("c8282c")
const YELLOW := Color("f2c230")
const FOAM := Color(1, 1, 1, 0.85)

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"sioux_falls": _sioux_falls()
		"corn_palace": _corn_palace()
		"wall_drug_badlands": _wall_drug_badlands()
		"sturgis_motorcycles": _sturgis_motorcycles()
		"devils_tower": _devils_tower()
		"crow_fair_teepees": _crow_fair_teepees()
		"van_gogh_sunflowers": _van_gogh_sunflowers()
		"keeper_of_the_plains": _keeper_of_the_plains()
		"first_americans_museum": _first_americans_museum()
		"navajo_hogan": _navajo_hogan()
		"pendleton_umatilla": _pendleton_umatilla()
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

## A dark evergreen: a brown stem and three stacked triangles, `h` tall.
static func _fir(x: float, y: float, h: float, col: Color) -> void:
	_r(x - h * 0.04, y, x + h * 0.04, y + h * 0.2, WOOD)
	for k in 3:
		var y0 := y + h * (0.15 + k * 0.25)
		var w := h * (0.3 - k * 0.07)
		_poly([x - w, y0, x + w, y0, x, y0 + h * 0.4], col)
		_poly([x - w, y0, x, y0, x, y0 + h * 0.4], col.lightened(0.1))

## Strokes of one capital letter in a unit box (x right, y up), as polylines.
static func _letter(ch: String) -> Array:
	match ch:
		"W": return [[0, 1, 0.25, 0, 0.5, 0.65, 0.75, 0, 1, 1]]
		"A": return [[0, 0, 0.5, 1, 1, 0], [0.22, 0.42, 0.78, 0.42]]
		"L": return [[0, 1, 0, 0, 0.9, 0]]
		"D": return [[0, 0, 0, 1, 0.35, 1] + _arc(0.35, 0.5, 0.6, 0.5, PI * 0.5, -PI * 0.5, 8) + [0, 0]]
		"R": return [[0, 0, 0, 1, 0.55, 1] + _arc(0.55, 0.75, 0.4, 0.25, PI * 0.5, -PI * 0.5, 6) + [0, 0.5],
			[0.45, 0.5, 1, 0]]
		"U": return [[0, 1, 0, 0.4] + _arc(0.5, 0.4, 0.5, 0.4, PI, TAU, 8) + [1, 1]]
		"G": return [_arc(0.5, 0.5, 0.5, 0.5, PI * 0.3, TAU, 12) + [0.5, 0.5]]
	return []

## A word of stroke letters, `lh` tall, starting at (x, y); `lw` is the letter width.
static func _word(word: String, x: float, y: float, lw: float, lh: float, gap: float, col: Color, w: float) -> void:
	for k in word.length():
		var x0 := x + k * (lw + gap)
		for s in _letter(word[k]):
			var pts := []
			for j in range(0, s.size(), 2):
				pts.append_array([x0 + s[j] * lw, y + s[j + 1] * lh])
			_pl(pts, col, w)

## A horse in profile facing left, standing at (x, y); `s` scales it (1 = about 1.6 m at the withers).
static func _horse(x: float, y: float, s: float, col: Color, mane: Color) -> void:
	var leg := col.darkened(0.2)
	for p in [[-1.0, -0.15], [-0.75, 0.1], [0.75, -0.1], [1.0, 0.12]]:
		var lx: float = x + p[0] * s
		_l(lx, y + 1.25 * s, lx + p[1] * s, y + 0.05 * s, leg if p[1] > 0 else col, 0.22 * s)
		_r(lx + p[1] * s - 0.13 * s, y, lx + p[1] * s + 0.13 * s, y + 0.15 * s, DARK)
	_ell(x, y + 1.45 * s, 1.35 * s, 0.5 * s, 0, col)
	# the neck and head
	_poly([x - 0.75 * s, y + 1.15 * s, x - 1.3 * s, y + 1.5 * s, x - 1.75 * s, y + 2.5 * s, x - 1.35 * s, y + 2.65 * s,
		x - 0.6 * s, y + 1.8 * s], col)
	_poly([x - 1.75 * s, y + 2.5 * s, x - 2.45 * s, y + 1.95 * s, x - 2.55 * s, y + 2.15 * s, x - 1.85 * s,
		y + 2.8 * s, x - 1.45 * s, y + 2.75 * s], col)
	_poly([x - 1.55 * s, y + 2.75 * s, x - 1.45 * s, y + 3.05 * s, x - 1.4 * s, y + 2.7 * s], col)
	# the mane and tail
	_pl([x - 1.4 * s, y + 2.8 * s, x - 1.0 * s, y + 2.2 * s, x - 0.6 * s, y + 1.85 * s], mane, 0.22 * s)
	_pl([x + 1.3 * s, y + 1.7 * s, x + 1.6 * s, y + 1.3 * s, x + 1.65 * s, y + 0.6 * s], mane, 0.25 * s)
	if _detail(3.0):
		_c(x - 1.85 * s, y + 2.5 * s, 0.07 * s, DARK)

## Sioux Falls: the Big Sioux River tumbling in white cascades over ledges of pink quartzite in Falls Park,
## with the stone ruins of the old Queen Bee Mill above and trees along the banks.
static func _sioux_falls() -> void:
	var q := Color("c98274")
	var qd := Color("9a5a50")
	var ql := Color("e0a597")
	# trees behind and the river above the falls
	for p in [[-17.5, 12.5, 3.0], [-13, 13.5, 3.4], [-5, 13, 2.6], [5, 13.2, 2.8], [11, 13.8, 3.4], [16.5, 12.8, 3.2]]:
		_c(p[0], p[1], p[2], Color("4f7a40"))
		_c(p[0] - 0.8, p[1] + 0.8, p[2] * 0.6, Color("6a944f"))
	_r(-20, 10.5, 20, 12.4, WATER)
	# the mill ruin: stone walls with empty windows on the left bank
	var mill := Color("cdb58f")
	_r(-19, 11.5, -11, 17, mill)
	_poly([-19, 17, -17, 17, -17, 18.2, -16, 18.2, -16, 17, -11, 17, -11, 16, -19, 16], mill)
	_r(-11.2, 11.5, -11, 16, mill.darkened(0.15))
	for x in [-18.0, -15.6, -13.2]:
		_r(x, 12.6, x + 1.2, 14.4, WIN)
		_c(x + 0.6, 14.4, 0.6, WIN)
	# the quartzite: one rounded, cracked mass in three ledges, each a little lower and nearer
	var tiers := [[11.2, 7.4, 0.0], [7.4, 4.2, 1.5], [4.2, 1.2, 0.7]]
	for t in 3:
		var yt: float = tiers[t][0]
		var yb: float = tiers[t][1]
		var ph: float = tiers[t][2]
		var top := [20.0, yb]
		for k in 21:
			var x := 20.0 - k * 2.0
			top.append_array([x, yt + sin(x * 0.7 + ph) * 0.35 + sin(x * 1.9 + ph) * 0.2])
		top.append_array([-20.0, yb])
		_poly(top, q if t % 2 == 0 else q.lightened(0.06))
		_r(-20, yb, 20, yb + 0.7, qd)
		for k in 7:
			var x := -17.0 + k * 5.6 + ph * 1.5
			_ell(x, yt - 0.9, 1.9, 0.6, 0, ql)
			if _detail(1.2):
				_l(x + 1.2, yb + 0.7, x + 0.6, yt - 1.4, qd, 0.18)
	# the cascades: broad white water falling over each lip, foaming at each foot
	var falls := [[-1.0, 3.0, 0], [-1.5, 5.0, 1], [-0.5, 7.0, 2], [9.5, 2.2, 1], [10.5, 3.5, 2], [-12.0, 2.4, 2],
		[14.5, 1.4, 0]]
	for f in falls:
		var fx: float = f[0]
		var hw: float = f[1]
		var t: int = f[2]
		var yt: float = tiers[t][0]
		var yb: float = tiers[t][1]
		_poly([fx - hw, yt + 0.4, fx + hw, yt + 0.4, fx + hw * 1.1, yb, fx - hw * 1.1, yb], WATER_L)
		_poly([fx - hw * 0.8, yt + 0.3, fx + hw * 0.8, yt + 0.3, fx + hw * 0.9, yb, fx - hw * 0.9, yb], FOAM)
		if _detail(1.0):
			for j in 3:
				var sx := fx + (j - 1) * hw * 0.5
				_l(sx, yt, sx, yb + 0.3, WATER_L, 0.2)
		_ell(fx, yb + 0.2, hw * 1.3, 0.7, 0, WHITE)
	# the river running across the ledges between the falls
	_r(-3.5, 7.4, 2.5, 7.9, WATER)
	_r(-6.0, 4.2, 4.0, 4.6, WATER)
	# the pool below
	_r(-20, 0, 20, 1.5, WATER)
	if _detail(1.5):
		for p in [[-16, 0.6], [-6, 0.4], [9, 0.8]]:
			_r(p[0], p[1], p[0] + 4, p[1] + 0.2, WATER_L)

## An onion dome on a drum: a bulb `r` wide at the waist and `h` tall, base centred on (cx, y), striped with c2.
static func _onion(cx: float, y: float, r: float, h: float, c1: Color, c2: Color) -> void:
	var prof := [[0.7, 0.0], [0.95, 0.18], [1.0, 0.34], [0.88, 0.52], [0.6, 0.68], [0.3, 0.82], [0.0, 1.0]]
	for band in [[1.0, c1], [0.55, c2], [0.18, c1]]:
		var sx: float = band[0]
		var pts := []
		for p in prof:
			pts.append_array([cx - p[0] * r * sx, y + p[1] * h])
		for j in range(prof.size() - 2, -1, -1):
			pts.append_array([cx + prof[j][0] * r * sx, y + prof[j][1] * h])
		_poly(pts, band[1])
	_l(cx, y + h, cx, y + h + h * 0.3, DARK, 0.12)
	_c(cx, y + h + h * 0.3, 0.15, YELLOW)

## A corn cob with its husk leaves, lying at angle `a` from (x, y).
static func _cob(x: float, y: float, ln: float, a: float, col: Color) -> void:
	var dx := cos(a)
	var dy := sin(a)
	_poly([x, y, x + dx * ln * 0.5 - dy * 0.6, y + dy * ln * 0.5 + dx * 0.6, x + dx * ln * 0.2, y + dy * ln * 0.2],
		Color("6f9a48"))
	_poly([x, y, x + dx * ln * 0.5 + dy * 0.6, y + dy * ln * 0.5 - dx * 0.6, x + dx * ln * 0.2, y + dy * ln * 0.2],
		Color("8ab05a"))
	_ell(x + dx * ln * 0.55, y + dy * ln * 0.55, ln * 0.45, ln * 0.13, a, col)
	if _detail(2.5):
		for k in 4:
			var t := 0.3 + k * 0.15
			_c(x + dx * ln * t, y + dy * ln * t, ln * 0.05, col.darkened(0.25))

## The Corn Palace in Mitchell: a hall whose walls are covered in murals made of corn cobs and grain, redone
## every year, under a row of colourful Moorish onion domes and minarets.
static func _corn_palace() -> void:
	var wall := Color("e8c45a")
	var frame := Color("8a5a2a")
	var husk := Color("d9a441")
	# the main hall and the three towers
	_r(-16, 0, 16, 12.5, wall)
	_r(-16, 12.5, 16, 13.4, frame)
	for k in 16:
		var x := -16.0 + k * 2.0
		_poly([x, 13.4, x + 2, 13.4, x + 1, 14.6], RED if k % 2 == 0 else husk)
	for t in [[-16.5, -11.5, 17.0], [11.5, 16.5, 17.0], [-3.0, 3.0, 19.0]]:
		_r(t[0], 0, t[1], t[2], wall.darkened(0.06))
		_r(t[0], t[2] - 1.0, t[1], t[2], frame)
		_r(t[0] + 0.6, t[2] - 3.4, t[1] - 0.6, t[2] - 1.6, frame.lightened(0.15))
		if _detail(1.5):
			for j in 3:
				var x0: float = lerpf(t[0] + 0.8, t[1] - 0.8, (j + 0.5) / 3.0)
				_r(x0 - 0.3, t[2] - 3.2, x0 + 0.3, t[2] - 1.8, YELLOW)
	# the onion domes, striped like painted corn
	_onion(-14, 17, 2.2, 5.0, RED, WHITE)
	_onion(14, 17, 2.2, 5.0, Color("2f6fa6"), WHITE)
	_onion(0, 19, 3.0, 6.5, Color("d97a2a"), YELLOW)
	for x in [-7.5, 7.5]:
		_r(x - 0.6, 13.4, x + 0.6, 16.5, wall.darkened(0.06))
		_onion(x, 16.5, 1.1, 3.0, Color("49a85a"), YELLOW)
	# the corn murals: framed panels with cobs and a sun over striped fields
	for p in [[-15.0, -4.0], [4.0, 15.0]]:
		var x0: float = p[0]
		var x1: float = p[1]
		_r(x0, 3.0, x1, 11.0, frame)
		_r(x0 + 0.4, 3.4, x1 - 0.4, 10.6, Color("f3e3b0"))
	# left panel: crossed cobs
	_cob(-9.5, 3.8, 6.4, PI * 0.5 + 0.55, Color("e2a93b"))
	_cob(-9.5, 3.8, 6.4, PI * 0.5 - 0.55, Color("c8502a"))
	_cob(-9.5, 3.8, 6.8, PI * 0.5, YELLOW)
	# right panel: the sun over rows of a corn field
	for k in 4:
		_r(4.4, 3.4 + k * 1.2, 14.6, 4.0 + k * 1.2, Color("6f9a48") if k % 2 == 0 else Color("b8833a"))
	_c(9.5, 9.0, 1.6, Color("e8902a"))
	if _detail(1.0):
		for k in 8:
			var a := TAU * k / 8.0
			_l(9.5 + cos(a) * 1.9, 9.0 + sin(a) * 1.9, 9.5 + cos(a) * 2.6, 9.0 + sin(a) * 1.4 * 1.85, Color("e8902a"), 0.25)
	# the entrance arch
	_r(-3.0, 0, 3.0, 8.5, frame)
	_r(-2.2, 0, 2.2, 6.0, Color("5a3a20"))
	_c(0, 6.0, 2.2, Color("5a3a20"))
	if _detail(1.0):
		_l(0, 0, 0, 7.6, frame, 0.2)
		_r(-1.9, 9.4, 1.9, 11.6, frame)
		_cob(-1.6, 10.1, 3.4, 0.1, YELLOW)

## One striped Badlands butte: a peak at (ax, ay) over the base x0..x1, in horizontal bands of `cols`.
static func _butte(x0: float, x1: float, ax: float, ay: float, cols: Array, phase: int) -> void:
	var bands := [0.0, 0.16, 0.27, 0.42, 0.52, 0.64, 0.75, 0.86, 1.0]
	for k in bands.size() - 1:
		var y0: float = bands[k] * ay
		var y1: float = bands[k + 1] * ay
		var f0 := y0 / ay
		var f1 := y1 / ay
		_poly([lerpf(x0, ax, f0), y0, lerpf(x1, ax, f0), y0, lerpf(x1, ax, f1), y1, lerpf(x0, ax, f1), y1],
			cols[(k + phase) % cols.size()])
	if _detail(1.0):
		for j in 3:
			var gx := lerpf(x0, x1, 0.3 + j * 0.2)
			_l(gx, 0, lerpf(gx, ax, 0.7), ay * 0.7, Color(0, 0, 0, 0.12), 0.25)

## Wall, South Dakota: the striped peaks of the Badlands, a big Wall Drug billboard on its posts, and the giant
## jackalope, the rabbit with antlers, sitting by the road.
static func _wall_drug_badlands() -> void:
	var cols := [Color("eadbc0"), Color("d9a08a"), Color("c9a77a"), Color("c47e66"), Color("e4c69c"), Color("efe4cf")]
	for b in [[-25, -9, -17, 17, 0], [-14, 4, -6, 21, 2], [-2, 14, 6, 18, 1], [8, 25, 17, 20, 3], [18, 25, 22, 13, 4],
			[-21, -3, -12, 12, 3], [2, 20, 11, 11, 5]]:
		_butte(b[0], b[1], b[2], b[3], cols, b[4])
	_r(-25, 0, 25, 2.2, PRAIRIE)
	_r(-25, 0, 25, 0.6, Color("a8955a"))
	# the billboard
	for x in [-21.0, -9.0]:
		_r(x - 0.4, 0, x + 0.4, 5.5, WOOD)
	_r(-24.0, 5.0, -6.0, 13.6, Color("7a3a2a"))
	_r(-23.5, 5.5, -6.5, 13.1, WHITE)
	_word("WALL", -21.5, 9.9, 2.4, 2.3, 0.9, RED, 0.5)
	_word("DRUG", -21.5, 6.4, 2.4, 2.3, 0.9, DARK, 0.5)
	# the giant jackalope, sitting and facing left
	_jackalope(15.5, 0.5, 1.45)

## The giant jackalope, a rabbit with deer antlers, sitting and facing left at (x, y), `s` times 8 m tall.
static func _jackalope(x: float, y: float, s: float) -> void:
	var fur := Color("a87850")
	_ell(x + 1.6 * s, y + 1.2 * s, 2.2 * s, 1.3 * s, 0, fur.darkened(0.12))
	_ell(x + 0.4 * s, y + 3.8 * s, 2.5 * s, 3.3 * s, -0.25, fur)
	_ell(x - 0.8 * s, y + 3.2 * s, 1.0 * s, 1.8 * s, -0.2, Color("d8b890"))
	_ell(x - 1.0 * s, y + 0.8 * s, 1.6 * s, 0.8 * s, 0, fur.lightened(0.08))
	_c(x + 3.0 * s, y + 2.2 * s, 0.8 * s, WHITE)
	_ell(x - 1.6 * s, y + 6.9 * s, 1.7 * s, 1.4 * s, 0.15, fur)
	_ell(x - 3.0 * s, y + 6.5 * s, 0.7 * s, 0.55 * s, 0, fur.lightened(0.15))
	_c(x - 3.6 * s, y + 6.6 * s, 0.22 * s, DARK)
	_c(x - 2.0 * s, y + 7.3 * s, 0.25 * s, DARK)
	_ell(x - 0.5 * s, y + 9.2 * s, 0.45 * s, 1.6 * s, 0.45, fur)
	_ell(x - 0.5 * s, y + 9.2 * s, 0.22 * s, 1.2 * s, 0.45, Color("e7b6a2"))
	# the antlers
	var ant := Color("f4ead2")
	for side in [-1.0, 1.0]:
		var bx: float = x - 1.8 * s + side * 0.4 * s
		var by := y + 8.0 * s
		_pl([bx, by, bx + side * 0.8 * s, by + 1.8 * s, bx + side * 1.9 * s, by + 3.0 * s], ant, 0.32 * s)
		_l(bx + side * 0.8 * s, by + 1.8 * s, bx + side * 0.2 * s, by + 3.3 * s, ant, 0.26 * s)
		_l(bx + side * 1.4 * s, by + 2.5 * s, bx + side * 2.4 * s, by + 2.2 * s, ant, 0.26 * s)

## A cruiser motorcycle in profile facing right, standing at (x, y).
static func _bike(x: float, y: float, s: float, col: Color) -> void:
	var chrome := Color("d8dde2")
	for wx in [x - 0.8 * s, x + 0.85 * s]:
		_c(wx, y + 0.36 * s, 0.36 * s, DARK)
		_c(wx, y + 0.36 * s, 0.2 * s, chrome)
		_c(wx, y + 0.36 * s, 0.07 * s, DARK)
	_poly([x - 1.2 * s, y + 0.55 * s, x - 0.75 * s, y + 0.85 * s, x - 0.3 * s, y + 0.75 * s], col)
	_r(x - 0.35 * s, y + 0.3 * s, x + 0.25 * s, y + 0.7 * s, chrome)
	_l(x - 0.8 * s, y + 0.36 * s, x + 0.2 * s, y + 0.45 * s, chrome, 0.08 * s)
	_l(x - 0.3 * s, y + 0.3 * s, x - 1.1 * s, y + 0.25 * s, chrome, 0.1 * s)
	_ell(x + 0.15 * s, y + 0.9 * s, 0.42 * s, 0.19 * s, -0.1, col)
	_poly([x - 0.75 * s, y + 0.78 * s, x - 0.15 * s, y + 0.82 * s, x - 0.25 * s, y + 0.98 * s, x - 0.8 * s, y + 0.98 * s], DARK)
	_l(x + 0.85 * s, y + 0.36 * s, x + 0.55 * s, y + 1.15 * s, chrome, 0.08 * s)
	_pl([x + 0.55 * s, y + 1.15 * s, x + 0.45 * s, y + 1.5 * s, x + 0.3 * s, y + 1.5 * s], DARK, 0.08 * s)
	_c(x + 0.72 * s, y + 1.0 * s, 0.1 * s, Color("fff2b0"))
	_poly([x + 0.55 * s, y + 0.6 * s, x + 1.12 * s, y + 0.6 * s, x + 0.95 * s, y + 0.8 * s], col)

## Sturgis during the rally: a long row of motorcycles parked along Main Street in front of old brick and
## false-front shops, pennants over the street and the dark pine-covered Black Hills behind.
static func _sturgis_motorcycles() -> void:
	var hills := Color("2c4434")
	_poly([-18, 0, -18, 9, -12, 11.5, -6, 10.5, 0, 12.5, 7, 11, 13, 12, 18, 10, 18, 0], hills)
	_poly([-18, 0, -18, 7, -9, 8.5, 2, 7.8, 10, 9, 18, 7.5, 18, 0], hills.lightened(0.1))
	# the shops
	var fronts := [[-18, -12, 7.5, Color("a5452f")], [-12, -7, 8.5, Color("d6c39a")], [-7, -1, 7.0, Color("4f8c88")],
		[-1, 5, 9.0, Color("8a3a2c")], [5, 10, 7.5, Color("e0b85a")], [10, 18, 8.0, Color("7d5a8a")]]
	for f in fronts:
		var x0: float = f[0]
		var x1: float = f[1]
		var h: float = f[2]
		var c: Color = f[3]
		_r(x0, 0, x1, h, c)
		_r(x0, h - 0.6, x1, h, c.darkened(0.25))
		_r(x0 + 0.5, 0.6, x1 - 0.5, 3.0, Color("9fc4dc").darkened(0.2))
		_r(x0 + 0.3, 3.0, x1 - 0.3, 3.6, c.lightened(0.25))
		_windows(x0 + 0.6, x1 - 0.6, 4.6, 6.2, 2 if x1 - x0 < 6.5 else 3, WIN)
	# the pennants
	if _detail(1.5):
		var pc := [RED, WHITE, Color("2f6fa6"), YELLOW]
		for k in 18:
			var px := -17.0 + k * 2.0
			var py := 9.6 - sin(float(k) / 17.0 * PI) * 1.0
			_poly([px - 0.5, py, px + 0.5, py, px, py - 0.9], pc[k % pc.size()])
		_pl([-18, 9.6, -9, 8.9, 0, 8.6, 9, 8.9, 18, 9.6], DARK, 0.08)
	_r(-18, 0, 18, 0.5, Color("5e5b56"))
	# the row of motorcycles
	var bc := [Color("1f1f24"), RED, Color("2f6fa6"), Color("1f1f24"), Color("e8902a"), Color("6a2a6a"),
		Color("1f1f24"), Color("2f8a5a"), Color("b0282a"), Color("1f1f24")]
	for k in 7:
		_bike(-14.6 + k * 4.9, 0.1, 2.1, bc[k])

## Devils Tower, which the Lakota and other nations call Mato Tipila, Bear Lodge: a sacred tower of grey
## rock columns with a flat top, rising over a skirt of pines, a slope of fallen boulders and the golden
## prairie of Wyoming.
static func _devils_tower() -> void:
	var rock := Color("b8a07e")
	# the prairie and a far ridge
	_poly([-25, 0, -25, 7, -15, 8.5, 0, 7.5, 15, 9, 25, 7, 25, 0], Color("8a9a6a"))
	# the boulder apron
	_poly([-18, 4, -11, 9, 11, 9, 18, 4], Color("a39a8a"))
	if _detail(1.0):
		for p in [[-14, 5.2], [-10, 6.6], [-6, 5.4], [7, 6.0], [11, 5.0], [14, 6.6], [2, 7.6]]:
			_c(p[0], p[1], 0.7, Color("c4bcae"))
	# the columns: strips flaring at the foot, the top shoulders rounded
	var n := 16
	for k in n:
		var t0 := float(k) / n
		var t1 := float(k + 1) / n
		var tm := (t0 + t1) * 0.5
		var top := 34.0 - 4.0 * pow(absf(tm - 0.5) * 2.0, 2.5) + sin(k * 2.3) * 0.5
		var c := rock.lightened(0.12 - tm * 0.3) if k % 2 == 0 else rock.lightened(0.05 - tm * 0.3)
		_poly([lerpf(-11, 11, t0), 8.5, lerpf(-11, 11, t1), 8.5, lerpf(-8, 8, t1), 13, lerpf(-6.2, 6.2, t1), top,
			lerpf(-6.2, 6.2, t0), top, lerpf(-8, 8, t0), 13], c)
	if _detail(1.0):
		for k in range(1, n):
			var t := float(k) / n
			_pl([lerpf(-11, 11, t), 8.5, lerpf(-8, 8, t), 13, lerpf(-6.2, 6.2, t), 33], rock.darkened(0.3), 0.12)
	# the pine skirt round its foot
	for p in [[-17, 5.5], [-14.5, 6.5], [-12, 6], [-9, 5], [-6, 4.5], [-3, 5], [1, 4.5], [4, 5], [7.5, 4.8], [10.5, 6],
			[13, 6.5], [16, 5.5], [19, 4.5], [-20, 4]]:
		_fir(p[0], 3.0, p[1], PINE)
	_r(-25, 0, 25, 3.2, PRAIRIE)
	_r(-25, 0, 25, 1.0, Color("b19f5c"))

## A teepee `h` tall at (x, y) with painted bands, poles crossing at the top and the door.
static func _teepee(x: float, y: float, h: float, band: Color, band2: Color) -> void:
	var w := h * 0.42
	var canvas := Color("f1ead8")
	_l(x, y + h * 0.95, x - w * 0.35, y + h * 1.18, WOOD, h * 0.025)
	_l(x, y + h * 0.95, x + w * 0.3, y + h * 1.2, WOOD, h * 0.025)
	_l(x, y + h * 0.95, x + w * 0.05, y + h * 1.22, WOOD, h * 0.025)
	_poly([x - w, y, x + w, y, x, y + h], canvas)
	_poly([x, y, x + w, y, x, y + h], canvas.darkened(0.08))
	# the smoke flaps
	_poly([x - w * 0.12, y + h * 0.72, x - w * 0.42, y + h * 0.82, x - w * 0.06, y + h * 0.9], canvas.darkened(0.12))
	_poly([x + w * 0.12, y + h * 0.72, x + w * 0.42, y + h * 0.82, x + w * 0.06, y + h * 0.9], canvas.darkened(0.18))
	# painted bands
	var f0 := 0.12
	var f1 := 0.24
	_poly([x - w * (1 - f0), y + h * f0, x + w * (1 - f0), y + h * f0, x + w * (1 - f1), y + h * f1,
		x - w * (1 - f1), y + h * f1], band)
	_poly([x - w * 0.42, y + h * 0.58, x + w * 0.42, y + h * 0.58, x + w * 0.36, y + h * 0.64, x - w * 0.36,
		y + h * 0.64], band2)
	if _detail(1.2):
		for k in 3:
			_c(x + (k - 1) * w * 0.35, y + h * 0.4, h * 0.035, band2)
		for k in 4:
			var bx := x - w * 0.62 + k * w * 0.41
			_poly([bx, y + h * 0.24, bx + w * 0.2, y + h * 0.24, bx + w * 0.1, y + h * 0.31], band)
	# the door
	_ell(x, y + h * 0.1, w * 0.17, h * 0.1, 0, DARK)

## Crow Fair at Crow Agency on the Crow Nation's reservation, the "teepee capital of the world": a camp of many
## white teepees with painted bands, the Bighorn Mountains behind.
static func _crow_fair_teepees() -> void:
	_poly([-22, 0, -22, 9, -14, 12.5, -8, 11, -2, 14, 6, 11.5, 12, 13.5, 18, 11, 22, 10, 22, 0], Color("7f92a8"))
	_poly([-22, 0, -22, 6, -10, 7.5, 2, 6.5, 14, 8, 22, 6.5, 22, 0], Color("8a9a6a"))
	_r(-22, 0, 22, 4.0, Color("9ab06a"))
	var cols := [[RED, Color("2f6fa6")], [Color("2f6fa6"), YELLOW], [YELLOW, RED], [Color("2f8a5a"), RED],
		[Color("5a3a8a"), YELLOW], [RED, DARK]]
	# the back row, smaller with distance
	for k in 6:
		var c: Array = cols[(k + 2) % cols.size()]
		_teepee(-17.0 + k * 7.0, 3.8, 6.5, c[0], c[1])
	for k in 5:
		var c: Array = cols[k % cols.size()]
		_teepee(-14.5 + k * 7.2, 0.3, 10.0 + (k % 2) * 1.5, c[0], c[1])

## A sunflower head of radius r at (x, y), facing us.
static func _sunflower(x: float, y: float, r: float) -> void:
	_c(x, y, r, YELLOW)
	if _detail(2.0):
		for k in 8:
			var a := TAU * k / 8.0 + 0.2
			_c(x + cos(a) * r * 0.9, y + sin(a) * r * 0.9, r * 0.32, Color("f5b52a"))
	_c(x, y, r * 0.48, Color("6a3a1a"))

## Goodland's giant easel with a copy of Van Gogh's "Sunflowers", 24 metres tall, over a Kansas field of
## sunflowers.
static func _van_gogh_sunflowers() -> void:
	var wood := Color("7a5634")
	var steel := Color("6a5a48")
	# the easel: back leg, two front legs and the ledge
	_l(0, 24.5, 2.5, 0, steel.darkened(0.25), 0.6)
	_l(-0.6, 25, -6.5, 0, steel, 0.7)
	_l(0.6, 25, 6.5, 0, steel, 0.7)
	_r(-6.2, 3.6, 6.2, 4.4, steel.darkened(0.1))
	# the canvas in its frame
	_r(-5.6, 4.4, 5.6, 19.6, wood)
	_r(-5.1, 4.9, 5.1, 19.1, Color("e9cf58"))
	_r(-5.1, 4.9, 5.1, 9.2, Color("d6a83a"))
	_l(-5.1, 9.2, 5.1, 9.2, Color("b8862a"), 0.15)
	# the vase
	_ell(0, 7.6, 1.9, 1.9, 0, Color("e8b84a"))
	_r(-1.4, 7.6, 1.4, 11.0, Color("e8b84a"))
	_r(-1.4, 9.4, 1.4, 9.8, Color("2f6fa6"))
	_r(-1.6, 10.8, 1.6, 11.4, Color("d09a3a"))
	# the sunflowers, some looking up, some drooping
	var heads := [[-2.6, 16.6, 1.4], [0.6, 17.4, 1.3], [3.2, 15.4, 1.2], [-3.4, 13.4, 1.1], [1.4, 14.0, 1.25],
		[-0.9, 12.4, 0.9], [3.6, 12.2, 0.85], [-3.8, 10.6, 0.8]]
	for h in heads:
		_l(0, 11, h[0], h[1], Color("6f9a48"), 0.18)
	for h in heads:
		_sunflower(h[0], h[1], h[2])
	# the field of sunflowers in front
	for row in 3:
		for k in 16:
			var x := -14.5 + k * 1.95 + (row % 2) * 0.9
			var y := 3.2 - row * 1.1
			if absf(x) < 1.0 and row == 0:
				continue
			_l(x, 0, x, y, Color("4f7a40"), 0.14)
			_ell(x + 0.35, y - 0.5, 0.4, 0.18, 0.4, Color("4f7a40"))
			_sunflower(x, y, 0.55 + row * 0.1)

## The Keeper of the Plains in Wichita: the tall steel statue of a Native American with his arms raised to the
## sky, by the Mid-America All-Indian Museum, on a rock where the Big and Little Arkansas Rivers meet, with its
## ring of fire pots and the two bow-shaped footbridges.
static func _keeper_of_the_plains() -> void:
	# the two rivers meeting in front
	_poly([-20, 0, 20, 0, 20, 2.5, 3, 5, 0, 5.2, -3, 5, -20, 2.5], WATER)
	if _detail(1.0):
		for p in [[-15, 1.2], [-4, 0.6], [8, 1.5]]:
			_r(p[0], p[1], p[0] + 5, p[1] + 0.25, WATER_L)
	# the footbridges: a deck and a white bow mast with its cables, one each side
	for side in [-1.0, 1.0]:
		var d0: float = side * 3.5
		var d1: float = side * 20.0
		_r(minf(d0, d1), 3.0, maxf(d0, d1), 3.7, Color("d8d2c2"))
		var bow := []
		for k in 9:
			var t := float(k) / 8.0
			bow.append_array([lerpf(side * 6.0, side * 17.0, t), 3.7 + sin(t * PI) * 8.0 + t * 1.5])
		_pl(bow, WHITE, 0.45)
		if _detail(1.0):
			for j in range(2, bow.size() - 2, 2):
				_l(bow[j], bow[j + 1], bow[j] + side * 0.6, 3.7, Color("c4c8cc"), 0.08)
	# the rock and the fire pots round it
	var stone := Color("a8957a")
	_poly([-6.5, 4.5, -5.5, 7, -3, 8.5, 3, 8.5, 5.5, 7, 6.5, 4.5], stone)
	_poly([-5.5, 7, -3, 8.5, 3, 8.5, 5.5, 7], stone.lightened(0.12))
	for x in [-5.0, -2.0, 2.0, 5.0]:
		_r(x - 0.5, 4.8, x + 0.5, 5.6, Color("4a4038"))
		_ell(x, 6.3, 0.45, 0.8, 0, Color("f08a2a"))
		_ell(x, 6.1, 0.22, 0.45, 0, YELLOW)
	# the Keeper, in weathered steel
	var st := Color("6b4a36")
	var sl := Color("8a6448")
	_poly([-1.4, 8.5, 1.4, 8.5, 0.9, 15.5, -0.9, 15.5], st)
	_poly([0, 8.5, 1.4, 8.5, 0.9, 15.5, 0, 15.5], sl)
	_poly([-0.9, 15.5, 0.9, 15.5, 0.8, 18.0, -0.8, 18.0], st)
	if _detail(1.2):
		_l(-1.1, 11.0, 1.1, 11.0, sl, 0.15)
		_l(-0.6, 9.0, -0.3, 15.0, sl.lightened(0.15), 0.12)
	# the arms, raised high
	_pl([-0.7, 17.6, -1.9, 19.8, -2.6, 22.4], st, 0.45)
	_pl([0.7, 17.6, 1.9, 19.8, 2.6, 22.4], st, 0.45)
	_c(-2.6, 22.5, 0.3, st)
	_c(2.6, 22.5, 0.3, st)
	# the head and the headdress of feathers
	for k in 7:
		var a := lerpf(PI * 0.3, PI * 0.7, float(k) / 6.0)
		_l(0, 18.9, cos(a) * 2.2, 18.9 + sin(a) * 2.6, sl if k % 2 == 0 else st, 0.3)
	_c(0, 18.9, 0.7, st)

## The First Americans Museum in Oklahoma City, which honours the 39 nations of Oklahoma: its great grassy mound
## with a path spiralling up, and the tall ribbed glass dome of the Hall of the People.
static func _first_americans_museum() -> void:
	# the mound
	_poly([-30, 0] + _arc(-10, 0, 20, 12, PI, 0, 18) + [10, 0], Color("6f9a48"))
	_poly([-30, 0] + _arc(-10, 0, 20, 12, PI, PI * 0.5, 9) + [-10, 0], Color("7ea856"))
	if _detail(0.6):
		_pl([-28, 1.5, -18, 5.5, -6, 8.0, 4, 6.5, 7, 3.5, -2, 4.5, -12, 7.5, -18, 9.5, -12, 11.5, -6, 11.2], Color("d8c49a"), 0.45)
	# the long low wings of stone and glass
	var stone := Color("d6be96")
	_poly([-24, 0, 30, 0, 30, 4.2, 18, 5.2, 4, 4.8, -10, 3.8, -24, 2.6], stone)
	_r(-20, 0.8, 28, 2.4, Color("6a8aa6"))
	if _detail(1.0):
		for k in 24:
			var x := -19.0 + k * 2.0
			_l(x, 0.8, x, 2.4, stone, 0.12)
	# the Hall of the People: a tall ribbed glass dome
	var hx := 17.0
	var glass := Color("6f9cba")
	var dome := []
	for k in 17:
		var t := float(k) / 16.0
		var x := lerpf(-8.0, 8.0, t)
		var u := x / 8.0
		dome.append_array([hx + x, 4.5 + 19.0 * (1.0 - pow(absf(u), 2.2))])
	_poly(dome, glass)
	_poly([hx, 4.5] + dome.slice(16, 34), glass.darkened(0.1))
	for k in 9:
		var x := lerpf(-7.2, 7.2, (float(k) + 0.5) / 9.0)
		var rib := []
		for j in 7:
			var v := float(j) / 6.0
			rib.append_array([hx + x * pow(1.0 - v, 1.0 / 2.2), 4.5 + 19.0 * v])
		_pl(rib, glass.lightened(0.35), 0.16)
	if _detail(1.0):
		for y in [9.0, 13.5, 17.5, 21.0]:
			var hw := 8.0 * pow(1.0 - (y - 4.5) / 19.0, 1.0 / 2.2)
			_l(hx - hw, y, hx + hw, y, glass.lightened(0.35), 0.1)
	_r(hx - 0.5, 23.3, hx + 0.5, 24.6, Color("e8ecee"))

## A Navajo rug on an upright loom: a red field with serrated black-and-white diamonds and a grey border.
static func _loom(x0: float, x1: float, y0: float, y1: float) -> void:
	_r(x0 - 0.5, 0, x0, y1 + 1.0, WOOD)
	_r(x1, 0, x1 + 0.5, y1 + 1.0, WOOD)
	_r(x0 - 0.7, y1 + 0.4, x1 + 0.7, y1 + 0.9, WOOD)
	_r(x0, y0 - 0.5, x1, y0, WOOD.lightened(0.1))
	if _detail(1.5):
		for k in 9:
			var x := lerpf(x0 + 0.2, x1 - 0.2, k / 8.0)
			_l(x, y1, x, y1 + 0.4, Color("e8e0cc"), 0.05)
	_r(x0, y0, x1, y1, Color("8a8a84"))
	_r(x0 + 0.35, y0 + 0.35, x1 - 0.35, y1 - 0.35, Color("b8302a"))
	var cx := (x0 + x1) * 0.5
	var cy := (y0 + y1) * 0.5
	var rx := (x1 - x0) * 0.36
	var ry := (y1 - y0) * 0.38
	for s in [[1.0, DARK], [0.72, WHITE], [0.45, DARK], [0.2, Color("b8302a")]]:
		var f: float = s[0]
		_poly([cx, cy + ry * f, cx + rx * f, cy, cx, cy - ry * f, cx - rx * f, cy], s[1])
	for p in [[x0 + 0.9, y0 + 0.9], [x1 - 0.9, y0 + 0.9], [x0 + 0.9, y1 - 0.9], [x1 - 0.9, y1 - 0.9]]:
		_poly([p[0], p[1] + 0.45, p[0] + 0.45, p[1], p[0], p[1] - 0.45, p[0] - 0.45, p[1]], DARK)

## Navajo Nation, the largest reservation in the USA: a red sandstone cliff with a round window through it like
## Window Rock, a round hogan of logs and earth with its door facing the sunrise, and a weaver at her loom with
## a Navajo rug.
static func _navajo_hogan() -> void:
	var sand := Color("c87a4f")
	var cliff := Color("b5502e")
	# the cliff with its window
	_poly([-20, 0, -20, 14, -17, 16, -11, 17, -5, 16.5, 0, 15, 3, 12, 5, 7, 6, 0], cliff)
	_poly([-20, 14, -17, 16, -11, 17, -5, 16.5, 0, 15, -2, 14, -8, 15, -14, 14.5], cliff.lightened(0.15))
	if _detail(0.8):
		for y in [4.0, 7.5, 11.0]:
			_l(-20, y, 6.0 - (y / 15.0) * 4.0, y, cliff.darkened(0.15), 0.25)
	_ell(-9, 9.5, 3.6, 3.9, 0, SKY)
	_pl(_arc(-9, 9.5, 3.6, 3.9, 0, TAU, 20), cliff.darkened(0.2), 0.3)
	# the ground
	_r(-20, 0, 20, 1.5, sand)
	for p in [[11, 1.2], [18.5, 1.0], [-17, 1.4]]:
		_c(p[0], p[1] + 0.6, 1.0, Color("5f7a4a"))
		_c(p[0] + 0.7, p[1] + 0.9, 0.7, Color("6f8a52"))
	# the hogan: eight log walls (three seen) under a domed earth roof, the door facing east
	var lg := Color("8a6440")
	var hx := 13.0
	_poly([hx - 5.5, 0.5, hx - 3.5, 0, hx + 3.5, 0, hx + 5.5, 0.5, hx + 5.5, 4.5, hx + 3.5, 4.2, hx - 3.5, 4.2,
		hx - 5.5, 4.5], lg)
	_poly([hx - 5.5, 0.5, hx - 3.5, 0, hx - 3.5, 4.2, hx - 5.5, 4.5], lg.darkened(0.15))
	_poly([hx + 3.5, 0, hx + 5.5, 0.5, hx + 5.5, 4.5, hx + 3.5, 4.2], lg.lightened(0.08))
	if _detail(1.0):
		for k in 5:
			var y := 0.7 + k * 0.75
			_l(hx - 5.5, y + 0.25, hx - 3.5, y, lg.darkened(0.3), 0.08)
			_l(hx - 3.5, y, hx + 3.5, y, lg.darkened(0.3), 0.08)
			_l(hx + 3.5, y, hx + 5.5, y + 0.25, lg.darkened(0.3), 0.08)
	_poly([hx - 5.9, 4.4, hx + 5.9, 4.4, hx + 4.2, 6.6, hx + 1.5, 7.4, hx - 1.5, 7.4, hx - 4.2, 6.6], Color("a8704a"))
	_r(hx + 1.0, 7.0, hx + 1.5, 8.6, DARK)
	_r(hx - 1.0, 0, hx + 1.0, 3.2, Color("5a3a20"))
	_r(hx - 1.4, 3.2, hx + 1.4, 3.7, lg.darkened(0.2))
	# the loom with its rug, and the weaver sitting at it
	_loom(-3.5, 3.5, 2.0, 9.5)
	_weaver(-6.4, 0.2, 1.45)

## A Navajo weaver kneeling at her loom, facing right at (x, y), `s` times 4 m tall: velvet blouse, long
## skirt, silver concha belt and her hair tied in a bun.
static func _weaver(x: float, y: float, s: float) -> void:
	_poly([x - 1.6 * s, y, x + 1.6 * s, y, x + 1.1 * s, y + 1.4 * s, x - 1.2 * s, y + 1.4 * s], Color("2f6fa6"))
	_poly([x - 0.8 * s, y + 1.3 * s, x + 0.8 * s, y + 1.3 * s, x + 0.6 * s, y + 3.8 * s, x - 0.6 * s, y + 3.8 * s],
		Color("6a2a8a"))
	_r(x - 0.85 * s, y + 1.4 * s, x + 0.85 * s, y + 1.75 * s, Color("cfd3d6"))
	if _detail(2.0):
		for k in 3:
			_c(x + (k - 1) * 0.5 * s, y + 1.57 * s, 0.13 * s, Color("f4f7fa"))
	_pl([x + 0.4 * s, y + 3.4 * s, x + 1.5 * s, y + 2.7 * s, x + 2.5 * s, y + 3.1 * s], Color("6a2a8a"), 0.35 * s)
	_c(x + 2.55 * s, y + 3.1 * s, 0.2 * s, Color("8a5a3a"))
	_c(x, y + 4.4 * s, 0.62 * s, Color("8a5a3a"))
	_c(x - 0.15 * s, y + 4.65 * s, 0.6 * s, DARK)
	_ell(x - 0.6 * s, y + 4.3 * s, 0.38 * s, 0.3 * s, 0, DARK)
	_ell(x - 0.6 * s, y + 4.3 * s, 0.4 * s, 0.1 * s, 0, WHITE)

## A folded Pendleton-style blanket hanging over a rail from y down to y - h, in bold stripes and stepped
## arrows.
static func _blanket(x0: float, x1: float, y: float, h: float, base: Color, c1: Color, c2: Color) -> void:
	_r(x0, y - h, x1, y, base)
	_r(x0, y - h * 0.2, x1, y - h * 0.12, c1)
	_r(x0, y - h * 0.88, x1, y - h * 0.8, c1)
	var cx := (x0 + x1) * 0.5
	var cy := y - h * 0.5
	var r := (x1 - x0) * 0.32
	_poly([cx, cy + r, cx + r, cy, cx, cy - r, cx - r, cy], c2)
	_poly([cx, cy + r * 0.55, cx + r * 0.55, cy, cx, cy - r * 0.55, cx - r * 0.55, cy], c1)
	_poly([cx, cy + r * 0.2, cx + r * 0.2, cy, cx, cy - r * 0.2, cx - r * 0.2, cy], base)
	if _detail(1.5):
		for k in 3:
			var x := lerpf(x0 + 0.3, x1 - 0.3, k / 2.0)
			_poly([x - 0.3, y - h * 0.68, x + 0.3, y - h * 0.68, x, y - h * 0.6], c2)
			_poly([x - 0.3, y - h * 0.32, x + 0.3, y - h * 0.32, x, y - h * 0.4], c2)
	_r(x0, y - h - 0.2, x1, y - h, base.darkened(0.2))

## Pendleton and the Umatilla Reservation, home of the Cayuse, Umatilla and Walla Walla: the Tamástslikt Cultural
## Institute under the Blue Mountains, horses grazing, and boldly patterned Pendleton blankets on a fence rail.
static func _pendleton_umatilla() -> void:
	_poly([-20, 0, -20, 8, -12, 11, -4, 10, 4, 12.5, 12, 10.5, 20, 11.5, 20, 0], Color("6f86a8"))
	_poly([-20, 0, -20, 5.5, -8, 7, 4, 6, 14, 7.5, 20, 6.5, 20, 0], Color("d6b860"))
	_r(-20, 0, 20, 3.5, Color("b9a65a"))
	# the cultural institute: a long low hall with a sloping roof and a tall round entry
	var wood := Color("a8784a")
	_r(-2, 3.0, 17, 6.5, wood)
	_poly([-3, 6.3, 18, 6.3, 18, 7.0, 4, 8.8, -3, 7.2], Color("5f7f5a"))
	_windows(0, 15, 3.8, 5.6, 6, Color("4a5a6a"))
	_r(4.2, 3.0, 7.8, 9.0, Color("c8a878"))
	_poly([3.8, 9.0, 8.2, 9.0, 6.0, 10.6], Color("5f7f5a"))
	_r(5.3, 3.0, 6.7, 5.5, DARK)
	# horses
	_horse(16.5, 1.2, 1.3, Color("efe6d6"), Color("6a5a48"))
	if _detail(1.0):
		for p in [[16.0, 2.6], [17.2, 3.2], [15.4, 3.4], [17.6, 2.3], [18.1, 3.0]]:
			_c(p[0], p[1], 0.22, DARK)
	_horse(9.0, 0.2, 1.8, Color("8a4a2a"), DARK)
	# a blanket on the brown horse's back
	_poly([7.4, 3.3, 10.6, 3.3, 10.5, 2.0, 7.5, 2.0], Color("2f6fa6"))
	_r(7.4, 2.5, 10.6, 2.8, YELLOW)
	_poly([8.6, 3.2, 9.4, 3.2, 9.0, 2.2], RED)
	# the fence with the blankets over its rail
	for x in [-19.0, -13.0, -7.0, -1.0]:
		_r(x - 0.3, 0, x + 0.3, 5.6, WOOD)
	_r(-19.5, 5.0, -0.5, 5.5, WOOD.lightened(0.1))
	_r(-19.5, 2.2, -0.5, 2.6, WOOD.lightened(0.1))
	_blanket(-18.4, -13.6, 5.5, 4.4, Color("b8302a"), Color("f2c230"), Color("1f3a5a"))
	_blanket(-12.4, -7.6, 5.5, 4.0, Color("1f5a6a"), Color("e8902a"), Color("f4f2ea"))
	_blanket(-6.4, -1.6, 5.5, 4.6, Color("f0e2c0"), Color("b8302a"), Color("2f2a2a"))
