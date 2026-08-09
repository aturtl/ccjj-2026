extends Node2D


func _ready():
	%Cheats.cheat_entered.connect(_on_cheat_entered)


func _on_cheat_entered(s: String):
	print("CHEATING")
	
	if s.match("dl_*"):
		var nm = s.substr(3)
		var line_holder = get_node(nm)
		if !line_holder:
			return
		for child in line_holder.get_children():
			if child is DialogueLine:
				%NPCTalk.dialogue_start(child)
