class_name LandmarksRoB
extends RefCounted
## Romanian landmarks (Pitești to Deva), drawn with LandmarkPainter's helpers (metres from the base point, y up).

const WHITE := Color("f3f0e8")
const WIN := Color("3a4048")
const DARK := Color("2e3238")
const ROOF := Color("b5432e")
const GRASS := Color("5d8f42")
const TREE := Color("3f6f34")
const WATER_L := Color("8cc0e0")
const GOLD := Color("e0b43a")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"pitesti_tulips": _tulips()
		"bacau_observatory": _observatory()
		"sibiu_roof_eyes": _sibiu()
		"targu_mures_culture_palace": _tg_mures_palace()
		"turnul_stefan": _stephens_tower()
		"trajan_bridge": _trajan_bridge()
		"suceava_citadel": _suceava_citadel()
		"delta_pelicans": _pelicans()
		"sighisoara_clock_tower": _clock_tower()
		"deva_citadel": _deva_citadel()
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

## A pointed (Gothic) window.
static func _pointed(x: float, y0: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.5, y0, x + w * 0.5, y0, x + w * 0.5, y0 + h - w * 0.8, x, y0 + h, x - w * 0.5, y0 + h - w * 0.8], col)

## Pitești's Tulip Symphony: rows of red, yellow, pink and white tulips in Strand Park, with the white Princely
## Church and its little round bell tower behind.
static func _tulips() -> void:
	# the church behind
	var w := Color("efe7d6")
	_r(-8, 4, 10, 15, w)
	_poly([-9, 15, 11, 15, 8, 18, -6, 18], Color("6b4a38"))
	_poly(_arc(1, 15, 9, 3, 0, PI, 10), Color("6b4a38"))
	_r(-3, 18, 3, 23, w)
	_poly([-3.5, 23, 3.5, 23, 0, 27], Color("6b4a38"))
	_l(0, 27, 0, 28, GOLD, 0.2)
	_l(-0.6, 27.6, 0.6, 27.6, GOLD, 0.15)
	for x in [-5.0, -1.0, 3.0, 7.0]:
		_arched(x, 8, 1.2, 3.5, WIN)
	_r(-8, 11.5, 10, 12, Color("b05a3c"))
	_c(-18, 7, 5, TREE)
	_c(19, 8, 6, TREE)
	# the beds of tulips
	_r(-25, 0, 25, 5, GRASS)
	var cols := [Color("d8202c"), Color("f2c418"), Color("e86fa0"), Color("f6f2ea"), Color("e2602a")]
	for row in 3:
		var y := 0.8 + row * 1.5
		for k in 25:
			var x := -24.0 + k * 2.0 + (row % 2) * 1.0
			var col: Color = cols[(k / 5 + row) % cols.size()]
			_l(x, y, x, y + 0.9, Color("3f7a32"), 0.12)
			_poly([x - 0.45, y + 0.9, x + 0.45, y + 0.9, x + 0.5, y + 1.6, x + 0.15, y + 1.4, x, y + 1.7, x - 0.15, y + 1.4, x - 0.5, y + 1.6], col)

## The Victor Anestin observatory in Bacău: a white building on a little hill with a silver dome, the shutter open
## and the telescope looking out, and a few stars.
static func _observatory() -> void:
	_poly([-15, 0, -10, 3, 10, 3, 15, 0], GRASS)
	var w := Color("eeeae0")
	_r(-10, 3, 10, 11, w)
	_r(-10.5, 11, 10.5, 12, Color("c8c0ae"))
	_windows(-8, 8, 5.5, 8.5, 5, WIN)
	_r(-1.2, 3, 1.2, 7, Color("6b5040"))
	# the dome and its open shutter
	_r(-6, 12, 6, 14, w)
	_poly(_arc(0, 14, 6.5, 6.5, 0, PI, 16), Color("b8c2c8"))
	_poly([-0.8, 14, 0.8, 14, 0.8, 20.4, -0.8, 20.4], Color("2a3036"))
	_l(0, 15, 3.5, 20.5, Color("5a6068"), 0.6)
	if _detail(0.8):
		for sx in [[-12.0, 19.0], [11.0, 21.0], [13.5, 16.5], [-9.0, 21.5]]:
			_c(sx[0], sx[1], 0.35, GOLD)

