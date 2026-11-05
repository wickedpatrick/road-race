class_name LandmarksUsA
extends RefCounted
## American landmarks, drawn with LandmarkPainter's helpers (metres from the base point, y up).

const WHITE := Color("f2efe6")
const MARBLE := Color("e8e4da")
const LIBERTY := Color("7fb8a2")
const GRANITE := Color("b8ae9c")
const WATER := Color("4f8fc0")
const WATER_L := Color("9cc8e6")
const RIVER := Color("3f8f8a")
const ROCK := Color("8f8a80")
const GRASS := Color("5d8f42")
const TREE := Color("3f6f34")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const WOOD := Color("7a5634")
const GOLD := Color("d8b14a")
const BRASS := Color("c9a043")
const TYRE := Color("1e2226")
const US_RED := Color("b22234")
const US_BLUE := Color("3c3b6e")
const GLASS := Color("a9cfe0")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"statue_of_liberty": _statue_of_liberty()
		"empire_state_building": _empire_state_building()
		"uss_constitution": _uss_constitution()
		"liberty_bell": _liberty_bell()
		"us_capitol": _us_capitol()
		"washington_monument": _washington_monument()
		"niagara_falls": _niagara_falls()
		"duquesne_incline": _duquesne_incline()
		"rock_hall": _rock_hall()
		"model_t": _model_t()
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

## A small American flag on a pole standing at (x, y): the pole `h` high, the flag `fw` wide.
static func _us_flag(x: float, y: float, h: float, fw: float) -> void:
	_l(x, y, x, y + h, Color("d8d8d8"), fw * 0.06)
	var fh := fw * 0.55
	var top := y + h
	_r(x, top - fh, x + fw, top, US_RED)
	if _detail(1.5):
		for k in 3:
			var yy := top - fh + fh * (k * 2 + 1) / 7.0
			_r(x, yy, x + fw, yy + fh / 7.0, WHITE)
	else:
		_r(x, top - fh * 0.6, x + fw, top - fh * 0.4, WHITE)
	_r(x, top - fh * 0.55, x + fw * 0.42, top, US_BLUE)

## A spoked wheel with a dark tyre.
static func _wheel(x: float, y: float, r: float, rim: Color, spokes: int) -> void:
	_c(x, y, r, TYRE)
	_c(x, y, r * 0.75, rim)
	if spokes > 0:
		for k in spokes:
			var a: float = TAU * k / spokes
			_l(x, y, x + cos(a) * r * 0.72, y + sin(a) * r * 0.72, rim.darkened(0.35), 0.04)
	_c(x, y, r * 0.2, rim.darkened(0.25))

