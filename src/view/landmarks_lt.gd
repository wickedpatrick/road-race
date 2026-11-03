class_name LandmarksLt
extends RefCounted
## Lithuanian landmarks, drawn with LandmarkPainter's helpers (metres from the base point, y up).

const BRICK := Color("a8472e")
const BRICK_D := Color("7d3322")
const BRICK_L := Color("c0603f")
const WATER := Color("4f8fc0")
const WATER_L := Color("9cc8e6")
const SAND := Color("e8d49c")
const WHITE := Color("f2efe6")
const SHADE := Color("d2cdbf")
const DARK := Color("2e3238")
const GRASS := Color("5e9a3f")
const FLAG_Y := Color("f2c318")
const FLAG_G := Color("1a7a3c")
const FLAG_R := Color("c1272d")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"gediminas_tower": _gediminas_tower()
		"vilnius_cathedral": _vilnius_cathedral()
		"trakai_castle": _trakai_castle()
		"basketball": _basketball()
		"hill_of_crosses": _hill_of_crosses()
		"stork": _stork()
		"amber": _amber()
		"snow_arena": _snow_arena()
		"dunes": _dunes()
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

static func _arc(cx: float, cy: float, rx: float, ry: float, a0: float, a1: float, n: int) -> Array:
	return LandmarkPainter._arc_pts(cx, cy, rx, ry, a0, a1, n)

static func _fine(k: float) -> bool:
	return LandmarkPainter._pm > k

## The Lithuanian tricolour on a pole from (x, y): yellow, green, red.
static func _flag(x: float, y: float, h: float, w: float) -> void:
	_l(x, y, x, y + h, Color("d8d8d8"), 0.25)
	var fh := w * 0.6
	var top := y + h
	_r(x, top - fh / 3.0, x + w, top, FLAG_Y)
	_r(x, top - fh * 2.0 / 3.0, x + w, top - fh / 3.0, FLAG_G)
	_r(x, top - fh, x + w, top - fh * 2.0 / 3.0, FLAG_R)

## Gediminas' Tower: the octagonal red brick tower of the upper castle on its wooded hill, the flag on top.
static func _gediminas_tower() -> void:
	# the hill, with a lit side and a footpath winding up
	_poly([-15, 0, 15, 0, 11, 6, 6, 13, 3.5, 15.5, -3.5, 15.5, -7, 12.5, -11, 6], Color("4f8a3a"))
	_poly([-15, 0, -11, 6, -7, 12.5, -3.5, 15.5, -1, 15.5, -5, 11, -8, 5, -10, 0], Color("62a04a"))
	if _fine(1.0):
		for p in [[-12, 2.5], [-8, 7.5], [9, 3], [11.5, 1.5], [6.5, 9.5], [-4.5, 12.5]]:
			_c(p[0], p[1], 1.4, Color("3d7430"))
		_pl([12, 0.5, 6, 4, 9, 7.5, 3, 11, 4, 14.5], Color("c9b48a"), 0.35)
	# the remains of the castle wall on the hilltop
	_r(-5.6, 15.5, -2.6, 17.4, BRICK_D)
	_r(3.2, 15.5, 5.4, 16.8, BRICK_D)
	# the tower: three storeys, the lower one wider
	var x0 := -3.2
	var x1 := 3.2
	_r(x0, 15.5, x1, 22.5, BRICK)
	_r(x0 + 0.3, 22.5, x1 - 0.3, 28.2, BRICK)
	_r(x0, 15.5, x0 + 1.0, 22.5, BRICK_L) # the lit facet
	_r(x0 + 0.3, 22.5, x0 + 1.2, 28.2, BRICK_L)
	_r(x0 - 0.2, 22.2, x1 + 0.2, 22.8, BRICK_D)
	# crenellated top storey
	_r(x0 + 0.1, 28.2, x1 - 0.1, 29.0, BRICK_D)
	for k in 5:
		var x := x0 + 0.2 + k * 1.3
		_r(x, 29.0, x + 0.75, 29.9, BRICK)
	# gothic windows
	var win := Color("3a2620")
	for y in [17.4, 24.0]:
		for x in [-1.6, 0.9]:
			_poly([x, y, x + 0.8, y, x + 0.8, y + 2.0, x + 0.4, y + 2.6, x, y + 2.0], win)
	if _fine(1.6):
		for y in [19.6, 21.0, 26.4]:
			_l(x0, y, x1, y, BRICK_D, 0.12)
	_flag(0, 29.9, 4.0, 3.2)

