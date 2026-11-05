class_name LandmarksDeT2
extends RefCounted
## German landmarks of the towns between the map cities, drawn with LandmarkPainter's helpers (metres from the
## base point, y up).

const WHITE := Color("f2efe6")
const RED_ROOF := Color("b5432e")
const SLATE := Color("5a6470")
const COPPER := Color("5f9e86")
const BRONZE_G := Color("4f6f5f")
const WATER := Color("4f8fc0")
const WATER_L := Color("9cc8e6")
const ROCK := Color("8f8a80")
const GRASS := Color("5d8f42")
const TREE := Color("3f6f34")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const WOOD := Color("7a5634")
const GOLD := Color("e0b43a")
const DE_BLACK := Color("1f1f1f")
const DE_RED := Color("dd0000")
const DE_GOLD := Color("ffce00")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"kaiser_wilhelm_denkmal": _kaiser_wilhelm_denkmal()
		"deutsches_eck": _deutsches_eck()
		"andernach_geyser": _andernach_geyser()
		"wormser_dom": _wormser_dom()
		"bayer_cross": _bayer_cross()
		"grimm_monument": _grimm_monument()
		"technik_museum_sinsheim": _technik_museum_sinsheim()
		"rottweil_test_tower": _rottweil_test_tower()
		"donauquelle": _donauquelle()
		"wieskirche": _wieskirche()
		"bayertor": _bayertor()
		"schloss_ludwigslust": _schloss_ludwigslust()
		"malchow_swing_bridge": _malchow_swing_bridge()
		"doebeln_horse_tram": _doebeln_horse_tram()
		"atom_ei": _atom_ei()
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

## A round-topped window (or door) from x0..x1, y0 up to y1 including the arch.
static func _arch_win(x0: float, x1: float, y0: float, y1: float, col: Color) -> void:
	var rr := (x1 - x0) * 0.5
	_poly([x0, y0, x1, y0, x1, y1 - rr] + _arc(x0 + rr, y1 - rr, rr, rr, 0, PI, 6), col)

## A flag on its pole: the pole from (x, y) up `h`, the cloth `fw` wide, stripes given from the top.
static func _flag(x: float, y: float, h: float, fw: float, stripes: Array) -> void:
	_l(x, y, x, y + h, Color("8a8d92"), 0.18)
	var fh := fw * 0.62
	var s := fh / stripes.size()
	for k in stripes.size():
		_r(x, y + h - s * (k + 1), x + fw, y + h - s * k, stripes[k])

## A rounded tree crown on a trunk.
static func _tree(x: float, y: float, r: float) -> void:
	_r(x - r * 0.12, y, x + r * 0.12, y + r, WOOD)
	_c(x, y + r * 1.4, r, TREE)
	_c(x - r * 0.35, y + r * 1.6, r * 0.55, TREE.lightened(0.1))

## Flat [x, y, ...] points scaled by s, turned by `rot` and moved to (ox, oy).
static func _tf(xy: Array, ox: float, oy: float, s: float, rot: float) -> Array:
	var out := []
	for k in range(0, xy.size(), 2):
		var x: float = xy[k] * s
		var y: float = xy[k + 1] * s
		out.append_array([ox + x * cos(rot) - y * sin(rot), oy + x * sin(rot) + y * cos(rot)])
	return out

## Porta Westfalica: the Kaiser Wilhelm Monument high on the wooded Wittekindsberg over the Weser gap: a broad stone
## terrace and on it the domed canopy on columns sheltering the bronze emperor.
static func _kaiser_wilhelm_denkmal() -> void:
	_r(-22, 0, 22, 1.5, WATER)
	_poly([-22, 1.5, -18, 7, -12, 11, -6, 12.5, 6, 12.5, 12, 11, 18, 7, 22, 1.5], TREE)
	_poly([-22, 1.5, -18, 7, -14, 9, -12, 5, -14, 1.5], TREE.lightened(0.1))
	_poly([10, 1.5, 15, 8, 18, 7, 22, 1.5], TREE.darkened(0.1))
	var st := Color("cdbf9f")
	var sd := st.darkened(0.2)
	# the terrace with its ring wall and the stairs
	_r(-17, 11, 17, 16, st)
	_r(-17, 11, 17, 12, sd)
	_r(-17.5, 15.6, 17.5, 16.4, sd)
	_poly([-3, 11, 3, 11, 2, 16, -2, 16], sd)
	if _detail(1.2):
		for y in [12.0, 13.0, 14.0, 15.0]:
			_r(-2.6 + (y - 11) * 0.2, y, 2.6 - (y - 11) * 0.2, y + 0.3, st.lightened(0.1))
	# the canopy
	_r(-7.5, 16.4, 7.5, 18.5, st)
	_r(-5.2, 18.5, 5.2, 27.5, Color("3e3a34")) # the shade inside
	for x in [-6.6, -5.0, 5.0, 6.6]:
		_r(x - 0.6, 18.5, x + 0.6, 27.5, st)
		_r(x - 0.6, 18.5, x - 0.2, 27.5, st.lightened(0.1))
	# the bronze emperor in his long coat
	var b := BRONZE_G
	_r(-1.4, 18.5, 1.4, 19.3, st.darkened(0.1))
	_poly([-1.3, 19.3, 1.3, 19.3, 1.0, 23.5, 1.2, 24.5, -1.2, 24.5, -1.0, 23.5], b)
	_c(0, 25.3, 0.75, b)
	_l(1.0, 24.0, 2.0, 21.5, b, 0.4)
	_r(-7.8, 27.5, 7.8, 29.2, st)
	_r(-8.2, 29.2, 8.2, 29.8, sd)
	# the dome with its crown
	_poly([-7, 29.8] + _arc(0, 29.8, 7, 4.6, PI, 0, 12) + [7, 29.8], st)
	_poly([-7, 29.8] + _arc(0, 29.8, 7, 4.6, PI, PI * 0.62, 5) + [-2, 29.8], st.lightened(0.1))
	_r(-1.2, 34.2, 1.2, 35.2, sd)
	_poly([-0.9, 35.2, 0.9, 35.2, 0, 36], GOLD)

