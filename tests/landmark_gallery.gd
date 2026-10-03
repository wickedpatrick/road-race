extends Node2D
## Dev-only: every landmark painter on one screen. Arg: page (0, 1).
func _draw() -> void:
	draw_rect(Rect2(0, 0, 960, 540), Color("9fc6e6"))
	var kinds: Array = Landmarks.SIZE.keys()
	var a := OS.get_cmdline_user_args()
	var page := int(a[0]) if a.size() > 0 else 0
	kinds = kinds.slice(page * 24, page * 24 + 24)
	var font := ThemeDB.fallback_font
	for i in kinds.size():
		var k: String = kinds[i]
		var sz: Array = Landmarks.SIZE[k]
		var cell := Vector2(160, 135)
		var o := Vector2((i % 6) * cell.x, (i / 6) * cell.y)
		draw_rect(Rect2(o + Vector2(0, 100), Vector2(cell.x, 35)), Color("7fae5a"))
		var pm := minf(85.0 / sz[1], 140.0 / sz[0])
		LandmarkPainter.draw(self, {"kind": k, "w": float(sz[0]), "h": float(sz[1]), "v": 0.3}, o + Vector2(cell.x * 0.5, 104), pm)
		draw_string(font, o + Vector2(4, 128), k, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.BLACK)
