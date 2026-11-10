class_name LandmarksIeB
extends RefCounted
## Irish landmarks (Tralee to Cashel), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const WIN := Color("2f3640")
const DARK := Color("2e3238")
const SLATE := Color("4f565e")
const WATER := Color("4f7f9c")
const WATER_L := Color("7aa6c0")
const GRASS := Color("4f8f3a")
const GRASS_D := Color("3c7430")
const BOG := Color("6b5a3e")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"ie_tralee_windmill": _tralee_windmill()
		"ie_ennis_friary": _ennis_friary()
		"ie_wexford_hook": _wexford_hook()
		"ie_westport_croagh": _westport_croagh()
		"ie_donegal_castle": _donegal_castle()
		"ie_letterkenny_eunan": _letterkenny_eunan()
		"ie_clifden_vimy": _clifden_vimy()
		"ie_dingle_gallarus": _dingle_gallarus()
		"ie_kenmare_circle": _kenmare_circle()
		"ie_cashel_rock": _cashel_rock()
		"ie_cahersiveen_ballycarbery": _cahersiveen_ballycarbery()
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

static func _ell(cx: float, cy: float, rx: float, ry: float, rot: float, col: Color) -> void:
	LandmarkPainter._ell(cx, cy, rx, ry, rot, col)

static func _windows(x0: float, x1: float, y0: float, y1: float, n: int, col: Color) -> void:
	LandmarkPainter._windows(x0, x1, y0, y1, n, col)

static func _arc(cx: float, cy: float, rx: float, ry: float, a0: float, a1: float, n: int) -> Array:
	return LandmarkPainter._arc_pts(cx, cy, rx, ry, a0, a1, n)

static func _detail(min_pm: float) -> bool:
	return LandmarkPainter._pm > min_pm

static func _arched(x: float, y0: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.5, y0, x + w * 0.5, y0, x + w * 0.5, y0 + h - w * 0.5] + _arc(x, y0 + h - w * 0.5, w * 0.5, w * 0.5, 0, PI, 6), col)

## A pointed (Gothic) window: a rectangle under two slopes meeting at a point.
static func _pointed(x: float, y0: float, w: float, h: float, col: Color) -> void:
	var hw := w * 0.5
	var ys := y0 + h - w * 0.8
	_poly([x - hw, y0, x + hw, y0, x + hw, ys, x, y0 + h, x - hw, ys], col)

static func _merlons(x0: float, x1: float, y: float, h: float, n: int, col: Color) -> void:
	var step := (x1 - x0) / n
	for k in n:
		_r(x0 + step * k + step * 0.15, y, x0 + step * k + step * 0.65, y + h, col)

## Irish stepped battlements: each merlon a small stepped block.
static func _stepped(x0: float, x1: float, y: float, n: int, col: Color) -> void:
	var step := (x1 - x0) / n
	for k in n:
		var x := x0 + step * k + step * 0.1
		var w := step * 0.6
		_poly([x, y, x + w, y, x + w, y + 0.9, x + w * 0.75, y + 0.9, x + w * 0.75, y + 1.4, x + w * 0.25, y + 1.4,
			x + w * 0.25, y + 0.9, x, y + 0.9], col)

