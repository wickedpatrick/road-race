extends Node2D
func _draw() -> void:
	draw_rect(Rect2(0, 0, 960, 540), Color("8fb8d8"))
	draw_rect(Rect2(0, 300, 960, 240), Color("666a6f"))
	var ids := CarStats.ALL_IDS
	for i in ids.size():
		CarPainter.draw(self, ids[i], Vector2(170 + i * 310, 280), 1.0, 0.0, i == 1)
	var kinds := ["car", "van", "truck"]
	for i in kinds.size():
		CarPainter.draw_traffic(self, kinds[i], Vector2(170 + i * 310, 520), 0.8, CarPainter.TRAFFIC_COLORS[i])
