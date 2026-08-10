extends Camera2D


@export var player_cam: Node2D
@export var talk_cam: Node2D
var follow = "player"


func _ready():
	make_current()


func _physics_process(delta):
	if follow == "player":
		print("following")
		global_position = global_position.lerp(player_cam.global_position,.3)
		zoom = talk_cam.global_scale
	elif follow == "talk":
		global_position = global_position.lerp(talk_cam.global_position, .3)
		zoom = talk_cam.global_scale
