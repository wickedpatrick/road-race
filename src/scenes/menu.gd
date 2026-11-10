extends Node2D
## Selection: car -> destination on the country map (each trip's weather shown on the card beside it) (tabs above the map, or C, switch the country). The race always starts where the last one ended;
## the very first time the player first picks a home city on the map.
## Arrow keys / WASD move, Enter or Space confirms, Esc goes back; on the map cities can also be clicked.

var font: Font
var steps: Array = []
var step := 0
var sel := [0, 1]
var start_city := "krakow"
var dest_city := "rzeszow"
var hover := ""
var legs: Array = []
const MAP_RECT := Rect2(24, 104, 440, 378)
const MAP_PANEL := Rect2(16, 100, 456, 384)
var map: CountryMap
## the map is drawn on its own layer clipped to the panel, so a big country can scroll inside it
var _map_clip: Control
var _map_layer: Node2D
var _follow := "" ## city the scrolling map glides to ("" while the player drags it)
var _press := Vector2(-1, -1) ## where the left button went down on the map (-1: not pressed)
var _dragging := false
const DRAG_START := 8.0 ## pixels moved before a press becomes a drag (not a click on a city)
const NEXT_BTN := Rect2(744, 490, 200, 44)
const BACK_BTN := Rect2(584, 490, 148, 44)
const CAR_GAP := 8.0 ## pixels between the car cards
const LANG_BTN := Rect2(736, 124, 196, 36) ## car step: the game's language (L key)
const ALBUM_CAR_BTN := Rect2(28, 124, 196, 36) ## the postcard album (P key): on the car step
const ALBUM_MAP_BTN := Rect2(796, 14, 148, 40) ## and on the map steps
const RANKING_BTN := Rect2(764, 440, 168, 36) ## destination step: the rankings of the trip's roads (R key)
var loading := false ## start chosen: the "get ready" card is shown while the race scene loads
var t := 0.0

func _ready() -> void:
	font = ThemeDB.fallback_font
	_map_clip = Control.new()
	_map_clip.clip_contents = true
	_map_clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_map_clip.position = MAP_PANEL.position
	_map_clip.size = MAP_PANEL.size
	_map_layer = Node2D.new()
	_map_layer.position = -MAP_PANEL.position # draws in screen coordinates
	_map_layer.draw.connect(_draw_map_layer)
	_map_clip.add_child(_map_layer)
	add_child(_map_clip)
	_new_map()
	Sfx.silence_all_loops()
	sel[0] = maxi(0, CarStats.ids().find(Session.car_id))
	_set_steps()
	start_city = Session.from_city
	dest_city = Session.to_city
	if Session.menu_at_map and Session.has_home():
		step = steps.find("dest")
	Session.menu_at_map = false
	_enter_step()

func _set_steps() -> void:
	steps = ["car", "dest"] if Session.has_home() else ["home", "car", "dest"]
	step = 0

func kind() -> String:
	return steps[step]

func _on_map() -> bool:
	return kind() == "home" or kind() == "dest"

func _new_map() -> void:
	map = CountryMap.new(MAP_RECT, true)
	if steps.size() > 0 and _on_map():
		map.center_on(start_city)

func _enter_step() -> void:
	if kind() == "dest":
		_pick_dest(dest_city if Route.neighbours(start_city).has(dest_city) else _default_dest())
		hover = dest_city
	else:
		hover = start_city
	_follow = start_city
	map.center_on(start_city)

## A trip goes one road, to a neighbouring city. By default the nearest one not visited yet, else the nearest one.
func _default_dest() -> String:
	var best := ""
	var best_score := INF
	for id in Route.neighbours(start_city):
		var score := Route.total_km(Route.find(start_city, id)) + (0.0 if not Session.visited.has(id) else 10000.0)
		if score < best_score:
			best_score = score
			best = id
	return best

func _count() -> int:
	return CarStats.ids().size()

func _sel_idx() -> int:
	return 0

func _pick_dest(id: String) -> void:
	dest_city = id
	legs = Route.find(start_city, dest_city)

