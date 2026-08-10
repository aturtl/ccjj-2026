class_name NPC extends Node2D

@export var connector: DialogueInstanceConnector
@onready var sprite: AnimatedSprite2D = get_node("Sprite")
@onready var interactable: Interactable = get_node("Interactable")

func _on_interactable_interacted(text: String) -> void:
	if connector:
		connector.play_tree(self)
