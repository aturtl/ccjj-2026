class_name DialogueInstanceConnector extends Node2D


@export var connected_tree: DialogueLineTree


func play_tree():
	for child in connected_tree.get_children():
		if child is DialogueLine:
			%NPCTalk.dialogue_start(child)
