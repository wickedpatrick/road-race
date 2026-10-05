class_name Hud
extends Control
## Heads-up display, drawn procedurally. Reads the Race only.
var race: Race
var font: Font
var _panel := StyleBoxFlat.new()
var _region := ""
var _region_time := 0.0
var _warm_left: Array = [] ## [text, size] still to pre-render, a few per frame
var _legs: Array = []
var _mini: PolandMap
var touch := false ## touch-screen layout (set before bind): the bottom corners belong to the driving buttons
const PAUSE_BTN := Rect2(16, 14, 46, 66)
## positions that move on touch screens, where the bottom corners belong to the driving buttons
var _fuel_pos := Vector2(16, 446)
var _limit_pos := Vector2(312, 486)
var _mini_rect := Rect2(780, 376, 170, 154)
var _board_y := 92.0
var _t := 0.0
var _landmarks: Array = []

func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel.bg_color = Color(0.05, 0.07, 0.1, 0.55)
	_panel.set_corner_radius_all(12)
	font = ThemeDB.fallback_font

func bind(p_race: Race) -> void:
	race = p_race
	if touch:
		_fuel_pos = Vector2(16, 88)
		_limit_pos = Vector2(52, 208)
		_mini_rect = Rect2(794, 88, 150, 132)
		_board_y = 228.0
	_mini = PolandMap.new(_mini_rect.grow_individual(-10, -8, -10, -8))
	_legs = Route.find(race.stage.from, race.stage.to)
	# town names, facts and regions shown in the HUD, pre-rendered during the countdown (see Scenery.warm_text)
	for t in race.stage.towns:
		for fs in [10, 11, 12, 13, 14, 15]:
			_warm_left.append([t.name, fs])
		_warm_left.append([t.name, 19])
		_warm_left.append([t.fact, 15])
	_landmarks = Landmarks.place(race.stage)
	for lm in _landmarks:
		_warm_left.append([_landmark_title(lm), 19])
		_warm_left.append([lm.desc, 15])
	for zn in race.stage.zones:
		_warm_left.append(["Kraina: " + zn.region, 19])
		_warm_left.append([zn.region, 14])

var _frame := 0

