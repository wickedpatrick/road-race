class_name WorldThumb
extends RefCounted
## A tiny picture of Europe from the country picker's map (data/world.json) for the "change country" button: the sea, the
## planned countries grey, the ones in the game green, the one played now in gold.
static var _shapes := {} ## rect -> {code: [PackedVector2Array, ...]}, scaled once per button size

static func draw(cv: CanvasItem, r: Rect2, current: String, playable: Array) -> void:
	var key := str(r)
	if not _shapes.has(key):
		_shapes[key] = _scaled(r)
	cv.draw_rect(r, Color("2c5d86"))
	var shapes: Dictionary = _shapes[key]
	for code in shapes:
		var col := Color("ffd24a") if code == current else (Color("8fd16a") if playable.has(code) else Color("b4b9bd"))
		for pts in shapes[code]:
			cv.draw_colored_polygon(pts, col)

## The map's countries scaled into r; shapes too small to draw (or to triangulate) are left out.
static func _scaled(r: Rect2) -> Dictionary:
	var w: Dictionary = GameData.load_json(GameData.DIR + "world.json")
	var v: Array = w.views[0].rect # Europe (the first view) on the picker's 960x540 screen
	var src := Rect2(v[0], v[1], v[2], v[3])
	var s := maxf(r.size.x / src.size.x, r.size.y / src.size.y) # fills the button's picture, cut at its edges
	var off := r.position + (r.size - src.size * s) * 0.5 - src.position * s
	var out := {}
	for code in w.countries:
		var list := []
		for f in w.countries[code].polys:
			var pts := PackedVector2Array()
			for i in range(0, f.size(), 2):
				var p := Vector2(f[i], f[i + 1]) * s + off
				if pts.is_empty() or p.distance_to(pts[pts.size() - 1]) > 0.6: pts.append(p)
			if pts.size() < 3: continue
			var cut := Geometry2D.intersect_polygons(pts, PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]))
			for c in cut:
				if c.size() >= 3 and not Geometry2D.triangulate_polygon(c).is_empty():
					list.append(c)
		out[code] = list
	return out
