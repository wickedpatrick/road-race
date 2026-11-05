class_name LandmarksUsE
extends RefCounted
## American landmarks, drawn with LandmarkPainter's helpers (metres from the base point, y up).

const WHITE := Color("f4f2ea")
const WATER := Color("3f7fb5")
const WATER_L := Color("9cc8e6")
const SAND := Color("e6d29c")
const GRASS := Color("6f9a48")
const PINE := Color("2f5a36")
const WOOD := Color("7a5634")
const DARK := Color("2e3238")
const WIN := Color("3a4048")
const SNOW := Color("f4f7fa")
const SNOW_S := Color("c9d6e4")
const ORANGE := Color("c0362c")
const FOG := Color(1, 1, 1, 0.55)

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"route66_seligman": _route66_seligman()
		"hollywood_sign": _hollywood_sign()
		"santa_monica_pier": _santa_monica_pier()
		"golden_gate": _golden_gate()
		"cable_car": _cable_car()
		"space_needle": _space_needle()
		"mount_hood": _mount_hood()
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

## A digit 6 in a box w wide and h tall whose lower left corner is (x, y), drawn as strokes.
static func _six(x: float, y: float, w: float, h: float, col: Color, lw: float) -> void:
	var r := w * 0.5
	_pl(_arc(x + r, y + r, r, r, 0, TAU, 14), col, lw)
	_pl([x, y + r] + _arc(x + r, y + h - r, r, r, PI, PI * 0.25, 6), col, lw)

## A classic 1950s car with tail fins, facing right; (x, y) is the middle of its base.
static func _classic_car(x: float, y: float, col: Color) -> void:
	var chrome := Color("dfe3e6")
	_poly([x - 2.9, y + 0.4, x + 2.9, y + 0.4, x + 3.0, y + 1.0, x + 2.7, y + 1.25, x - 2.6, y + 1.3,
		x - 3.0, y + 1.55, x - 3.05, y + 0.9], col)
	_poly([x - 1.3, y + 1.25, x + 1.2, y + 1.25, x + 0.7, y + 2.0, x - 1.0, y + 2.0], col.lightened(0.1))
	_poly([x - 1.1, y + 1.3, x + 1.0, y + 1.3, x + 0.6, y + 1.88, x - 0.85, y + 1.88], Color("9fc4dc"))
	_l(x - 0.1, y + 1.3, x - 0.1, y + 1.9, col, 0.12)
	_r(x - 3.0, y + 0.35, x + 3.0, y + 0.55, chrome)
	_l(x - 2.6, y + 0.95, x + 2.6, y + 0.95, chrome, 0.08)
	_r(x + 2.8, y + 0.7, x + 3.0, y + 0.95, Color("fff2b0"))
	_r(x - 3.05, y + 1.1, x - 2.9, y + 1.4, Color("d03a2a"))
	for wx in [x - 1.8, x + 1.8]:
		_c(wx, y + 0.42, 0.42, DARK)
		_c(wx, y + 0.42, 0.2, chrome)

