@icon("res://icons/icon_event.png")

class_name DialogueFadeScreen extends DialogueLine

@export var fade_time: float = 1.0

enum FadeType {IN, OUT}
@export var fade_type = FadeType.IN

@export var goto: DialogueLine # only necessary for repeatable dialogue

@export var parallel_gotos = [] # VERY SPECIFIC CASES. annoying to use so just use goto,
	# but if you have to, this will absolutely work.
	# also only store DialogueLines in this

func _ready():
	if !goto:
		set_goto_from_child()


func set_goto_from_child():
	for child in self.get_children():
		if child is DialogueLine:
			if !goto:
				goto = child
			else:
				parallel_gotos.append(child)
