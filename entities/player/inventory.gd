extends Node

var items: Array[String] = []

func add_item(item: String):
	items.append(item)

func remove_item(item: String):
	items.erase(item)

func has_item(item: String) -> bool:
	return item in items
