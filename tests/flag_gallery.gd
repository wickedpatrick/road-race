extends Node2D
## Dev-only: every flag of data/world.json on one screen, big and small.
func _draw() -> void:
	draw_rect(Rect2(0, 0, 960, 540), Color("9fc6e6"))
	var codes: Array = GameData.load_json(GameData.DIR + "world.json").countries.keys()
	codes.sort()
	var font := ThemeDB.fallback_font
	for i in codes.size():
		var o := Vector2((i % 8) * 120 + 10, (i / 8) * 88 + 10)
		FlagPainter.draw(self, codes[i], Rect2(o, Vector2(72, 48)))
		FlagPainter.draw(self, codes[i], Rect2(o + Vector2(78, 0), Vector2(24, 16)))
		draw_string(font, o + Vector2(0, 66), codes[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.BLACK)
