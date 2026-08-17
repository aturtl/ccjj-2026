class_name DialogueInstanceConnector extends Node


@export var connected_tree: DialogueLineTree


func play_tree(subject: WorldEntity):
	print("PLAYING")
	for child in connected_tree.get_children():
		if child is DialogueLine:
			%DialogueManager.dialogue_start(child, subject)
