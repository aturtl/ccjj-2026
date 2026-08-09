@icon("uid://wtyvo4svr0wq")

class_name DialogueChoice extends DialogueLine
## stores info for dialogue line

@export var goto: DialogueLine # only necessary for repeatable dialogue
@export var parallel_gotos = []

@export var choice_text: String = ""

@export var prereq_item: ItemData
@export var prereq_confidence: int


func _ready():
	set_goto_from_child()


func set_goto_from_child():
	for child in self.get_children():
		if child is DialogueLine:
			if !goto:
				goto = child
			else:
				parallel_gotos.append(child)
