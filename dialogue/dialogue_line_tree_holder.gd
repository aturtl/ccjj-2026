extends Node

@export var debug_npc: NPC

func _ready():
	%CheatsUI.cheat_entered.connect(_on_cheat_entered)


func _on_cheat_entered(s: String):
	if s.match("dl_*"):
		var nm = s.substr(3)
		play_tree(nm)


func play_tree(nm: String):
	var line_holder = get_node(nm)
	if !line_holder:
		return
	for child in line_holder.get_children():
		if child is DialogueLine:
			%DialogueManager.dialogue_start(child, debug_npc)
