extends Node2D
## Picking the country to play on a map of Europe (with a piece of Asia) and, small across the sea on the left,
## North America (data/world.json, made by tools/make_world.py). Countries in the game are green with their flag in
## the middle; the ones planned but not in the game yet are grey, striped and marked "coming soon"; any other land
## has no borders at all. Names show in the header and in a tooltip by the cursor (or the tap).
## A country in the game but not open to the player yet (Session.is_country_open) is a darker green with a padlock
## by its flag; picking it offers it for sale (Shop `country_one`), Enter buys it and plays it.
## Opened from the map in the menu (the country button, C) or from the shop (to buy one); Esc goes back without a change.
const SEA := Color("2c5d86")
const LAND := Color("c4b893") ## land of countries not in the plan, without borders
const PLANNED := Color("b4b9bd")
const PLANNED_EDGE := Color("7d858c")
const PLAYABLE := Color("8fd16a")
const PLAYABLE_EDGE := Color("2f6b2a")
const LOCKED := Color("7d8a74") ## in the game, not open yet: a greyish green
const CURRENT := Color("ffd24a")
const STRIPE := Color("969ca1")
const STRIPE_GAP := 7.0 ## px between the "coming soon" stripes
const BACK_BTN := Rect2(24, 490, 148, 44)
var font: Font
var world: Dictionary
var polys := {} ## code -> [PackedVector2Array, ...]
var land: Array = [] ## PackedVector2Array
var hover := "" ## the playable country under the mouse or picked with the arrows
var hover_soon := "" ## a country not in the game yet under the mouse (or last tapped)
var tip := "" ## the country named in the tooltip by the cursor (or the tap), "" with none or after the arrows
var cursor := Vector2.ZERO ## where the tooltip stands
var stripes := PackedVector2Array() ## segment pairs: diagonal stripes over the countries coming soon
var soon := 0.0 ## seconds left of the "not in the game yet" note
var offer := "" ## a locked country offered for sale (Enter buys, Esc cancels)
const BUY_BTN := Rect2(330, 314, 140, 44)
const CANCEL_BTN := Rect2(490, 314, 140, 44)
var t := 0.0

func _ready() -> void:
	Sfx.music(true)
	font = ThemeDB.fallback_font
	world = GameData.load_json(GameData.DIR + "world.json")
	for code in world.countries:
		polys[code] = world.countries[code].polys.map(func(f): return _pts(f))
	# a map spanning several countries (index.json `members`) is one shape made of theirs, labelled in their middle
	for c in GameData.countries():
		var members: Array = c.get("members", []).filter(func(m): return polys.has(m))
		if members.is_empty(): continue
		var shape := []
		var mid := Vector2.ZERO
		for m in members:
			shape.append_array(polys[m])
			mid += label_pos(m) / members.size()
			polys.erase(m)
		polys[c.code] = shape
		world.countries[c.code] = {"name": c.name, "label": [mid.x, mid.y]}
	land =world.land.map(func(f): return _pts(f))
	hover = Session.country
	_make_stripes()

## Diagonal stripes cut to the shapes of the countries not in the game yet (worked out once: the map stands still).
func _make_stripes() -> void:
	var play := playable()
	for code in polys:
		if play.has(code): continue
		for pts in polys[code]:
			var box := Rect2(pts[0], Vector2.ZERO)
			for v in pts: box = box.expand(v)
			var c0 := floorf((box.position.x + box.position.y) / STRIPE_GAP) * STRIPE_GAP
			var c := c0
			while c < box.end.x + box.end.y: # the line x + y = c, from the box's left edge to its right edge
				var line := PackedVector2Array([Vector2(box.position.x, c - box.position.x), Vector2(box.end.x, c - box.end.x)])
				for seg in Geometry2D.intersect_polyline_with_polygon(line, pts):
					if seg.size() >= 2:
						stripes.append(seg[0])
						stripes.append(seg[seg.size() - 1])
				c += STRIPE_GAP

