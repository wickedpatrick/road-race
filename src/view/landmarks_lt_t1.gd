class_name LandmarksLtT1
extends RefCounted
## Lithuanian landmarks of the towns between the map cities, drawn with LandmarkPainter's helpers (metres from the
## base point, y up).

const WHITE := Color("f2efe6")
const GRASS := Color("5d8f42")
const TREE := Color("3f6f34")
const WATER := Color("4f8fc0")
const WATER_L := Color("9cc8e6")
const WIN := Color("3a4048")
const WOOD := Color("7a5634")
const WOOD_D := Color("5a3e26")
const THATCH := Color("b39a62")
const BRONZE := Color("6b5a3a")
const STONE := Color("b9b4a8")
const GLASS := Color("8fb8cf")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"rumsiskes_farmstead": _rumsiskes_farmstead()
		"zemaitis_monument": _zemaitis_monument()
		"kedainiai_minaret": _kedainiai_minaret()
		"kretinga_winter_garden": _kretinga_winter_garden()
		"pervalka_lighthouse": _pervalka_lighthouse()
		"moletai_observatory": _moletai_observatory()
		"prienai_glider": _prienai_glider()
		"varena_boletus": _varena_boletus()
		"merkine_hillfort": _merkine_hillfort()
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

## A round tree crown on a short trunk.
static func _tree(x: float, y: float, r: float) -> void:
	_r(x - r * 0.12, y, x + r * 0.12, y + r, WOOD)
	_c(x, y + r * 1.4, r, TREE)
	_c(x - r * 0.35, y + r * 1.6, r * 0.55, TREE.lightened(0.1))

## Rumšiškės open-air museum: an old log farmhouse under a big thatched roof, small white-framed windows, a well
## sweep (a long beam on a forked post) over the well and a roofed wooden cross pole (stogastulpis) by the yard.
static func _rumsiskes_farmstead() -> void:
	_r(-12, 0, 12, 0.6, GRASS)
	# the house
	_r(-7.5, 0.6, 4.5, 4.2, WOOD)
	if _detail(1.0):
		for k in 6:
			var y: float = 1.1 + k * 0.55
			_l(-7.5, y, 4.5, y, WOOD_D, 0.08)
	for x in [-6.0, -3.0, 2.0]:
		_r(x - 0.75, 1.8, x + 0.75, 3.2, WHITE)
		_r(x - 0.55, 2.0, x + 0.55, 3.0, WIN)
		if _detail(1.4):
			_l(x, 2.0, x, 3.0, WHITE, 0.08)
			_l(x - 0.55, 2.5, x + 0.55, 2.5, WHITE, 0.08)
	_r(-0.7, 0.6, 0.7, 3.3, WOOD_D) # door
	# the thatched hip-gable roof
	_poly([-8.6, 4.0, 5.6, 4.0, 3.2, 9.0, -6.3, 9.0], THATCH)
	_poly([-8.6, 4.0, -5.8, 4.0, -4.6, 9.0, -6.3, 9.0], THATCH.lightened(0.12))
	_poly([-6.3, 9.0, 3.2, 9.0, 2.6, 9.5, -5.7, 9.5], THATCH.darkened(0.25)) # ridge
	_r(-8.6, 3.8, 5.6, 4.2, THATCH.darkened(0.15))
	_r(-1.0, 8.6, 0.0, 10.2, Color("8a7e70")) # chimney
	# the well sweep
	var post := Vector2(8.2, 4.3)
	_l(post.x, 0.6, post.x, post.y, WOOD_D, 0.3)
	_l(post.x, post.y, post.x - 0.35, post.y + 0.5, WOOD_D, 0.15)
	_l(post.x, post.y, post.x + 0.35, post.y + 0.5, WOOD_D, 0.15)
	_l(6.0, 1.4, 11.3, 9.4, WOOD, 0.22)
	_r(5.6, 1.0, 6.6, 1.8, Color("8a8580")) # counterweight stone
	_l(11.3, 9.4, 11.3, 2.0, WOOD_D, 0.08)
	_r(10.9, 1.6, 11.7, 2.4, WOOD_D) # bucket
	_r(10.2, 0.6, 12.0, 1.6, WOOD.lightened(0.1)) # the well box
	_r(10.2, 1.4, 12.0, 1.6, WOOD_D)
	# the roofed cross pole
	_r(-10.6, 0.6, -10.2, 6.5, WOOD)
	_r(-11.2, 5.6, -9.6, 7.0, WOOD.lightened(0.15))
	_r(-10.8, 5.9, -10.0, 6.7, Color("e8d9b0")) # little saint inside
	_poly([-11.6, 7.0, -9.2, 7.0, -10.4, 8.2], WOOD_D)
	_l(-10.4, 8.2, -10.4, 9.4, Color("8a8d92"), 0.12)
	_l(-10.8, 9.0, -10.0, 9.0, Color("8a8d92"), 0.12)
	_c(-10.4, 9.0, 0.3, Color("8a8d92"))

