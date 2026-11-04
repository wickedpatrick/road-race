extends Node2D
## Picking the country to play on a map of Europe (with a piece of Asia) and, small across the sea on the left,
## North America (data/world.json, made by tools/make_world.py). Countries in the game are green and named; the
## ones planned but not in the game yet are grey with their borders; any other land has no borders at all.
## Opened from the map in the menu (the country button, C); Esc goes back without a change.
const SEA := Color("2c5d86")
const LAND := Color("c4b893") ## land of countries not in the plan, without borders
const PLANNED := Color("b4b9bd")
const PLANNED_EDGE := Color("7d858c")
const PLAYABLE := Color("8fd16a")
const PLAYABLE_EDGE := Color("2f6b2a")
const CURRENT := Color("ffd24a")
const BACK_BTN := Rect2(24, 490, 148, 44)
var font: Font
var world: Dictionary
var polys := {} ## code -> [PackedVector2Array, ...]
var land: Array = [] ## PackedVector2Array
var hover := "" ## the playable country under the mouse or picked with the arrows
var soon := 0.0 ## seconds left of the "not in the game yet" note
var t := 0.0

func _ready() -> void:
	font = ThemeDB.fallback_font
	world = GameData.load_json(GameData.DIR + "world.json")
	for code in world.countries:
		polys[code] = world.countries[code].polys.map(func(f): return _pts(f))
	land = world.land.map(func(f): return _pts(f))
	hover = Session.country

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
			soon = 1.6
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
		Sfx.play("blip", -12.0)

func _pick(code: String) -> void:
	if not playable().has(code):
		return
	Sfx.play("blip", -8.0)
	Session.switch_country(code)
	Session.menu_at_map = true
	get_tree().change_scene_to_file("res://src/scenes/menu.tscn")

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
		for pts in polys[code]:
			draw_colored_polygon(pts, fill)
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
	for code in play:
		var size := (17 if code == hover else 14) if polys[code].size() > 0 and _wide(code) else (15 if code == hover else 12)
		var p := label_pos(code)
		var w := font.get_string_size(names[code], HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
		var pos := p + Vector2(-w * 0.5, size * 0.35)
		draw_string_outline(font, pos, names[code], HORIZONTAL_ALIGNMENT_LEFT, -1, size, 4, Color(0, 0, 0, 0.6))
		draw_string(font, pos, names[code], HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color.WHITE)
	# header and footer
	draw_rect(Rect2(0, 0, 960, 58), Color(0, 0, 0, 0.45))
	draw_string(font, Vector2(24, 42), Lang.t("pick_country"), HORIZONTAL_ALIGNMENT_LEFT, -1, 32, Color.WHITE)
	if names.has(hover):
		draw_string(font, Vector2(0, 42), names[hover], HORIZONTAL_ALIGNMENT_RIGHT, 936, 28, CURRENT)
	draw_rect(Rect2(0, 486, 960, 54), Color(0, 0, 0, 0.5))
	Ui.button(self, font, BACK_BTN, Lang.t("back"), false, 20)
	var hint := Lang.t("country_soon") if soon > 0.0 else ("" if Screen.touch else Lang.t("pick_country_hint"))
	draw_string(font, Vector2(0, 518), hint, HORIZONTAL_ALIGNMENT_RIGHT, 936, 20, CURRENT if soon > 0.0 else Color.WHITE)
