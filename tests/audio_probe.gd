extends Node
## Dev-only: plays the engine loop loud while sweeping its pitch idle -> max (for click analysis with --write-movie).
var t := 0.0
func _process(dt: float) -> void:
	t += dt
	Sfx.set_loop("engine", -6.0, lerpf(EngineAudio.IDLE, EngineAudio.MAX_PITCH, clampf(t / 6.0, 0.0, 1.0)))
