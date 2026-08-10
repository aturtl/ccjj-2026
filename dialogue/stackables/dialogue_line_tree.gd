@tool
class_name DialogueLineTree extends Node2D

var descendents = []

func get_all_descendents(parent:Node):
	for child in parent.get_children():
		if child is DialogueLine:
			descendents.append(child)
			get_all_descendents(child)
			
			


func _ready():
	if Engine.is_editor_hint(): # checks once per editor run
		get_all_descendents(self)
		print("")
		print_rich("[color=yellow]TREE: ", name, "[/color]")
		for descendent in descendents:
			if descendent is DialogueReward:
				print_rich("[color=purple]Reward Display: ", descendent.reward_text, "[/color]")
			elif descendent is DialogueStatSetter:
				print_rich("[color=magenta]Stat Change: ", descendent.confidence_reward, " + ", descendent.add_item, " - ", descendent.remove_item, "[/color]")
			elif descendent is DialogueChoice:
				print("Choice: ", descendent.choice_text)
				if descendent.prereq_confidence != 0.0 or descendent.prereq_item:
					print_rich("[color=cyan] <*> Requirements: ", descendent.prereq_confidence, " + ", descendent.prereq_item, "[/color]")
				else:
					print_rich("[color=red] * Requirements: NONE[/color]")
