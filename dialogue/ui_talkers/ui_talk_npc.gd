class_name UITalkNPC extends UITalk

@export var box_template: BoxTemplate

@export var instance_count = 3

@export var transitioners: Node2D
@export var in_between_time = .1

var box_instances = {}

signal talk_ended
signal start_next

func _ready():
	box_template.visible = false


#region sounds (not implemented)
func play_talk_sound():
	pass
#endregion


#region box
func talk(s: String, starting_visible_characters: int = 0):
	var box = add_templated_box_instance(box_template)
	var label = box.label
	
	label.text = s
	label.visible_characters = starting_visible_characters
	
	for i in s.length() - starting_visible_characters:
		await get_tree().create_timer(in_between_time).timeout
		play_talk_sound()
		if label and !label.is_queued_for_deletion():
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