## The "Žemaitis" monument in Raseiniai: a strong Samogitian man in bronze with a bear, the old symbol of Samogitia,
## on a tall stone plinth in the market square.
static func _zemaitis_monument() -> void:
	_r(-3, 0, 3, 0.6, STONE.darkened(0.1))
	_r(-2.4, 0.6, 2.4, 1.3, STONE)
	_r(-1.5, 1.3, 1.5, 6.6, STONE)
	_r(-1.5, 1.3, -1.0, 6.6, STONE.lightened(0.1))
	_r(-2.0, 6.6, 2.0, 7.2, STONE.lightened(0.05))
	if _detail(1.4):
		_r(-0.9, 3.6, 0.9, 4.2, BRONZE) # name plate
	var b := BRONZE
	var bl := BRONZE.lightened(0.15)
	# the bear, sitting up on the left of the man
	_ell(-1.0, 8.0, 0.9, 0.8, 0.0, b.darkened(0.1))
	_c(-1.25, 9.0, 0.5, b.darkened(0.1))
	_c(-1.6, 9.35, 0.17, b.darkened(0.1))
	_c(-0.95, 9.4, 0.17, b.darkened(0.1))
	_c(-1.55, 8.85, 0.18, b.darkened(0.25)) # snout
	_r(-1.7, 7.2, -1.3, 7.6, b.darkened(0.1))
	_r(-0.7, 7.2, -0.3, 7.6, b.darkened(0.1))
	# the man
	_poly([0.2, 7.2, 0.6, 7.2, 0.7, 9.0, 0.3, 9.0], b) # legs
	_poly([0.9, 7.2, 1.3, 7.2, 1.2, 9.0, 0.8, 9.0], b)
	_poly([0.15, 9.0, 1.35, 9.0, 1.55, 10.8, -0.05, 10.8], bl) # body
	_c(0.75, 11.25, 0.42, bl) # head
	_l(1.45, 10.6, 1.9, 9.4, b, 0.28) # right arm down
	_l(0.0, 10.6, -0.5, 11.6, b, 0.28) # left arm raised
	_l(-0.5, 11.6, -0.5, 12.0, Color("8a8d92"), 0.12) # the sword hilt
	_l(-0.6, 11.4, -0.4, 11.8, b, 0.25)

