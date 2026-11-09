class_name LandmarksCyA
extends RefCounted
## Cypriot landmarks, drawn with LandmarkPainter's helpers (metres from the base point, y up).

const HONEY := Color("d6b47a")
const LIME := Color("e6dcc2")
const WHITE := Color("f4f1ea")
const WIN := Color("3a4048")
const SEA := Color("2f8fb5")
const TURQ := Color("3fc0c4")
const FOAM := Color("e8f6f6")
const GRASS := Color("9aa356")
const PINE := Color("3f6a3a")
const PALM := Color("4f7f3a")
const TRUNK := Color("8a6a46")
const DARK := Color("2e3238")
const RED_ROOF := Color("b5543a")
const GOLD := Color("e0b43a")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"nicosia_walls": _nicosia_walls()
		"limassol_castle": _limassol_castle()
		"agios_lazaros": _agios_lazaros()
		"paphos_fort": _paphos_fort()
		"petra_tou_romiou": _petra_tou_romiou()
		"kamara_tou_koraka": _kamara_tou_koraka()
		"profitis_ilias_chapel": _profitis_ilias_chapel()
		"aphrodite_baths": _aphrodite_baths()
		"caledonia_falls": _caledonia_falls()
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

## An arched opening: a rectangle under a half circle.
static func _arched(x: float, y0: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.5, y0, x + w * 0.5, y0, x + w * 0.5, y0 + h - w * 0.5] + _arc(x, y0 + h - w * 0.5, w * 0.5, w * 0.5, 0, PI, 6), col)

## A date palm: a slightly bent trunk and a crown of drooping fronds.
static func _palm(x: float, h: float, lean: float) -> void:
	_poly([x - 0.35, 0, x + 0.35, 0, x + lean + 0.25, h, x + lean - 0.25, h], TRUNK)
	var top := Vector2(x + lean, h)
	for k in 7:
		var a := PI * (0.05 + k * 0.15)
		var tip := top + Vector2(cos(a) * 3.2, sin(a) * 1.4 - 1.2 + absf(cos(a)) * -0.6)
		_l(top.x, top.y, tip.x, tip.y, PALM if k % 2 else PALM.darkened(0.15), 0.55)
	_c(top.x, top.y, 0.6, PALM.darkened(0.25))

## A tall dark cypress.
static func _cypress(x: float, h: float) -> void:
	_poly([x - 0.9, 0.4, x + 0.9, 0.4, x + 0.5, h * 0.7, x, h, x - 0.5, h * 0.7], Color("2f4f2f"))

## Lefkosia's Venetian walls: the honey-coloured sloping curtain wall above the grassy dry moat, a heart-shaped
## bastion pushing out in front with its two round shoulders, and the old town behind: flat-roofed houses, the
## dome of Faneromeni and a bell tower, palms on the bastion.
static func _nicosia_walls() -> void:
	# the old town behind the wall
	var town := [Color("efe6d2"), Color("e3cfa6"), Color("f4efe4"), Color("dcc39a")]
	for k in 9:
		var x := -34.0 + k * 7.6
		_r(x, 8, x + 6.4, 12.5 + (k * 37 % 5) * 0.7, town[k % 4])
	_r(-20, 8, -14, 17, LIME) # Faneromeni: the drum and the dome
	_poly(_arc(-17, 17, 3.2, 3.2, 0, PI, 10), Color("c9a26a"))
	_l(-17, 20.2, -17, 21.6, DARK, 0.2)
	_r(14, 8, 17, 21, LIME) # a bell tower
	_poly([13.6, 21, 17.4, 21, 15.5, 22.6], RED_ROOF)
	if _detail(1.0):
		_arched(15.5, 17.5, 1.4, 2.4, WIN)
		_windows(-33, 33, 10, 11.4, 14, WIN)
	# the curtain wall, sloping outwards at its foot
	_poly([-36, 2, 36, 2, 36, 8.6, -36, 8.6], HONEY.darkened(0.08))
	_r(-36, 8.6, 36, 9.4, HONEY.lightened(0.1))
	# the moat
	_r(-36, 0, 36, 2.2, GRASS)
	# the bastion: two flanks in shadow, the pointed face in sun and the rounded shoulders (orillons)
	var b := HONEY
	_poly([-14, 0.6, -9, 1.4, -8, 9, -12.4, 8.6], b.darkened(0.2))
	_poly([14, 0.6, 9, 1.4, 8, 9, 12.4, 8.6], b.darkened(0.2))
	_poly([-9, 1.4, 0, -0.4, 9, 1.4, 8, 9, 0, 9.6, -8, 9], b)
	_l(0, -0.2, 0, 9.6, b.darkened(0.12), 0.3)
	_c(-13.2, 6.6, 2.4, b.darkened(0.1))
	_c(13.2, 6.6, 2.4, b.darkened(0.1))
	_poly([-8.2, 9, 0, 9.6, 8.2, 9, 8.2, 10, 0, 10.6, -8.2, 10], b.lightened(0.12)) # the parapet
	if _detail(0.8):
		for k in 6: # courses of stone
			var y := 2.4 + k * 1.2
			_l(-8.6 + k * 0.1, y, 8.6 - k * 0.1, y, b.darkened(0.1), 0.08)
	for p in [[-6.0, 7.0, 0.6], [5.0, 6.0, -0.5]]:
		_palm(p[0], 10.0 + p[1], p[2])
	_palm(-27, 13, 0.5)
	_palm(26, 12, -0.4)

