extends Node

enum UIState {
	START,
	PAUSED,
	SETTINGS, 
	GAME
	}

var current_state: UIState
var previous_state: UIState

func _ready() -> void:
	current_state = UIState.START

func _process(_delta: float) -> void:
	# TODO remove input from script? 
	if Input.is_action_just_pressed("escape"):
		switch_to_previous()

func switch_to_previous() -> void:
	if current_state == UIState.START:
		return
	
	if current_state == UIState.GAME:
		change_state(UIState.PAUSED)
	elif current_state == UIState.PAUSED:
		change_state(UIState.GAME)
	else:
		change_state(previous_state)

func change_state(new_state: UIState) -> void:
	if new_state == current_state:
		return
		
	previous_state = current_state
	current_state = new_state
	
	match current_state:
		UIState.START:
			get_tree().change_scene_to_file("res://ui/start_menu/start_menu.tscn")
			pass
		UIState.PAUSED:
			get_tree().change_scene_to_file("res://ui/paused_menu/paused.tscn")
			pass
		UIState.SETTINGS:
			get_tree().change_scene_to_file("res://ui/settings_menu/settings.tscn")
			pass
		UIState.GAME:
			get_tree().change_scene_to_file("res://ui/test.tscn")
			pass
	
	#print_debug("\ncurr: ", UIState.find_key(current_state))
	#print_debug("prev: ", UIState.find_key(previous_state))
