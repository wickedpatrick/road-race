class_name LandmarksUsT1
extends RefCounted
## American town landmarks (1), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const WHITE := Color("f4f2ea")
const WATER := Color("3f7fb5")
const WATER_L := Color("9cc8e6")
const SAND := Color("e6d29c")
const GRASS := Color("6f9a48")
const PINE := Color("2f5a36")
const WOOD := Color("7a5634")
const DARK := Color("2e3238")
const WIN := Color("3a4048")
const TYRE := Color("1e2226")
const SNOW := Color("f4f7fa")
const SNOW_S := Color("c9d6e4")
const BRICK := Color("a5503a")
const US_RED := Color("b22234")
const US_BLUE := Color("3c3b6e")
const GLASS := Color("a9cfe0")
const SMOKE := Color(0.92, 0.92, 0.94, 0.7)

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"fort_mchenry": _fort_mchenry()
		"presque_isle_lighthouse": _presque_isle_lighthouse()
		"cedar_point_coaster": _cedar_point_coaster()
		"goodyear_blimp": _goodyear_blimp()
		"amish_buggy": _amish_buggy()
		"valley_forge_huts": _valley_forge_huts()
		"dells_rocks": _dells_rocks()
		"lincoln_home": _lincoln_home()
		"butter_cow": _butter_cow()
		"nascar_car": _nascar_car()
		"incline_railway": _incline_railway()
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

## A dark evergreen: a brown stem and three stacked triangles, `h` tall.
static func _fir(x: float, y: float, h: float, col: Color) -> void:
	_r(x - h * 0.04, y, x + h * 0.04, y + h * 0.2, WOOD)
	for k in 3:
		var y0 := y + h * (0.15 + k * 0.25)
		var w := h * (0.3 - k * 0.07)
		_poly([x - w, y0, x + w, y0, x, y0 + h * 0.4], col)
		_poly([x - w, y0, x, y0, x, y0 + h * 0.4], col.lightened(0.1))

## A round leafy tree: a trunk and a few overlapping blobs, `h` tall.
static func _tree(x: float, y: float, h: float, col: Color) -> void:
	_r(x - h * 0.05, y, x + h * 0.05, y + h * 0.45, WOOD)
	_c(x, y + h * 0.65, h * 0.3, col)
	_c(x - h * 0.18, y + h * 0.55, h * 0.22, col.darkened(0.08))
	_c(x + h * 0.15, y + h * 0.75, h * 0.2, col.lightened(0.08))

## A bare winter tree: a trunk and a few forked branches, `h` tall.
static func _bare_tree(x: float, y: float, h: float, col: Color) -> void:
	_l(x, y, x, y + h * 0.75, col, h * 0.05)
	for b in [[0.35, -0.3, 0.6], [0.45, 0.28, 0.75], [0.6, -0.22, 0.95], [0.7, 0.18, 1.0]]:
		_l(x, y + h * b[0], x + h * b[1], y + h * b[2], col, h * 0.025)

## A flat list of points of a star with `n` points, radii `ro` and `ri`, squashed in y by `sq`.
static func _star_pts(cx: float, cy: float, ro: float, ri: float, n: int, sq: float, a0: float) -> Array:
	var out := []
	for k in n * 2:
		var a := a0 + PI * k / n
		var rr := ro if k % 2 == 0 else ri
		out.append_array([cx + cos(a) * rr, cy + sin(a) * rr * sq])
	return out

## A flag waving to the right on a pole standing at (x, y): the pole `h` high, the flag `fw` wide and `fh` tall,
## `stripes` red and white stripes, the blue canton `cw` of its width with a ring (true) or rows of white stars.
static func _old_flag(x: float, y: float, h: float, fw: float, fh: float, stripes: int, ring: bool) -> void:
	_l(x, y, x, y + h, Color("d8d4c8"), fw * 0.04)
	_c(x, y + h, fw * 0.03, Color("d8b14a"))
	var top := y + h - fw * 0.02
	var n := 6
	var wave := fh * 0.08
	# the flag as vertical slices, each a little up or down for the wave
	var sh := stripes if _detail(1.0) else 5
	for j in n:
		var x0 := x + fw * j / n
		var x1 := x + fw * (j + 1) / n
		var d0 := sin(j * 1.2) * wave
		var d1 := sin((j + 1) * 1.2) * wave
		for s in sh:
			var y0 := top - fh * (s + 1) / sh
			var y1 := top - fh * s / sh
			var col := US_RED if s % 2 == 0 else WHITE
			_poly([x0, y0 + d0, x1, y0 + d1, x1, y1 + d1, x0, y1 + d0], col)
	# the canton over the top stripes
	var cw := fw * 0.4
	var ch := fh * 0.54
	var nc := 3
	for j in nc:
		var x0 := x + cw * j / nc
		var x1 := x + cw * (j + 1) / nc
		var d0 := sin(float(j) / nc * 0.4 * n * 1.2) * wave
		var d1 := sin(float(j + 1) / nc * 0.4 * n * 1.2) * wave
		_poly([x0, top - ch + d0, x1, top - ch + d1, x1, top + d1, x0, top + d0], US_BLUE)
	if _detail(1.2):
		var sr := ch * 0.07
		if ring:
			for k in 13:
				var a := TAU * k / 13.0
				_c(x + cw * 0.5 + cos(a) * ch * 0.3, top - ch * 0.5 + sin(a) * ch * 0.32 + wave * 0.5, sr, WHITE)
		else:
			for r in 3:
				for c in 5:
					_c(x + cw * (0.12 + c * 0.19), top - ch * (0.2 + r * 0.3) + wave * 0.5, sr, WHITE)

## A seven-segment digit in a box w wide and h tall whose lower left corner is (x, y).
static func _digit(d: int, x: float, y: float, w: float, h: float, col: Color, lw: float) -> void:
	var segs := ["abcdef", "bc", "abged", "abgcd", "fgbc", "afgcd", "afgedc", "abc", "abcdefg", "abcdfg"]
	var s: String = segs[d]
	var m := y + h * 0.5
	if s.contains("a"): _l(x, y + h, x + w, y + h, col, lw)
	if s.contains("b"): _l(x + w, y + h, x + w, m, col, lw)
	if s.contains("c"): _l(x + w, m, x + w, y, col, lw)
	if s.contains("d"): _l(x, y, x + w, y, col, lw)
	if s.contains("e"): _l(x, m, x, y, col, lw)
	if s.contains("f"): _l(x, y + h, x, m, col, lw)
	if s.contains("g"): _l(x, m, x + w, m, col, lw)