## Sibiu's Great Square: the Council Tower in the middle with its steep roof and four corner turrets, and the old
## houses either side whose red roofs look out through narrow eyebrow dormers, the "eyes" of Sibiu.
static func _sibiu() -> void:
	var cols := [Color("efd9a8"), Color("e6b9a0"), Color("d8e0c8"), Color("f2e6cf")]
	var roof := Color("b0482e")
	for i in 4:
		var x0: float = -25.0 + i * 11.5 if i < 2 else -25.0 + i * 11.5 + 4.0
		var x1: float = x0 + 10.5
		_r(x0, 0, x1, 9, cols[i])
		_windows(x0 + 1, x1 - 1, 5, 7, 3, WIN)
		_r(x0 + 4.5, 0, x0 + 6.0, 3, Color("6b5040"))
		_poly([x0 - 0.4, 9, x1 + 0.4, 9, (x0 + x1) * 0.5, 22], roof)
		# the eyes: narrow dormers like half-closed lids
		for e in [[0.5, 13.0], [0.3, 16.5], [0.7, 16.5]]:
			var ex: float = x0 + (x1 - x0) * e[0]
			var ey: float = e[1]
			_poly([ex - 1.1, ey, ex, ey + 0.8, ex + 1.1, ey, ex, ey - 0.3], roof.darkened(0.3))
			_poly([ex - 0.7, ey + 0.05, ex, ey + 0.45, ex + 0.7, ey + 0.05], Color("1e2226"))
	# the Council Tower
	var st := Color("e2d6bc")
	_r(-3, 0, 4, 30, st)
	_arched(0.5, 0, 3.6, 6, Color("4a3a30"))
	_windows(-2, 3, 13, 15, 2, WIN)
	_windows(-2, 3, 20, 22, 2, WIN)
	_c(0.5, 26, 1.3, WHITE)
	_l(0.5, 26, 0.5, 27, DARK, 0.15)
	_r(-3.4, 30, 4.4, 31, st.darkened(0.15))
	_poly([-3.4, 31, 4.4, 31, 0.5, 42], roof)
	for x in [-3.0, 4.0]:
		_poly([x - 0.7, 31, x + 0.7, 31, x, 35], roof.darkened(0.15))
	_l(0.5, 42, 0.5, 44, GOLD, 0.2)

## The Palace of Culture in Târgu Mureș: a Secession palace in cream with a decorated front, its roof of coloured
## glazed tiles in zigzags, and the tall corner tower with a pointed cap.
static func _tg_mures_palace() -> void:
	var w := Color("efe2c4")
	var orn := Color("c4a066")
	_r(-24, 0, 16, 20, w)
	_r(-24, 20, 16, 21, orn)
	# the tiled roof in zigzag bands
	_poly([-25, 21, 17, 21, 13, 31, -21, 31], Color("3f7a52"))
	if _detail(0.5):
		for band in 3:
			var y := 22.5 + band * 2.8
			var col: Color = [Color("e0b43a"), Color("c8402a"), Color("2e5d9a")][band]
			for k in 14:
				var x := -22.0 + band * 1.0 + k * 2.6
				if x > 14.0 - band * 1.2: break
				_poly([x, y, x + 1.3, y + 1.4, x + 2.6, y, x + 2.6, y + 0.5, x + 1.3, y + 1.9, x, y + 0.5], col)
	# the front: tall arched windows of the great hall and the entrance
	for x in [-20.0, -15.5, -11.0, 3.0, 7.5, 12.0]:
		_arched(x, 10, 2.2, 7, Color("5a7a8a"))
		_r(x - 1.1, 3, x + 1.1, 6.5, WIN)
	_arched(-4, 0, 7, 16, orn)
	_arched(-4, 1, 5.4, 13, Color("3e4a52"))
	_poly(_arc(-4, 9.2, 2.2, 2.2, 0, PI, 8), Color("e0b43a"))
	# the corner tower
	_r(16, 0, 24, 36, w)
	_r(16, 20, 24, 21, orn)
	_arched(20, 24, 2.4, 6, WIN)
	_arched(20, 12, 2.4, 6, WIN)
	_r(15.5, 36, 24.5, 37, orn)
	_poly([15.5, 37, 24.5, 37, 20, 46], Color("3f7a52"))
	_poly([18, 40, 22, 40, 20, 44], Color("e0b43a"))