## Seligman on old Route 66: the big black-and-white Route 66 shield on its post, a little roadside diner with a
## gas pump in front, and a red classic car with fins parked by it.
static func _route66_seligman() -> void:
	_r(-15, 0, 15, 0.5, Color("c8a878"))
	_r(-15, 0, 15, 0.25, Color("55524e"))
	# the diner: a low stucco building with a turquoise band and a striped awning
	var wall := Color("f0e2c4")
	var turq := Color("3fb3b0")
	_r(-12, 0.25, 2, 5, wall)
	_r(-12, 5, 2, 6, turq)
	_r(-12.3, 6, 2.3, 6.4, turq.darkened(0.2))
	_r(-11, 0.25, -9, 3.6, Color("7a4a2e"))
	_r(-8, 1.6, 1, 3.8, Color("9fc4dc"))
	if _detail(1.2):
		for k in 6:
			var x0 := -8.3 + k * 1.6
			_poly([x0, 4.6, x0 + 0.8, 4.6, x0 + 0.8, 3.9, x0, 3.9], Color("d23b33") if k % 2 == 0 else WHITE)
			_poly([x0 + 0.8, 4.6, x0 + 1.6, 4.6, x0 + 1.6, 3.9, x0 + 0.8, 3.9], WHITE if k % 2 == 0 else Color("d23b33"))
	else:
		_r(-8.3, 3.9, 1.3, 4.6, Color("d23b33"))
	# a sign board on the roof
	_r(-9, 6.4, -1, 8.4, Color("d23b33"))
	_r(-8.6, 6.8, -1.4, 8.0, Color("f5d36b"))
	# the old gas pump
	_r(3.2, 0.25, 4.6, 3.4, Color("d23b33"))
	_c(3.9, 3.7, 0.55, WHITE)
	_c(3.9, 3.7, 0.4, Color("f5d36b"))
	_r(3.5, 1.6, 4.3, 2.5, WHITE)
	_l(4.6, 2.2, 5.1, 1.2, DARK, 0.1)
	# the classic car
	_classic_car(-5.5, 0.25, Color("c8323a"))
	# the Route 66 shield on its post
	_r(9.6, 0.25, 10.4, 6, Color("6b6b6b"))
	var sx := 10.0
	var sy := 6.0
	var sh := [sx - 3.2, sy + 6.0, sx - 2.6, sy + 2.4, sx - 1.2, sy + 0.8, sx, sy, sx + 1.2, sy + 0.8, sx + 2.6, sy + 2.4,
		sx + 3.2, sy + 6.0, sx + 2.4, sy + 6.3, sx + 1.4, sy + 5.9, sx, sy + 6.4, sx - 1.4, sy + 5.9, sx - 2.4, sy + 6.3]
	_poly(sh, DARK)
	var inner := []
	for k in range(0, sh.size(), 2):
		inner.append_array([sx + (sh[k] - sx) * 0.86, sy + 0.45 + (sh[k + 1] - sy) * 0.86])
	_poly(inner, WHITE)
	# the top band and the big 66
	_r(sx - 2.5, sy + 4.3, sx + 2.5, sy + 4.5, DARK)
	if _detail(0.9):
		_r(sx - 1.6, sy + 4.7, sx - 1.3, sy + 5.4, DARK)
		_r(sx - 0.9, sy + 4.7, sx - 0.6, sy + 5.4, DARK)
		_r(sx + 0.3, sy + 4.7, sx + 1.5, sy + 4.9, DARK)
		_r(sx + 0.3, sy + 5.2, sx + 1.5, sy + 5.4, DARK)
	_six(sx - 2.0, sy + 1.2, 1.6, 2.6, DARK, 0.35)
	_six(sx + 0.4, sy + 1.2, 1.6, 2.6, DARK, 0.35)

## Strokes of one capital letter in a unit box (x right, y up), as polylines.
static func _letter(ch: String) -> Array:
	match ch:
		"H": return [[0, 0, 0, 1], [1, 0, 1, 1], [0, 0.5, 1, 0.5]]
		"O": return [_arc(0.5, 0.5, 0.5, 0.5, 0, TAU, 14)]
		"L": return [[0, 1, 0, 0, 0.9, 0]]
		"Y": return [[0, 1, 0.5, 0.5, 1, 1], [0.5, 0.5, 0.5, 0]]
		"W": return [[0, 1, 0.25, 0, 0.5, 0.65, 0.75, 0, 1, 1]]
		"D": return [[0, 0, 0, 1, 0.35, 1] + _arc(0.35, 0.5, 0.6, 0.5, PI * 0.5, -PI * 0.5, 8) + [0, 0]]
	return []

