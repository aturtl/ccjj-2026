extends Node

signal inventory_changed

var items: Array[ItemData] = []

func add_item(item: ItemData):
	items.append(item)
	inventory_changed.emit()

func remove_item(item: ItemData):
	items.erase(item)
	inventory_changed.emit()

func has_item(item: ItemData) -> bool:
	return item in items
	
