extends Node2D
## The postcard album, one country at a time: every city on its map, biggest first, then the routes between them
## (bigger city first) with the postcards of the towns on the way, folded until their title is clicked. Postcards
## not collected yet are grey, darkened and do not name their landmarks; collected ones are in colour and postmarked,
## a city's with its stamps under it, and turn over when clicked: a few words about the landmarks on the back.
## Opened from the car screen and the map; Esc (or the back button) goes back there.
const COLS := 4
const CARD := Vector2(210, 140)
const CELL := Vector2(228, 178)
const TOWN_CELL_H := 158.0 ## no stamps under a town's postcard
const HEAD_H := 46.0 ## a section or route title above its row of postcards
const GRID := Rect2(20, 108, 920, 372) ## the scrolling part of the screen
const BACK_BTN := Rect2(24, 490, 148, 44)
const FLIP_TIME := 0.35 ## seconds to turn a card over
var code := ""
var scroll := 0.0
var font: Font
var batch := DrawBatch.new()
var _press := Vector2.ZERO
var _dragging := false
var _layout: Array = [] ## [{y, card: id, town: bool} or {y, title} or {y, route}], y from the top of the list
var _height := 0.0
var _open := {} ## route key "a|b" -> true: its towns' postcards are shown
var _face := {} ## card key -> 0 (front) .. 1 (back), turning towards _back_key's card
var _back_key := "" ## the one card showing its back ("" none)

func _ready() -> void:
	font = ThemeDB.fallback_font
	code = Session.country
	_lay_out()

## Where everything of this country's album goes: the cities' grid, then each route's title and its towns' grid.
func _lay_out() -> void:
	_layout = []
	var y := 8.0
	var ids := Postcards.cities(code)
	for i in ids.size():
		_layout.append({"x": i % COLS, "y": y + (i / COLS) * CELL.y, "card": ids[i], "town": false, "key": ids[i]})
	y += ceili(ids.size() / float(COLS)) * CELL.y
	var routes := Postcards.routes(code)
	if not routes.is_empty():
		_layout.append({"y": y, "title": Lang.t("album_routes")})
		y += HEAD_H
	for rt in routes:
		var rk := _route_key(rt)
		_layout.append({"y": y, "route": rt})
		y += HEAD_H - 10.0
		if not _open.has(rk):
			continue
		for i in rt.towns.size():
			_layout.append({"x": i % COLS, "y": y + (i / COLS) * TOWN_CELL_H, "card": rt.towns[i], "town": true, "key": rt.towns[i] + "|" + rk})
		y += ceili(rt.towns.size() / float(COLS)) * TOWN_CELL_H
	_height = y

static func _route_key(rt: Dictionary) -> String:
	return rt.a + "|" + rt.b

## Screen rectangle of a laid-out card, or of a route's title row.
func _item_rect(it: Dictionary) -> Rect2:
	var y: float = GRID.position.y + it.y - scroll
	if it.has("route"):
		return Rect2(GRID.position.x, y, GRID.size.x, HEAD_H - 10.0)
	return Rect2(Vector2(GRID.position.x + it.x * CELL.x + (CELL.x - CARD.x) * 0.5, y), CARD)

func _process(dt: float) -> void:
	var moving := false
	for k in _face.keys():
		var want := 1.0 if k == _back_key else 0.0
		_face[k] = move_toward(_face[k], want, dt / FLIP_TIME)
		if _face[k] == 0.0 and want == 0.0: _face.erase(k)
		else: moving = moving or _face[k] != want
	if moving: queue_redraw()

func _tab_rect(i: int) -> Rect2:
	var w := GRID.size.x / GameData.countries().size()
	return Rect2(GRID.position.x + i * w, 64, w - 8, 34)

func _max_scroll() -> float:
	return maxf(0.0, _height - GRID.size.y + 10.0)

func _scroll_by(d: float) -> void:
	scroll = clampf(scroll + d, 0.0, _max_scroll())
	queue_redraw()