## The Kėdainiai minaret: a slim pale tower from the 1880s in the town park, the only minaret in Lithuania, with
## its ring balcony, the pointed cap and a crescent on top.
static func _kedainiai_minaret() -> void:
	_r(-4, 0, 4, 0.5, GRASS)
	_tree(-3.0, 0.4, 1.2)
	_tree(3.1, 0.4, 1.1)
	var s := Color("e6dcc4")
	var sd := s.darkened(0.15)
	_r(-1.9, 0.4, 1.9, 3.4, sd) # octagonal base
	_r(-1.9, 0.4, -1.3, 3.4, s)
	_r(-0.5, 0.4, 0.5, 2.0, WIN)
	_poly([-1.4, 3.4, 1.4, 3.4, 1.1, 18.0, -1.1, 18.0], s) # the shaft
	_poly([-1.4, 3.4, -0.7, 3.4, -0.55, 18.0, -1.1, 18.0], s.lightened(0.06))
	_poly([0.9, 3.4, 1.4, 3.4, 1.1, 18.0, 0.7, 18.0], sd)
	if _detail(1.2):
		for y in [6.0, 10.0, 14.0]:
			_r(-1.3, y, 1.3, y + 0.25, Color("b6845a"))
		for y in [7.5, 12.0, 15.8]:
			_r(-0.18, y, 0.18, y + 0.9, WIN)
	# the balcony
	_poly([-1.1, 17.4, 1.1, 17.4, 1.9, 18.3, -1.9, 18.3], sd)
	_r(-1.9, 18.3, 1.9, 19.2, s)
	if _detail(1.2):
		for x in [-1.5, -0.8, -0.1, 0.6, 1.3]:
			_r(x, 18.5, x + 0.3, 19.0, sd)
	# the upper drum and cap
	_r(-0.8, 19.2, 0.8, 22.0, s)
	_r(0.4, 19.2, 0.8, 22.0, sd)
	_r(-0.15, 20.0, 0.15, 21.0, WIN)
	_poly([-1.0, 22.0, 1.0, 22.0, 0, 25.0], Color("5f7d8a"))
	_l(0, 25.0, 0, 25.6, LandmarkPainter.GOLD, 0.12)
	_c(0, 26.0, 0.4, LandmarkPainter.GOLD)
	_c(0.2, 26.1, 0.33, Color("8ec3e8"))

## Kretinga manor: the white Tyszkiewicz palace and its big glass winter garden with palms growing inside under the
## arched glass roof.
static func _kretinga_winter_garden() -> void:
	_r(-17, 0, 17, 0.5, GRASS)
	# the palace
	var w := WHITE
	var roof := Color("6d5d55")
	_r(-16, 0.5, 2, 9, w)
	_r(-16, 0.5, -15, 9, w.darkened(0.06))
	_windows(-15, 1, 2, 4, 7, WIN)
	_windows(-15, 1, 5.5, 7.5, 7, WIN)
	_poly([-16.6, 9, 2.6, 9, 0.5, 12, -14.5, 12], roof)
	# the portico
	_r(-9.5, 0.5, -4.5, 1.0, w.darkened(0.1))
	for x in [-9.0, -7.7, -6.3, -5.0]:
		_r(x - 0.3, 1.0, x + 0.3, 8.2, w.lightened(0.04))
	_poly([-9.8, 8.2, -4.2, 8.2, -4.2, 9, -7, 11.2, -9.8, 9], w.darkened(0.05))
	_poly([-9.0, 9.0, -5.0, 9.0, -7, 10.6], w.darkened(0.12))
	# the winter garden: a glass house with a half-barrel glass roof
	var frame := Color("e8ebee")
	_r(2, 0.5, 16, 6.5, GLASS)
	_poly(_arc(9, 6.5, 7.0, 6.0, 0, PI, 18), GLASS.lightened(0.15))
	# palms inside
	for p in [[5.0, 7.0], [9.5, 10.5], [13.5, 6.5]]:
		var x: float = p[0]
		var top: float = p[1]
		_l(x, 0.5, x + 0.3, top, Color("8a6a44"), 0.3)
		for a in [-2.6, -1.8, -1.0, -0.2, 0.6]:
			_l(x + 0.3, top, x + 0.3 + cos(a + PI * 0.5) * 2.0, top + sin(a + PI * 0.5) * 1.2 - 0.6,
				Color("3f8a4a"), 0.35)
	# the frames
	for k in 8:
		var x: float = 2.0 + k * 2.0
		_l(x, 0.5, x, 6.5, frame, 0.15)
	_l(2, 6.5, 16, 6.5, frame, 0.2)
	_l(2, 3.5, 16, 3.5, frame, 0.1)
	if _detail(0.8):
		for k in range(1, 9):
			var a := PI * k / 9.0
			_l(9 + cos(a) * 7.0, 6.5 + sin(a) * 6.0, 9 + cos(a) * 1.0, 6.5 + sin(a) * 0.8, frame, 0.1)
	_pl(_arc(9, 6.5, 7.0, 6.0, 0, PI, 18), frame, 0.2)
	_pl(_arc(9, 6.5, 4.0, 3.4, 0, PI, 12), frame, 0.1)
	_r(8.0, 0.5, 10.0, 3.0, GLASS.darkened(0.3)) # the door

