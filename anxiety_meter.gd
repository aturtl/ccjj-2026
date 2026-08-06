extends ColorRect


@onready var fill_thingy = get_child(0)


func _physics_process(delta):
	fill_thingy.scale.x -= .01 * delta
