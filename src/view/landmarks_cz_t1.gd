class_name LandmarksCzT1
extends RefCounted
## Czech landmarks of the towns between the map cities, drawn with LandmarkPainter's helpers (metres from the
## base point, y up).

const WHITE := Color("f2efe6")
const RED_ROOF := Color("b5432e")
const WATER := Color("4f8fc0")
const WATER_L := Color("9cc8e6")
const ROCK := Color("9a958a")
const GRASS := Color("5d8f42")
const TREE := Color("3f6f34")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const WOOD := Color("7a5634")
const GOLD := Color("d8b14a")
const BRONZE := Color("4f6b5e")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"podebrady_george": _podebrady_george()
		"karlova_koruna": _karlova_koruna()
		"pisek_stone_bridge": _pisek_stone_bridge()
		"blatna_castle": _blatna_castle()
		"karosa_bus": _karosa_bus()
		"chrudim_puppet": _chrudim_puppet()
		"novy_bor_glass": _novy_bor_glass()
		"panska_skala": _panska_skala()
		"hranice_abyss": _hranice_abyss()
		"cerveny_zamek": _cerveny_zamek()
		"kadan_castle": _kadan_castle()
		"stribro_bridge_gate": _stribro_bridge_gate()
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

static func _ell(cx: float, cy: float, rx: float, ry: float, rot: float, col: Color) -> void:
	LandmarkPainter._ell(cx, cy, rx, ry, rot, col)

static func _detail(min_pm: float) -> bool:
	return LandmarkPainter._pm > min_pm

## A rounded tree crown on a trunk.
static func _tree(x: float, y: float, r: float) -> void:
	_r(x - r * 0.12, y, x + r * 0.12, y + r, WOOD)
	_c(x, y + r * 1.4, r, TREE)
	_c(x - r * 0.35, y + r * 1.6, r * 0.55, TREE.lightened(0.1))

## Gothic window with a pointed top, framed in `frame`.
static func _gwin(x: float, y: float, w: float, h: float, frame: Color) -> void:
	_poly([x - w * 0.5 - 0.2, y - 0.2, x + w * 0.5 + 0.2, y - 0.2, x + w * 0.5 + 0.2, y + h - w * 0.5, x, y + h + 0.3,
		x - w * 0.5 - 0.2, y + h - w * 0.5], frame)
	_poly([x - w * 0.5, y, x + w * 0.5, y, x + w * 0.5, y + h - w * 0.5, x, y + h, x - w * 0.5, y + h - w * 0.5], WIN)

## Battlements along the top of a wall from x0 to x1 at height y.
static func _merlons(x0: float, x1: float, y: float, step: float, col: Color) -> void:
	var x := x0
	while x < x1 - step * 0.4:
		_r(x, y, minf(x + step * 0.55, x1), y + step * 0.6, col)
		x += step

