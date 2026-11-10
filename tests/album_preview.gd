extends "res://src/scenes/album.gd"
## Dev-only: the album with some postcards collected (not saved). Env RR_COUNTRY, RR_LANG, RR_FLIP (cards turned
## over), RR_OPEN (the first route unfolded); arg: scroll in pixels.
func _ready() -> void:
	Session.save_path = "res://.godot/rr_preview_profile.json" # a preview never writes the player's profile
	if OS.get_environment("RR_LANG") != "": GameData.set_language(OS.get_environment("RR_LANG"))
	if OS.get_environment("RR_COUNTRY") != "": # without saving the profile
		Session.country = OS.get_environment("RR_COUNTRY")
		GameData.current = Session.country
		Session._apply_place({})
	super()
	var ids := Postcards.cities(Session.country)
	for i in ids.size():
		if i % 3 != 2: Session.postcards[ids[i]] = {"stamps": i % 5 + 1, "year": 2026}
	var towns := Postcards.towns(Session.country)
	for i in towns.size():
		if i % 3 != 1: Session.postcards[towns[i]] = {"stamps": 1, "year": 2026}
	if OS.get_environment("RR_FLIP") != "": # the first two cards turned over (the second one half-way)
		_back_key = ids[0]
		_face[ids[0]] = 1.0
		_face[ids[1]] = 0.3
	if OS.get_environment("RR_OPEN") != "": # the first route unfolded
		var rts := Postcards.routes(Session.country)
		if not rts.is_empty(): _open[_route_key(rts[0])] = true
		_lay_out()
	var a := OS.get_cmdline_user_args()
	if a.size() > 0: _scroll_by(float(a[0]))

## Leaving quits: the menu could save this preview's made-up progress into the real profile.
func _back() -> void:
	get_tree().quit()