## The Blennerville Windmill by Tralee Bay: a tapering white stone tower with a dark boat-shaped cap, a gallery
## and four lattice sails set as a cross.
static func _tralee_windmill() -> void:
	var white := Color("f2f0ea")
	var shade := Color("d2cec4")
	_r(-8, 0, 8, 0.4, GRASS_D)
	_poly([-4.2, 0, 4.2, 0, 2.9, 16, -2.9, 16], white)
	_poly([-4.2, 0, -2.6, 0, -1.8, 16, -2.9, 16], shade)
	_r(-3.8, 6.0, 3.8, 6.5, DARK) # the reefing stage
	_l(-3.8, 6.0, -3.2, 4.8, DARK, 0.1)
	_l(3.8, 6.0, 3.2, 4.8, DARK, 0.1)
	for y in [2.5, 9.0, 12.5]:
		_r(-0.4, y, 0.4, y + 1.2, WIN)
	_arched(1.6, 0, 1.2, 2.2, WIN)
	# the cap
	_poly([-3.2, 16, 3.2, 16, 2.6, 17.6, 0, 18.6, -2.6, 17.6], Color("3c3f45"))
	# the four sails on the hub, as an X
	var hx := 0.0
	var hy := 17.0
	for k in 4:
		var a := PI * 0.25 + PI * 0.5 * k
		var d := Vector2(cos(a), sin(a))
		var n := Vector2(-d.y, d.x)
		var p0 := Vector2(hx, hy) + d * 1.2
		var p1 := Vector2(hx, hy) + d * 7.6
		var w := 0.9
		_l(hx, hy, p1.x, p1.y, Color("6b4a32"), 0.22)
		var q := [p0 + n * 0.15, p1 + n * 0.15, p1 + n * (0.15 + w), p0 + n * (0.15 + w)]
		_poly([q[0].x, q[0].y, q[1].x, q[1].y, q[2].x, q[2].y, q[3].x, q[3].y], Color(0.95, 0.94, 0.9, 0.9))
		if _detail(2.0):
			for j in 6:
				var m: Vector2 = p0.lerp(p1, (j + 0.5) / 6.0)
				_l(m.x + n.x * 0.15, m.y + n.y * 0.15, m.x + n.x * (0.15 + w), m.y + n.y * (0.15 + w), Color("8a7a66"), 0.05)
	_c(hx, hy, 0.45, DARK)

## Ennis Friary: the roofless nave and chancel of grey limestone with stepped gables, the slender square bell
## tower in the middle and the tall five-light east window.
static func _ennis_friary() -> void:
	var stone := Color("a7a397")
	var shade := Color("858174")
	_r(-18, 0, 18, 0.5, GRASS)
	# the nave (left) and chancel (right), roofless: walls with gables at the ends
	_r(-17, 0.5, 17, 9, stone)
	_poly([-17, 9, -11, 9, -14, 14], stone)
	# the east gable, centred on the great window so its pointed head stays inside the wall
	_poly([5, 9, 17, 9, 11, 15.5], stone)
	_r(-17, 8.4, 17, 9, shade)
	# the tower over the crossing
	_r(-2.6, 9, 2.6, 23, stone)
	_r(-2.6, 9, -1.6, 23, shade)
	_stepped(-2.8, 2.8, 23, 4, stone)
	_pointed(0, 17, 1.0, 2.6, DARK)
	_r(-0.3, 12.5, 0.3, 14, DARK)
	# the great east window with its mullions
	_pointed(11, 1.8, 5.2, 10.5, DARK)
	if _detail(1.2):
		for x in [9.2, 10.1, 11.0, 11.9, 12.8]:
			_l(x, 1.8, x, 8.5, stone, 0.18)
	# nave windows and a door
	for x in [-13.0, -8.5]:
		_pointed(x, 3, 1.3, 4, DARK)
	_arched(-4.5, 0.5, 1.8, 3.4, DARK)
	# ivy
	_c(-16.2, 6, 1.4, Color("3e6a33"))
	_c(-15.5, 7.6, 1.0, Color("4a7a3c"))

## Hook Lighthouse: the broad medieval tower painted white with two black bands, its gallery and lantern on top,
## the keepers' houses at its foot on the rocks.
static func _wexford_hook() -> void:
	var white := Color("f3f1ea")
	var shade := Color("d0cdc2")
	var black := Color("26282c")
	_r(-8, 0, 8, 1.0, Color("6f6c63"))
	# the keepers' houses
	_r(-8, 1.0, -4.5, 5, white)
	_poly([-8.3, 5, -4.2, 5, -6.2, 6.6], SLATE)
	_r(4.5, 1.0, 8, 4.6, white)
	_poly([4.2, 4.6, 8.3, 4.6, 6.2, 6.0], SLATE)
	# the tower
	_r(-5, 1.0, 5, 28, white)
	_r(-5, 1.0, -3.4, 28, shade)
	_r(-5, 10.5, 5, 15, black)
	_r(-5, 19.5, 5, 24, black)
	_merlons(-5.2, 5.2, 28, 0.9, 7, white)
	for y in [5.0, 16.5, 25.0]:
		_r(-0.4, y, 0.4, y + 1.4, WIN if y != 25.0 else Color("595c62"))
	# the lantern
	_r(-2.4, 28.9, 2.4, 29.5, black)
	_r(-1.9, 29.5, 1.9, 32.5, Color("f4dc8c"))
	if _detail(1.2):
		for x in [-1.2, 0.0, 1.2]:
			_l(x, 29.5, x, 32.5, black, 0.1)
	_poly([-2.3, 32.5, 2.3, 32.5, 0, 34.8], Color("b43a2f"))
	_l(0, 34.8, 0, 35.6, black, 0.12)