## Koblenz, the German Corner: the huge bronze-green Emperor William on horseback, a winged spirit walking beside,
## on his tall stone pedestal at the very tip where the Moselle flows into the Rhine, a German flag beside.
static func _deutsches_eck() -> void:
	_r(-18, 0, 18, 2, WATER)
	if _detail(1.0):
		_r(-15, 0.7, -8, 1.0, WATER_L)
		_r(9, 1.1, 15, 1.4, WATER_L)
	var st := Color("a59a86")
	var sd := st.darkened(0.18)
	# the point of land and the big pedestal with its steps
	_poly([-14, 2, 14, 2, 12, 4, -12, 4], sd)
	_r(-10, 4, 10, 6, st)
	_r(-7, 6, 7, 12, st)
	_r(-7, 6, -5.8, 12, st.lightened(0.1))
	_r(-7.6, 11.5, 7.6, 12.6, sd)
	_poly([-2, 6, 2, 6, 2, 9] + _arc(0, 9, 2, 1.6, 0, PI, 6), DARK)
	if _detail(1.2):
		for x in [-4.5, 4.5]:
			_r(x - 0.5, 6, x + 0.5, 11.5, sd)
	# the horse, walking right
	var b := BRONZE_G
	var bl := b.lightened(0.12)
	_l(-3.2, 12.6, -3.6, 15.5, b, 0.7)
	_l(-1.8, 12.6, -1.4, 15.5, b, 0.7)
	_l(2.4, 12.6, 2.8, 15.5, b, 0.7)
	_l(3.8, 13.8, 3.4, 15.5, b, 0.7)
	_l(3.8, 13.8, 4.6, 13.2, b, 0.6) # a front hoof lifted
	_ell(0.3, 16.4, 4.6, 2.0, 0, b)
	_poly([3.4, 16.0, 4.8, 16.6, 6.2, 19.4, 6.0, 20.6, 4.6, 20.2, 2.8, 17.6], b)
	_poly([5.6, 20.6, 6.4, 20.4, 7.6, 18.8, 7.0, 18.4, 5.6, 19.2], b)
	_poly([-4.2, 17.0, -5.4, 16.0, -5.8, 13.8, -4.8, 15.4], b)
	# the rider in his cloak
	_poly([-1.4, 17.4, 1.4, 17.4, 1.2, 21.6, -1.2, 21.6], bl)
	_poly([-1.4, 21.6, -2.6, 17.0, -1.0, 17.6], b)
	_c(0, 22.4, 0.85, bl)
	_l(0, 23.1, 0, 23.9, b, 0.25) # the spike on the helmet
	# the winged spirit walking ahead with the crown
	_poly([5.6, 12.6, 6.8, 12.6, 6.8, 17.0, 5.8, 17.0], b)
	_c(6.3, 17.7, 0.6, b)
	_poly([5.8, 16.4, 4.0, 19.8, 4.6, 17.0], bl)
	_flag(-13, 4, 9, 4.2, [DE_BLACK, DE_RED, DE_GOLD])