## Stephen's Tower in Baia Mare: a lone square Gothic tower of grey stone with buttressed corners, a clock, a gallery
## and a steep pointed roof with little corner spires.
static func _stephens_tower() -> void:
	var st := Color("a9a294")
	var sd := st.darkened(0.2)
	_r(-10, 0, 10, 1.5, Color("8a8478"))
	_r(-6, 1.5, 6, 30, st)
	for x in [-6.0, 6.0]:
		_poly([x - 1.2, 1.5, x + 1.2, 1.5, x + 0.6, 18, x - 0.6, 18], sd)
	_pointed(0, 1.5, 3, 7, Color("3a3028"))
	_pointed(0, 13, 1.6, 5, WIN)
	_c(0, 22.5, 2.2, WHITE)
	_l(0, 22.5, 0, 24, DARK, 0.2)
	_l(0, 22.5, 1.2, 22.5, DARK, 0.15)
	# the gallery
	_r(-7, 30, 7, 31, sd)
	for k in 8:
		var x := -6.5 + k * 1.86
		_r(x - 0.2, 31, x + 0.2, 32.2, sd)
	_r(-7, 32.2, 7, 32.6, sd)
	_poly([-5.5, 31, 5.5, 31, 0, 41], Color("5a4a40"))
	for x in [-6.5, 6.5]:
		_poly([x - 0.6, 32.6, x + 0.6, 32.6, x, 36], Color("5a4a40"))
	_l(0, 41, 0, 42, GOLD, 0.2)

## Trajan's Bridge at Drobeta as Apollodorus built it: timber arches on stone piers across the Danube, a Roman
## gate at the near end, and in front on the bank the stump of a real surviving pier.
static func _trajan_bridge() -> void:
	_r(-40, 0, 40, 6, Color("4f7f8a"))
	if _detail(1.0):
		for x in [-30.0, -5.0, 18.0]:
			_l(x, 3, x + 6.0, 3, WATER_L, 0.15)
	var st := Color("cfc3a8")
	var wood := Color("8a5f38")
	var deck := 14.0
	# the piers and the timber arches
	for k in 6:
		var x := -26.0 + k * 13.0
		_r(x - 1.6, 0, x + 1.6, deck - 1.0, st)
	for k in 5:
		var x0 := -26.0 + k * 13.0 + 1.6
		var x1 := x0 + 13.0 - 3.2
		for off in [0.0, 1.2]:
			var pts := _arc((x0 + x1) * 0.5, deck - 6.0 - off, (x1 - x0) * 0.5, 5.0, 0, PI, 10)
			for i in range(0, pts.size() - 2, 2):
				_l(pts[i], pts[i + 1], pts[i + 2], pts[i + 3], wood, 0.35)
		for i in 4:
			var x := x0 + (i + 1) * (x1 - x0) / 5.0
			_l(x, deck - 1.0, x, deck - 3.5, wood, 0.2)
	_r(-30, deck - 1.0, 40, deck, wood)
	_l(-30, deck + 0.8, 40, deck + 0.8, wood.darkened(0.2), 0.15)
	# the gate at the bank
	_r(-36, 0, -28, deck + 6.0, st)
	_arched(-32, deck - 1.0, 3, 5.5, Color("4a3a30"))
	_r(-36.5, deck + 6.0, -27.5, deck + 7.0, st.darkened(0.15))
	_poly([-36.5, deck + 7.0, -27.5, deck + 7.0, -32, deck + 9.5], ROOF)
	# the surviving stump on the bank in front
	_poly([-40, 0, -40, 2, -33, 2, -31, 0], GRASS)
	_poly([-38.5, 2, -34, 2, -34.6, 7, -36, 8.2, -37.8, 6.5], st.darkened(0.2))

