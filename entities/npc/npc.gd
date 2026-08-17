class_name NPC extends WorldEntity

@export var dialogue_height: float = 50.0
@export var dialogue_distance: float = 50.0
@export var connector: DialogueInstanceConnector

func _ready():
	get_node("Interactable").interacted.connect(_on_interactable_interacted)

func _on_interactable_interacted(text: String) -> void:
	if %Player.dialogue_lock:
		return
	if connector:
		connector.play_tree(self)