## Poděbrady: the bronze statue of King George of Poděbrady on his horse, raising his sceptre, on a tall stone
## pedestal in the middle of the square.
static func _podebrady_george() -> void:
	var st := Color("b9b4a8")
	_r(-4.6, 0, 4.6, 1, st.darkened(0.1))
	_r(-3.6, 1, 3.6, 5, st)
	_r(-3.6, 1, -2.8, 5, st.lightened(0.1))
	_r(-4.0, 4.6, 4.0, 5.2, st.lightened(0.08))
	if _detail(2.0):
		_r(-2, 2.4, 2, 3.4, Color("8a8576")) # the plaque
	var b := BRONZE
	var bl := b.lightened(0.18)
	# the horse, walking to the left
	_ell(0.2, 7.4, 2.6, 1.1, 0, b)
	_poly([-1.6, 7.8, -2.4, 9.4, -3.0, 9.9, -3.7, 9.3, -3.2, 8.7, -2.4, 7.0], b) # neck and head
	_poly([-3.0, 9.9, -2.6, 10.5, -2.4, 9.8], b) # ear
	_l(-1.6, 6.8, -2.4, 5.2, b, 0.4)
	_l(-1.0, 6.6, -1.1, 5.2, b, 0.4)
	_l(1.6, 6.6, 1.9, 5.2, b, 0.4)
	_l(2.2, 6.8, 2.6, 5.2, b, 0.4)
	_poly([2.7, 7.8, 3.4, 7.4, 3.4, 5.9, 2.9, 6.6], b) # tail
	_ell(-0.2, 7.9, 1.6, 0.4, 0, bl)
	# the king, a cloak and a crown, his sceptre up
	_poly([-0.6, 8.2, 1.0, 8.2, 0.7, 10.6, -0.4, 10.6], b)
	_poly([0.4, 8.6, 1.6, 8.0, 1.0, 10.4], b.darkened(0.15)) # cloak
	_l(0.3, 7.6, 0.4, 6.4, b, 0.35) # the leg
	_c(0.15, 11.0, 0.45, b)
	_poly([-0.35, 11.3, 0.65, 11.3, 0.65, 11.8, 0.4, 11.55, 0.15, 11.85, -0.1, 11.55, -0.35, 11.8], GOLD.darkened(0.25))
	_l(-0.3, 10.2, -1.4, 11.0, b, 0.3)
	_l(-1.4, 10.6, -1.6, 11.9, b, 0.18)

## Karlova Koruna in Chlumec nad Cidlinou: Santini's baroque chateau built like a crown, the round, tall middle hall
## with its dome and lantern and the wings going out from it, on a little green hill.
static func _karlova_koruna() -> void:
	_poly([-22, 0, 22, 0, 18, 3, -18, 3], GRASS)
	_poly([-22, 0, -14, 0, -15, 3, -18, 3], GRASS.darkened(0.1))
	var w := Color("e9c98a")
	var wd := w.darkened(0.12)
	var wh := WHITE
	var roof := Color("6b4a3a")
	# the wings
	for s in [-1.0, 1.0]:
		var xa: float = s * 5.0
		var xb: float = s * 19.0
		_r(minf(xa, xb), 3, maxf(xa, xb), 11, w)
		_poly([minf(xa, xb) - 0.4, 11, maxf(xa, xb) + 0.4, 11, maxf(xa, xb) - 1.2 + (1.2 if s < 0 else 0.0), 13.2,
			minf(xa, xb) + 1.2 - (1.2 if s > 0 else 0.0), 13.2], roof)
		_r(s * 18.6 - 0.4, 3, s * 18.6 + 0.4, 11, wh)
		_windows(minf(xa, xb) + 0.6, maxf(xa, xb) - 0.6, 4.5, 6.8, 5, WIN)
		_windows(minf(xa, xb) + 0.6, maxf(xa, xb) - 0.6, 8.2, 10.2, 5, WIN)
	# the round middle hall: shaded at both edges
	_r(-6, 3, 6, 15, w)
	_r(-6, 3, -4.6, 15, wd)
	_r(4.6, 3, 6, 15, wd)
	_r(-1.5, 3, 1.5, 15, w.lightened(0.07))
	_r(-6.3, 14.6, 6.3, 15.3, wh)
	for x in [-3.6, 0.0, 3.6]:
		_poly([x - 0.8, 7, x + 0.8, 7, x + 0.8, 11] + _arc(x, 11, 0.8, 0.8, 0, PI, 5), WIN)
	_poly([-1.3, 3, 1.3, 3, 1.3, 5.6] + _arc(0, 5.6, 1.3, 1.1, 0, PI, 5), Color("5a3b26"))
	# drum, dome and lantern with a little golden crown
	_r(-4, 15.3, 4, 16.6, w)
	_poly(_arc(0, 16.6, 4.6, 4.4, 0, PI, 14), roof)
	_poly(_arc(0, 16.6, 4.6, 4.4, PI * 0.55, PI, 6) + [0, 16.6], roof.lightened(0.15))
	_r(-0.8, 20.6, 0.8, 22, w)
	_poly([-1.2, 22, 1.2, 22, 1.2, 23.2, 0.6, 22.7, 0, 23.6, -0.6, 22.7, -1.2, 23.2], GOLD)

