class_name DialogueLine extends Node
## stores info for dialogue line

@export var goto: DialogueLine # only necessary for repeatable dialogue

@export var dialogue: String = ""
@export_enum("STATEMENT","QUESTION") var dialogue_type = 0 # more types can be added, i.e. EXCLAMATION



func _ready():
	if !goto:
		set_goto_from_child()


func set_goto_from_child():
	for child in self.get_children():
		if child is DialogueLine:
			goto = child
