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
const QUALITY_BTN := Rect2(330, 384, 300, 48)
const SLOW_FRAME := 1.0 / 45.0 ## average frame time that switches the graphics to the light mode
var _world_vp: SubViewport ## light mode: the world is drawn at 960x540 and scaled up, the HUD stays sharp
var _world_sprite: Sprite2D
var _perf_t := 0.0
var _perf_n := 0
var _toast := 0.0
var countdown := COUNTDOWN
var paused := false
var end_timer := 0.0
var font: Font
var _last_count := 99
var _was_refueling := false
var _low_fuel_timer := 0.0
var _end_sound_played := false
var _radar_timer := 0.0
var _ferry_screen: Control ## the crossing (Race.ferry_left > 0), drawn over the world and under the HUD
var _ferry := {} ## the ferry the car is on (Race.ferry_started)
var _sea_t := 0.0 ## seconds of waves on the ferry screen

func _ready() -> void:
	font = ThemeDB.fallback_font
	race = Race.new(Session.car_id, Session.stage(), randi())
	Sfx.set_engine(Session.car_id)
	view = WorldView.new()
	add_child(view)
	view.bind(race)
	_apply_quality()
	race.collided.connect(func(_i): Sfx.play("hit", -2.0))
	race.crashed.connect(func(): Sfx.play("hit", 0.0))
	race.fined.connect(func(): Sfx.play("lowfuel", -10.0))
	race.police_crashed.connect(func(): Sfx.play("hit", -4.0))
	race.ferry_started.connect(func(f): _ferry = f)
	var layer := CanvasLayer.new()
	add_child(layer)
	_ferry_screen = Control.new()
	_ferry_screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	_ferry_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ferry_screen.draw.connect(_draw_ferry)
	layer.add_child(_ferry_screen)
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

## Moves the world view into a 960x540 offscreen viewport (light mode) or back onto the full-resolution screen.
func _apply_quality() -> void:
	var low := Session.quality == "low"
	view.smoke_on = not low
	view.detail_on = not low
	if low and _world_vp == null:
		_world_vp = SubViewport.new()
		_world_vp.size = Vector2i(960, 540)
		_world_vp.disable_3d = true
		_world_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		add_child(_world_vp)
		_world_sprite = Sprite2D.new()
		_world_sprite.centered = false
		_world_sprite.texture = _world_vp.get_texture()
		add_child(_world_sprite)
		move_child(_world_sprite, 0)
	if low and view.get_parent() != _world_vp:
		view.reparent(_world_vp, false)
	elif not low and view.get_parent() != self:
		view.reparent(self, false)
		move_child(view, 0)
	if _world_sprite != null:
		_world_sprite.visible = low

func _set_quality(q: String) -> void:
	Session.quality = q
	Session.save_profile()
	_apply_quality()

## Watches the first seconds of driving: a device that cannot keep up gets the light graphics mode.
func _process(dt: float) -> void:
	_toast = maxf(0.0, _toast - dt)
	if paused or countdown > 0.0 or race.state != "running" or Session.quality == "low" or _perf_n < 0:
		return
	_perf_t += dt
	_perf_n += 1
	if _perf_t >= 5.0:
		if _perf_t / _perf_n > SLOW_FRAME:
			_set_quality("low")
			_toast = 5.0
		_perf_n = -1 # checked once per race

func _read_input() -> Dictionary:
	var brake := Input.is_action_pressed("brake") or pad.pressed("brake")
	return {
		"accel": (Input.is_action_pressed("accel") or pad.pressed("accel")) and not brake,
		"brake": brake,
		"steer": clampf(Input.get_axis("left", "right") + pad.steer(), -1.0, 1.0),
	}

## Per frame: the overlay and the ferry screen redrawn, its waves rolling on.
func _tick_screens(dt: float) -> void:
	overlay.queue_redraw()
	_ferry_screen.queue_redraw()
	_sea_t += dt