## Písek: the Stone Bridge over the Otava, the oldest bridge in the country, its Gothic arches of grey stone and the
## baroque saints standing along the parapet.
static func _pisek_stone_bridge() -> void:
	_r(-30, 0, 30, 3, WATER)
	if _detail(1.0):
		_r(-24, 1, -14, 1.3, WATER_L)
		_r(4, 1.8, 16, 2.1, WATER_L)
	_poly([-30, 0, -30, 9, -26, 9, -22, 0], GRASS)
	_poly([30, 0, 30, 9, 26, 9, 22, 0], GRASS)
	_tree(-28, 9, 1.5)
	_tree(28, 9, 1.6)
	var st := Color("a49d8f")
	var sd := st.darkened(0.2)
	_r(-27, 2, 27, 9, st)
	_r(-27.6, 8.6, 27.6, 10.2, st.lightened(0.1)) # the parapet
	# arches, the water showing through
	var n := 6
	var span := 52.0 / n
	for k in n:
		var cx := -26.0 + span * (k + 0.5)
		_poly([cx - span * 0.36, 0, cx + span * 0.36, 0, cx + span * 0.36, 3.2] + _arc(cx, 3.2, span * 0.36, 3.0, 0, PI, 8),
			sd)
		_poly([cx - span * 0.33, 0, cx + span * 0.33, 0, cx + span * 0.33, 3.0] + _arc(cx, 3.0, span * 0.33, 2.8, 0, PI, 8),
			WATER.darkened(0.25))
		if k > 0: # pointed cutwaters between the arches
			var px := -26.0 + span * k
			_poly([px - 0.9, 0, px + 0.9, 0, px + 0.9, 4, px, 5, px - 0.9, 4], st.darkened(0.08))
	if _detail(1.4):
		for x in range(-26, 27, 2):
			_r(x - 0.08, 2.4, x + 0.08, 8.6, st.darkened(0.06))
	# the statues of saints and a cross
	for x in [-17.5, -8.6, 8.6, 17.5]:
		_r(x - 0.6, 10.2, x + 0.6, 11.0, st.darkened(0.1))
		_poly([x - 0.5, 11, x + 0.5, 11, x + 0.35, 13.4, x - 0.35, 13.4], Color("6e6a62"))
		_c(x, 13.8, 0.4, Color("6e6a62"))
	_r(-0.12, 10.2, 0.12, 14.6, DARK)
	_r(-0.9, 13.2, 0.9, 13.45, DARK)