func _process(dt: float) -> void:
	t += dt
	_map_clip.visible = _on_map() and not loading
	if _map_clip.visible:
		if _follow != "" and not _dragging:
			map.follow(_follow, dt)
		_map_layer.queue_redraw()
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if loading:
		return
	var tp = Ui.tap(event)
	if tp != null and _tap(tp):
		return
	if _on_map() and event is InputEventMouse:
		_map_mouse(event)
		return
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if _on_map() and event.keycode == KEY_C and _countries() > 1:
		_open_countries()
		return
	if event.keycode == KEY_P and (kind() == "car" or kind() == "dest"):
		_open_album()
		return
	if kind() == "dest" and event.keycode == KEY_R:
		_open_ranking()
		return
	if kind() == "car" and event.keycode == KEY_L:
		_next_language()
		return
	var confirm: bool = event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER or event.keycode == KEY_SPACE
	var back: bool = event.keycode == KEY_ESCAPE and step > 0
	var dir := Vector2.ZERO
	if event.is_action_pressed("left"): dir = Vector2.LEFT
	elif event.is_action_pressed("right"): dir = Vector2.RIGHT
	elif event.keycode == KEY_UP or event.keycode == KEY_W: dir = Vector2.UP
	elif event.keycode == KEY_DOWN or event.keycode == KEY_S: dir = Vector2.DOWN
	if dir != Vector2.ZERO or confirm or back:
		Sfx.play("blip", -15.0)
	if back:
		step -= 1
		_enter_step()
	elif confirm:
		_confirm()
	elif dir != Vector2.ZERO:
		match kind():
			"car":
				if dir.x != 0.0:
					sel[_sel_idx()] = (sel[_sel_idx()] + _count() + int(dir.x)) % _count()
			"home":
				start_city = map.step(start_city, dir)
				hover = start_city
				_follow = start_city
			"dest":
				_pick_dest(map.step(dest_city, dir, start_city, Route.neighbours(start_city)))
				hover = dest_city
				_follow = dest_city

## Keeps the chosen car and destination while the album is open (the menu is built again on the way back);
## not saved: a trip started makes them the player's choice.
func _keep_picks() -> void:
	var car: String = CarStats.ids()[sel[0]]
	if Profile.is_unlocked(car, Session.car_km()):
		Session.car_id = car
	if kind() == "dest" and dest_city != "":
		Session.to_city = dest_city

func _album_btn() -> Rect2:
	return ALBUM_CAR_BTN if kind() == "car" else ALBUM_MAP_BTN

func _open_album() -> void:
	Sfx.play("blip", -15.0)
	_keep_picks()
	Session.album_back_to_map = _on_map()
	get_tree().change_scene_to_file("res://src/scenes/album.tscn")

## The ranking tables (src/scenes/ranking.gd): the roads of the trip picked, or every road from the start city.
func _open_ranking() -> void:
	Sfx.play("blip", -15.0)
	_keep_picks()
	var keys := []
	if not legs.is_empty():
		keys = legs.map(func(l): return Rankings.key(l.from, l.to))
	else:
		keys = Route.neighbours(start_city).map(func(id): return Rankings.key(start_city, id))
	Session.ranking_view = {"keys": keys, "i": 0, "country": false, "back": "menu"}
	get_tree().change_scene_to_file("res://src/scenes/ranking.tscn")

func _next_language() -> void:
	Sfx.play("blip", -15.0)
	var langs := GameData.LANGUAGES
	Session.set_language(langs[(langs.find(GameData.language) + 1) % langs.size()])
	_new_map() # city names on the map follow the language

func _confirm() -> void:
	match kind():
		"car":
			if not Profile.is_unlocked(CarStats.ids()[sel[0]], Session.car_km()):
				return # locked car
		"home":
			Session.set_home(start_city)
		"dest":
			if not legs.is_empty():
				_start()
			return
	step += 1
	_enter_step()

