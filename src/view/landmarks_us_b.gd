class_name LandmarksUsB
extends RefCounted
## American landmarks, drawn with LandmarkPainter's helpers (metres from the base point, y up).

const WHITE := Color("f2efe6")
const WATER := Color("4f8fc0")
const WATER_L := Color("9cc8e6")
const GRASS := Color("5d8f42")
const TREE := Color("3f6f34")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const WOOD := Color("7a5634")
const STEEL := Color("c9d1d8")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"cloud_gate": _cloud_gate()
		"willis_tower": _willis_tower()
		"spoonbridge_cherry": _spoonbridge_cherry()
		"mount_rushmore": _mount_rushmore()
		"gateway_arch": _gateway_arch()
		"kc_shuttlecocks": _kc_shuttlecocks()
		"nashville_parthenon": _nashville_parthenon()
		"memphis_riverboat": _memphis_riverboat()
		"georgia_aquarium": _georgia_aquarium()
		"american_bison": _american_bison()
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

## A rounded tree crown on a trunk.
static func _tree(x: float, y: float, r: float) -> void:
	_r(x - r * 0.12, y, x + r * 0.12, y + r, WOOD)
	_c(x, y + r * 1.4, r, TREE)
	_c(x - r * 0.35, y + r * 1.6, r * 0.55, TREE.lightened(0.1))

## A pointed pine.
static func _pine(x: float, y: float, h: float, col: Color) -> void:
	_poly([x - h * 0.28, y, x + h * 0.28, y, x, y + h], col)

## A person standing (a dark figure) of height h.
static func _person(x: float, h: float, col: Color) -> void:
	_r(x - h * 0.11, 0, x + h * 0.11, h * 0.82, col)
	_c(x, h * 0.9, h * 0.1, col)

## Cloud Gate, "the Bean", in Chicago's Millennium Park: a mirror-steel bean on its plaza with an arch under it,
## reflecting the blue sky and the skyline behind, and a few people for scale.
static func _cloud_gate() -> void:
	# the skyline behind
	var far := Color("93a8bd")
	var tops := [[-13, -10, 9], [-10.5, -8, 13.5], [-8, -5, 10], [-5, -2.5, 12], [2, 4.5, 11], [4.5, 7.5, 14],
		[7.5, 10, 9.5], [10, 13, 12.5]]
	for t in tops:
		var c := far if int(t[0]) % 2 == 0 else far.darkened(0.08)
		_r(t[0], 1, t[1], t[2], c)
		if _detail(2.5):
			_windows(t[0] + 0.3, t[1] - 0.3, t[2] - 2.5, t[2] - 1.5, 2, far.lightened(0.15))
	_r(-13, 0, 13, 1, Color("b7b2a8"))
	# the bean: its outline with the arch (the "omphalos") cut out underneath
	var bean := [] + _arc(0, 4, 10, 6, 0, PI, 18)
	bean += [-10, 3.2, -9.2, 1.8, -7.6, 1.1]
	bean += _arc(0, 1.1, 4.2, 2.6, PI, 0, 10)
	bean += [7.6, 1.1, 9.2, 1.8, 10, 3.2]
	_poly(bean, Color("8f9aa6"))
	# the sky in its top
	_poly(_arc(0, 4.6, 9.6, 5.2, 0, PI, 18), Color("a9cbe8"))
	_poly(_arc(0, 6.4, 7.5, 3.2, 0, PI, 14), Color("c6def2"))
	# the skyline reflected round the middle, bent by the curve
	var refl := Color("6f8196")
	for k in 13:
		var x := -8.4 + k * 1.4
		var hh := 1.2 + 1.4 * absf(sin(k * 1.7)) * (1.0 - absf(x) / 10.0)
		_r(x, 4.2, x + 1.0, 4.6 + hh, refl if k % 2 == 0 else refl.lightened(0.12))
	_poly([-9.6, 3.6, 9.6, 3.6, 9.9, 4.3, -9.9, 4.3], Color("7b8794"))
	# the plaza and people reflected low down
	_poly([-9.6, 3.4, -7.2, 1.6, -4.4, 1.8, -4.2, 2.8, -2.5, 3.2, 2.5, 3.2, 4.2, 2.8, 4.4, 1.8, 7.2, 1.6, 9.6, 3.4],
		Color("a3abb3"))
	# the shine
	_poly([-6.5, 8.4, -2.0, 9.6, -2.4, 9.2, -6.0, 8.0], Color("f2f7fb"))
	_l(5.5, 8.6, 7.6, 7.2, Color("e8f0f6"), 0.35)
	# the arch underneath, dark inside
	_poly(_arc(0, 1, 3.8, 2.3, 0, PI, 10), Color("5f6a75"))
	_poly(_arc(0, 1, 3.0, 1.6, 0, PI, 10), Color("7d8995"))
	_r(-13, 0, 13, 1, Color("b7b2a8"))
	_r(-13, 0.9, 13, 1.05, Color("a29d93"))
	_person(-11.5, 1.75, Color("3c4a6a"))
	_person(-0.8, 1.7, Color("8a3a2e"))
	_person(0.5, 1.15, Color("e0a830"))
	_person(11.2, 1.8, Color("2e3a2e"))