func _physics_process(dt: float) -> void:
	_tick_screens(dt)
	if paused:
		Sfx.silence_all_loops()
		return
	if countdown > 0.0:
		countdown -= dt
		var n := int(ceil(countdown))
		if n != _last_count:
			_last_count = n
			if n > 0: Sfx.play("beep", -18.0)
			else: Sfx.play("go", -17.0)
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
	var throttle: bool = inp.accel and has_fuel and race.ferry_left <= 0.0 # on board the engine just idles
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
			Sfx.play("refuel_done", -12.0)
	_was_refueling = race.refueling
	# radar detector beeps while speeding; the siren wails while the police chase and stop the car
	_radar_timer -= dt
	if race.speeding > 0.0 and _radar_timer <= 0.0:
		Sfx.play("radar", -29.0) # kept quiet: a single beep every 0.5 s (each -6 dB halves the amplitude)
		_radar_timer = 0.5
	var phase: String = race.police.get("phase", "")
	Sfx.set_loop("siren", -14.0 if phase in ["chase", "pull_over"] else Sfx.SILENT)
	_low_fuel_timer -= dt
	if race.fuel.ratio() < 0.15 and _low_fuel_timer <= 0.0:
		Sfx.play("lowfuel", -14.0)
		_low_fuel_timer = 2.5

func _end_audio() -> void:
	Sfx.set_loop("siren", Sfx.SILENT)
	Sfx.set_loop("gravel", Sfx.SILENT)
	Sfx.set_loop("pump", Sfx.SILENT)
	Sfx.set_loop("engine", -24.0 + 10.0 * race.speed_ratio(), EngineAudio.pitch(race.speed, race.stats.max_speed, false, race.gear))
	if not _end_sound_played:
		_end_sound_played = true
		Sfx.play(Sfx.arrival(Session.to_city) if race.state == "won" else "lose", 0.0 if race.state == "won" else -3.0) # the anthem on arrival

func _finish() -> void:
	Sfx.silence_all_loops()
	Session.last_result = {
		"state": race.state, "time_left": race.time_left, "elapsed": race.elapsed,
		"duration": race.stage.duration, "fuel": race.fuel.ratio(), "name": race.stage.name, "km": race.stage.km,
		"fines": race.fines, "weather": race.weather,
		"km_driven": Route.km_between(race.stage, 0.0, minf(race.z, race.stage.length)),
	}
	Session.last_result.unlocked = Session.add_km(Session.last_result.km_driven)
	var reached := Route.cities_reached(race.stage, race.z + (1.0 if race.state == "won" else 0.0))
	var dest := Session.to_city
	var before: int = Session.postcards.get(dest, {}).get("stamps", 0) # before this trip's visit gives it
	Session.collect_towns(Route.towns_reached(race.stage, race.z))
	Session.last_result.new_cities = Session.visit(reached)
	if race.state == "won":
		var n := Postcards.stamps_for(race.time_left, race.stage.duration, Session.car_id)
		Session.stamp(dest, n)
		Session.last_result.postcard = {"city": dest, "before": before, "after": int(Session.postcards[dest].stamps),
			"faster_car": Postcards.car_for_stamps(n + 1) if n < Postcards.stamps_for(race.time_left, race.stage.duration) else ""}
			# fast enough for more stamps, the car was not: the slowest car that would have got the next one
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
			elif QUALITY_BTN.has_point(p): _set_quality("high" if Session.quality == "low" else "low")
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
		o.draw_string(font, Vector2(0, 340), "%s  ·  %s" % [race.stage.name, Units.dist_text(race.stage.km)], HORIZONTAL_ALIGNMENT_CENTER, 960, 24, Color.WHITE)
	elif race.elapsed < 0.9 and race.state == "running" and race.ferry_left <= 0.0:
		o.draw_string(font, Vector2(0, 300), Lang.t("start"), HORIZONTAL_ALIGNMENT_CENTER, 960, 110, Color(0, 0, 0, 0.5))
		o.draw_string(font, Vector2(0, 296), Lang.t("start"), HORIZONTAL_ALIGNMENT_CENTER, 960, 110, Color("49d36b"))
	elif race.state != "running":
		var msg := Lang.t({"won": "finish", "out_of_time": "out_of_time", "out_of_fuel": "out_of_fuel"}[race.state])
		var col := Color("49d36b") if race.state == "won" else Color("ff6a5a")
		o.draw_rect(Rect2(0, 190, 960, 110), Color(0, 0, 0, 0.45))
		o.draw_string(font, Vector2(0, 268), msg, HORIZONTAL_ALIGNMENT_CENTER, 960, 80, col)
	if paused:
		o.draw_rect(Rect2(0, 0, 960, 540), Color(0, 0, 0, 0.6))
		o.draw_string(font, Vector2(0, 250), Lang.t("pause"), HORIZONTAL_ALIGNMENT_CENTER, 960, 72, Color.WHITE)
		Ui.button(o, font, RESUME_BTN, Lang.t("resume"), true)
		Ui.button(o, font, MAP_BTN, Lang.t("to_map"), false)
		Ui.button(o, font, QUALITY_BTN, Lang.t("graphics") % Lang.t("gfx_low" if Session.quality == "low" else "gfx_high"), false, 18)
		if not Screen.touch:
			o.draw_string(font, Vector2(0, 470), Lang.t("pause_keys"), HORIZONTAL_ALIGNMENT_CENTER, 960, 22, Color("c8d6e3"))
	elif _toast > 0.0:
		o.draw_rect(Rect2(230, 214, 500, 40), Color(0, 0, 0, 0.55))
		o.draw_string(font, Vector2(0, 241), Lang.t("low_gfx_toast"), HORIZONTAL_ALIGNMENT_CENTER, 960, 18, Color.WHITE)

