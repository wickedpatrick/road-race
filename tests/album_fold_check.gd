extends "res://src/scenes/album.gd"
## Dev check (tests/run.sh): the routes' postcards start folded and a click on a route's title unfolds them; a click
## on a collected card turns it over, a second click turns it back. Made-up progress is never saved: it quits.
func _ready() -> void:
	Session.country = "pl"
	GameData.current = "pl"
	Session._apply_place({})
	super()
	var ok := true
	var towns_shown := _layout.filter(func(it): return it.get("town", false)).size()
	if towns_shown != 0: ok = false; print("routes not folded: %d towns" % towns_shown)
	var head: Dictionary = _layout.filter(func(it): return it.has("route"))[0]
	scroll = clampf(head.y - 20.0, 0.0, _max_scroll())
	_tap(_item_rect(head).get_center())
	var shown := _layout.filter(func(it): return it.get("town", false)).size()
	if shown != head.route.towns.size(): ok = false; print("a click did not unfold the route: %d" % shown)
	var first: Dictionary = _layout[0]
	Session.postcards[first.card] = {"stamps": 1, "year": 2026}
	scroll = 0.0
	_tap(_item_rect(first).get_center())
	if _back_key != first.key: ok = false; print("a click did not turn the card over")
	_tap(_item_rect(first).get_center())
	if _back_key != "": ok = false; print("a second click did not turn it back")
	print("PASS" if ok else "FAIL")
	get_tree().quit()