## Andernach: the world's highest cold-water geyser shooting its white fountain high over the Rhine meadows.
static func _andernach_geyser() -> void:
	_r(-12, 0, 12, 1.5, WATER)
	if _detail(1.0):
		_r(-10, 0.6, -4, 0.9, WATER_L)
	_r(-12, 1.5, 12, 3, GRASS)
	_tree(-9.5, 3, 1.6)
	_tree(9.5, 3, 1.9)
	# the stone ring round the hole
	_r(-3, 3, 3, 4, ROCK)
	_r(-3, 3.8, 3, 4.2, ROCK.lightened(0.2))
	# the column of water, widening as it rises
	var w := Color("e8f2fa")
	var wb := Color("bcd8ee")
	_poly([-1.2, 4.2, 1.2, 4.2, 2.0, 20, 2.8, 36, 1.8, 42, -1.8, 42, -2.8, 36, -2.0, 20], wb)
	_poly([-0.6, 4.2, 0.7, 4.2, 1.1, 24, 1.4, 40, -1.4, 40, -1.1, 24], w)
	for p in [[0, 44, 3.4], [-2.6, 42, 2.4], [2.8, 41.6, 2.6], [-1.2, 46.4, 2.2], [1.6, 46.8, 2.0], [-4.0, 39.0, 1.6],
			[4.4, 38.6, 1.6]]:
		_c(p[0], p[1], p[2], wb)
	for p in [[0, 44.2, 2.6], [-2.2, 42.4, 1.6], [2.4, 42.0, 1.8], [-0.8, 46.6, 1.5], [1.4, 47.0, 1.3]]:
		_c(p[0], p[1], p[2], w)
	# the falling spray
	if _detail(0.8):
		for p in [[-5.5, 34, 0.6], [5.8, 33, 0.6], [-6.2, 28, 0.5], [6.4, 27, 0.5], [-5.8, 21, 0.45], [6.0, 20, 0.45],
				[-5.0, 13, 0.4], [5.4, 12, 0.4]]:
			_c(p[0], p[1], p[2], wb)

## Worms Cathedral: the long Romanesque church of red sandstone with a round tower pair at each end, an
## octagonal tower with a pointed roof in the west and a lower dome in the east.
static func _wormser_dom() -> void:
	_r(-30, 0, 30, 1, GRASS)
	var st := Color("b0624c")
	var sd := st.darkened(0.18)
	var sl := st.lightened(0.1)
	var rf := Color("5b6766")
	# the nave
	_r(-20, 1, 20, 19, st)
	_poly([-20.5, 19, 20.5, 19, 18, 23, -18, 23], rf)
	for k in 7:
		var x := -16.5 + k * 5.5
		_arch_win(x - 1, x + 1, 11, 16, WIN)
		_arch_win(x - 0.9, x + 0.9, 4, 8, WIN)
	if _detail(1.2):
		for k in 20:
			var x := -19.5 + k * 2.05
			_poly([x, 18.4, x + 2.0, 18.4] + _arc(x + 1.0, 18.4, 1.0, 0.5, 0, PI, 4), sd)
	# the octagon towers in the middle of each end
	_r(-25, 1, -18, 30, sd)
	_r(-24, 1, -19, 30, st)
	_poly([-25.5, 30, -17.5, 30, -21.5, 37.5], rf)
	_arch_win(-22.5, -20.5, 24, 28, WIN)
	_r(18, 1, 26, 27, sd)
	_r(19, 1, 25, 27, st)
	_poly([17.6, 27] + _arc(22, 27, 4.4, 4.2, PI, 0, 10) + [26.4, 27], rf)
	_l(22, 31.2, 22, 33, GOLD, 0.2)
	_arch_win(21, 23, 21.5, 25.5, WIN)
	# the four round towers with their stone spires
	for x in [-28.0, -15.0, 15.0, 28.5]:
		_r(x - 1.8, 1, x + 1.8, 33, st)
		_r(x - 1.8, 1, x - 1.0, 33, sl)
		_r(x + 1.0, 1, x + 1.8, 33, sd)
		for y in [12.0, 20.0, 27.0]:
			_r(x - 2.0, y, x + 2.0, y + 0.5, sd)
		if _detail(1.0):
			_arch_win(x - 0.5, x + 0.5, 23.5, 26, WIN)
			_arch_win(x - 0.5, x + 0.5, 29, 31.5, WIN)
		_poly([x - 2.0, 33, x + 2.0, 33, x, 40], st.darkened(0.08))
		_poly([x - 2.0, 33, x - 0.6, 33, x, 40], sl)

