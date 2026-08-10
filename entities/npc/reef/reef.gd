extends Node2D

@export var connector: DialogueInstanceConnector

func _on_interactable_interacted(text: String) -> void:
	if connector:
		connector.play_tree()
