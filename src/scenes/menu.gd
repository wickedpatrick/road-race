extends Node2D
## Selection: car -> season -> destination on the map of Poland. The race always starts where the last one ended;
## the very first time (or after a progress reset) the player first picks a home city on the map.
## Arrow keys / WASD move, Enter or Space confirms, Esc goes back; on the map cities can also be clicked.
const TITLES := {"home": "Skąd jesteś?", "car": "Wybierz auto", "season": "Wybierz porę roku", "dest": "Dokąd jedziesz?"}
var font: Font
var steps: Array = []
var step := 0
var sel := [0, 1]
var start_city := "krakow"
var dest_city := "rzeszow"
var hover := ""
var legs: Array = []
var map := PolandMap.new(Rect2(24, 104, 440, 378))
var confirm_reset := false ## "reset progress?" question is shown (car step, R key)
var loading := false ## start chosen: the "get ready" card is shown while the race scene loads
var t := 0.0

func _ready() -> void:
	font = ThemeDB.fallback_font
	Sfx.silence_all_loops()
	sel[0] = maxi(0, CarStats.ALL_IDS.find(Session.car_id))
	sel[1] = maxi(0, SeasonPalette.SEASONS.find(Session.season))
	_set_steps()
	start_city = Session.from_city
	dest_city = Session.to_city
	if Session.menu_at_map and Session.has_home():
		step = steps.find("dest")
	Session.menu_at_map = false
	_enter_step()

func _set_steps() -> void:
	steps = ["car", "season", "dest"] if Session.has_home() else ["home", "car", "season", "dest"]
	step = 0

func kind() -> String:
	return steps[step]

func _on_map() -> bool:
	return kind() == "home" or kind() == "dest"

func _enter_step() -> void:
	if kind() == "dest":
		_pick_dest(dest_city if dest_city != start_city and Geo.CITIES.has(dest_city) else map.step(start_city, Vector2.RIGHT))
		hover = dest_city
	else:
		hover = start_city

func _count() -> int:
	return CarStats.ALL_IDS.size() if kind() == "car" else SeasonPalette.SEASONS.size()

func _sel_idx() -> int:
	return 0 if kind() == "car" else 1

func _pick_dest(id: String) -> void:
	dest_city = id
	legs = Route.find(start_city, dest_city)

func _process(dt: float) -> void:
	t += dt
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if loading:
		return
	if _on_map() and event is InputEventMouse:
		_map_mouse(event)
		return
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if confirm_reset:
		if event.keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_T]:
			_reset_progress()
		elif event.keycode in [KEY_ESCAPE, KEY_N]:
			Sfx.play("blip", -8.0)
			confirm_reset = false
		return
	if kind() == "car" and event.keycode == KEY_R:
		Sfx.play("blip", -8.0)
		confirm_reset = true
		return
	var confirm: bool = event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER or event.keycode == KEY_SPACE
	var back: bool = event.keycode == KEY_ESCAPE and step > 0
	var dir := Vector2.ZERO
	if event.is_action_pressed("left"): dir = Vector2.LEFT
	elif event.is_action_pressed("right"): dir = Vector2.RIGHT
	elif event.keycode == KEY_UP or event.keycode == KEY_W: dir = Vector2.UP
	elif event.keycode == KEY_DOWN or event.keycode == KEY_S: dir = Vector2.DOWN
	if dir != Vector2.ZERO or confirm or back:
		Sfx.play("blip", -8.0)
	if back:
		step -= 1
		_enter_step()
	elif confirm:
		_confirm()
	elif dir != Vector2.ZERO:
		match kind():
			"car", "season":
				if dir.x != 0.0:
					sel[_sel_idx()] = (sel[_sel_idx()] + _count() + int(dir.x)) % _count()
			"home":
				start_city = map.step(start_city, dir)
				hover = start_city
			"dest":
				_pick_dest(map.step(dest_city, dir, start_city))
				hover = dest_city

func _confirm() -> void:
	match kind():
		"car":
			if not Profile.is_unlocked(CarStats.ALL_IDS[sel[0]], Session.total_km):
				return # locked car
		"home":
			Session.set_home(start_city)
		"dest":
			if not legs.is_empty():
				_start()
			return
	step += 1
	_enter_step()

func _reset_progress() -> void:
	Session.reset_profile()
	sel = [0, SeasonPalette.SEASONS.find(Session.season)]
	start_city = Session.from_city
	dest_city = Session.to_city
	confirm_reset = false
	_set_steps()
	_enter_step()
	Sfx.play("hit", -6.0)

