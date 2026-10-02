class_name Hud
extends Control
## Heads-up display, drawn procedurally. Reads the Race only.
var race: Race
var font: Font
var _panel := StyleBoxFlat.new()

func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel.bg_color = Color(0.05, 0.07, 0.1, 0.55)
	_panel.set_corner_radius_all(12)
	font = ThemeDB.fallback_font

func bind(p_race: Race) -> void:
	race = p_race

func _process(_dt: float) -> void:
	queue_redraw()

static func format_time(t: float) -> String:
	var s := maxi(0, int(ceil(t)))
	return "%d:%02d" % [s / 60, s % 60]

func _text(pos: Vector2, text: String, size: int, col: Color, align := HORIZONTAL_ALIGNMENT_LEFT, width := -1.0) -> void:
	draw_string(font, pos + Vector2(2, 2), text, align, width, size, Color(0, 0, 0, 0.6))
	draw_string(font, pos, text, align, width, size, col)

func _draw() -> void:
	if race == null:
		return
	# time
	var low_time := race.time_left < 20.0
	var blink := low_time and int(race.elapsed * 3.0) % 2 == 0
	draw_style_box(_panel, Rect2(16, 14, 150, 66))
	_text(Vector2(28, 36), "CZAS", 15, Color("9fb3c8"))
	_text(Vector2(28, 70), format_time(race.time_left), 38, Color("ff5a4d") if blink else (Color("ff8a7a") if low_time else Color.WHITE))
	# speed + gear
	draw_style_box(_panel, Rect2(794, 14, 150, 66))
	_text(Vector2(806, 36), "KM/H", 15, Color("9fb3c8"))
	_text(Vector2(806, 70), str(int(race.speed * 3.6)), 38, Color.WHITE)
	_text(Vector2(840, 70), "D%d" % race.gear, 26, Color("ffd24a"), HORIZONTAL_ALIGNMENT_RIGHT, 92)
	# progress bar
	var bx := 200.0
	var bw := 560.0
	draw_style_box(_panel, Rect2(bx - 10, 14, bw + 20, 52))
	_text(Vector2(bx, 36), race.stage.name, 17, Color.WHITE)
	var by := 50.0
	draw_rect(Rect2(bx, by, bw, 8), Color(1, 1, 1, 0.25))
	draw_rect(Rect2(bx, by, bw * race.progress(), 8), Color("4cc3ff"))
	for s in race.stage.stations:
		var sx: float = bx + bw * (s / race.stage.length)
		draw_rect(Rect2(sx - 3, by - 5, 6, 18), Color("f2c21b"))
	draw_circle(Vector2(bx + bw * race.progress(), by + 4), 8, Color.WHITE)
	draw_circle(Vector2(bx + bw * race.progress(), by + 4), 5, Color("e14b3a"))
	_text(Vector2(bx, 80), "żółte znaczniki = stacje paliw", 13, Color("f2c21b"))
	_text(Vector2(bx, 80), "META: " + race.stage.finish_label.to_upper(), 13, Color("d6e4f0"), HORIZONTAL_ALIGNMENT_RIGHT, bw)
	# fuel
	var fr := race.fuel.ratio()
	var low_fuel := fr < 0.15
	var fblink := low_fuel and int(race.elapsed * 4.0) % 2 == 0
	draw_style_box(_panel, Rect2(16, 470, 250, 56))
	_text(Vector2(28, 492), "PALIWO", 15, Color("ff6a5a") if fblink else Color("9fb3c8"))
	_text(Vector2(28, 492), "%d / %d l" % [int(round(race.fuel.level)), int(race.fuel.capacity)], 15, Color.WHITE, HORIZONTAL_ALIGNMENT_RIGHT, 226)
	draw_rect(Rect2(28, 500, 226, 16), Color(1, 1, 1, 0.2))
	var fc := Color("49d36b") if fr > 0.35 else (Color("f2b01e") if fr > 0.15 else Color("ff4d3d"))
	draw_rect(Rect2(28, 500, 226 * fr, 16), fc)
	# station / state hints
	if race.refueling:
		_banner("TANKOWANIE...  %d%%" % int(fr * 100.0), Color("49d36b"))
	elif race.station_in_range():
		_banner("STACJA PALIW: ZATRZYMAJ SIĘ (spacja), ABY TANKOWAĆ", Color("f2c21b"))
	elif race.next_station_distance() > 0.0 and race.next_station_distance() < 450.0 and fr < 0.85:
		_banner("STACJA PALIW za %d m  -  zwalniaj (spacja)" % (int(race.next_station_distance() / 10.0) * 10), Color("f2c21b"))
	elif low_fuel and int(race.elapsed * 2.0) % 2 == 0:
		_banner("MAŁO PALIWA! Szukaj stacji", Color("ff6a5a"))

func _banner(text: String, col: Color) -> void:
	draw_style_box(_panel, Rect2(180, 118, 600, 46))
	_text(Vector2(180, 150), text, 22, col, HORIZONTAL_ALIGNMENT_CENTER, 600)
