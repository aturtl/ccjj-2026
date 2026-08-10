extends Sprite2D

@export var car_key_scene: PackedScene

func _on_interactable_interacted(text: String) -> void:
	print(text)
	spawn_key()

func spawn_key() -> void:
	var car_key = car_key_scene.instantiate()
	add_child(car_key)
	car_key.global_position.y += 150
