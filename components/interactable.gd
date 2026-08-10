extends Area2D
class_name Interactable

@export var interaction_string: String
@export var highlight_on_hover : bool = true
@export_custom(PROPERTY_HINT_NODE_TYPE, "AnimatedSprite2D,Sprite2D") var sprite: Node2D
var shader: ShaderMaterial

var disabled = false

signal interacted(text: String)

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_event.connect(_on_input_event)
	shader = sprite.material as ShaderMaterial


func _on_mouse_entered() -> void:
	if highlight_on_hover and !disabled:
		shader.set_shader_parameter("outline_thickness", 3)


func _on_mouse_exited() -> void:
	if highlight_on_hover and !disabled:
		shader.set_shader_parameter("outline_thickness", 0)


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("interact") and !disabled:
		interacted.emit(interaction_string)


func disable():
	disabled = true
	shader.set_shader_parameter("outline_thickness", 0)
