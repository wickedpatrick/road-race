class_name LandmarksPtA
extends RefCounted
## Portuguese landmarks, drawn with LandmarkPainter's helpers (metres from the base point, y up).

const LIME := Color("ece6d6")
const LIME_D := Color("cdc4ae")
const GRANITE := Color("b8b2a4")
const GRANITE_D := Color("8f897c")
const STONE := Color("d6c9a8")
const STONE_D := Color("b0a383")
const WHITE := Color("f4f1ea")
const OCHRE := Color("e3b85c")
const TILE := Color("b4553a")
const WIN := Color("33363c")
const DARK := Color("26282c")
const GRASS := Color("6f8f45")
const WATER := Color("4f7fa6")
const WATER_L := Color("7aa3c4")
const GREEN := Color("4f7a3a")

## Draws `kind` when it is one of these; false otherwise.
static func draw(kind: String) -> bool:
	match kind:
		"pt_lisboa_belem": _lisboa_belem()
		"pt_porto_clerigos": _porto_clerigos()
		"pt_braga_bom_jesus": _braga_bom_jesus()
		"pt_guimaraes_castelo": _guimaraes_castelo()
		"pt_coimbra_universidade": _coimbra_universidade()
		"pt_leiria_castelo": _leiria_castelo()
		"pt_setubal_sao_filipe": _setubal_sao_filipe()
		"pt_viseu_se": _viseu_se()
		"pt_aveiro_moliceiro": _aveiro_moliceiro()
		"pt_faro_arco_vila": _faro_arco_vila()
		"pt_evora_templo": _evora_templo()
		"pt_vila_real_mateus": _vila_real_mateus()
		"pt_braganca_castelo": _braganca_castelo()
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

static func _arched(x: float, y0: float, w: float, h: float, col: Color) -> void:
	_poly([x - w * 0.5, y0, x + w * 0.5, y0, x + w * 0.5, y0 + h - w * 0.5] + _arc(x, y0 + h - w * 0.5, w * 0.5, w * 0.5, 0, PI, 6), col)

## Square merlons along the top of a wall from x0 to x1 at height y.
static func _merlons(x0: float, x1: float, y: float, w: float, h: float, col: Color) -> void:
	var n := maxi(1, int((x1 - x0) / (w * 2.0)))
	var step := (x1 - x0) / n
	for k in n:
		var x := x0 + step * k + (step - w) * 0.5
		_r(x, y, x + w, y + h, col)

## Belém Tower: the low bastion standing in the river with its round sentry boxes, the four-storey tower rising
## behind it with the loggia and the battlements of shields.
static func _lisboa_belem() -> void:
	_r(-20, 0, 20, 1.5, WATER)
	_r(-18, 1.5, 6, 11, LIME)
	_r(-18, 11, 6, 12, LIME_D)
	_merlons(-18, 6, 12, 1.0, 1.3, LIME)
	for x in [-18.0, 6.0]:
		_r(x - 1.2, 11, x + 1.2, 14, LIME)
		_poly(_arc(x, 14, 1.2, 1.6, 0, PI, 6), LIME_D)
	for x in [-14.0, -9.0, -4.0, 1.0]:
		_arched(x, 5, 1.6, 3.2, WIN)
	# the tower
	_r(2, 1.5, 15, 30, LIME)
	_r(1.6, 29, 15.4, 30, LIME_D)
	_merlons(2, 15, 30, 1.0, 1.4, LIME)
	_r(4, 18, 13, 22, LIME_D)
	for x in [5.5, 8.5, 11.5]:
		_arched(x, 18.3, 2.0, 3.4, WIN)
	_arched(8.5, 24, 2.0, 3.4, WIN)
	_arched(8.5, 12, 2.0, 3.4, WIN)
	for x in [2.0, 15.0]:
		_r(x - 1.1, 26, x + 1.1, 31, LIME)
		_poly(_arc(x, 31, 1.1, 1.8, 0, PI, 6), LIME_D)
	_c(8.5, 32.6, 1.0, LIME_D)
	_r(8.2, 30, 8.8, 32, LIME_D)