const FERRY_SKY := [Color("4f9fdc"), Color("cde8f6")]
const FERRY_SEA := Color("2f6f9e")
const HORIZON_Y := 300.0

## The crossing: the ferry sails over the waves from left to right in Race.FERRY_TIME, the player's car on its open
## deck, the coast left behind sinking and the one ahead rising; the ferry's name (and its fact) above. The HUD stays
## over it, its clock standing still.
func _draw_ferry() -> void:
	if race.ferry_left <= 0.0:
		return
	var o := _ferry_screen
	var t := clampf(1.0 - race.ferry_left / Race.FERRY_TIME, 0.0, 1.0)
	o.draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(960, 0), Vector2(960, HORIZON_Y), Vector2(0, HORIZON_Y)]),
		PackedColorArray([FERRY_SKY[0], FERRY_SKY[0], FERRY_SKY[1], FERRY_SKY[1]]))
	o.draw_circle(Vector2(760, 190), 34.0, Color(1, 0.96, 0.8, 0.5))
	o.draw_circle(Vector2(760, 190), 22.0, Color("fff3c4"))
	# the coasts: the one left behind sinks away on the left, the one ahead rises on the right
	for side in [[0.0, 1.0 - t], [1.0, t]]:
		var k: float = 0.25 + 0.75 * side[1]
		var x0: float = -20.0 if side[0] == 0.0 else 980.0
		var x1: float = x0 + (320.0 if side[0] == 0.0 else -320.0) * k
		var pts := PackedVector2Array([Vector2(x0, HORIZON_Y)])
		for j in 9:
			var x := lerpf(x0, x1, j / 8.0)
			pts.append(Vector2(x, HORIZON_Y - k * (26.0 + 14.0 * sin(j * 1.3 + side[0] * 2.0)) * (1.0 - pow(j / 8.0, 3.0))))
		pts.append(Vector2(x1, HORIZON_Y))
		o.draw_colored_polygon(pts, Color("6f8f6a").lerp(FERRY_SKY[1], 0.45))
	o.draw_rect(Rect2(0, HORIZON_Y, 960, 540 - HORIZON_Y), FERRY_SEA)
	_waves(o, 0, 5)
	var c := Vector2(lerpf(170.0, 790.0, t), 392.0 + 4.0 * sin(_sea_t * 2.2))
	_ferry_side(o, c, sin(_sea_t * 1.7) * 0.015)
	_waves(o, 5, 8)
	# the ferry's name over the sea, its fact under it
	var title: String = _ferry.get("name", "")
	o.draw_string(font, Vector2(2, 202), title, HORIZONTAL_ALIGNMENT_CENTER, 960, 34, Color(0, 0, 0, 0.35))
	o.draw_string(font, Vector2(0, 200), title, HORIZONTAL_ALIGNMENT_CENTER, 960, 34, Color.WHITE)
	var fact: String = _ferry.get("fact", "")
	var sub := Units.dist_text(_ferry.get("sea_km", 0.0)) + ("  ·  " + fact if fact != "" else "")
	o.draw_string(font, Vector2(1, 235), sub, HORIZONTAL_ALIGNMENT_CENTER, 960, 18, Color(0, 0, 0, 0.35))
	o.draw_string(font, Vector2(0, 234), sub, HORIZONTAL_ALIGNMENT_CENTER, 960, 18, Color("f3f8fc"))

