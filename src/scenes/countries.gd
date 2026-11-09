extends Node2D
## Picking the country to play on a map of Europe (with a piece of Asia) and, small across the sea on the left,
## North America (data/world.json, made by tools/make_world.py). Countries in the game are green with their flag in
## the middle; the ones planned but not in the game yet are grey, striped and marked "coming soon"; any other land
## has no borders at all. Names show in the header and in a tooltip by the cursor (or the tap). A legend in the
## corner tells the two apart.
## Opened from the map in the menu (the country button, C); Esc goes back without a change.
const SEA := Color("2c5d86")
const LAND := Color("c4b893") ## land of countries not in the plan, without borders
const PLANNED := Color("b4b9bd")
const PLANNED_EDGE := Color("7d858c")
const PLAYABLE := Color("8fd16a")
const PLAYABLE_EDGE := Color("2f6b2a")
const CURRENT := Color("ffd24a")
const STRIPE := Color("969ca1")
const STRIPE_GAP := 7.0 ## px between the "coming soon" stripes
const LEGEND := Rect2(16, 404, 214, 70)
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
var t := 0.0

func _ready() -> void:
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

func label_pos(code: String) -> Vector2:
	var l: Array = world.countries[code].label
	return Vector2(l[0], l[1])

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
	Session.switch_country(code)
	Session.menu_at_map = true
	get_tree().change_scene_to_file("res://src/scenes/menu.tscn")

## A planned country's name in the player's language (data/world.json).
func _name(code: String) -> String:
	return GameData.localize(world.countries[code].name)

## Which colour means what: in the game, coming soon.
func _legend() -> void:
	draw_rect(LEGEND, Color(0.06, 0.09, 0.13, 0.8))
	draw_rect(LEGEND, Color(1, 1, 1, 0.5), false, 1.0)
	var r1 := Rect2(LEGEND.position + Vector2(12, 12), Vector2(30, 18))
	draw_rect(r1, PLAYABLE)
	draw_rect(r1, PLAYABLE_EDGE, false, 1.5)
	draw_string(font, Vector2(r1.end.x + 10, r1.end.y - 3), Lang.t("legend_playable"), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
	var r2 := Rect2(LEGEND.position + Vector2(12, 40), Vector2(30, 18))
	draw_rect(r2, PLANNED)
	for k in range(-2, 7):
		var a := r2.position + Vector2(k * 7.0, r2.size.y)
		var b := a + Vector2(r2.size.y, -r2.size.y)
		var seg := Geometry2D.intersect_polyline_with_polygon(PackedVector2Array([a, b]), PackedVector2Array([r2.position, Vector2(r2.end.x, r2.position.y), r2.end, Vector2(r2.position.x, r2.end.y)]))
		for sg in seg:
			draw_line(sg[0], sg[sg.size() - 1], STRIPE, 1.0)
	draw_rect(r2, PLANNED_EDGE, false, 1.0)
	draw_string(font, Vector2(r2.end.x + 10, r2.end.y - 3), Lang.t("legend_soon"), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)

func _back() -> void:
	Sfx.play("blip", -8.0)
	Session.menu_at_map = true
	get_tree().change_scene_to_file("res://src/scenes/menu.tscn")

func _draw() -> void:
	draw_rect(Rect2(0, 0, 960, 540), SEA)
	for pts in land:
		draw_colored_polygon(pts, LAND)
	var play := playable()
	for code in polys:
		var on: bool = play.has(code)
		var fill := PLAYABLE if on else PLANNED
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
	for code in play: # the flag in the middle of every country in the game, bigger under the cursor
		var h := (18.0 if code == hover else 14.0) if _wide(code) else (14.0 if code == hover else 10.0)
		var fl := Rect2(label_pos(code) - Vector2(h * 0.75, h * 0.5), Vector2(h * 1.5, h))
		draw_rect(fl.grow(1.0), Color(0, 0, 0, 0.55))
		FlagPainter.draw(self, code, fl)
	if tip != "": # the name by the cursor: "Poland", or "France · coming soon"
		var text: String = names[tip] if names.has(tip) else "%s · %s" % [_name(tip), Lang.t("soon_tag")]
		var w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x + 26 # with the flag
		var pos := cursor + Vector2(14, 30)
		pos.x = clampf(pos.x, 8.0, 952.0 - w)
		pos.y = clampf(pos.y, 80.0, 478.0)
		var box := Rect2(pos + Vector2(-8, -17), Vector2(w + 16, 24))
		draw_rect(box, Color(0.1, 0.12, 0.15, 0.85))
		draw_rect(box, CURRENT, false, 1.5)
		FlagPainter.draw(self, tip, Rect2(pos + Vector2(0, -12), Vector2(21, 14)))
		draw_string(font, pos + Vector2(26, 0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color.WHITE)
	_legend()
	# header and footer
	draw_rect(Rect2(0, 0, 960, 58), Color(0, 0, 0, 0.45))
	draw_string(font, Vector2(24, 42), Lang.t("pick_country"), HORIZONTAL_ALIGNMENT_LEFT, -1, 32, Color.WHITE)
	var head_code := hover_soon if hover_soon != "" else (hover if names.has(hover) else "")
	if head_code != "": # the name on the right, its flag before it
		var head: String = "%s · %s" % [_name(hover_soon), Lang.t("soon_tag")] if hover_soon != "" else names[hover]
		var hs := 24 if hover_soon != "" else 28
		draw_string(font, Vector2(0, 42), head, HORIZONTAL_ALIGNMENT_RIGHT, 936, hs, Color("c8d0d6") if hover_soon != "" else CURRENT)
		var hw := font.get_string_size(head, HORIZONTAL_ALIGNMENT_LEFT, -1, hs).x
		FlagPainter.draw(self, head_code, Rect2(Vector2(936 - hw - 52, 14), Vector2(42, 28)))
	draw_rect(Rect2(0, 486, 960, 54), Color(0, 0, 0, 0.5))
	Ui.button(self, font, BACK_BTN, Lang.t("back"), false, 20)
	var hint := Lang.t("country_soon") if soon > 0.0 else ("" if Screen.touch else Lang.t("pick_country_hint"))
	draw_string(font, Vector2(0, 518), hint, HORIZONTAL_ALIGNMENT_RIGHT, 936, 20, CURRENT if soon > 0.0 else Color.WHITE)
