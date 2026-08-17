class_name DialogueStatSetter extends DialogueEvent

@export var confidence_reward: int = 0
@export var add_item: ItemData # Not blank = item, you know the drill
@export var remove_item: ItemData

func _play_line():
	Stats.confidence += confidence_reward
	confidence_reward = 0
	if add_item:
		Inventory.add_item(add_item)
	if remove_item:
		Inventory.remove_item(remove_item)