func _process(dt: float) -> void:
	_t += dt
	if race != null:
		var reg: String = Route.zone_at(race.stage, race.z).region
		if reg != _region:
			_region = reg
			_region_time = 5.0
		_region_time = maxf(0.0, _region_time - dt)
	# the HUD is mostly text: 30 redraws a second are plenty and halve its cost (the last drawing stays on screen)
	_frame += 1
	if _frame % 2 == 0 or not _warm_left.is_empty():
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
	for w in _warm_left.slice(0, 8):
		draw_string(font, Vector2(-5000, -5000), w[0], HORIZONTAL_ALIGNMENT_LEFT, -1, w[1])
	_warm_left = _warm_left.slice(8)
	# time
	var low_time := race.time_left < 20.0
	var blink := low_time and int(race.elapsed * 3.0) % 2 == 0
	draw_style_box(_panel, PAUSE_BTN)
	var pc := PAUSE_BTN.get_center()
	draw_rect(Rect2(pc + Vector2(-9, -13), Vector2(6, 26)), Color.WHITE)
	draw_rect(Rect2(pc + Vector2(3, -13), Vector2(6, 26)), Color.WHITE)
	draw_style_box(_panel, Rect2(70, 14, 112, 66))
	_text(Vector2(82, 36), "CZAS", 15, Color("9fb3c8"))
	_text(Vector2(82, 70), format_time(race.time_left), 38, Color("ff5a4d") if blink else (Color("ff8a7a") if low_time else Color.WHITE))
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
	var road := Route.road_at(race.stage, race.z)
	if road != "":
		_shield(Vector2(bx + bw - 44, 21), road)
	var by := 50.0
	draw_rect(Rect2(bx, by, bw, 8), Color(1, 1, 1, 0.25))
	draw_rect(Rect2(bx, by, bw * race.progress(), 8), Color("4cc3ff"))
	for t in race.stage.towns:
		var tx: float = bx + bw * clampf(t.z / race.stage.length, 0.0, 1.0)
		draw_rect(Rect2(tx - 1, by - (4 if t.big else 1), 2, 10 if t.big else 7), Color(1, 1, 1, 0.9 if t.big else 0.55))
	for s in race.stage.stations:
		_pump_icon(Vector2(bx + bw * (s / race.stage.length), by + 4))
	draw_circle(Vector2(bx + bw * race.progress(), by + 4), 8, Color.WHITE)
	draw_circle(Vector2(bx + bw * race.progress(), by + 4), 5, Color("e14b3a"))
	_text(Vector2(bx, 82), "%s: %d km" % [race.stage.finish_label, int(ceil(race.km_left()))], 16, Color("ffd24a"))
	_text(Vector2(bx, 82), _region, 14, Color("d6e4f0"), HORIZONTAL_ALIGNMENT_RIGHT, bw)
	# fuel
	var fr := race.fuel.ratio()
	var low_fuel := fr < 0.15
	var fblink := low_fuel and int(race.elapsed * 4.0) % 2 == 0
	var fp := _fuel_pos
	var fw := 170.0 if touch else 250.0
	draw_style_box(_panel, Rect2(fp, Vector2(fw, 80)))
	var l100 := minf(99.0, race.fuel.litres_per_100km(race.speed, Route.M_PER_KM, race.load, race.gearbox.rpm(race.speed)))
	var eco := absf(race.speed * 3.6 - 90.0) < 12.0
	var l100_text := "-" if race.speed < 1.0 else ("%.1f l/100 km" % l100).replace(".", ",")
	var lc := Color("ff8a7a") if l100 > 15.0 else (Color("7fe0a0") if eco else Color("d6e4f0"))
	_text(fp + Vector2(12, 22), l100_text, 15, lc)
	_text(fp + Vector2(12, 46), "PALIWO", 15, Color("ff6a5a") if fblink else Color("9fb3c8"))
	_text(fp + Vector2(12, 46), "%d / %d l" % [int(round(race.fuel.level)), int(race.fuel.capacity)], 15, Color.WHITE, HORIZONTAL_ALIGNMENT_RIGHT, fw - 24)
	draw_rect(Rect2(fp + Vector2(12, 54), Vector2(fw - 24, 16)), Color(1, 1, 1, 0.2))
	var fc := Color("49d36b") if fr > 0.35 else (Color("f2b01e") if fr > 0.15 else Color("ff4d3d"))
	draw_rect(Rect2(fp + Vector2(12, 54), Vector2((fw - 24) * fr, 16)), fc)
	_limit_sign()
	# police / speeding / station / state hints
	var ph: String = race.police.get("phase", "")
	if ph == "ticket" or (ph == "leave" and race.police.t < 3.0):
		_banner("MANDAT za przekroczenie prędkości: -%d l paliwa" % int(Race.FINE_FUEL), Color("ff6a5a"))
	elif ph == "chase" or ph == "pull_over":
		_banner("POLICJA! Zatrzymaj się", Color("6aa8ff") if int(race.elapsed * 4.0) % 2 == 0 else Color("ff6a5a"))
	elif race.speeding > 0.0:
		_banner("ZWOLNIJ! Ograniczenie %d km/h   (%d s)" % [race.speed_limit(), int(ceil(race.speeding_grace() - race.speeding))], Color("ff6a5a"))
	elif race.refueling:
		_banner("TANKOWANIE...  %d%%" % int(fr * 100.0), Color("49d36b"))
	elif race.station_in_range() and race.shoulder_fraction() < Race.SHOULDER_MIN:
		_banner("STACJA PALIW: ZJEDŹ W PRAWO NA POBOCZE", Color("f2c21b"))
	elif race.station_in_range():
		_banner("STACJA PALIW: ZATRZYMAJ SIĘ (%s), ABY TANKOWAĆ" % ("hamulec" if touch else "spacja"), Color("f2c21b"))
	elif race.next_station_distance() > 0.0 and race.next_station_distance() < 450.0 and fr < 0.85:
		_banner("STACJA za %d m: zjedź na prawe pobocze" % (int(race.next_station_distance() / 10.0) * 10), Color("f2c21b"))
	elif low_fuel and int(race.elapsed * 2.0) % 2 == 0:
		_banner("MAŁO PALIWA! Szukaj stacji", Color("ff6a5a"))

	_info_card()
	_board_echo()
	_minimap()

