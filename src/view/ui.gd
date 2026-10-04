class_name Ui
extends RefCounted
## Big rounded buttons shared by the menus (sized for a finger).

static func button(cv: CanvasItem, font: Font, r: Rect2, text: String, main: bool, size := 24) -> void:
	var sb := StyleBoxFlat.new()
	sb.set_corner_radius_all(14)
	sb.bg_color = Color("2e9e4f") if main else Color(0.06, 0.09, 0.13, 0.8)
	sb.border_color = Color("ffd24a") if main else Color(1, 1, 1, 0.6)
	sb.set_border_width_all(3)
	cv.draw_style_box(sb, r)
	cv.draw_string(font, Vector2(r.position.x, r.get_center().y + size * 0.36), text, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, size, Color.WHITE)

## A left click or a tap (touches arrive as an emulated left click), at its position; null otherwise.
static func tap(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		return event.position
	return null