## Blatná: the water chateau standing on a rock in its pond, a tall Gothic palace with steep roofs, the slim tower
## with its pointed spire, and a fallow deer from the castle park on the bank.
static func _blatna_castle() -> void:
	_r(-22, 0, 22, 3, WATER)
	if _detail(1.0):
		_r(-12, 1, -2, 1.3, WATER_L)
		_r(8, 1.8, 18, 2.1, WATER_L)
	_poly([-22, 0, -22, 3.8, -15, 3.8, -13, 0], GRASS)
	_poly([-11, 2, 19, 2, 17, 4.4, -9, 4.4], ROCK)
	var w := Color("ece4d2")
	var wd := w.darkened(0.12)
	# the Renaissance wing on the right
	_r(10, 4.4, 18, 13, w)
	_poly([9.6, 13, 18.4, 13, 14, 17], RED_ROOF)
	_windows(10.5, 17.5, 6, 8, 3, WIN)
	_windows(10.5, 17.5, 9.8, 11.8, 3, WIN)
	# the Gothic palace
	_r(-9, 4.4, 5, 19, w)
	_r(-9, 4.4, -8, 19, wd)
	_poly([-9.6, 19, 5.6, 19, 3.4, 25.5, -7.4, 25.5], Color("8a3a2a"))
	_poly([-9.6, 19, -5, 19, -5.6, 25.5, -7.4, 25.5], Color("8a3a2a").lightened(0.12))
	for x in [-6.0, -2.0, 2.0]:
		_gwin(x, 8, 1.2, 3.2, wd)
		_gwin(x, 13.5, 1.2, 3.2, wd)
	# the slim tower with a tall spire
	_r(5, 4.4, 10, 25, w)
	_r(5, 4.4, 6, 25, wd)
	_gwin(7.5, 20.5, 1.1, 2.6, wd)
	_gwin(7.5, 14, 1.1, 2.6, wd)
	_r(4.6, 25, 10.4, 26, wd)
	_poly([4.6, 26, 10.4, 26, 7.5, 33.5], Color("3e4a44"))
	_poly([4.6, 26, 6.8, 26, 7.5, 33.5], Color("56645d"))
	_l(7.5, 33.5, 7.5, 34, GOLD, 0.12)
	# a fallow deer on the bank
	var dr := Color("a8683a")
	_ell(-18, 2.6, 1.3, 0.55, 0, dr)
	_l(-19.0, 2.4, -19.1, 0.8, dr, 0.18)
	_l(-17.0, 2.4, -16.9, 0.8, dr, 0.18)
	_l(-18.6, 2.3, -18.5, 0.8, dr, 0.18)
	_l(-17.4, 2.3, -17.5, 0.8, dr, 0.18)
	_poly([-19.0, 2.8, -19.6, 3.8, -20.3, 3.7, -19.6, 3.1], dr)
	_l(-19.6, 3.8, -20.1, 4.6, Color("6b4a2a"), 0.1)
	_l(-19.6, 3.8, -19.2, 4.6, Color("6b4a2a"), 0.1)
	if _detail(3.0):
		for p in [[-18.4, 2.8], [-17.6, 2.6], [-18.0, 2.3]]:
			_c(p[0], p[1], 0.12, Color.WHITE)

## Vysoké Mýto: the town where the Karosa buses are built, here an old Czech country bus in cream and red with its
## long row of windows.
static func _karosa_bus() -> void:
	var cr := Color("f1e6c8")
	var rd := Color("c0392b")
	_poly([-5.9, 0.5, 5.9, 0.5, 5.9, 3.0, 5.6, 3.25, -5.6, 3.25, -5.9, 3.0], cr)
	_r(-5.9, 0.5, 5.9, 1.25, rd)
	_r(-5.9, 1.55, 5.9, 1.7, rd)
	_r(-5.4, 3.25, 4.0, 3.45, cr.darkened(0.1)) # the roof
	# windows
	for k in 7:
		var x := -5.4 + k * 1.35
		_r(x, 2.0, x + 1.15, 3.0, Color("3d5566"))
	_r(4.4, 1.85, 5.85, 3.05, Color("5d7a8c")) # the windscreen
	_r(4.4, 2.95, 5.85, 3.2, DARK) # the route sign
	if _detail(3.0):
		_r(4.6, 2.98, 5.6, 3.15, Color("f2c94c"))
	_r(3.0, 0.6, 4.1, 2.95, Color("4a5a66")) # the door
	_l(3.55, 0.6, 3.55, 2.95, cr, 0.06)
	_r(5.6, 0.75, 5.9, 1.05, Color("fff3b0")) # headlight
	_r(-5.9, 0.75, -5.7, 1.05, Color("e04a3a"))
	for x in [-3.5, 3.6]:
		_c(x, 0.5, 0.52, DARK)
		_c(x, 0.5, 0.24, Color("9aa0a6"))