## The Clérigos Tower: the granite Baroque bell tower over the church roof, its storeys narrowing upward, the
## clock, the open belfry and the cupola with its ball.
static func _porto_clerigos() -> void:
	_r(-15, 0, 15, 0.6, GRANITE_D)
	# the church in front
	_r(-14, 0.6, 2, 18, WHITE)
	_poly([-14, 18, 2, 18, -6, 23], GRANITE)
	_arched(-6, 0.6, 3.0, 6.0, DARK)
	_c(-6, 13, 1.6, GRANITE_D)
	# the tower
	_r(2, 0.6, 12, 46, GRANITE)
	_r(1.6, 46, 12.4, 47.2, GRANITE_D)
	for y in [10.0, 20.0, 30.0, 38.0]:
		_arched(7, y, 2.4, 4.0, WIN)
	_r(3, 47.2, 11, 57, GRANITE)
	_c(7, 52, 2.0, WHITE)
	_l(7, 52, 7, 53.5, DARK, 0.25)
	_l(7, 52, 8.2, 52, DARK, 0.25)
	_r(2.6, 57, 11.4, 58, GRANITE_D)
	_r(4, 58, 10, 66, GRANITE)
	_arched(7, 59, 3.2, 6.0, WIN)
	_r(3.6, 66, 10.4, 67, GRANITE_D)
	_poly(_arc(7, 67, 3.2, 5.0, 0, PI, 10), GRANITE)
	_r(6.6, 72, 7.4, 75, GRANITE_D)
	_c(7, 75.8, 1.0, GRANITE_D)
	_l(7, 76.8, 7, 79.5, DARK, 0.25)

## Bom Jesus do Monte: the zigzag white stairway climbing the wooded hill to the church with two towers.
static func _braga_bom_jesus() -> void:
	_poly([-30, 0, 30, 0, 30, 24, 16, 30, -16, 30, -30, 24], GREEN)
	# the stairway in flights turning left and right
	for k in 6:
		var y := 1.0 + k * 4.6
		var x0: float = -8.0 if k % 2 == 0 else -2.0
		_poly([x0, y, x0 + 10.0, y + 3.6, x0 + 10.0, y + 4.6, x0, y + 1.0], WHITE)
		_r(-1.5, y + 3.0, 1.5, y + 4.6, LIME)
	# the church on the top
	_r(-12, 30, 12, 42, WHITE)
	_poly([-5, 42, 5, 42, 0, 46], WHITE)
	_arched(0, 30, 3.0, 6.0, DARK)
	_arched(-4.5, 36, 1.6, 3.0, WIN)
	_arched(4.5, 36, 1.6, 3.0, WIN)
	for x in [-10.0, 10.0]:
		_r(x - 2.2, 30, x + 2.2, 48, WHITE)
		_r(x - 2.4, 42, x + 2.4, 43, GRANITE)
		_arched(x, 44, 1.6, 3.0, WIN)
		_poly(_arc(x, 48, 2.2, 3.0, 0, PI, 8), GRANITE)
		_l(x, 51, x, 54, GRANITE_D, 0.3)

## Guimarães Castle: the curtain wall with its square towers on the grassy hill and the tall keep in the middle.
static func _guimaraes_castelo() -> void:
	_poly([-28, 0, 28, 0, 24, 3, -24, 3], GRASS)
	_r(-22, 3, 22, 14, GRANITE)
	_merlons(-22, 22, 14, 1.2, 1.5, GRANITE)
	for x in [-22.0, -11.0, 11.0, 22.0]:
		var w := 2.5 if absf(x) > 20.0 else 3.0
		_r(x - w, 3, x + w, 19, GRANITE)
		_merlons(x - w, x + w, 19, 1.0, 1.4, GRANITE)
	_arched(0, 3, 3.0, 6.0, DARK)
	# the keep
	_r(-4, 14, 4, 28, GRANITE_D)
	_merlons(-4, 4, 28, 1.0, 1.6, GRANITE_D)
	_r(-0.4, 21, 0.4, 24, DARK)

