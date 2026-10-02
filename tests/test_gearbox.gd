extends RefCounted
func run(t) -> void:
	var g := Gearbox.new(50.0)
	t.check(g.gear_for(0.0) == 1, "gear 1 at speed 0")
	t.check(g.gear_for(50.0) == 6, "gear 6 at vmax")
	t.check(g.gear_for(-5.0) == 1, "negative speed still gear 1 (no reverse)")
	var prev := 1
	var mono := true
	for i in range(0, 101):
		var gr := g.gear_for(i * 0.5)
		if gr < prev: mono = false
		prev = gr
	t.check(mono, "gear monotonic")
	t.check(g.gear_for(500.0) == 6, "gear capped at 6")