## Leverkusen: the Bayer Cross, a giant ring 51 metres across with BAYER spelt across and down through the same Y, lit
## by thousands of lamps, hung between two steel masts.
static func _bayer_cross() -> void:
	var steel := Color("6c7680")
	# the two lattice masts
	for x in [-28.0, 28.0]:
		_l(x - 1.4, 0, x - 1.4, 72, steel, 0.35)
		_l(x + 1.4, 0, x + 1.4, 72, steel, 0.35)
		if _detail(0.9):
			for k in 18:
				var y := k * 4.0
				_l(x - 1.4, y, x + 1.4, y + 4, steel, 0.2)
		_c(x, 73, 0.9, Color("e04030"))
	_l(-29.4, 71, 29.4, 71, steel, 0.6)
	_l(-26.6, 42, -25.4, 42, steel, 0.8)
	_l(26.6, 42, 25.4, 42, steel, 0.8)
	_l(-12, 71, -9, 66.5, steel, 0.25)
	_l(12, 71, 9, 66.5, steel, 0.25)
	# the ring and the letters, glowing
	var cy := 42.0
	var glow := Color("fffbe0")
	_pl(_arc(0, cy, 25, 25, 0, TAU, 48), Color("c9a63a"), 2.2)
	_pl(_arc(0, cy, 25, 25, 0, TAU, 48), glow, 0.9)
	var letters := {
		"B": [[0, 0, 0, 1, 0.65, 1, 0.9, 0.88, 0.9, 0.62, 0.65, 0.5, 0, 0.5], [0.65, 0.5, 1, 0.38, 1, 0.12, 0.7, 0, 0, 0]],
		"A": [[0, 0, 0.5, 1, 1, 0], [0.22, 0.42, 0.78, 0.42]],
		"Y": [[0, 1, 0.5, 0.5, 1, 1], [0.5, 0.5, 0.5, 0]],
		"E": [[1, 1, 0, 1, 0, 0, 1, 0], [0, 0.5, 0.75, 0.5]],
		"R": [[0, 0, 0, 1, 0.65, 1, 0.95, 0.86, 0.95, 0.64, 0.65, 0.5, 0, 0.5], [0.4, 0.5, 1, 0]],
	}
	var word := "BAYER"
	for k in 5:
		var ch := word[k]
		var across := Vector2(-19 + k * 9.5, cy)
		var down := Vector2(0, cy + 19 - k * 9.5)
		var spots := [across] if ch == "Y" else [across, down]
		for at in spots:
			for s in letters[ch]:
				var pts := []
				for j in range(0, s.size(), 2):
					pts.append_array([at.x - 2.6 + s[j] * 5.2, at.y - 3.4 + s[j + 1] * 6.8])
				_pl(pts, Color("c9a63a"), 1.7)
				_pl(pts, glow, 0.9)

## Hanau: the Brothers Grimm monument on the market square, Wilhelm sitting and Jacob standing beside him in bronze
## over their big book of fairy tales, on a tall stone pedestal.
static func _grimm_monument() -> void:
	var st := Color("a8907a")
	var sd := st.darkened(0.2)
	_r(-4, 0, 4, 0.8, sd)
	_r(-3.2, 0.8, 3.2, 5.6, st)
	_r(-3.2, 0.8, -2.6, 5.6, st.lightened(0.1))
	_r(-3.6, 5.2, 3.6, 6.0, sd)
	if _detail(2.0):
		_r(-2.2, 2.6, 2.2, 3.8, sd) # the inscription
	var b := Color("4e5e4c")
	var bl := b.lightened(0.15)
	# Wilhelm on his chair, on the left
	_r(-2.6, 6.0, -0.6, 7.6, b)
	_r(-2.8, 7.4, -2.2, 9.6, b) # the back of the chair
	_poly([-2.3, 7.6, -0.9, 7.6, -1.0, 9.8, -2.1, 9.8], bl)
	_r(-1.0, 7.4, 0.4, 7.9, bl) # his lap
	_r(0.0, 6.0, 0.5, 7.6, b) # his legs
	_c(-1.5, 10.3, 0.55, bl)
	# Jacob standing on the right, leaning in
	_poly([0.9, 6.0, 2.6, 6.0, 2.5, 9.8, 1.2, 9.8], b)
	_poly([1.0, 6.0, 1.6, 6.0, 1.5, 8.4, 1.0, 8.4], bl)
	_c(1.75, 10.4, 0.6, bl)
	# the open book they share
	_poly([-0.6, 8.0, 0.4, 8.3, 1.2, 8.0, 1.2, 8.5, 0.4, 8.8, -0.6, 8.5], Color("d8c89a"))
	_l(1.3, 9.2, 0.6, 8.4, b, 0.3)

