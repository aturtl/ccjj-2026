extends Control

signal resume

@onready var start_menu: Control = %StartMenu
@onready var settings_menu: Control = %SettingsMenu


func _on_resume_pressed() -> void:
	UIManager.close_overlay()
	resume.emit()
	

func _on_settings_pressed() -> void:
	UIManager.open_overlay(settings_menu)


func _on_main_pressed() -> void:
	UIManager.close_overlay()
	UIManager.open_menu(start_menu)


func _on_quit_pressed() -> void:
	get_tree().quit()
