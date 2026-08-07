extends Control


func _on_resume_pressed() -> void:
	UIManager.change_state(UIManager.UIState.GAME)
	

func _on_settings_pressed() -> void:
	UIManager.change_state(UIManager.UIState.SETTINGS)


func _on_main_pressed() -> void:
	UIManager.change_state(UIManager.UIState.START)


func _on_quit_pressed() -> void:
	get_tree().quit()
