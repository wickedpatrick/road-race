class_name Profile
extends RefCounted
## Car unlocking: everyone starts with the first car; the next one unlocks after UNLOCK_FIRST_KM kilometres
## (about Kraków - Zamość), and every following car needs 20% more kilometres than the one before.
const UNLOCK_FIRST_KM := 325.0
const UNLOCK_GROWTH := 1.2

## Total kilometres needed to unlock car number n (0 = the first car, always available).
static func unlock_km(n: int) -> float:
	var total := 0.0
	var step := UNLOCK_FIRST_KM
	for i in n:
		total += step
		step *= UNLOCK_GROWTH
	return total

static func unlocked_count(km: float) -> int:
	var n := 1
	while n < CarStats.ALL_IDS.size() and km >= unlock_km(n):
		n += 1
	return n

static func is_unlocked(car_id: String, km: float) -> bool:
	return CarStats.ALL_IDS.find(car_id) < unlocked_count(km)

## Progress towards the next car as 0..1, or 1 when all are unlocked.
static func next_progress(km: float) -> float:
	var n := unlocked_count(km)
	if n >= CarStats.ALL_IDS.size():
		return 1.0
	var a := unlock_km(n - 1)
	return clampf((km - a) / (unlock_km(n) - a), 0.0, 1.0)
