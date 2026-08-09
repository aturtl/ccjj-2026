extends Control

const TITLE_SONG = preload("uid://c1foiygvumej6")

signal start_game

@onready var settings_menu: Control = %SettingsMenu
@onready var credits_menu: Control = %CreditsMenu

func _ready() -> void:
	AudioManager.play_music(TITLE_SONG)

func _on_play_pressed() -> void:
	start_game.emit()

func _on_settings_pressed() -> void:
	UIManager.open_overlay(settings_menu)

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_creddits_pressed() -> void:
	UIManager.open_overlay(credits_menu)
