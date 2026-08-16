extends Area2D
class_name Interactable

@export var interaction_string: String
@export var highlight_on_hover : bool = true
@export_custom(PROPERTY_HINT_NODE_TYPE, "AnimatedSprite2D,Sprite2D") var sprite: Node2D
var shader: ShaderMaterial


signal interacted(text: String)

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_event.connect(_on_input_event)
	sprite.material = sprite.material.duplicate() # so duplicated objects have unique outlines
	shader = sprite.material as ShaderMaterial


func _on_mouse_entered() -> void:
	if highlight_on_hover and SettingsManager.show_outline_on_hover:
		shader.set_shader_parameter("outline_thickness", 5)


func _on_mouse_exited() -> void:
	if highlight_on_hover:
		shader.set_shader_parameter("outline_thickness", 0)


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("interact"):
		interacted.emit(interaction_string)
