class_name LandmarksUsT4
extends RefCounted
## American town landmarks (4): the desert Southwest, the Great Basin, the Rockies and the Pacific Northwest,
## drawn with LandmarkPainter's helpers (metres from the base point, y up).

const WHITE := Color("f4f2ea")
const WATER := Color("3f7fb5")
const WATER_L := Color("9cc8e6")
const SAND := Color("e2c993")
const GRASS := Color("6f9a48")
const PINE := Color("2f5a36")
const WOOD := Color("7a5634")
const DARK := Color("2e3238")
const WIN := Color("3a4048")
const SNOW := Color("f4f7fa")
const SNOW_S := Color("c9d6e4")
const RED := Color("c8282c")
const FOAM := Color("f2f8fa")
const SPRAY := Color("cfe6ee")
const MIST := Color(1, 1, 1, 0.6)
const SKIN := Color("e6c2a0")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"wind_farm": _wind_farm()
		"giant_thermometer": _giant_thermometer()
		"zion_canyon": _zion_canyon()
		"cheyenne_frontier_boots": _cheyenne_boots()
		"reno_arch": _reno_arch()
		"salt_flats_racer": _salt_flats_racer()
		"mount_shasta": _mount_shasta()
		"shoshone_falls": _shoshone_falls()
		"multnomah_falls": _multnomah_falls()
		"snoqualmie_falls": _snoqualmie_falls()
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

## Strokes of one capital letter or digit in a unit box (x right, y up), as polylines.
static func _letter(ch: String) -> Array:
	match ch:
		"R": return [[0, 0, 0, 1, 0.7, 1, 0.95, 0.85, 0.95, 0.65, 0.7, 0.5, 0, 0.5], [0.45, 0.5, 1, 0]]
		"E": return [[1, 1, 0, 1, 0, 0, 1, 0], [0, 0.5, 0.75, 0.5]]
		"N": return [[0, 0, 0, 1, 1, 0, 1, 1]]
		"O": return [_arc(0.5, 0.5, 0.5, 0.5, 0, TAU, 12)]
		"T": return [[0, 1, 1, 1], [0.5, 1, 0.5, 0]]
		"H": return [[0, 0, 0, 1], [1, 0, 1, 1], [0, 0.5, 1, 0.5]]
		"B": return [[0, 0, 0, 1, 0.7, 1, 0.9, 0.85, 0.9, 0.65, 0.7, 0.5, 0, 0.5], [0.7, 0.5, 1, 0.35, 1, 0.15, 0.75, 0, 0, 0]]
		"I": return [[0.5, 0, 0.5, 1]]
		"G": return [[1, 0.85, 0.7, 1, 0.3, 1, 0, 0.75, 0, 0.25, 0.3, 0, 0.7, 0, 1, 0.25, 1, 0.5, 0.55, 0.5]]
		"S": return [[1, 0.9, 0.7, 1, 0.3, 1, 0, 0.8, 0.1, 0.55, 0.9, 0.45, 1, 0.2, 0.7, 0, 0.3, 0, 0, 0.1]]
		"L": return [[0, 1, 0, 0, 0.9, 0]]
		"C": return [[1, 0.85, 0.7, 1, 0.3, 1, 0, 0.75, 0, 0.25, 0.3, 0, 0.7, 0, 1, 0.15]]
		"Y": return [[0, 1, 0.5, 0.5, 1, 1], [0.5, 0.5, 0.5, 0]]
		"W": return [[0, 1, 0.25, 0, 0.5, 0.65, 0.75, 0, 1, 1]]
		"D": return [[0, 0, 0, 1, 0.55, 1, 0.9, 0.8, 1, 0.5, 0.9, 0.2, 0.55, 0, 0, 0]]
		"1": return [[0.25, 0.8, 0.6, 1, 0.6, 0]]
		"2": return [[0, 0.8, 0.3, 1, 0.7, 1, 1, 0.8, 1, 0.6, 0, 0, 1, 0]]
		"0": return [_arc(0.5, 0.5, 0.5, 0.5, 0, TAU, 12)]
		"F": return [[0, 0, 0, 1, 1, 1], [0, 0.5, 0.75, 0.5]]
	return []

## A line of text in stroke letters `lw` wide and `lh` tall, centred on x, its baseline at y. When the picture is
## too small for strokes, each letter is a little block.
static func _text(s: String, x: float, y: float, lw: float, lh: float, col: Color, w: float) -> void:
	var step := lw * 1.4
	var x0 := x - (s.length() * step - lw * 0.4) * 0.5
	for k in s.length():
		var lx := x0 + k * step
		if s[k] == " ":
			continue
		if lh * LandmarkPainter._pm < 5.0:
			_r(lx, y + lh * 0.15, lx + lw, y + lh * 0.85, Color(col, 0.75))
			continue
		for st in _letter(s[k]):
			var pts := []
			for j in range(0, st.size(), 2):
				pts.append_array([lx + st[j] * lw, y + st[j + 1] * lh])
			_pl(pts, col, w)

## A falling curtain of water from (x0..x1, y1) down to y0, widening by `spread` each side, with streaks.
static func _fall(x0: float, x1: float, y0: float, y1: float, spread: float) -> void:
	_poly([x0, y1, x1, y1, x1 + spread, y0, x0 - spread, y0], SPRAY)
	_poly([x0 + 0.3, y1, x1 - 0.3, y1, x1 + spread * 0.6, y0, x0 - spread * 0.6, y0], FOAM)
	if _detail(0.8):
		var m := maxi(2, int((x1 - x0) / 1.4))
		for k in m:
			var t := (k + 0.5) / m
			var xa := lerpf(x0, x1, t)
			var xb := lerpf(x0 - spread * 0.6, x1 + spread * 0.6, t)
			_l(xa, y1 - 0.3, xb, y0 + (y1 - y0) * 0.1, SPRAY.darkened(0.06), 0.16)