## The Willis Tower: black bundled tubes that end at different heights, the dark glass banded by lighter service
## floors, two white antennas on top, lower downtown buildings at its feet.
static func _willis_tower() -> void:
	var blk := Color("24272c")
	var tubes := [[-8, -4.8, 32], [-4.8, -1.6, 50], [-1.6, 1.6, 62], [1.6, 4.8, 62], [4.8, 8, 44]]
	for t in tubes:
		var x0: float = t[0]
		var x1: float = t[1]
		var h: float = t[2]
		_r(x0, 0, x1, h, blk)
		_r(x0, 0, x0 + 0.5, h, blk.lightened(0.1))
		_r(x0 + 0.5, 0, x0 + 0.65, h, Color("16181b"))
		_r(x0, h - 0.6, x1, h, Color("3a3e45"))
		if _detail(1.6):
			for y in range(3, int(h) - 1, 3):
				_r(x0 + 0.65, y, x1, y + 0.18, Color("3b3f46"))
		# the light service floors
		for y in [20.0, 37.0, 55.0]:
			if y < h - 1:
				_r(x0, y, x1, y + 0.8, Color("4b5059"))
	# the antennas
	_r(-1.0, 62, 0.0, 64, Color("cfd3d8"))
	_l(-0.5, 64, -0.5, 75, Color("e8eaec"), 0.45)
	_r(1.2, 62, 2.2, 63.6, Color("cfd3d8"))
	_l(1.7, 63.6, 1.7, 73, Color("e8eaec"), 0.45)
	_c(-0.5, 75, 0.35, Color("d84030"))
	# the lower city at its feet
	var lows := [[-12, -8.2, 16, Color("b8a48a")], [-11, -8.5, 9, Color("9aa3ad")], [8.2, 12, 20, Color("c9c3b6")],
		[8.6, 11.5, 11, Color("a46a52")]]
	for b in lows:
		var bx0: float = b[0]
		var bx1: float = b[1]
		var bh: float = b[2]
		_r(bx0, 0, bx1, bh, b[3])
		_r(bx0, bh - 0.5, bx1, bh, (b[3] as Color).darkened(0.12))
		if _detail(1.6):
			for y in range(2, int(bh) - 1, 3):
				_windows(bx0 + 0.3, bx1 - 0.3, y, y + 1.4, 3, WIN)