## Croagh Patrick above Clew Bay: a steep quartzite cone with pale scree near the top, the pilgrim path zigzagging
## up the shoulder and the small white chapel on the summit.
static func _westport_croagh() -> void:
	var green := Color("5d8346")
	var rock := Color("8a8a7e")
	var scree := Color("bdbbae")
	_poly([-70, 0, 70, 0, 52, 8, 26, 20, 6, 38, 0, 40, -8, 37, -26, 22, -48, 12], green)
	_poly([-14, 30, -8, 37, 0, 40, 6, 38, 14, 28, 6, 30, -4, 28], rock)
	_poly([-8, 37, 0, 40, 6, 38, 2, 34, -3, 33.5], scree)
	if _detail(0.5):
		var path := [[-48, 12], [-30, 16], [-36, 19], [-20, 24], [-24, 27], [-10, 33], [-4, 38]]
		for k in path.size() - 1:
			_l(path[k][0], path[k][1], path[k + 1][0], path[k + 1][1], Color("d8d2bd"), 0.35)
	# the chapel, drawn larger than life so it shows
	_r(-1.4, 40, 1.4, 42, Color("f4f2ec"))
	_poly([-1.6, 42, 1.6, 42, 0, 43.4], SLATE)
	_r(-0.2, 43.4, 0.2, 44, Color("f4f2ec"))

## Donegal Castle: the O'Donnells' tall rectangular tower house with corner turrets and gables, and the lower
## manor house of the 1620s alongside with its gabled dormers and mullioned windows.
static func _donegal_castle() -> void:
	var stone := Color("9f9888")
	var shade := Color("7d776a")
	_r(-20, 0, 20, 0.6, GRASS)
	# the manor house on the right
	_r(-2, 0.6, 19, 10, stone)
	_poly([-2, 10, 19, 10, 17, 12.5, 0, 12.5], SLATE)
	for x in [3.0, 9.0, 15.0]:
		_poly([x - 2, 10, x + 2, 10, x + 2, 12.5, x, 14.5, x - 2, 12.5], stone)
		_r(x - 1.1, 10.6, x + 1.1, 12.4, WIN)
	_windows(0, 18, 2.5, 5.5, 6, WIN)
	_windows(0, 18, 6.8, 8.8, 6, WIN)
	_r(17, 12, 18, 15.5, shade) # a chimney stack
	# the tower house
	_r(-17, 0.6, -2, 19, stone)
	_r(-17, 0.6, -15.4, 19, shade)
	_poly([-14, 19, -5, 19, -9.5, 22.5], SLATE)
	_stepped(-17, -2, 19, 7, stone)
	for x in [-17.0, -2.0]: # corner turrets corbelled out
		_r(x - 1.2, 17, x + 1.2, 21.5, stone)
		_poly([x - 1.2, 17, x + 1.2, 17, x, 15.6], shade)
		_poly([x - 1.4, 21.5, x + 1.4, 21.5, x, 23.5], SLATE)
	for y in [5.0, 10.0, 14.5]:
		_r(-11.5, y, -10, y + 2.0, WIN)
		_r(-7, y, -5.5, y + 2.0, WIN)
	_arched(-9, 0.6, 1.8, 3.4, DARK)

