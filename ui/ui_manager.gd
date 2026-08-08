extends Node

var current_menu: Control
var overlay_stack: Array[Control]

func open_menu(menu: Control) -> void:
	if current_menu:
		current_menu.hide()

	current_menu = menu
	current_menu.show()
	

func close_menu() -> void:
	if current_menu:
		current_menu.hide()

	current_menu = null

func open_overlay(overlay: Control) -> void:
	overlay_stack.push_back(overlay)
	overlay.show()
	
func close_overlay() -> void:
	var current_overlay: Control = overlay_stack.pop_back()
	if 	current_overlay:
		current_overlay.hide()
	
