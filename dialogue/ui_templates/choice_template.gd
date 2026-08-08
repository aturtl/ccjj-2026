class_name ChoiceTemplate extends Node2D


@export var select_button: Button
@export var label: RichTextLabel
@export var sprite: AnimatedSprite2D
@export var sanity_display: RichTextLabel
var goto: DialogueLine

signal selected


func bd():
	selected.emit(self)
	print("GOTO:", goto)


func _ready():
	select_button.button_down.connect(bd)