## Spoonbridge and Cherry in Minneapolis: a giant silver spoon arching over its pond, a shiny red cherry with its
## stem in the bowl, clipped hedges behind.
static func _spoonbridge_cherry() -> void:
	_r(-10, 0, 10, 3.2, Color("3f6f34"))
	for k in 6:
		_c(-8.5 + k * 3.4, 3.0, 1.2, Color("467a3a"))
	_r(-10, 0, 10, 1.6, WATER)
	if _detail(4.0):
		_r(-8, 0.6, -4, 0.8, WATER_L)
		_r(1, 0.3, 6, 0.5, WATER_L)
	# the handle, lying in the pond on the left and arching up to the bowl
	var sp := STEEL
	var handle := [-9.4, 1.4, -7.5, 1.9, -5, 2.8, -2.5, 3.6, 0, 4.1, 2.2, 4.3]
	_pl(handle, sp.darkened(0.25), 0.9)
	_pl(handle, sp, 0.6)
	_ell(-9.2, 1.5, 0.8, 0.45, 0.2, sp)
	# the bowl
	_ell(5.4, 4.2, 3.6, 1.4, -0.08, sp.darkened(0.2))
	_ell(5.4, 4.45, 3.3, 1.05, -0.08, sp.lightened(0.15))
	_ell(5.6, 4.6, 2.5, 0.6, -0.08, Color("aab4bd"))
	# the cherry and its stem
	_pl([6.2, 6.4, 6.0, 7.4, 5.3, 8.4, 4.4, 9.4], Color("8a5a2a"), 0.3)
	_c(6.3, 6.1, 1.6, Color("b8141e"))
	_c(6.7, 6.0, 1.3, Color("d0202a"))
	_c(5.7, 6.7, 0.35, Color("f6c8c8"))
	# reflections in the pond
	if _detail(4.0):
		_r(3.0, 1.0, 8.0, 1.2, Color("8fb2cc"))
		_r(5.5, 0.4, 7.0, 0.7, Color("c06070"))

## Mount Rushmore: four presidents' faces carved in the pale granite of a Black Hills mountain, the rubble of the
## carving below them and the dark pines all round.
static func _mount_rushmore() -> void:
	var gr := Color("bdb7ac")
	var gd := gr.darkened(0.2)
	_poly([-40, 0, -40, 22, -33, 32, -27, 39, -18, 43, -6, 44, 6, 42, 16, 40, 24, 36, 32, 30, 40, 22, 40, 0], gd)
	_poly([-33, 0, -31, 30, -25, 38, -17, 41.5, -6, 42.5, 6, 40.5, 15, 38.5, 22, 34, 28, 27, 31, 0], gr)
	# the faces
	_face(-20, 28.5, 5.2, 7.6, 0)
	_face(-8.5, 30, 4.6, 7.2, 1)
	_poly([-2, 21, 6.5, 21, 7.5, 34, 2, 36.5, -2.5, 33], gd)
	_face(2.6, 27.5, 3.6, 6.2, 2)
	_face(14.5, 28, 4.8, 7.6, 3)
	# the rubble slope below the carving
	_poly([-30, 0, -24, 17, -12, 20, 2, 19.5, 14, 18.5, 24, 15, 30, 0], Color("d6cfbf"))
	_poly([-30, 0, -24, 17, -16, 18.5, -20, 0], Color("c7bfaf"))
	# the pines
	var pc := Color("2f4f32")
	for k in 27:
		var x := -40.0 + k * 3.0
		var h := 7.0 + 4.0 * absf(sin(k * 2.3))
		_pine(x + 1.5, 0, h, pc if k % 2 == 0 else pc.lightened(0.08))
	for k in 6:
		_pine(-38.5 + k * 2.2, 8, 6.0 + k % 2, pc)
		_pine(28.5 + k * 2.2, 8, 6.0 + (k + 1) % 2, pc)

