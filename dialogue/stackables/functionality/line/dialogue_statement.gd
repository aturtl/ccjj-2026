@icon("res://placeholders/placeholder_cake_0001.png")

class_name DialogueStatement extends DialogueLine


@export var dialogue: String = ""

@onready var ui_right: UITalkNPC = %DialogueCanvas.get_node("UITalkNPCRight")
@onready var ui_left: UITalkNPC = %DialogueCanvas.get_node("UITalkNPCLeft")

var ui: UITalkNPC:
	set(value):
		if ui:
			ui.kill_all_box_instances()
		ui = value

func _run():
	dm.subject_talking_instances += 1
	dm.update_cam_state()
	
	var x_sign = -sign(dm.main_cam.global_position.x - dm.subject.global_position.x)
	
	ui = ui_left if x_sign == 1 else ui_right
	ui.talk(self, dm.subject.global_position + Vector2(x_sign*-dm.subject.dialogue_distance, -dm.subject.dialogue_height))
	
	await ui.start_next
	
	dm.subject_talking_instances -= 1
	if !(goto is DialogueStatement):
		ui.kill_all_box_instances()


func _after_run():
	pass
