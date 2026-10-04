extends Node2D
## Gameplay scene: reads input, steps the Race at a fixed rate, shows the world and HUD.
const COUNTDOWN := 3.0
const END_DELAY := 1.6
var race: Race
var view: WorldView
var hud: Hud
var overlay: Control
var pad: TouchPad
const RESUME_BTN := Rect2(290, 300, 180, 64)
const MAP_BTN := Rect2(490, 300, 180, 64)
var countdown := COUNTDOWN
var paused := false
var end_timer := 0.0
var font: Font
var _last_count := 99
var _was_refueling := false
var _low_fuel_timer := 0.0
var _end_sound_played := false
var _radar_timer := 0.0

func _ready() -> void:
	font = ThemeDB.fallback_font
	race = Race.new(Session.car_id, Session.stage(), randi())
	view = WorldView.new()
	add_child(view)
	view.bind(race, Session.season)
	race.collided.connect(func(_i): Sfx.play("hit", -2.0))
	race.fined.connect(func(): Sfx.play("lowfuel", -4.0))
	var layer := CanvasLayer.new()
	add_child(layer)
	hud = Hud.new()
	hud.touch = Screen.touch
	layer.add_child(hud)
	hud.bind(race)
	overlay = Control.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.draw.connect(_draw_overlay)
	pad = TouchPad.new()
	pad.enabled = Screen.touch
	layer.add_child(pad)
	layer.add_child(overlay)

func _read_input() -> Dictionary:
	var brake := Input.is_action_pressed("brake") or pad.pressed("brake")
	return {
		"accel": (Input.is_action_pressed("accel") or pad.pressed("accel")) and not brake,
		"brake": brake,
		"steer": clampf(Input.get_axis("left", "right") + pad.steer(), -1.0, 1.0),
	}

func _physics_process(dt: float) -> void:
	overlay.queue_redraw()
	if paused:
		Sfx.silence_all_loops()
		return
	if countdown > 0.0:
		countdown -= dt
		var n := int(ceil(countdown))
		if n != _last_count:
			_last_count = n
			if n > 0: Sfx.play("beep", -6.0)
			else: Sfx.play("go", -5.0)
		Sfx.set_loop("engine", -22.0, EngineAudio.IDLE)
		return
	if race.state == "running":
		var inp := _read_input()
		race.step(dt, inp)
		_update_audio(dt, inp)
	else:
		_end_audio()
		race.coast_after_finish(dt)
		end_timer += dt
		if end_timer >= END_DELAY:
			_finish()

func _update_audio(dt: float, inp: Dictionary) -> void:
	var has_fuel := not race.fuel.is_empty()
	var throttle: bool = inp.accel and has_fuel
	if has_fuel or race.speed > 1.0:
		var db := -17.0 + (5.0 if throttle else 0.0) + 4.0 * race.speed_ratio()
		Sfx.set_loop("engine", db, EngineAudio.pitch(race.speed, race.stats.max_speed, throttle, race.gear))
	else:
		Sfx.set_loop("engine", Sfx.SILENT)
	if absf(race.x) > 1.0 and race.speed > 4.0:
		Sfx.set_loop("gravel", -22.0 + 12.0 * race.speed_ratio(), 0.8 + 0.5 * race.speed_ratio())
	else:
		Sfx.set_loop("gravel", Sfx.SILENT)
	if race.refueling:
		Sfx.set_loop("pump", -10.0)
	else:
		Sfx.set_loop("pump", Sfx.SILENT)
		if _was_refueling and race.fuel.ratio() >= 0.99:
			Sfx.play("refuel_done", -6.0)
	_was_refueling = race.refueling
	# radar detector beeps while speeding; the siren wails while the police chase and stop the car
	_radar_timer -= dt
	if race.speeding > 0.0 and _radar_timer <= 0.0:
		Sfx.play("radar", -8.0)
		_radar_timer = 0.5
	var phase: String = race.police.get("phase", "")
	Sfx.set_loop("siren", -12.0 if phase in ["chase", "pull_over"] else Sfx.SILENT)
	_low_fuel_timer -= dt
	if race.fuel.ratio() < 0.15 and _low_fuel_timer <= 0.0:
		Sfx.play("lowfuel", -8.0)
		_low_fuel_timer = 2.5