## The Hollywood Sign: nine tall white letters on stilts across the dry, scrubby slope of the Hollywood Hills.
static func _hollywood_sign() -> void:
	var hill := Color("a88f5c")
	var scrub := Color("6f7d45")
	_poly([-35, 0, -35, 10, -26, 16, -16, 21, -4, 25, 6, 27, 16, 25.5, 26, 21, 35, 15, 35, 0], hill.lightened(0.08))
	_poly([-35, 0, -35, 6, -20, 12, 0, 16, 18, 15, 35, 8, 35, 0], hill)
	if _detail(0.8):
		for p in [[-28, 9], [-18, 14], [-8, 12], [2, 20], [12, 13], [22, 17], [30, 8], [-24, 4], [8, 5], [24, 4], [-4, 6]]:
			_c(p[0], p[1], 1.4, scrub)
			_c(p[0] + 1.2, p[1] + 0.3, 1.0, scrub.lightened(0.1))
	_poly([-35, 0, -35, 2, 35, 2, 35, 0], scrub.darkened(0.1))
	var word := "HOLLYWOOD"
	var lw := 4.6
	var gap := 1.9
	var x0 := -(word.length() * lw + (word.length() - 1) * gap) * 0.5
	for k in word.length():
		var x := x0 + k * (lw + gap)
		var base := 12.0 + sin(k * 0.55) * 1.6 + k * 0.2
		var lh := 8.0
		# the stilts and frame behind each letter
		_l(x + lw * 0.3, base - 2.5, x + lw * 0.3, base + 1, Color("8a8a84"), 0.18)
		_l(x + lw * 0.7, base - 2.5, x + lw * 0.7, base + 1, Color("8a8a84"), 0.18)
		for s in _letter(word[k]):
			var pts := []
			for j in range(0, s.size(), 2):
				pts.append_array([x + s[j] * lw, base + s[j + 1] * lh])
			_pl(pts, WHITE.darkened(0.1), 1.25)
			var pts2 := []
			for j in range(0, pts.size(), 2):
				pts2.append_array([pts[j] - 0.12, pts[j + 1] + 0.12])
			_pl(pts2, WHITE, 1.0)

## Santa Monica Pier: the wooden pier on its piles over the beach and the sea, with the big ferris wheel and a
## yellow-and-red roller coaster at its end, a little arcade between them.
static func _santa_monica_pier() -> void:
	_r(-35, 0, 35, 3, WATER)
	if _detail(1.0):
		for p in [[-30, 1.2], [-12, 0.6], [6, 1.8], [24, 0.9]]:
			_r(p[0], p[1], p[0] + 6, p[1] + 0.3, WATER_L)
	_poly([-35, 0, -35, 5, -24, 3.4, -18, 0], SAND)
	_l(-35, 4.8, -22, 2.8, Color.WHITE, 0.25)
	# the deck on its piles
	var deck := Color("8a6a48")
	for k in 22:
		var x := -26.0 + k * 2.8
		_r(x - 0.25, 0, x + 0.25, 7, deck.darkened(0.25))
	if _detail(1.0):
		for k in 11:
			var x := -24.6 + k * 5.6
			_l(x - 2.8, 1.5, x + 2.8, 6.5, deck.darkened(0.3), 0.12)
	_r(-30, 7, 34, 8.2, deck)
	_r(-30, 8.2, 34, 8.5, deck.lightened(0.2))
	# the arcade with its blue roof
	_r(-24, 8.5, -8, 12.5, Color("f1e6cf"))
	_windows(-23, -9, 9.5, 11.5, 5, Color("3c6e9e"))
	_poly([-25, 12.5, -7, 12.5, -9, 14.5, -23, 14.5], Color("2f6fa6"))
	# the roller coaster: a hump track on lattice legs
	var track := [-6, 8.5, -5, 13, -3, 18, -1, 19.5, 1, 17, 2.5, 12, 4, 10.5, 6, 13, 8, 15, 10, 13.5, 11.5, 10, 13, 8.5]
	if _detail(1.0):
		for j in range(2, track.size() - 2, 2):
			_l(track[j], 8.5, track[j], track[j + 1], Color("d23b33"), 0.25)
	_pl(track, Color("f2c230"), 0.6)
	_pl(track, Color("d23b33"), 0.2)
	# the ferris wheel
	var cx := 22.0
	var cy := 22.0
	var rr := 12.5
	var leg := Color("d8dde2")
	_l(cx - 5, 8.5, cx, cy, leg, 0.6)
	_l(cx + 5, 8.5, cx, cy, leg, 0.6)
	_pl(_arc(cx, cy, rr, rr, 0, TAU, 32), Color("f2c230"), 0.5)
	_pl(_arc(cx, cy, rr * 0.82, rr * 0.82, 0, TAU, 28), Color("e85a4a"), 0.25)
	var cols := [Color("d23b33"), Color("f2c230"), Color("2f8fd0"), Color("49a85a"), Color("e57ac0")]
	for k in 16:
		var a := TAU * k / 16.0
		_l(cx, cy, cx + cos(a) * rr, cy + sin(a) * rr, Color("e8e8e0"), 0.12)
	for k in 16:
		var a := TAU * k / 16.0 + 0.1
		var gx := cx + cos(a) * rr
		var gy := cy + sin(a) * rr
		_r(gx - 0.8, gy - 1.6, gx + 0.8, gy - 0.2, cols[k % cols.size()])
	_c(cx, cy, 1.2, Color("d8dde2"))

