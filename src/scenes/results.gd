extends Node2D
var font: Font
var r: Dictionary
var age := 0.0

func _ready() -> void:
	font = ThemeDB.fallback_font
	Sfx.set_music(-9.0)
	r = Session.last_result

func _stars() -> int:
	if r.get("state", "") != "won":
		return 0
	var f: float = r.time_left / r.duration
	return 3 if f > 0.35 else (2 if f > 0.12 else 1)

func _draw() -> void:
	var pal := SeasonPalette.by_name(Session.season)
	draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(960, 0), Vector2(960, 540), Vector2(0, 540)]),
		PackedColorArray([pal.sky_top, pal.sky_top, pal.sky_bottom, pal.sky_bottom]))
	var won: bool = r.get("state", "") == "won"
	var title := {"won": "DOJECHAŁEŚ!", "out_of_time": "Skończył się czas", "out_of_fuel": "Skończyło się paliwo"}.get(r.get("state", "won"), "") as String
	var col := Color("2e9e4f") if won else Color("c0392b")
	draw_string(font, Vector2(2, 142), title, HORIZONTAL_ALIGNMENT_CENTER, 960, 64, Color(0, 0, 0, 0.35))
	draw_string(font, Vector2(0, 140), title, HORIZONTAL_ALIGNMENT_CENTER, 960, 64, col)
	var st := StageData.at(Session.stage)
	draw_string(font, Vector2(0, 190), "%s  ·  %s  ·  %s" % [st.name, CarStats.by_id(Session.car_id).name, SeasonPalette.label(Session.season)], HORIZONTAL_ALIGNMENT_CENTER, 960, 24, Color("23323f"))
	var stars := _stars()
	for i in 3:
		var c := Vector2(380 + i * 100, 270)
		var on := i < stars
		var pts := PackedVector2Array()
		for k in 10:
			var rad := 40.0 if k % 2 == 0 else 17.0
			var a := -PI / 2.0 + k * PI / 5.0
			pts.append(c + Vector2(cos(a), sin(a)) * rad)
		draw_colored_polygon(pts, Color("f6c21b") if on else Color(0, 0, 0, 0.2))
	var detail := ""
	if won:
		detail = "Czas przejazdu %s   ·   zostało %s" % [Hud.format_time(r.elapsed), Hud.format_time(r.time_left)]
	else:
		detail = "Spróbuj jeszcze raz: tankuj na stacjach i unikaj zderzeń"
	draw_string(font, Vector2(0, 360), detail, HORIZONTAL_ALIGNMENT_CENTER, 960, 26, Color("23323f"))
	draw_string(font, Vector2(0, 450), "Enter: jeszcze raz        Esc: menu", HORIZONTAL_ALIGNMENT_CENTER, 960, 28, Color.WHITE)
	if won and Session.stage < StageData.COUNT - 1:
		draw_string(font, Vector2(0, 490), "N: następny odcinek (%s)" % StageData.at(Session.stage + 1).name, HORIZONTAL_ALIGNMENT_CENTER, 960, 22, Color("23323f"))

func _process(dt: float) -> void:
	age += dt

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo) or age < 0.8:
		return # ignore keys right after the race (the child may still be mashing the brake)
	if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
		get_tree().change_scene_to_file("res://src/scenes/game.tscn")
	elif event.keycode == KEY_ESCAPE or event.keycode == KEY_M:
		get_tree().change_scene_to_file("res://src/scenes/menu.tscn")
	elif event.keycode == KEY_N and r.get("state", "") == "won" and Session.stage < StageData.COUNT - 1:
		Session.stage += 1
		get_tree().change_scene_to_file("res://src/scenes/game.tscn")