## A long white supersonic jet seen from the side, nose to the right, at (ox, oy), `s` times its 30 m drawing, raised
## by `rot`, with a dropped nose and a stripe of colour along it.
static func _sst(ox: float, oy: float, s: float, rot: float, stripe: Color) -> void:
	var w := Color("eef0f2")
	var g := Color("b8bec6")
	# the delta wing under the body
	_poly(_tf([-12, -0.3, 2, -0.3, -9, -2.4, -13, -2.4], ox, oy, s, rot), g)
	# the engines under the wing
	_poly(_tf([-12, -2.4, -6, -2.4, -6, -3.4, -12.5, -3.4], ox, oy, s, rot), Color("8a9098"))
	# the body and its drooped nose
	_poly(_tf([-15, -0.8, 12, -0.8, 14.5, -1.1, 15.5, -1.5, 13.5, 0.6, 11, 1.2, -12, 1.2, -15, 0.6], ox, oy, s, rot), w)
	_poly(_tf([-15, 0.2, 13, 0.2, 13, -0.1, -15, -0.1], ox, oy, s, rot), stripe)
	# the tail fin
	_poly(_tf([-15, 0.9, -10, 0.9, -13.5, 5.0, -15.2, 5.0], ox, oy, s, rot), w)
	_poly(_tf([-14.8, 3.6, -13.0, 3.6, -13.5, 4.8, -15.0, 4.8], ox, oy, s, rot), stripe)
	if _detail(1.2):
		for k in 10:
			var p: Array = _tf([-9.0 + k * 2.0, 0.45], ox, oy, s, rot)
			_c(p[0], p[1], 0.18 * s, WIN)

## Sinsheim Auto & Technik Museum: the big museum hall with Concorde and the Russian Tupolev Tu-144 standing on its
## roof, both noses up as if they had just taken off.
static func _technik_museum_sinsheim() -> void:
	_r(-30, 0, 30, 1, Color("8a8a84"))
	var hall := Color("d6d8da")
	_r(-27, 1, 27, 12, hall)
	_r(-27, 11, 27, 12.6, Color("9aa0a8"))
	_r(-27, 1, 27, 2, Color("b0b4b8"))
	_r(-8, 1, 8, 8, Color("5a7896")) # the glass front
	if _detail(1.0):
		for x in [-4.0, 0.0, 4.0]:
			_l(x, 1, x, 8, Color("c8d0d8"), 0.2)
	_r(-6, 8.8, 6, 10.2, Color("c0392b")) # the sign
	if _detail(1.6):
		_windows(-25, -10, 4, 7, 4, Color("8a9aa8"))
		_windows(10, 25, 4, 7, 4, Color("8a9aa8"))
	# the stands on the roof
	_l(-14, 12.6, -13, 17.4, Color("6c7680"), 0.6)
	_l(14, 12.6, 15, 17.0, Color("6c7680"), 0.6)
	_sst(-13, 18.6, 0.95, 0.28, Color("2b4c8c"))
	_sst(14, 18.2, 1.0, 0.24, Color("c0392b"))

## Rottweil: the elevator test tower, the tallest visitor platform in Germany, a slim grey cylinder wrapped in a
## light spiralling skin, over the roofs of the old town.
static func _rottweil_test_tower() -> void:
	_r(-8, 0, 8, 1, GRASS)
	var c := Color("c6cacf")
	var cd := c.darkened(0.15)
	var skin := Color("eef0f2")
	_r(-5, 1, 5, 82, c)
	_r(-5, 1, -3.6, 82, cd)
	_r(3.4, 1, 5, 82, c.lightened(0.08))
	# the spiral of the skin round the tower
	var y := 3.0
	while y < 78:
		_l(-5, y, 5, y + 5, skin, 1.0)
		y += 7.0
	# the top with the platform
	_r(-5.6, 82, 5.6, 84, cd)
	_r(-5.0, 84, 5.0, 87, c)
	_windows(-4.6, 4.6, 84.6, 86.4, 4, WIN)
	_l(-5.6, 87.6, 5.6, 87.6, DARK, 0.25)
	_l(2.5, 87, 2.5, 90, DARK, 0.2)
	# little houses at its foot
	for h in [[-8, -4.6, 4.2, RED_ROOF], [4.8, 8, 3.8, Color("9a4a32")]]:
		_r(h[0], 1, h[1], h[2], Color("e8dcc0"))
		_poly([h[0] - 0.3, h[2], h[1] + 0.3, h[2], (h[0] + h[1]) * 0.5, h[2] + 2.2], h[3])

## Donaueschingen: the source of the Danube, a round spring basin behind a stone balustrade, and over it the white
## statue of Mother Baar showing the little young Danube the way to the sea.
static func _donauquelle() -> void:
	var st := Color("ddd6c4")
	var sd := st.darkened(0.15)
	_r(-10, 0, 10, 0.6, Color("a09a8c"))
	# the back wall of the niche
	_r(-8.5, 2.6, 8.5, 5.6, sd)
	_r(-8.5, 5.6, 8.5, 6.0, st)
	# the water in the basin
	_ell(0, 2.6, 8.4, 0.9, 0, Color("2f8a8a"))
	_ell(-1.5, 2.7, 4.0, 0.35, 0, Color("6cc0b8"))
	# the balustrade
	_r(-9, 0.6, 9, 1.0, st)
	if _detail(1.5):
		for k in 22:
			var x := -8.6 + k * 0.82
			_r(x - 0.17, 1.0, x + 0.17, 2.1, st)
	else:
		_r(-9, 1.0, 9, 2.1, st.darkened(0.05))
	_r(-9, 2.1, 9, 2.5, st.lightened(0.05))
	for x in [-9.0, 0.0, 9.0]:
		_r(x - 0.5, 0.6, x + 0.5, 2.7, st)
	# the white statues on their stone
	var m := Color("f4f2ec")
	_r(-1.6, 6.0, 1.6, 6.8, st)
	# Mother Baar sitting, her arm stretched out
	_poly([-1.4, 6.8, 0.6, 6.8, 0.3, 8.8, -1.0, 8.8], m)
	_c(-0.35, 9.3, 0.45, m)
	_l(0.0, 8.5, 1.8, 9.2, m, 0.3)
	# the young Danube, a child, at her knee
	_poly([0.8, 6.8, 1.6, 6.8, 1.5, 8.0, 0.9, 8.0], m)
	_c(1.2, 8.35, 0.32, m)