## Chrudim, the town of puppets: a wooden puppet theatre with its red curtains, Kašpárek in his red jester's cap
## with a bell bowing on the stage.
static func _chrudim_puppet() -> void:
	var wd := Color("8a5a34")
	var rd := Color("b8222e")
	# the booth
	_r(-3.8, 0, 3.8, 7.6, wd)
	_r(-3.8, 0, -3.3, 7.6, wd.lightened(0.12))
	_poly([-4.2, 7.6, 4.2, 7.6, 3.6, 8.9, -3.6, 8.9], rd)
	_r(-4.2, 7.4, 4.2, 7.7, GOLD)
	if _detail(3.0):
		for x in [-2.4, 0.0, 2.4]:
			_c(x, 8.25, 0.25, GOLD)
	_r(-3.0, 3.0, 3.0, 7.0, Color("2b2a3a")) # the stage opening
	_poly([-3.0, 7.0, -1.6, 7.0, -2.4, 5.2, -3.0, 3.0], rd) # curtains drawn aside
	_poly([3.0, 7.0, 1.6, 7.0, 2.4, 5.2, 3.0, 3.0], rd)
	_r(-3.2, 2.7, 3.2, 3.1, GOLD)
	_r(-3.4, 0.2, 3.4, 2.6, wd.darkened(0.15))
	if _detail(2.0):
		for x in [-2.0, 0.0, 2.0]:
			_c(x, 1.4, 0.45, Color("e8c35a"))
	# Kašpárek on a string from above
	_l(0, 7.0, 0, 6.6, Color("d8d2c2"), 0.04)
	_poly([-0.8, 3.1, 0.8, 3.1, 0.6, 4.6, -0.6, 4.6], Color("2f6fb5")) # body
	_r(-0.8, 3.7, 0.8, 3.95, Color("f2c94c"))
	_l(-0.6, 4.4, -1.4, 4.9, Color("2f6fb5"), 0.25)
	_l(0.6, 4.4, 1.4, 4.9, Color("2f6fb5"), 0.25)
	_c(-1.5, 5.0, 0.18, Color("f3c9a6"))
	_c(1.5, 5.0, 0.18, Color("f3c9a6"))
	_c(0, 5.1, 0.6, Color("f3c9a6")) # the face
	_c(-0.32, 4.95, 0.14, Color("e07a7a"))
	_c(0.32, 4.95, 0.14, Color("e07a7a"))
	_c(-0.2, 5.25, 0.06, DARK)
	_c(0.2, 5.25, 0.06, DARK)
	_c(0, 5.1, 0.1, Color("d94a3a"))
	_poly([-0.6, 5.5, 0.6, 5.5, 1.1, 6.4, 0.2, 5.9, -0.5, 6.5], rd) # the jester's cap
	_c(1.1, 6.4, 0.15, GOLD)
	_c(-0.5, 6.5, 0.15, GOLD)

