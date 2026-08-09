class_name DialogueLine extends Node
## Originally, I meant for this only to be dialogue lines but due to time constraints, just pretend it's DialogueItem

@export var switch_npc_animation_to = "" # Blank if no change needed
@export var switch_player_animation_to = "" # Blank if no change needed

@export var in_between_time: float = -1.0 # -1.0 to use default value
@export var dynamic_range: float = -1.0 # -1.0 to use default value

@export var after_wait: float = 0.0