## St Eunan's Cathedral in Letterkenny: the neo-Gothic church of pale Donegal sandstone, its tall tower and spire
## at the west end and the long nave with pointed windows.
static func _letterkenny_eunan() -> void:
	var stone := Color("d8ccb0")
	var shade := Color("b7aa8d")
	var spire := Color("c9bc9e")
	_r(-20, 0, 20, 0.6, GRASS)
	# the nave and its roof
	_r(-6, 0.6, 19, 16, stone)
	_poly([-6, 16, 19, 16, 19, 18, 6.5, 24, -6, 18], SLATE)
	_r(17, 16, 19, 22, stone)
	for x in [-2.0, 2.5, 7.0, 11.5, 16.0]:
		_pointed(x, 4, 1.8, 7.5, Color("5a6278"))
	for x in [-3.5, 1.0, 5.5, 10.0, 14.5]:
		_r(x - 0.35, 0.6, x + 0.35, 15, shade) # buttresses
	# the tower and spire
	_r(-14, 0.6, -6, 36, stone)
	_r(-14, 0.6, -12.6, 36, shade)
	_pointed(-10, 0.6, 3.2, 7, DARK)
	_pointed(-10, 12, 1.8, 6, Color("5a6278"))
	_pointed(-10, 26, 2.6, 6, DARK)
	_c(-10, 21, 1.4, shade)
	_poly([-14, 36, -6, 36, -10, 71.5], spire)
	_poly([-14, 36, -10, 36, -10, 71.5], shade)
	for x in [-13.6, -6.4]:
		_poly([x - 0.7, 36, x + 0.7, 36, x, 41], stone)
	_l(-10, 71.5, -10, 72, DARK, 0.3)

## Alcock and Brown's Vickers Vimy in the Derrygimlagh bog as it landed on 15 June 1919: the big biplane seen from the
## side, nose down in the brown bog and tail up in the air, the two wings edge-on with their struts, an engine and its
## propeller between them, the wheels sunk in the peat and the twin rudders between the two tailplanes.
static func _clifden_vimy() -> void:
	var fabric := Color("ddd3b6")
	var fab_d := Color("b9ae90")
	var strut := Color("6b5a43")
	var o := Vector2(-5.6, 0.6) # the nose, dug into the bog
	var a := 0.5 # nose down by about 29 degrees
	# the undercarriage: struts from the lower wing to the wheels, half sunk
	var w := _tilt([3.4, -1.9], o, a)
	for u in [3.0, 3.8]:
		var t := _tilt([u, -0.9], o, a)
		_l(t[0], t[1], w[0], w[1], strut, 0.12)
	_c(w[0], w[1], 0.55, DARK)
	_c(w[0], w[1], 0.22, Color("8b8b8b"))
	# the lower wing edge-on, under the fuselage
	_poly(_tilt([2.3, -1.0, 5.6, -1.0, 5.6, -0.72, 2.3, -0.65], o, a), fab_d)
	# the fuselage: blunt nose, slimming to the tail
	_poly(_tilt([0, -0.6, 0, 0.8, 1.2, 0.9, 12.8, 0.45, 13.3, 0.4, 13.3, 0.0, 12.8, 0.0, 1.2, -0.75], o, a), fabric)
	_poly(_tilt([1.5, 0.75, 2.5, 0.72, 2.5, 1.1, 1.5, 1.1], o, a), DARK) # the open cockpit
	# the interplane struts
	for u in [2.8, 5.0]:
		var p0 := _tilt([u, -0.7, u, 2.7], o, a)
		_l(p0[0], p0[1], p0[2], p0[3], strut, 0.1)
	# the engine nacelle between the wings, the propeller in front of it
	_poly(_tilt([1.7, 0.5, 4.4, 0.6, 4.9, 1.0, 4.4, 1.5, 1.7, 1.55, 1.5, 1.0], o, a), Color("6e7377"))
	var pr := _tilt([1.35, -0.6, 1.35, 2.6], o, a)
	_l(pr[0], pr[1], pr[2], pr[3], Color("5a4632"), 0.16)
	var hub := _tilt([1.4, 1.0], o, a)
	_c(hub[0], hub[1], 0.18, DARK)
	# the upper wing edge-on
	_poly(_tilt([2.3, 2.7, 5.6, 2.7, 5.6, 2.95, 2.3, 3.0], o, a), fabric)
	# the biplane tail: two tailplanes with the twin rudders between them, high in the air
	_poly(_tilt([12.4, 0.4, 13.4, 0.4, 13.5, 1.9, 12.7, 1.9], o, a), fab_d)
	_poly(_tilt([10.9, 0.3, 13.6, 0.3, 13.6, 0.45, 10.9, 0.5], o, a), fabric)
	_poly(_tilt([11.2, 1.85, 13.6, 1.85, 13.6, 2.0, 11.2, 2.0], o, a), fabric)
	# the bog over the buried nose and wheels
	_r(-7.5, 0, 7.5, 0.6, BOG)
	if _detail(2.0):
		_c(-6.8, 0.6, 0.35, Color("8a6e4a"))
		_c(5.6, 0.6, 0.3, Color("8a6e4a"))
		for x in [-1.0, 2.5, 6.6]:
			_l(x, 0.5, x - 0.15, 0.95, GRASS_D, 0.08)
			_l(x, 0.5, x + 0.15, 0.9, GRASS_D, 0.08)

