@icon("res://icons/icon_event.png")

class_name DialogueFadeScreen extends DialogueEvent

@export var fade_time: float = 1.0

enum FadeType {IN, OUT}
@export var fade_type = FadeType.IN
