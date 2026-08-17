extends Control


func _on_back_pressed() -> void:
	AudioManager.play_music(load("res://audio/Title song.mp3"))
	UIManager.close_overlay()