## Pl helper (polyline) through flat points.
static func _pl(xy: Array, col: Color, w: float) -> void:
	LandmarkPainter._pl(xy, col, w)

## Vilnius Cathedral: the white classical temple front, six columns under a pediment with three statues on top,
## a long side wing, and the free-standing bell tower beside it, slimmer storeys up to a little cross.
static func _vilnius_cathedral() -> void:
	# the bell tower (right)
	var bx := 16.0
	_r(bx - 4.0, 0, bx + 4.0, 12, WHITE)
	_r(bx - 4.0, 0, bx - 3.0, 12, SHADE)
	_r(bx - 3.2, 12, bx + 3.2, 21, WHITE)
	_r(bx - 4.3, 11.6, bx + 4.3, 12.4, SHADE)
	_r(bx - 2.5, 21, bx + 2.5, 28, WHITE)
	_r(bx - 3.5, 20.6, bx + 3.5, 21.4, SHADE)
	_r(bx - 1.8, 28, bx + 1.8, 33, WHITE)
	_r(bx - 2.8, 27.6, bx + 2.8, 28.4, SHADE)
	_c(bx, 30.8, 0.9, Color("3a4048")) # the clock
	_poly([bx - 2.0, 33, bx + 2.0, 33, bx + 0.5, 36.5, bx - 0.5, 36.5], Color("4d6b5a"))
	_l(bx, 36.5, bx, 39.4, LandmarkPainter.GOLD, 0.25)
	_l(bx - 0.8, 38.4, bx + 0.8, 38.4, LandmarkPainter.GOLD, 0.25)
	var win := Color("4a4f58")
	for y in [4.0, 14.0, 22.5]:
		var hw := 1.0 if y < 20.0 else 0.8
		_poly([bx - hw, y, bx + hw, y, bx + hw, y + 3.0] + _arc(bx, y + 3.0, hw, hw, 0, PI, 6) + [bx - hw, y + 3.0], win)
	# the side wing behind the portico
	_r(-20, 0, 10, 13, SHADE)
	_r(-20, 13, 10, 14.2, WHITE)
	if _fine(1.2):
		for k in 6:
			var x := -19.0 + k * 5.0
			_r(x, 3, x + 1.6, 9, Color("8f8b80"))
	# the portico: steps, six columns, the pediment
	_r(-21, 0, 1, 1.2, Color("bdb7a8"))
	_r(-20, 1.2, 0, 2.0, SHADE)
	for k in 6:
		var x := -18.7 + k * 3.5
		_r(x, 2.0, x + 1.4, 14.0, WHITE)
		_r(x + 1.0, 2.0, x + 1.4, 14.0, SHADE)
		_r(x - 0.2, 13.6, x + 1.6, 14.3, WHITE)
	_r(-20.5, 14.3, 0.5, 16.2, WHITE)
	_poly([-21, 16.2, 1, 16.2, -10, 22.5], WHITE)
	_poly([-18.6, 16.8, -1.4, 16.8, -10, 21.6], SHADE)
	# the three saints on the pediment: Helena with her cross in the middle, Stanislaus and Casimir at the ends
	for p in [[-10.0, 22.5, 3.0], [-20.6, 16.2, 2.6], [0.6, 16.2, 2.6]]:
		var x: float = p[0]
		var y: float = p[1]
		var h: float = p[2]
		_poly([x - 0.6, y, x + 0.6, y, x + 0.4, y + h * 0.8, x - 0.4, y + h * 0.8], Color("e9e5d9"))
		_c(x, y + h * 0.9, 0.42, Color("e9e5d9"))
	_l(-10, 25.6, -10, 28.4, LandmarkPainter.GOLD, 0.3)
	_l(-11, 27.4, -9, 27.4, LandmarkPainter.GOLD, 0.3)
	_poly([-11.5, 2.0, -8.5, 2.0, -8.5, 7.5] + _arc(-10, 7.5, 1.5, 1.5, 0, PI, 6) + [-11.5, 7.5], Color("5a4a3c"))

