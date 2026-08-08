class_name UITalk extends Node2D

@export var box_template: BoxTemplate
@export var choice_template: ChoiceTemplate

@export var in_between_time = .1

@export var instance_count = 3

@export var transitioners: Node2D

var box_instances = {}

var connected_choice_instances = []
var choice_instance_count = 0
var total_choice_instance_count = 0
var choice_spread = PI/2.0
var choice_distance = 150.0

signal talk_ended
signal start_next
signal choice_selected

func _ready():
	box_template.visible = false
	choice_template.visible = false


#region sounds (not implemented)
func play_talk_sound():
	pass
#endregion


#region box
func box_talk(s: String, starting_visible_characters: int = 0):
	var box = add_templated_box_instance(box_template)
	var label = box.label
	
	label.text = s
	label.visible_characters = starting_visible_characters
	
	for i in s.length() - starting_visible_characters:
		await get_tree().create_timer(in_between_time).timeout
		play_talk_sound()
		label.visible_characters += 1
	
	talk_ended.emit()
	
	await get_tree().create_timer(.5).timeout
	
	start_next.emit()


func add_templated_box_instance(box_temp: BoxTemplate):
	var box = box_temp.duplicate()
	add_child(box)
	
	var repl: BoxTemplate = box
	var old: BoxTemplate
	
	for i in instance_count:
		
		if i in box_instances:
			old = box_instances[i]
		
		box_instances[i] = repl
		
		if repl:
			animate_box_instance(i, repl)
		
		repl = old
	
	if old:
		animate_kill_box_instance(old)
	
	box.visible = true
	
	## trigger camera shake
	
	return box


func animate_box_instance(num: int, box: BoxTemplate):
	var pos_x_tween = get_tree().create_tween()
	var pos_y_tween = get_tree().create_tween()
	var rot_tween = get_tree().create_tween()
	var scale_x_tween = get_tree().create_tween()
	var scale_y_tween = get_tree().create_tween()
	
	var speed = .3
	
	
	
	if num == 0:
		
		
		rot_tween.tween_property(box.rotater, "rotation", box.rotater.rotation-.15, speed)
		
		scale_x_tween.tween_property(box.sizer, "scale:x", box.sizer.scale.x*1.2, speed/2.0).set_trans(Tween.TRANS_CIRC)
		scale_y_tween.tween_property(box.sizer, "scale:y", box.sizer.scale.y*.9, speed/2.0).set_trans(Tween.TRANS_CIRC)
		
		scale_x_tween.tween_property(box.sizer, "scale:x", box.sizer.scale.x, speed/2.0).set_trans(Tween.TRANS_CIRC)
		scale_y_tween.tween_property(box.sizer, "scale:y", box.sizer.scale.y, speed/2.0).set_trans(Tween.TRANS_CIRC)
	else:
		
		var angle = box.rotater.rotation - PI*.12*box.sizer.scale.x
		
		var down = Vector2(cos(angle),sin(angle))
		
		pos_x_tween.tween_property(box.positioner, "global_position:x", box.positioner.global_position.x+30.0, speed).set_trans(Tween.TRANS_SPRING)
		pos_y_tween.tween_property(box.positioner, "global_position:y", box.positioner.global_position.y+100.0*(box.sizer.scale.y)*-down.y, speed).set_trans(Tween.TRANS_SPRING)
		
		rot_tween.tween_property(box.rotater, "rotation", angle, speed)
		
		
		scale_x_tween.tween_property(box.sizer, "scale:x", box.sizer.scale.x/1.5, speed).set_trans(Tween.TRANS_SINE)
		scale_y_tween.tween_property(box.sizer, "scale:y", box.sizer.scale.y/1.5, speed).set_trans(Tween.TRANS_SINE)
	
	pos_x_tween.play()
	pos_y_tween.play()
	rot_tween.play()
	scale_x_tween.play()
	scale_y_tween.play()


func animate_kill_box_instance(box: BoxTemplate):
	var kill_tween = get_tree().create_tween()
	
	animate_box_instance(instance_count,box)
	kill_tween.tween_property(box.positioner, "modulate:a", 0.0, .4).set_trans(Tween.TRANS_CUBIC)
	#kill_tween.parallel().tween_property(box.sizer, "scale", 0.0, .2).set_trans(Tween.TRANS_SPRING)
	
	kill_tween.play()
	
	await kill_tween.finished
	
	box.queue_free()
#endregion


#region choices
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
		
		choice_instance.goto = choice_info.goto


func add_templated_choice_instance(choice_temp: ChoiceTemplate):
	var choice = choice_temp.duplicate()
	add_child(choice)
	
	var spread_start = -choice_spread
	var spread_end = choice_spread
	
	var angle = spread_start + spread_end * choice_instance_count/(float(total_choice_instance_count-1)) - (PI-choice_spread)/2.0
	
	var direction = Vector2(cos(angle), sin(angle))
	
	choice.global_position = transitioners.get_node("TransDisplayChoices").global_position + 250.0*direction
	
	choice_instance_count += 1
	
	choice.selected.connect(on_choice_selected)
	connected_choice_instances.append(choice)
	
	choice.visible = true
	
	return choice
	
func on_choice_selected(goto: DialogueLine):
	for choice: ChoiceTemplate in connected_choice_instances:
		choice.selected.disconnect(on_choice_selected)
		choice.queue_free()
	connected_choice_instances.clear()
	choice_instance_count = 0
	
	if goto:
		choice_selected.emit(goto)
		print("emitted")
#endregion


func player_has_item(item: String):
	return true


func player_has_sufficient_sanity(sanity: int):
	return true
