extends Node
## All game audio: engine/gravel/pump loops and one-shot effects (no music). X toggles mute.
const DIR := "res://assets/audio/"
const LOOPS := ["engine", "gravel", "pump", "siren"] ## looped whole-file by their import settings
const ONESHOTS := ["hit", "beep", "go", "blip", "lowfuel", "refuel_done", "win", "lose", "radar"]
const SILENT := -80.0
var muted := false
var _players := {}
var _oneshot_pool: Array = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for n in LOOPS:
		var p := AudioStreamPlayer.new()
		p.stream = load(DIR + n + ".wav")
		# mixed by the engine on every platform: the browser's native sample playback clicked on these
		# continuously re-pitched loops
		p.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
		p.volume_db = SILENT
		add_child(p)
		_players[n] = p
	for n in ONESHOTS:
		_players[n] = load(DIR + n + ".wav")
	for i in 6:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_oneshot_pool.append(p)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_X:
		muted = not muted
		AudioServer.set_bus_mute(0, muted)

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
	for n in LOOPS:
		set_loop(n, SILENT)