# --- Palm Springs ---------------------------------------------------------------------------------------------

## One wind turbine at (x, y), `h` to the hub: a slim white tower, the nacelle and three long blades turned by `a`.
static func _turbine(x: float, y: float, h: float, a: float) -> void:
	var col := Color("f6f6f2")
	var sh := Color("cfd2d4")
	_poly([x - h * 0.03, y, x + h * 0.03, y, x + h * 0.012, y + h, x - h * 0.012, y + h], col)
	_poly([x + h * 0.005, y, x + h * 0.03, y, x + h * 0.012, y + h, x + h * 0.004, y + h], sh)
	_r(x - h * 0.04, y + h - h * 0.025, x + h * 0.07, y + h + h * 0.03, col)
	var bl := h * 0.62
	for k in 3:
		var b := a + TAU * k / 3.0
		var tip := Vector2(cos(b), sin(b)) * bl
		var side := Vector2(-sin(b), cos(b)) * h * 0.035
		_poly([x + side.x, y + h + side.y, x + tip.x, y + h + tip.y, x - side.x * 0.3, y + h - side.y * 0.3], col)
	_c(x, y + h, h * 0.035, sh)

## The San Gorgonio Pass wind farm by Palm Springs: rows upon rows of white wind turbines standing in the pale
## desert, the bare brown San Jacinto mountains with a cap of snow behind, sagebrush and a palm or two in front.
static func _wind_farm() -> void:
	# the mountains behind
	_poly([-40, 6, -40, 14, -32, 18, -24, 22, -16, 25, -10, 27, -5, 26, 0, 24.5, 6, 22, 14, 19.5, 22, 17, 30, 15, 40, 12, 40, 6],
			Color("a08670"))
	_poly([-40, 6, -40, 11, -30, 13.5, -20, 16, -12, 17, -2, 16, 8, 15, 20, 13, 32, 11, 40, 10, 40, 6], Color("8a705c"))
	_poly([-16, 25, -10, 27, -5, 26, -2, 24.8, -6, 24, -9, 25.2, -13, 24.2], SNOW)
	if _detail(0.8): # gullies down the slopes
		for g in [[-26, 21, -22, 14], [-14, 25, -12, 17], [-4, 25.5, -3, 17], [8, 21, 10, 15], [20, 17.5, 22, 13]]:
			_l(g[0], g[1], g[2], g[3], Color("7a6250"), 0.35)
	# the desert floor
	_poly([-40, 0, -40, 9, -20, 8, 0, 9, 20, 8, 40, 9, 40, 0], SAND)
	_poly([-40, 0, -40, 4, 0, 3.5, 40, 4, 40, 0], Color("d6b97e"))
	# the rows of turbines, small and far away behind, big in front, blades at different angles
	var rows := [[8.4, 5.0, 6.0, -38.0], [6.4, 9.0, 11.0, -35.0], [1.5, 19.0, 26.0, -26.0]]
	var idx := 0
	for row in rows:
		var y: float = row[0]
		var h: float = row[1]
		var gap: float = row[2]
		var x: float = row[3] + (idx % 2) * gap * 0.4
		while x < 40.0 - h * 0.5:
			_turbine(x, y, h, 0.4 + idx * 0.73)
			idx += 1
			x += gap
	# sagebrush and a palm in front
	if _detail(0.8):
		for p in [[-35, 1.2], [-22, 0.8], [-8, 1.4], [10, 0.9], [24, 1.3], [35, 0.8]]:
			_ell(p[0], p[1], 1.4, 0.8, 0, Color("8f9a68"))
			_ell(p[0] + 0.6, p[1] + 0.3, 0.9, 0.5, 0, Color("a6ae7a"))
	var px := 34.0
	_l(px, 0, px + 0.6, 10, Color("8a6a48"), 0.6)
	for a in [0.3, 0.9, 1.6, 2.3, 2.9, -0.2]:
		_pl([px + 0.6, 10, px + 0.6 + cos(a) * 2.6, 10 + sin(a) * 1.4, px + 0.6 + cos(a) * 4.2, 10 + sin(a) * 0.4 - 1.2],
				Color("4f7a3a"), 0.5)

# --- Baker ------------------------------------------------------------------------------------------------------