## Flat [x, y, ...] points given along the tilted aircraft (u along the fuselage from the nose, v up from it), turned
## by `a` radians and placed at `o`.
static func _tilt(uv: Array, o: Vector2, a: float) -> Array:
	var out := []
	for k in range(0, uv.size(), 2):
		out.append_array([o.x + uv[k] * cos(a) - uv[k + 1] * sin(a), o.y + uv[k] * sin(a) + uv[k + 1] * cos(a)])
	return out

## The Gallarus Oratory: seen from its west end, the dry-stone walls curving inwards up to the ridge like an
## upturned boat, the narrow doorway with sloping jambs.
static func _dingle_gallarus() -> void:
	var stone := Color("8f877a")
	var shade := Color("6f685d")
	_r(-5, 0, 5, 0.3, GRASS)
	var side := []
	for k in 9:
		var t := k / 8.0
		side.append_array([-3.4 * (1.0 - pow(t, 1.8)), 0.3 + 5.0 * t])
	var other := []
	for k in range(8, -1, -1):
		var t := k / 8.0
		other.append_array([3.4 * (1.0 - pow(t, 1.8)), 0.3 + 5.0 * t])
	_poly(side + other.slice(2), stone)
	_poly([-3.4, 0.3, -2.4, 0.3, -1.6, 2.6, -0.3, 5.1, -0.4, 5.3, -2.5, 3.2], shade)
	_poly([-0.55, 0.3, 0.55, 0.3, 0.38, 2.0, -0.38, 2.0], DARK)
	_r(-0.6, 2.0, 0.6, 2.25, Color("a39b8c")) # the lintel
	if _detail(2.5):
		for k in 7:
			var y := 0.9 + k * 0.62
			var hw := 3.4 * (1.0 - pow((y - 0.3) / 5.0, 1.8)) - 0.1
			_l(-hw, y, hw, y, Color(shade, 0.6), 0.04)

## The Kenmare Stone Circle: an oval of fifteen standing stones, the far ones smaller, around the boulder burial
## (a great boulder on three small stones) in the middle, a hawthorn behind.
static func _kenmare_circle() -> void:
	var stone := Color("8a857a")
	var shade := Color("6c675d")
	_r(-9, 0, 9, 0.3, GRASS)
	_c(6.5, 2.9, 1.4, Color("436f35"))
	_l(6.5, 0.3, 6.5, 2.0, Color("5a4632"), 0.25)
	# the back row, smaller and higher
	for k in 7:
		var x := -6.0 + k * 2.0
		var h := 0.9 + (k % 3) * 0.2
		_poly([x - 0.35, 0.8, x + 0.35, 0.8, x + 0.25, 0.8 + h, x - 0.2, 0.8 + h], shade)
	# the boulder burial
	_r(-0.9, 0.4, -0.6, 1.0, shade)
	_r(0.6, 0.4, 0.9, 1.0, shade)
	_ell(0, 1.6, 1.6, 0.8, 0.05, stone)
	# the front row
	for k in 8:
		var x := -7.0 + k * 2.0
		var h := 1.1 + ((k + 1) % 3) * 0.3
		_poly([x - 0.5, 0.2, x + 0.5, 0.2, x + 0.35, 0.2 + h, x - 0.3, 0.2 + h], stone)

