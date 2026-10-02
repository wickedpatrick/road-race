class_name DrawBatch
extends RefCounted
## Collects solid-colour shapes into one triangle array, so a whole frame is a single draw call instead of one per
## circle/polygon. Mirrors the CanvasItem draw_* methods the painters use, so they accept either. Painter order is kept:
## triangles are drawn in the order they were added. Text cannot be batched, so draw_string flushes first.
var _cv: CanvasItem
var _pts := PackedVector2Array()
var _cols := PackedColorArray()
var _idx := PackedInt32Array()
var _tmp_cols := PackedColorArray()
var _xf := Transform2D.IDENTITY
var _xf_on := false

func begin(cv: CanvasItem) -> void:
	_cv = cv
	_pts.clear()
	_cols.clear()
	_idx.clear()
	_xf = Transform2D.IDENTITY
	_xf_on = false

func flush() -> void:
	if _idx.is_empty():
		return
	RenderingServer.canvas_item_add_triangle_array(_cv.get_canvas_item(), _idx, _pts, _cols)
	_pts.clear()
	_cols.clear()
	_idx.clear()

## Convex polygon as a triangle fan.
func fan(p: PackedVector2Array, col: Color) -> void:
	var n := p.size()
	var base := _pts.size()
	_pts.append_array(_xf * p if _xf_on else p)
	_tmp_cols.resize(n)
	_tmp_cols.fill(col)
	_cols.append_array(_tmp_cols)
	for k in range(1, n - 1):
		_idx.append(base)
		_idx.append(base + k)
		_idx.append(base + k + 1)

func draw_set_transform(pos: Vector2, rot := 0.0, scl := Vector2.ONE) -> void:
	_xf = Transform2D(rot, scl, 0.0, pos)
	_xf_on = _xf != Transform2D.IDENTITY

func draw_rect(r: Rect2, col: Color, filled := true, width := -1.0) -> void:
	if not filled:
		var w := maxf(width, 1.0)
		var h := w * 0.5
		draw_rect(Rect2(r.position.x - h, r.position.y - h, r.size.x + w, w), col)
		draw_rect(Rect2(r.position.x - h, r.end.y - h, r.size.x + w, w), col)
		draw_rect(Rect2(r.position.x - h, r.position.y + h, w, r.size.y - w), col)
		draw_rect(Rect2(r.end.x - h, r.position.y + h, w, r.size.y - w), col)
		return
	var a := r.position
	var b := r.end
	fan(PackedVector2Array([a, Vector2(b.x, a.y), b, Vector2(a.x, b.y)]), col)

func draw_circle(c: Vector2, r: float, col: Color, _filled := true, _width := -1.0, _aa := false) -> void:
	# segment count follows the on-screen radius: distant trees get 8, the sun gets 32
	var sx := r * (_xf.get_scale().x if _xf_on else 1.0)
	var n := clampi(int(sx * 0.5) + 6, 8, 32)
	var p := PackedVector2Array()
	p.resize(n)
	var step := TAU / n
	for k in n:
		p[k] = c + Vector2(cos(k * step), sin(k * step)) * r
	fan(p, col)

func draw_primitive(p: PackedVector2Array, cols: PackedColorArray, _uvs: PackedVector2Array) -> void:
	fan(p, cols[0])

func draw_colored_polygon(p: PackedVector2Array, col: Color) -> void:
	if p.size() <= 4:
		fan(p, col)
		return
	# may be concave (horizon silhouettes): triangulate natively
	var tri := Geometry2D.triangulate_polygon(p)
	if tri.is_empty():
		return
	var base := _pts.size()
	_pts.append_array(_xf * p if _xf_on else p)
	_tmp_cols.resize(p.size())
	_tmp_cols.fill(col)
	_cols.append_array(_tmp_cols)
	for i in tri:
		_idx.append(base + i)

## Vertical-gradient polygon (sky): one colour per point, convex.
func draw_polygon(p: PackedVector2Array, cols: PackedColorArray) -> void:
	var base := _pts.size()
	_pts.append_array(_xf * p if _xf_on else p)
	_cols.append_array(cols)
	for k in range(1, p.size() - 1):
		_idx.append(base)
		_idx.append(base + k)
		_idx.append(base + k + 1)

func draw_line(a: Vector2, b: Vector2, col: Color, width := -1.0) -> void:
	var d := b - a
	if d == Vector2.ZERO:
		return
	var nrm := Vector2(-d.y, d.x).normalized() * (maxf(width, 1.0) * 0.5)
	fan(PackedVector2Array([a + nrm, b + nrm, b - nrm, a - nrm]), col)

func draw_string(font: Font, pos: Vector2, text: String, align := HORIZONTAL_ALIGNMENT_LEFT, width := -1.0, size := 16, col := Color.WHITE) -> void:
	flush()
	_cv.draw_string(font, pos, text, align, width, size, col)