# --- Baltimore ------------------------------------------------------------------------------------------------

## Fort McHenry: the low, star-shaped brick fort on its green point in Baltimore harbour, seen a little from
## above, little white barracks in its yard, a cannon on the wall and the huge Star-Spangled Banner (15 stars,
## 15 stripes) flying from its tall pole.
static func _fort_mchenry() -> void:
	_r(-20, 0, 20, 2.2, WATER)
	if _detail(1.0):
		for p in [[-17, 0.6], [-4, 1.3], [9, 0.5]]:
			_r(p[0], p[1], p[0] + 5, p[1] + 0.25, WATER_L)
	_poly([-20, 2.2, -20, 4.5, -14, 6.5, 14, 6.5, 20, 4.5, 20, 2.2], GRASS)
	_poly([-20, 2.2, -16, 3.2, 16, 3.2, 20, 2.2], GRASS.darkened(0.12))
	# the star: five pointed bastions, flattened by the view from above
	var cx := -3.0
	var cy := 4.0
	var wall := 2.4
	var outer := _star_pts(cx, cy, 13.5, 8.0, 5, 0.28, PI * 0.5)
	for k in 6:
		var dy := wall * k / 5.0
		var pts := []
		for j in range(0, outer.size(), 2):
			pts.append_array([outer[j], outer[j + 1] + dy])
		_poly(pts, BRICK.darkened(0.2) if k < 5 else BRICK)
	var top := []
	for j in range(0, outer.size(), 2):
		top.append_array([outer[j], outer[j + 1] + wall])
	_pl(top + [top[0], top[1]], Color("c8735a"), 0.3)
	# the grassy yard inside the walls
	var yard := _star_pts(cx, cy + wall + 0.2, 10.0, 5.8, 5, 0.26, PI * 0.5)
	_poly(yard, GRASS.lightened(0.08))
	# the barracks: little whitewashed houses with red roofs and porches
	for b in [[-8.5, 5.4, 4.5], [-2.5, 6.6, 4.0], [3.0, 5.6, 4.5]]:
		var x0: float = b[0]
		var y0: float = b[1]
		var w: float = b[2]
		_r(x0, y0, x0 + w, y0 + 1.7, WHITE)
		_poly([x0 - 0.3, y0 + 1.7, x0 + w + 0.3, y0 + 1.7, x0 + w - 0.2, y0 + 2.5, x0 + 0.2, y0 + 2.5], BRICK.darkened(0.1))
		_windows(x0 + 0.2, x0 + w - 0.2, y0 + 0.6, y0 + 1.3, 4, WIN)
	# a black cannon on the front bastion
	_l(cx - 1.2, 3.0, cx + 1.3, 3.5, DARK, 0.45)
	_c(cx - 0.7, 2.75, 0.4, WOOD)
	# the flagpole and the giant flag
	_old_flag(cx + 0.6, 6.0, 15.5, 11.0, 6.4, 15, false)

# --- Erie -----------------------------------------------------------------------------------------------------

## Presque Isle Lighthouse: the square white tower with its black lantern joined to the brick keeper's house,
## standing in the dunes and beach grass of the sandy peninsula, Lake Erie's waves rolling in.
static func _presque_isle_lighthouse() -> void:
	_r(-12, 0, 12, 5.2, WATER)
	if _detail(1.0):
		for p in [[-11.5, 2.4], [-10, 4.0], [3, 4.6]]:
			_r(p[0], p[1], p[0] + 2.5, p[1] + 0.2, WATER_L)
	# the sandy spit: a low beach on the left rising to the dunes
	_poly([-12, 0, -12, 1.2, -9, 1.7, -7.5, 3.6, -6, 4.4, 12, 4.6, 12, 0], SAND)
	_pl([-12, 1.2, -9, 1.7, -7.5, 3.6, -6, 4.4], Color.WHITE, 0.3)
	_poly([-12, 0, -12, 0.6, -4, 1.2, 4, 1.0, 12, 1.8, 12, 0], SAND.darkened(0.08))
	_poly([-7, 4.0, -5, 5.6, -1, 5.0, 3, 5.8, 7, 5.2, 12, 6.0, 12, 4.0], SAND.lightened(0.05))
	if _detail(0.9):
		for x in [-6.6, 6.5, 8.0, 10.5, -1.0, 2.0]:
			for d in [-0.3, 0.0, 0.3]:
				_l(x, 3.5, x + d * 1.5, 5.0, Color("8a9a4a"), 0.12)
	# the keeper's house: red brick, two storeys, gable roof
	var hx0 := -6.0
	var hx1 := 1.5
	_r(hx0, 4.0, hx1, 11.0, BRICK)
	_poly([hx0 - 0.5, 11, hx1 + 0.5, 11, (hx0 + hx1) * 0.5, 14], Color("5a4a44"))
	_r(hx0 + 1.0, 12.0, hx0 + 1.8, 14.2, BRICK.darkened(0.2))
	_windows(hx0 + 0.3, hx1 - 0.3, 8.0, 9.8, 3, WHITE)
	_windows(hx0 + 0.3, hx1 - 0.3, 5.0, 6.8, 3, WHITE)
	if _detail(1.2):
		_windows(hx0 + 0.45, hx1 - 0.15, 8.2, 9.6, 3, WIN)
		_windows(hx0 + 0.45, hx1 - 0.15, 5.2, 6.6, 3, WIN)
	# the square white tower
	var tx0 := 1.5
	var tx1 := 5.5
	_r(tx0, 4.0, tx1, 20.5, WHITE)
	_r(tx1 - 0.8, 4.0, tx1, 20.5, WHITE.darkened(0.12))
	_r(tx0 + 1.5, 9.0, tx0 + 2.3, 10.4, WIN)
	_r(tx0 + 1.5, 14.0, tx0 + 2.3, 15.4, WIN)
	_r(tx0 + 1.3, 4.0, tx0 + 2.5, 6.4, Color("5a4a44"))
	# the gallery, the lantern and its cap
	_r(tx0 - 0.6, 20.5, tx1 + 0.6, 21.1, DARK)
	if _detail(1.0):
		for k in 6:
			var x := tx0 - 0.5 + k * 1.0
			_l(x, 21.1, x, 22.0, DARK, 0.1)
	_l(tx0 - 0.6, 22.0, tx1 + 0.6, 22.0, DARK, 0.15)
	var lx := (tx0 + tx1) * 0.5
	_r(lx - 1.3, 21.1, lx + 1.3, 23.6, DARK)
	_r(lx - 0.95, 21.5, lx + 0.95, 23.3, Color("f6e27a"))
	_poly([lx - 1.6, 23.6, lx + 1.6, 23.6, lx, 25.2], DARK)
	_l(lx, 25.2, lx, 26.0, DARK, 0.12)
	# a bush and a fence in front
	_c(8.0, 4.2, 1.2, GRASS)
	_c(10.2, 4.0, 1.0, GRASS.darkened(0.1))

