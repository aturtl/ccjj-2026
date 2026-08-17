@icon("res://icons/icon_event.png")

class_name DialoguePlayMusic extends DialogueEvent

@export var audio_stream: AudioStream

@export var volume_db: float = 0.0

func _play_line():
	AudioManager.play_music(audio_stream, volume_db)
