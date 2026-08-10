extends Node2D


@onready var sprite = $AnimatedSprite2D
@onready var cam = $Camera

var lock = false

var playing = false


func _physics_process(delta):
	if lock:
		return
	var right_axis = Input.get_axis("left", "right")
	position.x += right_axis
	if right_axis != 0.0:
		if !playing:
			playing = true
			sprite.play("walk")
	else:
		if playing:
			sprite.pause()
			playing = false
	
