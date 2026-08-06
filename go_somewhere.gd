extends Button

@onready var cam = get_parent()
@export var new_position = Vector2()

func bd():
	cam.global_position = new_position


func _ready():
	button_down.connect(bd)
