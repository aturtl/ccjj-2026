extends TextureRect
class_name InventorySlot

var item: ItemData

func set_item(new_item: ItemData) -> void:
	item = new_item
	texture = new_item.texture
	
func clear() -> void:
	item = null
	texture = null
