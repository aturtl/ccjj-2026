extends Sprite2D

@export var item: ItemData

func _on_interacted(text: String) -> void:
	print(text)
	collect()
	
func collect() -> void:
	Inventory.add_item(item)
	
	await get_tree().process_frame
	queue_free()
