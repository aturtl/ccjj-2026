class_name DialogueChangeEnvironment extends DialogueEvent

enum Environments {
	NONE,
	FRONT_YARD,
	LIVING_ROOM,
	KITCHEN,
	HALLWAY,
	BATHROOM,
	BACKYARD
}

@export var environment_holder: Environments
@export var to_pos: Vector2
@export var use_x = false
@export var use_y = false

func _play_line():
	if environment_holder:
		if use_x:
			%MainCamera.to_pos.x = to_pos.x
		if use_y:
			%MainCamera.to_pos.y = to_pos.y
		%Environment.switch_environment(environment_holder)
