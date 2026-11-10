class_name LandmarksIeA
extends RefCounted
## Irish landmarks (Dublin to Killarney), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const WIN := Color("2f3640")
const DARK := Color("2e3238")
const LIME := Color("b9b3a3") ## grey limestone
const LIME_D := Color("8f897b")
const LIME_L := Color("d3cdbd")
const SLATE := Color("4f565e")
const WATER := Color("4f7f9c")
const WATER_L := Color("7aa6c0")
const GRASS := Color("4f8f3a")
const GRASS_D := Color("3c7430")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"ie_dublin_hapenny": _dublin_hapenny()
		"ie_cork_finbarre": _cork_finbarre()
		"ie_limerick_castle": _limerick_castle()
		"ie_galway_arch": _galway_arch()
		"ie_waterford_reginald": _waterford_reginald()
		"ie_drogheda_gate": _drogheda_gate()
		"ie_dundalk_dolmen": _dundalk_dolmen()
		"ie_kilkenny_castle": _kilkenny_castle()
		"ie_sligo_benbulben": _sligo_benbulben()
		"ie_athlone_castle": _athlone_castle()
		"ie_killarney_ross": _killarney_ross()
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

## An arched window or door: a rectangle under a half circle.
static func _arched(x: float, y0: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.5, y0, x + w * 0.5, y0, x + w * 0.5, y0 + h - w * 0.5] + _arc(x, y0 + h - w * 0.5, w * 0.5, w * 0.5, 0, PI, 6), col)

## A pointed (Gothic) window: a rectangle under two arcs meeting at a point.
static func _pointed(x: float, y0: float, w: float, h: float, col: Color) -> void:
	var hw := w * 0.5
	var ys := y0 + h - w * 0.8
	_poly([x - hw, y0, x + hw, y0, x + hw, ys, x, y0 + h, x - hw, ys], col)

## Battlements along a wall top from x0 to x1 at height y (Irish stepped merlons are kept simple).
static func _merlons(x0: float, x1: float, y: float, h: float, n: int, col: Color) -> void:
	var step := (x1 - x0) / n
	for k in n:
		_r(x0 + step * k + step * 0.15, y, x0 + step * k + step * 0.65, y + h, col)

## A round drum tower seen from the side: shaded body with a lighter middle.
static func _drum(x: float, w: float, y0: float, y1: float, col: Color, shade: Color) -> void:
	_r(x - w * 0.5, y0, x + w * 0.5, y1, col)
	_r(x - w * 0.5, y0, x - w * 0.3, y1, shade)
	_r(x + w * 0.32, y0, x + w * 0.5, y1, shade.lerp(col, 0.4))

