@icon("res://icons/icon_event.png")

class_name DialoguePlaySound extends DialogueEvent

@export var audio_stream: AudioStream

func _play_line():
	AudioManager.play_sfx(audio_stream)
