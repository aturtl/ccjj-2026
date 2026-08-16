class_name EnvironmentHolder extends Node2D

@export var left_bound: float = -INF
@export var right_bound: float = INF

@onready var background: Sprite2D = $BG

func _ready():
	if background:
		calculate_bounds()

func calculate_bounds():
	var rect = background.get_rect()
	rect.size *= background.global_scale
	var left = background.global_position.x - rect.size.x + rect.size.x/2.0
	var right = left+rect.size.x
	left_bound = left
	right_bound = right
	print("l:",left,"r:", right)