## Wieskirche near Steingaden: the white rococo pilgrimage church alone in its meadow, the oval nave under a tall grey
## roof, the long choir and the slim tower with its onion cap, the Alps behind.
static func _wieskirche() -> void:
	_poly([-20, 2, -14, 13, -9, 9, -3, 15, 4, 10, 11, 14, 20, 6, 20, 2], Color("8fa2b8"))
	_poly([-3, 15, -1.5, 13.6, -4.4, 13.6], WHITE)
	_poly([11, 14, 12.4, 12.8, 9.8, 12.8], WHITE)
	_r(-20, 0, 20, 2.5, GRASS)
	var w := WHITE
	var y := Color("e8d9a8")
	var rf := Color("6f7880")
	# the choir going east, behind the nave
	_r(2, 2.5, 14, 12, w)
	_poly([1.5, 12, 14.5, 12, 13.5, 14.5, 2.5, 17], rf)
	_windows(4, 13, 6, 10, 3, WIN)
	# the tower beside the choir
	_r(9, 2.5, 13.5, 22, w)
	_r(9, 2.5, 9.6, 22, y)
	_r(12.9, 2.5, 13.5, 22, y)
	_r(8.7, 15.5, 13.8, 16, y)
	_arch_win(10.4, 12.1, 17.5, 20.8, WIN)
	_poly([8.8, 22, 13.7, 22, 14.2, 23.8, 13.0, 25.6, 11.8, 26.6, 11.25, 27.8, 10.7, 26.6, 9.5, 25.6, 8.3, 23.8], rf)
	_r(10.9, 27.8, 11.6, 29.0, rf)
	_l(11.25, 29, 11.25, 31.2, GOLD, 0.18)
	# the oval nave with its high roof
	_r(-15, 2.5, 4, 14, w)
	for x in [-15.0, -10.0, -5.0, 0.0, 4.0]:
		_r(x - 0.4, 2.5, x + 0.4, 14, y)
	_poly([-15.6, 14, 4.6, 14, 2.2, 20.5, -1, 22.5, -9.6, 22.5, -12.8, 20.5], rf)
	_poly([-15.6, 14, -9, 14, -9.6, 22.5, -12.8, 20.5], rf.lightened(0.12))
	for x in [-12.5, -2.5]:
		_arch_win(x - 1.2, x + 1.2, 9, 12.6, WIN)
		if _detail(1.0):
			_c(x, 7.2, 0.8, WIN)
	_arch_win(-8.8, -6.2, 2.5, 7.5, Color("6a4a30")) # the door
	_r(-9.4, 7.8, -5.6, 8.4, y)