func _map_mouse(event: InputEventMouse) -> void:
	var id := map.city_at(get_global_mouse_position())
	if event is InputEventMouseMotion:
		if id != "" and not (kind() == "dest" and id == start_city):
			hover = id
		return
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) or id == "":
		return
	Sfx.play("blip", -8.0)
	if kind() == "home":
		start_city = id
		_confirm()
	elif id == dest_city:
		_confirm()
	elif id != start_city:
		_pick_dest(id)
		hover = id

func _start() -> void:
	Session.car_id = CarStats.ALL_IDS[sel[0]]
	Session.season = SeasonPalette.SEASONS[sel[1]]
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
	return "%d / %d   %s" % [step + 1, steps.size(), TITLES[kind()]]

func _draw() -> void:
	var pal := SeasonPalette.by_name(SeasonPalette.SEASONS[sel[1]] if kind() != "car" and kind() != "home" else "summer")
	draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(960, 0), Vector2(960, 540), Vector2(0, 540)]),
		PackedColorArray([pal.sky_top, pal.sky_top, pal.sky_bottom, pal.sky_bottom]))
	draw_rect(Rect2(0, 400, 960, 140), pal.grass_a)
	draw_primitive(PackedVector2Array([Vector2(430, 400), Vector2(530, 400), Vector2(760, 540), Vector2(200, 540)]), PackedColorArray([pal.road_a, pal.road_a, pal.road_a, pal.road_a]), PackedVector2Array())
	_t(Vector2(0, 62), "RAJD PRZEZ POLSKĘ", 54, Color(0, 0, 0, 0.25), HORIZONTAL_ALIGNMENT_CENTER, 964)
	_t(Vector2(0, 60), "RAJD PRZEZ POLSKĘ", 54, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, 960)
	_t(Vector2(0, 92), "Edukacyjna podróż po polskich drogach", 24, Color("1d2b38"), HORIZONTAL_ALIGNMENT_CENTER, 960)
	if not _on_map():
		_t(Vector2(0, 140), _step_title(), 28, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, 960)
	match kind():
		"car": _draw_cars()
		"season": _draw_seasons()
		_: _draw_map()
	var summary := ""
	if kind() == "season" or kind() == "dest":
		summary = CarStats.by_id(CarStats.ALL_IDS[sel[0]]).name
	if kind() == "dest":
		summary += "  ·  " + SeasonPalette.label(SeasonPalette.SEASONS[sel[1]])
	draw_rect(Rect2(0, 486, 960, 54), Color(0, 0, 0, 0.5))
	_t(Vector2(24, 518), summary, 17 if _on_map() else 20, Color("ffd24a"))
	var hint := "Strzałki: wybierz      Enter: dalej"
	if _on_map():
		hint = "Strzałki/myszka   " + ("Enter: START!" if kind() == "dest" else "Enter: dalej")
	if kind() == "car":
		_unlock_progress(Vector2(24, 505))
		hint = "Strzałki   Enter: dalej   R: reset postępu"
	if step > 0:
		hint += "      Esc: wstecz"
	hint += "      X: dźwięk"
	_t(Vector2(0, 518), hint, 20, Color.WHITE, HORIZONTAL_ALIGNMENT_RIGHT, 936)
	if confirm_reset:
		_draw_reset_question()
	if loading:
		draw_rect(Rect2(0, 0, 960, 540), Color(0.03, 0.05, 0.08, 0.82))
		_t(Vector2(0, 250), "Przygotuj się do rajdu!", 48, Color("ffd24a"), HORIZONTAL_ALIGNMENT_CENTER, 960)
		_t(Vector2(0, 300), "%s - %s" % [Geo.city(start_city).name, Geo.city(dest_city).name], 26, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, 960)