## Fuel pump: yellow body with a dark display and a hose, centred on the progress bar.
func _pump_icon(c: Vector2) -> void:
	var body := Rect2(c + Vector2(-5, -10), Vector2(10, 17))
	draw_rect(body.grow(1.5), Color("1c2733"))
	draw_rect(body, Color("f2c21b"))
	draw_rect(Rect2(c + Vector2(-3, -8), Vector2(6, 4)), Color("1c2733"))
	draw_rect(Rect2(c + Vector2(-6.5, 6), Vector2(13, 3)), Color("1c2733"))
	draw_polyline(PackedVector2Array([c + Vector2(5, -6), c + Vector2(9, -4), c + Vector2(9, 4), c + Vector2(7, 5)]), Color("1c2733"), 2.0)

## Road-number plate (E-15), see Scenery.plate().
func _shield(pos: Vector2, road: String) -> void:
	var pl := Scenery.plate(road)
	draw_rect(Rect2(pos, Vector2(44, 22)), pl[1])
	draw_rect(Rect2(pos + Vector2(2, 2), Vector2(40, 18)), pl[2], false, 1.0)
	draw_string(font, pos + Vector2(0, 17), pl[0], HORIZONTAL_ALIGNMENT_CENTER, 44, 15, pl[2])

## Map of Poland with the route and the car's position on it.
func _minimap() -> void:
	if _legs.is_empty():
		return
	draw_style_box(_panel, _mini_rect)
	_mini.draw_mini(self, font, _legs, Route.km_between(race.stage, 0.0, minf(race.z, race.stage.length)), _t)

## Current speed limit (B-33), flashing while the radar detector warns.
func _limit_sign() -> void:
	var c := _limit_pos
	var warn := race.speeding > 0.0 and int(race.elapsed * 6.0) % 2 == 0
	draw_circle(c, 31, Color(0, 0, 0, 0.35))
	draw_circle(c, 29, Color("ffd24a") if warn else Scenery.SIGN_RED)
	draw_circle(c, 22, Color.WHITE)
	draw_string(font, c + Vector2(-22, 8), str(race.speed_limit()), HORIZONTAL_ALIGNMENT_CENTER, 44, 21, Color.BLACK)

## Copy of the distance board being passed, so its towns and kilometres can be read at speed.
func _board_echo() -> void:
	for bd in race.stage.boards:
		if race.z > bd.z - 160.0 and race.z < bd.z + 220.0:
			var lines: Array = bd.lines
			var r := Rect2(784, _board_y, 160, 34 + 22 * lines.size())
			draw_rect(r, Scenery.SIGN_BLUE if bd.blue else Scenery.SIGN_GREEN)
			draw_rect(r.grow(-3), Color.WHITE, false, 2.0)
			if bd.road != "":
				_shield(Vector2(r.position.x + 58, r.position.y + 7), bd.road)
			for i in lines.size():
				var y := r.position.y + 50 + 22 * i
				var fs := 15
				while fs > 10 and font.get_string_size(lines[i][0], HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x > 108:
					fs -= 1
				draw_string(font, Vector2(r.position.x + 10, y), lines[i][0], HORIZONTAL_ALIGNMENT_LEFT, 112, fs, Color.WHITE)
				draw_string(font, Vector2(r.position.x + 10, y), str(lines[i][1]), HORIZONTAL_ALIGNMENT_RIGHT, 140, 15, Color.WHITE)
			return

## Top card: the town being driven through (with a fact when there is one), or the region just entered.
func _info_card() -> void:
	var t := Route.town_at(race.stage, race.z)
	var title := ""
	var body := ""
	var lm := Landmarks.in_view(_landmarks, race.z)
	if not lm.is_empty():
		title = _landmark_title(lm)
		body = lm.desc
	elif not t.is_empty():
		title = t.name
		body = t.fact if t.fact != "" else ("Duże miasto" if t.big else "Miejscowość na trasie")
	elif _region_time > 0.0:
		title = "Kraina: " + _region
		body = "Wjeżdżasz w nowy region"
	else:
		return
	var r := Rect2(200, 92, 560, 58)
	draw_style_box(_panel, r)
	_text(r.position + Vector2(16, 24), title, 19, Color("ffd24a"))
	_text(r.position + Vector2(16, 48), body, 15, Color.WHITE, HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 32)

static func _landmark_title(lm: Dictionary) -> String:
	return "%s: %s" % [lm.town, lm.name] if lm.town != lm.name else lm.name

func _banner(text: String, col: Color) -> void:
	draw_style_box(_panel, Rect2(180, 158, 600, 46))
	_text(Vector2(180, 190), text, 22, col, HORIZONTAL_ALIGNMENT_CENTER, 600)
