class_name UIChoiceDisplay extends Node2D

@export var choice_template: ChoiceTemplate

@export var transitioners: Node2D

var connected_choice_instances = []
var choice_instance_count = 0
var total_choice_instance_count = 0
var choice_spread = PI/2.0
var choice_distance = 150.0

signal choice_selected


func _ready():
	choice_template.visible = false


func display_choices(choices: Array):
	total_choice_instance_count = choices.size()
	
	for choice_info:DialogueChoice in choices:
		var text = choice_info.choice_text
		var prereq_item = choice_info.prereq_item
		var prereq_sanity = choice_info.prereq_sanity
		
		if prereq_item != "" and !player_has_item(prereq_item): # skip if player doesnt have item
			continue
		
		if !player_has_sufficient_sanity(choice_info.prereq_sanity): # skip if player has less sanity than req
			continue
		
		var choice_instance: ChoiceTemplate = add_templated_choice_instance(choice_template)
		
		choice_instance.label.text = "[center]"+choice_info.choice_text+"[/center]"
		choice_instance.sprite.play(prereq_item)

		choice_instance.sanity_display.visible = prereq_sanity != 0.0
		choice_instance.sprite.visible = prereq_item != ""
		
		choice_instance.goto = choice_info


func add_templated_choice_instance(choice_temp: ChoiceTemplate):
	var choice = choice_temp.duplicate()
	add_child(choice)
	
	var spread_start = -choice_spread
	var spread_end = choice_spread
	
	var direction = Vector2(0, 1)
	
	if total_choice_instance_count >= 1:
		var angle = spread_start + spread_end * choice_instance_count/(float(total_choice_instance_count-1)) - (PI-choice_spread)/2.0
		direction = Vector2(cos(angle), sin(angle))
	
	choice.global_position = transitioners.get_node("TransDisplayChoices").global_position + 250.0*direction
	
	choice_instance_count += 1
	
	choice.selected.connect(on_choice_selected)
	connected_choice_instances.append(choice)
	
	choice.visible = true
	
	return choice
	
func on_choice_selected(chosen_choice):
	var goto = chosen_choice.goto
	for choice: ChoiceTemplate in connected_choice_instances:
		choice.selected.disconnect(on_choice_selected)
		choice.queue_free()
	connected_choice_instances.clear()
	choice_instance_count = 0
	
	if goto:
		choice_selected.emit(goto)
		print("emitted")


func player_has_item(item: String):
	return true


func player_has_sufficient_sanity(sanity: int):
	return true