## The world's tallest thermometer in Baker: a slim white tower 134 feet tall (one foot for the hottest day ever
## measured in nearby Death Valley), its red "mercury" up the middle, the big glowing red numbers near the top and
## a little diner and Joshua trees in the desert at its foot.
static func _giant_thermometer() -> void:
	# desert ground with the far mountains
	_poly([-12, 0, -12, 4, -6, 6, -2, 5, 3, 7, 8, 5.5, 12, 6.5, 12, 0], Color("b49276"))
	_r(-12, 0, 12, 2.2, SAND)
	# the tower: white, a little narrower at the top, a lit edge
	var w0 := 1.9
	var w1 := 1.5
	var top := 40.0
	_poly([-w0, 0, w0, 0, w1, top, -w1, top], WHITE)
	_poly([w0 * 0.45, 0, w0, 0, w1, top, w1 * 0.45, top], Color("d8d6d0"))
	# the red column of mercury up the middle, from a round bulb at the bottom
	_r(-0.45, 4.5, 0.45, 30, Color("e8e2da"))
	_r(-0.32, 4.5, 0.32, 27.5, RED)
	_c(0, 4.2, 1.1, RED)
	if _detail(1.5): # degree ticks
		for k in 12:
			var y := 7.0 + k * 2.0
			_l(-1.1, y, -0.6, y, DARK, 0.1)
			_l(0.6, y, 1.1, y, DARK, 0.1)
	# the sign box near the top with the temperature in big red numbers
	_r(-w1 - 0.5, 30.5, w1 + 0.5, 38.5, DARK)
	_r(-w1 - 0.5, 30.5, w1 + 0.5, 31.0, Color("1c1e22"))
	var d := Color("ff3a2a")
	if _detail(2.0):
		_text("120", 0, 33.2, 0.75, 2.4, d, 0.22)
	else:
		_r(-1.4, 33.2, 1.4, 35.6, d)
	_c(1.5, 35.4, 0.22, d)
	_r(-w1, top, w1, top + 0.8, Color("d8d6d0"))
	_poly([-w1 - 0.3, top + 0.8, w1 + 0.3, top + 0.8, 0, top + 2.0], RED)
	# the little diner at the foot
	_r(3.2, 0, 10, 3.2, Color("e8dcc0"))
	_r(3.0, 3.2, 10.2, 3.8, RED)
	_windows(3.6, 9.6, 1.0, 2.4, 3, WIN)
	# Joshua trees
	for p in [[-8.0, 1.0], [-5.0, 0.8], [11.0, 0.9]]:
		var x: float = p[0]
		var s: float = p[1]
		var bark := Color("6e5a44")
		_l(x, 0, x, 3.2 * s, bark, 0.35)
		_l(x, 2.4 * s, x - 1.1 * s, 3.6 * s, bark, 0.28)
		_l(x, 2.8 * s, x + 1.0 * s, 4.0 * s, bark, 0.28)
		for t in [[x - 1.1 * s, 3.6 * s], [x + 1.0 * s, 4.0 * s], [x, 3.2 * s]]:
			_c(t[0], t[1] + 0.2, 0.45 * s, Color("5c7a3c"))

# --- St. George -------------------------------------------------------------------------------------------------

## Zion Canyon: towering sandstone walls, deep red at the bottom and pale cream on top, rising straight up on
## both sides of the green valley floor where the Virgin River winds between cottonwoods.
static func _zion_canyon() -> void:
	var red := Color("b5522e")
	var red_d := Color("8a3a22")
	var cream := Color("ecd8b4")
	var cream_d := Color("cfb48c")
	# the far wall at the end of the canyon, hazy
	_poly([-20, 14, -14, 34, -8, 38, -2, 37, 4, 39, 10, 36, 16, 31, 22, 14], Color("c9a088"))
	_poly([-14, 32, -8, 38, -2, 37, 4, 39, 10, 36, 13, 33, 6, 31, -6, 32], Color("e8d8c4"))
	# the left wall: a huge rounded dome of cream rock on top of a red cliff
	_poly([-40, 0, -40, 48, -34, 50, -28, 48.5, -23, 44, -19, 36, -17, 26, -15, 14, -12, 6, -12, 0], red)
	_poly([-40, 30, -40, 48, -34, 50, -28, 48.5, -23, 44, -19, 36, -18.5, 30], cream)
	_poly([-26, 30, -23, 44, -19, 36, -18.5, 30], cream_d)
	_poly([-18, 30, -17, 26, -15, 14, -12, 6, -12, 0, -16, 0, -17, 14, -18.6, 26], red_d)
	# the right wall: the tall cliff of the Great White Throne side, squarer
	_poly([40, 0, 40, 46, 36, 47, 30, 46, 25, 42, 21, 34, 19, 24, 16, 12, 13, 5, 13, 0], red)
	_poly([40, 28, 40, 46, 36, 47, 30, 46, 25, 42, 21, 34, 20.3, 28], cream)
	_poly([20.3, 28, 21, 34, 25, 42, 26, 36, 24, 28], Color(1, 1, 1, 0.25))
	_poly([13, 0, 13, 5, 16, 12, 19, 24, 20.3, 28, 22.5, 28, 20, 18, 17, 6, 16, 0], red_d.lightened(0.08))
	# layers and vertical streaks (desert varnish) on the faces
	if _detail(0.6):
		for y in [17.0]:
			_l(-40, y, -17.2, y, red_d, 0.35)
			_l(18.5, y, 40, y, red_d, 0.35)
		for y in [35.0, 40.0, 45.0]:
			_l(-40, y, -22 - (y - 35) * 0.5, y, cream_d, 0.3)
			_l(22 + (y - 34) * 0.6, y, 40, y, cream_d, 0.3)
	if _detail(0.9):
		for v in [[-37.0, 12.0], [-31.0, 20.0], [-24.0, 9.0], [25.0, 16.0], [31.0, 8.0], [36.0, 22.0]]:
			_l(v[0], 29, v[0] + 0.4, v[1], red_d, 0.6)
	# a few pines clinging on top of the walls
	for p in [[-36.0, 49.6], [-31.0, 49.5], [33.0, 46.8], [37.5, 46.8]]:
		_fir(p[0], p[1] - 0.4, 2.4, PINE)
	# the valley floor: green meadow and cottonwoods, the river winding towards us
	_poly([-14, 0, -12, 6, -6, 10, 0, 13, 6, 12, 12, 6, 14, 0], Color("7fa04e"))
	_poly([-2, 13, 1, 13, 4, 10, 1, 7, 5, 4, 2, 0, -5, 0, -2, 4, -4, 7, -1, 10], WATER)
	if _detail(1.0):
		_l(-1, 10, 1, 7, WATER_L, 0.25)
		_l(-2, 3, 2, 1, WATER_L, 0.25)
	for t in [[-10, 2.5, 2.2], [-7.5, 7.5, 1.6], [8, 8, 1.6], [9.5, 2, 2.4], [5.5, 11, 1.1], [-4, 11.5, 1.1]]:
		_r(t[0] - 0.2, t[1] - t[2], t[0] + 0.2, t[1], WOOD)
		_c(t[0], t[1], t[2], Color("4f8a3a"))
		_c(t[0] - t[2] * 0.3, t[1] + t[2] * 0.3, t[2] * 0.55, Color("74a84e"))