static func _pl(xy: Array, col: Color, w: float) -> void:
	LandmarkPainter._pl(xy, col, w)

## Pervalka lighthouse: a small white iron tower from 1900 with a red lantern roof, standing on its own little
## island of stones in the Curonian Lagoon.
static func _pervalka_lighthouse() -> void:
	_r(-5, 0, 5, 1.2, WATER)
	if _detail(1.0):
		_l(-4.5, 0.6, -2.5, 0.6, WATER_L, 0.15)
		_l(2.6, 0.5, 4.4, 0.5, WATER_L, 0.15)
	var rock := Color("8f8a80")
	_poly([-3.6, 0.6, 3.6, 0.6, 2.8, 2.2, -2.8, 2.2], rock)
	if _detail(0.8):
		for p in [[-2.6, 1.2], [-1.4, 1.6], [0.0, 1.2], [1.3, 1.7], [2.5, 1.1], [-0.6, 2.0], [0.8, 2.0]]:
			_c(p[0], p[1], 0.55, rock.lightened(0.12))
	var w := WHITE
	_poly([-0.9, 2.2, 0.9, 2.2, 0.65, 10.6, -0.65, 10.6], w)
	_poly([0.4, 2.2, 0.9, 2.2, 0.65, 10.6, 0.3, 10.6], w.darkened(0.1))
	_r(-0.3, 2.2, 0.3, 3.6, WIN) # door
	if _detail(1.2):
		_r(-0.15, 6.0, 0.15, 6.8, WIN)
	_r(-1.2, 10.6, 1.2, 11.0, Color("3a3d42")) # the gallery
	_l(-1.2, 11.5, 1.2, 11.5, Color("3a3d42"), 0.08)
	_l(-1.15, 11.0, -1.15, 11.5, Color("3a3d42"), 0.08)
	_l(1.15, 11.0, 1.15, 11.5, Color("3a3d42"), 0.08)
	_r(-0.6, 11.0, 0.6, 12.4, Color("f4e7a0")) # the lantern glass
	_l(0, 11.0, 0, 12.4, Color("3a3d42"), 0.08)
	_poly([-0.85, 12.4, 0.85, 12.4, 0, 13.4], Color("c0392b"))
	_l(0, 13.4, 0, 13.9, Color("3a3d42"), 0.1)

## Molėtai astronomical observatory on the Kaldiniai hill near Molėtai: white buildings with silver telescope domes,
## the big one with its slit open to the sky.
static func _moletai_observatory() -> void:
	_poly([-15, 0, 15, 0, 11, 3.5, 5, 5.2, -5, 5.2, -11, 3.5], GRASS)
	_poly([-15, 0, -8, 0, -6, 4.8, -11, 3.5], GRASS.darkened(0.08))
	_tree(-12.5, 2.0, 1.2)
	_tree(12.6, 2.0, 1.1)
	var w := WHITE
	var silver := Color("c4cad0")
	# the main building and its big dome
	_r(-7, 5.0, 3, 10, w)
	_r(-7, 5.0, -6, 10, w.darkened(0.06))
	_windows(-6, 2, 6.2, 7.6, 5, WIN)
	_r(-7.3, 10, 3.3, 10.5, w.darkened(0.1))
	_poly(_arc(-2, 10.5, 4.2, 4.2, 0, PI, 18), silver)
	_poly(_arc(-2, 10.5, 4.2, 4.2, PI * 0.6, PI, 8) + [-2, 10.5], silver.lightened(0.12))
	_poly([-2.6, 10.5, -1.4, 10.5, -1.0, 14.6, -2.2, 14.7], Color("2a3340")) # the open slit
	_l(-1.7, 12.0, -0.6, 15.0, Color("5a6068"), 0.4) # the telescope peeking out
	# the small tower with its dome
	_r(5, 5.0, 9.5, 12.5, w)
	_r(8.6, 5.0, 9.5, 12.5, w.darkened(0.08))
	_r(6.6, 8.5, 7.9, 10.0, WIN)
	_r(4.8, 12.5, 9.7, 12.9, w.darkened(0.1))
	_poly(_arc(7.25, 12.9, 2.4, 2.4, 0, PI, 14), silver)
	_poly([7.0, 12.9, 7.6, 12.9, 7.7, 15.2, 7.1, 15.3], Color("2a3340"))
	_r(3, 5.0, 5, 7.5, w.darkened(0.04)) # the link between them
	_r(-0.5, 5.0, 1.0, 7.0, WIN.lightened(0.1)) # door

