extends Node2D
## The rankings (Rankings): one road's table (the 100 made-up drivers and the player, with car and time) or the
## country's fastest driver (sums over every road); LINES rows of it: the top ones, or the podium and the rows
## around the player when the player is further down. A road the player has just climbed on (view.climb: key ->
## the place before, DRIVERS + 1 the first time) shows the climb as in Top Gear: the player's row starts on the old
## place and glides up the table, the others stepping down as it passes, until it settles on the new one. Session.ranking_view says which roads to page through and where
## to go back. Arrows / the < > buttons: the previous or next road; C or the button: road <-> country; Esc, Enter or
## the back button: back to the map (or the trip's results).
const PANEL := Rect2(120, 92, 720, 390)
const ROW_H := 17.6
const LINES := 21
const PREV_BTN := Rect2(24, 490, 64, 44)
const NEXT_BTN := Rect2(96, 490, 64, 44)
const MODE_BTN := Rect2(624, 490, 160, 44)
const BACK_BTN := Rect2(792, 490, 148, 44)
var font: Font
var view := {}
var rows: Array = []
var climb := {} ## the climb being shown: {from, to (row indexes), t (seconds into it), dur}; {} none
var _pf := -1.0 ## the player's row, a fractional index while climbing

func _ready() -> void:
	Sfx.music(true)
	font = ThemeDB.fallback_font
	view = Session.ranking_view
	if (view.get("keys", []) as Array).is_empty():
		view = {"keys": Rankings.keys(Session.country), "i": 0, "country": false, "back": "menu"}
	_build()

func _keys() -> Array:
	return view.keys

func _key() -> String:
	return _keys()[clampi(view.get("i", 0), 0, _keys().size() - 1)]

func _build() -> void:
	if view.get("country", false):
		rows = Rankings.country_table(Session.country, Session.my_rankings())
	else:
		rows = Rankings.table(Session.country, _key(), Session.my_rankings().get(_key(), {}))
	climb = {}
	var climbs: Dictionary = view.get("climb", {})
	var me := rows.find_custom(func(r): return r.get("me", false))
	if not view.get("country", false) and climbs.has(_key()) and me >= 0:
		var from := mini(int(climbs[_key()]), rows.size()) - 1
		climbs.erase(_key()) # once
		if from > me:
			# Top Gear's pace: slow off the mark, quick through the middle, easing onto the new place
			climb = {"from": float(from), "to": float(me), "t": -0.4, "dur": clampf(1.2 + 0.05 * (from - me), 1.5, 5.0) * 0.7}
			_pf = from
	view.climbed = _key() if not climb.is_empty() else "" # the table stays around the player after the climb
	queue_redraw()

func _process(dt: float) -> void:
	if climb.is_empty():
		return
	climb.t += dt
	var k := smoothstep(0.0, 1.0, clampf(climb.t / climb.dur, 0.0, 1.0))
	var was := _pf
	_pf = lerpf(climb.from, climb.to, k)
	if roundi(_pf) != roundi(was):
		Sfx.play("blip", -20.0, 1.0 + 0.6 * (1.0 - (_pf - climb.to) / maxf(climb.from - climb.to, 1.0))) # a tick per place passed, higher towards the end
	if climb.t >= climb.dur:
		_pf = climb.to
		Sfx.play("refuel_done", -10.0)
		climb = {}
	queue_redraw()

static func road_name(k: String) -> String:
	var ab := k.split("|")
	return "%s - %s" % [Geo.display_name(ab[0]), Geo.display_name(ab[1])]

func _t(pos: Vector2, text: String, size: int, col: Color, align := HORIZONTAL_ALIGNMENT_LEFT, width := -1.0) -> void:
	draw_string(font, pos, text, align, width, size, col)