## Nový Bor, the town of glassmakers: a big cut-glass vase in ruby and blue on a stone stand, a sparkling goblet
## beside it.
static func _novy_bor_glass() -> void:
	var st := Color("b9b4a8")
	_r(-3.6, 0, 3.6, 1.0, st)
	_r(-3.8, 0.9, 3.8, 1.2, st.lightened(0.1))
	# the vase
	var ruby := Color("b0233a")
	var x := 1.0
	_poly([x - 1.2, 1.2, x + 1.2, 1.2, x + 1.5, 1.6, x + 0.8, 2.0, x + 2.0, 4.0, x + 2.2, 6.0, x + 1.6, 7.6, x + 1.0, 8.4,
		x + 1.4, 9.4, x - 1.4, 9.4, x - 1.0, 8.4, x - 1.6, 7.6, x - 2.2, 6.0, x - 2.0, 4.0, x - 0.8, 2.0, x - 1.5, 1.6],
		ruby)
	_poly([x - 1.4, 9.4, x + 1.4, 9.4, x + 1.5, 9.7, x - 1.5, 9.7], ruby.lightened(0.3))
	# the cut facets: lighter diamonds, the glass shining
	for row in [[4.2, 3], [5.8, 3]]:
		var yy: float = row[0]
		for k in 3:
			var fx := x - 1.2 + k * 1.2
			_poly([fx, yy - 0.7, fx + 0.5, yy, fx, yy + 0.7, fx - 0.5, yy], ruby.lightened(0.35))
	_poly([x - 1.8, 4.0, x - 1.4, 4.0, x - 1.3, 7.0, x - 1.7, 6.8], Color(1, 1, 1, 0.55))
	_r(x - 1.9, 6.8, x + 1.9, 7.1, GOLD)
	# the goblet
	var bl := Color("2f6fb5")
	var g := -2.4
	_poly([g - 0.9, 1.2, g + 0.9, 1.2, g + 0.2, 1.5], bl)
	_r(g - 0.12, 1.4, g + 0.12, 3.0, bl.lightened(0.3))
	_c(g, 2.2, 0.2, bl)
	_poly([g - 0.2, 3.0, g + 0.2, 3.0, g + 1.0, 3.6, g + 1.1, 5.0, g - 1.1, 5.0, g - 1.0, 3.6], bl)
	_poly([g - 0.8, 3.8, g - 0.5, 3.8, g - 0.5, 4.8, g - 0.85, 4.8], Color(1, 1, 1, 0.5))
	if _detail(2.5):
		for p in [[x + 2.6, 8.2], [g + 1.4, 5.4], [x - 2.6, 3.0]]:
			_l(p[0] - 0.3, p[1], p[0] + 0.3, p[1], Color.WHITE, 0.07)
			_l(p[0], p[1] - 0.3, p[0], p[1] + 0.3, Color.WHITE, 0.07)

## Panská skála by Česká Kamenice: a wall of tall six-sided basalt columns standing side by side like organ pipes,
## the little pond at its foot and pines on top.
static func _panska_skala() -> void:
	_r(-20, 0, 20, 1.6, GRASS)
	_r(-9, 0, 9, 1.2, WATER)
	if _detail(1.0):
		_r(-6, 0.5, 2, 0.8, WATER_L)
	var cols := [9.0, 11.0, 12.5, 14.0, 15.0, 15.5, 16.0, 15.2, 14.6, 13.4, 12.0, 10.4, 9.0, 7.4]
	var n := cols.size()
	var cw := 2.2
	var x0 := -cw * n * 0.5
	var b := Color("5d5c60")
	for k in n:
		var x := x0 + k * cw
		var h: float = cols[k]
		var c := b.lightened(0.1) if k % 2 == 0 else b
		_r(x, 1.2, x + cw, h, c)
		_r(x, 1.2, x + 0.4, h, c.lightened(0.15))
		_r(x + cw - 0.3, 1.2, x + cw, h, c.darkened(0.2))
		_poly([x, h, x + cw, h, x + cw * 0.5, h + 0.6], c.lightened(0.2)) # the six-sided top seen slanted
		if _detail(1.5):
			_r(x, h * 0.55, x + cw, h * 0.55 + 0.15, c.darkened(0.25))
	# pines along the top
	for p in [[-12.0, 13.0], [-4.0, 16.4], [5.0, 16.4], [12.0, 12.4]]:
		var px: float = p[0]
		var py: float = p[1]
		_r(px - 0.2, py, px + 0.2, py + 0.8, WOOD)
		_poly([px - 1.4, py + 0.6, px + 1.4, py + 0.6, px, py + 3.0], TREE)
	_tree(-18, 1.6, 1.2)
	_tree(18, 1.6, 1.3)