func _draw_reset_question() -> void:
	draw_rect(Rect2(0, 0, 960, 540), Color(0.03, 0.05, 0.08, 0.75))
	var r := Rect2(200, 160, 560, 220)
	_card(r, true)
	_t(Vector2(0, 220), "Zresetować postęp?", 40, Color("ffd24a"), HORIZONTAL_ALIGNMENT_CENTER, 960)
	draw_multiline_string(font, Vector2(240, 262), "Licznik przejechanych kilometrów (%d km) i odblokowane auta zostaną skasowane. Zaczniesz od nowa Yarisem i znów wybierzesz swoje miasto." % int(Session.total_km), HORIZONTAL_ALIGNMENT_CENTER, 480, 18, 3, Color.WHITE)
	_t(Vector2(0, 352), "Enter: tak, resetuj      Esc: nie", 20, Color("c8d6e3"), HORIZONTAL_ALIGNMENT_CENTER, 960)

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
	var n := Profile.unlocked_count(km)
	_t(pos + Vector2(0, 0), "Przejechane: %d km" % int(km), 16, Color("ffd24a"))
	if n >= CarStats.ALL_IDS.size():
		_t(pos + Vector2(0, 22), "Wszystkie auta odblokowane!", 14, Color.WHITE)
		return
	var next: Dictionary = CarStats.by_id(CarStats.ALL_IDS[n])
	_t(pos + Vector2(0, 24), "%s za %d km" % [next.name, int(ceil(Profile.unlock_km(n) - km))], 14, Color.WHITE)
	draw_rect(Rect2(pos + Vector2(190, -12), Vector2(160, 10)), Color(1, 1, 1, 0.2))
	draw_rect(Rect2(pos + Vector2(190, -12), Vector2(160 * Profile.next_progress(km), 10)), Color("49d36b"))

func _draw_cars() -> void:
	var n := CarStats.ALL_IDS.size()
	var w := 172.0
	for i in n:
		var id: String = CarStats.ALL_IDS[i]
		var c := CarStats.by_id(id)
		var r := Rect2(28 + i * (w + 11), 172, w, 302)
		var on: bool = sel[0] == i
		var open := Profile.is_unlocked(id, Session.total_km)
		_card(r, on)
		CarPainter.draw(self, id, Vector2(r.position.x + w * 0.5, r.position.y + 106), 0.62 if on else 0.55, sin(t * 2.0) * 0.3 if on and open else 0.0, false)
		draw_multiline_string(font, r.position + Vector2(6, 138), c.name, HORIZONTAL_ALIGNMENT_CENTER, w - 12, 17, 2, Color.WHITE)
		_t(r.position + Vector2(0, 180), "%d KM" % c.hp, 13, Color("c8d6e3"), HORIZONTAL_ALIGNMENT_CENTER, w)
		var bx := r.position.x + 12
		_bar(Vector2(bx, r.position.y + 200), "Prędkość", c.max_speed / 70.0, w - 24)
		_bar(Vector2(bx, r.position.y + 224), "Przyspieszenie", c.accel / 12.0, w - 24)
		_bar(Vector2(bx, r.position.y + 248), "Zwrotność", (c.handling - 0.6) / 0.65, w - 24)
		_bar(Vector2(bx, r.position.y + 272), "Oszczędność", 0.3 / c.burn * 0.9, w - 24)
		if not open:
			var sb := StyleBoxFlat.new()
			sb.bg_color = Color(0.03, 0.05, 0.08, 0.72)
			sb.set_corner_radius_all(16)
			draw_style_box(sb, r)
			var lc := r.position + Vector2(w * 0.5, 84)
			draw_rect(Rect2(lc + Vector2(-18, -6), Vector2(36, 28)), Color("ffd24a"))
			draw_arc(lc + Vector2(0, -6), 12, PI, TAU, 16, Color("ffd24a"), 5.0)
			draw_circle(lc + Vector2(0, 6), 4, Color("2b2b2f"))
			_t(r.position + Vector2(0, 186), "od %d km" % int(Profile.unlock_km(i)), 18, Color("ffd24a"), HORIZONTAL_ALIGNMENT_CENTER, w)

func _draw_seasons() -> void:
	for i in 4:
		var s: String = SeasonPalette.SEASONS[i]
		var p := SeasonPalette.by_name(s)
		var r := Rect2(48 + i * 218, 180, 198, 290)
		var on: bool = sel[1] == i
		_card(r, on)
		var pr := Rect2(r.position + Vector2(12, 12), Vector2(174, 200))
		draw_polygon(PackedVector2Array([pr.position, pr.position + Vector2(pr.size.x, 0), pr.position + pr.size * Vector2(1, 0.55), pr.position + pr.size * Vector2(0, 0.55)]), PackedColorArray([p.sky_top, p.sky_top, p.sky_bottom, p.sky_bottom]))
		draw_rect(Rect2(pr.position + Vector2(0, pr.size.y * 0.55), Vector2(pr.size.x, pr.size.y * 0.45)), p.grass_a)
		draw_primitive(PackedVector2Array([pr.position + Vector2(76, 110), pr.position + Vector2(98, 110), pr.position + Vector2(140, 200), pr.position + Vector2(34, 200)]), PackedColorArray([p.road_a, p.road_a, p.road_a, p.road_a]), PackedVector2Array())
		draw_circle(pr.position + Vector2(24, 140), 16, p.tree)
		draw_circle(pr.position + Vector2(152, 135), 18, p.tree2)
		draw_circle(pr.position + Vector2(160, 160), 14, p.tree)
		if p.sun:
			draw_circle(pr.position + Vector2(130, 30), 18, Color("fff3c4"))
		if p.particle != "none":
			for k in 14:
				var px := fposmod(k * 47.0 + sin(t + k) * 10.0, pr.size.x)
				var py := fposmod(k * 31.0 + t * 30.0, pr.size.y * 0.9)
				draw_circle(pr.position + Vector2(px, py), 2.0, Color.WHITE if p.particle == "snow" else (Color("d9772a") if p.particle == "leaves" else Color("f7b8d2")))
		_t(r.position + Vector2(0, 252), SeasonPalette.label(s), 26, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)