## The Rock of Cashel: the limestone outcrop over the plain, crowned by the roofless Gothic cathedral with its
## central tower, Cormac's Chapel with its square tower on the left and the tall round tower on the right.
static func _cashel_rock() -> void:
	var stone := Color("b3ac9b")
	var shade := Color("8d8676")
	var grass := Color("5e8a45")
	# the rock and its grass
	_poly([-36, 0, 36, 0, 30, 6, 22, 10, -24, 10.5, -32, 5], grass)
	_poly([-24, 10.5, 22, 10, 24, 8.5, -26, 9], Color("8a8578"))
	# Cormac's Chapel: steep stone roof, square tower beside it
	_r(-24, 10, -12, 18, stone)
	_poly([-24, 18, -12, 18, -18, 24], shade)
	_r(-14, 10, -11, 26, stone)
	_poly([-14, 26, -11, 26, -12.5, 28.5], shade)
	if _detail(1.2):
		for x in [-21.0, -18.0, -15.0]:
			_arched(x, 13, 0.9, 2.2, DARK)
	# the cathedral, roofless: walls, gables, lancets and the central tower
	_r(-11, 10, 20, 22, stone)
	_poly([-11, 22, -4, 22, -7.5, 27], stone)
	_poly([13, 22, 20, 22, 16.5, 27], stone)
	for x in [-8.0, -2.0, 11.0, 16.5]:
		_pointed(x, 13, 1.4, 6, DARK)
	_r(2, 22, 9, 35, stone)
	_r(2, 22, 3.4, 35, shade)
	_merlons(2, 9, 35, 1.2, 5, stone)
	_pointed(5.5, 27, 1.6, 4, DARK)
	# the round tower
	_r(23, 9.5, 27, 38, Color("bdb6a5"))
	_r(23, 9.5, 24, 38, shade)
	_poly([22.8, 38, 27.2, 38, 25, 43.5], shade)
	_r(24.6, 20, 25.4, 22, DARK)
	_r(24.6, 33, 25.4, 35, DARK)

## Ballycarbery Castle near Cahersiveen: the broken shell of a tall tower house with a lower ruined wing, its
## jagged wall tops and gaping windows half hidden under ivy, in a green field by the water.
static func _cahersiveen_ballycarbery() -> void:
	var stone := Color("9a958a")
	var shade := Color("77736a")
	var ivy := Color("3f6a32")
	var ivy_l := Color("55823f")
	_r(-15, 0, 15, 0.5, GRASS)
	_r(10, 0, 15, 0.5, WATER)
	# the lower wing on the left, broken off
	_poly([-14, 0.5, -3, 0.5, -3, 9, -6, 10, -8, 8.5, -11, 9.2, -14, 7], stone)
	_arched(-9, 0.5, 2.0, 3.6, DARK)
	_r(-12.5, 5, -11.5, 6.6, DARK)
	# the tower house, its top ragged
	_poly([-4, 0.5, 9, 0.5, 9, 14.5, 7.5, 16.5, 6, 15, 4, 17.5, 1.5, 16, -1, 17, -2.5, 15.5, -4, 16], stone)
	_poly([-4, 0.5, -2.4, 0.5, -2.4, 15.3, -4, 16], shade)
	for w in [[0.5, 4.0, 1.4, 2.4], [5.0, 4.0, 1.4, 2.4], [2.6, 9.0, 1.6, 3.2], [6.0, 11.5, 1.2, 2.2]]:
		_r(w[0], w[1], w[0] + w[2], w[1] + w[3], DARK)
	# the ivy
	for c in [[-4, 9, 2.2], [-2.5, 12.5, 1.8], [8.6, 6, 1.6], [8.2, 10, 1.4], [-13.5, 3, 1.6], [-12, 6.8, 1.5], [3.0, 15.4, 1.3]]:
		_c(c[0], c[1], c[2], ivy)
	for c in [[-3.2, 10, 1.1], [8.4, 7, 0.9], [-12.6, 4, 0.9]]:
		_c(c[0], c[1], c[2], ivy_l)
