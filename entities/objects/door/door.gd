extends Sprite2D

@export var requirement: ItemData

func _on_interacted(text: String) -> void:
	print(text)
	if not Inventory.has_item(requirement):
		print("can't open door")
		return
		
	open_door()
		
func open_door() -> void:
	print("opening door")
	self.modulate = Color.BLACK
	