# --- Cheyenne ---------------------------------------------------------------------------------------------------

## One of Cheyenne's "Big Boots": a giant cowboy boot statue taller than a man, painted all over with a bright
## picture (blue sky, mountains and a sun), standing on a little plinth.
static func _big_boot(x: float, s: float) -> void:
	var y := 0.6 * s
	_r(x - 1.6 * s, 0, x + 2.2 * s, y, Color("b8b2a6"))
	# the boot: shaft on the left, the foot pointing right to a pointy toe, the heel at the back
	var shaft := [x - 1.1 * s, y + 1.0 * s, x - 1.25 * s, y + 4.6 * s, x - 0.75 * s, y + 4.4 * s, x - 0.2 * s, y + 4.7 * s,
		x + 0.55 * s, y + 4.5 * s, x + 0.5 * s, y + 1.6 * s]
	var foot := [x - 1.1 * s, y + 0.3 * s, x - 1.1 * s, y + 1.6 * s, x + 0.5 * s, y + 1.7 * s, x + 1.3 * s, y + 1.3 * s,
		x + 2.0 * s, y + 0.6 * s, x + 2.0 * s, y + 0.3 * s]
	_poly(shaft, Color("3a8fd0"))
	_poly(foot, Color("3a8fd0"))
	# painted: mountains on the shaft, a yellow sun, a green prairie on the foot, a red flower
	_poly([x - 1.15 * s, y + 2.0 * s, x - 0.6 * s, y + 3.1 * s, x - 0.2 * s, y + 2.5 * s, x + 0.2 * s, y + 3.3 * s,
		x + 0.52 * s, y + 2.6 * s, x + 0.5 * s, y + 1.6 * s, x - 1.1 * s, y + 1.5 * s], Color("7a6aa8"))
	_poly([x - 0.6 * s, y + 3.1 * s, x - 0.4 * s, y + 2.8 * s, x - 0.8 * s, y + 2.75 * s], SNOW)
	_c(x - 0.1 * s, y + 3.9 * s, 0.3 * s, Color("f6d23a"))
	_poly([x - 1.1 * s, y + 0.3 * s, x - 1.1 * s, y + 1.5 * s, x + 0.5 * s, y + 1.6 * s, x + 1.3 * s, y + 1.2 * s,
		x + 2.0 * s, y + 0.55 * s, x + 2.0 * s, y + 0.3 * s], Color("5aa84a"))
	_c(x + 0.6 * s, y + 0.95 * s, 0.18 * s, Color("e8483a"))
	_c(x - 0.5 * s, y + 0.8 * s, 0.15 * s, Color("f6d23a"))
	# the heel, the sole and the stitched top band
	_r(x - 1.1 * s, y, x - 0.4 * s, y + 0.35 * s, Color("5a3a22"))
	_r(x - 0.4 * s, y + 0.2 * s, x + 2.0 * s, y + 0.32 * s, Color("5a3a22"))
	_pl([x - 1.25 * s, y + 4.6 * s, x - 0.75 * s, y + 4.4 * s, x - 0.2 * s, y + 4.7 * s, x + 0.55 * s, y + 4.5 * s],
			Color("e8483a"), 0.12 * s)
	if _detail(3.0): # pull straps
		_l(x - 0.9 * s, y + 4.5 * s, x - 0.95 * s, y + 4.0 * s, Color("5a3a22"), 0.08 * s)
		_l(x + 0.35 * s, y + 4.55 * s, x + 0.4 * s, y + 4.0 * s, Color("5a3a22"), 0.08 * s)

