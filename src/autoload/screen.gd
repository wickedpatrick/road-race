extends Node
## Phones and tablets: notices a touch screen (scenes then show touch buttons instead of key hints), asks to turn
## the phone sideways while it is held upright (and pauses until then), and on Android goes full screen on the
## first touch.
var touch := false
var _portrait := false
var _layer: CanvasLayer
var _veil: Control
var _font: Font

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	touch = DisplayServer.is_touchscreen_available()
	_font = ThemeDB.fallback_font
	_layer = CanvasLayer.new()
	_layer.layer = 100
	add_child(_layer)
	_veil = Control.new()
	_veil.set_anchors_preset(Control.PRESET_FULL_RECT)
	_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_veil.draw.connect(_draw_veil)
	_layer.add_child(_veil)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		if not touch:
			touch = true
		_go_full_screen()

func _go_full_screen() -> void:
	if not OS.has_feature("web_android") or DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		return
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	JavaScriptBridge.eval("screen.orientation && screen.orientation.lock && screen.orientation.lock('landscape').catch(function(){})")

func _process(_dt: float) -> void:
	var size := DisplayServer.window_get_size()
	var portrait := touch and size.y > size.x
	if portrait != _portrait:
		_portrait = portrait
		get_tree().paused = portrait
		if portrait:
			Sfx.silence_all_loops()
		_veil.queue_redraw()

func _draw_veil() -> void:
	if not _portrait:
		return
	_veil.draw_rect(Rect2(0, 0, 960, 540), Color("0f1a24"))
	# a phone turning sideways
	var c := Vector2(480, 220)
	_veil.draw_rect(Rect2(c + Vector2(-150, -45), Vector2(70, 120)), Color("d6e4f0"), false, 6.0)
	_veil.draw_rect(Rect2(c + Vector2(80, -10), Vector2(120, 70)), Color("ffd24a"), false, 6.0)
	_veil.draw_arc(c + Vector2(0, 0), 60, -PI * 0.9, -PI * 0.2, 16, Color.WHITE, 5.0)
	_veil.draw_colored_polygon(PackedVector2Array([c + Vector2(48, -52), c + Vector2(66, -30), c + Vector2(38, -28)]), Color.WHITE)
	_veil.draw_string(_font, Vector2(0, 360), "Obróć telefon poziomo", HORIZONTAL_ALIGNMENT_CENTER, 960, 52, Color.WHITE)
	_veil.draw_string(_font, Vector2(0, 410), "Rajd przez Polskę gra się w poziomie", HORIZONTAL_ALIGNMENT_CENTER, 960, 26, Color("9fb3c8"))
