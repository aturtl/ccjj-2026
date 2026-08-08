extends Node
class_name OutlineComponent

@export var sprite: Sprite2D
@export var outline_material: ShaderMaterial

func _ready():
	sprite.material = outline_material.duplicate()

func show_outline():
	sprite.material.set_shader_parameter("outline_enabled", true)

func hide_outline():
	sprite.material.set_shader_parameter("outline_enabled", false)
