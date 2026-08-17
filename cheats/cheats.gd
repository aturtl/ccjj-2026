@icon("uid://dvqw73kytml1i")
class_name Cheats extends CanvasLayer
## To make testing stuff easier
## This would preferably be put inside the camera in the main branch

@onready var text_console: LineEdit = $TextConsole

var ignore_all_prerequisites = false
var skip_talk = false

signal cheat_entered # sends text on enter

func text_set():
	var console_text = text_console.text
	cheat_entered.emit(console_text)
	match console_text:
		"confidence":
			Stats.confidence += 5
		"extrovert":
			Stats.confidence += 1000
		"dereq":
			ignore_all_prerequisites = true
		"skiptalk":
			skip_talk = true
	if console_text.match("item_*"):
		var item = load("res://data/items/"+console_text.substr(5)+".tres")
		if item and item is ItemData:
			Inventory.add_item(item)
	if console_text.match("confidence_*"):
		var num = int(console_text.substr(11))
		Stats.confidence += num
		print("CONFIDENCE ADDED: "+str(num))


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