## The Statue of Liberty: the old star-shaped fort walls at her feet, the tall granite pedestal and the green copper
## lady in her robe, her torch with its golden flame held high, the tablet in her other arm and the spiked crown.
static func _statue_of_liberty() -> void:
	_r(-10, 0, 10, 0.8, GRASS)
	# the star fort: low walls with pointed bastions
	var fort := Color("a89f8c")
	_poly([-10, 0.8, -8.5, 4, -6, 3.2, -4.5, 5, 4.5, 5, 6, 3.2, 8.5, 4, 10, 0.8], fort)
	_poly([-10, 0.8, -8.5, 4, -7.5, 3.6, -8.6, 0.8], fort.lightened(0.12))
	_poly([-4.5, 5, -1, 5, -1, 0.8, -6, 0.8, -6, 3.2], fort.darkened(0.08))
	# the pedestal
	var gd := GRANITE.darkened(0.14)
	_r(-5, 5, 5, 8, GRANITE)
	_poly([-4.2, 8, 4.2, 8, 3.6, 19, -3.6, 19], GRANITE)
	_poly([-4.2, 8, -2.8, 8, -2.6, 19, -3.6, 19], GRANITE.lightened(0.1))
	_r(-4.1, 15.5, 4.1, 16.4, gd)
	_r(-4.0, 18.6, 4.0, 19.6, gd)
	if _detail(2.0):
		for x in [-1.8, 0.0, 1.8]:
			_r(x - 0.4, 11, x + 0.4, 14, gd)
	# the robe
	var g := LIBERTY
	var gd2 := LIBERTY.darkened(0.2)
	_poly([-2.6, 19.6, 2.4, 19.6, 2.0, 25, 1.9, 30, 1.6, 33.6, -1.6, 33.6, -2.0, 30, -2.2, 25], g)
	_poly([-2.6, 19.6, -1.0, 19.6, -1.2, 26, -1.0, 33.6, -1.6, 33.6, -2.0, 30, -2.2, 25], g.lightened(0.12))
	if _detail(1.6):
		_l(0.4, 19.8, 0.7, 28, gd2, 0.18)
		_l(1.4, 19.8, 1.5, 26, gd2, 0.15)
		_l(-0.3, 26, 1.6, 31, gd2, 0.18) # the sash
	# the tablet in her left arm (on the right as we look)
	_poly([1.4, 27.5, 3.0, 27.0, 3.3, 31.5, 1.7, 32.0], g.darkened(0.1))
	_l(1.6, 30.2, 3.1, 29.8, gd2, 0.15)
	# the raised right arm and the torch
	_poly([-1.6, 33.0, -0.8, 33.6, -1.6, 40.2, -2.4, 40.0], g)
	_poly([-2.6, 40.0, -1.4, 40.2, -1.6, 41.4, -2.5, 41.3], g.darkened(0.1))
	_r(-2.9, 41.3, -1.2, 41.8, GOLD.darkened(0.15))
	_poly([-2.8, 41.8, -1.3, 41.8, -1.6, 43.0, -2.0, 44.0, -2.3, 43.0], GOLD)
	_poly([-2.4, 41.8, -1.7, 41.8, -2.0, 43.2], Color("f6e08a"))
	# the head and crown
	_r(-0.5, 33.6, 0.5, 34.4, g)
	_c(0, 35.2, 1.0, g)
	_c(-0.25, 35.4, 0.55, g.lightened(0.12))
	_r(-1.1, 35.9, 1.1, 36.5, gd2)
	for k in 7:
		var a := lerpf(PI * 0.12, PI * 0.88, k / 6.0)
		_l(cos(a) * 0.9, 36.2 + sin(a) * 0.4, cos(a) * 2.2, 36.2 + sin(a) * 1.7, g, 0.22)

## The Empire State Building: the stepped Art Deco tower of pale limestone with its long window stripes, the
## setbacks near the ground and at the top, and the mooring mast with its thin spire.
static func _empire_state_building() -> void:
	var st := Color("d8d2c2")
	var sd := st.darkened(0.16)
	var strip := Color("7d7f86")
	_r(-12, 0, 12, 1, Color("9a968c"))
	# the low podium and the first setbacks
	_r(-12, 1, 12, 9, sd)
	_windows(-11.5, 11.5, 2, 8, 10, strip)
	_r(-10, 9, 10, 15, st)
	_r(-10, 9, -8, 15, sd)
	_windows(-9.5, 9.5, 9.5, 14.5, 8, strip)
	# the main shaft with its wings
	_r(-8.5, 15, 8.5, 52, st)
	_r(-8.5, 15, -5.5, 52, sd)
	_r(-3, 15, 3, 56, st.lightened(0.06))
	for x in [-7.5, -6.2, -4.5, -2.2, -0.7, 0.8, 2.3, 4.5, 6.2, 7.5]:
		_r(x - 0.35, 16, x + 0.35, 51 if absf(x) > 3 else 55, strip)
	# the top setbacks and the crown
	_r(-6, 52, 6, 56, st)
	_r(-6, 52, -4.5, 56, sd)
	_r(-4.5, 56, 4.5, 59.5, st)
	_r(-3.2, 59.5, 3.2, 62, st.lightened(0.04))
	_r(-2.2, 62, 2.2, 64, st)
	if _detail(1.0):
		for x in [-3.6, -1.2, 1.2, 3.6]:
			_l(x, 56.5, x, 59, strip, 0.3)
	# the mooring mast and spire
	_poly([-1.8, 64, 1.8, 64, 1.4, 70, -1.4, 70], Color("cfd2d6"))
	_r(-1.8, 66, 1.8, 66.6, sd)
	_poly([-1.0, 70, 1.0, 70, 0.6, 72.5, -0.6, 72.5], Color("b7bcc2"))
	_l(0, 72.5, 0, 80, Color("9aa0a6"), 0.35)