## The Golden Gate Bridge: two International Orange art-deco towers, the main cables sweeping down to the deck,
## the bay under it, green headlands at both ends and a bank of fog rolling over.
static func _golden_gate() -> void:
	_r(-45, 0, 45, 4, WATER)
	if _detail(1.0):
		for p in [[-38, 1.5], [-10, 0.8], [14, 2.2], [32, 1.0]]:
			_r(p[0], p[1], p[0] + 7, p[1] + 0.3, WATER_L)
	var hl := Color("6b8a4a")
	_poly([-45, 0, -45, 15, -40, 14, -35, 9, -32, 4, -30, 0], hl)
	_poly([45, 0, 45, 18, 41, 17, 37, 12, 34, 5, 32, 0], hl.darkened(0.08))
	var o := ORANGE
	var od := o.darkened(0.2)
	var deck_y := 12.0
	# deck and truss
	_r(-45, deck_y - 1.4, 45, deck_y, od)
	_r(-45, deck_y, 45, deck_y + 0.5, o)
	if _detail(1.2):
		for k in 45:
			var x := -44.0 + k * 2.0
			_l(x, deck_y - 1.3, x + 1.0, deck_y - 0.1, o, 0.12)
	var tx := [-20.0, 20.0]
	var top := 44.0
	# the main cables (one span between the towers, side spans to the anchorages)
	var cab := []
	for k in 21:
		var t := float(k) / 20.0
		var x := lerpf(tx[0], tx[1], t)
		var s := (t - 0.5) * 2.0
		cab.append_array([x, deck_y + 1 + (top - 2 - deck_y - 1) * s * s])
	_pl(cab, o, 0.55)
	_pl([-45, deck_y + 9, -32, deck_y + 18, -20, top - 2], o, 0.55)
	_pl([20, top - 2, 32, deck_y + 18, 45, deck_y + 9], o, 0.55)
	if _detail(0.8):
		for j in range(2, cab.size() - 2, 2):
			_l(cab[j], deck_y + 0.5, cab[j], cab[j + 1], o, 0.12)
		for x in [-42.0, -38.0, -34.0, -30.0, -26.0, 26.0, 30.0, 34.0, 38.0, 42.0]:
			var ax := absf(x)
			var y := deck_y + 9 + (ax - 45) / (20 - 45) * (top - 2 - deck_y - 9)
			_l(x, deck_y + 0.5, x, y, o, 0.12)
	# the towers: two legs joined by stepped portal beams
	for x in tx:
		_r(x - 3.4, 0, x + 3.4, 2, Color("9a9a94"))
		for d in [-2.3, 2.3]:
			_poly([x + d - 0.9, 2, x + d + 0.9, 2, x + d + 0.7, top, x + d - 0.7, top], o)
			_r(x + d - 0.9, 2, x + d - 0.4, top, od)
		for y in [deck_y + 9, deck_y + 17, deck_y + 24, top - 3]:
			_r(x - 1.6, y, x + 1.6, y + 1.6, o)
			if _detail(1.2):
				_r(x - 1.0, y + 0.3, x + 1.0, y + 1.3, od)
		_r(x - 3.2, top, x + 3.2, top + 0.8, od)
	# fog rolling in over the headland and round the right tower
	for p in [[30, 22, 8, 3], [38, 26, 9, 3.5], [24, 28, 6, 2.2], [-40, 18, 7, 2.6], [-33, 15, 5, 2]]:
		_ell(p[0], p[1], p[2], p[3], 0, FOG)