## Clicks and taps on buttons and cards; true when handled.
func _tap(p: Vector2) -> bool:
	if _on_map() and _countries() > 1 and COUNTRY_BTN.has_point(p):
		_open_countries()
		return true
	if kind() == "car" and LANG_BTN.has_point(p):
		_next_language()
		return true
	if (kind() == "car" or kind() == "dest") and _album_btn().has_point(p):
		_open_album()
		return true
	if kind() == "dest" and RANKING_BTN.has_point(p):
		_open_ranking()
		return true
	if Screen.touch:
		if NEXT_BTN.has_point(p):
			Sfx.play("blip", -15.0)
			_confirm()
			return true
		if BACK_BTN.has_point(p) and step > 0:
			Sfx.play("blip", -15.0)
			step -= 1
			_enter_step()
			return true
	if kind() == "car":
		for i in _count():
			if _card_rect(i).has_point(p):
				Sfx.play("blip", -15.0)
				if sel[_sel_idx()] == i:
					_confirm() # tapping the chosen card again goes on
				else:
					sel[_sel_idx()] = i
				return true
	return false

func _card_rect(i: int) -> Rect2:
	if kind() == "car":
		var w := _car_card_w()
		return Rect2(28 + i * (w + CAR_GAP), 172, w, 302)
	return Rect2(48 + i * 218, 180, 198, 290)

## Mouse or finger on the map: hover, drag to scroll a big map, a click (a press released without dragging) picks a city.
func _map_mouse(event: InputEventMouse) -> void:
	var pos := get_global_mouse_position()
	if event is InputEventMouseButton and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
		if event.pressed and map.pans():
			map.pan_by(Vector2(0, 40.0 if event.button_index == MOUSE_BUTTON_WHEEL_UP else -40.0))
			_follow = ""
		return
	if event is InputEventMouseMotion:
		if _press.x >= 0.0 and map.pans() and (_dragging or pos.distance_to(_press) > DRAG_START):
			if not _dragging:
				map.pan_by(pos - _press - event.relative) # the first steps of the drag too
			_dragging = true
			_follow = ""
			map.pan_by(event.relative)
			return
		var hid := map.city_at(pos)
		if hid != "" and not (kind() == "dest" and not Route.neighbours(start_city).has(hid)):
			hover = hid
		return
	if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if event.pressed:
		_press = pos if MAP_PANEL.has_point(pos) else Vector2(-1, -1)
		_dragging = false
		return
	var was_drag := _dragging
	var pressed_here := _press.x >= 0.0
	_press = Vector2(-1, -1)
	_dragging = false
	var id := map.city_at(pos)
	if was_drag or not pressed_here or id == "":
		return
	Sfx.play("blip", -15.0)
	if kind() == "home":
		start_city = id
		_confirm()
	elif id == dest_city:
		_confirm()
	elif Route.neighbours(start_city).has(id):
		_pick_dest(id)
		hover = id
		_follow = id

func _start() -> void:
	Session.car_id = CarStats.ids()[sel[0]]
	Session.from_city = start_city
	Session.to_city = dest_city
	Session.save_profile()
	loading = true
	queue_redraw()
	# let the "get ready" card reach the screen before the (blocking) scene change
	await get_tree().process_frame
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://src/scenes/game.tscn")

func _t(pos: Vector2, text: String, size: int, col: Color, align := HORIZONTAL_ALIGNMENT_LEFT, width := -1.0) -> void:
	draw_string(font, pos, text, align, width, size, col)

func _step_title() -> String:
	return "%d / %d   %s" % [step + 1, steps.size(), Lang.t("title_" + kind())]