## Limassol Castle: a squat honey-stone keep with a crenellated top, pointed windows, a stair up to the arched
## door, and palms in the garden in front.
static func _limassol_castle() -> void:
	_r(-20, 0, 20, 1, Color("b8a98a"))
	var s := Color("cfae78")
	_r(-15, 1, 15, 15, s)
	_r(-15, 15, 15, 15.8, s.lightened(0.1))
	for k in 11: # the merlons
		var x := -15.0 + k * 2.8
		_r(x, 15.8, x + 1.6, 17.4, s)
	_r(8, 1, 15, 18.5, s.darkened(0.08)) # the taller corner
	for k in 3:
		var x := 8.0 + k * 2.6
		_r(x, 18.5, x + 1.5, 19.8, s.darkened(0.08))
	if _detail(0.8):
		for y in [4.0, 7.0, 10.0, 13.0]:
			_l(-15, y, 15, y, s.darkened(0.08), 0.08)
	for x in [-11.0, -5.0, 11.5]:
		_poly([x - 0.6, 9, x + 0.6, 9, x + 0.6, 11, x, 12, x - 0.6, 11], WIN)
	# the stair up to the door
	for k in 5:
		_r(-3.0 + k * 0.8, 1.0 + k * 0.92, 5, 1.92 + k * 0.92, s.darkened(0.12 + k * 0.03))
	_poly([1.2, 5.6, 4.4, 5.6, 4.4, 8.6, 2.8, 9.8, 1.2, 8.6], DARK)
	# the garden
	_r(-20, 0, -8, 1.6, Color("6f9a46"))
	_r(-20, 0, 20, 0.4, Color("a59578"))
	_palm(-17, 11, 0.6)
	_palm(-10, 9, -0.3)
	_palm(18, 12, -0.6)

## The Church of St Lazarus in Larnaka: a long low stone church with an arcaded porch, and its tall bell tower of
## four storeys of arches, a little cupola and a cross on top.
static func _agios_lazaros() -> void:
	var s := Color("d8c39a")
	var sd := s.darkened(0.14)
	_r(-18, 0, 18, 0.6, Color("c7bba2"))
	# the church and its porch
	_r(-16, 0.6, 6, 11, s)
	_poly([-16.5, 11, 6.5, 11, 4.5, 13, -14.5, 13], sd)
	for k in 6:
		_arched(-14 + k * 3.4, 0.6, 2.4, 6.4, sd.darkened(0.25))
	_r(-16, 7.4, 6, 8.2, s.lightened(0.08))
	if _detail(1.0):
		for k in 4:
			_arched(-12 + k * 4.8, 9.2, 1, 1.4, WIN)
	# the bell tower in four storeys
	var x0 := 7.0
	var x1 := 15.0
	var y := 0.6
	for k in 4:
		var h: float = [9.0, 7.0, 6.0, 5.0][k]
		var inset := k * 0.6
		_r(x0 + inset, y, x1 - inset, y + h, s if k % 2 == 0 else s.lightened(0.05))
		_r(x0 + inset - 0.3, y + h - 0.6, x1 - inset + 0.3, y + h, sd)
		if k > 0:
			_arched((x0 + x1) * 0.5, y + 0.8, 2.6 - k * 0.3, h - 2.0, WIN)
			if k < 3:
				_arched(x0 + inset + 1.0, y + 1.2, 0.8, h - 3.0, WIN)
				_arched(x1 - inset - 1.0, y + 1.2, 0.8, h - 3.0, WIN)
		else:
			_arched((x0 + x1) * 0.5, y, 2.2, 4.4, DARK)
		y += h
	_poly(_arc((x0 + x1) * 0.5, y, 1.8, 2.2, 0, PI, 8), sd)
	_l(11, y + 2.2, 11, y + 4.2, GOLD, 0.25)
	_l(10.2, y + 3.5, 11.8, y + 3.5, GOLD, 0.25)
	_palm(-18, 10, 0.5)
	_palm(17.5, 9, -0.5)