## A San Francisco cable car climbing a steep street: the red-and-cream wooden car with its open end benches,
## the cable slot in the cobbled hill, and colourful Victorian houses stepping up the hill behind.
static func _cable_car() -> void:
	var a := deg_to_rad(14.0)
	var slope := tan(a)
	# the houses behind, each standing a step higher
	var hc := [Color("e9b84a"), Color("9cc3d8"), Color("e48a8a"), Color("b9d39a")]
	for k in 4:
		var x0 := -8.0 + k * 4.0
		var gy := (x0 + 8.0) * slope
		var c: Color = hc[k]
		_r(x0, gy, x0 + 4, gy + 7.5, c)
		_poly([x0 - 0.2, gy + 7.5, x0 + 4.2, gy + 7.5, x0 + 2, gy + 9], c.darkened(0.25))
		_r(x0 + 0.5, gy + 1.5, x0 + 1.6, gy + 6.5, c.lightened(0.15))
		if _detail(1.5):
			_r(x0 + 0.7, gy + 4.0, x0 + 1.4, gy + 6.0, WIN)
			_r(x0 + 2.4, gy + 4.0, x0 + 3.4, gy + 6.0, WIN)
	# the street: a steep slope of grey cobbles with the rails
	_poly([-8, 0, 8, 0, 8, 16 * slope], Color("7d7a74"))
	_poly([-8, 0, 8, 16 * slope, 8, 16 * slope - 0.7, -5.2, 0], Color("5e5b56"))
	_l(-8, 0.15, 8, 16 * slope + 0.15, Color("b8b8b0"), 0.12)
	# the car, tilted with the hill
	var ox := 0.0
	var oy := 8.0 * slope
	var red := Color("b0282a")
	var cream := Color("f0e2c0")
	_poly(_rot([-5, 0.6, 5, 0.6, 5, 2.3, -5, 2.3], ox, oy, a), red)
	_poly(_rot([-2.8, 2.3, 2.8, 2.3, 2.8, 5.0, -2.8, 5.0], ox, oy, a), cream)
	_poly(_rot([-2.5, 3.0, 2.5, 3.0, 2.5, 4.6, -2.5, 4.6], ox, oy, a), Color("9fc4dc"))
	for wx in [-1.6, -0.15, 1.3]:
		_poly(_rot([wx, 3.0, wx + 0.2, 3.0, wx + 0.2, 4.6, wx, 4.6], ox, oy, a), red)
	# the open ends: poles holding up the roof
	for x in [-4.8, -3.6, 3.6, 4.8]:
		_poly(_rot([x - 0.1, 2.3, x + 0.1, 2.3, x + 0.1, 5.1, x - 0.1, 5.1], ox, oy, a), Color("6a4a2c"))
	_poly(_rot([-5.4, 5.0, 5.4, 5.0, 5.0, 5.6, -5.0, 5.6], ox, oy, a), Color("3a3634"))
	_poly(_rot([-2.6, 5.6, 2.6, 5.6, 2.2, 6.0, -2.2, 6.0], ox, oy, a), Color("3a3634"))
	_poly(_rot([-1.0, 1.0, 1.0, 1.0, 1.0, 1.9, -1.0, 1.9], ox, oy, a), Color("e8c450"))
	for wx in [-3.0, 3.0]:
		var p: Array = _rot([wx, 0.45], ox, oy, a)
		_c(p[0], p[1], 0.5, DARK)

