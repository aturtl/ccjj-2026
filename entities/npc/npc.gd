class_name NPC extends Node2D

@export var connector: DialogueInstanceConnector

func _ready():
	get_node("Interactable").interacted.connect(_on_interactable_interacted)

func _on_interactable_interacted(text: String) -> void:
	if connector:
		connector.play_tree(self)