func _draw() -> void:
	var pal := Weather.palette("sun")
	draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(960, 0), Vector2(960, 540), Vector2(0, 540)]),
		PackedColorArray([pal.sky_top, pal.sky_top, pal.sky_bottom, pal.sky_bottom]))
	draw_rect(Rect2(0, 400, 960, 140), pal.grass_a)
	draw_primitive(PackedVector2Array([Vector2(430, 400), Vector2(530, 400), Vector2(760, 540), Vector2(200, 540)]), PackedColorArray([pal.road_a, pal.road_a, pal.road_a, pal.road_a]), PackedVector2Array())
	var cn := GameData.country()
	var title := String(ProjectSettings.get_setting("application/config/name")).to_upper()
	var ts := 54 # a long title shrinks to stay clear of the postcards button top right
	while ts > 34 and font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, ts).x > TITLE_MAX_W:
		ts -= 2
	_t(Vector2(0, 62), title, ts, Color(0, 0, 0, 0.25), HORIZONTAL_ALIGNMENT_CENTER, 964)
	_t(Vector2(0, 60), title, ts, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, 960)
	_t(Vector2(0, 92), cn.subtitle, 24, Color("1d2b38"), HORIZONTAL_ALIGNMENT_CENTER, 960)
	if not _on_map():
		_t(Vector2(0, 140), _step_title(), 28, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, 960)
	match kind():
		"car": _draw_cars()
		_: _draw_map()
	var summary := ""
	if kind() == "dest":
		summary = CarStats.by_id(CarStats.ids()[sel[0]]).name
	draw_rect(Rect2(0, 486, 960, 54), Color(0, 0, 0, 0.5))
	_t(Vector2(24, 518), summary, 17 if _on_map() else 20, Color("ffd24a"))
	if kind() == "car":
		_unlock_progress(Vector2(24, 505))
		Ui.button(self, font, LANG_BTN, Lang.t("lang_btn") % Lang.NAMES[GameData.language], false, 16)
	if kind() == "car" or kind() == "dest":
		Ui.button(self, font, _album_btn(), Lang.t("album_btn"), false, 16)
	if kind() == "dest":
		Ui.button(self, font, RANKING_BTN, Lang.t("ranking_btn"), false, 16)
	if Screen.touch:
		if step > 0:
			Ui.button(self, font, BACK_BTN, Lang.t("back"), false, 20)
		Ui.button(self, font, NEXT_BTN, Lang.t("start") if kind() == "dest" else Lang.t("next"), true, 22)
	var hint := Lang.t("hint_select")
	if _on_map():
		hint = Lang.t("hint_map") + Lang.t("hint_enter_start" if kind() == "dest" else "hint_enter_next") + (Lang.t("hint_country") if _countries() > 1 else "")
	if kind() == "car":
		hint = Lang.t("hint_car")
	if kind() == "car" or kind() == "dest":
		hint += Lang.t("hint_album")
	if kind() == "dest":
		hint += Lang.t("hint_ranking")
	if step > 0:
		hint += Lang.t("hint_back")
	hint += Lang.t("hint_sound")
	if not Screen.touch:
		_t(Vector2(0, 518), hint, 20, Color.WHITE, HORIZONTAL_ALIGNMENT_RIGHT, 936)
	if loading:
		draw_rect(Rect2(0, 0, 960, 540), Color(0.03, 0.05, 0.08, 0.82))
		_t(Vector2(0, 250), Lang.t("get_ready"), 48, Color("ffd24a"), HORIZONTAL_ALIGNMENT_CENTER, 960)
		_t(Vector2(0, 300), "%s - %s" % [Geo.display_name(start_city), Geo.display_name(dest_city)], 26, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, 960)

func _card(rect: Rect2, selected: bool) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.06, 0.09, 0.13, 0.78) if selected else Color(0.06, 0.09, 0.13, 0.45)
	sb.set_corner_radius_all(16)
	if selected:
		sb.border_color = Color("ffd24a")
		sb.set_border_width_all(4)
	draw_style_box(sb, rect)

func _bar(pos: Vector2, label: String, v: float, w: float) -> void:
	_t(pos, label, 12, Color("b8c7d6"))
	draw_rect(Rect2(pos + Vector2(0, 4), Vector2(w, 6)), Color(1, 1, 1, 0.2))
	draw_rect(Rect2(pos + Vector2(0, 4), Vector2(w * clampf(v, 0.0, 1.0), 6)), Color("4cc3ff"))

