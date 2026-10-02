extends RefCounted
func run(t) -> void:
	var vmax := 50.0
	t.check(is_equal_approx(EngineAudio.pitch(0.0, vmax, false), EngineAudio.IDLE), "idle pitch at standstill")
	t.check(EngineAudio.pitch(0.0, vmax, true) > EngineAudio.pitch(0.0, vmax, false), "throttle raises pitch")
	t.check(EngineAudio.pitch(5.0, vmax, false) > EngineAudio.pitch(1.0, vmax, false), "pitch rises with speed inside a gear")
	var top1 := vmax / 6.0
	t.check(EngineAudio.pitch(top1 + 0.2, vmax, false) < EngineAudio.pitch(top1 - 0.2, vmax, false), "pitch drops after an upshift")
	var ok := true
	for i in 101:
		var p := EngineAudio.pitch(vmax * i / 100.0, vmax, true)
		if p < EngineAudio.MIN_PITCH or p > EngineAudio.MAX_PITCH: ok = false
	t.check(ok, "pitch stays within limits")
	t.check(EngineAudio.pitch(-3.0, vmax, false) == EngineAudio.pitch(0.0, vmax, false), "negative speed treated as 0")
