class_name DialogueReward extends DialogueEvent

@export var reward_text = ""

@onready var ui = %DialogueCanvas.get_node("UIReward")

func _play_line():
	await ui.display(reward_text)
