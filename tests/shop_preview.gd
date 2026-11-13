extends "res://src/scenes/shop.gd"
## Dev-only: the shop with a few products bought (in memory). Args: [the card picked]
func _ready() -> void:
	Session.save_path = "res://.godot/rr_preview_profile.json" # a preview never writes the player's profile
	Session.bought = ["speed_10", "tank_10", "police_150"]
	super()
	var a := OS.get_cmdline_user_args()
	if a.size() > 0: sel = int(a[0])

func _back() -> void:
	get_tree().quit()