# --- Sandusky -------------------------------------------------------------------------------------------------

## Cedar Point: the giant red top-hat coaster shooting straight up and over by the lake, a white wooden coaster's
## lattice of hills in front of it, a blue steel hill with a train of cars on it, Lake Erie behind.
static func _cedar_point_coaster() -> void:
	_r(-30, 0, 30, 9, WATER_L)
	_r(-30, 0, 30, 6, WATER)
	_r(-30, 0, 30, 2.5, SAND)
	_r(-30, 0, 30, 0.8, GRASS)
	# the blue steel hill (one long, smooth camelback)
	var blue := Color("2f6fc0")
	var hill := []
	for k in 25:
		var t := float(k) / 24.0
		hill.append_array([lerpf(-28, 2, t), 3 + 26 * pow(sin(t * PI), 1.6)])
	if _detail(0.8):
		for j in range(4, hill.size() - 2, 6):
			_l(hill[j], 0, hill[j], hill[j + 1], Color("8aa0b8"), 0.25)
	_pl(hill, blue, 0.7)
	# a train of cars climbing it
	for k in 4:
		var t := 0.22 + k * 0.022
		var x := lerpf(-28, 2, t)
		var y := 3 + 26 * pow(sin(t * PI), 1.6)
		_c(x, y + 0.7, 0.75, Color("f2c230") if k % 2 == 0 else Color("d23b33"))
	# the red top hat: launch straight along the ground, up a tower, over the top and straight down
	var red := Color("d0282c")
	var yel := Color("f2c230")
	var hx := 16.0
	var ht := 38.0
	var hat := [-2, 2.4, 9, 2.4, 11.5, 3.5, 13.0, 7.0, hx - 1.6, 18] + _arc(hx, ht - 3.5, 3.0, 3.5, PI, 0, 10) + [
		hx + 1.6, 18, hx + 3.0, 7.0, hx + 4.5, 3.5, 30, 2.4]
	_pl(hat, yel, 0.9)
	_pl(hat, red, 0.45)
	# its white support tower
	for d in [-1.4, 1.4]:
		_l(hx + d, 0, hx + d * 0.6, ht - 4, Color("e4e4de"), 0.35)
	if _detail(1.0):
		for k in 8:
			var y := 2.0 + k * 4.2
			_l(hx - 1.3, y, hx + 1.3, y + 4.0, Color("e4e4de"), 0.12)
	# the white wooden coaster: a lattice of hills in front
	var wood := Color("f1ede2")
	var wpath := []
	for k in 31:
		var t := float(k) / 30.0
		var x := lerpf(-29, 29, t)
		var y := 4.0 + 7.0 * absf(sin(t * PI * 3.0)) * (1.0 - t * 0.4)
		wpath.append_array([x, y])
	if _detail(0.7):
		for j in range(0, wpath.size(), 2):
			_l(wpath[j], 0.8, wpath[j], wpath[j + 1], wood.darkened(0.12), 0.18)
		for j in range(0, wpath.size() - 2, 2):
			_l(wpath[j], 0.8, wpath[j + 2], wpath[j + 3], wood.darkened(0.2), 0.08)
	_pl(wpath, wood, 0.5)
	# a little carousel tent
	_r(-24, 0.8, -18, 3.2, Color("f4e6c8"))
	_poly([-24.6, 3.2, -17.4, 3.2, -21, 5.6], Color("d23b33"))
	_l(-21, 5.6, -21, 6.4, DARK, 0.1)

# --- Akron ----------------------------------------------------------------------------------------------------

## The Goodyear blimp: the silver airship with its blue-and-yellow band, fins and little gondola floating over
## Akron's low buildings and the huge rounded hangar of the airdock where airships were built.
static func _goodyear_blimp() -> void:
	# the airdock: a giant silver half-pill hangar
	var hang := Color("b8bec4")
	_poly(_arc(10, 0, 9.5, 8.5, 0, PI, 18), hang)
	_poly(_arc(10, 0, 9.5, 8.5, 0, PI * 0.5, 9) + [10, 0], hang.darkened(0.1))
	if _detail(1.0):
		for k in 5:
			var a := PI * (k + 1) / 6.0
			_l(10 + cos(a) * 9.5, sin(a) * 8.5, 10 + cos(a) * 9.5, 0, hang.darkened(0.2), 0.1)
	# the city: a row of low buildings and a few taller ones
	var cols := [Color("c9a68a"), Color("a7b0b8"), Color("d8c8a8"), Color("9a7a62"), Color("b8b0a0")]
	var bx := -20.0
	for k in 7:
		var w := 2.6 + (k % 3) * 0.6
		var h := 3.0 + float((k * 7) % 5) * 1.3
		var c: Color = cols[k % cols.size()]
		_r(bx, 0, bx + w, h, c)
		if _detail(1.5):
			_windows(bx + 0.2, bx + w - 0.2, h * 0.5, h * 0.8, 3, WIN)
		bx += w + 0.2
	_r(-20, 0, 20, 0.7, GRASS)
	# the blimp
	var bx0 := -1.0
	var by := 17.0
	var len := 14.0
	var rh := 4.2
	var silver := Color("d6dade")
	# tail fins
	_poly([bx0 - len + 2.5, by + 0.5, bx0 - len - 1.5, by + 4.5, bx0 - len - 1.0, by + 0.3], Color("3a5aa8"))
	_poly([bx0 - len + 2.5, by - 0.5, bx0 - len - 1.5, by - 4.5, bx0 - len - 1.0, by - 0.3], Color("3a5aa8"))
	_ell(bx0, by, len, rh, 0, silver)
	_ell(bx0 + 1, by + 1.2, len - 2, rh - 1.8, 0, silver.lightened(0.25))
	_poly([bx0 - len + 3, by - 0.4, bx0 - len - 2.2, by - 0.9, bx0 - len - 2.2, by + 0.9, bx0 - len + 3, by + 0.4], Color("3a5aa8"))
	# the band: blue with yellow lines, and a stylized winged foot
	_r(bx0 - 8.5, by - 1.4, bx0 + 9.5, by + 1.4, Color("1f3f8f"))
	_r(bx0 - 8.5, by + 1.4, bx0 + 9.5, by + 1.75, Color("f2c230"))
	_r(bx0 - 8.5, by - 1.75, bx0 + 9.5, by - 1.4, Color("f2c230"))
	if _detail(1.2):
		# GOODYEAR in yellow strokes
		var word := "GOODYEAR"
		for k in word.length():
			var x := bx0 - 7.7 + k * 2.15
			for st in _letter(word[k]):
				var pts := []
				for j in range(0, st.size(), 2):
					pts.append_array([x + st[j] * 1.3, by - 0.8 + st[j + 1] * 1.6])
				_pl(pts, Color("f2c230"), 0.28)
	# the gondola
	_poly([bx0 + 1.5, by - rh + 0.3, bx0 + 6.5, by - rh + 0.3, bx0 + 6.0, by - rh - 1.3, bx0 + 2.0, by - rh - 1.3], Color("e8eaec"))
	_r(bx0 + 2.6, by - rh - 0.9, bx0 + 5.6, by - rh - 0.2, GLASS)
	_c(bx0 + 4, by - rh - 1.6, 0.35, DARK)