func _draw() -> void:
	var pal := Weather.palette("sun")
	draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(960, 0), Vector2(960, 540), Vector2(0, 540)]),
		PackedColorArray([pal.sky_top, pal.sky_top, pal.sky_bottom, pal.sky_bottom]))
	var country: bool = view.get("country", false)
	var title := Lang.t("ranking_country") % GameData.country().name if country else Lang.t("ranking_road")
	_t(Vector2(2, 44), title, 34, Color(0, 0, 0, 0.3), HORIZONTAL_ALIGNMENT_CENTER, 960)
	_t(Vector2(0, 42), title, 34, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, 960)
	var sub := ""
	if country:
		sub = Lang.t("ranking_roads") % [Rankings.keys(Session.country).size(), Rankings.keys(Session.country).size()]
	else:
		var rd := Rankings.road(Session.country, _key())
		sub = "%s (%s)" % [road_name(_key()), Units.dist_text(rd.get("km", 0))]
		if _keys().size() > 1:
			sub += "   %d/%d" % [int(view.i) + 1, _keys().size()]
	_t(Vector2(0, 76), sub, 22, Color("1d2b38"), HORIZONTAL_ALIGNMENT_CENTER, 960)
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.06, 0.09, 0.13, 0.85)
	bg.set_corner_radius_all(14)
	draw_style_box(bg, PANEL)
	var x := PANEL.position.x + 20
	var y := PANEL.position.y + 22
	var all := Rankings.keys(Session.country).size()
	var me_found := false
	if not climb.is_empty() or view.get("climbed", "") == _key():
		_draw_climb(x, y)
		_draw_bar(country)
		return
	var shown := Rankings.shown(rows, LINES)
	for li in shown.size():
		var i: int = shown[li]
		var yy := y + li * ROW_H
		if i < 0:
			_t(Vector2(x + 44, yy), "...", 16, Color("c8d6e3"))
			continue
		var r: Dictionary = rows[i]
		var me: bool = r.get("me", false)
		if me:
			me_found = true
			draw_rect(Rect2(PANEL.position.x + 8, yy - 14, PANEL.size.x - 16, ROW_H), Color("ffd24a", 0.9))
		var col := Color("1d2b38") if me else (Color("ffd24a") if i < 3 else Color.WHITE)
		_t(Vector2(x, yy), "%d." % (i + 1), 16, col, HORIZONTAL_ALIGNMENT_RIGHT, 30)
		_t(Vector2(x + 44, yy), Lang.t("ranking_you") if me else r.nick, 16, col)
		if country:
			var full: bool = r.roads >= all
			_t(Vector2(x + 300, yy), Lang.t("ranking_roads") % [r.roads, all], 16, col if full else (Color("7a2a1f") if me else Color("ff9a86")))
		elif r.car != "":
			_t(Vector2(x + 300, yy), CarStats.by_id(r.car).name if CarStats.has(r.car) else r.car, 16, col)
		_t(Vector2(x + 520, yy), Rankings.time_text(r.t), 16, col, HORIZONTAL_ALIGNMENT_RIGHT, 160)
	if not me_found and not country:
		_t(Vector2(PANEL.position.x, PANEL.end.y - 8), Lang.t("ranking_no_time"), 15, Color("c8d6e3"), HORIZONTAL_ALIGNMENT_CENTER, PANEL.size.x)
	_draw_bar(country)

## One row of a road's table at the baseline yy: the place, the nick, the car and the time.
func _row(x: float, yy: float, place: int, r: Dictionary) -> void:
	var me: bool = r.get("me", false)
	if me: # opaque: gliding over the rows it passes
		draw_rect(Rect2(PANEL.position.x + 8, yy - 14, PANEL.size.x - 16, ROW_H), Color("ffd24a"))
	var col := Color("1d2b38") if me else (Color("ffd24a") if place <= 3 else Color.WHITE)
	_t(Vector2(x, yy), "%d." % place, 16, col, HORIZONTAL_ALIGNMENT_RIGHT, 30)
	_t(Vector2(x + 44, yy), Lang.t("ranking_you") if me else r.nick, 16, col)
	if r.car != "":
		_t(Vector2(x + 300, yy), CarStats.by_id(r.car).name if CarStats.has(r.car) else r.car, 16, col)
	_t(Vector2(x + 520, yy), Rankings.time_text(r.t), 16, col, HORIZONTAL_ALIGNMENT_RIGHT, 160)