## Total kilometres and a bar towards the next car to unlock.
func _unlock_progress(pos: Vector2) -> void:
	var km := Session.total_km
	var n := Profile.unlocked_count(Session.car_km())
	_t(pos + Vector2(0, 0), Lang.t("driven") % Units.dist_text(km), 16, Color("ffd24a"))
	if n >= CarStats.ids().size():
		_t(pos + Vector2(0, 22), Lang.t("all_cars"), 14, Color.WHITE)
		return
	var next: Dictionary = CarStats.by_id(CarStats.ids()[n])
	_t(pos + Vector2(0, 24), Lang.t("next_car") % [next.name, Units.dist_text(Profile.unlock_km(n) - km, true)], 14, Color.WHITE)
	draw_rect(Rect2(pos + Vector2(190, -12), Vector2(160, 10)), Color(1, 1, 1, 0.2))
	draw_rect(Rect2(pos + Vector2(190, -12), Vector2(160 * Profile.next_progress(km), 10)), Color("49d36b"))

## The car cards share the menu's 904 px width, however many cars there are.
func _car_card_w() -> float:
	var n := CarStats.ids().size()
	return minf(172.0, (904.0 - CAR_GAP * (n - 1)) / n)

func _draw_cars() -> void:
	var n := CarStats.ids().size()
	var w := _car_card_w()
	var top := {"max_speed": 0.0, "accel": 0.0, "handling": 0.0}
	for id in CarStats.ids():
		for k in top: top[k] = maxf(top[k], CarStats.by_id(id)[k])
	var cs := minf(0.55, (w - 16.0) / 232.0) # the widest car is ~232 px across at scale 1
	var bw := w - 16.0 if w < 150.0 else w - 24.0
	for i in n:
		var id: String = CarStats.ids()[i]
		var c := CarStats.by_id(id)
		var r := _card_rect(i)
		var on: bool = sel[0] == i
		var open := Profile.is_unlocked(id, Session.car_km())
		_card(r, on)
		CarPainter.draw(self, id, Vector2(r.position.x + w * 0.5, r.position.y + 106), cs * 1.13 if on else cs, sin(t * 2.0) * 0.3 if on and open else 0.0, false)
		draw_multiline_string(font, r.position + Vector2(4, 138), c.name, HORIZONTAL_ALIGNMENT_CENTER, w - 8, 17 if w >= 150.0 else 15, 2, Color.WHITE)
		_power_and_tank(r.position + Vector2(w * 0.5, 180), c)
		var bx := r.position.x + (w - bw) * 0.5
		_bar(Vector2(bx, r.position.y + 200), Lang.t("bar_speed"), c.max_speed / top.max_speed, bw)
		_bar(Vector2(bx, r.position.y + 224), Lang.t("bar_accel"), c.accel / top.accel, bw)
		_bar(Vector2(bx, r.position.y + 248), Lang.t("bar_handling"), (c.handling - 0.6) / (top.handling - 0.55), bw)
		_bar(Vector2(bx, r.position.y + 272), Lang.t("bar_economy"), 0.3 / c.burn * 0.9, bw)
		if not open:
			var sb := StyleBoxFlat.new()
			sb.bg_color = Color(0.03, 0.05, 0.08, 0.72)
			sb.set_corner_radius_all(16)
			draw_style_box(sb, r)
			var lc := r.position + Vector2(w * 0.5, 84)
			draw_rect(Rect2(lc + Vector2(-18, -6), Vector2(36, 28)), Color("ffd24a"))
			draw_arc(lc + Vector2(0, -6), 12, PI, TAU, 16, Color("ffd24a"), 5.0)
			draw_circle(lc + Vector2(0, 6), 4, Color("2b2b2f"))
			_t(r.position + Vector2(0, 186), Lang.t("from_dist") % Units.dist_text(Profile.unlock_km(i)), 18, Color("ffd24a"), HORIZONTAL_ALIGNMENT_CENTER, w)