## One carved face: a lit oval with brow, eyes, nose, mouth and chin in shadow. Style 0 Washington, 1 Jefferson,
## 2 Roosevelt (glasses, moustache), 3 Lincoln (beard).
static func _face(x: float, y: float, rx: float, ry: float, style: int) -> void:
	var lit := Color("d9d3c6")
	var sh := Color("8f877a")
	var mid := Color("b2ab9e")
	if style == 0:
		_ell(x - rx * 0.9, y + ry * 0.35, rx * 0.55, ry * 0.5, 0.2, mid) # hair at the side
	if style == 3:
		_ell(x, y - ry * 0.45, rx * 0.95, ry * 0.6, 0, mid) # the beard
	_ell(x, y, rx, ry, 0, lit)
	_ell(x + rx * 0.45, y - ry * 0.05, rx * 0.55, ry * 0.9, 0, lit.darkened(0.06))
	# the brow
	_r(x - rx * 0.75, y + ry * 0.3, x + rx * 0.75, y + ry * 0.38, sh.lightened(0.15))
	# the eyes
	_ell(x - rx * 0.38, y + ry * 0.18, rx * 0.2, ry * 0.08, 0, sh)
	_ell(x + rx * 0.38, y + ry * 0.18, rx * 0.2, ry * 0.08, 0, sh)
	if style == 2:
		_pl(_arc(x - rx * 0.38, y + ry * 0.18, rx * 0.3, ry * 0.13, 0, TAU, 12), Color("6f685c"), 0.25)
		_pl(_arc(x + rx * 0.38, y + ry * 0.18, rx * 0.3, ry * 0.13, 0, TAU, 12), Color("6f685c"), 0.25)
	# the nose and its shadow
	_poly([x - rx * 0.06, y + ry * 0.12, x + rx * 0.14, y + ry * 0.12, x + rx * 0.24, y - ry * 0.3, x - rx * 0.1,
		y - ry * 0.3], lit.lightened(0.06))
	_poly([x + rx * 0.14, y + ry * 0.12, x + rx * 0.24, y - ry * 0.3, x + rx * 0.36, y - ry * 0.26], sh.lightened(0.1))
	# moustache or mouth
	if style == 2:
		_ell(x + rx * 0.05, y - ry * 0.4, rx * 0.36, ry * 0.07, 0, Color("756e62"))
	else:
		_r(x - rx * 0.3, y - ry * 0.47, x + rx * 0.35, y - ry * 0.42, sh)
	# the chin
	_ell(x + rx * 0.1, y - ry * 0.98, rx * 0.5, ry * 0.08, 0, sh.lightened(0.1))
	if style == 3:
		_r(x - rx * 0.75, y - ry * 0.6, x - rx * 0.7, y - ry * 0.2, mid.darkened(0.2))
		_r(x + rx * 0.7, y - ry * 0.6, x + rx * 0.75, y - ry * 0.2, mid.darkened(0.2))
	# the hair over the forehead
	_poly(_arc(x, y + ry * 0.55, rx * 0.95, ry * 0.45, 0.15, PI - 0.15, 10), mid if style != 1 else lit.darkened(0.03))

## The Gateway Arch in St. Louis: a stainless-steel catenary arch, the light outer face and the shaded inner one,
## narrowing towards the top, standing in a park.
static func _gateway_arch() -> void:
	_r(-35, 0, 35, 1, GRASS)
	var ht := 74.0
	var half := 29.0
	var b := 18.0
	var den := cosh(half / b) - 1.0
	var outer := []
	var mid := []
	var inner := []
	var n := 64
	for k in n + 1:
		var x := lerpf(-half, half, float(k) / n)
		var y := ht * (cosh(half / b) - cosh(x / b)) / den
		var dy := -ht * sinh(x / b) / b / den
		var nl := Vector2(-dy, 1).normalized()
		var t := lerpf(4.2, 2.0, y / ht) * 0.5
		outer.append_array([x + nl.x * t, maxf(0.0, y + nl.y * t)])
		mid.append_array([x, y])
		inner.append_array([x - nl.x * t, maxf(0.0, y - nl.y * t)])
	var rmid := []
	var rin := []
	for k in range(n, -1, -1):
		rmid.append_array([mid[k * 2], mid[k * 2 + 1]])
		rin.append_array([inner[k * 2], inner[k * 2 + 1]])
	for k in 8:
		var a := k * 8
		var e := mini(n, a + 9)
		_poly(outer.slice(a * 2, e * 2 + 2) + rmid.slice((n - e) * 2, (n - a) * 2 + 2), Color("dde3e8"))
		_poly(mid.slice(a * 2, e * 2 + 2) + rin.slice((n - e) * 2, (n - a) * 2 + 2), Color("9aa4ae"))
	# a glint up the left leg
	if _detail(1.0):
		_pl(outer.slice(8, 40), Color("f6f9fb"), 0.35)
	# the park
	for x in [-33.0, -24.0, -14.0, 14.0, 24.0, 33.0]:
		_tree(x, 1, 2.0)
	for x in [-6.0, 6.0]:
		_tree(x, 1, 1.6)

