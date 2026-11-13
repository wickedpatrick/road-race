extends RefCounted
## Car unlocking by kilometres driven.
func run(t) -> void:
	t.check(Profile.unlocked_count(0.0) == 1 and Profile.is_unlocked("yaris", 0.0), "only the Yaris at the start")
	t.check(not Profile.is_unlocked("octavia", 300.0), "Octavia still locked at 300 km")
	t.check(Route.build("krakow", "zamosc").km == int(Profile.UNLOCK_FIRST_KM), "first unlock = one Kraków - Zamość trip")
	t.check(Profile.is_unlocked("octavia", 325.0), "Octavia after one Kraków - Zamość")
	t.check(is_equal_approx(Profile.unlock_km(2) - Profile.unlock_km(1), Profile.UNLOCK_FIRST_KM * 1.2), "each next car needs 20% more")
	t.check(Profile.unlocked_count(1.0e6) == CarStats.ids().size(), "all cars eventually")
	t.check(absf(Profile.next_progress(325.0 + 195.0) - 0.5) < 0.001, "progress bar towards the next car")
	# the last two cars take many times longer: the 6th three times its step, the 7th five times
	var step := func(n): return Profile.UNLOCK_FIRST_KM * pow(Profile.UNLOCK_GROWTH, n - 1)
	t.check(is_equal_approx(Profile.unlock_km(5) - Profile.unlock_km(4), step.call(5) * 3.0), "the 6th car: three times its step")
	t.check(is_equal_approx(Profile.unlock_km(6) - Profile.unlock_km(5), step.call(6) * 5.0), "the 7th car: five times its step")
