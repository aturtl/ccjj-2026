class_name WorldObjectHasDialogueConnector extends WorldObject

@export var connector: DialogueInstanceConnector

var interacted = false

func _on_interactable_interacted(text: String) -> void:
	interacted = true
	if connector:
		connector.play_tree(null)
