class_name DialogueObject extends Node

@export var goto: DialogueObject # only necessary for repeatable dialogue
@export var parallel_gotos = [] # VERY SPECIFIC CASES. annoying to use so just use goto,
	# but if you have to, this will absolutely work.
	# also only store DialogueLines in this

@export var after_wait: float = 0.0

@onready var dm: DialogueManager = %DialogueManager

func _ready():
	if !goto:
		set_goto_from_child()


func set_goto_from_child():
	for child in self.get_children():
		if child is DialogueObject:
			if !goto:
				goto = child
			else:
				parallel_gotos.append(child)


func _play_line():
	pass
