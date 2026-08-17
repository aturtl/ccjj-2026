extends Node

signal in_dialogue_changed

var in_dialogue: bool = false:
	set(value):
		in_dialogue = value
		in_dialogue_changed.emit(value)

var mouse_hovers: Array[Interactable]
var mouse_priority_hover: Interactable


func _input(e):
	if e is InputEventMouseButton:
		if e.is_action_pressed("interact"):
			click()


func add_hover(i: Interactable):
	print("add")
	if !mouse_hovers.has(i):
		print("APPENDED")
		mouse_hovers.append(i)
	decide_priority_hover()


func remove_hover(i: Interactable):
	var pos = mouse_hovers.find(i)
	if pos != -1:
		mouse_hovers.remove_at(pos)
	decide_priority_hover()


func decide_priority_hover():
	var highest_priority: int = 0
	var chosen: Interactable = null
	
	for interactable in mouse_hovers:
		if interactable.hover_priority >= highest_priority:
			chosen = interactable
			highest_priority = interactable.hover_priority
	
	if mouse_priority_hover != chosen:
		if mouse_priority_hover:
			mouse_priority_hover.unhover()
		mouse_priority_hover = chosen
		if chosen:
			chosen.hover()
			print("PRIORITY:",chosen, highest_priority)

func click() -> void:
	if GameState.in_dialogue:
		return
	
	if mouse_priority_hover:
		mouse_priority_hover._on_interact()
