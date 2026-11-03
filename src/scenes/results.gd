extends Node2D
var font: Font
var r: Dictionary
var age := 0.0
var batch := DrawBatch.new()
## a won trip shows the destination's postcard: a new one goes from grey to colour, gets its postmark, then the
## stamps are struck one by one; one collected before is in colour at once and only gets its new stamps
const CARD := Rect2(305, 112, 350, 228)
const COLOUR_AT := 0.8 ## s: grey -> colour (new postcard)
const COLOUR_TIME := 0.8
const POSTMARK_AT := 2.0
const POSTMARK_TIME := 0.25
const STAMPS_AT := 2.6 ## the first new stamp (0.6 s on a postcard collected before)
const STAMPS_AT_OLD := 0.6
const STAMP_EVERY := 0.3

func _ready() -> void:
	font = ThemeDB.fallback_font
	r = Session.last_result

## How far the stamps are struck: the stamps the postcard had, plus the new ones as they drop in (fractions).
func _struck(pc: Dictionary) -> float:
	var t0 := STAMPS_AT if pc.before == 0 else STAMPS_AT_OLD
	return pc.before + clampf((age - t0) / STAMP_EVERY, 0.0, pc.after - pc.before)

func _draw_postcard(pc: Dictionary) -> void:
	var fresh: bool = pc.before == 0
	var gray := clampf(1.0 - (age - COLOUR_AT) / COLOUR_TIME, 0.0, 1.0) if fresh else 0.0
	batch.begin(self)
	PostcardPainter.card(self, batch, CARD, Session.country, pc.city, gray, not fresh or age >= COLOUR_AT + COLOUR_TIME * 0.5)
	var k := clampf((age - POSTMARK_AT) / POSTMARK_TIME, 0.0, 1.0) if fresh else 1.0
	if k > 0.0:
		var year: int = Session.postcards.get(pc.city, {}).get("year", 0)
		PostcardPainter.postmark(self, CARD.position + Vector2(CARD.size.x - 58, 58), 44.0, PostcardPainter.caption(Session.country, pc.city)[0], year, k, lerpf(2.2, 1.0, k))
	PostcardPainter.stamp_row(self, Vector2(CARD.get_center().x, CARD.end.y + 30), 26.0, pc.after, _struck(pc))

func _draw() -> void:
	var pal := Weather.palette(r.get("weather", "sun"))
	draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(960, 0), Vector2(960, 540), Vector2(0, 540)]),
		PackedColorArray([pal.sky_top, pal.sky_top, pal.sky_bottom, pal.sky_bottom]))
	var won: bool = r.get("state", "") == "won"
	var title := Lang.t({"won": "won", "out_of_time": "time_up", "out_of_fuel": "fuel_out"}.get(r.get("state", "won"), "won"))
	var col := Color("2e9e4f") if won else Color("c0392b")
	var top := 64.0 if r.has("postcard") else 140.0
	draw_string(font, Vector2(2, top + 2), title, HORIZONTAL_ALIGNMENT_CENTER, 960, 56 if r.has("postcard") else 64, Color(0, 0, 0, 0.35))
	draw_string(font, Vector2(0, top), title, HORIZONTAL_ALIGNMENT_CENTER, 960, 56 if r.has("postcard") else 64, col)
	draw_string(font, Vector2(0, top + 36 if r.has("postcard") else 190), "%s (%s)  ·  %s  ·  %s" % [r.get("name", ""), Units.dist_text(r.get("km", 0)), CarStats.by_id(Session.car_id).name, Weather.label(r.get("weather", "sun"))], HORIZONTAL_ALIGNMENT_CENTER, 960, 24, Color("23323f"))
	var pc: Dictionary = r.get("postcard", {})
	# the lines under the postcard (or where the stars used to be): detail, kilometres, fines, banners
	var ys := {"detail": 360.0, "total": 392.0, "fines": 420.0, "banner": 432.0, "banner_h": 34.0}
	if not pc.is_empty():
		_draw_postcard(pc)
		ys = {"detail": 412.0, "total": 435.0, "fines": 435.0, "banner": 448.0, "banner_h": 27.0}
	var detail := ""
	if won:
		detail = Lang.t("trip_result") % [Hud.format_time(r.elapsed), Hud.format_time(r.time_left)]
	else:
		detail = Lang.t("tip") % Units.speed_text(90.0)
	draw_string(font, Vector2(0, ys.detail), detail, HORIZONTAL_ALIGNMENT_CENTER, 960, 26 if pc.is_empty() else 22, Color("23323f"))
	var fines: int = r.get("fines", 0)
	var total_w := 960.0 if fines == 0 or pc.is_empty() else 640.0 # beside the fines under a postcard
	draw_string(font, Vector2(0, ys.total), Lang.t("total_driven") % [Units.dist_text(r.get("km_driven", 0.0)), Units.dist_text(Session.total_km)], HORIZONTAL_ALIGNMENT_CENTER, total_w, 20, Color("23323f"))
	if fines > 0:
		draw_string(font, Vector2(total_w if not pc.is_empty() else 0.0, ys.fines), Lang.t("fines") % fines, HORIZONTAL_ALIGNMENT_CENTER if pc.is_empty() else HORIZONTAL_ALIGNMENT_LEFT, -1 if not pc.is_empty() else 960, 20 if not pc.is_empty() else 22, Color("c0392b"))
	var banner_y: float = ys.banner
	var unlocked: Array = r.get("unlocked", [])
	if not unlocked.is_empty():
		var names := []
		for id in unlocked: names.append(CarStats.by_id(id).name)
		_banner(banner_y, ys.banner_h, Lang.t("new_car") % ", ".join(names), Color(0.1, 0.5, 0.2, 0.85))
		banner_y += ys.banner_h + 4.0
	if pc.get("faster_car", false):
		_banner(banner_y, ys.banner_h, Lang.t("stamp_faster_car") % CarStats.by_id(Postcards.first_top_stamp_car()).name, Color(0.55, 0.15, 0.15, 0.85))
		banner_y += ys.banner_h + 4.0
	var cities: Array = r.get("new_cities", [])
	if not cities.is_empty():
		var names := []
		for id in cities: names.append(Geo.display_name(id))
		var n := Session.visited.size()
		var text := Lang.t("new_city") % [", ".join(names), n, Geo.cities().size()]
		if n >= Geo.cities().size():
			text = Lang.t("all_cities") % n
		_banner(banner_y, ys.banner_h, text, Color(0.75, 0.55, 0.05, 0.9))
	draw_string(font, Vector2(0, 530), Lang.t("back_touch") if Screen.touch else Lang.t("back_key"), HORIZONTAL_ALIGNMENT_CENTER, 960, 22 if pc.is_empty() else 18, Color.WHITE)

func _banner(y: float, h: float, text: String, col: Color) -> void:
	draw_rect(Rect2(150, y, 660, h), col)
	draw_string(font, Vector2(0, y + h * 0.5 + 8), text, HORIZONTAL_ALIGNMENT_CENTER, 960, 22 if h > 32.0 else 18, Color.WHITE)

func _process(dt: float) -> void:
	var pc: Dictionary = r.get("postcard", {})
	if not pc.is_empty():
		var before := _struck(pc)
		var was := age
		age += dt
		if pc.before == 0 and was < POSTMARK_AT and age >= POSTMARK_AT:
			Sfx.play("hit", -8.0)
		if floorf(_struck(pc)) > floorf(before):
			Sfx.play("blip", -6.0)
		queue_redraw()
	else:
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
