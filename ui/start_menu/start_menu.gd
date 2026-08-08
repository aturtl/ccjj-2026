extends Control

signal start_game

@onready var settings_menu: Control = %SettingsMenu


func _on_play_pressed() -> void:
	start_game.emit()

func _on_settings_pressed() -> void:
	UIManager.open_overlay(settings_menu)

func _on_quit_pressed() -> void:
	get_tree().quit()
