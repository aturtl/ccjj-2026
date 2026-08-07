class_name ClickPeople extends Button

@export var talk_ui: Node2D

@export var anxiety_meter: Control

func bd():
	talk_ui.visible = !talk_ui.visible

func _ready():
	button_down.connect(bd)
