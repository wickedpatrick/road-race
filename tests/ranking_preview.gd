extends "res://src/scenes/ranking.gd"
## Dev-only: the ranking screen. Args: road|country [from] [to] [the player's time as a share of the road's best, 0:
## none] [roads driven, for the country's ranking] [the place climbed from, e.g. 101: the climb's animation]. RR_COUNTRY=cz for another map, RR_LANG=de, RR_TOUCH=1. The made-up
## player's times stay in memory; nothing is saved (any back quits).
func _ready() -> void:
	Session.save_path = "res://.godot/rr_preview_profile.json" # a preview never writes the player's profile
	if OS.get_environment("RR_LANG") != "": GameData.set_language(OS.get_environment("RR_LANG"))
	Session.country = OS.get_environment("RR_COUNTRY") if OS.get_environment("RR_COUNTRY") != "" else "pl" # in memory only
	GameData.current = Session.country
	if OS.get_environment("RR_TOUCH") == "1": Screen.touch = true
	var a := OS.get_cmdline_user_args()
	var mode: String = a[0] if a.size() > 0 else "road"
	var cc := Session.country
	var all := Rankings.keys(cc)
	var from: String = a[1] if a.size() > 1 else all[0].split("|")[0]
	var to: String = a[2] if a.size() > 2 else all[0].split("|")[1]
	var share := float(a[3]) if a.size() > 3 else 1.05
	var driven := int(a[4]) if a.size() > 4 else all.size()
	var mine := {}
	for i in mini(driven, all.size()):
		mine[all[i]] = {"t": snappedf(Rankings.best(cc, all[i]) * 1.12, 0.1), "car": "octavia", "weather": "sun", "date": "2026-11-10"}
	var k := Rankings.key(from, to)
	if not all.has(k): k = all[0]
	if share > 0.0:
		mine[k] = {"t": snappedf(Rankings.best(cc, k) * share, 0.1), "car": "bmw530", "weather": "rain", "date": "2026-11-10"}
	else:
		mine.erase(k)
	Session.rankings = {cc: mine}
	var keys := [k]
	for x in all:
		if x != k and keys.size() < 3: keys.append(x)
	Session.ranking_view = {"keys": keys, "i": 0, "country": mode == "country", "back": "menu"}
	if a.size() > 5: Session.ranking_view["climb"] = {k: int(a[5])}
	super()

func _back() -> void:
	get_tree().quit()
