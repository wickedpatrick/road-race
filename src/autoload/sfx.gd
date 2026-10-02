extends Node
## All game audio. Lives across scenes so the music never restarts. X toggles mute.
const DIR := "res://assets/audio/"
const LOOPS := ["engine", "gravel", "pump", "music"]
const ONESHOTS := ["hit", "beep", "go", "blip", "lowfuel", "refuel_done", "win", "lose"]
const SILENT := -80.0
var muted := false
var _players := {}
var _oneshot_pool: Array = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for n in LOOPS:
		var p := AudioStreamPlayer.new()
		var s: AudioStreamWAV = load(DIR + n + ".wav")
		s.loop_mode = AudioStreamWAV.LOOP_FORWARD
		s.loop_begin = 0
		s.loop_end = s.data.size() / 2
		p.stream = s
		p.volume_db = SILENT
		add_child(p)
		_players[n] = p
	for n in ONESHOTS:
		_players[n] = load(DIR + n + ".wav")
	for i in 6:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_oneshot_pool.append(p)
	set_music(-9.0)
	_players.music.play()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_X:
		muted = not muted
		AudioServer.set_bus_mute(0, muted)

func set_music(db: float) -> void:
	_players.music.volume_db = db

func play(name: String, db := -6.0, pitch := 1.0) -> void:
	for p in _oneshot_pool:
		if not p.playing:
			p.stream = _players[name]
			p.volume_db = db
			p.pitch_scale = pitch
			p.play()
			return

## Looping sounds (engine, gravel, pump): `db` <= SILENT stops them.
func set_loop(name: String, db: float, pitch := 1.0) -> void:
	var p: AudioStreamPlayer = _players[name]
	if db <= SILENT:
		if p.playing: p.stop()
		return
	p.volume_db = db
	p.pitch_scale = pitch
	if not p.playing: p.play()

func silence_all_loops() -> void:
	for n in ["engine", "gravel", "pump"]:
		set_loop(n, SILENT)