## Cheyenne Frontier Days: a big painted cowboy boot statue on the street and, in the rodeo arena behind its
## fence, a cowboy in his hat waving one arm while riding a bucking brown bronco.
static func _cheyenne_boots() -> void:
	# the arena: dirt and the white fence, the grandstand flags
	_r(-6, 0, 6, 0.6, Color("c9a878"))
	if _detail(1.0):
		for x in [-5.5, -2.5, 0.5, 3.5]:
			_l(x, 0.6, x, 1.8, WHITE, 0.1)
		_l(-6, 1.2, 6, 1.2, WHITE, 0.08)
		_l(-6, 1.7, 6, 1.7, WHITE, 0.08)
	# the bucking bronco: hind legs kicking up, front legs down, the cowboy on top
	var hx := 2.2
	var hy := 1.6
	var horse := Color("8a5230")
	var horse_d := Color("6a3c22")
	var a := 0.35 # tipped forward, rear up
	var body := _arc(0, 0, 1.25, 0.55, 0, TAU, 16)
	var bp := []
	for k in range(0, body.size(), 2):
		var x: float = body[k]
		var y: float = body[k + 1]
		bp.append_array([hx + x * cos(-a) - y * sin(-a), hy + 0.9 + x * sin(-a) + y * cos(-a)])
	# legs
	_l(hx + 0.8, hy + 0.5, hx + 1.1, 0.6, horse_d, 0.22) # front leg
	_l(hx + 0.6, hy + 0.5, hx + 0.6, 0.6, horse, 0.22)
	_l(hx - 0.9, hy + 1.2, hx - 1.9, hy + 1.0, horse_d, 0.22) # hind legs kicking out
	_l(hx - 0.9, hy + 1.1, hx - 1.8, hy + 1.6, horse, 0.22)
	_poly(bp, horse)
	# neck and head down between the front legs
	_poly([hx + 0.7, hy + 0.9, hx + 1.2, hy + 0.7, hx + 1.6, hy + 0.0, hx + 1.35, hy - 0.2, hx + 0.9, hy + 0.3], horse)
	_ell(hx + 1.55, hy - 0.15, 0.35, 0.2, -0.9, horse_d)
	# tail flying up
	_pl([hx - 1.1, hy + 1.5, hx - 1.5, hy + 2.0, hx - 1.4, hy + 2.5], DARK, 0.15)
	# the cowboy: leaning back, one arm waving his hat high
	var cx := hx - 0.1
	var cy := hy + 1.4
	_l(cx, cy, cx + 0.35, cy - 0.5, Color("3a5a8a"), 0.2) # leg
	_l(cx, cy, cx - 0.35, cy + 0.9, Color("c8382c"), 0.32) # body leaning back
	_c(cx - 0.45, cy + 1.25, 0.2, SKIN)
	_r(cx - 0.75, cy + 1.38, cx - 0.15, cy + 1.45, Color("6a4a2a"))
	_r(cx - 0.6, cy + 1.45, cx - 0.3, cy + 1.62, Color("6a4a2a"))
	_l(cx - 0.3, cy + 0.75, cx - 0.9, cy + 1.6, SKIN, 0.1) # waving arm
	_r(cx - 1.15, cy + 1.62, cx - 0.65, cy + 1.7, Color("e8d8b0"))
	_l(cx - 0.2, cy + 0.6, cx + 0.5, cy + 0.2, SKIN, 0.1) # hand on the rope
	# the big boot in front on the left
	_big_boot(-3.6, 0.95)

# --- Reno -------------------------------------------------------------------------------------------------------

## The Reno Arch over Virginia Street: two silver pillars and a curved arch of lights, the big word RENO in its
## middle and "THE BIGGEST LITTLE CITY IN THE WORLD" along its curve, the casino towers glittering behind.
static func _reno_arch() -> void:
	# casino towers behind, in the evening sky
	var tw := [[-15, -9, 15, Color("b85a7a")], [-8, -3, 11, Color("6a7aa8")], [4, 9, 13, Color("c8a84a")], [10, 15, 9, Color("7a5aa0")]]
	for t in tw:
		var c: Color = t[3]
		_r(t[0], 0, t[1], t[2], c)
		_r(t[1] - 1.0, 0, t[1], t[2], c.darkened(0.2))
		if _detail(1.5):
			for y in range(2, int(t[2]) - 1, 2):
				_r(t[0] + 0.5, y, t[1] - 1.5, y + 0.6, Color("ffe08a", 0.8))
	# the street
	_r(-15, 0, 15, 0.6, Color("4a4c50"))
	if _detail(1.0):
		for x in [-4.0, 0.0, 4.0]:
			_r(x - 0.8, 0.25, x + 0.8, 0.35, Color("f2d24a"))
	# the pillars
	var px := 9.0
	for s in [-1.0, 1.0]:
		var x: float = px * s
		_r(x - 0.7, 0, x + 0.7, 9.5, Color("c8ccd2"))
		_r(x + 0.2 * s, 0, x + 0.7 * s, 9.5, Color("9aa0a8"))
		_r(x - 1.0, 0, x + 1.0, 0.8, Color("8a8e94"))
	# the arch: an outer and inner curve with lights, the slogan band between
	var outer := _arc(0, 9.0, 10.2, 4.6, 0, PI, 24)
	var inner := _arc(0, 9.0, 8.4, 2.6, 0, PI, 24)
	var band := []
	band.append_array(outer)
	for k in range(inner.size() - 2, -1, -2):
		band.append_array([inner[k], inner[k + 1]])
	_poly(band, Color("1e3a8a"))
	_pl(outer, Color("ffe68a"), 0.3)
	_pl(inner, Color("ffe68a"), 0.25)
	if _detail(1.5): # bulbs along the outer curve
		for k in range(0, outer.size(), 2):
			_c(outer[k], outer[k + 1], 0.18, Color.WHITE)
	# the slogan: little white letters along the curve
	var slogan := "THE BIGGEST LITTLE CITY IN THE WORLD"
	var n := slogan.length()
	for k in n:
		var t := PI * (1.0 - (k + 0.5) / n)
		var x := cos(t) * 9.3
		var y := 9.0 + sin(t) * 3.6 - 0.35
		if slogan[k] == " ":
			continue
		if _detail(3.0):
			for st in _letter(slogan[k]):
				var pts := []
				var ca := cos(t - PI * 0.5)
				var sa := sin(t - PI * 0.5)
				for j in range(0, st.size(), 2):
					var u: float = (st[j] - 0.5) * 0.4
					var v: float = st[j + 1] * 0.7
					pts.append_array([x + u * ca - v * sa, y + u * sa + v * ca])
				_pl(pts, WHITE, 0.07)
		else:
			_c(x, y + 0.35, 0.16, WHITE)
	# RENO on the panel at the top of the arch, with a star on top
	_r(-4.2, 11.6, 4.2, 15.0, Color("f2f2ee"))
	_r(-4.2, 11.6, 4.2, 11.9, RED)
	_r(-4.2, 14.7, 4.2, 15.0, RED)
	_text("RENO", 0, 12.2, 1.4, 2.2, RED, 0.35)
	var st := []
	for k in 10:
		var r := 1.0 if k % 2 == 0 else 0.42
		var a := PI * 0.5 + TAU * k / 10.0
		st.append_array([cos(a) * r, 16.0 + sin(a) * r])
	_poly(st, Color("ffd23a"))

