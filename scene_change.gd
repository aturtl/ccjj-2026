extends Button
	


func _on_button_down():
	%Environment.switch_environment((%Environment.current_environment+ 1) % 6)
