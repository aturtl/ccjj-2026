extends ColorRect


@export var duck_animation: ColorRect


func _physics_process(delta):
	if Input.is_action_pressed("ui_down"):
		visible = false
		duck_animation.visible = true
	else:
		visible = true
		duck_animation.visible = false
