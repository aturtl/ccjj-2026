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


func display_choices(choices: Array, origin: Vector2):
	total_choice_instance_count = choices.size()
	
	for choice_info:DialogueChoice in choices:
		var text = choice_info.choice_text
		var prereq_item = choice_info.prereq_item
		var prereq_confidence = choice_info.prereq_confidence
		
		if prereq_item and !Inventory.has_item(prereq_item): # skip if player doesnt have item
			continue
		
		if Stats.confidence < prereq_confidence: # skip if player has less sanity than req
			continue
		
		var choice_instance: ChoiceTemplate = add_templated_choice_instance(choice_template, origin)
		
		choice_instance.label.text = "[center]"+choice_info.choice_text+"[/center]"
		
		if prereq_item:
			choice_instance.sprite.texture = prereq_item.texture
			choice_instance.sprite.visible = true

		choice_instance.sanity_display.visible = prereq_confidence != 0.0
		
		choice_instance.goto = choice_info


func add_templated_choice_instance(choice_temp: ChoiceTemplate, origin: Vector2):
	var choice = choice_temp.duplicate()
	choice_temp.get_parent().add_child(choice)
	
	var spread_start = -choice_spread
	var spread_end = choice_spread
	
	var direction = Vector2(0, 1)
	
	if total_choice_instance_count >= 1:
		var angle = spread_start + spread_end * choice_instance_count/(float(total_choice_instance_count-1)) - (PI-choice_spread)/2.0
		direction = Vector2(cos(angle), sin(angle))
	
	choice.position = origin + 250.0*direction
	
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