## Strokes of one capital letter in a unit box (x right, y up), as polylines.
static func _letter(ch: String) -> Array:
	match ch:
		"G": return [_arc(0.5, 0.5, 0.5, 0.5, PI * 0.25, PI * 1.95, 12) + [0.55, 0.45]]
		"O": return [_arc(0.5, 0.5, 0.5, 0.5, 0, TAU, 14)]
		"D": return [[0, 0, 0, 1, 0.35, 1] + _arc(0.35, 0.5, 0.6, 0.5, PI * 0.5, -PI * 0.5, 8) + [0, 0]]
		"Y": return [[0, 1, 0.5, 0.5, 1, 1], [0.5, 0.5, 0.5, 0]]
		"E": return [[1, 1, 0, 1, 0, 0, 1, 0], [0, 0.5, 0.75, 0.5]]
		"A": return [[0, 0, 0.5, 1, 1, 0], [0.22, 0.4, 0.78, 0.4]]
		"R": return [[0, 0, 0, 1, 0.6, 1] + _arc(0.6, 0.75, 0.4, 0.25, PI * 0.5, -PI * 0.5, 6) + [0, 0.5, 1, 0]]
	return []

# --- Lancaster ------------------------------------------------------------------------------------------------

## An Amish horse and buggy on a Lancaster County farm road: the boxy dark buggy with its big thin wheels and
## orange slow-moving sign, a brown horse trotting, a red barn with a silo and a white farmhouse behind green fields.
static func _amish_buggy() -> void:
	_r(-15, 0, 15, 8, GRASS.lightened(0.05))
	for k in 3:
		_r(-15, 2.5 + k * 1.6, 15, 3.1 + k * 1.6, GRASS.darkened(0.06))
	# the barn: red with white trim and a gambrel roof, the silo by it
	var red := Color("a3302a")
	_r(-13, 4, -3, 10, red)
	_poly([-13.6, 10, -2.4, 10, -4, 12.8, -8, 14.2, -12, 12.8], Color("4a4440"))
	_r(-9.5, 4, -6.5, 8.5, red.darkened(0.25))
	_l(-9.5, 4, -6.5, 8.5, WHITE, 0.2)
	_l(-6.5, 4, -9.5, 8.5, WHITE, 0.2)
	_pl([-9.5, 4, -9.5, 8.5, -6.5, 8.5, -6.5, 4], WHITE, 0.2)
	_r(-8.6, 10.2, -7.4, 11.4, WHITE)
	_r(-2.7, 4, 0.0, 13.0, Color("b8b8b0"))
	_poly(_arc(-1.35, 13.0, 1.35, 1.2, 0, PI, 8), Color("7a8288"))
	if _detail(1.2):
		for k in 4:
			_l(-2.7, 5.5 + k * 2, 0.0, 5.5 + k * 2, Color("8e8e88"), 0.08)
	# the white farmhouse
	_r(3, 4, 9, 9.5, WHITE)
	_poly([2.6, 9.5, 9.4, 9.5, 6, 11.8], Color("4a4440"))
	_windows(3.3, 8.7, 7.0, 8.4, 3, WIN)
	_windows(3.3, 8.7, 4.8, 6.2, 3, WIN)
	_r(7.6, 10.2, 8.3, 11.6, BRICK)
	# the road
	_r(-15, 0, 15, 1.4, Color("6a6864"))
	_r(-15, 1.4, 15, 1.7, Color("a8a69e"))
	# the buggy: a tall dark box with a grey top, facing right
	var bx := 2.5
	var body := Color("2a2a2c")
	_r(bx - 3.2, 2.0, bx + 0.4, 5.6, body)
	_r(bx - 3.3, 5.6, bx + 0.5, 6.0, Color("5a5a5c"))
	_r(bx - 0.3, 3.2, bx + 0.2, 5.2, Color("444448"))
	_r(bx - 2.6, 3.6, bx - 0.8, 5.0, Color("4a4e54"))
	# the orange slow-moving triangle at the back
	_poly([bx - 3.2, 2.6, bx - 3.2, 4.0, bx - 3.9, 3.3], Color("f07a1a"))
	for wx in [bx - 2.4, bx - 0.1]:
		var wr := 1.0
		var wy := 0.7 + wr
		_pl(_arc(wx, wy, wr, wr, 0, TAU, 18), DARK, 0.16)
		_c(wx, wy, 0.15, DARK)
		if _detail(1.0):
			for sp in 6:
				var a := PI * sp / 6.0
				_l(wx - cos(a) * wr, wy - sin(a) * wr, wx + cos(a) * wr, wy + sin(a) * wr, Color("4a4a4e"), 0.05)
	# the shafts and the horse
	_l(bx + 0.4, 3.0, bx + 3.4, 3.6, WOOD, 0.12)
	var hx := bx + 4.6
	var horse := Color("6a3e24")
	_ell(hx, 3.6, 1.7, 0.85, 0, horse)
	_poly([hx + 1.1, 3.8, hx + 1.8, 4.1, hx + 2.6, 5.5, hx + 2.1, 5.8, hx + 1.2, 4.6], horse)
	_ell(hx + 2.7, 5.4, 0.7, 0.35, -0.5, horse)
	_poly([hx + 2.0, 5.8, hx + 2.2, 6.3, hx + 2.35, 5.75], horse)
	_l(hx - 1.6, 3.9, hx - 2.2, 2.6, DARK, 0.2)
	for lg in [[-1.2, -1.6], [-0.8, -0.5], [1.0, 1.5], [1.3, 0.8]]:
		_l(hx + lg[0], 3.0, hx + lg[1], 1.5, horse.darkened(0.2), 0.22)
	_l(hx + 1.6, 5.6, bx + 0.3, 4.4, DARK, 0.06)