## The giant shuttlecocks on the lawn of the Nelson-Atkins Museum in Kansas City: one standing on its nose, one
## lying on its side, the pale museum behind.
static func _kc_shuttlecocks() -> void:
	# the museum far behind
	var st := Color("cfd6dc")
	_r(-12, 1, 12, 4.0, st)
	_r(-12, 4.0, 12, 4.4, st.darkened(0.08))
	_r(-3, 4.4, 3, 5.0, st.darkened(0.04))
	if _detail(6.0):
		for k in 11:
			var x := -2.8 + k * 0.55
			_r(x, 1.5, x + 0.22, 3.9, st.darkened(0.12))
	_r(-12, 0, 12, 1.4, GRASS)
	_r(-12, 1.3, 12, 1.5, GRASS.darkened(0.1))
	# standing: the nose on the lawn, the feathers up
	_shuttle_up(-5, 0.4)
	# lying on its side, the nose to the right
	var fe := Color("f5f3ee")
	var rib := Color("c8c4ba")
	_poly([0.2, 1.0, 0.6, 5.6, 6.3, 3.5, 6.3, 1.6], fe)
	if _detail(6.0):
		for k in 6:
			var t := float(k) / 5.0
			_l(lerpf(0.3, 0.6, t), lerpf(1.2, 5.4, t), 6.3, lerpf(1.7, 3.4, t), rib, 0.08)
	for k in 6:
		_c(0.32 + 0.06 * k, 1.25 + k * 0.85, 0.42, fe.darkened(0.04))
	_r(6.2, 1.5, 6.8, 3.6, Color("d6cfbd"))
	_poly([6.8, 1.5] + _arc(6.8, 2.55, 1.6, 1.05, -PI * 0.5, PI * 0.5, 10), Color("ece6d6"))
	_poly([6.8, 2.55] + _arc(6.8, 2.55, 1.3, 0.75, -PI * 0.5, 0, 5), Color("d2cab6"))

## A shuttlecock standing on its rounded nose at x, with the feather skirt widening upwards.
static func _shuttle_up(x: float, y: float) -> void:
	var fe := Color("f5f3ee")
	var rib := Color("c8c4ba")
	_poly(_arc(x, y + 1.6, 1.1, 1.6, PI, TAU, 10), Color("ece6d6"))
	_poly(_arc(x + 0.3, y + 1.6, 0.6, 1.3, PI * 1.4, TAU, 6) + [x + 0.3, y + 1.6], Color("d2cab6"))
	_r(x - 1.15, y + 1.6, x + 1.15, y + 2.2, Color("d6cfbd"))
	_poly([x - 1.0, y + 2.2, x + 1.0, y + 2.2, x + 2.5, y + 7.2, x - 2.5, y + 7.2], fe)
	_poly([x + 0.3, y + 2.2, x + 1.0, y + 2.2, x + 2.5, y + 7.2, x + 1.3, y + 7.2], fe.darkened(0.06))
	for k in 7:
		var t := float(k) / 6.0
		var tx := x + lerpf(-2.3, 2.3, t)
		_c(tx, y + 7.1, 0.42, fe.darkened(0.03))
		if _detail(6.0):
			_l(x + lerpf(-0.9, 0.9, t), y + 2.3, tx, y + 7.0, rib, 0.08)