## The Ha'penny Bridge in Dublin: a single white cast-iron arch over the Liffey (1816) with lattice railings and
## the three lamp-holder arches over the walkway.
static func _dublin_hapenny() -> void:
	var iron := Color("f1f0ea")
	var shade := Color("c9cbc8")
	_r(-22, 0, 22, 1.2, WATER)
	_r(-22, 0.9, 22, 1.2, WATER_L)
	# the quay walls at both ends
	_r(-22, 0, -19.5, 2.4, LIME_D)
	_r(19.5, 0, 22, 2.4, LIME_D)
	var top := []
	var under := []
	for k in 25:
		var x := lerpf(-20.0, 20.0, k / 24.0)
		var t := x / 20.0
		top.append_array([x, 2.4 + 2.6 * (1.0 - t * t)])
		var xb := -x
		under.append_array([xb, 1.6 + 2.0 * (1.0 - t * t)])
	_poly(top + under, iron)
	# the railing: posts and the lattice between the deck and the handrail
	var rail := []
	for k in 25:
		var x := lerpf(-20.0, 20.0, k / 24.0)
		var t := x / 20.0
		rail.append([x, 2.4 + 2.6 * (1.0 - t * t)])
	for k in rail.size() - 1:
		var a: Array = rail[k]
		var b: Array = rail[k + 1]
		_l(a[0], a[1] + 1.2, b[0], b[1] + 1.2, iron, 0.18)
		if _detail(1.2):
			_l(a[0], a[1], b[0], b[1] + 1.2, shade, 0.08)
			_l(a[0], a[1] + 1.2, b[0], b[1], shade, 0.08)
	for k in range(0, rail.size(), 3):
		_l(rail[k][0], rail[k][1], rail[k][0], rail[k][1] + 1.2, iron, 0.12)
	# the three lamp arches over the walkway, a lantern hanging in each
	for x in [-9.0, 0.0, 9.0]:
		var t: float = x / 20.0
		var y := 2.4 + 2.6 * (1.0 - t * t) + 1.2
		var arch := _arc(x, y, 1.1, 1.6, PI, 0.0, 8)
		for k in range(0, arch.size() - 2, 2):
			_l(arch[k], arch[k + 1], arch[k + 2], arch[k + 3], iron, 0.14)
		_l(x, y + 1.6, x, y + 1.0, DARK, 0.06)
		_r(x - 0.22, y + 0.55, x + 0.22, y + 1.0, Color("f3d98a"))
		_r(x - 0.26, y + 0.98, x + 0.26, y + 1.08, DARK)

## St Fin Barre's Cathedral in Cork: William Burges's French Gothic front of white limestone, twin west towers
## with tall spires and the taller central spire over the crossing behind, a rose window over the doors.
static func _cork_finbarre() -> void:
	var stone := Color("e4dfd2")
	var shade := Color("c2bba9")
	var spire := Color("cfc8b6")
	# the central tower and spire behind
	_r(-4.5, 18, 4.5, 34, shade)
	_poly([-4.5, 34, 4.5, 34, 0, 72], spire)
	_poly([-4.5, 34, 0, 34, 0, 72], shade)
	# the nave front between the towers, with its gable
	_r(-11, 0, 11, 22, stone)
	_poly([-11, 22, 11, 22, 0, 31], stone)
	_c(0, 18, 4.2, shade)
	_c(0, 18, 3.4, Color("5b6f8a"))
	if _detail(1.0):
		for k in 8:
			var a := TAU * k / 8.0
			_l(0, 18, cos(a) * 3.4, 18 + sin(a) * 3.4, stone, 0.25)
	# the three deep doors
	for x in [-6.0, 0.0, 6.0]:
		_pointed(x, 0, 4.2 if x == 0.0 else 3.2, 10.5 if x == 0.0 else 8.5, shade)
		_pointed(x, 0, 2.6 if x == 0.0 else 1.9, 8.5 if x == 0.0 else 7.0, DARK)
	# the twin west towers with their spires and pinnacles
	for s in [-1.0, 1.0]:
		var x0: float = s * 11.0
		var x1: float = s * 21.0
		_r(minf(x0, x1), 0, maxf(x0, x1), 30, stone)
		_r(minf(x0, x1), 0, minf(x0, x1) + 1.0, 30, shade)
		var cx: float = s * 16.0
		_pointed(cx, 13, 2.2, 6, DARK)
		_pointed(cx, 22, 2.6, 6.5, DARK)
		_poly([cx - 5, 30, cx + 5, 30, cx, 58], spire)
		_poly([cx - 5, 30, cx, 30, cx, 58], shade)
		for px in [cx - 4.6, cx + 4.6]:
			_poly([px - 0.8, 30, px + 0.8, 30, px, 35], stone)
	_r(-23, 0, 23, 0.8, shade)