# --- Valley Forge ---------------------------------------------------------------------------------------------

## Valley Forge in winter: Washington's army's log huts in the snow, smoke from their stone chimneys, bare
## trees, a cannon, and the old flag with a ring of 13 stars flying over the camp.
static func _valley_forge_huts() -> void:
	_r(-15, 0, 15, 4.5, SNOW)
	_poly([-15, 4.5, -15, 6.5, -8, 7.2, 0, 6.6, 8, 7.4, 15, 6.4, 15, 4.5], SNOW_S)
	for x in [-13.0, -11.0, 12.5]:
		_bare_tree(x, 5.5, 6.5, Color("5a4a3e"))
	var log := Color("7a5634")
	for h in [[-9.5, 3.0, 1.0], [-1.5, 1.2, 1.15], [6.5, 3.2, 0.95]]:
		var x0: float = h[0]
		var y0: float = h[1]
		var s: float = h[2]
		var w := 6.0 * s
		var hh := 3.0 * s
		_r(x0, y0, x0 + w, y0 + hh, log)
		if _detail(0.9):
			for k in 5:
				var y := y0 + hh * (k + 0.5) / 5.0
				_l(x0, y, x0 + w, y, log.darkened(0.3), 0.1)
			for k in 5:
				_c(x0, y0 + hh * (k + 0.5) / 5.0, hh * 0.1, log.lightened(0.25))
		# the door and the roof of planks with snow on it
		_r(x0 + w * 0.55, y0, x0 + w * 0.75, y0 + hh * 0.75, log.darkened(0.45))
		_poly([x0 - 0.4 * s, y0 + hh, x0 + w + 0.4 * s, y0 + hh, x0 + w * 0.5, y0 + hh + 2.0 * s], log.darkened(0.15))
		_poly([x0 - 0.4 * s, y0 + hh, x0 + w * 0.5, y0 + hh + 2.0 * s, x0 + w + 0.4 * s, y0 + hh,
			x0 + w * 0.5, y0 + hh + 1.5 * s], SNOW)
		# the stone chimney at the end, with smoke
		var cx := x0 + w * 0.12
		_r(cx - 0.45 * s, y0 + hh, cx + 0.45 * s, y0 + hh + 2.2 * s, Color("9a9488"))
		_c(cx + 0.2, y0 + hh + 3.0 * s, 0.6 * s, SMOKE)
		_c(cx + 0.7, y0 + hh + 3.9 * s, 0.75 * s, SMOKE)
		_c(cx + 1.4, y0 + hh + 4.9 * s, 0.9 * s, SMOKE)
		# snow banks at the foot
		_ell(x0 + w * 0.5, y0, w * 0.55, 0.35, 0, SNOW)
	# a cannon on its wooden carriage
	_l(-13.5, 1.2, -10.5, 1.9, DARK, 0.5)
	_poly([-13.5, 0.4, -11.2, 0.4, -11.5, 1.4, -13.2, 1.2], log.darkened(0.2))
	_c(-12.0, 0.7, 0.65, log.darkened(0.35))
	# the old flag
	_old_flag(12.0, 0.5, 12.5, 5.5, 3.4, 13, true)

# --- Wisconsin Dells ------------------------------------------------------------------------------------------

