extends Node2D
## Dev-only: 12 postcards of a country (RR_COUNTRY) on one screen, every other one grey and unnamed. Arg: page (0..2).
var batch := DrawBatch.new()

func _draw() -> void:
	draw_rect(Rect2(0, 0, 960, 540), Color("2c3e50"))
	var code := OS.get_environment("RR_COUNTRY") if OS.get_environment("RR_COUNTRY") != "" else "pl"
	if OS.get_environment("RR_LANG") != "": GameData.set_language(OS.get_environment("RR_LANG"))
	var a := OS.get_cmdline_user_args()
	var page := int(a[0]) if a.size() > 0 else 0
	var ids := Postcards.cities(code).slice(page * 12, page * 12 + 12)
	batch.begin(self)
	for i in ids.size():
		var r := Rect2(12 + (i % 4) * 237, 10 + (i / 4) * 178, 225, 150)
		var grey := i % 4 == 3
		PostcardPainter.card(self, batch, r, code, ids[i], 1.0 if grey else 0.0, not grey)
		if not grey:
			PostcardPainter.stamp_row(self, Vector2(r.get_center().x, r.end.y + 12), 14.0, (i % 5) + 1, 5.0)
		if i == 0:
			PostcardPainter.postmark(self, r.position + Vector2(r.size.x - 34, 34), 26.0, PostcardPainter.caption(code, ids[i])[0], 2026, 1.0)
	batch.flush()