## USS Constitution, "Old Ironsides": the black wooden frigate with the white band of gun ports, three tall masts
## with square sails, the long bowsprit, and the American flag at her stern, afloat in Boston harbour.
static func _uss_constitution() -> void:
	_r(-28, 0, 28, 3, WATER)
	if _detail(1.0):
		_r(-25, 1.0, -15, 1.3, WATER_L)
		_r(5, 0.6, 18, 0.9, WATER_L)
	# the hull: black, with the white gun-port stripe and a copper bottom at the waterline
	var hull := Color("1f2124")
	_poly([-24, 2.5, 21, 2.5, 25, 9.5, 21, 9, -22, 9, -25, 11, -24.5, 6], hull)
	_poly([-24, 2.5, 21, 2.5, 22, 3.6, -24.2, 3.6], Color("9a5a38"))
	_poly([-24.3, 6.2, 22.6, 6.2, 23.4, 7.6, -24.6, 7.6], WHITE)
	if _detail(1.5):
		for k in 16:
			var x := -20.5 + k * 2.6
			_r(x, 6.5, x + 0.9, 7.3, hull)
	_poly([-25, 11, -22, 9, -21, 9, -22.5, 12], hull) # the raised stern
	# the bowsprit and jib-boom
	_l(22, 9.5, 28, 14, WOOD.darkened(0.2), 0.45)
	# masts, yards and sails
	var sail := Color("efe7d2")
	var sd := sail.darkened(0.1)
	var masts := [[-12.0, 34.0], [1.0, 40.0], [13.0, 33.0]]
	for m in masts:
		var x: float = m[0]
		var top: float = m[1]
		_l(x, 9, x, top, WOOD.darkened(0.25), 0.5)
		var span := (top - 9.0) / 3.0
		for k in 3:
			var y0 := 10.5 + k * span
			var y1 := y0 + span * 0.85
			var hw := 5.5 - k * 1.3
			_poly([x - hw, y1, x + hw, y1, x + hw * 1.08, y0, x - hw * 1.08, y0], sail)
			_poly([x - hw, y1, x - hw * 0.4, y1, x - hw * 0.45, y0, x - hw * 1.08, y0], sd)
			_l(x - hw - 0.3, y1, x + hw + 0.3, y1, WOOD.darkened(0.25), 0.25)
	# the jib sails at the bow
	_poly([19, 10, 27, 13.5, 13.5, 29], sail)
	_poly([16, 10, 24, 12.5, 13.2, 22], sd)
	# rigging
	if _detail(1.2):
		_l(-12, 34, -24, 11, DARK, 0.08)
		_l(13, 33, 27.5, 13.8, DARK, 0.08)
		_l(-12, 34, 1, 40, DARK, 0.08)
		_l(1, 40, 13, 33, DARK, 0.08)
	# the flag at the stern
	_l(-24, 11.5, -26.5, 15, WOOD.darkened(0.2), 0.2)
	_r(-27.8, 13.4, -26.3, 15.1, US_RED)
	_r(-27.8, 14.2, -26.3, 14.5, WHITE)
	_r(-27.1, 14.2, -26.3, 15.1, US_BLUE)
	_us_flag(1, 40, 2.5, 3.0)

