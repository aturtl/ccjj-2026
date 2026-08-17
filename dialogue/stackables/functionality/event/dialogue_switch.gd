class_name DialogueSwitch extends DialogueEvent

@export var switch_connector_name: String = ""
@export var switch_tree: DialogueLineTree

@onready var dc = %DialogueConnectors

func _ready():
	var switch_connector = dc.get_node(switch_connector_name)
	if switch_connector:
		switch_connector.connected_tree = switch_tree
