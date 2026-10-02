extends Node2D
## Three-step selection: car -> season -> stage. Arrow keys / A D move, Enter or Space confirms, Esc goes back.
const STEP_TITLES := ["Wybierz auto", "Wybierz porę roku", "Wybierz odcinek"]
const STAGE_BLURBS := ["Ulice miasta, gęsty ruch", "Szeroka autostrada, wysokie prędkości", "Leśne zakręty i wzgórza, meta w Zamościu"]
var font: Font
var step := 0
var sel := [0, 1, 0]
var t := 0.0

func _ready() -> void:
	font = ThemeDB.fallback_font
	Sfx.silence_all_loops()
	Sfx.set_music(-9.0)
	sel[0] = maxi(0, CarStats.ALL_IDS.find(Session.car_id))
	sel[1] = maxi(0, SeasonPalette.SEASONS.find(Session.season))
	sel[2] = Session.stage

func _count() -> int:
	return [CarStats.ALL_IDS.size(), SeasonPalette.SEASONS.size(), StageData.COUNT][step]

func _process(dt: float) -> void:
	t += dt
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if event.is_action_pressed("left") or event.is_action_pressed("right") or event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER or event.keycode == KEY_SPACE or (event.keycode == KEY_ESCAPE and step > 0):
		Sfx.play("blip", -8.0)
	if event.is_action_pressed("left"):
		sel[step] = (sel[step] + _count() - 1) % _count()
	elif event.is_action_pressed("right"):
		sel[step] = (sel[step] + 1) % _count()
	elif event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER or event.keycode == KEY_SPACE:
		if step < 2:
			step += 1
		else:
			_start()
	elif event.keycode == KEY_ESCAPE and step > 0:
		step -= 1

func _start() -> void:
	Session.car_id = CarStats.ALL_IDS[sel[0]]
	Session.season = SeasonPalette.SEASONS[sel[1]]
	Session.stage = sel[2]
	get_tree().change_scene_to_file("res://src/scenes/game.tscn")

func _t(pos: Vector2, text: String, size: int, col: Color, align := HORIZONTAL_ALIGNMENT_LEFT, width := -1.0) -> void:
	draw_string(font, pos, text, align, width, size, col)

func _draw() -> void:
	var pal := SeasonPalette.by_name(SeasonPalette.SEASONS[sel[1]] if step > 0 else "summer")
	draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(960, 0), Vector2(960, 540), Vector2(0, 540)]),
		PackedColorArray([pal.sky_top, pal.sky_top, pal.sky_bottom, pal.sky_bottom]))
	draw_rect(Rect2(0, 400, 960, 140), pal.grass_a)
	draw_primitive(PackedVector2Array([Vector2(430, 400), Vector2(530, 400), Vector2(760, 540), Vector2(200, 540)]), PackedColorArray([pal.road_a, pal.road_a, pal.road_a, pal.road_a]), PackedVector2Array())
	_t(Vector2(0, 62), "ROAD RACE", 54, Color(0, 0, 0, 0.25), HORIZONTAL_ALIGNMENT_CENTER, 964)
	_t(Vector2(0, 60), "ROAD RACE", 54, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, 960)
	_t(Vector2(0, 92), "Kraków - Zamość", 24, Color("1d2b38"), HORIZONTAL_ALIGNMENT_CENTER, 960)
	_t(Vector2(0, 140), "%d / 3   %s" % [step + 1, STEP_TITLES[step]], 28, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, 960)
	match step:
		0: _draw_cars()
		1: _draw_seasons()
		_: _draw_stages()
	var summary := "%s  ·  %s  ·  %s" % [CarStats.by_id(CarStats.ALL_IDS[sel[0]]).name, SeasonPalette.label(SeasonPalette.SEASONS[sel[1]]), StageData.at(sel[2]).name]
	if step == 0:
		summary = ""
	elif step == 1:
		summary = CarStats.by_id(CarStats.ALL_IDS[sel[0]]).name
	draw_rect(Rect2(0, 486, 960, 54), Color(0, 0, 0, 0.5))
	_t(Vector2(24, 518), summary, 20, Color("ffd24a"))
	var hint := "Strzałki: wybierz      Enter: dalej" if step < 2 else "Strzałki: wybierz      Enter: START!"
	if step > 0:
		hint += "      Esc: wstecz"
	hint += "      X: dźwięk"
	_t(Vector2(0, 518), hint, 20, Color.WHITE, HORIZONTAL_ALIGNMENT_RIGHT, 936)

func _card(rect: Rect2, selected: bool) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.06, 0.09, 0.13, 0.78) if selected else Color(0.06, 0.09, 0.13, 0.45)
	sb.set_corner_radius_all(16)
	if selected:
		sb.border_color = Color("ffd24a")
		sb.set_border_width_all(4)
	draw_style_box(sb, rect)

func _bar(pos: Vector2, label: String, v: float) -> void:
	_t(pos, label, 14, Color("b8c7d6"))
	draw_rect(Rect2(pos + Vector2(112, -11), Vector2(116, 9)), Color(1, 1, 1, 0.2))
	draw_rect(Rect2(pos + Vector2(112, -11), Vector2(116 * clampf(v, 0.0, 1.0), 9)), Color("4cc3ff"))

func _draw_cars() -> void:
	for i in 3:
		var id: String = CarStats.ALL_IDS[i]
		var c := CarStats.by_id(id)
		var r := Rect2(60 + i * 290, 180, 260, 290)
		var on: bool = sel[0] == i
		_card(r, on)
		CarPainter.draw(self, id, Vector2(r.position.x + 130, r.position.y + 128), 0.78 if on else 0.68, sin(t * 2.0) * 0.3 if on else 0.0, false)
		_t(r.position + Vector2(0, 160), c.name, 24, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
		_bar(r.position + Vector2(14, 196), "Prędkość", c.max_speed / 55.0)
		_bar(r.position + Vector2(14, 224), "Przyspieszenie", c.accel / 9.0)
		_bar(r.position + Vector2(14, 252), "Bak", c.tank / 60.0)
		_bar(r.position + Vector2(14, 280), "Zwrotność", (c.handling - 0.7) / 0.5)

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

func _draw_stages() -> void:
	for i in 3:
		var s := StageData.at(i)
		var r := Rect2(60 + i * 290, 180, 260, 290)
		var on: bool = sel[2] == i
		_card(r, on)
		_t(r.position + Vector2(0, 52), str(i + 1), 56, Color("ffd24a"), HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
		draw_multiline_string(font, r.position + Vector2(10, 92), s.name, HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 20, 22, 2, Color.WHITE)
		_t(r.position + Vector2(0, 160), "Czas: %s" % Hud.format_time(s.duration), 22, Color("4cc3ff"), HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
		_t(r.position + Vector2(0, 188), "Stacje paliw: %d" % s.stations.size(), 18, Color("f2c21b"), HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
		draw_multiline_string(font, r.position + Vector2(14, 220), STAGE_BLURBS[i], HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 28, 17, 3, Color("c8d6e3"))
		_t(r.position + Vector2(0, 262), "Meta: " + s.finish_label, 18, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, r.size.x)
