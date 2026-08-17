@icon("uid://cpql43g5ii105")

class_name DialogueQuestion extends DialogueObject

@onready var ui = %DialogueCanvas.get_node("UIChoice")

var chosen_choice: DialogueChoice

func _play_line():
	dm.player_thinking_instances += 1
	dm.update_cam_state()
	dm.kill_boxes()
	
	#await tween_to_thought()
	
	var choices = dm.get_choices(self)
	ui.display_choices(choices, Vector2(576,320))
	
	chosen_choice = await ui.choice_selected
	
	dm.fade_screen(false, .5)
	dm.player_thinking_instances -= 1