## A Lithuanian sailplane: the slim white glider from the Prienai glider works (the LAK gliders), resting on its one
## wheel with a wingtip on the grass, a clear bubble canopy and its T-shaped tail.
static func _prienai_glider() -> void:
	_r(-8, 0, 8, 0.3, GRASS)
	var w := Color("f6f6f2")
	var ws := Color("cfd3d8")
	# the far wing behind the body, rising toward the back
	_poly([-0.6, 2.1, 1.0, 2.1, 5.4, 3.9, 4.9, 4.05], ws)
	# the body: a round pod that thins into the tail boom
	_poly([-7.4, 1.5] + _arc(-6.2, 1.5, 1.2, 0.55, PI, PI * 0.5, 6) + [-3, 2.3, 0.5, 2.4, 3.5, 2.0, 7.0, 1.95,
		7.0, 1.65, 3.5, 1.35, 0.5, 0.95, -3, 0.85] + _arc(-6.2, 1.5, 1.2, 0.6, PI * 1.5, PI, 6), w)
	_poly([-3, 0.85, 0.5, 0.95, 3.5, 1.35, 7.0, 1.65, 7.0, 1.75, 3.5, 1.5, 0.5, 1.15, -3, 1.05], ws)
	# the canopy
	_poly([-5.8, 2.0, -5.0, 2.55, -3.6, 2.85, -2.2, 2.6, -1.6, 2.32, -5.0, 2.1], Color("3d5a78"))
	if _detail(1.4):
		_l(-4.9, 2.5, -3.2, 2.75, Color("a9c8e0"), 0.1)
	# the tail fin and the T stabiliser
	_poly([5.6, 1.95, 7.0, 1.95, 7.4, 4.3, 6.6, 4.3], w)
	_poly([6.6, 4.3, 7.4, 4.3, 7.3, 3.4, 6.5, 3.2], Color("d8443a")) # red tip
	_r(5.6, 4.25, 8.0, 4.5, ws)
	# the wheel
	_c(-1.6, 0.65, 0.4, Color("2e3238"))
	_c(-1.6, 0.65, 0.15, Color("8a8d92"))
	# the near wing coming out toward us, its tip resting on the grass
	_poly([-0.9, 1.9, 1.1, 1.9, -6.6, 0.35, -7.6, 0.28], w.darkened(0.03))
	_poly([-0.9, 1.9, -0.2, 1.9, -7.2, 0.3, -7.6, 0.28], w.lightened(0.05))
	_poly([-7.6, 0.28, -6.6, 0.35, -6.9, 0.55], Color("d8443a"))
	_l(-0.9, 1.9, -7.6, 0.28, ws, 0.06)

