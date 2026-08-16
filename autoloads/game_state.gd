extends Node

signal in_dialogue_changed

var in_dialogue: bool = false:
	set(value):
		in_dialogue = value
		in_dialogue_changed.emit(value)