## Paphos harbour castle: a square stone fort at the end of the mole, a small arched door, a parapet with
## merlons, the sea lapping at the quay and a blue-and-white fishing boat.
static func _paphos_fort() -> void:
	_r(-17, 0, 17, 2.4, SEA)
	if _detail(0.8):
		_l(-16, 1.2, -10, 1.2, FOAM, 0.12)
		_l(4, 0.8, 13, 0.8, FOAM, 0.12)
	_r(-14, 2.4, 14, 3.6, Color("bdb3a0")) # the mole
	var s := Color("cdb58a")
	_r(-8, 3.6, 8, 15, s)
	_r(-8.4, 15, 8.4, 16, s.lightened(0.1))
	for k in 6:
		var x := -8.4 + k * 3.2
		_r(x, 16, x + 1.8, 17.6, s)
	_r(-8, 3.6, -6.8, 15, s.darkened(0.15)) # the corner in shadow
	_arched(0, 3.6, 2.6, 4.4, DARK)
	_r(-1.8, 8.6, 1.8, 9.2, s.darkened(0.15)) # the slab over the door
	if _detail(0.8):
		for y in [6.0, 9.0, 12.0]:
			_l(-6.8, y, 8, y, s.darkened(0.08), 0.08)
		_r(4.2, 11, 5, 12.4, WIN)
		_r(-4.6, 11, -3.8, 12.4, WIN)
	# the fishing boat
	_poly([-15, 2.2, -9, 2.2, -8.4, 3.4, -15.6, 3.4], Color("2a6fb0"))
	_r(-15.6, 3.2, -8.4, 3.5, WHITE)
	_r(-12.8, 3.5, -11.4, 4.6, WHITE)
	_l(-12, 4.6, -12, 7.4, DARK, 0.12)

## Petra tou Romiou: the tall jagged limestone stack standing in the surf, smaller rocks beside it, the white
## chalk cliffs behind the pebble beach and foam around the rocks.
static func _petra_tou_romiou() -> void:
	_poly([-30, 3, -24, 10, -14, 12, -4, 11, 6, 13, 18, 12, 26, 9, 30, 6, 30, 3], Color("ece6d6")) # the cliffs
	_poly([-30, 9.6, -24, 10, -14, 12, -4, 11, 6, 13, 18, 12, 26, 9, 30, 6, 30, 8, 18, 13.5, 6, 14.4, -4, 12.6, -14, 13.4, -24, 11.4], Color("b8a35a"))
	_r(-30, 2.4, 30, 3.6, Color("bdb6a8")) # the pebble beach
	_r(-30, 0, 30, 2.6, SEA)
	_r(-30, 1.8, 30, 2.6, TURQ)
	# the great rock
	var rk := Color("d6cdb6")
	_poly([-10, 0.4, -9, 8, -7, 14, -4.5, 21, -2, 24, 0.5, 22, 2, 17, 4.5, 12, 6, 6, 7, 0.4], rk)
	_poly([-2, 24, 0.5, 22, 2, 17, 4.5, 12, 6, 6, 7, 0.4, 2.5, 0.4, 2, 8, 0.6, 15, -1, 21], rk.darkened(0.16))
	_poly([10, 0.4, 11, 5, 13.6, 7, 15.4, 4.4, 16, 0.4], rk.darkened(0.08))
	_poly([-17, 0.4, -16, 3, -14, 3.6, -13, 0.4], rk.darkened(0.1))
	for x in [-11.0, 8.0, 17.0, -18.0]:
		_l(x - 1.6, 0.6, x + 1.6, 0.6, FOAM, 0.4)
	if _detail(1.0):
		_l(-5, 9, -3, 13, rk.darkened(0.25), 0.12)
		_l(-7, 4, -6, 8, rk.darkened(0.25), 0.12)

