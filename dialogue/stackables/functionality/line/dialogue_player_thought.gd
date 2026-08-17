@icon("res://icons/icon_thought.png")

class_name DialoguePlayerThought extends DialogueLine

@export var dialogue: String = ""

@onready var ui_right: UITalkThought = %DialogueCanvas.get_node("UITalkPlayerRight")
@onready var ui_left: UITalkThought = %DialogueCanvas.get_node("UITalkPlayerLeft")

var ui: UITalkThought:
	set(value):
		if ui:
			ui.kill_box_instance()
		ui = value

func _run():
	dm.player.sprite.play("talk")
		
	var x_sign = 1
	
	if dm.subject:
		x_sign = -sign(dm.main_cam.global_position.x - dm.subject.global_position.x)
	
	dm.player_talking_instances += 1
	dm.update_cam_state()
	
	ui = ui_left if x_sign == -1 else ui_right
	
	ui.talk(self, dm.player.global_position + Vector2.UP * 150.0 + Vector2.RIGHT * 75.0 * x_sign)
	
	await ui.start_next
	
	dm.player_talking_instances -= 1
	
	if !(goto is DialoguePlayerThought):
		ui.kill_box_instance()