## Landsberg am Lech: the Bayertor, a tall Gothic town gate with a steep red roof between little corner turrets, its
## front full of carvings and the blue-and-white Bavarian arms, the town wall at its sides.
static func _bayertor() -> void:
	_r(-7, 0, 7, 0.6, Color("9a958a"))
	var w := Color("ece4d0")
	var wd := w.darkened(0.15)
	# the town wall on both sides
	for s in [-1.0, 1.0]:
		_r(s * 4, 0.6, s * 7, 7, wd)
		for k in 2:
			var x: float = s * (4.6 + k * 1.4)
			_r(x - 0.4, 7, x + 0.4, 7.8, wd)
	# the tower
	_r(-4, 0.6, 4, 25, w)
	_r(-4, 0.6, -3.2, 25, wd)
	_poly([-2, 0.6, 2, 0.6, 2, 4.4, 0, 6.6, -2, 4.4], DARK) # the pointed gateway
	for y in [8.0, 14.0, 20.0]:
		_r(-4.2, y, 4.2, y + 0.4, wd)
	# the Bavarian arms and the carvings
	_r(-1.4, 8.8, 1.4, 12.2, Color("f8f8f8"))
	if _detail(1.2):
		for i in 3:
			for j in 4:
				if (i + j) % 2 == 0:
					_r(-1.4 + i * 0.93, 8.8 + j * 0.85, -0.47 + i * 0.93, 9.65 + j * 0.85, Color("3a7cc8"))
	else:
		_r(-1.4, 8.8, 1.4, 12.2, Color("8ab4e0"))
	_r(-0.15, 15.0, 0.15, 18.6, Color("6a4a30")) # the cross
	_r(-1.0, 17.4, 1.0, 17.7, Color("6a4a30"))
	for x in [-2.8, 2.8]:
		_poly([x - 0.6, 14.4, x + 0.6, 14.4, x + 0.6, 18.4, x, 19.4, x - 0.6, 18.4], wd)
	_poly([-1.0, 21.0, 1.0, 21.0, 1.0, 23.0, 0, 24.0, -1.0, 23.0], WIN)
	# the steep roof and its little corner turrets
	_poly([-4.2, 25, 4.2, 25, 0, 35.5], RED_ROOF)
	_poly([-4.2, 25, -1.2, 25, 0, 35.5], RED_ROOF.lightened(0.12))
	for x in [-4.0, 4.0]:
		_r(x - 1.0, 23, x + 1.0, 28, w)
		_poly([x - 1.2, 28, x + 1.2, 28, x, 31.5], RED_ROOF.darkened(0.1))
	_l(0, 35.5, 0, 36, GOLD, 0.15)

## Ludwigslust Palace: the long baroque front of the dukes of Mecklenburg, its middle part higher, a row of stone
## statues standing all along the roof, and the cascade of water before it.
static func _schloss_ludwigslust() -> void:
	_r(-35, 0, 35, 1.2, GRASS)
	var st := Color("d8c39e")
	var sd := st.darkened(0.15)
	var wh := Color("f0ead8")
	# the wings
	_r(-31, 1.2, 31, 15, st)
	_r(-31.4, 15, 31.4, 16, sd)
	_r(-31, 1.2, 31, 2.2, sd)
	for row in [[3.4, 6.4], [8.4, 11.6]]:
		_windows(-30, -11, row[0], row[1], 8, WIN)
		_windows(11, 30, row[0], row[1], 8, WIN)
	_windows(-30, -11, 12.8, 14.2, 8, WIN)
	_windows(11, 30, 12.8, 14.2, 8, WIN)
	# the middle part, higher
	_r(-10, 1.2, 10, 19, st)
	_r(-10.4, 19, 10.4, 20, sd)
	for x in [-6.0, -2.0, 2.0, 6.0]:
		_r(x - 0.5, 2.2, x + 0.5, 18, wh)
	_poly([-1.5, 1.2, 1.5, 1.2, 1.5, 5] + _arc(0, 5, 1.5, 1.4, 0, PI, 6), Color("5a3b26"))
	_windows(-10, 10, 8.4, 12.6, 5, WIN)
	_windows(-10, 10, 14.4, 16.4, 5, WIN)
	_c(0, 21.4, 1.2, Color("8a7a62")) # the coat of arms
	# the statues on the roof
	if _detail(0.7):
		var xs := []
		for k in 12:
			xs.append(-29.8 + k * 1.6)
			xs.append(12.2 + k * 1.6)
		for x in xs:
			_r(x - 0.25, 16, x + 0.25, 17.4, wh)
			_c(x, 17.7, 0.3, wh)
		for k in 11:
			var x := -9.0 + k * 1.8
			_r(x - 0.25, 20, x + 0.25, 21.6, wh)
			_c(x, 21.9, 0.3, wh)
	# the cascade
	_r(-6, 0, 6, 1.2, Color("b8b0a0"))
	_r(-5, 0.3, 5, 1.0, WATER)
	if _detail(1.0):
		for x in [-3.6, -1.2, 1.2, 3.6]:
			_l(x, 0.3, x, 1.0, WATER_L, 0.3)

