@icon("uid://dvqw73kytml1i")
class_name Cheats extends Node2D
## To make testing stuff easier
## This would preferably be put inside the camera in the main branch

@onready var text_console: LineEdit = $TextConsole

signal cheat_entered # sends text on enter

func text_set():
	cheat_entered.emit(text_console.text)


func _ready():
	text_console.visible = false
	if OS.is_debug_build():
		text_console.text_changed.connect(text_set)


func _physics_process(delta):
	if OS.is_debug_build():
		if Input.is_action_just_pressed("display_cheats"):
			text_console.visible = !text_console.visible
			if text_console.visible:
				text_console.grab_focus()
			else:
				text_console.release_focus()
		if text_console.visible:
			if Input.is_action_just_pressed("ui_accept"):
				text_set()
				text_console.text = ""