## King John's Castle in Limerick: a curtain wall along the Shannon between round drum towers, the gatehouse
## with its two towers on the left.
static func _limerick_castle() -> void:
	var stone := Color("a9a294")
	var shade := Color("857e70")
	_r(-30, 0, 30, 1.4, WATER)
	_r(-30, 1.1, 30, 1.4, WATER_L)
	# the curtain wall
	_r(-26, 1.4, 26, 14, stone)
	_merlons(-26, 26, 14, 1.2, 26, stone)
	if _detail(1.5):
		for k in 6:
			_r(-20 + k * 8.0, 7, -19.4 + k * 8.0, 9, DARK)
	# the round towers at the corners and in the middle
	for t in [[-24.0, 9.0, 22.0], [24.0, 9.0, 20.0], [6.0, 7.0, 17.0]]:
		_drum(t[0], t[1], 1.4, t[2], stone, shade)
		_merlons(t[0] - t[1] * 0.5, t[0] + t[1] * 0.5, t[2], 1.2, 6, stone)
		if _detail(1.2):
			_r(t[0] - 0.4, t[2] - 7, t[0] + 0.4, t[2] - 5, DARK)
	# the gatehouse: two towers flanking the gate
	for x in [-13.0, -6.0]:
		_drum(x, 5.0, 1.4, 21, stone, shade)
		_merlons(x - 2.5, x + 2.5, 21, 1.2, 4, stone)
	_r(-11, 1.4, -8, 16, stone)
	_arched(-9.5, 1.4, 2.6, 5.5, DARK)

## The Spanish Arch in Galway: two round arches through a short stretch of the 16th-century town wall by the
## Corrib, a grass bank on top and the river in front.
static func _galway_arch() -> void:
	var stone := Color("9c968b")
	var shade := Color("7a756b")
	_r(-13, 0, 13, 0.6, WATER)
	_r(-12, 0.6, 12, 8.4, stone)
	_r(-12, 7.6, 12, 8.4, shade)
	_arched(-4.5, 0.6, 5.2, 5.8, DARK)
	_arched(4.5, 0.6, 5.2, 5.8, DARK)
	# the arch stones round each opening
	for x in [-4.5, 4.5]:
		var a := _arc(x, 3.8, 2.9, 2.9, PI, 0.0, 9)
		for k in range(0, a.size() - 2, 2):
			_l(a[k], a[k + 1], a[k + 2], a[k + 3], LIME_L, 0.3)
	# the grass and a few shrubs on the wall top
	_r(-12, 8.4, 12, 9.2, GRASS)
	_c(-9, 9.4, 0.8, GRASS_D)
	_c(8, 9.3, 0.7, GRASS_D)
	if _detail(1.5):
		for k in 7:
			_r(-11 + k * 3.4, 1.5 + (k % 3) * 1.8, -10 + k * 3.4, 1.9 + (k % 3) * 1.8, shade)

## Reginald's Tower in Waterford: a squat round tower of rubble stone on the quay, its conical slate roof and a
## few small windows.
static func _waterford_reginald() -> void:
	var stone := Color("b2a68e")
	var shade := Color("8c8270")
	_drum(0, 12, 0, 16, stone, shade)
	_r(-6.4, 0, 6.4, 2.2, shade)
	_merlons(-6, 6, 16, 1.0, 8, stone)
	_poly([-5.2, 16, 5.2, 16, 0, 21.5], SLATE)
	_poly([-5.2, 16, 0, 16, 0, 21.5], Color("3f454c"))
	for w in [[-2.5, 5.0], [1.5, 9.0], [-1.0, 12.5]]:
		_r(w[0], w[1], w[0] + 0.6, w[1] + 1.4, DARK)
	_arched(2.5, 0, 1.6, 3.0, DARK)
	if _detail(1.5):
		for k in 5:
			_l(-6, 3.5 + k * 2.6, 6, 3.5 + k * 2.6, Color(shade, 0.5), 0.1)

