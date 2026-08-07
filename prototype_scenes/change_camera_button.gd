class_name CamButton extends Button

@export var cam: Camera2D


func bd():
	cam.make_current()


func _ready():
	button_down.connect(bd)
