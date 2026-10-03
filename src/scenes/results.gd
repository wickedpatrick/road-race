extends Node2D
var font: Font
var r: Dictionary
var age := 0.0

func _ready() -> void:
	font = ThemeDB.fallback_font
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
	draw_string(font, Vector2(0, 190), "%s (%d km)  ·  %s  ·  %s" % [r.get("name", ""), r.get("km", 0), CarStats.by_id(Session.car_id).name, SeasonPalette.label(Session.season)], HORIZONTAL_ALIGNMENT_CENTER, 960, 24, Color("23323f"))
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
		detail = "Wskazówka: tankuj na stacjach, jedź ok. 90 km/h i unikaj zderzeń"
	draw_string(font, Vector2(0, 360), detail, HORIZONTAL_ALIGNMENT_CENTER, 960, 26, Color("23323f"))
	draw_string(font, Vector2(0, 392), "+%d km   ·   razem przejechane: %d km" % [int(r.get("km_driven", 0.0)), int(Session.total_km)], HORIZONTAL_ALIGNMENT_CENTER, 960, 20, Color("23323f"))
	var unlocked: Array = r.get("unlocked", [])
	if not unlocked.is_empty():
		var names := []
		for id in unlocked: names.append(CarStats.by_id(id).name)
		draw_rect(Rect2(180, 432, 600, 34), Color(0.1, 0.5, 0.2, 0.85))
		draw_string(font, Vector2(0, 457), "Nowe auto odblokowane: %s!" % ", ".join(names), HORIZONTAL_ALIGNMENT_CENTER, 960, 22, Color.WHITE)
	var fines: int = r.get("fines", 0)
	if fines > 0:
		draw_string(font, Vector2(0, 420), "Mandaty za prędkość: %d" % fines, HORIZONTAL_ALIGNMENT_CENTER, 960, 22, Color("c0392b"))
	draw_string(font, Vector2(0, 506), "Naciśnij dowolny klawisz, aby wrócić do mapy", HORIZONTAL_ALIGNMENT_CENTER, 960, 26, Color.WHITE)

func _process(dt: float) -> void:
	age += dt

func _unhandled_input(event: InputEvent) -> void:
	var pressed := (event is InputEventKey or event is InputEventMouseButton) and event.is_pressed() and not event.is_echo()
	if not pressed or age < 0.8:
		return # ignore keys right after the race (the child may still be mashing the brake)
	# back to the map; after arriving, the destination is preselected as the new start
	if r.get("state", "") == "won":
		Session.from_city = Session.to_city
	Session.menu_at_map = true
	get_tree().change_scene_to_file("res://src/scenes/menu.tscn")