## Hranice Abyss: the deepest flooded abyss in the world, a chasm between white limestone walls with forest on top,
## green-blue water deep down at its bottom.
static func _hranice_abyss() -> void:
	var lm := Color("cdc6b4")
	var ld := lm.darkened(0.2)
	# both walls of the chasm
	_poly([-22, 0, -22, 15, -9, 15, -7, 11, -8, 7, -5, 3, -5, 0], lm)
	_poly([22, 0, 22, 15, 9, 15, 8, 12, 9, 8, 6, 3, 6, 0], lm)
	_poly([-9, 15, -7, 11, -8, 7, -5, 3, -6.5, 3, -9.5, 8, -8.6, 12], ld)
	_poly([9, 15, 8, 12, 9, 8, 6, 3, 7.5, 3, 10.5, 9, 10, 13], ld)
	# the dark gap and the water, deep down
	_poly([-9, 15, 9, 15, 8, 12, 9, 8, 6, 3, -5, 3, -8, 7, -7, 11], Color("46524e"))
	_poly([-7, 11, 8, 12, 9, 8, 6, 3, -5, 3, -8, 7], Color("34403d"))
	_r(-5, 0, 6, 4.2, Color("1f7a78"))
	_r(-5.5, 3.0, 6.5, 4.2, Color("39a39a"))
	if _detail(1.5):
		_r(-2, 3.6, 3, 3.8, Color("9fe0d4"))
		_l(-20, 6, -12, 5, ld, 0.15)
		_l(13, 10, 20, 9, ld, 0.15)
	# forest on top and a viewing rail
	_r(-22, 15, -9, 16, GRASS)
	_r(9, 15, 22, 16, GRASS)
	for x in [-20.0, -16.5, -13.0, 12.5, 16.0, 19.5]:
		_tree(x, 16, 1.2)
	_l(-9.4, 16, -9.4, 17.2, WOOD, 0.15)
	_l(-12, 17.2, -9.4, 17.2, WOOD, 0.15)

## Hradec nad Moravicí: the Red Castle, a neo-Gothic castle of red brick with white trims, battlements, a round
## corner turret and the tall square tower, on its green hill.
static func _cerveny_zamek() -> void:
	_poly([-22, 0, 22, 0, 20, 3, -20, 3], GRASS)
	var br := Color("b23a2a")
	var bd := br.darkened(0.2)
	var wh := WHITE
	# the main building
	_r(-17, 3, 10, 16, br)
	_r(-17.2, 15.8, 10.2, 16.4, wh)
	_merlons(-17, 10, 16.4, 1.8, br)
	_r(-17.2, 9.4, 10.2, 9.8, wh)
	for x in [-12.0, -8.0, -4.0, 0.0, 4.0]:
		_gwin(x, 5, 1.2, 2.8, wh)
		_gwin(x, 11.4, 1.2, 2.8, wh)
	_poly([6.0, 3, 8.4, 3, 8.4, 5.8] + _arc(7.2, 5.8, 1.2, 1.2, 0, PI, 5), Color("4a2a20"))
	# the round corner turret
	_r(-20, 3, -15, 20, br)
	_r(-20, 3, -19, 20, bd)
	_r(-16, 3, -15, 20, bd)
	_r(-20.3, 19.8, -14.7, 20.4, wh)
	_merlons(-20.3, -14.7, 20.4, 1.4, br)
	_gwin(-17.5, 13.5, 1.0, 2.4, wh)
	# the tall square tower
	_r(10, 3, 17, 26, br)
	_r(10, 3, 11, 26, br.lightened(0.1))
	_r(9.6, 25.6, 17.4, 26.4, wh)
	_merlons(9.6, 17.4, 26.4, 1.6, br)
	for y in [8.0, 14.5, 20.5]:
		_gwin(13.5, y, 1.4, 3.0, wh)
	_l(13.5, 27.4, 13.5, 30, Color("8a8d92"), 0.15)
	_r(13.5, 28.4, 15.8, 29.9, Color("f2efe6"))
	_r(13.5, 28.4, 15.8, 29.15, Color("c8102e"))

