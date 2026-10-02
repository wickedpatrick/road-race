extends SceneTree
var failures := 0
var passes := 0
func check(cond: bool, msg: String) -> void:
	if cond:
		passes += 1
	else:
		print("FAIL ", msg)
		failures += 1
func _init() -> void:
	var files := DirAccess.get_files_at("res://tests")
	files.sort()
	for f in files:
		if f.begins_with("test_") and f.ends_with(".gd"):
			var t = load("res://tests/" + f).new()
			t.run(self)
	print("RESULT: %d passed, %d failed" % [passes, failures])
	quit(1 if failures > 0 else 0)