## The Liberty Bell: the old bronze bell with its long crack and its name round the top, hanging from its dark
## wooden yoke in a frame, on a stone base.
static func _liberty_bell() -> void:
	_r(-2.5, 0, 2.5, 0.3, Color("a8a090"))
	# the frame
	var fw := Color("5a3c24")
	_r(-2.2, 0.3, -1.9, 4.5, fw)
	_r(1.9, 0.3, 2.2, 4.5, fw)
	_r(-2.4, 4.4, 2.4, 4.75, fw)
	_r(-2.2, 0.3, 2.2, 0.55, fw.darkened(0.15))
	# the yoke
	_poly([-1.3, 3.75, 1.3, 3.75, 1.5, 4.15, -1.5, 4.15], WOOD.darkened(0.3))
	_r(-0.1, 4.15, 0.1, 4.4, Color("3a3030"))
	# the bell
	var br := Color("8a6638")
	var bd := br.darkened(0.25)
	_poly([-0.5, 3.75, 0.5, 3.75, 0.7, 3.5, 0.78, 2.6, 0.95, 1.8, 1.25, 1.35, 1.45, 1.05, -1.45, 1.05, -1.25, 1.35,
		-0.95, 1.8, -0.78, 2.6, -0.7, 3.5], br)
	_poly([-0.5, 3.75, -0.2, 3.75, -0.35, 2.6, -0.6, 1.8, -1.1, 1.05, -1.45, 1.05, -1.25, 1.35, -0.95, 1.8,
		-0.78, 2.6, -0.7, 3.5], br.lightened(0.15))
	_r(-1.5, 1.0, 1.5, 1.2, bd) # the lip
	_r(-0.72, 3.15, 0.72, 3.25, bd) # the lettering band
	_r(-0.76, 2.95, 0.76, 3.02, bd)
	# the famous crack
	_pl([0.15, 1.05, 0.22, 1.5, 0.12, 1.9, 0.25, 2.3, 0.18, 2.75], Color("1e1a16"), 0.09)

static func _pl(xy: Array, col: Color, w: float) -> void:
	for k in range(0, xy.size() - 2, 2):
		_l(xy[k], xy[k + 1], xy[k + 2], xy[k + 3], col, w)

## A row of white columns from x0 to x1, y0 to y1.
static func _columns(x0: float, x1: float, y0: float, y1: float, n: int, col: Color) -> void:
	var step := (x1 - x0) / n
	for k in n:
		var x := x0 + step * (k + 0.5)
		_r(x - step * 0.22, y0, x + step * 0.22, y1, col)

## The United States Capitol: the long white building with its two wings, the columned portico with a pediment in
## the middle, and the great white dome on its ring of columns, crowned by the lantern and the Statue of Freedom.
static func _us_capitol() -> void:
	_r(-38, 0, 38, 2, GRASS)
	var wd := MARBLE.darkened(0.14)
	var sh := Color("b9b4a8")
	# the wings
	for s in [-1.0, 1.0]:
		var a: float = 16.0 * s
		var b: float = 38.0 * s
		_r(minf(a, b), 2, maxf(a, b), 13, MARBLE)
		_r(minf(a, b), 12.4, maxf(a, b), 13.4, wd)
		_windows(minf(a, b) + 1, maxf(a, b) - 1, 4, 6.5, 7, WIN)
		_windows(minf(a, b) + 1, maxf(a, b) - 1, 8.5, 11, 7, WIN)
		var c: float = 27.0 * s
		_r(c - 4.5, 2, c + 4.5, 14.2, MARBLE.lightened(0.04))
		_poly([c - 5, 14.2, c + 5, 14.2, c, 16.2], MARBLE)
		if _detail(1.2):
			_columns(c - 4.5, c + 4.5, 4, 13.2, 6, WHITE)
	# the central block and its portico
	_r(-16, 2, 16, 15, MARBLE)
	_r(-16, 14.5, 16, 15.6, wd)
	_windows(-15, -8, 5, 8, 3, WIN)
	_windows(8, 15, 5, 8, 3, WIN)
	_r(-7.5, 2, 7.5, 4.5, sh) # the steps
	_r(-7, 4.5, 7, 14, sh.darkened(0.15))
	_columns(-7, 7, 4.5, 14, 8, WHITE)
	_r(-7.5, 14, 7.5, 15.6, MARBLE)
	_poly([-8, 15.6, 8, 15.6, 0, 19], MARBLE)
	_poly([-6, 16, 6, 16, 0, 18.2], wd)
	# the dome: the drum with its columns, the attic and the cupola
	_r(-11, 15.6, 11, 18, MARBLE)
	_r(-10, 18, 10, 26, sh)
	_columns(-10, 10, 18, 25.4, 12, WHITE)
	_r(-10.5, 25.4, 10.5, 26.6, MARBLE)
	_r(-8.5, 26.6, 8.5, 30.5, MARBLE)
	_windows(-8, 8, 27.6, 29.6, 8, wd)
	_poly([-8.5, 30.5, 8.5, 30.5] + _arc(0, 30.5, 8.5, 10, 0, PI, 14), MARBLE.lightened(0.04))
	_poly([0, 30.5] + _arc(0, 30.5, 8.5, 10, PI * 0.62, PI, 6), MARBLE.darkened(0.06))
	if _detail(1.2):
		for k in 5:
			var a := lerpf(PI * 0.2, PI * 0.8, k / 4.0)
			_l(cos(a) * 8.0, 30.8, cos(a) * 3.0, 30.5 + sin(a) * 9.6, wd, 0.2)
	_r(-1.6, 39.8, 1.6, 43.5, MARBLE)
	_columns(-1.6, 1.6, 40.3, 43.0, 3, WHITE)
	_poly([-1.9, 43.5, 1.9, 43.5, 0, 45.2], MARBLE)
	_r(-0.3, 45.2, 0.3, 47.5, Color("6f6a5e")) # the Statue of Freedom
	_c(0, 48.0, 0.45, Color("6f6a5e"))

