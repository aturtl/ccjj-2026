extends Node2D


func cheat_entered(cheat: String):
	if cheat.match("conn_*"):
		var conn = get_node(cheat.substr(5))
		if conn and conn is DialogueInstanceConnector:
			conn.play_tree()

func _ready():
	%Cheats.cheat_entered.connect(cheat_entered)
