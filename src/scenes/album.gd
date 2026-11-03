extends Node2D
## The postcard album, one country at a time: every city on its map, biggest first. Postcards not collected yet are
## grey and do not name their landmarks; collected ones are in colour, postmarked, with their stamps under them.
## Opened from the car screen and the map; Esc (or the back button) goes back there.
const COLS := 4
const CARD := Vector2(210, 140)
const CELL := Vector2(228, 178)
const GRID := Rect2(20, 108, 920, 372) ## the scrolling part of the screen
const BACK_BTN := Rect2(24, 490, 148, 44)
var code := ""
var scroll := 0.0
var font: Font
var batch := DrawBatch.new()
var _press := Vector2.ZERO
var _dragging := false

func _ready() -> void:
	font = ThemeDB.fallback_font
	code = Session.country

func _tab_rect(i: int) -> Rect2:
	var w := GRID.size.x / GameData.countries().size()
	return Rect2(GRID.position.x + i * w, 64, w - 8, 34)

func _max_scroll() -> float:
	var rows := ceili(Postcards.cities(code).size() / float(COLS))
	return maxf(0.0, rows * CELL.y - GRID.size.y + 10.0)

func _scroll_by(d: float) -> void:
	scroll = clampf(scroll + d, 0.0, _max_scroll())
	queue_redraw()

func _switch(step: int) -> void:
	var codes := GameData.country_codes()
	code = codes[(codes.find(code) + step + codes.size()) % codes.size()]
	scroll = 0.0
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
	if not (event is InputEventKey and event.pressed):
		return
	if event.keycode == KEY_ESCAPE or event.keycode == KEY_P or event.keycode == KEY_BACKSPACE:
		_back()
	elif event.is_action_pressed("left"): _switch(-1)
	elif event.is_action_pressed("right"): _switch(1)
	elif event.keycode in [KEY_DOWN, KEY_S]: _scroll_by(CELL.y * 0.5)
	elif event.keycode in [KEY_UP, KEY_W]: _scroll_by(-CELL.y * 0.5)
	elif event.keycode == KEY_PAGEDOWN: _scroll_by(GRID.size.y)
	elif event.keycode == KEY_PAGEUP: _scroll_by(-GRID.size.y)

func _tap(p: Vector2) -> void:
	if BACK_BTN.has_point(p):
		_back()
		return
	var codes := GameData.country_codes()
	for i in codes.size():
		if _tab_rect(i).has_point(p) and codes[i] != code:
			_switch(i - codes.find(code))
			return

func _draw() -> void:
	var pal := Weather.palette("sun")
	draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(960, 0), Vector2(960, 540), Vector2(0, 540)]),
		PackedColorArray([pal.sky_top, pal.sky_top, pal.sky_bottom, pal.sky_bottom]))
	draw_rect(GRID.grow(6), Color("2c3e50"))
	var cards := Session.postcards_of(code)
	var ids := Postcards.cities(code)
	batch.begin(self)
	for i in ids.size():
		var cell := Vector2(GRID.position.x + (i % COLS) * CELL.x + (CELL.x - CARD.x) * 0.5, GRID.position.y + 8.0 + (i / COLS) * CELL.y - scroll)
		if cell.y + CELL.y < GRID.position.y - 10.0 or cell.y > GRID.end.y + 10.0:
			continue # off screen
		var r := Rect2(cell, CARD)
		var card: Dictionary = cards.get(ids[i], {})
		var got := not card.is_empty()
		PostcardPainter.card(self, batch, r, code, ids[i], 0.0 if got else 1.0, got)
		if got:
			PostcardPainter.postmark(self, r.position + Vector2(r.size.x - 34, 34), 24.0, PostcardPainter.caption(code, ids[i])[0], int(card.get("year", 0)), 1.0)
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
