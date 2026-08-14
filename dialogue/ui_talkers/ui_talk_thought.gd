class_name UITalkThought extends UITalk

@export var box_template: BoxTemplate
@export var in_between_time = .04
@export var end_wait = .7

var box_instance: BoxTemplate

signal talk_ended
signal start_next

func _ready():
	box_template.visible = false


#region sounds (not implemented)
func play_talk_sound():
	pass
#endregion


#region box
func talk(dl: DialogueLine, origin: Vector2 = Vector2(0, 0), starting_visible_characters: int = 0):
	if dl.in_between_time == -1.0:
		dl.in_between_time = in_between_time
	
	var s = dl.dialogue
	
	if s == "":
		talk_ended.emit()
		start_next.emit()
		animate_kill_box_instance(box_instance)
		return
	
	var box = add_templated_box_instance(box_template, origin)
	var label = box.label
	
	label.text = s
	label.visible_characters = starting_visible_characters
	
	var true_index = starting_visible_characters
	
	for i in s.length() - starting_visible_characters:
		if s[true_index] != ' ':
			if dl.dynamic_range == -1.0:
				get_parent().get_parent().play_blip() #temp
			else:
				get_parent().get_parent().play_blip(dl.dynamic_range) #temp
		await get_tree().create_timer(dl.in_between_time).timeout
		if label and !label.is_queued_for_deletion():
			label.visible_characters += 1
		true_index += 1
	
	talk_ended.emit()
	
	await get_tree().create_timer(end_wait).timeout
	
	start_next.emit()


func add_templated_box_instance(box_temp: BoxTemplate, origin: Vector2):
	var box = box_temp.duplicate()
	
	add_child(box)
	box.global_position = origin
	
	if box_instance:
		animate_kill_box_instance(box_instance)
	
	box_instance = box
	box.visible = true
	
	## trigger camera shake
	
	return box


func animate_box_instance(num: int, box: BoxTemplate):
	pass


func kill_box_instance():
	if box_instance:
		animate_kill_box_instance(box_instance)


func animate_kill_box_instance(box: BoxTemplate):
	var kill_tween = get_tree().create_tween()
	
	kill_tween.tween_property(box.positioner, "modulate:a", 0.0, .4).set_trans(Tween.TRANS_CUBIC)
	#kill_tween.parallel().tween_property(box.sizer, "scale", 0.0, .2).set_trans(Tween.TRANS_SPRING)
	
	kill_tween.play()
	
	await kill_tween.finished
	
	
	box.queue_free()
#endregion