## The Parthenon of Nashville: a full-size copy of the Athenian temple in Centennial Park, eight Doric columns on
## its stepped base, the frieze and the pediment above, trees on the lawn.
static func _nashville_parthenon() -> void:
	_r(-30, 0, 30, 1, GRASS)
	var st := Color("d8c8a2")
	var sd := st.darkened(0.15)
	var dk := Color("6b604e")
	# the stepped base
	_r(-25, 0.5, 25, 1.3, sd)
	_r(-24.4, 1.3, 24.4, 2.1, st.darkened(0.08))
	_r(-23.8, 2.1, 23.8, 2.9, st)
	# the dark porch behind the columns
	_r(-23, 2.9, 23, 13.6, dk)
	_r(-23, 2.9, 23, 4.0, dk.darkened(0.15))
	# the columns
	for k in 8:
		var x := -21.3 + k * 6.085
		_poly([x - 1.15, 2.9, x + 1.15, 2.9, x + 0.95, 13.2, x - 0.95, 13.2], st)
		_poly([x - 1.15, 2.9, x - 0.55, 2.9, x - 0.45, 13.2, x - 0.95, 13.2], st.lightened(0.08))
		_poly([x + 0.6, 2.9, x + 1.15, 2.9, x + 0.95, 13.2, x + 0.5, 13.2], sd)
		if _detail(2.5):
			_l(x, 3.0, x, 13.0, sd, 0.08)
		_r(x - 1.35, 13.2, x + 1.35, 13.9, st.lightened(0.04))
	# the architrave, the frieze with its triglyphs and the cornice
	_r(-23.6, 13.9, 23.6, 15.4, st)
	_r(-23.6, 15.4, 23.6, 17.0, st.darkened(0.05))
	if _detail(1.2):
		for k in 24:
			var x := -23.0 + k * 1.995
			_r(x, 15.5, x + 0.7, 16.9, sd)
	_r(-24.2, 17.0, 24.2, 17.5, sd)
	# the pediment with its sculptures
	_poly([-24.4, 17.5, 24.4, 17.5, 0, 22.5], st.lightened(0.04))
	_poly([-21.5, 18.0, 21.5, 18.0, 0, 21.8], st.darkened(0.1))
	if _detail(1.5):
		for k in 11:
			var x := -14.0 + k * 2.8
			var hh := 3.2 * (1.0 - absf(x) / 21.5)
			_r(x - 0.4, 18.0, x + 0.4, 18.0 + hh, st.lightened(0.06))
			_c(x, 18.0 + hh + 0.2, 0.35, st.lightened(0.06))
	_l(-24.4, 17.5, 0, 22.5, sd, 0.25)
	_l(24.4, 17.5, 0, 22.5, sd, 0.25)
	for x in [-28.0, 28.0]:
		_tree(x, 0.5, 2.0)

## A Mississippi paddle-wheel riverboat at the Memphis riverfront: a white boat of three decks with railings, the
## pilot house on top, two tall black stacks at the bow and the red wheel at the stern.
static func _memphis_riverboat() -> void:
	_r(-20, 0, 20, 2.0, Color("6f8a78"))
	if _detail(2.0):
		_r(-18, 0.7, -10, 0.9, Color("a3b8a6"))
		_r(4, 0.4, 12, 0.6, Color("a3b8a6"))
	var wh := Color("f4f2ec")
	var red := Color("b8262a")
	# the hull
	_poly([-18.5, 3.6, 15, 3.6, 15, 1.2, -15, 1.2], wh.darkened(0.08))
	_r(-15.5, 1.2, 15, 1.6, red)
	# the main deck
	_r(-15, 3.6, 13.5, 6.4, wh)
	_r(-15, 3.6, 13.5, 3.9, red)
	_windows(-13.5, 12.5, 4.3, 5.9, 12, WIN)
	_r(-16, 6.4, 14.2, 6.8, wh.darkened(0.06))
	# the second deck with its railing
	_r(-12, 6.8, 12, 9.4, wh)
	_windows(-11, 11, 7.2, 8.6, 10, WIN)
	if _detail(2.0):
		_r(-16, 7.6, -12, 7.75, DARK)
		_r(-12.6, 9.9, 12.6, 10.05, DARK)
		for k in 26:
			_r(-12.5 + k * 1.0, 9.4, -12.4 + k * 1.0, 10.0, DARK)
	_r(-12.6, 9.4, 12.6, 9.7, red)
	# the texas deck and the pilot house
	_r(-7, 9.7, 8, 11.8, wh)
	_windows(-6, 7, 10.2, 11.3, 7, WIN)
	_r(-7.6, 11.8, 8.6, 12.2, wh.darkened(0.06))
	_r(-4, 12.2, 0.5, 14.2, wh)
	_windows(-3.6, 0.1, 12.7, 13.6, 3, WIN)
	_poly([-4.6, 14.2, 1.1, 14.2, 0.3, 14.8, -3.8, 14.8], red)
	# a flag on the pilot house
	_l(-1.8, 14.8, -1.8, 16, DARK, 0.1)
	_r(-1.8, 15.4, -0.8, 16, Color("2a4a86"))
	# the stacks
	for x in [-11.5, -9.0]:
		_r(x - 0.45, 6.8, x + 0.45, 15.2, Color("1f2124"))
		_poly([x - 0.9, 15.2, x + 0.9, 15.2, x + 0.6, 14.6, x - 0.6, 14.6], Color("1f2124"))
		if _detail(2.0):
			for k in 5:
				_poly([x - 0.9 + k * 0.45, 15.2, x - 0.65 + k * 0.45, 16.0, x - 0.4 + k * 0.45, 15.2], GOLD_C)
	# the paddle wheel at the stern
	_r(13.5, 3.0, 19.6, 9.4, red.darkened(0.15))
	for k in 6:
		var y := 3.5 + k * 1.0
		_r(13.7, y, 19.4, y + 0.55, red)
	_r(13.5, 9.0, 19.6, 9.6, wh.darkened(0.1))
	_r(16.3, 2.6, 16.8, 9.4, Color("5a1a1c"))
	_r(-15, 1.8, 19.8, 2.1, Color("8fa69a"))

