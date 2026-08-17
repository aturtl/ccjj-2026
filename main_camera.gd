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

var to_pos: Vector2 = position

func _cheat_entered(cheat: String):
	match cheat:
		"cam_talk":
			current_state = State.DIALOGUE
			var t = get_tree().create_tween()
			t.set_trans(Tween.TRANS_BOUNCE)
			tween_to_transform(talk_trans.transform, t, .5)


func _ready():
	%CheatsUI.cheat_entered.connect(_cheat_entered)


func tween_to_transform(trans: Transform2D, tween: Tween, time: float = DEFAULT_TIME):
	tween.tween_property(self, "global_transform", trans, time)
	tween.parallel().tween_property(self, "zoom", trans.get_scale(), time)
	tween.play()


func snap_cam_to_bounds():
	global_position = restrict_to_cam_bounds(global_position)


func state_follow(delta):
	var axis = Input.get_axis("left","right")
	
	to_pos.x += delta*MOVE_AMOUNT*axis
	
	to_pos = keep_in_bounds(to_pos)
	
	var lerp_pos = lerp(player.global_position.x, to_pos.x, .9)
	player.global_position.x = lerp_pos
	
	global_position = global_position.lerp(restrict_to_cam_bounds(to_pos), .2)
	
	if axis > 0:
		player.sprite.flip_h = false
		player.sprite.play("walk_right")
	elif axis < 0:
		player.sprite.flip_h = true
		player.sprite.play("walk_right")
	else:
		player.sprite.play("idle")


func is_out_of_bounds(pos: Vector2):
	var oob = false
	
	if pos.x < environment_holder.left_bound:
		oob = true
	elif pos.x > environment_holder.right_bound:
		oob = true
	
	return oob


func keep_in_bounds(pos: Vector2):
	var new_pos = pos
	
	if new_pos.x < environment_holder.left_bound:
		new_pos.x = environment_holder.left_bound
	elif pos.x > environment_holder.right_bound:
		new_pos.x = environment_holder.right_bound
	
	return new_pos


func restrict_to_cam_bounds(pos: Vector2, z: Vector2 = zoom):
	var new_pos = pos
	
	var camera_rect = get_viewport_rect() #thanks Lertos on Reddit!! This is really helpful!
		#actually the solution wasn't the one I needed... but thanks for leading me in the right direction anyways!
	
	var s = camera_rect.size/z
	
	var top_left = pos-s/2.0
	var bot_right = top_left + s
	
	var l = top_left.x
	var r = bot_right.x
	
	#var t = top_left.y
	#var b = bot_right.y
	
	if l < environment_holder.left_bound:
		new_pos.x = environment_holder.left_bound + s.x/2.0
	
	if r > environment_holder.right_bound:
		new_pos.x = environment_holder.right_bound - s.x/2.0
	
	return new_pos


func _physics_process(delta):
	match current_state:
		State.FOLLOW:
			state_follow(delta)