## The Seat Fortress of Suceava: thick grey walls on a grassy hill, round and square towers, the gate and the keep,
## partly ruined.
static func _suceava_citadel() -> void:
	_poly([-30, 0, -24, 5, -12, 7, 12, 7, 24, 5, 30, 0], GRASS)
	var st := Color("a8a090")
	var sd := st.darkened(0.18)
	_r(-22, 6, 22, 15, st)
	for k in 22:
		var x := -21.5 + k * 2.0
		if k == 7 or k == 8: continue # a gap in the ruined parapet
		_r(x - 0.5, 15, x + 0.5, 16.2, st)
	# towers
	for x in [-22.0, 22.0]:
		_r(x - 3, 5.5, x + 3, 19, sd)
		for k in 3:
			_r(x - 2.8 + k * 2.3, 19, x - 1.6 + k * 2.3, 20.4, sd)
		_r(x - 0.4, 12, x + 0.4, 14, WIN)
	for x in [-9.0, 9.0]:
		_poly(_arc(x, 17, 2.8, 1.4, 0, PI, 6) + [x - 2.8, 17, x - 2.8, 6, x + 2.8, 6, x + 2.8, 17], sd)
	# the keep
	_r(-4, 6, 4, 22, st)
	_r(-4.4, 22, 4.4, 23, sd)
	for k in 4:
		_r(-4.2 + k * 2.4, 23, -3.0 + k * 2.4, 24.4, sd)
	_r(-0.4, 15, 0.4, 18, WIN)
	_arched(0, 6, 3, 5, Color("3a3028"))
	_r(-0.1, 24.4, 0.1, 26, DARK)
	_r(0.1, 24.9, 1.6, 25.8, Color("2e4fa0"))

## Pelicans in the Danube Delta: a channel through the reeds, white pelicans afloat with their yellow pouches and one
## in flight, a fisherman's black boat by the reeds.
static func _pelicans() -> void:
	_r(-20, 0, 20, 3, Color("4f7f8a"))
	if _detail(1.5):
		_l(-15, 1.2, -9, 1.2, WATER_L, 0.1)
		_l(4, 0.7, 10, 0.7, WATER_L, 0.1)
	var reed := Color("8a8a4a")
	for k in 40:
		var side := -1.0 if k < 20 else 1.0
		var x: float = side * (13.0 + (k % 20) * 0.35)
		var h := 5.0 + float((k * 7) % 5)
		_l(x, 1.5, x + 0.3 * side, h, reed if k % 3 else reed.darkened(0.2), 0.12)
		if k % 4 == 0:
			_poly([x + 0.3 * side - 0.12, h, x + 0.3 * side + 0.12, h, x + 0.3 * side, h + 0.8], Color("6a4a30"))
	# the boat
	_poly([8.5, 1.4, 13.5, 1.4, 14.5, 2.4, 7.8, 2.4], Color("2a2a2a"))
	# pelicans on the water
	for p in [[-7.0, 1.0], [-1.5, 0.9], [4.0, 1.0]]:
		var x: float = p[0]
		var s: float = p[1]
		_poly([x - 1.4 * s, 1.6, x + 1.2 * s, 1.6, x + 1.0 * s, 2.6, x - 0.6 * s, 2.9, x - 1.6 * s, 2.3], WHITE)
		_l(x + 0.8 * s, 2.5, x + 1.0 * s, 4.0, WHITE, 0.25 * s)
		_c(x + 1.05 * s, 4.1, 0.32 * s, WHITE)
		_poly([x + 1.3 * s, 4.15, x + 2.9 * s, 3.7, x + 1.3 * s, 3.6], Color("f0b030"))
		_l(x - 1.3 * s, 2.3, x - 0.2 * s, 2.6, Color("3a3a3a"), 0.12)
	# one in flight
	var fx := 0.0
	var fy := 10.5
	_poly([fx - 0.9, fy, fx + 1.2, fy + 0.1, fx + 1.0, fy + 0.5, fx - 0.8, fy + 0.4], WHITE)
	_poly([fx - 0.2, fy + 0.4, fx - 4.5, fy + 2.2, fx - 5.0, fy + 1.9, fx + 0.3, fy + 0.2], WHITE)
	_poly([fx + 0.0, fy + 0.4, fx + 3.8, fy + 2.4, fx + 4.4, fy + 2.0, fx + 0.5, fy + 0.2], WHITE)
	_l(-4.0, fy + 2.0, -5.0, fy + 1.9, Color("2a2a2a"), 0.2)
	_l(3.6, fy + 2.2, 4.4, fy + 2.0, Color("2a2a2a"), 0.2)
	_poly([fx + 1.2, fy + 0.3, fx + 2.6, fy + 0.1, fx + 1.2, fy - 0.1], Color("f0b030"))