## The University of Coimbra: the long wing of the palace on the hill and the Baroque clock tower at its corner.
static func _coimbra_universidade() -> void:
	_r(-25, 0, 25, 0.6, GRANITE_D)
	_r(-24, 0.6, 12, 14, WHITE)
	_r(-24.5, 14, 12.5, 15, OCHRE)
	for k in 7:
		var x := -21.0 + k * 4.5
		_r(x, 4, x + 2, 7.5, WIN)
		_r(x, 9.5, x + 2, 12.5, WIN)
	_arched(-3, 0.6, 3.0, 4.5, DARK)
	# the tower
	_r(13, 0.6, 21, 30, WHITE)
	_r(12.6, 14, 21.4, 15, OCHRE)
	_r(12.6, 24, 21.4, 25, OCHRE)
	_arched(17, 5, 2.4, 5.0, WIN)
	_c(17, 19.5, 2.4, OCHRE)
	_c(17, 19.5, 1.9, WHITE)
	_l(17, 19.5, 17, 21, DARK, 0.25)
	_l(17, 19.5, 18.2, 19.5, DARK, 0.25)
	_arched(17, 25.5, 3.0, 4.0, WIN)
	_r(13.5, 30, 20.5, 31, OCHRE)
	_poly(_arc(17, 31, 3.5, 5.0, 0, PI, 10), LIME_D)
	_r(16.6, 36, 17.4, 38, LIME_D)
	_c(17, 38.6, 0.7, LIME_D)

## Leiria Castle on its hill: the walls following the slope, the keep and the open Gothic loggia of the palace.
static func _leiria_castelo() -> void:
	_poly([-32, 0, 32, 0, 22, 14, -26, 16], GREEN)
	_poly([-24, 15, -4, 16, -4, 24, -24, 22], STONE)
	_merlons(-24, -4, 22.5, 1.0, 1.3, STONE)
	# the loggia
	_r(-4, 14, 14, 28, STONE)
	for k in 5:
		_arched(-1.5 + k * 3.5, 19, 2.4, 6.0, WIN)
	_r(-4.4, 27.4, 14.4, 28.4, STONE_D)
	# the keep
	_r(14, 12, 22, 36, STONE_D)
	_merlons(14, 22, 36, 1.0, 1.6, STONE_D)
	_r(17.6, 26, 18.4, 29, DARK)

## The Fort of São Filipe: angled bastions in yellowish stone on the green slope, the gate and the chapel roof.
static func _setubal_sao_filipe() -> void:
	_poly([-35, 0, 35, 0, 35, 6, -35, 10], GREEN)
	_poly([-32, 9, -24, 18, 24, 18, 32, 6, 20, 6, 0, 7.5, -20, 8.5], STONE)
	_r(-24, 18, 24, 19, STONE_D)
	for x in [-24.0, 24.0]:
		_poly([x - 3, 19, x + 3, 19, x + 1.8, 21, x - 1.8, 21], STONE_D)
	_arched(0, 10, 3.0, 5.0, DARK)
	_r(-8, 19, 6, 21, WHITE)
	_poly([-9, 21, 7, 21, -1, 23.5], TILE)

