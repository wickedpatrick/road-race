extends Node
var car_id := "xc60"
var season := "summer"
var from_city := "krakow"
var to_city := "rzeszow"
var menu_step := 0 ## step the menu opens at (results can jump straight to choosing the next destination)
var last_result := {}

func stage() -> Dictionary:
	return Route.build(from_city, to_city)
