extends Control

var slots: Array[InventorySlot] = []

func _ready() -> void:
	Inventory.inventory_changed.connect(refresh)

	for slot in $FoldableContainer/TextureRect/HBoxContainer.get_children():
		slots.append(slot)

	refresh()


func refresh() -> void:
	for slot in slots:
		slot.clear()

	for i in range(min(Inventory.items.size(), slots.size())):
		slots[i].set_item(Inventory.items[i])
