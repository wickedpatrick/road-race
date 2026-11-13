extends RefCounted
## The shop (Shop): the levels of an upgrade, what the upgrades do to the cars and the stage, the faster car
## unlocking; the device's country; the night roads (Route.night_roads).
func run(t) -> void:
	var b := ["speed_5"]
	t.check(Shop.can_buy(b, "speed_10") and not Shop.can_buy(b, "speed_5"), "+10% after +5%, not +5% twice")
	t.check(not Shop.can_buy(["speed_10"], "speed_5"), "no +5% with +10% owned")
	var car: Dictionary = CarStats.by_id("yaris")
	var tuned := Shop.tuned(car, ["speed_10", "brakes_20", "tank_10"])
	t.check(is_equal_approx(tuned.max_speed, car.max_speed * 1.1) and is_equal_approx(tuned.brake, car.brake * 1.2)
		and tuned.tank == car.tank + 10.0 and car.tank == CarStats.by_id("yaris").tank, "upgrades on a copy of the car")
	var m := Shop.stage_mods(["police_chance", "police_150"])
	t.check(is_equal_approx(m.police_escape, 0.7) and m.escape_kmh == 150.0, "the police upgrades: 70%, from 150 km/h")
	var st := Route.build("krakow", "katowice")
	st["bought"] = ["speed_10"]
	st["escape_kmh"] = 150.0
	var race := Race.new("yaris", st, 1)
	t.check(is_equal_approx(race.stats.max_speed, car.max_speed * 1.1) and race.police_rules.escape_kmh == 150.0
		and GameData.rules().police.escape_kmh != 150.0, "the race drives with the upgrades, the rules untouched")
	var s = load("res://src/autoload/session.gd").new()
	s.total_km = 300.0
	t.check(Profile.unlocked_count(s.car_km()) == 1, "300 km: one car")
	t.check(is_equal_approx(s.km_to_car(1), Profile.unlock_km(1) - 300.0), "the kilometres still to drive for the next car")
	s.bought = ["cars_all"]
	t.check(Profile.unlocked_count(s.car_km()) == CarStats.ids().size(), "every car bought")
	s.free()
	t.check(GameData.home_country("pl_PL") == "pl" and GameData.home_country("en_US") == "us" and GameData.home_country("nl_NL") == "bx"
		and GameData.home_country("ja_JP") == "pl" and GameData.home_country("en") == "pl", "the device's country (Poland when not in the game)")
	for code in ["pl", "de", "gb"]:
		var was := GameData.current
		GameData.current = code
		var n := Geo.roads().size()
		var night := Route.night_roads()
		t.check(night.size() == roundi(n * 0.1) and night.size() > 0, "%s: a tenth of its roads at night (%d of %d)" % [code, night.size(), n])
		GameData.current = was