const GOLD_C := Color("d8b14a")

## The whale shark at the Georgia Aquarium in Atlanta: the huge viewing window, the dark-blue water with light
## coming down, the spotted whale shark, a manta ray and little fish, people watching in front.
static func _georgia_aquarium() -> void:
	_r(-15, 0, 15, 16, Color("2b2f36"))
	_r(-14, 1.2, 14, 15, Color("1b4f7f"))
	_r(-14, 9.5, 14, 15, Color("23629a"))
	_r(-14, 12.5, 14, 15, Color("2f78b2"))
	# light rays from above
	_poly([-9, 15, -7, 15, -11, 1.2, -12.5, 1.2], Color(0.7, 0.9, 1.0, 0.12))
	_poly([3, 15, 5.5, 15, 3, 1.2, 0.5, 1.2], Color(0.7, 0.9, 1.0, 0.1))
	# the sandy floor and rocks
	_r(-14, 1.2, 14, 2.4, Color("c9b98a"))
	_ell(-10, 2.4, 2.2, 1.0, 0, Color("7a7464"))
	_ell(10.5, 2.4, 2.6, 1.3, 0, Color("6e6a5c"))
	# the manta ray far behind
	_poly([5.5, 12.6, 8.5, 13.6, 11.5, 12.6, 8.5, 12.1], Color("18324f"))
	_l(8.5, 12.1, 8.5, 11.2, Color("18324f"), 0.15)
	# the whale shark: tail on the left, the broad flat head on the right
	var sk := Color("4a5f74")
	_poly([-10.5, 8.0, -12.8, 11.6, -12.0, 8.2, -12.6, 5.8], sk)
	_poly([-11, 7.9, -6, 9.4, 0, 10.4, 5.5, 10.2, 8.8, 9.4, 9.8, 8.6, 9.6, 7.4, 8.6, 6.6, 3.0, 6.0, -3.0, 6.3, -8.0,
		7.2], sk)
	_poly([-8.0, 7.2, -3.0, 6.3, 3.0, 6.0, 8.6, 6.6, 9.6, 7.4, 6.0, 7.4, 0, 7.2, -6.0, 7.6], Color("c9d3da"))
	_poly([-1.0, 10.3, 1.0, 12.4, 2.4, 10.4], sk) # the dorsal fin
	_poly([3.0, 6.6, 1.0, 4.4, 5.0, 6.3], sk.darkened(0.1)) # a pectoral fin
	_l(8.6, 7.6, 9.75, 7.9, Color("1e2833"), 0.15) # the wide mouth
	_c(8.2, 8.7, 0.18, Color("10161c"))
	# its white spots and stripes
	if _detail(1.5):
		for k in 22:
			var sx := -8.0 + (k % 11) * 1.5 + (k / 11) * 0.7
			var sy := 8.0 + (k / 11) * 1.2 + 0.3 * sin(k * 1.3)
			if sx < 8.0:
				_c(sx, sy, 0.16, Color("e6eef4"))
		for x in [-2.0, 0.5, 3.0]:
			_l(x, 7.4, x + 0.3, 10.0, Color("6c8296"), 0.08)
	# little yellow fish
	for f in [[-6, 12.6], [-4.5, 13.2], [-5.4, 4.2], [10, 4.6], [11.2, 5.4], [-1, 3.4]]:
		var fx: float = f[0]
		var fy: float = f[1]
		_ell(fx, fy, 0.45, 0.22, 0, Color("f0c030"))
		_poly([fx - 0.4, fy, fx - 0.75, fy + 0.25, fx - 0.75, fy - 0.25], Color("f0c030"))
	# the people watching
	_r(-15, 0, 15, 1.2, Color("1a1d22"))
	_person(-6.5, 1.8, Color("0e1013"))
	_person(-5.6, 1.1, Color("0e1013"))
	_person(4.5, 1.75, Color("0e1013"))