# --- Wendover ---------------------------------------------------------------------------------------------------

## A long, low streamliner racing across the dazzling white Bonneville Salt Flats: a pointed nose, a little
## glass bubble and a tail fin, salt flying up behind, the black line of the course and blue mountains far away.
static func _salt_flats_racer() -> void:
	# far mountains floating over the salt (a mirage)
	_poly([-20, 2, -20, 4.5, -15, 6.5, -11, 5.2, -7, 7.2, -3, 5.6, 2, 6.8, 7, 5.0, 12, 6.0, 16, 4.6, 20, 5.2, 20, 2],
			Color("8ea2c0"))
	_poly([-20, 2, -20, 3.4, 0, 3.0, 20, 3.4, 20, 2], Color("b6c4d6"))
	# the salt: white, with the honeycomb cracks
	_r(-20, 0, 20, 2.6, Color("f4f4f0"))
	_r(-20, 2.2, 20, 2.6, Color("dfe6ee"))
	if _detail(2.0):
		for k in 14:
			var x := -19.0 + k * 2.9
			_pl([x, 0.2, x + 0.8, 0.6, x + 0.5, 1.1, x + 1.6, 1.4], Color("d8dcd8"), 0.06)
	# the black course line
	_r(-20, 0.5, 20, 0.62, DARK)
	# the car: a long blue-and-yellow pencil on hidden wheels
	var y := 0.9
	var body := [-8, y, -8, y + 1.1, -6, y + 1.35, 2, y + 1.3, 5, y + 1.0, 7.5, y + 0.45, 8.2, y + 0.2, 7.8, y]
	_poly(body, Color("2a62b8"))
	_poly([-8, y, 7.8, y, 8.2, y + 0.2, 7.5, y + 0.45, -8, y + 0.45], Color("f2c230"))
	_poly([-8, y + 1.1, -7.6, y + 2.8, -6.8, y + 2.8, -6.2, y + 1.3], RED) # tail fin
	_ell(-1.2, y + 1.35, 1.2, 0.5, 0, Color("8fc4e8")) # the bubble canopy
	_ell(-1.4, y + 1.5, 0.5, 0.2, 0, Color(1, 1, 1, 0.7))
	_c(-5.6, y, 0.4, DARK)
	_c(5.2, y, 0.4, DARK)
	if _detail(1.5):
		_l(-4.8, y + 0.75, 4.0, y + 0.75, WHITE, 0.12)
		_r(1.5, y + 0.55, 2.8, y + 1.05, WHITE)
		_r(1.85, y + 0.65, 2.45, y + 0.95, DARK)
	# a parachute pack and salt spray trailing behind
	_c(-8.2, y + 0.6, 0.35, Color("e8483a"))
	for p in [[-9.5, 1.2, 0.9], [-11.5, 1.5, 1.2], [-14.0, 1.7, 1.5], [-17.0, 1.9, 1.7], [-10.5, 0.7, 0.7]]:
		_ell(p[0], p[1], p[2] * 1.5, p[2] * 0.75, 0, Color(1, 1, 1, 0.75))
	if _detail(1.0): # speed lines
		for p in [[-12.0, 3.2], [-15.0, 2.7], [-11.0, 3.7]]:
			_l(p[0], p[1], p[0] + 2.8, p[1], Color(1, 1, 1, 0.8), 0.08)

# --- Mount Shasta ----------------------------------------------------------------------------------------------

## Mount Shasta: a huge lone volcano, its wide cone white with snow and glaciers, the smaller cone of Shastina on
## its shoulder, rising over the dark pine forest of the valley.
static func _mount_shasta() -> void:
	var rock := Color("7a7c8a")
	var rock_d := Color("626474")
	# the big cone and Shastina on its left shoulder
	_poly([-45, 4, -36, 10, -26, 18, -20, 25, -15, 30, -12, 32, -9, 30, -6, 36, -3, 42, -1, 44.5, 1.5, 45, 4, 43.5, 8, 38,
		14, 30, 22, 22, 32, 14, 45, 6, 45, 4], rock)
	_poly([2, 45, 4, 43.5, 8, 38, 14, 30, 22, 22, 32, 14, 45, 6, 45, 4, 10, 4], rock_d)
	# the snow and glaciers: a broad white cap reaching down in fingers
	var snow := [-15, 30, -12, 32, -9, 30, -6, 36, -3, 42, -1, 44.5, 1.5, 45, 4, 43.5, 8, 38, 14, 30, 18, 26, 15, 24,
		12, 26, 10, 21, 8, 25, 5, 18, 3, 24, 0, 17, -2, 24, -5, 19, -7, 25, -10, 22, -12, 26, -16, 23, -18, 27]
	_poly(snow, SNOW)
	_poly([1.5, 45, 4, 43.5, 8, 38, 14, 30, 18, 26, 15, 24, 12, 26, 10, 21, 8, 25, 5, 18, 3, 24, 2, 30], SNOW_S)
	if _detail(0.7): # ridges of rock showing through the snow
		for r in [[-4, 36, -6, 26], [0, 40, -0.5, 22], [5, 37, 6, 24], [-11, 30, -13, 25]]:
			_l(r[0], r[1], r[2], r[3], rock_d, 0.5)
	# lower slopes greening into the forest
	_poly([-45, 0, -45, 7, -34, 9, -20, 10, -6, 9, 8, 10, 22, 9, 36, 8, 45, 7, 45, 0], Color("5c7a54"))
	# the pine forest: rows of dark firs, the nearest the biggest
	for k in 15:
		var x := -44.0 + k * 6.3
		_fir(x, 6.0, 5.0 + (k % 3), PINE.lightened(0.08))
	for k in 12:
		var x := -42.0 + k * 7.6
		_fir(x, 0.5, 8.0 + (k % 2) * 1.6, PINE)
	_r(-45, 0, 45, 1.0, GRASS.darkened(0.15))

