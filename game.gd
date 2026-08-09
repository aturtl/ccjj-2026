extends Node

@onready var start_menu: Control = %StartMenu
@onready var pause_menu: Control = %PauseMenu
@onready var settings_menu: Control = %SettingsMenu
@onready var inventory_ui: Control = %InventoryUI

func _ready() -> void:
	UIManager.open_menu(start_menu)
	get_tree().paused = true
	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		if not get_tree().paused:
			pause_game()
		
		else:
			UIManager.close_overlay()
			if UIManager.overlay_stack.is_empty() and not UIManager.current_menu:
				unpause_game()
		
func pause_game() -> void:
	get_tree().paused = true
	UIManager.open_overlay(pause_menu)
	
func unpause_game() -> void:
	get_tree().paused = false
	


func _on_start_game() -> void:
	get_tree().paused = false
	UIManager.close_menu()
	AudioManager.stop_music()
	#inventory_ui.show()


func _on_inventory_button_toggled(toggled_on: bool) -> void:
	inventory_ui.visible = toggled_on
