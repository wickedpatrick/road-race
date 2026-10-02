extends "res://src/scenes/menu.gd"
func _ready() -> void:
	super()
	var a := OS.get_cmdline_user_args()
	step = int(a[0]) if a.size() > 0 else 0
	sel[1] = int(a[1]) if a.size() > 1 else 1
