class_name ClickPeople extends Button

@export var talk_ui: Node2D

func bd():
	talk_ui.visible = !talk_ui.visible

func _ready():
	button_down.connect(bd)
