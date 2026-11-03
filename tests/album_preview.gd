extends "res://src/scenes/album.gd"
## Dev-only: the album with some postcards collected (not saved). Env RR_COUNTRY, RR_LANG; arg: scroll in pixels.
func _ready() -> void:
	if OS.get_environment("RR_LANG") != "": GameData.set_language(OS.get_environment("RR_LANG"))
	if OS.get_environment("RR_COUNTRY") != "": # without saving the profile
		Session.country = OS.get_environment("RR_COUNTRY")
		GameData.current = Session.country
		Session._apply_place({})
	super()
	var ids := Postcards.cities(Session.country)
	for i in ids.size():
		if i % 3 != 2: Session.postcards[ids[i]] = {"stamps": i % 5 + 1, "year": 2026}
	var a := OS.get_cmdline_user_args()
	if a.size() > 0: _scroll_by(float(a[0]))

## Leaving quits: the menu could save this preview's made-up progress into the real profile.
func _back() -> void:
	get_tree().quit()
