extends RefCounted
const DT := 1.0 / 60.0

## Runs the box for `secs` at a steady speed and returns the gears it went through (changes only).
static func _drive(g: Gearbox, secs: float, kmh: float, accelerating: bool, need := 0.0) -> Array:
	var seen := [g.gear]
	for i in int(secs / DT):
		g.update(DT, kmh / 3.6, accelerating, need)
		if g.gear != seen[-1]: seen.append(g.gear)
	return seen

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
	# pulling power: full in the most powerful gear, weaker in every higher one
	var y := Gearbox.new(43.0)
	var v57 := 57.0 / 3.6
	t.check(is_equal_approx(y.pull_in(v57, y.gear_for(v57)), 1.0), "the most powerful gear pulls fully")
	t.check(y.pull_in(v57, 4) < 1.0 and y.pull_in(v57, 5) < y.pull_in(v57, 4), "higher gears pull weaker")
	t.check(y.eco_gear(90.0 / 3.6) == 6 and y.eco_gear(0.0) == 1, "eco gear: D6 at 90 km/h, D1 at a standstill")
	t.check(y.eco_gear(v57, 0.9) < y.eco_gear(v57), "uphill the eco gear is lower")
	# off the gas with revs to spare: two gears up at once
	var s := Gearbox.new(43.0)
	s.gear = 3
	var seen := _drive(s, 0.1, 70.0, false)
	t.check(seen == [3, 5], "off the gas at 70 km/h: D3 -> D5 in one shift (got %s)" % [seen])
	# only one gear up when the second would make the engine labour
	var s1 := Gearbox.new(43.0)
	s1.gear = 3
	_drive(s1, 0.1, 57.0, false)
	t.check(s1.gear == 4, "at 57 km/h only D3 -> D4 (got D%d)" % s1.gear)
	# holding the speed: settles in the eco gear and does not hunt
	var c := Gearbox.new(43.0)
	c.gear = 2
	_drive(c, 1.0, 57.0, false)
	var cruise := c.gear
	t.check(cruise >= 3 and cruise <= 4, "cruising at 57 km/h settles in D3/D4 (got D%d)" % cruise)
	t.check(_drive(c, 5.0, 57.0, false) == [cruise], "a steady speed keeps the gear")
	# a short tap on the gas keeps the gear, holding it kicks down two gears, then to full power
	var k := Gearbox.new(55.0)
	k.gear = 6
	var v100 := 100.0 / 3.6
	t.check(_drive(k, 0.2, 100.0, true) == [6], "a short tap on the gas keeps the gear")
	_drive(k, 0.15, 100.0, true)
	t.check(k.gear == 4, "holding the gas kicks down two gears D6 -> D4 (got D%d)" % k.gear)
	_drive(k, 1.0, 100.0, true)
	t.check(k.gear == k.gear_for(v100) and is_equal_approx(k.pull(v100), 1.0), "keeping the gas down: the most powerful gear (got D%d)" % k.gear)
	# no kick-down when the gear already pulls well
	var nk := Gearbox.new(43.0)
	nk.gear = nk.gear_for(v57)
	t.check(_drive(nk, 0.6, 57.0, true) == [nk.gear_for(v57)], "no kick-down in the most powerful gear")
	# letting go of the gas after the kick-down: back up two gears
	_drive(k, 0.1, 100.0, false)
	t.check(k.gear == 6, "gas released at 100 km/h: back up to D6 (got D%d)" % k.gear)
	# slowing down gently: one gear at a time
	var b := Gearbox.new(55.0)
	b.gear = 6
	var downs := []
	var kmh := 130.0
	var ok_steps := true
	while kmh > 20.0:
		var before := b.gear
		b.update(DT, kmh / 3.6, false)
		if b.gear < before:
			downs.append(b.gear)
			if before - b.gear > 1: ok_steps = false
		kmh -= 15.0 * DT
	t.check(ok_steps and downs.size() >= 3, "slowing down: changes down one gear at a time (got %s)" % [downs])
	t.check(b.gear <= 2, "slowed to 20 km/h: low gear (got D%d)" % b.gear)
	# braking hard: the gear keeps up with the speed (skips gears when it has to)
	var hb := Gearbox.new(50.0)
	hb.gear = 6
	kmh = 150.0
	var lugging := 0.0
	while kmh > 25.0:
		hb.update(DT, kmh / 3.6, false)
		if hb.rpm(kmh / 3.6) < Gearbox.LUG_DOWN * 0.8: lugging += DT
		kmh -= 86.0 * DT
	t.check(lugging < 0.25 and hb.gear <= 2, "hard braking: revs stay up, low gear at the end (lugged %.2fs, D%d)" % [lugging, hb.gear])
	# a hard stop drops straight to D1
	var st := Gearbox.new(55.0)
	st.gear = 5
	st.update(DT, 0.0, false)
	t.check(st.gear == 1, "stopped: D1")
	# uphill: no shift up into a gear that cannot hold the speed; downhill: keeps the gear for engine braking
	var up := Gearbox.new(43.0)
	up.gear = 3
	_drive(up, 1.0, 70.0, false, 0.8)
	t.check(up.gear < 5, "uphill at 70 km/h does not go up to D5 (got D%d)" % up.gear)
	var dn := Gearbox.new(43.0)
	dn.gear = 4
	_drive(dn, 1.0, 70.0, false, -0.3)
	t.check(dn.gear == 4, "downhill keeps the gear (got D%d)" % dn.gear)
	# never over-revs; no shift sooner than the shift time after the previous one, except the forced ones
	var ok := true
	for v in range(0, 44):
		var g2 := Gearbox.new(43.0)
		g2.gear = 6
		g2.update(DT, float(v), false)
		if float(v) > g2.top_speed_for_gear(g2.gear) + 0.01: ok = false
	t.check(ok, "never over-revs a gear")
	var w := Gearbox.new(43.0)
	var shifts := 0
	var last := -1.0
	var last_up := true
	var fast := false
	var sp := 15.0
	for i in 600:
		var before := w.gear
		var acc := (i / 90) % 2 == 0
		sp = clampf(sp + (3.0 if acc else -2.0) * DT, 5.0, 42.0)
		w.update(DT, sp, acc)
		if w.gear != before:
			shifts += 1
			var gap := Gearbox.SHIFT_TIME if last_up else Gearbox.DOWN_SHIFT_TIME
			var forced := w.gear == w.gear_for(sp) and before < w.gear
			if last >= 0.0 and i * DT - last < gap - 0.001 and not forced: fast = true
			last = i * DT
			last_up = w.gear > before
	t.check(not fast and shifts > 0, "no shift sooner than the shift time after the previous one")
