extends Node2D
## Dev-only: every player car (two rows, the last one braking) and the traffic kinds below.
func _draw() -> void:
	draw_rect(Rect2(0, 0, 960, 540), Color("8fb8d8"))
	draw_rect(Rect2(0, 300, 960, 240), Color("666a6f"))
	var ids := CarStats.ids()
	for i in ids.size():
		var row := i / 4
		CarPainter.draw(self, ids[i], Vector2(130 + (i % 4) * 233 + row * 116, 150 + row * 175), 0.85, 0.0, i == ids.size() - 1)
	var kinds := ["car", "van", "truck"]
	for i in kinds.size():
		CarPainter.draw_traffic(self, kinds[i], Vector2(170 + i * 310, 525), 0.6, CarPainter.TRAFFIC_COLORS[i])
