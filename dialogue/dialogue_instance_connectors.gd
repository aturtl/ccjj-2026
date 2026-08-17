extends Node


func cheat_entered(cheat: String):
	if cheat.match("conn_*"):
		var conn = get_node(cheat.substr(5))
		if conn and conn is DialogueInstanceConnector:
			conn.play_tree()

func _ready():
	%CheatsUI.cheat_entered.connect(cheat_entered)
