class_name DialogueChoice extends Node
## stores info for dialogue line

@export var goto: DialogueLine # only necessary for repeatable dialogue
@export var choice_text: String = ""
@export var sanity_change: float = 0.0


func _ready():
	if !goto:
		set_goto_from_child()


func set_goto_from_child():
	for child in self.get_children():
		if child is DialogueLine:
			goto = child
