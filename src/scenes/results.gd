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
## a won trip's road rankings, right of the postcard: each road's time, place and the best time; the button (or R)
## opens the ranking tables (src/scenes/ranking.gd)
const RANK_PANEL := Rect2(668, 112, 282, 228)
const RANK_BTN := Rect2(700, 296, 218, 38)
const RANK_ROWS := 3

func _ready() -> void:
	font = ThemeDB.fallback_font
	r = Session.last_result
	if r.get("seen", false): # back from the ranking: no animation again
		age = 99.0

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
	if pc.get("faster_car", "") != "":
		_banner(banner_y, ys.banner_h, Lang.t("stamp_faster_car") % CarStats.by_id(pc.faster_car).name, Color(0.55, 0.15, 0.15, 0.85))
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
	_draw_rankings()
	draw_string(font, Vector2(0, 530), Lang.t("back_touch") if Screen.touch else Lang.t("back_key"), HORIZONTAL_ALIGNMENT_CENTER, 960, 22 if pc.is_empty() else 18, Color.WHITE)

func _ranking_rows() -> Array:
	return r.get("rankings", []) if r.get("state", "") == "won" else []

func _draw_rankings() -> void:
	var rows := _ranking_rows()
	if rows.is_empty():
		return
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.06, 0.09, 0.13, 0.82)
	bg.set_corner_radius_all(12)
	draw_style_box(bg, RANK_PANEL)
	var x := RANK_PANEL.position.x + 12
	var w := RANK_PANEL.size.x - 24
	var head := Lang.t("rankings") + ("  (+%d)" % (rows.size() - RANK_ROWS) if rows.size() > RANK_ROWS else "")
	draw_string(font, Vector2(x, RANK_PANEL.position.y + 26), head, HORIZONTAL_ALIGNMENT_LEFT, w, 20, Color("ffd24a"))
	for i in mini(rows.size(), RANK_ROWS):
		var row: Dictionary = rows[i]
		var y := RANK_PANEL.position.y + 54 + i * 52
		draw_string(font, Vector2(x, y), "%s - %s" % [Geo.display_name(row.from), Geo.display_name(row.to)], HORIZONTAL_ALIGNMENT_LEFT, w, 16, Color.WHITE)
		var best: float = minf(row.top, row.best)
		var line := Lang.t("ranking_row") % [Rankings.time_text(row.t), row.pos, Rankings.time_text(best)]
		var fs := 15
		while fs > 11 and font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x > w:
			fs -= 1
		draw_string(font, Vector2(x, y + 20), line, HORIZONTAL_ALIGNMENT_LEFT, w, fs, Color("7fe0a0") if row.new_best else Color("c8d6e3"))
	Ui.button(self, font, RANK_BTN, Lang.t("ranking_btn") + ("" if Screen.touch else " (R)"), false, 17)

## The ranking tables of the roads just driven; they come back here. `climbing`: going on from here, the first
## time, after a better place on a road: the tables open on it, the climb shown (Top Gear), and going back from
## them goes on to the map.
func _open_ranking(climbing := false) -> void:
	Sfx.play("blip", -15.0)
	var rows := _ranking_rows()
	var climb := {}
	for row in rows:
		if row.pos < row.get("was", row.pos): climb[row.key] = row.was
	var first := rows.find_custom(func(x): return climb.has(x.key)) if climbing else 0
	r["climb_shown"] = true
	Session.ranking_view = {"keys": rows.map(func(x): return x.key), "i": maxi(first, 0), "country": false,
		"back": "continue" if climbing else "results", "climb": climb}
	get_tree().change_scene_to_file("res://src/scenes/ranking.tscn")

func _climbed() -> bool:
	return _ranking_rows().any(func(x): return x.pos < x.get("was", x.pos))

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
	if not _ranking_rows().is_empty():
		var tp = Ui.tap(event)
		if (tp != null and RANK_BTN.has_point(tp)) or (event is InputEventKey and event.keycode == KEY_R):
			_open_ranking()
			return
	if _climbed() and not r.get("climb_shown", false):
		_open_ranking(true)
		return
	# back to the map; after arriving, the destination is preselected as the new start
	if r.get("state", "") == "won":
		Session.from_city = Session.to_city
	Session.menu_at_map = true
	get_tree().change_scene_to_file("res://src/scenes/menu.tscn")