## Kadaň Castle above the river Ohře: the long light palace with its high red roof and a tall tower, the old town
## walls along the river bank.
static func _kadan_castle() -> void:
	_r(-22, 0, 22, 2, WATER)
	if _detail(1.0):
		_r(-18, 0.8, -8, 1.1, WATER_L)
		_r(6, 1.2, 16, 1.5, WATER_L)
	_poly([-22, 2, 22, 2, 22, 6, -22, 6], GRASS.darkened(0.05))
	var st := Color("cbbf9f")
	# the town wall along the bank
	_r(-22, 4, 22, 8, st.darkened(0.15))
	_merlons(-22, 22, 8, 1.6, st.darkened(0.15))
	var w := Color("efe2c2")
	var wd := w.darkened(0.12)
	# the palace
	_r(-16, 8, 8, 19, w)
	_r(-16, 8, -15, 19, wd)
	_poly([-16.6, 19, 8.6, 19, 6, 25, -14, 25], RED_ROOF)
	_poly([-16.6, 19, -12, 19, -11, 25, -14, 25], RED_ROOF.lightened(0.12))
	_windows(-15, 7, 10.5, 13, 7, WIN)
	_windows(-15, 7, 15, 17.5, 7, WIN)
	for x in [-9.0, 1.0]:
		_r(x - 0.8, 25, x + 0.8, 26.5, w)
		_poly([x - 1.1, 26.5, x + 1.1, 26.5, x, 27.6], RED_ROOF)
	# the tower
	_r(8, 8, 14, 24, w)
	_r(8, 8, 9, 24, wd)
	_windows(9, 13, 18.5, 21, 2, WIN)
	_windows(9, 13, 12, 14.5, 2, WIN)
	_r(7.6, 24, 14.4, 25, wd)
	_poly([7.6, 25, 14.4, 25, 11, 30], RED_ROOF.darkened(0.1))
	_l(11, 30, 11, 30.6, GOLD, 0.12)
	_r(14, 8, 18, 15, wd) # a lower side building
	_poly([13.6, 15, 18.4, 15, 16, 17], RED_ROOF)

## Stříbro: the Renaissance bridge gate, a tall tower covered with black-and-white sgraffito and gables, standing at
## the end of the old stone bridge over the river Mže.
static func _stribro_bridge_gate() -> void:
	_r(-20, 0, 20, 2, WATER)
	if _detail(1.0):
		_r(-16, 0.8, -6, 1.1, WATER_L)
	_poly([8, 0, 20, 0, 20, 5, 8, 5], GRASS)
	var st := Color("a49d8f")
	# the bridge coming from the left
	_r(-20, 1.5, 6, 6, st)
	_r(-20, 6, 6, 7, st.lightened(0.1))
	for cx in [-15.0, -6.5]:
		_poly([cx - 3.2, 0, cx + 3.2, 0, cx + 3.2, 2.2] + _arc(cx, 2.2, 3.2, 2.6, 0, PI, 8), WATER.darkened(0.25))
	# the gate tower
	var w := Color("ece6d6")
	var sg := Color("3a3a3e")
	_r(4, 1.5, 14, 19, w)
	_r(4, 1.5, 5, 19, w.darkened(0.1))
	_poly([6.6, 1.5, 11.4, 1.5, 11.4, 6] + _arc(9, 6, 2.4, 2.2, 0, PI, 8), DARK)
	if _detail(1.0): # sgraffito: rows of black-and-white blocks
		for y in [9.0, 13.0]:
			for k in 5:
				var x := 4.5 + k * 2.0
				_r(x, y, x + 1.6, y + 1.2, sg)
				_r(x + 0.25, y + 0.25, x + 1.35, y + 0.95, w)
				_r(x + 0.6, y + 0.45, x + 1.0, y + 0.75, sg)
	_windows(5.5, 12.5, 16, 17.8, 2, WIN)
	_r(3.6, 19, 14.4, 19.6, w.darkened(0.15))
	# the stepped gables
	_poly([4, 19.6, 14, 19.6, 14, 20.8, 12.6, 20.8, 12.6, 22, 11, 22, 11, 23, 7, 23, 7, 22, 5.4, 22, 5.4, 20.8, 4, 20.8], w)
	_c(9, 21.2, 0.7, WIN)
	# the little roof lantern
	_poly([7.4, 23, 10.6, 23, 9, 25.5], Color("5f6b70"))
	_l(9, 25.5, 9, 26, GOLD, 0.12)