## Dzūkija's ceps: Varėna is the mushroom capital of Lithuania, with a big mushroom festival every year. A fat
## boletus with a brown cap and a small one beside it in the moss among pine needles.
static func _varena_boletus() -> void:
	_poly([-3, 0, 3, 0, 2.6, 0.5, 1.0, 0.8, -1.2, 0.75, -2.7, 0.45], Color("6f9a4a"))
	var stem := Color("eadfc6")
	var cap := Color("8a4f28")
	# the big one
	_poly([-1.0, 0.5, 1.0, 0.5, 1.45, 1.6, 1.3, 2.8, 0.9, 3.7, -0.9, 3.7, -1.3, 2.8, -1.45, 1.6], stem)
	_poly([0.6, 0.5, 1.0, 0.5, 1.45, 1.6, 1.3, 2.8, 0.9, 3.7, 0.55, 3.7], stem.darkened(0.08))
	if _detail(1.4):
		for k in 4:
			var y: float = 1.4 + k * 0.55
			_l(-0.8, y, 0.8, y + 0.1, stem.darkened(0.12), 0.06)
	_poly([-2.6, 3.6, 2.6, 3.6] + _arc(0, 3.6, 2.6, 2.1, 0, PI, 18), cap)
	_r(-2.5, 3.3, 2.5, 3.65, Color("d9c27a")) # the yellow sponge underneath
	_poly(_arc(-0.6, 4.6, 1.2, 0.7, PI * 0.15, PI * 0.85, 8), cap.lightened(0.18))
	# the small one
	_poly([1.9, 0.5, 2.45, 0.5, 2.55, 1.1, 2.4, 1.5, 1.95, 1.5, 1.8, 1.1], stem)
	_poly([1.45, 1.45, 2.9, 1.45] + _arc(2.18, 1.45, 0.72, 0.6, 0, PI, 10), cap)
	# pine needles and a leaf
	if _detail(1.0):
		for p in [[-2.4, 0.6, -1.8, 0.9], [-1.9, 0.6, -2.3, 1.0], [2.6, 0.55, 2.9, 0.9], [-0.2, 0.75, 0.4, 0.85]]:
			_l(p[0], p[1], p[2], p[3], Color("a07a40"), 0.06)
		_ell(-2.2, 0.8, 0.35, 0.18, 0.4, Color("c98a2c"))

## Merkinė hill fort: a steep green mound over the Nemunas where the Merkys flows into it, with the long wooden
## staircase climbing to its flat top.
static func _merkine_hillfort() -> void:
	_r(-20, 0, 20, 1.6, WATER)
	if _detail(1.0):
		_l(-18, 0.8, -12, 0.8, WATER_L, 0.2)
		_l(10, 0.6, 17, 0.6, WATER_L, 0.2)
	var g := GRASS
	_r(-20, 1.4, 20, 2.2, g.darkened(0.05))
	_poly([-15, 2.0, 16, 2.0, 9, 14.5, 6, 15.4, -5, 15.6, -8, 14.6], g)
	_poly([-15, 2.0, -9, 2.0, -3, 15.5, -5, 15.6, -8, 14.6], g.lightened(0.08))
	_poly([10, 2.0, 16, 2.0, 9, 14.5, 7, 15.2], g.darkened(0.1))
	_poly([-8, 14.6, -5, 15.6, 6, 15.4, 9, 14.5, 7, 15.9, -6, 16.0], g.lightened(0.15)) # the flat top
	# trees on the slopes and at the foot
	for p in [[-17.5, 2.0, 1.3], [-13.5, 3.2, 1.1], [12.2, 6.0, 1.0], [14.0, 3.0, 1.2], [17.8, 2.0, 1.1]]:
		_tree(p[0], p[1], p[2])
	# the wooden staircase zigzagging up the front
	var st := Color("a77c4c")
	var path := [-1.0, 2.0, 5.0, 6.0, -2.0, 10.0, 3.0, 15.4]
	for k in range(0, path.size() - 2, 2):
		_l(path[k], path[k + 1], path[k + 2], path[k + 3], st, 0.7)
		_l(path[k], path[k + 1] + 0.6, path[k + 2], path[k + 3] + 0.6, WOOD_D, 0.12)
	_r(-1.6, 1.8, -0.4, 2.2, st)
	# a little wooden sign post and the Lithuanian flag on the top
	_l(-1.5, 15.8, -1.5, 18.0, Color("8a8d92"), 0.15)
	_r(-1.5, 17.5, 0.2, 18.0, Color("fdb913"))
	_r(-1.5, 17.0, 0.2, 17.5, Color("006a44"))
	_r(-1.5, 16.5, 0.2, 17.0, Color("c1272d"))