## Rows `r0`..`r1` of waves, further rows smaller and closer together, rolling with the time.
func _waves(o: Control, r0: int, r1: int) -> void:
	for r in range(r0, r1):
		var y := HORIZON_Y + 8.0 + pow(r, 1.55) * 13.0
		var amp := 1.5 + r * 0.9
		var wl := 40.0 + r * 18.0
		var ph := _sea_t * (1.0 + r * 0.25) + r * 1.7
		var pts := PackedVector2Array()
		var x := -20.0
		while x <= 980.0:
			pts.append(Vector2(x, y + amp * sin(x / wl * TAU * 0.5 + ph)))
			x += 8.0
		o.draw_polyline(pts, Color(1, 1, 1, 0.22 + r * 0.04), 1.0 + r * 0.35)

## A car ferry from the side, bow to the right, `c` at the middle of its waterline, rolling by `tilt` radians: the
## hull, the open car deck aft with the player's car, the white superstructure, the funnel.
func _ferry_side(o: Control, c: Vector2, tilt: float) -> void:
	o.draw_set_transform(c, tilt, Vector2.ONE)
	var hull := PackedVector2Array([Vector2(-160, -40), Vector2(130, -40), Vector2(172, -48), Vector2(146, 12), Vector2(-150, 12)])
	o.draw_colored_polygon(hull, Color("1f3f73"))
	o.draw_rect(Rect2(-152, 0, 300, 7), Color("b8322a"))
	o.draw_rect(Rect2(-160, -46, 200, 6), Color("f3f4f2"))
	# the superstructure and the bridge, rows of windows
	o.draw_rect(Rect2(-40, -80, 160, 34), Color("f3f4f2"))
	o.draw_rect(Rect2(-20, -102, 120, 22), Color("f3f4f2"))
	for k in 12:
		o.draw_rect(Rect2(-34 + k * 13, -72, 8, 7), Color("2a3a4a"))
		o.draw_rect(Rect2(-34 + k * 13, -59, 8, 7), Color("2a3a4a"))
	o.draw_rect(Rect2(-12, -96, 104, 8), Color("2a3a4a"))
	for k in 3:
		o.draw_rect(Rect2(-30 + k * 50, -86, 22, 7), Color("f08a1c")) # lifeboats
	o.draw_rect(Rect2(20, -128, 22, 26), Color("f3f4f2"))
	o.draw_rect(Rect2(20, -122, 22, 6), Scenery.SIGN_BLUE)
	o.draw_rect(Rect2(20, -128, 22, 3), Color("26272b"))
	o.draw_line(Vector2(70, -102), Vector2(70, -126), Color("3b3f45"), 2.0)
	# the player's car on the open deck aft, a rail along the deck's edge
	_car_side(o, Vector2(-100, -46), Color(CarStats.by_id(race.car_id).body_color))
	o.draw_line(Vector2(-160, -56), Vector2(-50, -56), Color("e9e9ec"), 1.5)
	for k in 8:
		o.draw_line(Vector2(-158 + k * 15, -56), Vector2(-158 + k * 15, -46), Color("e9e9ec"), 1.2)
	Scenery.ship_icon(o, Vector2(80, -18), 6.0, Color(1, 1, 1, 0.85))
	o.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

## A car seen from the side, facing right, standing on `b` (the middle of its wheels' line).
func _car_side(o: Control, b: Vector2, body: Color) -> void:
	o.draw_colored_polygon(PackedVector2Array([b + Vector2(-34, -6), b + Vector2(-32, -18), b + Vector2(-18, -20), b + Vector2(-10, -31),
		b + Vector2(14, -31), b + Vector2(24, -20), b + Vector2(34, -17), b + Vector2(36, -6)]), body)
	o.draw_colored_polygon(PackedVector2Array([b + Vector2(-8, -28), b + Vector2(12, -28), b + Vector2(20, -20), b + Vector2(-15, -20)]), Color("1b2a38"))
	for x in [-20.0, 22.0]:
		o.draw_circle(b + Vector2(x, -5), 7.0, Color("17171a"))
		o.draw_circle(b + Vector2(x, -5), 3.0, Color("9a9ea4"))
