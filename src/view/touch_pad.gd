class_name TouchPad
extends Control
## On-screen driving buttons for touch screens: steering under the left thumb, gas and brake under the right.
## Several fingers at once (steer and gas together); sliding a finger from one button to another works too.
const BUTTONS := {
	"left": Rect2(16, 400, 108, 124),
	"right": Rect2(134, 400, 108, 124),
	"brake": Rect2(718, 440, 104, 84),
	"accel": Rect2(834, 380, 110, 144),
}
var _fingers := {} ## touch index -> button name
var enabled := false ## shown and active (touch screens)

func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)

func pressed(name: String) -> bool:
	return _fingers.values().has(name)

func steer() -> float:
	return (1.0 if pressed("right") else 0.0) - (1.0 if pressed("left") else 0.0)

func release_all() -> void:
	_fingers.clear()

static func button_at(p: Vector2) -> String:
	for n in BUTTONS:
		if BUTTONS[n].grow(10).has_point(p):
			return n
	return ""

func _input(event: InputEvent) -> void:
	if not enabled:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			var b := button_at(event.position)
			if b != "": _fingers[event.index] = b
		else:
			_fingers.erase(event.index)
		queue_redraw()
	elif event is InputEventScreenDrag:
		var b := button_at(event.position)
		if b != "": _fingers[event.index] = b
		else: _fingers.erase(event.index)
		queue_redraw()

func _draw() -> void:
	if not enabled:
		return
	for n in BUTTONS:
		var r: Rect2 = BUTTONS[n]
		var on := pressed(n)
		var sb := StyleBoxFlat.new()
		sb.set_corner_radius_all(18)
		sb.bg_color = Color(1, 1, 1, 0.38) if on else Color(0.05, 0.07, 0.1, 0.35)
		sb.border_color = Color(1, 1, 1, 0.55)
		sb.set_border_width_all(3)
		draw_style_box(sb, r)
		var c := r.get_center()
		var col := Color(1, 1, 1, 0.9)
		match n:
			"left":
				draw_colored_polygon(PackedVector2Array([c + Vector2(-22, 0), c + Vector2(16, -26), c + Vector2(16, 26)]), col)
			"right":
				draw_colored_polygon(PackedVector2Array([c + Vector2(22, 0), c + Vector2(-16, -26), c + Vector2(-16, 26)]), col)
			"accel":
				draw_colored_polygon(PackedVector2Array([c + Vector2(0, -34), c + Vector2(26, 0), c + Vector2(-26, 0)]), Color("7fe0a0"))
				draw_string(ThemeDB.fallback_font, c + Vector2(-50, 36), "GAZ", HORIZONTAL_ALIGNMENT_CENTER, 100, 20, col)
			"brake":
				draw_rect(Rect2(c + Vector2(-20, -24), Vector2(40, 22)), Color("ff8a7a"))
				draw_string(ThemeDB.fallback_font, c + Vector2(-50, 26), "HAMULEC", HORIZONTAL_ALIGNMENT_CENTER, 100, 16, col)
