extends SceneTree
## Dev helper: prints where towns, signs and zones are on a route (for previews). Args: from to
func _init() -> void:
	var a := OS.get_cmdline_user_args()
	var s := Route.build(a[0], a[1])
	print("%s  %d km  length %d  duration %d  stations %s" % [s.name, s.km, s.length, s.duration, str(s.stations)])
	for zn in s.zones: print("zone %6d-%6d %-11s %s" % [zn.z0, zn.z1, zn.biome, zn.region])
	for t in s.towns: print("town %6d ±%d %s" % [t.z, t.half, t.name])
	var items := Scenery.build(s, 1)
	var keys := items.keys()
	keys.sort()
	for k in keys:
		for it in items[k]:
			if it.type in ["board", "region"]:
				print("%-6s %6d %s" % [it.type, it.z, str(it.get("lines", it.get("text", "")))])
	quit()