# --- Twin Falls -------------------------------------------------------------------------------------------------

## Shoshone Falls, the "Niagara of the West": the Snake River pours in a wide white horseshoe over a rim of black
## basalt, deep down into the canyon, spray rising, dark cliffs on both sides and green on the top.
static func _shoshone_falls() -> void:
	var rock := Color("2f2c2c")
	var rock_l := Color("4c4644")
	# the canyon walls left and right, high above the falls, the plateau on top
	_poly([-40, 0, -40, 34, -30, 33.5, -24, 31, -21, 24, -22, 12, -20, 0], rock)
	_poly([40, 0, 40, 34, 30, 33.5, 25, 31, 22, 24, 23, 12, 21, 0], rock)
	_poly([-40, 32.6, -30, 32.2, -24, 30.0, -24, 31, -30, 33.5, -40, 34], Color("8a9a58"))
	_poly([40, 32.6, 30, 32.2, 25, 30.0, 25, 31, 30, 33.5, 40, 34], Color("8a9a58"))
	if _detail(0.7): # basalt columns
		for k in 8:
			var x := -39.0 + k * 2.3
			_l(x, 31.0, x + 0.2, 3.0, rock_l, 0.4)
			_l(-x, 31.0, -x - 0.2, 3.0, rock_l, 0.4)
	# the river above the rim and the rim itself
	_poly([-22, 22, 22, 22, 18, 25, -18, 25], WATER)
	_poly([-22, 20, -10, 21.2, 0, 21.5, 10, 21.2, 22, 20, 22, 22, -22, 22], rock_l)
	# the falls: a wide curtain bowed towards us, broken by a few dark rocks
	var curve := []
	for k in 21:
		var x := -21.0 + k * 2.1
		curve.append_array([x, 21.5 - (x / 21.0) * (x / 21.0) * 1.2])
	var curtain := curve.duplicate()
	curtain.append_array([23, 4, -23, 4])
	_poly(curtain, SPRAY)
	for f in [[-20.0, -12.0], [-10.0, -2.0], [0.5, 9.0], [11.0, 20.0]]:
		_fall(f[0], f[1], 4.0, 21.0, 1.0)
	for p in [[-12.0, 21.0, 14.0], [-1.0, 21.4, 16.5], [10.0, 21.0, 13.0]]:
		_poly([p[0] - 0.8, p[1], p[0] + 0.9, p[1], p[0] + 0.5, p[2], p[0] - 0.3, p[2] + 1.0], rock)
	# the plunge pool, a cloud of spray rising from it
	_r(-23, 0, 23, 4.5, WATER)
	if _detail(1.0):
		for p in [[-18, 1.5], [-4, 2.4], [9, 1.2]]:
			_r(p[0], p[1], p[0] + 6, p[1] + 0.3, WATER_L)
	for x in [-18.0, -12.0, -6.0, 0.0, 6.0, 12.0, 18.0]:
		_c(x, 4.6, 3.4, MIST)
		_c(x + 2.5, 6.5, 2.2, Color(1, 1, 1, 0.45))
	# a little rainbow in the spray
	if _detail(0.6):
		var cols := [Color(0.9, 0.3, 0.3, 0.45), Color(0.95, 0.8, 0.3, 0.45), Color(0.3, 0.7, 0.4, 0.45), Color(0.3, 0.5, 0.9, 0.45)]
		for k in cols.size():
			_pl(_arc(4, 2, 9.0 - k * 0.6, 7.0 - k * 0.6, 0.35, PI - 0.35, 14), cols[k], 0.45)

# --- Troutdale --------------------------------------------------------------------------------------------------