## St Laurence's Gate in Drogheda: the barbican's two tall drum towers joined over a pointed gate, a parapet and
## arrow loops.
static func _drogheda_gate() -> void:
	var stone := Color("a8a296")
	var shade := Color("837d70")
	_r(-5, 0, 5, 16, stone)
	_merlons(-5, 5, 16, 1.0, 5, stone)
	for x in [-6.5, 6.5]:
		_drum(x, 5, 0, 20, stone, shade)
		_merlons(x - 2.5, x + 2.5, 20, 1.2, 4, stone)
		for y in [5.0, 10.0, 15.0]:
			_r(x - 0.2, y, x + 0.2, y + 1.6, DARK)
	_pointed(0, 0, 4.2, 7.5, DARK)
	_r(-1.5, 11, 1.5, 12.6, DARK)
	_l(-5, 9.5, 5, 9.5, shade, 0.2)

## The Proleek Dolmen near Dundalk: a huge capstone tilted on two tall portal stones and a lower back stone.
static func _dundalk_dolmen() -> void:
	var stone := Color("8e8a80")
	var shade := Color("6f6b62")
	_r(-4.5, 0, 4.5, 0.25, GRASS_D)
	_poly([-2.8, 0, -1.7, 0, -1.8, 2.7, -2.7, 2.9], stone)
	_poly([-1.4, 0, -0.4, 0, -0.5, 2.8, -1.3, 2.7], shade)
	_poly([2.2, 0, 3.2, 0, 3.0, 1.7, 2.3, 1.8], stone)
	# the capstone, highest over the portal
	_poly([-3.8, 3.0, -2.6, 4.6, 0.4, 5.0, 3.4, 3.2, 3.6, 2.2, 1.0, 1.8, -1.6, 2.3], stone)
	_poly([-3.8, 3.0, -1.6, 2.3, 1.0, 1.8, 3.6, 2.2, 3.4, 2.8, 0.0, 2.6], shade)
	if _detail(3.0):
		_c(-0.4, 4.85, 0.12, Color("a9a59a")) # pebbles thrown on top for luck
		_c(0.2, 4.9, 0.1, Color("a9a59a"))

## Kilkenny Castle: the long Victorian-fronted range of the castle with its three big round corner towers with
## battlements and copper-capped cones, the lawn in front.
static func _kilkenny_castle() -> void:
	var stone := Color("bfb29b")
	var shade := Color("9a8f7a")
	_r(-36, 0, 36, 0.8, GRASS)
	# the two ranges meeting at the middle tower
	_r(-30, 0.8, 4, 17, stone)
	_r(4, 0.8, 30, 15, shade.lerp(stone, 0.5))
	_merlons(-30, 4, 17, 1.0, 22, stone)
	_merlons(4, 30, 15, 1.0, 16, shade.lerp(stone, 0.5))
	_windows(-26, 0, 4, 7, 9, WIN)
	_windows(-26, 0, 10, 13, 9, WIN)
	_windows(8, 26, 4, 7, 6, WIN)
	_windows(8, 26, 9.5, 12.5, 6, WIN)
	# the round towers
	for t in [[-30.0, 26.0], [4.0, 27.0], [30.0, 24.0]]:
		_drum(t[0], 10, 0.8, t[1], stone, shade)
		_merlons(t[0] - 5, t[0] + 5, t[1], 1.0, 6, stone)
		if _detail(1.2):
			_r(t[0] - 0.6, t[1] - 8, t[0] + 0.6, t[1] - 5.5, WIN)
			_r(t[0] - 0.6, t[1] - 15, t[0] + 0.6, t[1] - 12.5, WIN)
	# the classical gateway in the middle range
	_r(-15.5, 0.8, -10.5, 8, LIME_L)
	_arched(-13, 0.8, 2.4, 5, DARK)