static func _pts(flat: Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in range(0, flat.size(), 2):
		out.append(Vector2(flat[i], flat[i + 1]))
	return out

## The game's countries that have a shape on the map.
func playable() -> Array:
	return GameData.country_codes().filter(func(c): return polys.has(c))

## The country (in the plan) at screen point p, "" over the sea or other land.
func country_at(p: Vector2) -> String:
	for code in polys:
		for pts in polys[code]:
			if Geometry2D.is_point_in_polygon(p, pts):
				return code
	return ""

## Big enough on the map for the full-size name.
func _wide(code: String) -> bool:
	var box := Rect2(polys[code][0][0], Vector2.ZERO)
	for pts in polys[code]:
		for v in pts: box = box.expand(v)
	return box.size.x > 70.0

## Flags moved off their country: a small island it would cover (Cyprus), out to sea, a line pointing back.
const FLAG_OFF := {"cy": Vector2(-24, 2)}

func label_pos(code: String) -> Vector2:
	var l: Array = world.countries[code].label
	return Vector2(l[0], l[1])

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_MOUSE_EXIT: tip = "" # the cursor left the window: no tooltip left standing

func _process(dt: float) -> void:
	t += dt
	soon = maxf(0.0, soon - dt)
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var c := country_at(event.position)
		if playable().has(c): hover = c
		hover_soon = c if c != "" and not playable().has(c) else ""
		tip = c
		cursor = event.position
		return
	var p = Ui.tap(event)
	if offer != "":
		if p != null:
			if BUY_BTN.has_point(p): _buy_offer()
			elif CANCEL_BTN.has_point(p): offer = ""
		elif event is InputEventKey and event.pressed and not event.echo:
			if event.keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE]: _buy_offer()
			elif event.keycode in [KEY_ESCAPE, KEY_BACKSPACE]: offer = ""
		return
	if p != null:
		if BACK_BTN.has_point(p):
			_back()
			return
		var c := country_at(p)
		if playable().has(c):
			_pick(c)
		elif c != "":
			Sfx.play("blip", -14.0)
			hover_soon = c
			tip = c
			cursor = p
			soon = 2.0
		return
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	match event.keycode:
		KEY_ESCAPE, KEY_C, KEY_BACKSPACE: _back()
		KEY_ENTER, KEY_KP_ENTER, KEY_SPACE: _pick(hover)
		KEY_LEFT, KEY_A: _step(Vector2.LEFT)
		KEY_RIGHT, KEY_D: _step(Vector2.RIGHT)
		KEY_UP, KEY_W: _step(Vector2.UP)
		KEY_DOWN, KEY_S: _step(Vector2.DOWN)

## Arrows: the nearest playable country in that direction.
func _step(dir: Vector2) -> void:
	var from := label_pos(hover) if polys.has(hover) else Vector2(480, 270)
	var best := ""
	var best_d := INF
	for c in playable():
		var d := label_pos(c) - from
		if c == hover or d.dot(dir) <= 0.0: continue
		var score := d.length() * (2.0 - d.normalized().dot(dir))
		if score < best_d:
			best_d = score
			best = c
	if best != "":
		hover = best
		tip = ""
		Sfx.play("blip", -12.0)

func _pick(code: String) -> void:
	if not playable().has(code):
		return
	Sfx.play("blip", -8.0)
	if not Session.is_country_open(code):
		offer = code
		return
	Session.switch_country(code)
	_to_menu()

func _buy_offer() -> void:
	var code := offer
	offer = ""
	if Session.buy("country_one", code):
		Sfx.play("refuel_done", -6.0)
		Session.switch_country(code)
		_to_menu()

func _to_menu() -> void:
	Session.countries_back = "menu"
	Session.menu_at_map = true
	get_tree().change_scene_to_file("res://src/scenes/menu.tscn")

## A planned country's name in the player's language (data/world.json).
func _name(code: String) -> String:
	return GameData.localize(world.countries[code].name)

## [[flag code, name], ...] for a country in the game: one, or each of the countries a map spans (the Southern
## Balkans: Montenegro, Kosovo, Albania, North Macedonia), and for one coming soon: its name with the tag.
func _parts(code: String, names: Dictionary) -> Array:
	if not names.has(code): return [[code, "%s · %s" % [_name(code), Lang.t("soon_tag")]]]
	var members := GameData.members(code)
	if members.is_empty(): return [[code, names[code]]]
	return members.map(func(m): return [m, _name(m)])

