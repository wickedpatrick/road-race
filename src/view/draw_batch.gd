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
var _user_xf := Transform2D.IDENTITY ## set by draw_set_transform
## left-hand traffic: the whole world is drawn mirrored (x -> mirror_w - x); painters of signs, cars and landmarks
## turn it off and draw at a mirrored point, so their lettering and shapes stay the right way round
var mirror := false
var mirror_w := 960.0
## distance haze: every colour added is blended this far (0..1) towards fog_color (set per depth by WorldView)
var fog := 0.0
var fog_color := Color.WHITE
## every colour added is blended this far (0..1) towards its grey (postcards not collected yet)
var gray := 0.0
## a convex polygon (any winding): when set, flush() keeps only the parts of the triangles inside it (a postcard's
## frame, half a card along its diagonal); empty: no clipping
var clip := PackedVector2Array()
## tests: every flush also appends the (clipped) triangle points it sends to `sent`
var keep_sent := false
var sent := PackedVector2Array()

func begin(cv: CanvasItem) -> void:
	_cv = cv
	_pts.clear()
	_cols.clear()
	_idx.clear()
	_user_xf = Transform2D.IDENTITY
	_update_xf()
	fog = 0.0
	gray = 0.0

func flush() -> void:
	if _idx.is_empty():
		return
	if not clip.is_empty():
		_clip_all()
	if keep_sent:
		for i in _idx: sent.append(_pts[i])
	if _idx.is_empty():
		return
	RenderingServer.canvas_item_add_triangle_array(_cv.get_canvas_item(), _idx, _pts, _cols)
	_pts.clear()
	_cols.clear()
	_idx.clear()

## The colour as drawn: hazed by the fog, greyed.
func _tone(col: Color) -> Color:
	if fog > 0.0:
		col = col.lerp(fog_color, fog)
	if gray > 0.0:
		var l := col.r * 0.3 + col.g * 0.59 + col.b * 0.11
		col = col.lerp(Color(l, l, l, col.a), gray)
	return col

## Cuts every triangle to the clip polygon (Sutherland-Hodgman; colours interpolated along cut edges).
func _clip_all() -> void:
	var pts := PackedVector2Array()
	var cols := PackedColorArray()
	var idx := PackedInt32Array()
	var n := clip.size()
	var area := 0.0
	for k in n:
		area += clip[k].cross(clip[(k + 1) % n])
	var turn := 1.0 if area > 0.0 else -1.0 # inside is left of every edge for this winding
	for i in range(0, _idx.size(), 3):
		var poly := [_pts[_idx[i]], _pts[_idx[i + 1]], _pts[_idx[i + 2]]]
		var pc := [_cols[_idx[i]], _cols[_idx[i + 1]], _cols[_idx[i + 2]]]
		for k in n:
			if poly.is_empty():
				break
			var a := clip[k]
			var e := clip[(k + 1) % n] - a
			var out := []
			var oc := []
			for j in poly.size():
				var p: Vector2 = poly[j]
				var q: Vector2 = poly[(j + 1) % poly.size()]
				var dp := e.cross(p - a) * turn
				var dq := e.cross(q - a) * turn
				if dp >= 0.0:
					out.append(p)
					oc.append(pc[j])
				if (dp >= 0.0) != (dq >= 0.0):
					var f := dp / (dp - dq)
					out.append(p.lerp(q, f))
					oc.append((pc[j] as Color).lerp(pc[(j + 1) % poly.size()], f))
			poly = out
			pc = oc
		if poly.size() < 3:
			continue
		var base := pts.size()
		for j in poly.size():
			pts.append(poly[j])
			cols.append(pc[j])
		for j in range(1, poly.size() - 1):
			idx.append_array([base, base + j, base + j + 1])
	_pts = pts
	_cols = cols
	_idx = idx

## Convex polygon as a triangle fan.
func fan(p: PackedVector2Array, col: Color) -> void:
	var n := p.size()
	var base := _pts.size()
	_pts.append_array(_xf * p if _xf_on else p)
	_tmp_cols.resize(n)
	_tmp_cols.fill(col if fog <= 0.0 and gray <= 0.0 else _tone(col))
	_cols.append_array(_tmp_cols)
	for k in range(1, n - 1):
		_idx.append(base)
		_idx.append(base + k)
		_idx.append(base + k + 1)

func draw_set_transform(pos: Vector2, rot := 0.0, scl := Vector2.ONE) -> void:
	_user_xf = Transform2D(rot, scl, 0.0, pos)
	_update_xf()

func set_mirror(on: bool) -> void:
	mirror = on
	_update_xf()

func _update_xf() -> void:
	_xf = Transform2D(Vector2(-1, 0), Vector2(0, 1), Vector2(mirror_w, 0)) * _user_xf if mirror else _user_xf
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
	var sx := r * (absf(_xf.get_scale().x) if _xf_on else 1.0)
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
	_tmp_cols.fill(col if fog <= 0.0 and gray <= 0.0 else _tone(col)) # the race draws thousands: no call when plain
	_cols.append_array(_tmp_cols)
	for i in tri:
		_idx.append(base + i)

## Vertical-gradient polygon (sky): one colour per point, convex.
func draw_polygon(p: PackedVector2Array, cols: PackedColorArray) -> void:
	var base := _pts.size()
	_pts.append_array(_xf * p if _xf_on else p)
	if gray > 0.0:
		for c in cols: _cols.append(_tone(c))
	else:
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

func draw_arc(c: Vector2, r: float, a0: float, a1: float, n: int, col: Color, width := -1.0, _aa := false) -> void:
	var prev := c + Vector2(cos(a0), sin(a0)) * r
	for k in range(1, n + 1):
		var a := lerpf(a0, a1, float(k) / n)
		var p := c + Vector2(cos(a), sin(a)) * r
		draw_line(prev, p, col, width)
		prev = p

func draw_string(font: Font, pos: Vector2, text: String, align := HORIZONTAL_ALIGNMENT_LEFT, width := -1.0, size := 16, col := Color.WHITE) -> void:
	flush()
	if mirror: # the text's box moves to the mirrored place, the letters stay readable
		var w := width if width > 0.0 else font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
		pos = Vector2(mirror_w - pos.x - w, pos.y)
	_cv.draw_string(font, pos, text, align, width, size, col)
