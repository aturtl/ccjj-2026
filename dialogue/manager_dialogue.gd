class_name DialogueManager extends Node

@export var main_cam: MainCamera
@export var talk_cam: FakeCam
@export var player_sprite: AnimatedSprite2D
@export var npc_sprite: AnimatedSprite2D
@export var transitioners: Node2D
@export var screen_fader: ColorRect

@export var instance_connectors: Node

@export_category("Talkers")
@export var ui_npc_talk_left: UITalkNPC
@export var ui_npc_talk_right: UITalkNPC
@export var ui_choice_display: UIChoiceDisplay
@export var ui_player_talk_right: UITalkThought
@export var ui_player_talk_left: UITalkThought
@export var ui_reward: UIReward
@export var blip_player: AudioStreamPlayer

@onready var cheats: Cheats = %Cheats

@export_category("Cheats")
@export var dia_ex_lines: DialogueLine
@export var dia_ex_choice: DialogueLine
@export var dia_ex_thought: DialogueLine

@export_category("Temporary")
@export var debug_rect_display: ColorRect
@export var blip_dynamic_range: float = .1

var original_player_pos: Vector2
var original_subject_pos: Vector2
var original_cam_pos: Vector2

var center_cam_pos: Vector2

var original_cam_trans: Transform2D

var parallel_count: int = 0

var scene = ""

var subject: WorldEntity = null
@export var player: Player

var player_talking_instances = 0
var subject_talking_instances = 0
var player_thinking_instances = 0

enum CameraState {NONE, NPC_TALK, PLAYER_TALK, PLAYER_THOUGHT, RETURN}
var current_camera_state = CameraState.NONE

func _ready():
	pass


func play_blip(dyn_range: float = blip_dynamic_range):
	var pitch_scale = randf_range(1-dyn_range,1+dyn_range)
	blip_player.play()


func cam_offset():
	return original_cam_pos - Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"),ProjectSettings.get_setting("display/window/size/viewport_height"))/2.0


