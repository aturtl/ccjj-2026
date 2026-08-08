extends Sprite2D


func _on_interactable_interacted(text: String) -> void:
	print(text)
	Inventory.add_item(name)
	 
	await get_tree().process_frame
	queue_free()
