extends Button


@export var display: Node2D


func bd():
	display.visible = !display.visible


func _ready():
	button_down.connect(bd)
