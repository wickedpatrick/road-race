extends Node2D
## The shop (opened from the destination map, K): every product of Shop as a card with its name, what it does and
## its price; the ones bought say so, a lower level of an upgrade owned in a higher one too. Arrows pick a card,
## Enter (or a click on the card picked) buys it; "one country" opens the map of countries to pick the one to buy.
## Esc goes back to the map. Payments are not real yet: a note at the bottom says the purchases are free.
const COLS := 3
const CARD := Vector2(296, 72)
const GAP := Vector2(12, 10)
const TOP := 72.0
const BACK_BTN := Rect2(24, 490, 148, 44)
var font: Font
var sel := 0
var t := 0.0
var _flash := 0.0 ## seconds left of the "bought" flash on the card picked

func _ready() -> void:
	Sfx.music(true)
	font = ThemeDB.fallback_font

func _process(dt: float) -> void:
	t += dt
	_flash = maxf(0.0, _flash - dt)
	queue_redraw()

func _rect(i: int) -> Rect2:
	var left := (960.0 - COLS * CARD.x - (COLS - 1) * GAP.x) * 0.5
	return Rect2(Vector2(left + (i % COLS) * (CARD.x + GAP.x), TOP + (i / COLS) * (CARD.y + GAP.y)), CARD)

func _unhandled_input(event: InputEvent) -> void:
	var p = Ui.tap(event)
	if p != null:
		if BACK_BTN.has_point(p):
			_back()
			return
		for i in Shop.PRODUCTS.size():
			if _rect(i).has_point(p):
				if sel == i: _buy()
				else:
					sel = i
					Sfx.play("blip", -15.0)
				return
		return
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	var n := Shop.PRODUCTS.size()
	match event.keycode:
		KEY_ESCAPE, KEY_K, KEY_BACKSPACE: _back()
		KEY_ENTER, KEY_KP_ENTER, KEY_SPACE: _buy()
		KEY_LEFT, KEY_A: _move(-1)
		KEY_RIGHT, KEY_D: _move(1)
		KEY_UP, KEY_W: _move(-COLS)
		KEY_DOWN, KEY_S: _move(COLS)

func _move(d: int) -> void:
	var i := sel + d
	if i < 0 or i >= Shop.PRODUCTS.size():
		return
	sel = i
	Sfx.play("blip", -15.0)

func _buy() -> void:
	var id: String = Shop.PRODUCTS[sel].id
	if id == "country_one": # the country picked on the map of countries
		if Session.bought.has("countries_all"): return
		Sfx.play("blip", -8.0)
		Session.countries_back = "shop"
		get_tree().change_scene_to_file("res://src/scenes/countries.tscn")
		return
	if Session.buy(id):
		Sfx.play("refuel_done", -6.0)
		_flash = 1.2

func _back() -> void:
	Sfx.play("blip", -8.0)
	Session.menu_at_map = true
	get_tree().change_scene_to_file("res://src/scenes/menu.tscn")

## "Bought", "you have a better one", or "" while it can be bought.
func _state(id: String) -> String:
	if id == "country_one":
		return Lang.t("shop_owned") if Session.bought.has("countries_all") else ""
	if Session.bought.has(id):
		return Lang.t("shop_owned")
	if not Shop.can_buy(Session.bought, id):
		return Lang.t("shop_better")
	return ""

func _draw() -> void:
	var pal := Weather.palette("sun")
	draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(960, 0), Vector2(960, 540), Vector2(0, 540)]),
		PackedColorArray([pal.sky_top, pal.sky_top, pal.sky_bottom, pal.sky_bottom]))
	draw_rect(Rect2(0, 0, 960, 58), Color(0, 0, 0, 0.45))
	draw_string(font, Vector2(24, 42), Lang.t("shop_title"), HORIZONTAL_ALIGNMENT_LEFT, -1, 32, Color.WHITE)
	for i in Shop.PRODUCTS.size():
		var id: String = Shop.PRODUCTS[i].id
		var r := _rect(i)
		var state := _state(id)
		var sb := StyleBoxFlat.new()
		sb.set_corner_radius_all(12)
		sb.bg_color = Color(0.06, 0.09, 0.13, 0.82 if i == sel else 0.55)
		if i == sel:
			sb.border_color = Color("49d36b") if _flash > 0.0 else Color("ffd24a")
			sb.set_border_width_all(3)
		draw_style_box(sb, r)
		var name_col := Color.WHITE if state == "" else Color("9fb0bf")
		draw_string(font, r.position + Vector2(12, 26), Lang.t("p_" + id), HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 84, 17, name_col)
		draw_multiline_string(font, r.position + Vector2(12, 48), Lang.t("pd_" + id), HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 84, 13, 2, Color("c8d6e3"))
		var tag := Shop.price_text(id) if state == "" else state
		var tc := Color("ffd24a") if state == "" else Color("7fe0a0")
		draw_string(font, Vector2(r.end.x - 80, r.position.y + 26), tag, HORIZONTAL_ALIGNMENT_RIGHT, 68, 18 if state == "" else 13, tc)
	draw_rect(Rect2(0, 486, 960, 54), Color(0, 0, 0, 0.5))
	Ui.button(self, font, BACK_BTN, Lang.t("back"), false, 20)
	draw_string(font, Vector2(190, 506), Lang.t("shop_test_note"), HORIZONTAL_ALIGNMENT_LEFT, 560, 15, Color("ffd24a"))
	if not Screen.touch:
		draw_string(font, Vector2(190, 528), Lang.t("shop_hint"), HORIZONTAL_ALIGNMENT_LEFT, 746, 15, Color.WHITE)
