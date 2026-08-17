class_name DialogueChangeState extends DialogueEvent

@export var state_holder: States
@export var state: String

@onready var dc = %DialogueConnectors

func _play_line():
	state_holder.set_state(state)