#region dialogue loop
func dialogue_start(d_object:DialogueLine, subject: WorldEntity):
	original_player_pos = player.global_position
	original_cam_pos = main_cam.global_position
	if subject:
		original_subject_pos = subject.global_position
	
	GameState.in_dialogue = true
	
	player.dialogue_lock = true
	main_cam.current_state = main_cam.State.DIALOGUE
	
	self.subject = subject
	
	parallel_count += 1
	
	scene = ""
	
	original_cam_trans = main_cam.global_transform
	
	if subject:
		var subject_player_start_dist_x = subject.global_position.x - player.global_position.x
		
		var new_pos_x = player.global_position.x
		
		var tweening = false
		var correct_tween = get_tree().create_tween()
		
		var jump_tween = get_tree().create_tween()
		
		if abs(subject_player_start_dist_x) < 200.0:
			tweening = true
			new_pos_x = subject.global_position.x-sign(subject_player_start_dist_x)*200.0
			
			if main_cam.is_out_of_bounds(new_pos_x*Vector2.RIGHT):
				new_pos_x = subject.global_position.x+sign(subject_player_start_dist_x)*200.0
			
			correct_tween.tween_property(player, "global_position:x", new_pos_x, .6).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
			correct_tween.play()
			
			player.sprite.play("walk")
			
			original_player_pos = Vector2(new_pos_x, player.global_position.y)
			original_cam_pos.x = main_cam.restrict_to_cam_bounds(original_player_pos, Vector2(1.0,1.0)).x
			
			jump_tween.tween_property(player, "global_position:y", original_player_pos.y - 12.0, .2).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
			jump_tween.tween_property(player, "global_position:y", original_player_pos.y, .2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			jump_tween.play()
		
		center_cam_pos = (subject.position + original_player_pos)/2.0
		
		current_camera_state = CameraState.PLAYER_TALK
		reposition_cam()
		
		var subject_player_real_dist_x = subject.global_position.x - original_player_pos.x
		
		var subject_player_sign_x = -sign(subject_player_real_dist_x)
		
		player.sprite.flip_h = subject_player_sign_x == 1
		
		if tweening:
			await correct_tween.finished
		
		player.sprite.play("talk")
	else:
		center_cam_pos = player.position
	
	main_cam.to_pos.x = original_player_pos.x
	
	print(GameState.in_dialogue)
	
	display_ui()
	dialogue_loop(d_object)


func dialogue_loop(d_object:DialogueObject):
	if !d_object:
		dialogue_branch_end()
		return
	
	if d_object is DialogueLine:
		if d_object.switch_npc_animation_to != "":
			if d_object.switch_npc_animation_to == "gone":
				npc_sprite.visible = false
			else:
				npc_sprite.play(d_object.switch_npc_animation_to)
		
		if d_object.switch_player_animation_to != "":
			player_sprite.play(d_object.switch_player_animation_to)
	
	await d_object._run()
	
	loop_with_parallels(d_object)


func dialogue_branch_end():
	parallel_count -= 1
	if parallel_count == 0:
		dialogue_end()


func dialogue_end():
	kill_boxes()
	current_camera_state = CameraState.RETURN
	await cam_return()
	main_cam.current_state = main_cam.State.FOLLOW
	player.dialogue_lock = false
	GameState.in_dialogue = false
#endregion

#region cam state
func update_cam_state():
	var decision: int
	if player_thinking_instances > 0:
		decision = CameraState.PLAYER_THOUGHT
	elif player_talking_instances > 0:
		decision = CameraState.PLAYER_TALK
	elif subject_talking_instances > 0:
		decision = CameraState.NPC_TALK
	else:
		decision = CameraState.NONE
	
	if decision != current_camera_state:
		current_camera_state = decision
		reposition_cam()


func reposition_cam():
	match current_camera_state:
		CameraState.PLAYER_THOUGHT:
			fade_screen(true, .5)
			cam_player_thought()
			player.sprite.play("thought")
		CameraState.PLAYER_TALK:
			cam_player_talk()
		CameraState.NPC_TALK:
			cam_npc_talk()
		CameraState.NONE:
			pass


func cam_player_thought():
	var tween = get_tree().create_tween()
	
	var x = player.global_position.x
	var y = player.global_position.y - 100.0
	
	var zoom = Vector2(3.0,3.0)
	
	if subject:
		tween.tween_property(main_cam, "global_position", Vector2(x,y), .5).set_trans(Tween.TRANS_SINE)
	
	tween.parallel().tween_property(main_cam, "zoom", zoom, .5).set_trans(Tween.TRANS_SINE)
	
	tween.play()


func cam_player_talk():
	var tween = get_tree().create_tween()
	
	var x = center_cam_pos.x
	var y = original_cam_pos.y
	
	var zoom = Vector2(1.3,1.3)
	
	if subject:
		tween.tween_property(main_cam, "global_position", main_cam.restrict_to_cam_bounds(Vector2(x,y), Vector2(1.3,1.3)), .5).set_trans(Tween.TRANS_SINE)
	
	tween.parallel().tween_property(main_cam, "zoom", zoom, .5).set_trans(Tween.TRANS_SINE)
	
	tween.play()


func cam_npc_talk():
	var x_sign = sign(original_cam_pos.x - subject.global_position.x)
	
	var tween = get_tree().create_tween()
	
	var x = subject.global_position.x + x_sign*200.0
	var y = original_cam_pos.y - 60.0
	
	var pos = Vector2(x,y)
	var zoom = Vector2(1.6,1.6)
	
	pos = main_cam.restrict_to_cam_bounds(pos, zoom)
	
	if subject:
		tween.tween_property(main_cam, "global_position", pos, .5).set_trans(Tween.TRANS_SINE)
	
	tween.parallel().tween_property(main_cam, "zoom", zoom, .5).set_trans(Tween.TRANS_SINE)
	
	tween.play()


func cam_return():
	var tween = get_tree().create_tween()
	
	var x = original_cam_pos.x
	var y = original_cam_pos.y
	
	var zoom = Vector2(1.0,1.0)
	
	if subject:
		tween.tween_property(main_cam, "global_position", Vector2(x,y), .5).set_trans(Tween.TRANS_SINE)
	
	tween.parallel().tween_property(player, "global_position", original_player_pos, .5).set_trans(Tween.TRANS_SINE)
	
	tween.parallel().tween_property(main_cam, "zoom", zoom, .5).set_trans(Tween.TRANS_SINE)
	
	tween.play()
	
	await tween.finished
#endregion

func fade_screen(show: bool, time: float):
	var alpha = 1.0 if show else 0.0
	screen_fader.visible = true
	
	var tween = get_tree().create_tween()
	tween.tween_property(screen_fader,"modulate:a",alpha,time)
	tween.play()
	
	await tween.finished
	
	if !show:
		screen_fader.visible = false


func kill_boxes():
	ui_npc_talk_left.kill_all_box_instances()
	ui_npc_talk_right.kill_all_box_instances()
	ui_player_talk_left.kill_box_instance()
	ui_player_talk_right.kill_box_instance()


func loop_with_parallels(d_object: DialogueObject):
	if d_object is DialogueQuestion:
		d_object = d_object.chosen_choice
	
	if d_object.after_wait > 0.0:
		await get_tree().create_timer(d_object.after_wait).timeout
	parallel_count += d_object.parallel_gotos.size()
	dialogue_loop(d_object.goto)
	for goto in d_object.parallel_gotos:
		dialogue_loop(goto)


func display_ui():
	pass


func tween_back_to_original_positions(): # right now, I just send them into space
	var player_tween: Tween = get_tree().create_tween().set_parallel()
	var cam_tween: Tween = get_tree().create_tween().set_parallel()
	var subject_tween: Tween = get_tree().create_tween().set_parallel()
	
	var trans_time = .2
	
	player.sprite.play("idle")
	
	#player_tween.tween_property(player, "global_position", original_player_pos, .6).set_trans(Tween.TRANS_CIRC)
	player_tween.tween_property(player.sprite, "scale", Vector2(1.0,1.0), trans_time).set_trans(Tween.TRANS_CIRC)
	player_tween.play()
	
	#cam_tween.tween_property(main_cam, "global_position", original_cam_pos, trans_time)
	#cam_tween.tween_property(main_cam, "zoom", Vector2(1.0,1.0), trans_time)
	
	#if npc:
		#npc_tween.tween_property(npc_sprite.get_parent(), "global_position", original_npc_pos, thought_trans_time).set_trans(Tween.TRANS_QUINT)
		#npc_tween.tween_property(npc_sprite, "scale", Vector2(1.0,1.0), thought_trans_time).set_trans(Tween.TRANS_BACK)
		#npc_tween.play()
	
	await player_tween.finished


func tween_to_talk(trans_time: float):
	scene = "talk"
	
	var player_tween: Tween = get_tree().create_tween().set_parallel()
	var cam_tween: Tween = get_tree().create_tween().set_parallel()
	var subject_tween: Tween = get_tree().create_tween().set_parallel()
	
	player.sprite.play("talk")
	
	if subject:
		player_tween.tween_property(player.sprite.get_parent(), "global_position", original_player_pos, trans_time*.8).set_trans(Tween.TRANS_BACK)
		player_tween.play()
	
		#cam_tween.tween_property(main_cam, "global_position", original_cam_pos, trans_time).set_trans(Tween.TRANS_EXPO)
		#cam_tween.tween_property(main_cam, "zoom", Vector2(1,1), trans_time).set_trans(Tween.TRANS_EXPO)
		#cam_tween.play()
		
		#npc_tween.tween_property(npc_sprite.get_parent(), "global_position", npc.global_position, trans_time).set_trans(Tween.TRANS_QUINT)
		#npc_tween.tween_property(npc_sprite, "scale", transitioners.get_node("TransNPCTalk").global_scale, trans_time).set_trans(Tween.TRANS_BACK)
		#npc_tween.play()
	
	await player_tween.finished


func tween_to_thought():
	scene = "thought"
	
	var player_tween: Tween = get_tree().create_tween().set_parallel()
	var cam_tween: Tween = get_tree().create_tween().set_parallel()
	var subject_tween: Tween = get_tree().create_tween().set_parallel()
	
	var trans_time = 1.5
	
	player.sprite.play("thought")
	
	if subject:
		#player_tween.tween_property(player, "global_position", main_cam.global_position, 1.2).set_trans(Tween.TRANS_BACK)
		player_tween.tween_property(player.sprite, "scale", transitioners.get_node("TransPlayerThought").global_scale, trans_time).set_trans(Tween.TRANS_BACK)
		player_tween.play()
	
		#cam_tween.tween_property(main_cam, "global_position", player.global_position + Vector2(0,-120), trans_time).set_trans(Tween.TRANS_EXPO)
		#cam_tween.tween_property(main_cam, "zoom", Vector2(1.5,1.5), trans_time).set_trans(Tween.TRANS_EXPO)
		
		#npc_tween.tween_property(npc_sprite.get_parent(), "global_position", transitioners.get_node("TransNPCThought").global_position + cam_offset(), trans_time).set_trans(Tween.TRANS_QUINT)
		#npc_tween.tween_property(npc_sprite, "scale", transitioners.get_node("TransNPCThought").global_scale, trans_time).set_trans(Tween.TRANS_BACK)
		#npc_tween.play()
	
	await player_tween.finished
	
	pass


func get_choices(d_object: DialogueObject):
	var choices = []
	
	for child in d_object.get_children():
		if child is DialogueChoice:
			choices.append(child)
	
	return choices
