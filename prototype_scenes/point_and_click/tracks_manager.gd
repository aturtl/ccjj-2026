extends Node2D

@export var cam: Camera2D

var initial_position = Vector2(0,0)

func _physics_process(delta):
	var axis = Input.get_axis("ui_left", "ui_right")
	if axis != 0:
		for track in get_children():
			if track is Track:
				track.position.x = initial_position.x + cam.position.x*track.move_factor