## "116 KM  ⛽ 40 l" centred under the car's name: the power, then the tank behind a little yellow pump.
func _power_and_tank(mid: Vector2, c: Dictionary) -> void:
	var hp: String = Lang.t("hp") % c.hp
	var tank := "%d l" % c.tank
	var hw := font.get_string_size(hp, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x
	var tw := font.get_string_size(tank, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x
	var x := mid.x - (hw + 8.0 + 11.0 + 4.0 + tw) * 0.5
	_t(Vector2(x, mid.y), hp, 13, Color("c8d6e3"))
	var pc := Vector2(x + hw + 8.0 + 4.0, mid.y - 5.0)
	var dark := Color("1c2733")
	draw_rect(Rect2(pc + Vector2(-4, -6), Vector2(8, 12)), Color("f2c21b"))
	draw_rect(Rect2(pc + Vector2(-2.5, -4.5), Vector2(5, 3)), dark)
	draw_polyline(PackedVector2Array([pc + Vector2(4, -4), pc + Vector2(6.5, -2.5), pc + Vector2(6.5, 3), pc + Vector2(5, 4)]), Color("f2c21b"), 1.5)
	_t(Vector2(x + hw + 8.0 + 11.0 + 4.0, mid.y), tank, 13, Color("ffd24a"))

func _draw_map() -> void:
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color("2b4763")
	bg.set_corner_radius_all(16)
	draw_style_box(bg, MAP_PANEL)
	var dest := kind() == "dest"
	var r := Rect2(488, 100, 456, 384)
	_card(r, true)
	var x := r.position.x + 20
	var w := r.size.x - 40
	_t(Vector2(x, 140), _step_title(), 26, Color.WHITE)
	var id := hover if hover != "" else start_city
	if not dest:
		_city_info(id, Vector2(x, 186), w)
		_t(Vector2(x, 460), Lang.t("pick_home"), 16, Color("c8d6e3"))
		return
	_t(Vector2(x, 176), Lang.t("you_are_in") % Geo.display_name(start_city), 18, Color("7fe0a0"))
	if id != dest_city and id != start_city:
		_city_info(id, Vector2(x, 214), w)
		if Route.neighbours(start_city).has(id):
			_weather_line(Weather.for_legs(Route.find(start_city, id)), x, 214 + 56, w)
		_t(Vector2(x, 460), Lang.t("tap_city") if Screen.touch else Lang.t("click_city"), 16, Color("c8d6e3"))
		return
	if legs.is_empty():
		return
	var st := Route.build(start_city, dest_city)
	_t(Vector2(x, 206), Lang.t("goal") % Geo.display_name(dest_city), 22, Color("ff9a86"))
	_weather_line(st.weather, x, 206, w)
	var roads := []
	for l in legs:
		for rd in Route.leg_roads(l):
			if rd[2] != "" and not roads.has(rd[2]): roads.append(rd[2])
	_t(Vector2(x, 236), Lang.t("trip_roads") % [Units.dist_text(st.km), ", ".join(roads) if not roads.is_empty() else Lang.t("city_roads")], 17, Color.WHITE)
	_t(Vector2(x, 262), Lang.t("trip_time") % [Hud.format_time(st.duration), st.stations.size()], 17, Color("4cc3ff"))
	var via := []
	var bigs := []
	for tw in st.towns:
		if tw.get("start", false) or tw.get("finish", false): continue
		via.append(tw.get("display", tw.name))
		if tw.big: bigs.append(tw.get("display", tw.name))
	var via_text := Lang.t("via") % ", ".join(via)
	if via.size() > 9:
		via_text = Lang.t("via_big") % [", ".join(bigs), via.size() - bigs.size()]
	draw_multiline_string(font, Vector2(x, 292), via_text, HORIZONTAL_ALIGNMENT_LEFT, w, 15, 4, Color("e8eef4"))
	var regions: Array = st.regions.slice(0, 6)
	var reg_text := Lang.t("regions") % (", ".join(regions) + (Lang.t("and_more") if st.regions.size() > regions.size() else ""))
	draw_multiline_string(font, Vector2(x, 386), reg_text, HORIZONTAL_ALIGNMENT_LEFT, w, 15, 3, Color("f1d9b5"))

## The trip's weather, right of the destination's name: an icon and its name.
func _weather_line(kind: String, x: float, y: float, w: float) -> void:
	var wl := Weather.label(kind)
	var ww := font.get_string_size(wl, HORIZONTAL_ALIGNMENT_LEFT, -1, 17).x
	CountryMap.weather_icon(self, Vector2(x + w - ww - 18, y - 6), kind, 12.0)
	_t(Vector2(x, y), wl, 17, Color.WHITE, HORIZONTAL_ALIGNMENT_RIGHT, w)

func _countries() -> int:
	return GameData.countries().size()

const COUNTRY_BTN := Rect2(26, 108, 232, 50) ## over the map: "Change country" with a tiny world map, opens the picker
const TITLE_MAX_W := 600.0 ## the menu title, centred, never reaches the postcards button

## The map and the country button over it, on the clipped layer.
func _draw_map_layer() -> void:
	var dest := kind() == "dest"
	map.visited = Session.visited
	map.reachable = Route.neighbours(start_city) + [start_city] if dest else []
	map.draw(_map_layer, font, legs if dest else [], start_city, dest_city if dest else "", hover, t)
	_draw_country_tabs(_map_layer)

## The country button above the map (only when there is more than one country): a tiny world map with the
## country in gold, its flag and name and "Change country", the border glowing a little so it gets noticed.
func _draw_country_tabs(cv: CanvasItem) -> void:
	if _countries() < 2:
		return
	var sb := StyleBoxFlat.new()
	sb.set_corner_radius_all(10)
	sb.bg_color = Color(0.06, 0.09, 0.13, 0.88)
	sb.border_color = Color("ffd24a", 0.65 + 0.35 * sin(t * 3.0))
	sb.set_border_width_all(2)
	cv.draw_style_box(sb, COUNTRY_BTN)
	var thumb := Rect2(COUNTRY_BTN.position + Vector2(6, 6), Vector2(62, COUNTRY_BTN.size.y - 12))
	WorldThumb.draw(cv, thumb, Session.country, GameData.country_codes())
	cv.draw_rect(thumb, Color(1, 1, 1, 0.5), false, 1.0)
	var x := thumb.end.x + 10
	var w := COUNTRY_BTN.end.x - x - 8
	var name: String = GameData.country().name
	FlagPainter.draw(cv, Session.country, Rect2(Vector2(x, COUNTRY_BTN.position.y + 8), Vector2(21, 14)))
	var nw := w - 26 # the name after the flag
	var fs := 18
	while fs > 12 and font.get_string_size(name, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x > nw:
		fs -= 1
	cv.draw_string(font, Vector2(x + 26, COUNTRY_BTN.position.y + 22), name, HORIZONTAL_ALIGNMENT_LEFT, nw, fs, Color("ffd24a"))
	var cta := Lang.t("change_country") + " ›"
	var cs := 15
	while cs > 11 and font.get_string_size(cta, HORIZONTAL_ALIGNMENT_LEFT, -1, cs).x > w:
		cs -= 1
	cv.draw_string(font, Vector2(x, COUNTRY_BTN.position.y + 42), cta, HORIZONTAL_ALIGNMENT_LEFT, w, cs, Color.WHITE)

## The map of Europe (src/scenes/countries.gd); it switches the country and comes back to the map.
func _open_countries() -> void:
	Sfx.play("blip", -15.0)
	_keep_picks()
	get_tree().change_scene_to_file("res://src/scenes/countries.tscn")

func _city_info(id: String, pos: Vector2, w: float) -> void:
	var c := Geo.city(id)
	var shown := Geo.display_name(id)
	_t(pos, shown if shown == c.name else "%s (%s)" % [shown, c.name], 26, Color("ffd24a"))
	_t(pos + Vector2(0, 30), "%s %s" % [GameData.country().region_label, c.region], 17, Color.WHITE)
	_t(pos + Vector2(0, 56), c.get("note", Lang.t("population") % c.pop), 17, Color("c8d6e3"))
	draw_multiline_string(font, pos + Vector2(0, 90), Geo.fact(c.name), HORIZONTAL_ALIGNMENT_LEFT, w, 17, 4, Color("e8eef4"))