## Kamara tou Koraka at Cape Greco: a natural bridge of pale limestone over turquoise water, the low cliff running
## on either side, maquis on top.
static func _kamara_tou_koraka() -> void:
	_r(-25, 0, 25, 3, SEA)
	_r(-25, 2, 25, 3, TURQ)
	var rk := Color("ddd2b4")
	var rd := rk.darkened(0.2)
	# the cliffs either side
	_poly([-25, 0, -25, 13, -12, 14, -9, 12, -9, 0], rk)
	_poly([25, 0, 25, 12, 14, 13.5, 10, 12, 10, 0], rk)
	# the arch
	_poly([-10, 0, -10, 12, 0, 14, 11, 12, 11, 0, 7, 0] + _arc(1.5, 0, 5.5, 8.5, 0, PI, 12) + [-4, 0], rk)
	_poly(_arc(1.5, 0, 5.5, 8.5, 0, PI, 12), Color("bfe0f0")) # the sky through the arch
	_r(-4, 0, 7, 2.6, SEA.lightened(0.1))
	_poly([-4, 0, -4, 2, -3.2, 5, -2.5, 6.6, -3, 0], rd)
	_r(-25, 0, 25, 1.2, SEA)
	_poly([-25, 11, -12, 12, -9, 10, -9, 7, -25, 8], rd.lightened(0.1))
	_poly([25, 10, 14, 11.5, 10, 10, 10, 7, 25, 7], rd.lightened(0.1))
	# maquis on top
	var g := Color("5f7a3c")
	for k in 12:
		var x := -24.0 + k * 4.2
		var top := 14.0 if absf(x) < 10 else 13.4
		_c(x, top, 0.9 + (k % 3) * 0.25, g if k % 2 else g.darkened(0.12))
	for x in [-6.0, 7.0, 15.0, -18.0]:
		_l(x - 1.4, 1.0, x + 1.4, 1.0, FOAM, 0.3)

## The Prophet Elias chapel above Protaras: a rocky knoll with the steps climbing it, and on top the little white
## chapel with its red dome, a bell gable and a cypress.
static func _profitis_ilias_chapel() -> void:
	var rk := Color("b09c76")
	_poly([-15, 0, -12, 6, -8, 12, -4, 17, 4, 18, 9, 14, 12, 8, 15, 0], rk)
	_poly([4, 18, 9, 14, 12, 8, 15, 0, 6, 0, 7, 8, 5, 14], rk.darkened(0.15))
	for k in 8:
		_c(-13.0 + k * 3.6, 1.0 + (k % 3) * 0.6, 1.0, Color("6f7f3c"))
	# the steps zigzagging up
	var st := Color("e9e2d2")
	_l(-12, 1, -2, 6, st, 0.6)
	_l(-2, 6, -9, 11, st, 0.6)
	_l(-9, 11, -2, 17, st, 0.6)
	if _detail(1.0):
		for k in 10:
			var t := k / 10.0
			_l(-12 + 10 * t, 1 + 5 * t + 0.3, -12 + 10 * t, 1 + 5 * t - 0.3, DARK, 0.06)
	# the chapel
	_r(-4, 17, 6, 23, WHITE)
	_r(-4.4, 23, 6.4, 23.6, Color("dcd6cc"))
	_r(-1, 23.6, 3, 25, WHITE)
	_poly(_arc(1, 25, 2.2, 2.6, 0, PI, 10), RED_ROOF)
	_l(1, 27.6, 1, 29, DARK, 0.18)
	_l(0.4, 28.5, 1.6, 28.5, DARK, 0.18)
	_r(4.4, 23.6, 6.2, 26.4, WHITE) # the bell gable
	_arched(5.3, 24, 0.8, 1.6, DARK)
	_arched(-1.6, 17, 1.6, 3.2, Color("4f6fa8"))
	_arched(3.2, 19.4, 0.8, 1.6, WIN)
	_cypress(9.5, 7)