## The Wisconsin Dells: layered golden sandstone cliffs topped with pines on both banks of the Wisconsin River,
## a mushroom-shaped rock standing alone, and a duck boat (a boat on wheels) splashing along the river.
static func _dells_rocks() -> void:
	var stone := Color("d9b77a")
	var stone_d := Color("b8925a")
	_r(-20, 0, 20, 4, Color("2f6f88"))
	if _detail(1.0):
		for p in [[-15, 1.2], [-2, 2.6], [10, 0.7]]:
			_r(p[0], p[1], p[0] + 4, p[1] + 0.22, WATER_L)
	# the left cliff
	var lc := [-20, 2.5, -20, 15, -17, 15.5, -14, 14.8, -11, 15.2, -9, 13.5, -8.5, 9, -9.5, 5, -8.5, 2.5]
	_poly(lc, stone)
	_poly([-11, 15.2, -9, 13.5, -8.5, 9, -9.5, 5, -8.5, 2.5, -10.5, 2.5, -10.5, 6, -10, 11], stone_d)
	# the right cliff
	var rc := [20, 2.5, 20, 16, 17, 16.4, 14, 15.6, 11, 16, 9.5, 14, 10, 10, 9.2, 6, 10.5, 2.5]
	_poly(rc, stone)
	_poly([11, 16, 9.5, 14, 10, 10, 9.2, 6, 10.5, 2.5, 12, 2.5, 11.2, 7, 11.8, 12], stone_d)
	# the layers of sandstone
	if _detail(0.8):
		for k in 6:
			var y := 4.0 + k * 1.9
			_l(-20, y, -9.0 + sin(k) * 0.4, y + 0.2, stone_d, 0.18)
			_l(9.8 + sin(k) * 0.3, y + 0.3, 20, y, stone_d, 0.18)
	# pines along the tops
	for p in [[-19, 15.2, 4.0], [-16.5, 15.3, 5.0], [-13.5, 14.8, 4.2], [-11, 15, 3.5], [11.5, 15.8, 4.0],
			[14, 15.5, 5.2], [17, 16.2, 4.4], [19.4, 16, 3.6]]:
		_fir(p[0], p[1], p[2], PINE)
	# the standing rock: a narrow stem with a wide flat cap, out in the middle
	_poly([-2.5, 4, 0.5, 4, 0.2, 9, 1.2, 10.5, -3.6, 10.5, -2.7, 9], stone)
	_poly([-0.5, 4, 0.5, 4, 0.2, 9, 1.2, 10.5, -0.2, 10.5, -0.6, 9], stone_d)
	_poly([-3.8, 10.5, 1.4, 10.5, 1.0, 11.6, -3.4, 11.6], stone.lightened(0.1))
	_fir(-1.2, 11.6, 2.4, PINE)
	# the duck boat: a boat hull on big wheels with a canopy, half in the water
	var bx := 4.0
	var by := 0.6
	_poly([bx - 5, by + 0.6, bx + 4.4, by + 0.6, bx + 5.4, by + 2.2, bx - 5.2, by + 2.4], Color("f2efe4"))
	_r(bx - 5.1, by + 1.4, bx + 4.8, by + 1.75, Color("c8322c"))
	_r(bx - 4.6, by + 2.4, bx + 3.4, by + 2.7, Color("4e6b3a"))
	for x in [bx - 4.4, bx - 1.0, bx + 2.6]:
		_l(x, by + 2.7, x, by + 4.4, DARK, 0.12)
	_poly([bx - 4.9, by + 4.3, bx + 3.7, by + 4.3, bx + 3.3, by + 4.9, bx - 4.5, by + 4.9], Color("3d6b48"))
	if _detail(1.0):
		for k in 5:
			_c(bx - 3.8 + k * 1.5, by + 3.2, 0.35, Color("e2b48a"))
	_r(bx + 3.5, by + 2.2, bx + 4.6, by + 3.2, GLASS)
	_c(bx - 3.2, by + 0.6, 0.85, TYRE)
	_c(bx + 2.6, by + 0.6, 0.85, TYRE)
	_r(-20, 0, 20, by + 0.5, Color("2f6f88"))
	_l(bx + 4.5, by + 0.6, bx + 6.5, by + 0.4, Color.WHITE, 0.25)

# --- Springfield ----------------------------------------------------------------------------------------------

## Abraham Lincoln's home in Springfield: the two-storey brown house with green shutters and white trim behind
## its board fence and brick walk, and his famous tall black stovepipe hat standing big in front.
static func _lincoln_home() -> void:
	_r(-12, 0, 12, 2.0, GRASS)
	var wall := Color("a8865c")
	var trim := Color("f2ecdc")
	var shut := Color("3c5a3a")
	# the house
	_r(-8, 2.0, 8, 13.0, wall)
	_r(-8.3, 1.4, 8.3, 2.4, Color("8a4a36"))
	_r(-8.5, 13.0, 8.5, 13.8, trim)
	_poly([-8.8, 13.8, 8.8, 13.8, 6.0, 16.0, -6.0, 16.0], Color("4a4440"))
	_r(-6.5, 15.0, -5.4, 17.6, BRICK)
	_r(5.4, 15.0, 6.5, 17.6, BRICK)
	_l(-8, 2.4, -8, 13, trim, 0.3)
	_l(8, 2.4, 8, 13, trim, 0.3)
	# windows with green shutters, two rows
	for y in [4.0, 9.0]:
		for x in [-6.5, -3.4, 2.2, 5.3]:
			if y < 5 and x > -1 and x < 1:
				continue
			_r(x - 0.5, y, x + 1.5, y + 2.8, trim)
			_r(x - 0.3, y + 0.2, x + 1.3, y + 2.6, WIN)
			_r(x - 1.0, y, x - 0.5, y + 2.8, shut)
			_r(x + 1.5, y, x + 2.0, y + 2.8, shut)
	# the middle upstairs window and the front door with its little porch
	_r(-0.6, 9.0, 0.6, 11.8, trim)
	_r(-0.45, 9.2, 0.45, 11.6, WIN)
	_r(-1.0, 2.4, 1.0, 6.4, trim)
	_r(-0.7, 2.4, 0.7, 6.1, Color("5a3a26"))
	_r(-1.6, 6.4, 1.6, 6.9, trim)
	_r(-1.2, 2.0, 1.2, 2.4, Color("b8b0a0"))
	# the board fence along the brick walk
	var fence := Color("e8e2d2")
	_r(-12, 0.8, -2.0, 2.4, fence)
	_r(2.0, 0.8, 12, 2.4, fence)
	if _detail(1.0):
		for k in 20:
			var x := -12.0 + k * 1.25
			if absf(x + 0.3) < 2.4:
				continue
			_l(x, 0.8, x, 2.4, fence.darkened(0.15), 0.06)
	_r(-12, 0, 12, 0.8, Color("9a4a36"))
	# the tall stovepipe hat, big in front on a little stone block
	var hx := 9.4
	var hat := Color("1e1e22")
	_r(hx - 2.2, 0, hx + 2.2, 1.3, Color("b8b2a6"))
	_r(hx - 2.2, 1.1, hx + 2.2, 1.3, Color("d0cabe"))
	var hy := 1.3
	_ell(hx, hy + 0.5, 2.9, 0.6, 0, hat)
	_pl(_arc(hx, hy + 0.5, 2.9, 0.6, PI * 1.05, PI * 1.95, 8), Color("4a4a52"), 0.12)
	_poly([hx - 1.4, hy + 0.6, hx + 1.4, hy + 0.6, hx + 1.55, hy + 7.4, hx - 1.55, hy + 7.4], hat)
	_ell(hx, hy + 7.4, 1.55, 0.3, 0, Color("34343a"))
	_r(hx - 1.43, hy + 1.0, hx + 1.43, hy + 1.8, Color("50505a"))
	_l(hx - 0.9, hy + 2.2, hx - 1.0, hy + 7.0, Color("3a3a42"), 0.25)

# --- Des Moines -----------------------------------------------------------------------------------------------

