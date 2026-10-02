extends RefCounted
func run(t) -> void:
	var f := Fuel.new(40.0, 0.5, 50.0)
	t.check(is_equal_approx(f.level, 40.0), "starts full")
	var eco := f.per_metre(Fuel.ECO_SPEED)
	t.check(is_equal_approx(f.per_metre(50.0), eco * 2.0), "top speed burns twice as much per km as 90 km/h")
	var best := true
	for v in [5.0, 15.0, 20.0, 30.0, 40.0, 50.0]:
		if f.per_metre(v) <= eco: best = false
	t.check(best, "90 km/h is the most economical speed")
	t.check(is_equal_approx(f.rate(0.0), 0.5 * Fuel.IDLE_BURN), "standing still only idles")
	t.check(absf(f.rate(50.0) - 0.5 * (1.0 + Fuel.IDLE_BURN)) < 0.001, "burn_at_max is the rate at top speed")
	f.burn(10.0, 50.0)
	t.check(absf(f.level - (40.0 - 10.0 * f.rate(50.0))) < 0.001, "burn over time")
	var added := f.refuel(1.0, 50.0)
	t.check(f.level == 40.0 and added > 0.0, "refuel capped at capacity")
	var f3 := Fuel.new(1.0, 10.0, 50.0)
	f3.burn(10.0, 50.0)
	t.check(f3.is_empty() and f3.level == 0.0, "empty and non-negative")
	t.check(is_equal_approx(f.ratio(), 1.0), "ratio full")
	t.check(absf(Fuel.new(65.0, 0.45, 56.0).litres_per_100km(25.0, 14.0) - 5.6) < 0.2, "Volvo shows a plausible l/100 km at 90")
