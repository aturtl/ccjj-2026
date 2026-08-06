extends Camera2D

const MOVEMENT = 250

func _physics_process(delta):
	if Input.is_action_pressed("ui_right"):
		position.x += MOVEMENT*delta
	if Input.is_action_pressed("ui_left"):
		position.x -= MOVEMENT*delta
