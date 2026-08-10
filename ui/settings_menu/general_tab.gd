extends VBoxContainer


func _on_check_box_toggled(toggled_on: bool) -> void:
	SettingsManager.show_outline_on_hover = toggled_on