## Flags and names in a row from `pos` (the baseline), each flag before its name; returns the row's width (with
## draw false only measures it).
func _row(pos: Vector2, parts: Array, size: int, color: Color, draw := true) -> float:
	var x := 0.0
	for k in parts.size():
		var fh := size * 0.8
		if draw: FlagPainter.draw(self, parts[k][0], Rect2(pos + Vector2(x, -size * 0.35 - fh * 0.5), Vector2(fh * 1.5, fh)))
		x += fh * 1.5 + 5.0
		var text: String = parts[k][1] + (", " if k < parts.size() - 1 else "")
		if draw: draw_string(font, pos + Vector2(x, 0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
		x += font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x + (8.0 if k < parts.size() - 1 else 0.0)
	return x

func _back() -> void:
	Sfx.play("blip", -8.0)
	if Session.countries_back == "shop":
		Session.countries_back = "menu"
		get_tree().change_scene_to_file("res://src/scenes/shop.tscn")
		return
	_to_menu()

func _draw() -> void:
	draw_rect(Rect2(0, 0, 960, 540), SEA)
	for pts in land:
		draw_colored_polygon(pts, LAND)
	var play := playable()
	for code in polys:
		var on: bool = play.has(code)
		var fill := (PLAYABLE if Session.is_country_open(code) else LOCKED) if on else PLANNED
		if code == hover: fill = fill.lightened(0.25)
		elif code == hover_soon: fill = fill.lightened(0.15)
		for pts in polys[code]:
			draw_colored_polygon(pts, fill)
	if not stripes.is_empty():
		draw_multiline(stripes, STRIPE, 1.0)
	for code in polys: # borders over every fill, so neighbours do not hide them
		var on: bool = play.has(code)
		for pts in polys[code]:
			var ring: PackedVector2Array = pts.duplicate()
			ring.append(pts[0])
			draw_polyline(ring, PLAYABLE_EDGE if on else PLANNED_EDGE, 1.2 if on else 0.8, true)
	for code in [Session.country, hover]: # the country played now in gold, the one under the cursor pulsing
		if not polys.has(code): continue
		var w := 3.0 if code == Session.country else 2.0 + sin(t * 6.0)
		for pts in polys[code]:
			var ring: PackedVector2Array = pts.duplicate()
			ring.append(pts[0])
			draw_polyline(ring, CURRENT if code == Session.country else Color.WHITE, w, true)
	var names := {}
	for c in GameData.countries(): names[c.code] = c.name
	var flag_order: Array = play.filter(func(c): return c != hover) # the one under the cursor last, over its neighbours
	if play.has(hover): flag_order.append(hover)
	for code in flag_order: # the flag in the middle of every country in the game, bigger under the cursor
		var h := (18.0 if code == hover else 14.0) if _wide(code) else (14.0 if code == hover else 10.0)
		var flags: Array = [code] # a map of several countries has its own emblem (FlagPainter)
		var cols := 1
		var rows := ceili(flags.size() / float(cols))
		var cell := Vector2(h * 1.5 + 3.0, h + 3.0)
		var at: Vector2 = label_pos(code) + FLAG_OFF.get(code, Vector2.ZERO)
		if FLAG_OFF.has(code): draw_line(label_pos(code), at, Color(0, 0, 0, 0.6), 1.0) # moved off a small island
		var top := at - Vector2(cell.x * cols - 3.0, cell.y * rows - 3.0) * 0.5
		for i in flags.size():
			var fl := Rect2(top + Vector2(cell.x * (i % cols), cell.y * (i / cols)), Vector2(h * 1.5, h))
			draw_rect(fl.grow(1.0), Color(0, 0, 0, 0.55))
			FlagPainter.draw(self, flags[i], fl)
			if not Session.is_country_open(code): # a padlock on the flag's corner
				_padlock(fl.end + Vector2(h * 0.55, 1), h * 0.6)
	if tip != "": # the name by the cursor: "Poland", or "France · coming soon"
		var parts := _parts(tip, names)
		var w := _row(Vector2.ZERO, parts, 15, Color.WHITE, false)
		var pos := cursor + Vector2(14, 30)
		pos.x = clampf(pos.x, 8.0, 952.0 - w)
		pos.y = clampf(pos.y, 80.0, 478.0)
		var box := Rect2(pos + Vector2(-8, -17), Vector2(w + 16, 24))
		draw_rect(box, Color(0.1, 0.12, 0.15, 0.85))
		draw_rect(box, CURRENT, false, 1.5)
		_row(pos, parts, 15, Color.WHITE)
	# header and footer
	draw_rect(Rect2(0, 0, 960, 58), Color(0, 0, 0, 0.45))
	draw_string(font, Vector2(24, 42), Lang.t("pick_country"), HORIZONTAL_ALIGNMENT_LEFT, -1, 32, Color.WHITE)
	var head_code := hover_soon if hover_soon != "" else (hover if names.has(hover) else "")
	if head_code != "": # the name on the right, its flag before it (each country's on a map of several)
		var parts := _parts(head_code, names)
		var title_w := font.get_string_size(Lang.t("pick_country"), HORIZONTAL_ALIGNMENT_LEFT, -1, 32).x + 48.0
		var hs := 24 if hover_soon != "" or parts.size() > 1 else 28
		while hs > 12 and _row(Vector2.ZERO, parts, hs, Color.WHITE, false) > 936.0 - title_w: hs -= 2
		var hw := _row(Vector2.ZERO, parts, hs, Color.WHITE, false)
		_row(Vector2(936.0 - hw, 42), parts, hs, Color("c8d0d6") if hover_soon != "" else CURRENT)
	draw_rect(Rect2(0, 486, 960, 54), Color(0, 0, 0, 0.5))
	Ui.button(self, font, BACK_BTN, Lang.t("back"), false, 20)
	var hint := Lang.t("country_soon") if soon > 0.0 else ("" if Screen.touch else Lang.t("pick_country_hint"))
	draw_string(font, Vector2(0, 518), hint, HORIZONTAL_ALIGNMENT_RIGHT, 936, 20, CURRENT if soon > 0.0 else Color.WHITE)
	if offer != "": # a locked country for sale
		draw_rect(Rect2(0, 0, 960, 540), Color(0, 0, 0, 0.45))
		var box := Rect2(230, 160, 500, 216)
		var sb := StyleBoxFlat.new()
		sb.set_corner_radius_all(16)
		sb.bg_color = Color(0.06, 0.09, 0.13, 0.95)
		sb.border_color = CURRENT
		sb.set_border_width_all(3)
		draw_style_box(sb, box)
		var name: String = names.get(offer, _name(offer))
		FlagPainter.draw(self, offer, Rect2(Vector2(456, 176), Vector2(48, 32)))
		draw_string(font, Vector2(box.position.x, 240), Lang.t("country_buy") % [name, Shop.price_text("country_one")], HORIZONTAL_ALIGNMENT_CENTER, box.size.x, 22, Color.WHITE)
		var earn := _earned_by(offer)
		if earn != "":
			draw_multiline_string(font, Vector2(box.position.x + 20, 268), Lang.t("country_earn") % names.get(earn, earn), HORIZONTAL_ALIGNMENT_CENTER, box.size.x - 40, 15, 2, Color("c8d6e3"))
		Ui.button(self, font, BUY_BTN, Lang.t("shop_buy"), true, 20)
		Ui.button(self, font, CANCEL_BTN, Lang.t("back"), false, 20)

## A small golden padlock with its bottom right corner at `at`.
func _padlock(at: Vector2, size: float) -> void:
	var body := Rect2(at - Vector2(size * 1.2, size), Vector2(size * 1.2, size))
	draw_arc(body.position + Vector2(size * 0.6, 0), size * 0.42, PI, TAU, 10, Color("ffd24a"), maxf(1.5, size * 0.22))
	draw_rect(body, Color("ffd24a"))
	draw_circle(body.get_center(), maxf(1.0, size * 0.16), Color("2b2b2f"))

## The open country whose completing earns `code` (Session.earned_for), "" with none.
func _earned_by(code: String) -> String:
	for c in Session.countries:
		if Session.earned_for(c) == code: return c
	return ""
