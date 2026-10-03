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
	# cruising: change up early to save fuel; accelerating: kick down
	var yb := Gearbox.new(43.0)
	yb.gear = 2
	for i in 60: yb.update(1.0 / 60.0, 57.0 / 3.6, false)
	t.check(yb.gear >= 3 and yb.gear <= 4, "cruising at 57 km/h shifts up to D3/D4 (got D%d)" % yb.gear)
	var cruise := yb.gear
	for i in 12: yb.update(1.0 / 60.0, 57.0 / 3.6, true)
	t.check(yb.gear == cruise, "a short tap on the gas keeps the gear")
	t.check(yb.pull(57.0 / 3.6) < 0.7, "a high cruising gear pulls weakly")
	for i in 10: yb.update(1.0 / 60.0, 57.0 / 3.6, true)
	t.check(yb.gear < cruise and yb.gear == yb.gear_for(57.0 / 3.6), "holding the gas kicks down (got D%d)" % yb.gear)
	var g3 := Gearbox.new(43.0)
	g3.gear = 3
	g3.update(1.0 / 60.0, 70.0 / 3.6, false)
	t.check(g3.gear == 4, "up-shifts one gear at a time")
	t.check(yb.eco_gear(90.0 / 3.6) == 6 and yb.eco_gear(0.0) == 1, "eco gear: D6 at 90 km/h, D1 at a standstill")
	var ok := true
	for v in range(0, 44):
		var g2 := Gearbox.new(43.0)
		g2.gear = 6
		g2.update(0.016, float(v), false)
		if float(v) > g2.top_speed_for_gear(g2.gear) + 0.01: ok = false
	t.check(ok, "never over-revs a gear")
	t.check(is_equal_approx(yb.pull(57.0 / 3.6), 1.0), "after the kick-down the full power is there")
