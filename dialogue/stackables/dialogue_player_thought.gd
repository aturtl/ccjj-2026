@icon("res://icons/icon_thought.png")

class_name DialoguePlayerThought extends DialogueLine


@export var goto: DialogueLine # only necessary for repeatable dialogue


func _ready():
	if !goto:
		set_goto_from_child()


func set_goto_from_child():
	for child in self.get_children():
		if child is DialogueLine:
			goto = child
