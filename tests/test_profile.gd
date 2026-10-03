extends RefCounted
## Car unlocking by kilometres driven.
func run(t) -> void:
	t.check(Profile.unlocked_count(0.0) == 1 and Profile.is_unlocked("yaris", 0.0), "only the Yaris at the start")
	t.check(not Profile.is_unlocked("octavia", 300.0), "Octavia still locked at 300 km")
	t.check(Route.build("krakow", "zamosc").km == int(Profile.UNLOCK_FIRST_KM), "first unlock = one Kraków - Zamość trip")
	t.check(Profile.is_unlocked("octavia", 325.0), "Octavia after one Kraków - Zamość")
	t.check(is_equal_approx(Profile.unlock_km(2) - Profile.unlock_km(1), Profile.UNLOCK_FIRST_KM * 1.2), "each next car needs 20% more")
	t.check(Profile.unlocked_count(1.0e6) == CarStats.ALL_IDS.size(), "all cars eventually")
	t.check(absf(Profile.next_progress(325.0 + 195.0) - 0.5) < 0.001, "progress bar towards the next car")
