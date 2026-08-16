class_name WorldObjectHoldsItem extends WorldObject

@export var item_scene: PackedScene
@export var offset: Vector2 = Vector2(0,-250)

var spawned = false

func _on_interactable_interacted(text: String) -> void:
	if !spawned:
		spawned = true
		spawn()


func spawn() -> void:
	var item = item_scene.instantiate()
	add_child(item)
	item.position = offset
