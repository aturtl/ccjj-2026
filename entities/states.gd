class_name States extends Node


var current_state = ""


func get_state():
	return current_state


func set_state(s):
	current_state = s
	
	if s == "kill":
		get_parent().visible = false