## Viseu Cathedral: the granite front between two square towers with their balustrades and pinnacles.
static func _viseu_se() -> void:
	_r(-20, 0, 20, 0.6, GRANITE_D)
	_r(-9, 0.6, 9, 24, GRANITE)
	_r(-9.4, 24, 9.4, 25, GRANITE_D)
	_arched(0, 0.6, 4.0, 8.0, DARK)
	_r(-3.5, 11, 3.5, 20, GRANITE_D)
	_arched(0, 13, 2.4, 5.0, WIN)
	for x in [-14.0, 14.0]:
		_r(x - 5, 0.6, x + 5, 32, GRANITE)
		_r(x - 5.4, 31, x + 5.4, 32.2, GRANITE_D)
		_arched(x, 22, 2.6, 5.0, WIN)
		_r(x - 1, 10, x + 1, 13, WIN)
		for d in [-4.4, 0.0, 4.4]:
			_r(x + d - 0.5, 32.2, x + d + 0.5, 35, GRANITE)
			_poly([x + d - 0.6, 35, x + d + 0.6, 35, x + d, 37], GRANITE_D)

## A moliceiro boat on the canal: the long black hull with the high curled prow, its painted panel, the stern
## sweeping up behind.
static func _aveiro_moliceiro() -> void:
	_r(-11, 0, 11, 1.2, WATER)
	_poly([-11, 1.0, 11, 1.0, 11, 1.4, -11, 1.4], WATER_L)
	_poly([-7, 1.4, 6, 1.4, 8.5, 3.2, 10, 6.8, 9.2, 7.6, 8.3, 4.2, 6, 2.6, -7, 2.6, -9, 4.8, -9.8, 4.4], DARK)
	_poly([6.2, 2.6, 8.3, 4.2, 8.9, 6.0, 7.6, 4.2], Color("d94a3a"))
	_r(-6, 2.0, 5, 2.5, OCHRE)
	for k in 4:
		_r(-5.0 + k * 2.6, 2.0, -4.0 + k * 2.6, 2.5, Color("2f6fb0"))
	_c(9.6, 7.4, 0.5, OCHRE)
	_l(-2, 2.6, -2, 8.4, Color("6b5a3a"), 0.18)

## Arco da Vila: the Neoclassical gate with its arch, the niche with the saint, the bell tower and a stork's nest.
static func _faro_arco_vila() -> void:
	_r(-11, 0, 11, 0.5, LIME_D)
	_r(-8, 0.5, 8, 15, WHITE)
	_r(-8.4, 15, 8.4, 16, LIME_D)
	_arched(0, 0.5, 5.0, 8.5, DARK)
	for x in [-6.5, -4.0, 4.0, 6.5]:
		_r(x - 0.4, 0.5, x + 0.4, 15, LIME_D)
	_arched(0, 10, 2.0, 4.2, LIME_D)
	_r(-0.4, 10.4, 0.4, 13.2, STONE_D)
	_c(0, 13.5, 0.4, STONE_D)
	# the bell tower and the nest
	_r(-4, 16, 4, 21, WHITE)
	_arched(0, 16.5, 2.2, 3.8, WIN)
	_poly([-4.5, 21, 4.5, 21, 0, 22.6], LIME_D)
	_poly([-2.4, 22.3, 2.4, 22.3, 2.0, 23.6, -2.0, 23.6], Color("6b5a3a"))
	_r(-0.6, 23.6, 0.4, 24.8, WHITE)
	_c(-0.1, 25.1, 0.4, WHITE)
	_l(0.2, 25.1, 1.1, 24.9, Color("d94a3a"), 0.15)

## The Roman Temple of Évora: the granite podium and the row of fluted columns with their marble capitals still
## carrying a piece of the architrave.
static func _evora_templo() -> void:
	_r(-12, 0, 12, 0.4, Color("a89a7a"))
	_r(-11, 0.4, 11, 4, GRANITE)
	_r(-11.3, 3.6, 11.3, 4.2, GRANITE_D)
	var xs := [-9.6, -5.8, -1.9, 1.9, 5.8, 9.6]
	for x in xs:
		var top := 13.0 if absf(x) < 7.0 else 11.0
		_r(x - 0.7, 4.2, x + 0.7, top, GRANITE)
		_r(x - 0.2, 4.6, x + 0.2, top - 0.4, GRANITE_D)
		_r(x - 1.0, top, x + 1.0, top + 1.2, WHITE)
	_r(-6.8, 14.2, 6.8, 15.4, GRANITE)
	_r(-6.8, 15.4, 4.0, 15.9, GRANITE_D)

