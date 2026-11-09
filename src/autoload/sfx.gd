extends Node
## All game audio: engine/gravel/pump loops and one-shot effects (no music but the anthems' first phrases and the
## countries' tunes on arrival). X toggles mute.
const DIR := "res://assets/audio/"
const LOOPS := ["engine", "engine_idle", "gravel", "pump", "siren"] ## looped whole-file by their import settings
const ONESHOTS := ["hit", "beep", "go", "blip", "lowfuel", "refuel_done", "lose", "radar"]
## The tunes of arriving in a country, taking turns: anthem_<code>, the first phrase of its anthem, and motif_<code>,
## the best-known bars of its classical (or folk) tune; a country whose anthem's music is still under copyright has
## a second tune, motif2_<code>, instead of the anthem (so has one without a reliable published score of its anthem).
## Every country has two of them (test_arrival_audio.gd).
const ARRIVAL_KINDS := ["anthem_", "motif_", "motif2_"]
const SILENT := -80.0
const IDLE_FADE_FROM := 0.74 ## engine pitch where an idle loop starts handing over to the driving loop
const IDLE_FADE_SPAN := 0.18 ## ... and has handed over completely
var muted := false
var _engine_db := [0.0, 0.0] ## the car's engine level: [driving, idling] dB (EngineAudio.LEVELS)
var _players := {}
var _oneshot_pool: Array = []
var _arrivals := 0 ## arrivals so far: the anthem and the tune take turns

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# a limiter on the master bus: a loud engine on top of a crash or the siren is held under full scale instead of
	# clipping (it only acts on what goes over)
	var lim := AudioEffectHardLimiter.new()
	lim.ceiling_db = -0.5
	AudioServer.add_bus_effect(0, lim)
	for n in LOOPS:
		var p := AudioStreamPlayer.new()
		if ResourceLoader.exists(DIR + n + ".wav"): p.stream = load(DIR + n + ".wav")
		# mixed by the engine on every platform: the browser's native sample playback clicked on these
		# continuously re-pitched loops
		p.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
		p.volume_db = SILENT
		add_child(p)
		_players[n] = p
	for n in ONESHOTS:
		_players[n] = load(DIR + n + ".wav")
	var codes := GameData.country_codes().duplicate()
	for code in GameData.country_codes(): codes.append_array(GameData.members(code))
	for code in codes:
		for kind in ARRIVAL_KINDS:
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

## The sound of arriving in the country being played: its tunes (ARRIVAL_KINDS) by turns, the anthem first.
## On a map spanning several countries (the Southern Balkans) it is the country of `city`, the one arrived in.
## "" (which play() skips) only for a country without any tune, which the tests do not let through.
func arrival(city := "") -> String:
	_arrivals += 1
	var code: String = GameData.current
	if not GameData.members(code).is_empty() and Geo.city_part(city) != "":
		code = Geo.city_part(city)
	var names := []
	for kind in ARRIVAL_KINDS:
		if _players.has(kind + code): names.append(kind + code)
	return names[(_arrivals - 1) % names.size()] if not names.is_empty() else ""

func play(name: String, db := -6.0, pitch := 1.0) -> void:
	if not _players.has(name): return
	for p in _oneshot_pool:
		if not p.playing:
			p.stream = _players[name]
			p.volume_db = db
			p.pitch_scale = pitch
			p.play()
			return

## The engine loop of the car being driven (engine_<car id>), or the plain one for a car without its own; a car
## with an engine_idle_<car id> (the Hemi's lope) idles on that instead of the driving loop pitched down.
func set_engine(car_id: String) -> void:
	_engine_db = EngineAudio.LEVELS.get(car_id, [0.0, 0.0])
	var path := DIR + "engine_" + car_id + ".wav"
	var stream: AudioStream = load(path) if ResourceLoader.exists(path) else load(DIR + "engine.wav")
	var idle_path := DIR + "engine_idle_" + car_id + ".wav"
	var idle: AudioStream = load(idle_path) if ResourceLoader.exists(idle_path) else null
	for n in ["engine", "engine_idle"]:
		var p: AudioStreamPlayer = _players[n]
		var want: AudioStream = stream if n == "engine" else idle
		if p.stream != want:
			p.stop()
			p.stream = want

## Looping sounds (engine, gravel, pump): `db` <= SILENT stops them.
func set_loop(name: String, db: float, pitch := 1.0) -> void:
	if name == "engine" and db > SILENT:
		# the car's own level, the idling one near idle, the driving one as the revs rise
		db += lerpf(_engine_db[1], _engine_db[0], clampf((pitch - IDLE_FADE_FROM) / IDLE_FADE_SPAN, 0.0, 1.0))
	if name == "engine" and _players["engine_idle"].stream != null:
		# near idle the idle loop takes over (at its own pitch), handing back to the driving loop as the revs rise
		var w := clampf((pitch - IDLE_FADE_FROM) / IDLE_FADE_SPAN, 0.0, 1.0)
		_set_one("engine_idle", db + linear_to_db(maxf(1.0 - w, 0.0001)) if db > SILENT and w < 1.0 else SILENT, 1.0)
		_set_one("engine", db + linear_to_db(maxf(w, 0.0001)) if db > SILENT and w > 0.0 else SILENT, pitch)
		return
	_set_one(name, db, pitch)

func _set_one(name: String, db: float, pitch: float) -> void:
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