## The Washington Monument: the tall white marble obelisk with its pyramid tip (the stone a little different above
## a third of the way up, where the building paused for many years) and the ring of flags around its foot.
static func _washington_monument() -> void:
	_poly([-20, 0, 20, 0, 13, 3, -13, 3], GRASS)
	_r(-6, 3, 6, 3.5, Color("c9c4b8"))
	var m := MARBLE
	var m2 := Color("dcd4c4")
	# the obelisk
	_poly([-3, 3.5, 3, 3.5, 2.75, 22, -2.75, 22], m)
	_poly([-2.75, 22, 2.75, 22, 2.0, 64, -2.0, 64], m2)
	_poly([-3, 3.5, -0.6, 3.5, -0.45, 64, -2.0, 64, -2.75, 22], m.darkened(0.08))
	_poly([-2.0, 64, 2.0, 64, 0, 72], m2.lightened(0.05))
	_poly([-2.0, 64, -0.45, 64, 0, 72], m2.darkened(0.06))
	if _detail(1.5):
		_r(-0.6, 61.2, 0.6, 62.2, DARK)
	# the ring of flags: the far ones small and high, the near ones big and low
	for k in 14:
		var a := TAU * k / 14.0 + 0.11
		var x := cos(a) * 15.0
		var depth := sin(a) # 1 = far, -1 = near
		if depth > 0:
			_us_flag(x * 0.85, 2.2 + depth * 0.6, 8.0, 3.0)
	for k in 14:
		var a := TAU * k / 14.0 + 0.11
		var x := cos(a) * 15.0
		var depth := sin(a)
		if depth <= 0:
			_us_flag(x, 1.2 + (depth + 1.0) * 0.8, 9.0, 3.4)

## Niagara Falls: the great curved Horseshoe Falls pouring white over the cliff edge, the mist rising from below,
## green woods on the shores and the little blue tour boat in the green river.
static func _niagara_falls() -> void:
	# the far shore and the river above the falls
	_r(-43, 24, 43, 27, Color("6a9c50"))
	for x in [-38.0, -30.0, -22.0, 18.0, 27.0, 36.0]:
		_c(x, 27.5, 3.2, TREE)
		_c(x + 2.0, 28.2, 2.4, TREE.lightened(0.1))
	_r(-26, 22, 26, 25, WATER)
	# the cliffs on both sides
	_poly([-43, 0, -26, 0, -24, 22, -26, 25, -43, 25], ROCK)
	_poly([43, 0, 26, 0, 24, 22, 26, 25, 43, 25], ROCK)
	_poly([-43, 0, -32, 0, -31, 25, -43, 25], ROCK.darkened(0.1))
	_poly([43, 0, 34, 0, 33, 25, 43, 25], ROCK.lightened(0.08))
	# the horseshoe: the falling water, its brim dipping in the middle where it curves back
	var top := _arc(0, 24.0, 25, 7, PI, TAU, 16)
	var fall := [] + top
	fall.append_array([25, 5, -25, 5])
	_poly(fall, Color("dbeef6"))
	var mid := _arc(0, 24.0, 15, 4, PI, TAU, 10)
	mid.append_array([15, 8, -15, 8])
	_poly(mid, Color("b8dcea"))
	var brim := _arc(0, 24.0, 25, 7, PI, TAU, 16) # the green brim of the water at the edge
	var under := _arc(0, 22.6, 25, 7, TAU, PI, 16)
	_poly(brim + under, Color("5aa0a0"))
	if _detail(1.0):
		for k in 9:
			var x := -20.0 + k * 5.0
			_l(x, 22, x * 0.95, 7, WHITE, 0.5)
	# the lower river and the mist
	_r(-43, 0, 43, 6, RIVER)
	for x in [-24.0, -16.0, -8.0, 0.0, 8.0, 16.0, 24.0]:
		_c(x, 6.5, 4.0, Color(1, 1, 1, 0.85))
		_c(x + 3.5, 9.5, 2.8, Color(1, 1, 1, 0.55))
	# the little tour boat
	var boat := Color("2f5fa8")
	_poly([12, 0.4, 26, 0.4, 28, 3.2, 10.5, 3.2], boat)
	_r(13, 3.2, 24, 5.6, WHITE)
	_r(13.5, 5.6, 23.5, 6.2, boat.darkened(0.2))
	_windows(13.5, 23.5, 4.0, 5.0, 6, Color("5aa0e6"))