## Trakai Island Castle: red brick walls and towers on an island, the tall donjon with its steep roof, the lake round
## it, a wooden footbridge from the left and a small boat.
static func _trakai_castle() -> void:
	_r(-25, 0, 25, 2.0, WATER)
	if _fine(1.0):
		for p in [[-22, 0.8, -15], [-6, 0.5, 4], [12, 1.2, 21]]:
			_l(p[0], p[1], p[2], p[1], WATER_L, 0.2)
	# the island
	_poly([-15, 2.0, 18, 2.0, 16, 3.4, -13, 3.4], Color("6b8f45"))
	# the footbridge
	_r(-25, 2.4, -14, 2.9, Color("8a6440"))
	if _fine(1.2):
		for x in [-23.0, -20.0, -17.0]:
			_l(x, 0.5, x, 2.4, Color("6a4a30"), 0.25)
	var roof := Color("8c3a28")
	# the outer bailey walls and round towers
	_r(-13, 3.4, 15, 10.5, BRICK)
	_r(-13, 3.4, 15, 4.6, Color("b8a68a")) # stone footing
	for x in [-12.0, 3.5, 14.0]:
		_r(x - 1.7, 3.4, x + 1.7, 13.5, BRICK_D if x > 0 else BRICK)
		_poly([x - 2.1, 13.5, x + 2.1, 13.5, x, 17.0], roof)
	# the palace and its donjon (right part, on its own)
	_r(-6, 10.5, 9, 18, BRICK)
	_poly([-6.6, 18, 9.6, 18, 7.5, 22.5, -4.5, 22.5], roof)
	_r(-1.5, 10.5, 4.5, 24.5, BRICK_L)
	_r(3.6, 10.5, 4.5, 24.5, BRICK_D)
	_poly([-2.2, 24.5, 5.2, 24.5, 1.5, 29.8], roof)
	_l(1.5, 29.8, 1.5, 30.0, roof, 0.2)
	var win := Color("3a2620")
	for x in [-4.5, 6.0]:
		_r(x, 13.5, x + 1.0, 15.6, win)
	_r(0.6, 20.4, 2.4, 22.6, win)
	if _fine(1.4):
		_poly([0.4, 10.5, 2.6, 10.5, 2.6, 13.0, 1.5, 14.0, 0.4, 13.0], win) # the gate
		for x in [-10.0, -7.0, 7.0, 10.0]:
			_r(x, 7.0, x + 0.7, 8.6, win)
		_r(-13, 10.5, 15, 10.9, BRICK_D)
	# a little boat on the lake
	_poly([17, 0.6, 22, 0.6, 23, 1.6, 16, 1.6], Color("f2efe6"))
	_l(19.5, 1.6, 19.5, 4.6, Color("6a4a30"), 0.15)
	_poly([19.6, 1.9, 19.6, 4.4, 21.6, 1.9], WHITE)

## Žalgiris Arena with a giant basketball and a hoop in front: in Lithuania basketball is the national game.
static func _basketball() -> void:
	# the arena: a long low building with a glass front and a green band
	_r(-15, 0, 9, 9, Color("cfd6dc"))
	_r(-15, 8, 9, 10.5, FLAG_G)
	_poly(_arc(-3, 10.5, 12, 3.6, 0, PI, 16), Color("aab4bc"))
	if _fine(1.2):
		for k in 8:
			var x := -14.2 + k * 2.9
			_r(x, 1.2, x + 2.2, 7.2, Color("4a6a86"))
	# the hoop: pole, backboard, ring and net
	_l(12.5, 0, 12.5, 9.5, Color("707880"), 0.45)
	_l(12.5, 9.5, 10.6, 9.5, Color("707880"), 0.35)
	_r(10.0, 8.4, 10.6, 12.0, WHITE)
	_r(10.0, 9.3, 10.6, 10.6, Color("c1272d"))
	_l(10.0, 9.0, 7.8, 9.0, Color("e2562a"), 0.25)
	if _fine(1.0):
		for k in 4:
			var x := 7.9 + k * 0.7
			_l(x, 9.0, x + 0.3, 7.9, WHITE, 0.08)
	# the big ball
	var o := Color("e07a2a")
	_c(13.0, 3.0, 3.0, o)
	_c(12.2, 3.8, 1.8, o.lightened(0.12))
	var seam := Color("3a2418")
	_l(10.0, 3.0, 16.0, 3.0, seam, 0.15)
	_l(13.0, 0.0, 13.0, 6.0, seam, 0.15)
	if _fine(1.4):
		LandmarkPainter._pl(_arc(9.6, 3.0, 2.4, 2.6, -PI * 0.42, PI * 0.42, 6), seam, 0.12)
		LandmarkPainter._pl(_arc(16.4, 3.0, 2.4, 2.6, PI * 0.58, PI * 1.42, 6), seam, 0.12)