## The Iowa State Fair's butter cow: a life-size cow sculpted from yellow butter on a butter base, inside its cold
## glass case with frosty corners and a steel frame.
static func _butter_cow() -> void:
	var frame := Color("8a9098")
	var inside := Color("d8eef6")
	var butter := Color("f2d36a")
	var but_d := Color("d9b44a")
	_r(-7, 0, 7, 9.6, frame)
	_r(-6.6, 0.4, 6.6, 9.2, inside)
	# shelves of ice-blue light at the back
	_r(-6.6, 8.2, 6.6, 9.2, Color("b8dcec"))
	# the butter base
	_r(-5.6, 0.4, 5.6, 1.6, but_d)
	_r(-5.6, 1.6, 5.6, 1.9, butter)
	# the cow facing left: body, legs, head with ears and horns, udder and tail
	var cy := 3.6
	for lx in [-2.9, -1.5, 2.2, 3.4]:
		var c := but_d if lx in [-2.9, 2.2] else butter
		_r(lx - 0.4, 1.9, lx + 0.4, cy + 0.6, c)
		_r(lx - 0.45, 1.9, lx + 0.45, 2.2, but_d.darkened(0.15))
	_r(-3.2, cy + 0.3, 3.9, cy + 2.4, butter)
	_ell(-2.9, cy + 1.35, 0.9, 1.05, 0, butter)
	_ell(3.7, cy + 1.4, 0.8, 1.1, 0, butter)
	_ell(0.4, cy + 0.35, 3.0, 0.35, 0, butter)
	_ell(0.6, cy + 2.0, 3.0, 0.3, 0, butter.lightened(0.25))
	_ell(2.6, cy + 0.0, 0.65, 0.4, 0, but_d)
	# the neck and the long head, nose down
	_poly([-2.6, cy + 2.4, -4.4, cy + 2.6, -4.6, cy + 1.6, -3.0, cy + 0.6], butter)
	_poly([-4.1, cy + 2.9, -5.0, cy + 2.8, -5.9, cy + 1.0, -5.5, cy + 0.6, -4.8, cy + 0.8, -3.9, cy + 2.0], butter)
	_ell(-5.55, cy + 0.85, 0.6, 0.45, -0.5, but_d)
	_poly([-4.0, cy + 2.6, -3.0, cy + 2.9, -3.3, cy + 2.4], but_d)
	_poly([-4.6, cy + 2.85, -4.4, cy + 3.5, -4.2, cy + 2.85], but_d.lightened(0.15))
	_c(-4.7, cy + 2.1, 0.15, but_d.darkened(0.45))
	# the tail with its tuft
	_l(4.4, cy + 2.0, 4.9, cy + 0.1, but_d, 0.18)
	_c(4.95, cy - 0.1, 0.3, but_d)
	# the glass: a light sheen and frost in the corners
	_poly([-6.6, 9.2, -3.6, 9.2, -6.6, 6.2], Color(1, 1, 1, 0.55))
	_poly([6.6, 0.4, 3.8, 0.4, 6.6, 3.0], Color(1, 1, 1, 0.5))
	_l(-4.5, 1.0, -1.5, 8.6, Color(1, 1, 1, 0.35), 0.4)
	_l(-3.2, 1.0, -0.4, 8.6, Color(1, 1, 1, 0.25), 0.18)
	_r(-0.1, 0.4, 0.1, 9.2, frame.lightened(0.2))
	# the sign on top
	_r(-3.5, 9.6, 3.5, 10.0, frame.darkened(0.2))

# --- Charlotte ------------------------------------------------------------------------------------------------

## A NASCAR stock car at speed on the steep banking of the Charlotte speedway: the bright car with its big
## number on the door, the white wall and catch fence, and the packed grandstand under a checkered flag.
static func _nascar_car() -> void:
	# the grandstand with a crowd
	_r(-12, 8.2, 12, 14.0, Color("8a9098"))
	if _detail(0.9):
		var cc := [Color("d23b33"), Color("f2c230"), Color("2f6fc0"), Color("f4f2ea"), Color("49a85a")]
		for r in 4:
			for k in 32:
				var x := -11.6 + k * 0.75 + (r % 2) * 0.35
				_c(x, 9.0 + r * 1.25, 0.3, cc[(k * 3 + r * 7) % cc.size()])
	_r(-12.3, 14.0, 12.3, 14.5, Color("5a6068"))
	# the catch fence and the wall
	if _detail(0.9):
		for k in 25:
			_l(-12 + k, 6.2, -12 + k, 8.2, Color("6a6e74"), 0.06)
	_l(-12, 8.2, 12, 8.2, Color("6a6e74"), 0.12)
	_r(-12, 5.0, 12, 6.2, Color("f4f2ea"))
	_r(-12, 5.3, 12, 5.55, Color("2f6fc0"))
	# the steep banked track, grey with a yellow line at the bottom
	_r(-12, 0, 12, 5.0, Color("6a6864"))
	_r(-12, 0, 12, 0.6, Color("8a9a6a"))
	_l(-12, 0.75, 12, 0.75, Color("f2c230"), 0.15)
	if _detail(1.0):
		_l(-12, 3.2, 12, 4.0, Color("7a7874"), 0.8)
	# the car, facing right: long low body, the cabin, the spoiler at the back
	var body := Color("1f5fc8")
	var cx := -0.5
	var y := 1.0
	var gl := Color("9fc4dc")
	_poly([cx - 5.2, y + 0.3, cx + 5.0, y + 0.3, cx + 5.3, y + 1.2, cx + 4.6, y + 1.7, cx + 1.4, y + 1.95,
		cx - 0.2, y + 3.1, cx - 3.0, y + 3.1, cx - 4.3, y + 2.1, cx - 5.4, y + 2.1], body)
	_poly([cx - 0.5, y + 2.95, cx + 1.1, y + 2.0, cx - 0.5, y + 2.0], gl)
	_r(cx - 2.8, y + 2.15, cx - 0.8, y + 2.9, gl)
	_l(cx - 2.8, y + 2.15, cx - 0.8, y + 2.9, DARK, 0.12)
	_r(cx - 5.6, y + 2.1, cx - 4.6, y + 2.45, DARK)
	# a yellow stripe and the number on a white roundel
	_poly([cx - 5.2, y + 0.85, cx + 5.1, y + 0.85, cx + 5.2, y + 1.15, cx - 5.3, y + 1.15], Color("f2c230"))
	_ell(cx - 1.6, y + 1.35, 1.25, 0.9, 0, WHITE)
	_digit(4, cx - 2.35, y + 0.85, 0.5, 1.0, DARK, 0.18)
	_digit(2, cx - 1.45, y + 0.85, 0.5, 1.0, DARK, 0.18)
	if _detail(1.3):
		_r(cx + 1.6, y + 1.3, cx + 3.6, y + 1.65, Color("d23b33"))
		_r(cx - 4.6, y + 1.3, cx - 3.2, y + 1.65, Color("f4f2ea"))
	_r(cx + 4.9, y + 1.25, cx + 5.3, y + 1.5, Color("fff2b0"))
	for wx in [cx - 3.4, cx + 3.2]:
		_c(wx, y + 0.45, 0.8, TYRE)
		_c(wx, y + 0.45, 0.42, Color("d8b14a"))
		_c(wx, y + 0.45, 0.12, DARK)
	# speed lines behind
	for k in 3:
		_l(cx - 9.5 + k * 0.7, y + 0.8 + k * 0.8, cx - 6.2, y + 0.8 + k * 0.8, Color(1, 1, 1, 0.65), 0.15)
	# the checkered flag on a pole
	var fx := 7.6
	_l(fx, 5.5, fx, 13.5, Color("d8d8d8"), 0.18)
	for r in 3:
		for c in 4:
			var x0 := fx + c * 0.9
			var y0 := 10.8 + r * 0.9 + sin(c * 1.3) * 0.25
			var y1 := 10.8 + r * 0.9 + sin((c + 1) * 1.3) * 0.25
			_poly([x0, y0, x0 + 0.9, y1, x0 + 0.9, y1 + 0.9, x0, y0 + 0.9], DARK if (r + c) % 2 == 0 else WHITE)