## Benbulben in County Sligo: the flat-topped limestone table mountain with its steep north face ribbed by gullies
## and a long grassy slope below.
static func _sligo_benbulben() -> void:
	var green := Color("5c8a46")
	var green_d := Color("4a7439")
	var cliff := Color("7d8270")
	var cliff_d := Color("5f6556")
	# the long lower slopes
	_poly([-70, 0, 70, 0, 66, 6, 40, 14, -30, 16, -62, 8], green)
	# the cliff face and the flat top
	_poly([-62, 8, -52, 30, -44, 36, 30, 38, 44, 33, 66, 6, 40, 14, -30, 16], cliff)
	_poly([-44, 36, -40, 38.5, 26, 40, 30, 38], green_d)
	# the ribs: gullies down the face
	if _detail(0.4):
		for k in 14:
			var x := -46.0 + k * 6.0
			var ytop := 36.5 + (k % 3) * 0.5
			_poly([x, ytop, x + 1.6, ytop, x + 2.6, 15.5 - absf(x) * 0.02, x + 0.4, 15.5 - absf(x) * 0.02], cliff_d)
	# the grass fringe at the foot of the face and a field wall
	_poly([-62, 8, -30, 16, 40, 14, 66, 6, 40, 12, -30, 13.5], green_d)
	if _detail(0.8):
		_l(-60, 3, 60, 4, Color("8d8a7e"), 0.3)

## Athlone Castle: the polygonal keep on its motte behind the curtain wall with two round drum towers, by the
## Shannon.
static func _athlone_castle() -> void:
	var stone := Color("a7a092")
	var shade := Color("837c6e")
	_r(-22, 0, 22, 1.2, WATER)
	_r(-22, 0.9, 22, 1.2, WATER_L)
	# the keep: a ten-sided tower, three faces seen
	_r(-6, 9, 6, 21, stone)
	_r(-6, 9, -3.5, 21, shade)
	_r(3.5, 9, 6, 21, shade.lerp(stone, 0.4))
	_merlons(-6, 6, 21, 1.0, 6, stone)
	_r(-0.4, 14, 0.4, 16, DARK)
	# the curtain wall and its drum towers
	_r(-18, 1.2, 18, 11, stone)
	_merlons(-18, 18, 11, 1.0, 18, stone)
	for x in [-16.0, 16.0]:
		_drum(x, 7, 1.2, 16, stone, shade)
		_merlons(x - 3.5, x + 3.5, 16, 1.0, 5, stone)
		_r(x - 0.3, 8, x + 0.3, 10, DARK)
	_arched(-6, 1.2, 2.6, 4.5, DARK)

## Ross Castle by Lough Leane: a tall rectangular tower house with stepped battlements and a slate roof, a lower
## bawn wall with a round corner turret, the lake in front.
static func _killarney_ross() -> void:
	var stone := Color("aaa596")
	var shade := Color("88837a")
	_r(-16, 0, 16, 1.2, WATER)
	_r(-16, 0.9, 16, 1.2, WATER_L)
	# the bawn wall and a corner turret
	_r(-15, 1.2, 15, 6, stone)
	_merlons(-15, 15, 6, 0.8, 14, stone)
	_drum(13, 4, 1.2, 9, stone, shade)
	_poly([11, 9, 15, 9, 13, 11.5], SLATE)
	# the tower house
	_r(-7, 1.2, 5, 21, stone)
	_r(-7, 1.2, -5.5, 21, shade)
	_poly([-6, 21, 4, 21, -1, 25.5], SLATE)
	# stepped Irish battlements
	for k in 6:
		var x := -7.0 + k * 2.0
		_poly([x, 21, x + 1.2, 21, x + 1.2, 22.2, x + 0.9, 22.2, x + 0.9, 22.8, x + 0.3, 22.8, x + 0.3, 22.2, x, 22.2], stone)
	for y in [8.0, 12.5, 17.0]:
		_r(-3.5, y, -2.7, y + 1.6, DARK)
		_r(1.0, y, 1.8, y + 1.6, DARK)
	_arched(-1, 1.2, 1.6, 3, DARK)
	_l(-12, 1.2, -12, 6, Color("5a4632"), 0.4)
	_c(-12, 7.5, 2.4, Color("3d6b33"))
	_c(-10.5, 8.6, 1.8, Color("4a7a3c"))