## The Clock Tower of Sighișoara: the citadel's stone gate tower with its passage, the big clock with the figures'
## niche, a wooden gallery, and the tall roof of coloured tiles with four corner turrets and a gilt ball.
static func _clock_tower() -> void:
	_poly([-12, 0, -9, 4, 9, 4, 12, 0], GRASS)
	var st := Color("e6dcc4")
	var sd := st.darkened(0.15)
	# a house either side
	for x in [-11.0, 7.0]:
		_r(x, 4, x + 4.0, 12, Color("e8c88a") if x < 0.0 else Color("b8d0c0"))
		_poly([x - 0.3, 12, x + 4.3, 12, x + 2.0, 16], ROOF)
	_r(-6, 4, 6, 36, st)
	_arched(0, 4, 4.5, 8, Color("3a3028"))
	_r(-6.4, 18, 6.4, 18.6, sd)
	# the clock and the niche for the figures
	_r(-2.2, 20, 2.2, 23, Color("5a3a2a"))
	_poly([-0.7, 20.4, 0.7, 20.4, 0.5, 22, -0.5, 22], Color("e0b43a"))
	_c(0, 27, 2.8, Color("2e4f7a"))
	_c(0, 27, 2.3, WHITE)
	_l(0, 27, 0, 29, DARK, 0.2)
	_l(0, 27, 1.4, 27.4, DARK, 0.18)
	# the wooden gallery
	_r(-7, 36, 7, 37.5, Color("6f4e30"))
	for k in 8:
		var x := -6.5 + k * 1.86
		_r(x - 0.25, 37.5, x + 0.25, 39.5, Color("6f4e30"))
	_r(-7, 39.5, 7, 40, Color("6f4e30"))
	# the tiled roof
	var tg := Color("3f7a52")
	var tr := Color("c8402a")
	_poly([-6.5, 40, 6.5, 40, 0, 60], tr)
	if _detail(0.6):
		for k in 6:
			var y := 42.0 + k * 3.0
			var hw := 6.5 * (1.0 - (y - 40.0) / 20.0)
			_l(-hw, y, hw, y, tg if k % 2 else Color("e0b43a"), 0.35)
	for x in [-6.5, 6.5]:
		_r(x - 0.8, 40, x + 0.8, 43, sd)
		_poly([x - 1.1, 43, x + 1.1, 43, x, 49], tr)
	_l(0, 60, 0, 63, DARK, 0.15)
	_c(0, 62, 0.5, GOLD)
	_l(-0.6, 63.4, 0.6, 63.4, GOLD, 0.15)

## The fortress of Deva: grey ruined walls and towers crowning a steep, wooded volcanic cone, the funicular's track
## climbing the slope with its little red car, and the town's roofs at the foot.
static func _deva_citadel() -> void:
	_poly([-25, 0, -18, 6, -10, 18, -5, 27, 5, 28, 11, 19, 18, 7, 25, 0], TREE)
	_poly([-25, 0, -20, 3, -14, 6, -4, 7, 8, 6, 18, 3, 25, 0], GRASS)
	# the town's houses at the foot
	for k in 6:
		var x := -22.0 + k * 8.0
		_r(x, 0, x + 4.5, 3.2, Color("ece4cf") if k % 2 else Color("e8c88a"))
		_poly([x - 0.3, 3.2, x + 4.8, 3.2, x + 2.25, 5.2], ROOF)
	# the funicular: a straight track up the right flank and its car
	_l(15, 3.5, 6, 27, Color("4a4038"), 0.35)
	_poly([10.6, 14.2, 12.6, 14.6, 12.0, 16.6, 10.0, 16.2], Color("c8302a"))
	_r(10.5, 15.2, 11.8, 15.9, WHITE)
	# the walls and towers along the top
	var st := Color("a49c8c")
	var sd := st.darkened(0.18)
	_r(-9, 26, 9, 33, st)
	for k in 9:
		var x := -8.5 + k * 2.1
		if k == 3: continue # a breach in the ruined parapet
		_r(x - 0.5, 33, x + 0.5, 34.2, st)
	for x in [-9.0, 9.0]:
		_r(x - 2.2, 25, x + 2.2, 36, sd)
		for k in 2:
			_r(x - 2.0 + k * 2.8, 36, x - 0.8 + k * 2.8, 37.2, sd)
		_r(x - 0.3, 30, x + 0.3, 32, WIN)
	_r(-1.8, 26, 1.8, 38.5, sd)
	_r(-2.0, 38.5, -0.8, 39.6, sd)
	_r(0.8, 38.5, 2.0, 39.6, sd)
	_arched(0, 26, 1.6, 3, Color("3a3028"))
	_r(-0.25, 33, 0.25, 35, WIN)
