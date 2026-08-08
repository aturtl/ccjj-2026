class_name UITalkThought extends UITalk

@export var box_template: BoxTemplate
@export var in_between_time = .1

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
func talk(s: String, starting_visible_characters: int = 0):
	var box = add_templated_box_instance(box_template)
	var label = box.label
	
	label.text = s
	label.visible_characters = starting_visible_characters
	
	for i in s.length() - starting_visible_characters:
		await get_tree().create_timer(in_between_time).timeout
		play_talk_sound()
		if !label.is_queued_for_deletion():
			label.visible_characters += 1
	
	talk_ended.emit()
	
	await get_tree().create_timer(.5).timeout
	
	start_next.emit()


func add_templated_box_instance(box_temp: BoxTemplate):
	var box = box_temp.duplicate()
	add_child(box)
	
	if box_instance:
		animate_kill_box_instance(box_instance)
	
	box_instance = box
	box.visible = true
	
	## trigger camera shake
	
	return box


func animate_box_instance(num: int, box: BoxTemplate):
	pass


func animate_kill_box_instance(box: BoxTemplate):
	var kill_tween = get_tree().create_tween()
	
	kill_tween.tween_property(box.positioner, "modulate:a", 0.0, .4).set_trans(Tween.TRANS_CUBIC)
	#kill_tween.parallel().tween_property(box.sizer, "scale", 0.0, .2).set_trans(Tween.TRANS_SPRING)
	
	kill_tween.play()
	
	await kill_tween.finished
	
	
	box.queue_free()
#endregion
