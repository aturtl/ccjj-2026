class_name MainCamera extends Camera2D

enum State {FOLLOW, CUTSCENE, DIALOGUE}
var current_state = State.FOLLOW

const MOVE_AMOUNT: float = 500
const DEFAULT_TIME: float = .5

@export var talk_trans: Node2D

@export var player: Player

@export var left_bound: float = 0
@export var right_bound: float = 1000

@export var environment_holder: EnvironmentHolder

func _cheat_entered(cheat: String):
	match cheat:
		"cam_talk":
			current_state = State.DIALOGUE
			var t = get_tree().create_tween()
			t.set_trans(Tween.TRANS_BOUNCE)
			tween_to_transform(talk_trans.transform, t, .5)


func _ready():
	%Cheats.cheat_entered.connect(_cheat_entered)


func tween_to_transform(trans: Transform2D, tween: Tween, time: float = DEFAULT_TIME):
	tween.tween_property(self, "global_transform", trans, time)
	tween.parallel().tween_property(self, "zoom", trans.get_scale(), time)
	tween.play()


func state_follow(delta):
	var axis = Input.get_axis("left","right")
	
	global_position.x += delta*MOVE_AMOUNT*axis
	player.global_position = $PlayerWalkPos.global_position
	
	var camera_rect = get_viewport_rect() #thanks Lertos on Reddit!! This is really helpful!
	
	var left = global_position.x-camera_rect.size.x/2.0
	var right = left+camera_rect.size.x
	
	if left < environment_holder.left_bound:
		global_position.x = environment_holder.left_bound + camera_rect.size.x/2.0
	
	if right > environment_holder.right_bound:
		global_position.x = environment_holder.right_bound - camera_rect.size.x/2.0
	
	if axis > 0:
		player.sprite.flip_h = false
		player.sprite.play("walk_right")
	elif axis < 0:
		player.sprite.flip_h = true
		player.sprite.play("walk_right")
	else:
		player.sprite.play("idle")


func _physics_process(delta):
	match current_state:
		State.FOLLOW:
			state_follow(delta)
