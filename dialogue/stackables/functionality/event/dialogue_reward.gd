class_name DialogueReward extends DialogueEvent

@export var reward_text = ""

@onready var ui = %DialogueCanvas.get_node("UIReward")

func _run():
	await ui.display(reward_text)