## The Hill of Crosses: a low green mound covered with crosses of every size, wood and metal, a big one in the middle.
static func _hill_of_crosses() -> void:
	_poly([-17, 0, 17, 0, 12, 4.5, 6, 6.5, -6, 6.5, -12, 4.5], Color("6c9a45"))
	_poly([-17, 0, -12, 4.5, -6, 6.5, -4, 6.5, -10, 3.5, -13, 0], Color("80ad55"))
	var cols := [Color("6b4a2e"), Color("8a6440"), Color("4c3a2a"), Color("9a9a96"), Color("5a4030")]
	var rnd := 7
	for row in 4:
		var y0 := 1.0 + row * 1.6
		var half := 15.0 - row * 3.2
		var n := 14 - row * 2
		for k in n:
			rnd = (rnd * 37 + 11) % 101
			var x := -half + (2.0 * half) * (k + 0.5) / n + (rnd % 7 - 3) * 0.12
			var h := 1.6 + (rnd % 5) * 0.45
			var col: Color = cols[rnd % cols.size()]
			var y := y0 + (rnd % 3) * 0.3
			_l(x, y, x, y + h, col, 0.18)
			_l(x - h * 0.28, y + h * 0.7, x + h * 0.28, y + h * 0.7, col, 0.16)
	# the big crucifix on the top
	_l(0, 6.5, 0, 13.5, Color("5a4030"), 0.45)
	_l(-2.0, 11.6, 2.0, 11.6, Color("5a4030"), 0.4)
	_poly([-1.4, 13.0, 1.4, 13.0, 0, 13.8], Color("5a4030")) # the little roof over it
	# a few small rosaries and the path up
	if _fine(1.2):
		LandmarkPainter._pl([-17, 0.2, -9, 1.2, -4, 3.0, 0, 6.5], Color("c9b48a"), 0.4)

## A white stork on its big nest on top of an old pole beside the road.
static func _stork() -> void:
	var pole := Color("7a6a58")
	_r(-0.4, 0, 0.4, 7.5, pole)
	_r(-0.2, 0, 0.0, 7.5, pole.lightened(0.15))
	# the nest
	_poly([-3.2, 7.5, 3.2, 7.5, 3.6, 8.6, -3.6, 8.6], Color("6e5638"))
	if _fine(1.2):
		for k in 6:
			var x := -3.2 + k * 1.3
			_l(x, 7.6, x + 1.4, 8.7, Color("8e7450"), 0.15)
	# the stork: white body, black wing feathers, long neck, red beak and legs
	var red := Color("d8452a")
	_l(0.4, 8.6, 0.6, 9.6, red, 0.15)
	_l(-0.4, 8.6, -0.2, 9.6, red, 0.15)
	LandmarkPainter._ell(0.0, 10.4, 1.6, 0.9, -0.15, WHITE)
	_poly([-1.6, 10.5, 0.6, 10.0, -0.2, 9.7, -2.6, 9.9], DARK) # wing tips
	_l(1.2, 10.7, 1.6, 12.4, WHITE, 0.4)
	_c(1.7, 12.5, 0.38, WHITE)
	_poly([1.9, 12.6, 3.4, 12.2, 1.9, 12.3], red)
	if _fine(1.6):
		_c(1.8, 12.6, 0.07, DARK)
	# a young one peeping out of the nest
	_l(-1.6, 8.6, -1.8, 9.4, Color("e6e2d8"), 0.3)
	_c(-1.8, 9.5, 0.28, Color("e6e2d8"))
	_poly([-2.0, 9.5, -2.9, 9.3, -2.0, 9.35], Color("4a4440"))

## A big polished lump of Baltic amber on a stand, a tiny insect caught inside.
static func _amber() -> void:
	_r(-2.2, 0, 2.2, 1.2, Color("9a8a70"))
	_r(-2.6, 1.0, 2.6, 1.4, Color("b4a488"))
	var a := Color("d98a1c")
	_poly([-2.6, 1.6, -1.8, 3.8, -0.4, 4.6, 1.6, 4.3, 2.8, 2.9, 2.4, 1.6], a)
	_poly([-1.9, 2.0, -1.4, 3.5, -0.3, 4.1, 0.6, 3.9, -0.6, 3.2, -1.2, 2.0], a.lightened(0.25))
	_poly([1.0, 1.7, 2.3, 1.8, 2.6, 2.8, 1.8, 3.6], a.darkened(0.15))
	# the insect: body, wings and legs
	var bug := Color("3a2410")
	LandmarkPainter._ell(0.6, 2.7, 0.45, 0.18, 0.3, bug)
	if _fine(1.5):
		LandmarkPainter._ell(0.5, 3.0, 0.35, 0.15, 1.1, Color(1, 1, 1, 0.35))
		_l(0.4, 2.6, 0.2, 2.3, bug, 0.05)
		_l(0.8, 2.7, 0.9, 2.3, bug, 0.05)
	_c(-1.0, 3.7, 0.22, Color(1, 1, 1, 0.6)) # the shine