## Multnomah Falls in the Columbia River Gorge: a thin white ribbon dropping from the top of a mossy dark cliff
## into an upper pool, then the short lower falls, and the little arched stone Benson Bridge across between them.
static func _multnomah_falls() -> void:
	var rock := Color("3a3e3a")
	var rock_l := Color("565c54")
	var moss := Color("4a7a3a")
	# the cliff
	_poly([-15, 0, -15, 54, -9, 57, -3, 58, 3, 58, 9, 56, 15, 53, 15, 0], rock)
	_poly([4, 0, 4, 57.8, 9, 56, 15, 53, 15, 0], rock_l.darkened(0.15))
	# trees on the top and moss down the sides
	for p in [[-13.0, 53.0], [-9.0, 56.0], [-5.0, 57.0], [5.0, 57.0], [9.5, 55.0], [13.0, 52.0]]:
		_fir(p[0], p[1], 5.0, PINE)
	if _detail(0.6):
		for p in [[-12, 44, 2.0], [-10, 32, 2.6], [-13, 20, 2.2], [11, 46, 2.2], [12, 34, 2.8], [10, 22, 2.0],
				[-11, 10, 2.4], [12, 10, 2.6]]:
			_ell(p[0], p[1], p[2], p[2] * 1.8, 0, moss)
			_ell(p[0] + 0.5, p[1] + 0.8, p[2] * 0.6, p[2] * 1.2, 0, moss.lightened(0.15))
	if _detail(1.0): # layers of lava rock
		for y in [12.0, 25.0, 38.0, 48.0]:
			_l(-15, y, 15, y - 0.5, rock_l, 0.4)
	# the upper falls: a tall slender drop from the notch at the top
	_poly([-2, 58.2, 2, 58.2, 1.5, 55, -1.5, 55], rock_l)
	_fall(-1.2, 1.2, 20.0, 56.0, 1.2)
	_ell(0, 19.5, 4.0, 1.3, 0, Color(1, 1, 1, 0.85))
	# the upper pool and the ledge
	_poly([-7, 17, -6, 19, 6, 19, 7, 17], WATER)
	_poly([-15, 13, -15, 17.5, -6, 17, 6, 17, 15, 17.5, 15, 13], rock_l)
	# the lower falls: shorter, a bit wider
	_fall(-1.6, 1.6, 2.0, 17.0, 1.6)
	# the Benson Bridge: a slim stone arch across the gorge in front of the lower falls
	var stone := Color("cfc8b4")
	var deck := 13.0
	_r(-8, deck, 8, deck + 1.0, stone)
	var under := _arc(0, deck - 3.6, 6.2, 3.6, 0, PI, 16)
	var arch := [-8, deck, 8, deck]
	arch.append_array(under)
	_poly(arch, stone)
	_poly([-8, deck, -6.2, deck - 3.6, -6.2, deck - 4.0, -8, deck - 4.0], stone)
	_poly([8, deck, 6.2, deck - 3.6, 6.2, deck - 4.0, 8, deck - 4.0], stone)
	_pl(under, stone.darkened(0.2), 0.2)
	if _detail(1.2): # railing posts
		_l(-8, deck + 1.8, 8, deck + 1.8, stone.darkened(0.25), 0.12)
		for k in 9:
			var x := -8.0 + k * 2.0
			_l(x, deck + 1.0, x, deck + 1.8, stone.darkened(0.25), 0.12)
	# visitors on the bridge
	var coats := [Color("d23b33"), Color("f2c230"), Color("2f6fa6")]
	for k in 3:
		var x := -3.5 + k * 3.2
		_r(x - 0.25, deck + 1.0, x + 0.25, deck + 2.1, coats[k])
		_c(x, deck + 2.4, 0.28, SKIN)
	# the pool at the bottom and the spray
	_r(-15, 0, 15, 2.4, WATER)
	_c(-1.5, 2.6, 2.2, MIST)
	_c(1.8, 3.0, 1.8, MIST)

# --- North Bend -------------------------------------------------------------------------------------------------

## Snoqualmie Falls: the river plunging in a thick white column off a dark rocky cliff into a misty pool, firs
## all round, and the Salish Lodge sitting right at the top of the cliff beside the brink.
static func _snoqualmie_falls() -> void:
	var rock := Color("3c3a36")
	var rock_l := Color("5a5650")
	# the cliff, the river coming over the brink a little right of the middle
	_poly([-25, 0, -25, 30, -10, 31, 0, 31.5, 10, 31, 25, 30, 25, 0], rock)
	_poly([8, 0, 8, 31.2, 25, 30, 25, 0], rock_l.darkened(0.1))
	if _detail(0.8):
		for k in 7:
			var x := -23.0 + k * 3.0
			_l(x, 29.5, x + 0.5, 4.0, rock_l, 0.4)
		for y in [10.0, 20.0]:
			_l(-25, y, 25, y + 0.5, rock_l, 0.35)
	# forest along the top and down the sides
	for p in [[-24.0, 30.0, 6.0], [-20.0, 30.5, 7.5], [-6.0, 31.0, 5.5], [14.0, 31.0, 6.0], [18.0, 30.5, 7.5],
			[22.5, 30.0, 6.5]]:
		_fir(p[0], p[1], p[2], PINE)
	for p in [[-23.0, 18.0, 5.0], [-22.0, 6.0, 6.0], [22.0, 16.0, 5.5], [21.5, 4.0, 6.0]]:
		_fir(p[0], p[1], p[2], PINE.lightened(0.05))
	# the river at the brink and the falls
	_poly([-1, 31, 9, 31, 8, 32.2, 0, 32.2], WATER)
	_fall(0, 8, 3.0, 31.0, 1.5)
	# the lodge on the cliff top on the left: a long cream building with a dark roof and chimneys
	var wall := Color("ece2c8")
	_r(-17, 31, -4, 35.5, wall)
	_poly([-17.6, 35.5, -3.4, 35.5, -5, 38, -16, 38], Color("5a4038"))
	_r(-15, 36.5, -14, 39, Color("8a5a48"))
	_r(-8, 36.5, -7, 39, Color("8a5a48"))
	_windows(-16.5, -4.5, 32, 34.5, 7, WIN)
	_r(-11.3, 31, -9.7, 33.5, Color("6a4a32"))
	# the pool and the great cloud of mist at the bottom
	_r(-25, 0, 25, 3.5, WATER)
	if _detail(1.0):
		for p in [[-18, 1.4], [-10, 2.2], [14, 1.2]]:
			_r(p[0], p[1], p[0] + 5, p[1] + 0.3, WATER_L)
	for p in [[-2.0, 4.0, 4.0], [4.0, 5.0, 4.5], [10.0, 4.0, 3.5], [1.0, 8.0, 3.0], [7.0, 9.0, 2.8]]:
		_c(p[0], p[1], p[2], MIST)