## The Space Needle: three pairs of white legs pinched at the waist, the flying-saucer top house with its
## halo ring, the spire, and Mount Rainier's snowy cone far behind.
static func _space_needle() -> void:
	# Mount Rainier, pale with distance
	var rock := Color("8fa3b8")
	_poly([-20, 0, -20, 6, -10, 17, -4, 23, 0, 24, 5, 22, 12, 15, 20, 7, 20, 0], rock)
	_poly([-10, 17, -4, 23, 0, 24, 5, 22, 12, 15, 8, 15.5, 5, 13, 2, 16, -2, 13.5, -6, 16], SNOW)
	_poly([0, 24, 5, 22, 12, 15, 8, 15.5, 5, 13, 2, 16], SNOW_S)
	_r(-20, 0, 20, 4, Color("4f7a46"))
	if _detail(0.8):
		for x in [-18.0, -15.0, -12.0, 13.0, 16.0, 18.5]:
			_poly([x - 1.2, 3, x + 1.2, 3, x, 7.5], PINE)
	var w := Color("eef0ee")
	var ws := Color("c4c8cc")
	var top := 40.0
	# legs: wide at the foot, pinched at the waist, flaring to the saucer
	_poly([-6, 0, -4.4, 0, -0.6, 22, -0.9, 22], ws)
	_poly([6, 0, 4.4, 0, 0.6, 22, 0.9, 22], w)
	_poly([-1.2, 0, 1.2, 0, 0.4, 22, -0.4, 22], w.darkened(0.05))
	_poly([-0.9, 22, -0.6, 22, -3.5, top - 1, -4.3, top - 1], ws)
	_poly([0.9, 22, 0.6, 22, 3.5, top - 1, 4.3, top - 1], w)
	_poly([-0.4, 22, 0.4, 22, 0.8, top - 1, -0.8, top - 1], w.darkened(0.05))
	# the waist ring and the lift shaft
	_r(-1.4, 21.4, 1.4, 22.6, ws)
	_r(-0.35, 0, 0.35, top, Color("b5bcc4"))
	# the base pavilion
	_r(-7, 0, 7, 1.6, Color("d6d2c6"))
	# the saucer top house
	_poly([-9, top, 9, top, 6.5, top - 1.6, -6.5, top - 1.6], ws)
	_poly([-9.6, top, 9.6, top, 9.6, top + 0.7, -9.6, top + 0.7], Color("d97a3a"))
	_poly([-7, top + 0.7, 7, top + 0.7, 7.5, top + 2.6, -7.5, top + 2.6], Color("6f8496"))
	if _detail(1.0):
		for k in 9:
			var x := -6.4 + k * 1.6
			_l(x, top + 0.8, x, top + 2.5, w, 0.1)
	_poly([-8.2, top + 2.6, 8.2, top + 2.6, 5, top + 4.3, -5, top + 4.3], w)
	_poly([-5, top + 4.3, 5, top + 4.3, 2.4, top + 5.6, -2.4, top + 5.6], ws)
	# the spire
	_l(0, top + 5.6, 0, top + 15, Color("b5bcc4"), 0.35)
	_c(0, top + 15, 0.3, Color("e85a4a"))

## Mount Hood, Oregon's snowy volcano seen from Portland: a steep, pointed white cone over dark forested
## foothills, with tall evergreens in front.
static func _mount_hood() -> void:
	var rock := Color("7f8fa6")
	var far := Color("5c7a64")
	_poly([-40, 0, -40, 8, -22, 18, -12, 30, -5, 41, -1, 47, 1.5, 46, 6, 39, 14, 28, 24, 18, 40, 9, 40, 0], rock)
	# snow fields with dark ridges between them
	_poly([-14, 28, -9, 34.5, -5, 41, -1, 47, 1.5, 46, 6, 39, 11, 31, 14, 28, 10, 26, 7, 30, 4, 25, 1, 31, -2, 24,
		-5, 29, -9, 25], SNOW)
	_poly([1.5, 46, 6, 39, 11, 31, 14, 28, 10, 26, 7, 30, 4, 25, 1, 31], SNOW_S)
	if _detail(0.9):
		_l(-1, 46.5, -4, 33, rock.darkened(0.1), 0.35)
		_l(2.5, 44, 5, 31, rock.darkened(0.1), 0.35)
		_poly([-22, 18, -18, 22, -15, 20.5, -18, 18], SNOW)
		_poly([24, 18, 19, 22, 17, 20, 20, 18.5], SNOW_S)
	# the forested foothills
	_poly([-40, 0, -40, 12, -30, 15, -18, 12, -6, 14, 6, 11, 18, 14, 30, 12, 40, 13, 40, 0], far)
	_poly([-40, 0, -40, 6, -25, 8, -10, 6, 8, 7.5, 25, 6, 40, 7, 40, 0], far.darkened(0.15))
	_r(-40, 0, 40, 1.5, GRASS)
	# tall evergreens in front
	for p in [[-34, 15.0], [-29, 11.0], [-23, 13.0], [24, 12.0], [30, 16.0], [36, 11.0]]:
		_fir(p[0], 1, p[1], PINE)