## Druskininkai's Snow Arena: the long indoor ski slope, a grey tube rising out of the pines on its legs to the top
## station, the glass end, a little skier.
static func _snow_arena() -> void:
	# pines along the bottom
	for k in 9:
		var x := -28.0 + k * 6.5
		_poly([x - 2.4, 0, x + 2.4, 0, x, 7.0 + (k % 3)], Color("2f5f3a"))
	# the legs under the slope
	for k in 5:
		var x := -10.0 + k * 7.0
		var y := 4.0 + (x + 24.0) * 0.42
		_r(x - 0.6, 0, x + 0.6, y, Color("8a9096"))
	# the slope: a long tube from the low end (left) to the top (right)
	var c := Color("b9c2ca")
	_poly([-26, 3, 22, 23.2, 22, 29, -26, 8], c)
	_poly([-26, 7, 22, 27.6, 22, 29, -26, 8], Color("dfe6ec")) # the light roof
	_l(-26, 3, 22, 23.2, Color("7d868e"), 0.4)
	# the top station with its glass end
	_r(22, 0, 29, 29, Color("9aa4ac"))
	_r(22.8, 18, 28.2, 28, Color("5a86a8"))
	if _fine(1.2):
		for y in [3.0, 8.0, 13.0]:
			_r(23.2, y, 27.8, y + 3.0, Color("6c8ea8"))
		# a snowy opening at the low end with a skier
		_poly([-26, 3.3, -24, 4.1, -24, 7.6, -26, 7.4], Color("f5f8fa"))
		_l(-24.6, 4.0, -24.2, 5.6, Color("c1272d"), 0.35)
		_c(-24.1, 5.9, 0.3, Color("c1272d"))
	_r(22, 29, 29, 30, Color("7d868e"))

## The Parnidis Dune in Nida: a great bare sand dune over the pines with the tall stone sundial on top.
static func _dunes() -> void:
	# pines at the foot
	for k in 7:
		var x := -24.0 + k * 7.6
		_poly([x - 2.6, 0, x + 2.6, 0, x, 5.5 + (k % 2) * 1.5], Color("2f5f3a"))
	# the dune: a long windward slope from the left, a steep lee side on the right
	var s := SAND
	_poly([-25, 0, -10, 4.5, 0, 9.5, 6, 11.5, 10, 11.0, 15, 6.0, 20, 1.2, 25, 0], s)
	_poly([6, 11.5, 10, 11.0, 15, 6.0, 20, 1.2, 25, 0, 16, 0, 11, 6, 7.5, 10.4], s.darkened(0.12))
	if _fine(1.0):
		for p in [[-16, 3.0], [-6, 6.5], [-11, 2.2], [2, 8.6]]:
			_l(p[0], p[1], p[0] + 0.5, p[1] + 1.2, Color("7a9a48"), 0.2)
			_l(p[0] + 0.4, p[1], p[0] - 0.2, p[1] + 1.0, Color("7a9a48"), 0.2)
		LandmarkPainter._pl([-22, 1.4, -12, 4.4, -4, 7.4, 4, 10.6], Color("f4e6bc"), 0.18) # wind ripples
	# the sundial: a granite obelisk on a round stepped platform
	_r(3.0, 11.2, 9.8, 12.0, Color("9a9890"))
	_r(4.0, 12.0, 8.8, 12.6, Color("b4b2aa"))
	_poly([5.6, 12.6, 7.2, 12.6, 6.7, 25.0, 6.1, 25.0], Color("8a8880"))
	_poly([5.6, 12.6, 6.2, 12.6, 6.3, 25.0, 6.1, 25.0], Color("a8a69e"))
	_l(6.4, 12.4, 13.5, 11.6, Color(0, 0, 0, 0.25), 0.4) # its shadow
