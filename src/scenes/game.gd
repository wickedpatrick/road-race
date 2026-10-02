extends Node2D
## Gameplay scene: reads input, steps the Race at a fixed rate, shows the world and HUD.
const COUNTDOWN := 3.0
const END_DELAY := 1.6
var race: Race
var view: WorldView
var hud: Hud
var overlay: Control
var countdown := COUNTDOWN
var paused := false
var end_timer := 0.0
var font: Font

func _ready() -> void:
	font = ThemeDB.fallback_font
	race = Race.new(Session.car_id, Session.stage, randi())
	view = WorldView.new()
	add_child(view)
	view.bind(race, Session.season)
	var layer := CanvasLayer.new()
	add_child(layer)
	hud = Hud.new()
	layer.add_child(hud)
	hud.bind(race)
	overlay = Control.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.draw.connect(_draw_overlay)
	layer.add_child(overlay)

func _read_input() -> Dictionary:
	var brake := Input.is_action_pressed("brake")
	return {
		"accel": Input.is_action_pressed("accel") and not brake,
		"brake": brake,
		"steer": Input.get_axis("left", "right"),
	}

func _physics_process(dt: float) -> void:
	overlay.queue_redraw()
	if paused:
		return
	if countdown > 0.0:
		countdown -= dt
		return
	if race.state == "running":
		race.step(dt, _read_input())
	else:
		race.coast_after_finish(dt)
		end_timer += dt
		if end_timer >= END_DELAY:
			_finish()

func _finish() -> void:
	Session.last_result = {
		"state": race.state, "time_left": race.time_left, "elapsed": race.elapsed,
		"duration": race.stage.duration, "fuel": race.fuel.ratio(),
	}
	get_tree().change_scene_to_file("res://src/scenes/results.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not event.is_echo():
		paused = not paused
	elif paused and event is InputEventKey and event.pressed and event.keycode == KEY_M:
		get_tree().change_scene_to_file("res://src/scenes/menu.tscn")

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		for a in ["accel", "brake", "left", "right"]:
			Input.action_release(a)
		if race != null and race.state == "running" and countdown <= 0.0:
			paused = true

func _draw_overlay() -> void:
	var o := overlay
	if countdown > 0.0:
		var n := int(ceil(countdown))
		o.draw_string(font, Vector2(0, 300), str(n), HORIZONTAL_ALIGNMENT_CENTER, 960, 140, Color(0, 0, 0, 0.5))
		o.draw_string(font, Vector2(0, 296), str(n), HORIZONTAL_ALIGNMENT_CENTER, 960, 140, Color("ffd24a"))
		o.draw_string(font, Vector2(0, 340), "%s - meta: %s" % [race.stage.name, race.stage.finish_label], HORIZONTAL_ALIGNMENT_CENTER, 960, 24, Color.WHITE)
	elif race.state != "running":
		var msg := {"won": "META!", "out_of_time": "KONIEC CZASU", "out_of_fuel": "KONIEC PALIWA"}[race.state] as String
		var col := Color("49d36b") if race.state == "won" else Color("ff6a5a")
		o.draw_rect(Rect2(0, 190, 960, 110), Color(0, 0, 0, 0.45))
		o.draw_string(font, Vector2(0, 268), msg, HORIZONTAL_ALIGNMENT_CENTER, 960, 80, col)
	if paused:
		o.draw_rect(Rect2(0, 0, 960, 540), Color(0, 0, 0, 0.6))
		o.draw_string(font, Vector2(0, 250), "PAUZA", HORIZONTAL_ALIGNMENT_CENTER, 960, 72, Color.WHITE)
		o.draw_string(font, Vector2(0, 310), "Esc: wznów     M: wróć do menu", HORIZONTAL_ALIGNMENT_CENTER, 960, 26, Color("c8d6e3"))