## The Duquesne Incline: the steep green slope of Mount Washington over Pittsburgh, the track on its wooden trestle
## and the little red cable cars with their stepped floors, the old station at the top and another at the bottom.
static func _duquesne_incline() -> void:
	_r(-22, 0, 22, 2, Color("5a7f9e")) # the river at the foot
	_poly([-22, 2, -14, 2, 12, 31, 16, 33, 22, 33, 22, 0, -22, 0], Color("6a9a4c"))
	_poly([-14, 2, 12, 31, 16, 33, 22, 33, 22, 26, 6, 18, -4, 4, -6, 2], GRASS.darkened(0.1))
	for p in [[2.0, 18.0], [10.0, 22.0], [17.0, 26.0], [-6.0, 6.0]]:
		_c(p[0], p[1], 2.2, TREE)
	# the trestle and rails
	var tr := Color("5a4632")
	if _detail(1.5):
		for k in 9:
			var t := k / 8.0
			var x := lerpf(-15.0, 11.0, t)
			var y := lerpf(4.0, 31.0, t)
			_l(x, y, x, maxf(2.0, y - 6.0 * (1.0 - t) - 1.5), tr, 0.35)
	_l(-15, 4, 11, 31, tr, 0.9)
	_l(-15, 4.6, 11, 31.6, Color("8a8e94"), 0.25)
	# the cars: red boxes stepped to keep the floor level on the slope
	for t in [0.32, 0.62]:
		var x := lerpf(-15.0, 11.0, t)
		var y := lerpf(4.0, 31.0, t) + 0.5
		var red := US_RED
		_poly([x - 2.0, y - 1.0, x + 1.6, y + 2.6, x + 1.6, y + 6.2, x - 2.0, y + 6.2], red)
		_r(x - 2.2, y + 6.2, x + 1.8, y + 6.8, Color("e0b84a"))
		_windows(x - 1.8, x + 1.4, y + 3.6, y + 5.6, 3, Color("f6e7b0"))
	# the top station
	var br := Color("8a5a3a")
	_r(11, 31, 21, 38, br)
	_poly([10.4, 38, 21.6, 38, 19.5, 40.5, 12.5, 40.5], Color("4a4f57"))
	_windows(12, 20, 33.5, 36.5, 4, Color("f2e2a8"))
	# the bottom station
	_r(-21, 2, -13, 7, br)
	_poly([-21.5, 7, -12.5, 7, -14, 8.8, -20, 8.8], Color("4a4f57"))
	_windows(-20, -14, 3.5, 6, 3, Color("f2e2a8"))

