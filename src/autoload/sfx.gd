extends Node
## All game audio: engine/gravel/pump loops and one-shot effects (no music but the anthems' first phrases on
## arrival). X toggles mute.
const DIR := "res://assets/audio/"
const LOOPS := ["engine", "gravel", "pump", "siren"] ## looped whole-file by their import settings
const ONESHOTS := ["hit", "beep", "go", "blip", "lowfuel", "refuel_done", "win", "lose", "radar"]
const SILENT := -80.0
var muted := false
var _players := {}
var _oneshot_pool: Array = []
var _arrivals := 0 ## arrivals so far: the anthem and the tune take turns

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
	for code in GameData.country_codes(): # on arrival: anthem_<code>, the first phrase of the anthem, and motif_<code>,
		for kind in ["anthem_", "motif_"]: # the best-known bars of the country's classical (or folk) tune
			if ResourceLoader.exists(DIR + kind + code + ".wav"):
				_players[kind + code] = load(DIR + kind + code + ".wav")
	for i in 6:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_oneshot_pool.append(p)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_X:
		muted = not muted
		AudioServer.set_bus_mute(0, muted)

## The sound of arriving in the country being played: its anthem's first phrase and its classical tune by turns
## (the anthem alone when there is no tune), or the fanfare.
func arrival() -> String:
	_arrivals += 1
	for name in (["motif_", "anthem_"] if _arrivals % 2 == 0 else ["anthem_", "motif_"]):
		if _players.has(name + GameData.current):
			return name + GameData.current
	return "win"

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
