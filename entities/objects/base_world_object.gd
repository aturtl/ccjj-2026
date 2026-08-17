extends WorldEntity
class_name WorldObject

@export var dialogue_connector: DialogueInstanceConnector

@export var item_scene: PackedScene
@export var item_spawn_offset: Vector2 = Vector2(0,-250)

var spawned_item = false
var interacted = false


func _on_interactable_interacted(text: String) -> void:
	if %Player.dialogue_lock:
		return
	interacted = true
	
	if dialogue_connector:
		dialogue_connector.play_tree(self)
	
	if item_scene and !spawned_item:
		spawned_item = true
		spawn_item()


func spawn_item() -> void:
	var item = item_scene.instantiate()
	add_child(item)
	item.position = item_spawn_offset