## The Rock and Roll Hall of Fame by Lake Erie: the big glass pyramid leaning against a white tower, the white drum
## sticking out on one side and the square block over the water on the other.
static func _rock_hall() -> void:
	_r(-28, 0, 28, 4, WATER)
	if _detail(1.0):
		_r(-26, 1.2, -18, 1.5, WATER_L)
		_r(18, 2.0, 26, 2.3, WATER_L)
	_r(-24, 3, 24, 5, Color("d6d2c8")) # the plaza
	# the white tower behind the glass
	_r(-1, 5, 6, 30, WHITE)
	_r(-1, 5, 0.5, 30, WHITE.darkened(0.08))
	_r(-1.5, 29, 6.5, 30, Color("d8d4ca"))
	# the glass pyramid
	_poly([-22, 5, 14, 5, 2.5, 25], GLASS)
	_poly([-22, 5, -6, 5, 2.5, 25], GLASS.lightened(0.18))
	if _detail(1.0):
		for k in 6:
			var t := (k + 1) / 7.0
			_l(lerpf(-22.0, 2.5, t), lerpf(5.0, 25.0, t), lerpf(14.0, 2.5, t), lerpf(5.0, 25.0, t), Color("e8f2f6"), 0.15)
		for k in 6:
			var x := lerpf(-22.0, 14.0, (k + 1) / 7.0)
			_l(x, 5, 2.5, 25, Color("e8f2f6"), 0.12)
	_l(-22, 5, 2.5, 25, WHITE, 0.4)
	_l(14, 5, 2.5, 25, WHITE, 0.4)
	# the drum on its one leg
	_r(17.5, 5, 18.5, 11, WHITE.darkened(0.1))
	_poly(_arc(18, 14, 5.5, 3.5, 0, TAU, 18), WHITE)
	_poly(_arc(18, 14, 5.5, 3.5, PI * 0.5, PI * 1.5, 9), WHITE.darkened(0.06))
	_r(13, 13.6, 23, 14.2, Color("c8c4ba"))
	# the block over the water
	_r(-27, 8, -18, 14, WHITE)
	_r(-27, 8, -25.5, 14, WHITE.darkened(0.08))
	_r(-23, 4, -22, 8, WHITE.darkened(0.12))

## A black Ford Model T, the car that put America on wheels: tall and square, with a brass radiator and lamps,
## thin wooden-spoked wheels, round fenders, running boards and a folding top.
static func _model_t() -> void:
	var bk := Color("1c1d20")
	var bl := Color("34363b")
	_r(-2.5, 0, 2.5, 0.08, Color("6f6a5e"))
	# the fenders and running board
	_poly(_arc(-1.25, 0.55, 0.62, 0.42, 0, PI, 8), bk)
	_poly(_arc(1.35, 0.55, 0.62, 0.42, 0, PI, 8), bk)
	_r(-0.65, 0.6, 0.75, 0.72, bk)
	# the body and the hood
	_poly([-2.0, 0.75, 0.7, 0.75, 0.7, 1.55, -0.4, 1.6, -0.5, 1.75, -2.0, 1.75], bk)
	_r(-1.95, 1.62, -0.6, 1.72, bl)
	_poly([0.7, 0.85, 1.75, 0.85, 1.75, 1.45, 0.7, 1.55], bk)
	_r(0.75, 1.42, 1.72, 1.48, bl)
	if _detail(10.0):
		for k in 4:
			_l(1.15 + k * 0.12, 1.0, 1.15 + k * 0.12, 1.3, bl, 0.03)
	# the brass radiator and lamps
	_r(1.75, 0.8, 1.9, 1.6, BRASS)
	_r(1.78, 0.85, 1.87, 1.52, Color("8a7030"))
	_c(1.98, 1.25, 0.12, BRASS)
	_c(2.0, 1.25, 0.07, Color("f6eec0"))
	# the seats and the folding top
	_r(-1.35, 1.75, -0.95, 2.1, Color("3a2a22"))
	_r(-0.2, 1.6, 0.15, 1.95, Color("3a2a22"))
	_r(0.62, 1.55, 0.7, 2.35, bl) # the windscreen frame
	_poly([0.66, 1.62, 0.7, 1.62, 0.7, 2.28, 0.66, 2.28], GLASS)
	_l(-1.95, 1.75, -1.75, 2.45, bk, 0.07)
	_l(0.65, 2.35, 0.65, 2.42, bk, 0.07)
	_poly([-1.85, 2.38, 0.75, 2.38, 0.75, 2.48, -1.65, 2.55], bk)
	# the wheels with wooden spokes
	_wheel(-1.25, 0.48, 0.45, Color("b88a4e"), 10)
	_wheel(1.35, 0.48, 0.45, Color("b88a4e"), 10)