func _switch(step: int) -> void:
	var codes := GameData.country_codes()
	code = codes[(codes.find(code) + step + codes.size()) % codes.size()]
	scroll = 0.0
	_open = {}
	_face = {}
	_back_key = ""
	_lay_out()
	Sfx.play("blip", -8.0)
	queue_redraw()

func _back() -> void:
	Sfx.play("blip", -8.0)
	Session.menu_at_map = Session.album_back_to_map
	get_tree().change_scene_to_file("res://src/scenes/menu.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed: _scroll_by(60.0)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed: _scroll_by(-60.0)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_press = event.position
				_dragging = false
			elif not _dragging:
				_tap(event.position)
		return
	if event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		if _dragging or event.position.distance_to(_press) > 8.0:
			_dragging = true
			_scroll_by(-event.relative.y)
		return
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if event.keycode == KEY_ESCAPE or event.keycode == KEY_P or event.keycode == KEY_BACKSPACE:
		_back()
	elif event.is_action_pressed("left"): _switch(-1)
	elif event.is_action_pressed("right"): _switch(1)
	elif event.keycode in [KEY_DOWN, KEY_S]: _scroll_by(CELL.y * 0.5)
	elif event.keycode in [KEY_UP, KEY_W]: _scroll_by(-CELL.y * 0.5)
	elif event.keycode == KEY_PAGEDOWN: _scroll_by(GRID.size.y)
	elif event.keycode == KEY_PAGEUP: _scroll_by(-GRID.size.y)

## "▸ Kraków – Rzeszów   1/2": a city's name bright when its postcard is collected, the towns' postcards collected
## of all, the arrow down while the route is unfolded.
func _route_title(rt: Dictionary, cards: Dictionary, pos: Vector2) -> void:
	var open := _open.has(_route_key(rt))
	var a := pos + Vector2(6, -8)
	var tri := PackedVector2Array([a + Vector2(-5, -5), a + Vector2(5, -5), a + Vector2(0, 4)]) if open \
		else PackedVector2Array([a + Vector2(-4, -7), a + Vector2(5, -1.5), a + Vector2(-4, 4)])
	draw_colored_polygon(tri, Color("ffd24a"))
	var x := pos.x + 20.0
	for part in [rt.a, " – ", rt.b]:
		var text: String = part if part == " – " else PostcardPainter.caption(code, part)[0]
		var col := Color("c8d6e3") if part == " – " else (Color("ffd24a") if cards.has(part) else Color("8a97a3"))
		draw_string(font, Vector2(x, pos.y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, col)
		x += font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x
	var got: int = rt.towns.filter(func(tn): return cards.has(tn)).size()
	draw_string(font, Vector2(x + 16, pos.y), "%d/%d" % [got, rt.towns.size()], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("ffd24a") if got == rt.towns.size() else Color("c8d6e3"))

func _tap(p: Vector2) -> void:
	if BACK_BTN.has_point(p):
		_back()
		return
	var codes := GameData.country_codes()
	for i in codes.size():
		if _tab_rect(i).has_point(p) and codes[i] != code:
			_switch(i - codes.find(code))
			return
	if not GRID.has_point(p):
		return
	var cards := Session.postcards_of(code)
	for it in _layout:
		if it.has("title") or not _item_rect(it).has_point(p): continue
		if it.has("route"): # fold or unfold the route's postcards
			var rk := _route_key(it.route)
			if _open.has(rk): _open.erase(rk)
			else: _open[rk] = true
			Sfx.play("blip", -10.0)
			_lay_out()
			scroll = clampf(scroll, 0.0, _max_scroll())
		elif cards.has(it.card): # turn a collected card over (and the one turned before back)
			_back_key = "" if _back_key == it.key else it.key
			_face[it.key] = _face.get(it.key, 0.0)
			Sfx.play("blip", -12.0)
		queue_redraw()
		return

func _draw() -> void:
	var pal := Weather.palette("sun")
	draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(960, 0), Vector2(960, 540), Vector2(0, 540)]),
		PackedColorArray([pal.sky_top, pal.sky_top, pal.sky_bottom, pal.sky_bottom]))
	draw_rect(GRID.grow(6), Color("2c3e50"))
	var cards := Session.postcards_of(code)
	batch.begin(self)
	for it in _layout:
		var y: float = GRID.position.y + it.y - scroll
		if y + CELL.y < GRID.position.y - 10.0 or y > GRID.end.y + 10.0:
			continue # off screen
		if it.has("title"):
			batch.flush()
			draw_string(font, Vector2(GRID.position.x + 10, y + 32), it.title, HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color.WHITE)
		elif it.has("route"):
			batch.flush()
			_route_title(it.route, cards, Vector2(GRID.position.x + 10, y + 26))
		else:
			var r := _item_rect(it)
			var card: Dictionary = cards.get(it.card, {})
			var got := not card.is_empty()
			var f: float = _face.get(it.key, 0.0)
			if f > 0.0:
				batch.flush()
				if f >= 1.0:
					PostcardPainter.back(self, r, code, it.card, int(card.get("year", 0)))
				else: # turning over: the paper narrows to its edge and widens again
					var w := absf(cos(PI * f)) * r.size.x
					PostcardPainter.paper(self, Rect2(r.position.x + (r.size.x - w) * 0.5, r.position.y, maxf(w, 2.0), r.size.y))
				if not it.town:
					PostcardPainter.stamp_row(self, Vector2(r.get_center().x, r.end.y + 15), 15.0, int(card.stamps), 5.0)
				continue
			PostcardPainter.card(self, batch, r, code, it.card, 0.0 if got else 1.0, got)
			if not got:
				PostcardPainter.cover(batch, PostcardPainter.picture(r))
			if got:
				PostcardPainter.postmark(self, r.position + Vector2(r.size.x - 34, 34), 24.0, PostcardPainter.caption(code, it.card)[0], int(card.get("year", 0)), 1.0)
				if not it.town:
					PostcardPainter.stamp_row(self, Vector2(r.get_center().x, r.end.y + 15), 15.0, int(card.stamps), 5.0)
	batch.flush()
	# the bars above and below the grid cover the cards scrolled out of it
	draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(960, 0), Vector2(960, GRID.position.y - 6), Vector2(0, GRID.position.y - 6)]),
		PackedColorArray([pal.sky_top, pal.sky_top, pal.sky_top.lerp(pal.sky_bottom, 0.2), pal.sky_top.lerp(pal.sky_bottom, 0.2)]))
	draw_rect(Rect2(0, GRID.end.y + 6, 960, 540 - GRID.end.y - 6), pal.sky_bottom)
	draw_string(font, Vector2(24, 46), Lang.t("album"), HORIZONTAL_ALIGNMENT_LEFT, -1, 36, Color.WHITE)
	var sm := Postcards.summary(code, cards)
	draw_string(font, Vector2(0, 46), Lang.t("album_stamps") % [sm.stamps, sm.max], HORIZONTAL_ALIGNMENT_RIGHT, 936, 24, Color("ffd24a"))
	var countries := GameData.countries()
	for i in countries.size():
		var c: Dictionary = countries[i]
		var s := Postcards.summary(c.code, Session.postcards_of(c.code))
		Ui.button(self, font, _tab_rect(i), "%s  %d/%d" % [c.name, s.earned, s.all], c.code == code, 15)
	if _max_scroll() > 0.0: # where in the list we are
		var h := GRID.size.y * GRID.size.y / (GRID.size.y + _max_scroll())
		var y := GRID.position.y + (GRID.size.y - h) * scroll / _max_scroll()
		draw_rect(Rect2(GRID.end.x + 2, y, 4, h), Color(1, 1, 1, 0.6))
	draw_rect(Rect2(0, 486, 960, 54), Color(0, 0, 0, 0.5))
	Ui.button(self, font, BACK_BTN, Lang.t("back"), false, 20)
	if not Screen.touch:
		draw_string(font, Vector2(0, 518), Lang.t("album_hint"), HORIZONTAL_ALIGNMENT_RIGHT, 936, 20, Color.WHITE)