# --- Chattanooga ----------------------------------------------------------------------------------------------

## The Lookout Mountain Incline Railway: the steepest passenger railway, a yellow car with stepped windows on a
## trestle track climbing straight up the green wooded mountainside to the station at the top.
static func _incline_railway() -> void:
	var a := deg_to_rad(38.0)
	var sl := tan(a)
	# the mountain
	var hill := Color("5f8a46")
	_poly([-20, 0, -20, 4, -12, 8, -8, 9, 18, 29, 20, 30, 20, 0], hill)
	_poly([-20, 0, -20, 2, 20, 2, 20, 0], hill.darkened(0.1))
	if _detail(0.7):
		for p in [[-17, 3, 4.0], [-11, 6, 3.6], [0, 5, 4.5], [4, 10, 4.0], [8, 6, 3.4], [12, 15, 4.2], [15, 9, 3.8],
				[17, 21, 4.0], [-4, 2, 3.2], [9, 1, 3.2], [-1, 12, 3.4]]:
			_c(p[0], p[1] + p[2] * 0.5, p[2] * 0.5, Color("3f6f34"))
			_c(p[0] + 0.6, p[1] + p[2] * 0.6, p[2] * 0.35, Color("4f8040"))
	# the track: two rails on a trestle, from (-14, 1) up to the top station
	var x0 := -14.0
	var y0 := 1.5
	var x1 := 13.0
	var y1 := y0 + (x1 - x0) * sl * 0.95
	var dx := x1 - x0
	var dy := y1 - y0
	if _detail(0.8):
		for k in 14:
			var t := float(k) / 13.0
			var px := x0 + dx * t
			var py := y0 + dy * t
			var gy := minf(py, 2.0 + maxf(0, (px + 8) * 1.0))
			_l(px, py - 0.4, px, gy, WOOD.darkened(0.15), 0.18)
	_l(x0, y0, x1, y1, WOOD, 1.3)
	_l(x0, y0 + 0.55, x1, y1 + 0.55, Color("c8c8c0"), 0.22)
	# the top station: a stone house with a dark roof, sitting on the ridge
	_r(x1 - 1.5, y1 - 1.0, x1 + 6.5, y1 + 4.5, Color("c9b89a"))
	_poly([x1 - 2.0, y1 + 4.5, x1 + 7.0, y1 + 4.5, x1 + 2.5, y1 + 7.0], Color("6a3a2c"))
	_r(x1 - 1.5, y1 - 1.0, x1 + 0.5, y1 + 3.0, DARK)
	_windows(x1 + 1.0, x1 + 6.2, y1 + 1.5, y1 + 3.2, 3, WIN)
	# the bottom station
	_r(x0 - 5.5, 0, x0 + 1.0, 4.0, Color("c9b89a"))
	_poly([x0 - 6.0, 4.0, x0 + 1.5, 4.0, x0 - 2.25, 6.0], Color("6a3a2c"))
	_r(x0 - 0.5, 0, x0 + 1.0, 3.2, DARK)
	# the car, on the track part way up: a parallelogram with vertical ends and a stepped roof
	var t0 := 0.4
	var cx := x0 + dx * t0
	var cy := y0 + dy * t0 + 0.4
	var cl := 9.5
	var hw := cl * 0.5
	var ax := cx - hw * cos(a)
	var ay := cy - hw * sin(a)
	var bx := cx + hw * cos(a)
	var by := cy + hw * sin(a)
	var hh := 4.4
	var yel := Color("e8b830")
	var red := Color("a8302a")
	_poly([ax, ay, bx, by, bx, by + hh, ax, ay + hh], yel)
	_poly([ax, ay, bx, by, bx, by + 0.6, ax, ay + 0.6], red)
	# windows: one per step, level boxes stepping up
	var n := 4
	for k in n:
		var t := (k + 0.5) / n
		var wx := lerpf(ax, bx, t)
		var wy := lerpf(ay, by, t)
		var ww := (bx - ax) / n * 0.36
		_r(wx - ww, wy + 1.4, wx + ww, wy + 3.3, GLASS)
	_poly([ax - 0.3, ay + hh, bx + 0.3, by + hh, bx + 0.3, by + hh + 0.4, ax - 0.3, ay + hh + 0.4], red)
	if _detail(1.0):
		_c(ax + 0.3, ay + 0.1, 0.3, DARK)
		_c(bx - 0.3, by + 0.1, 0.3, DARK)
		_r(bx - 0.35, by + 2.0, bx, by + 2.5, Color("fff2b0"))