## An American bison of the Black Hills: a shaggy dark-brown front with its big hump and beard, the lighter short
## coat behind, short curved horns, on the prairie grass.
static func _american_bison() -> void:
	var gr := Color("8a9a4a")
	_r(-3.5, 0, 3.5, 0.25, gr)
	var rear := Color("7a5636")
	var mane := Color("4a3222")
	var leg := Color("3b281b")
	# the legs (the far ones darker)
	_r(-2.6, 0.15, -2.2, 1.3, leg.darkened(0.2))
	_r(1.3, 0.15, 1.7, 1.3, leg.darkened(0.2))
	_r(-2.2, 0.15, -1.75, 1.4, leg)
	_r(0.75, 0.15, 1.3, 1.5, leg)
	_poly([0.55, 1.6, 1.5, 1.6, 1.4, 0.8, 0.7, 0.8], mane) # the shaggy forelock on the front leg
	# the body: lighter behind
	_poly([-3.0, 1.2, -3.1, 2.1, -2.6, 2.6, -1.0, 2.75, 0.4, 2.9, 0.6, 1.2], rear)
	# the hump and the mane
	_poly([-0.4, 2.8, 0.2, 3.5, 1.0, 3.75, 1.8, 3.5, 2.5, 2.9, 2.8, 2.2, 2.6, 1.2, 2.2, 0.9, 0.6, 1.0, -0.3, 1.3],
		mane)
	_poly([-0.4, 2.8, 0.2, 3.5, 1.0, 3.75, 0.9, 3.1, 0.2, 2.7], mane.lightened(0.12))
	# the head held low, with its beard
	_poly([2.3, 2.6, 3.2, 2.3, 3.45, 1.2, 3.2, 0.85, 2.6, 0.9, 2.3, 1.4], Color("3a281b"))
	_poly([2.5, 1.0, 3.1, 0.9, 2.8, 0.45, 2.5, 0.55], mane)
	_c(3.0, 1.9, 0.07, Color("0e0a07"))
	_c(3.33, 1.05, 0.06, Color("0e0a07"))
	# the horns
	_pl([2.75, 2.45, 2.95, 2.75, 3.05, 2.95, 2.95, 3.1], Color("d8d0bc"), 0.12)
	# the tail with its tuft
	_l(-3.05, 2.2, -3.25, 1.4, rear.darkened(0.2), 0.08)
	_ell(-3.28, 1.25, 0.1, 0.2, 0, mane)
	# prairie grass
	if _detail(10.0):
		for k in 12:
			var x := -3.3 + k * 0.6
			_l(x, 0.2, x + 0.08, 0.5, gr.darkened(0.15), 0.05)
