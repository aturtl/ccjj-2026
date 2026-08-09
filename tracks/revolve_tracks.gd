extends Node2D


@export var background_track: Track

var travel_gradient: float

var screen_size = 1152.0


func set_relative_track_positions():
	for track in get_children():
		if track is Track:
			var unit: float = 1.0/(background_track.size_x/track.size_x)
			track.position.x = unit*travel_gradient*screen_size
			print(unit, track)


func _physics_process(delta):
	#if travel_gradient > 1.0:
		#travel_gradient -= 1.0
	#elif travel_gradient < 0.0:
		#travel_gradient += 1.0
	travel_gradient += .01
	set_relative_track_positions()
