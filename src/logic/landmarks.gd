class_name Landmarks
extends RefCounted
## Things a town is known for (Wawel and the dragon in Kraków, the Palace of Culture in Warsaw, the beetle in
## Szczebrzeszyn...). place() puts them in the middle of every town the route passes through; the scenery draws
## them (LandmarkPainter) with a brown tourist board, and the HUD names them while they are in view.

## The current country's landmarks: town name -> [{kind (painter), name, desc}, ...] (one or two per town).
static func by_town() -> Dictionary:
	return GameData.country().landmarks

## Painter kind -> [width, height] in metres (shared by all countries).
static func size(kind: String) -> Array:
	return GameData.rules().landmark_sizes[kind]

## Landmarks along the stage: [{z, lat, kind, name, desc, town, w, h}], in route order.
static func place(stage: Dictionary) -> Array:
	var out := []
	for t in stage.towns:
		var list: Array = by_town().get(t.name, [])
		if list.is_empty():
			continue
		# the middle of the town; the start and finish cities show theirs just after the start / before the line
		var anchor: float = t.z - 20.0
		if t.get("start", false):
			anchor = 110.0
		elif t.get("finish", false):
			anchor = stage.length - 170.0
		for k in mini(list.size(), 2):
			var kind: String = list[k].kind
			var sz := size(kind)
			var side := -1.0 if k == 0 else 1.0
			out.append({"z": anchor + k * 55.0, "lat": side * (10.0 + sz[0] * 0.5), "kind": kind, "name": list[k].name,
				"desc": list[k].desc, "town": t.name, "w": float(sz[0]), "h": float(sz[1])})
	return out

## The landmark the player is looking at (coming up within `ahead` metres, or just passed), or {}.
static func in_view(landmarks: Array, z: float, ahead := 150.0) -> Dictionary:
	for lm in landmarks:
		if z > lm.z - ahead and z < lm.z + 15.0:
			return lm
	return {}