func _draw_map() -> void:
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color("2b4763")
	bg.set_corner_radius_all(16)
	draw_style_box(bg, Rect2(16, 100, 456, 384))
	var dest := kind() == "dest"
	map.draw(self, font, legs if dest else [], start_city, dest_city if dest else "", hover, t)
	var r := Rect2(488, 100, 456, 384)
	_card(r, true)
	var x := r.position.x + 20
	var w := r.size.x - 40
	_t(Vector2(x, 140), _step_title(), 26, Color.WHITE)
	var id := hover if hover != "" else start_city
	if not dest:
		_city_info(id, Vector2(x, 186), w)
		_t(Vector2(x, 460), "Wybierz swoje miasto: stąd ruszysz w pierwszy rajd", 16, Color("c8d6e3"))
		return
	_t(Vector2(x, 176), "Jesteś w: %s" % Geo.city(start_city).name, 18, Color("7fe0a0"))
	if id != dest_city and id != start_city:
		_city_info(id, Vector2(x, 214), w)
		_t(Vector2(x, 460), "Kliknij lub naciśnij Enter, aby wybrać", 16, Color("c8d6e3"))
		return
	if legs.is_empty():
		return
	var st := Route.build(start_city, dest_city)
	_t(Vector2(x, 206), "Cel: %s" % Geo.city(dest_city).name, 22, Color("ff9a86"))
	var roads := []
	for l in legs:
		for rd in Route.leg_roads(l):
			if rd[2] != "" and not roads.has(rd[2]): roads.append(rd[2])
	_t(Vector2(x, 236), "%d km   ·   drogi: %s" % [st.km, ", ".join(roads) if not roads.is_empty() else "miejskie"], 17, Color.WHITE)
	_t(Vector2(x, 262), "Czas: %s   ·   stacje paliw: %d" % [Hud.format_time(st.duration), st.stations.size()], 17, Color("4cc3ff"))
	var via := []
	var bigs := []
	for tw in st.towns:
		if tw.get("start", false) or tw.get("finish", false): continue
		via.append(tw.name)
		if tw.big: bigs.append(tw.name)
	var via_text := "Po drodze: " + ", ".join(via)
	if via.size() > 9:
		via_text = "Przez miasta: %s, oraz %d mniejszych miejscowości" % [", ".join(bigs), via.size() - bigs.size()]
	draw_multiline_string(font, Vector2(x, 292), via_text, HORIZONTAL_ALIGNMENT_LEFT, w, 15, 4, Color("e8eef4"))
	var regions: Array = st.regions.slice(0, 6)
	var reg_text := "Krainy: " + ", ".join(regions) + (" i inne" if st.regions.size() > regions.size() else "")
	draw_multiline_string(font, Vector2(x, 386), reg_text, HORIZONTAL_ALIGNMENT_LEFT, w, 15, 3, Color("f1d9b5"))

func _city_info(id: String, pos: Vector2, w: float) -> void:
	var c := Geo.city(id)
	_t(pos, c.name, 26, Color("ffd24a"))
	_t(pos + Vector2(0, 30), "województwo %s" % c.voiv, 17, Color.WHITE)
	_t(pos + Vector2(0, 56), "ok. %d tys. mieszkańców" % c.pop, 17, Color("c8d6e3"))
	draw_multiline_string(font, pos + Vector2(0, 90), Geo.fact(c.name), HORIZONTAL_ALIGNMENT_LEFT, w, 17, 4, Color("e8eef4"))