## The climb (and the table after it, still around the player): LINES rows following the player's row at _pf, each
## other row one place lower once the player has passed it.
func _draw_climb(x: float, y: float) -> void:
	var others := rows.filter(func(r): return not r.get("me", false))
	var me: Dictionary = rows[rows.find_custom(func(r): return r.get("me", false))]
	var top := clampf(_pf - LINES / 2, 0.0, maxf(rows.size() - LINES, 0.0))
	for j in others.size():
		var slot := j + clampf(j + 1 - _pf, 0.0, 1.0)
		if slot - top > -0.5 and slot - top < LINES - 0.5:
			_row(x, y + (slot - top) * ROW_H, roundi(slot) + 1, others[j])
	_row(x, y + (_pf - top) * ROW_H, roundi(_pf) + 1, me)

func _draw_bar(country: bool) -> void:
	draw_rect(Rect2(0, 486, 960, 54), Color(0, 0, 0, 0.5))
	if not country and _keys().size() > 1:
		Ui.button(self, font, PREV_BTN, "<", false, 24)
		Ui.button(self, font, NEXT_BTN, ">", false, 24)
	Ui.button(self, font, MODE_BTN, Lang.t("ranking_road_btn") if country else Lang.t("ranking_country_btn"), false, 18)
	Ui.button(self, font, BACK_BTN, Lang.t("back"), true, 20)
	if not Screen.touch:
		_t(Vector2(176, 518), Lang.t("ranking_hint"), 16, Color.WHITE)

func _page(d: int) -> void:
	if view.get("country", false) or _keys().size() < 2:
		return
	Sfx.play("blip", -15.0)
	view.i = (int(view.i) + d + _keys().size()) % _keys().size()
	_build()

func _toggle() -> void:
	Sfx.play("blip", -15.0)
	view.country = not view.get("country", false)
	_build()

func _back() -> void:
	Sfx.play("blip", -15.0)
	Session.ranking_view = {}
	if view.get("back", "menu") == "continue": # after a won trip's climb: on to the map, from the destination
		Session.from_city = Session.to_city
		Session.menu_at_map = true
		get_tree().change_scene_to_file("res://src/scenes/menu.tscn")
	elif view.get("back", "menu") == "results":
		Session.last_result["seen"] = true # no postcard animation again
		get_tree().change_scene_to_file("res://src/scenes/results.tscn")
	else:
		Session.menu_at_map = true
		get_tree().change_scene_to_file("res://src/scenes/menu.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if not climb.is_empty() and (event is InputEventKey or event is InputEventMouseButton or event is InputEventScreenTouch) and event.is_pressed():
		climb.t = climb.dur # a key or a tap during the climb: straight onto the new place
		get_viewport().set_input_as_handled()
		return
	var tp = Ui.tap(event)
	if tp != null:
		if PREV_BTN.has_point(tp): _page(-1)
		elif NEXT_BTN.has_point(tp): _page(1)
		elif MODE_BTN.has_point(tp): _toggle()
		elif BACK_BTN.has_point(tp): _back()
		return
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if event.is_action_pressed("left") or event.keycode == KEY_UP: _page(-1)
	elif event.is_action_pressed("right") or event.keycode == KEY_DOWN: _page(1)
	elif event.keycode == KEY_C or event.keycode == KEY_TAB: _toggle()
	elif event.keycode in [KEY_ESCAPE, KEY_ENTER, KEY_KP_ENTER, KEY_SPACE, KEY_BACKSPACE, KEY_R]: _back()