func _end_audio() -> void:
	Sfx.set_loop("siren", Sfx.SILENT)
	Sfx.set_loop("gravel", Sfx.SILENT)
	Sfx.set_loop("pump", Sfx.SILENT)
	Sfx.set_loop("engine", -24.0 + 10.0 * race.speed_ratio(), EngineAudio.pitch(race.speed, race.stats.max_speed, false, race.gear))
	if not _end_sound_played:
		_end_sound_played = true
		Sfx.play("win" if race.state == "won" else "lose", 0.0 if race.state == "won" else -3.0) # fanfare on arrival

func _finish() -> void:
	Sfx.silence_all_loops()
	Session.last_result = {
		"state": race.state, "time_left": race.time_left, "elapsed": race.elapsed,
		"duration": race.stage.duration, "fuel": race.fuel.ratio(), "name": race.stage.name, "km": race.stage.km,
		"fines": race.fines,
		"km_driven": Route.km_between(race.stage, 0.0, minf(race.z, race.stage.length)),
	}
	Session.last_result.unlocked = Session.add_km(Session.last_result.km_driven)
	var reached := Route.cities_reached(race.stage, race.z + (1.0 if race.state == "won" else 0.0))
	Session.last_result.new_cities = Session.visit(reached)
	get_tree().change_scene_to_file("res://src/scenes/results.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not event.is_echo():
		_set_paused(not paused)
	elif paused and event is InputEventKey and event.pressed and event.keycode == KEY_M:
		_back_to_map()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var p: Vector2 = event.position
		if paused:
			if RESUME_BTN.has_point(p): _set_paused(false)
			elif MAP_BTN.has_point(p): _back_to_map()
		elif Hud.PAUSE_BTN.grow(8).has_point(p) and race.state == "running":
			_set_paused(true)

func _set_paused(on: bool) -> void:
	paused = on
	pad.release_all()
	if paused: Sfx.silence_all_loops()

## Leaves the race without a result: back to the map, still in the start city.
func _back_to_map() -> void:
	Sfx.silence_all_loops()
	Session.menu_at_map = true
	get_tree().change_scene_to_file("res://src/scenes/menu.tscn")

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		for a in ["accel", "brake", "left", "right"]:
			Input.action_release(a)
		if pad != null: pad.release_all()
		if race != null and race.state == "running" and countdown <= 0.0:
			paused = true

func _draw_overlay() -> void:
	var o := overlay
	if countdown > 0.0:
		var n := int(ceil(countdown))
		o.draw_string(font, Vector2(0, 300), str(n), HORIZONTAL_ALIGNMENT_CENTER, 960, 140, Color(0, 0, 0, 0.5))
		o.draw_string(font, Vector2(0, 296), str(n), HORIZONTAL_ALIGNMENT_CENTER, 960, 140, Color("ffd24a"))
		o.draw_string(font, Vector2(0, 340), "%s  ·  %d km" % [race.stage.name, race.stage.km], HORIZONTAL_ALIGNMENT_CENTER, 960, 24, Color.WHITE)
	elif race.elapsed < 0.9 and race.state == "running":
		o.draw_string(font, Vector2(0, 300), "START!", HORIZONTAL_ALIGNMENT_CENTER, 960, 110, Color(0, 0, 0, 0.5))
		o.draw_string(font, Vector2(0, 296), "START!", HORIZONTAL_ALIGNMENT_CENTER, 960, 110, Color("49d36b"))
	elif race.state != "running":
		var msg := {"won": "META!", "out_of_time": "KONIEC CZASU", "out_of_fuel": "KONIEC PALIWA"}[race.state] as String
		var col := Color("49d36b") if race.state == "won" else Color("ff6a5a")
		o.draw_rect(Rect2(0, 190, 960, 110), Color(0, 0, 0, 0.45))
		o.draw_string(font, Vector2(0, 268), msg, HORIZONTAL_ALIGNMENT_CENTER, 960, 80, col)
	if paused:
		o.draw_rect(Rect2(0, 0, 960, 540), Color(0, 0, 0, 0.6))
		o.draw_string(font, Vector2(0, 250), "PAUZA", HORIZONTAL_ALIGNMENT_CENTER, 960, 72, Color.WHITE)
		Ui.button(o, font, RESUME_BTN, "Graj dalej", true)
		Ui.button(o, font, MAP_BTN, "Wróć do mapy", false)
		if not Screen.touch:
			o.draw_string(font, Vector2(0, 410), "Esc: wznów     M: mapa     X: dźwięk wł./wył.", HORIZONTAL_ALIGNMENT_CENTER, 960, 22, Color("c8d6e3"))