## Mateus Palace: the Baroque manor with its white walls and granite trim, the two wings forward, the tall
## central front with statues on its pediment, the pool before it.
static func _vila_real_mateus() -> void:
	_r(-38, 0, 38, 2.4, WATER)
	_r(-38, 2.4, 38, 3.0, GRANITE_D)
	for s in [-1, 1]:
		var x0: float = s * 34.0
		var x1: float = s * 14.0
		_r(minf(x0, x1), 3, maxf(x0, x1), 13, WHITE)
		_r(minf(x0, x1) - 0.4, 13, maxf(x0, x1) + 0.4, 14, GRANITE)
		_poly([minf(x0, x1) - 0.4, 14, maxf(x0, x1) + 0.4, 14, maxf(x0, x1) - 2, 16, minf(x0, x1) + 2, 16], TILE)
		for k in 4:
			var x: float = minf(x0, x1) + 2.5 + k * 4.8
			_r(x, 5, x + 1.6, 8, WIN)
			_r(x, 9.5, x + 1.6, 12, WIN)
		_r(x0 - 0.8, 13, x0 + 0.8, 18, GRANITE)
		_poly([x0 - 1, 18, x0 + 1, 18, x0, 20], GRANITE_D)
	_r(-14, 3, 14, 15, WHITE)
	_r(-14.4, 15, 14.4, 16, GRANITE)
	_poly([-9, 16, 9, 16, 9, 19, 4, 21, 0, 23, -4, 21, -9, 19], WHITE)
	_poly([-9.6, 19, -4, 21.4, 0, 23.6, 4, 21.4, 9.6, 19, 9.6, 19.8, 4, 22.2, 0, 24.3, -4, 22.2, -9.6, 19.8], GRANITE)
	for x in [-9.0, 0.0, 9.0]:
		_r(x - 0.4, 19.5 if x != 0.0 else 24.3, x + 0.4, (19.5 if x != 0.0 else 24.3) + 1.5, GRANITE_D)
	_r(-4, 3, 4, 6, GRANITE)
	_arched(0, 6, 3.0, 5.0, DARK)
	for x in [-10.0, -6.0, 6.0, 10.0]:
		_r(x - 0.8, 5, x + 0.8, 8, WIN)
		_r(x - 0.8, 10, x + 0.8, 13, WIN)
	_arched(0, 16.5, 2.0, 3.0, WIN)

## Bragança Castle: the citadel walls with round towers and the tall square keep with its corner turrets.
static func _braganca_castelo() -> void:
	_poly([-23, 0, 23, 0, 20, 3, -20, 3], GRASS)
	_r(-20, 3, 20, 12, GRANITE)
	_merlons(-20, 20, 12, 1.0, 1.4, GRANITE)
	for x in [-18.0, 18.0]:
		_r(x - 2.2, 3, x + 2.2, 15, GRANITE)
		_merlons(x - 2.2, x + 2.2, 15, 0.9, 1.2, GRANITE)
	_arched(-12, 3, 2.6, 5.0, DARK)
	# the keep
	_r(-5, 3, 7, 33, GRANITE_D)
	_merlons(-5, 7, 33, 1.0, 1.6, GRANITE_D)
	for x in [-5.0, 7.0]:
		_r(x - 1.0, 28, x + 1.0, 34.6, GRANITE)
		_poly([x - 1.0, 34.6, x + 1.0, 34.6, x, 36.5], GRANITE_D)
	_r(0.4, 22, 1.6, 25, DARK)
	_r(0.4, 14, 1.6, 17, DARK)
