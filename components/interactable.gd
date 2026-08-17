extends Area2D
class_name Interactable

@export var interaction_string: String
@export var highlight_on_hover : bool = true

@export var hover_priority: int = 0

@export_custom(PROPERTY_HINT_NODE_TYPE, "AnimatedSprite2D,Sprite2D") var sprite: Node2D
var shader: ShaderMaterial


signal interacted(text: String)

var true_mouse_enter = false

func _ready():
	GameState.in_dialogue_changed.connect(_game_in_dialogue_changed)
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	#input_event.connect(_on_input_event)
	sprite.material = sprite.material.duplicate() # so duplicated objects have unique outlines
	shader = sprite.material as ShaderMaterial


func _on_mouse_entered() -> void:
	GameState.add_hover(self)


func _on_mouse_exited() -> void:
	GameState.remove_hover(self)


func hover() -> void:
	true_mouse_enter = true
	
	if GameState.in_dialogue:
		return
	
	if highlight_on_hover and SettingsManager.show_outline_on_hover:
		shader.set_shader_parameter("outline_thickness", 5)


func unhover() -> void:
	true_mouse_enter = false
	
	if GameState.in_dialogue:
		return
	
	if highlight_on_hover:
		shader.set_shader_parameter("outline_thickness", 0)


func _on_interact() -> void:
	interacted.emit(interaction_string)


func _game_in_dialogue_changed(in_dialogue):
	if in_dialogue:
		shader.set_shader_parameter("outline_thickness", 0)
	if true_mouse_enter:
		hover()