## The Baths of Aphrodite near Polis: a little rock grotto with a dark mouth, the green pool beneath it, the old
## fig tree spreading over the water, ferns and a thin trickle down the rock.
static func _aphrodite_baths() -> void:
	var rk := Color("a8977a")
	_poly([-18, 0, -17, 8, -12, 14, -4, 16, 6, 15, 13, 12, 18, 6, 18, 0], rk)
	_poly([-8, 1.6, -8, 6, -5, 9, 0, 10, 5, 8.6, 7, 5, 7, 1.6], Color("3a3428")) # the grotto
	_poly([-18, 0, -18, 1.8, -8, 2.4, 7, 2.4, 18, 1.8, 18, 0], Color("3f7f6a")) # the pool
	_r(-6, 1.2, 4, 1.5, Color("6fae96"))
	_l(-1, 9.6, -1.2, 2.4, Color("cfe6ea"), 0.15) # the trickle
	# the fig tree, its trunk on the left bank leaning over
	var tr := Color("8f8a7a")
	_poly([-16, 1.6, -14.6, 1.6, -11, 10, -8, 13, -9, 14, -13, 11], tr)
	_l(-10, 12.4, -4, 15, tr, 0.6)
	var leaf := Color("4f7f3a")
	for p in [[-12.0, 15.0, 3.2], [-6.0, 16.6, 3.4], [0.0, 16.0, 2.8], [-15.0, 12.6, 2.4], [4.0, 14.6, 2.2]]:
		_c(p[0], p[1], p[2], leaf)
	for p in [[-10.0, 16.4, 1.6], [-4.0, 17.6, 1.6], [1.6, 17.0, 1.2]]:
		_c(p[0], p[1], p[2], leaf.lightened(0.12))
	if _detail(1.0):
		for x in [9.0, 11.0, 13.0, 15.0]: # ferns on the right
			_l(x, 2, x - 0.8, 4.4, Color("6f9a46"), 0.2)
			_l(x, 2, x + 0.8, 4.2, Color("6f9a46"), 0.2)

## The Caledonia waterfall in the Troodos: a dark rock wall, the white fall dropping into its pool, a stream with
## a little wooden footbridge, pines and plane trees around.
static func _caledonia_falls() -> void:
	var rk := Color("6b6458")
	_poly([-17, 0, -16, 14, -10, 20, -3, 24, 4, 23, 10, 19, 16, 12, 17, 0], rk)
	_poly([-3, 24, 4, 23, 10, 19, 16, 12, 17, 0, 6, 0, 5, 12, 3, 20], rk.darkened(0.18))
	# the fall
	_poly([-2.4, 22.6, 1.6, 22.6, 2.4, 3.4, -3, 3.4], Color("dfeef2"))
	if _detail(0.8):
		for x in [-1.6, -0.4, 0.8]:
			_l(x, 22, x + 0.2, 4, Color("b8d6e0"), 0.12)
	_poly(_arc(-0.2, 3.4, 4.4, 1.6, PI, TAU, 10), Color("cfe6ec"))
	_r(-17, 0, 17, 2.4, Color("4f8aa0")) # the pool and stream
	_c(-0.2, 2.6, 2.2, FOAM)
	# the footbridge
	var w := Color("7a5636")
	_r(6, 2.6, 14, 3.1, w)
	_l(6.2, 3.1, 6.2, 4.6, w, 0.2)
	_l(13.8, 3.1, 13.8, 4.6, w, 0.2)
	_l(6.2, 4.6, 13.8, 4.6, w, 0.15)
	# pines and plane trees
	for p in [[-14.0, 12.0], [-10.0, 15.0], [12.5, 14.0]]:
		_l(p[0], 0, p[0], p[1], TRUNK, 0.4)
		_poly([p[0] - 2.4, p[1] - 6, p[0] + 2.4, p[1] - 6, p[0], p[1] + 2], PINE)
		_poly([p[0] - 1.8, p[1] - 2.6, p[0] + 1.8, p[1] - 2.6, p[0], p[1] + 3.4], PINE.lightened(0.08))
	for p in [[-6.5, 6.0], [8.0, 7.6]]:
		_l(p[0], 0, p[0], p[1], Color("c8c0a8"), 0.4)
		_c(p[0], p[1] + 1.4, 2.4, Color("6f9a3a"))
		_c(p[0] + 1.2, p[1] + 2.4, 1.6, Color("7faa46"))