## Malchow: the old iron swing bridge from the island town to the shore across the lake; it turns aside on its middle
## pier so the boats can pass. A little boat waits, the brick convent church on the shore behind.
static func _malchow_swing_bridge() -> void:
	# the convent church behind
	var brick := Color("a5452f")
	_r(8, 2, 16, 8, brick)
	_poly([7.6, 8, 16.4, 8, 12, 10], Color("6a3a2a"))
	_r(16, 2, 19, 11, brick)
	_poly([15.8, 11, 19.2, 11, 17.5, 12], Color("6a3a2a"))
	_windows(9, 15, 3.5, 6.5, 3, WIN)
	_r(-20, 0, 20, 2.2, WATER)
	if _detail(1.0):
		_r(-16, 0.6, -9, 0.9, WATER_L)
		_r(4, 1.2, 12, 1.5, WATER_L)
	# the banks
	_poly([-20, 2.2, -12, 2.2, -10, 4.2, -20, 4.2], Color("9a958a"))
	_poly([20, 2.2, 12, 2.2, 10, 4.2, 20, 4.2], Color("9a958a"))
	_r(-20, 4.2, -10, 4.8, GRASS)
	_r(10, 4.2, 20, 4.8, GRASS)
	# a house on the island
	_r(-19, 4.8, -14, 8.4, Color("e6dcc4"))
	_poly([-19.4, 8.4, -13.6, 8.4, -16.5, 10.4], RED_ROOF)
	_windows(-18.5, -14.5, 6, 7.6, 2, WIN)
	# the middle pier and the bridge on it
	_r(-1.5, 0, 1.5, 3.6, Color("8a857a"))
	var ir := Color("3f5f52")
	_r(-10.5, 3.6, 10.5, 4.6, ir)
	_r(-10.5, 3.4, 10.5, 3.7, ir.darkened(0.2))
	_l(-10.5, 6.2, 10.5, 6.2, ir, 0.3) # the railing
	if _detail(0.9):
		for k in 15:
			var x := -10.5 + k * 1.5
			_l(x, 4.6, x, 6.2, ir, 0.12)
	_poly([-1.2, 6.2, 1.2, 6.2, 0, 7.6], ir) # the turning crown on top
	# a little boat waiting
	_poly([-8, 0.6, -3.5, 0.6, -2.6, 1.6, -8.8, 1.6], WHITE)
	_r(-7, 1.6, -5, 2.6, Color("d8dce0"))
	_r(-8.6, 1.4, -2.8, 1.6, Color("2b4c8c"))

## Döbeln: the horse-drawn tram, a little cream-and-red tram car on its rails pulled by a brown horse.
static func _doebeln_horse_tram() -> void:
	_r(-5, 0, 5, 0.12, Color("6a6a66"))
	var cream := Color("f0e2b8")
	var red := Color("9a2b28")
	# the car
	_r(-0.4, 0.55, 4.8, 1.3, red)
	_r(0.2, 1.3, 4.2, 3.4, cream)
	_windows(0.3, 4.1, 2.1, 3.1, 4, WIN)
	_r(-0.4, 3.4, 4.8, 3.75, red) # the roof
	_r(0.0, 3.75, 4.4, 3.95, Color("d8cca8"))
	for x in [-0.25, 4.65]:
		_l(x, 1.3, x, 3.4, red, 0.1) # the posts of the open platforms
	_c(0.9, 0.42, 0.42, DARK)
	_c(3.5, 0.42, 0.42, DARK)
	# the shaft and the horse
	_l(-0.4, 1.0, -1.8, 1.25, WOOD, 0.1)
	var h := Color("7a4a2a")
	for x in [-2.6, -2.2, -4.0, -3.6]:
		_l(x, 0.05, x, 1.1, h, 0.16)
	_ell(-3.1, 1.35, 1.1, 0.45, 0, h)
	_poly([-4.0, 1.4, -4.4, 1.6, -4.85, 2.2, -4.5, 2.35, -3.9, 1.8], h)
	_poly([-4.85, 2.2, -4.95, 1.95, -4.5, 1.9, -4.45, 2.2], h.darkened(0.15))
	_l(-2.0, 1.45, -1.8, 0.85, Color("3a2a1a"), 0.1) # the tail
	_l(-4.2, 1.85, -3.5, 1.75, Color("3a2a1a"), 0.1) # the mane

## Garching: the Atom Egg, the first research reactor in Germany, a shining silver egg-shaped dome on its low base,
## the town's own emblem.
static func _atom_ei() -> void:
	_r(-15, 0, 15, 1, GRASS)
	_tree(-12.5, 1, 1.8)
	_tree(12.8, 1, 2.0)
	var base := Color("b8b4aa")
	# a low building beside
	_r(5, 1, 12, 5, Color("d8d6d0"))
	_windows(5.5, 11.5, 2.2, 4, 3, WIN)
	_r(-10, 1, 10, 3.4, base)
	_r(-10, 3.2, 10, 3.6, base.darkened(0.15))
	# the egg
	var s := Color("e4e7ea")
	_poly(_arc(0, 3.6, 9, 17, 0, PI, 24), s)
	_poly([-9, 3.6] + _arc(0, 3.6, 9, 17, PI, PI * 0.62, 8) + [-2, 3.6], s.lightened(0.5))
	_poly([7, 3.6] + _arc(0, 3.6, 9, 17, PI * 0.12, 0, 4) + [9, 3.6], s.darkened(0.1))
	if _detail(1.0):
		for k in [-1.0, 1.0]:
			_pl(_arc(0, 3.6, 4.6 * k, 16.8, 0.0, PI * 0.5, 8), s.darkened(0.12), 0.15)
	_r(-1.4, 1, 1.4, 4.6, Color("5a5f66")) # the door
