@icon("uid://wtyvo4svr0wq")

class_name DialogueChoice extends DialogueLine
## stores info for dialogue line

@export var choice_text: String = ""

@export var prereq_item: ItemData
@export var prereq_confidence: int
