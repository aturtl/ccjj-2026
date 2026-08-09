extends Node2D

enum CameraAnimation {TALK, THOUGHT}
var current_camera_animation: int = 0

@export var talk_cam: Camera2D
@export var player_sprite: AnimatedSprite2D
@export var npc_sprite: AnimatedSprite2D
@export var transitioners: Node2D

@export_category("Talkers")
@export var ui_npc_talk: UITalkNPC
@export var ui_choice_display: UIChoiceDisplay
@export var ui_thought_talk: UITalkThought

@onready var cheats: Cheats = %Cheats

@export_category("Cheats")
@export var dia_ex_lines: DialogueLine
@export var dia_ex_choice: DialogueLine
@export var dia_ex_thought: DialogueLine

@export_category("Temporary")
@export var debug_rect_display: ColorRect
@export var blip_player: AudioStreamPlayer
@export var blip_dynamic_range: float = .1

var original_player_pos: Vector2
var original_npc_pos: Vector2
var original_cam_pos: Vector2

var scene = ""

func _ready():
	cheats.cheat_entered.connect(dialogue_cheats)


#region temp
func dialogue_cheats(s: String):
	match s:
		"dia_ex":
			dialogue_start(dia_ex_lines)
		"dia_ex_choice":
			dialogue_start(dia_ex_choice)
		"dia_ex_thought":
			dialogue_start(dia_ex_thought)


func play_blip(dyn_range: float = blip_dynamic_range):
	blip_player.pitch_scale = randf_range(1-dyn_range,1+dyn_range)
	blip_player.play()
#endregion

#region dialogue loop
func dialogue_start(dl:DialogueLine):
	scene = ""
	original_player_pos = player_sprite.get_parent().global_position
	original_npc_pos = npc_sprite.get_parent().global_position
	original_cam_pos = talk_cam.global_position
	display_ui()
	dialogue_loop(dl)


func dialogue_loop(dl:DialogueLine):
	if !dl:
		dialogue_end()
		return
	
	if dl.switch_npc_animation_to != "":
		npc_sprite.play(dl.switch_npc_animation_to)
	
	if dl.switch_player_animation_to != "":
		player_sprite.play(dl.switch_player_animation_to)
	
	if dl is DialogueStatement:
		player_sprite.play("talk")
		# current_camera_animation = CameraAnimation.TALK
		
		if scene == "":
			await tween_to_talk(1.5)
		else:
			tween_to_talk(1.5)
		
		ui_npc_talk.talk(dl)
		
		await ui_npc_talk.start_next
		
		if !(dl.goto is DialogueStatement):
			ui_npc_talk.kill_all_box_instances()
		loop_with_parallels(dl)
		
	elif dl is DialogueQuestion:
		kill_boxes()
		
		await tween_to_thought()
		
		var choices = get_choices(dl)
		ui_choice_display.display_choices(choices)
		
		var choice_dl: DialogueChoice = await ui_choice_display.choice_selected
		
		tween_to_talk(1.5)
		
		loop_with_parallels(choice_dl)
		
		print("QUESTION ASKED")
	
	elif dl is DialoguePlayerThought:
		ui_thought_talk.talk(dl)
		
		await ui_thought_talk.start_next
		
		if !(dl.goto is DialoguePlayerThought):
			ui_thought_talk.kill_box_instance()
		loop_with_parallels(dl)
	
	elif dl is DialogueSetCam:
		if dl.id == "Player":
			tween_back_to_original_positions()
	
	elif dl is DialogueFadeScreen:
		await get_tree().create_timer(dl.fade_time).timeout #replace with screen tween
		loop_with_parallels(dl)
	
	elif dl is DialoguePlaySound:
		loop_with_parallels(dl) # add func
	
	elif dl is DialogueReward:
		loop_with_parallels(dl) # add func


func kill_boxes():
	ui_npc_talk.kill_all_box_instances()
	ui_thought_talk.kill_box_instance()


func dialogue_end():
	kill_boxes()
#endregion


func loop_with_parallels(dl: DialogueLine):
	dialogue_loop(dl.goto)
	for goto in dl.parallel_gotos:
		print("p_loop", dl)
		dialogue_loop(goto)


func display_ui():
	pass


func tween_back_to_original_positions(): # right now, I just send them into space
	var player_tween: Tween = get_tree().create_tween().set_parallel()
	var cam_tween: Tween = get_tree().create_tween().set_parallel()
	var npc_tween: Tween = get_tree().create_tween().set_parallel()
	
	var thought_trans_time = 1.5
	
	player_sprite.play("thought")
	
	player_tween.tween_property(player_sprite.get_parent(), "global_position", original_player_pos, 1.2).set_trans(Tween.TRANS_BACK)
	player_tween.tween_property(player_sprite, "scale", Vector2(1.0,1.0), thought_trans_time).set_trans(Tween.TRANS_BACK)
	player_tween.play()
	
	cam_tween.tween_property(talk_cam, "global_position", original_cam_pos, thought_trans_time).set_trans(Tween.TRANS_EXPO)
	cam_tween.tween_property(talk_cam, "zoom", Vector2(1.0,1.0), thought_trans_time).set_trans(Tween.TRANS_EXPO)
	cam_tween.play()
	
	npc_tween.tween_property(npc_sprite.get_parent(), "global_position", original_npc_pos, thought_trans_time).set_trans(Tween.TRANS_QUINT)
	npc_tween.tween_property(npc_sprite, "scale", Vector2(1.0,1.0), thought_trans_time).set_trans(Tween.TRANS_BACK)
	npc_tween.play()
	
	await player_tween.finished


func tween_to_thought():
	scene = "thought"
	
	var player_tween: Tween = get_tree().create_tween().set_parallel()
	var cam_tween: Tween = get_tree().create_tween().set_parallel()
	var npc_tween: Tween = get_tree().create_tween().set_parallel()
	
	var thought_trans_time = 1.5
	
	player_sprite.play("thought")
	
	player_tween.tween_property(player_sprite.get_parent(), "global_position", transitioners.get_node("TransPlayerThought").global_position, 1.2).set_trans(Tween.TRANS_BACK)
	player_tween.tween_property(player_sprite, "scale", transitioners.get_node("TransPlayerThought").global_scale, thought_trans_time).set_trans(Tween.TRANS_BACK)
	player_tween.play()
	
	cam_tween.tween_property(talk_cam, "global_position", transitioners.get_node("TransCameraThought").global_position, thought_trans_time).set_trans(Tween.TRANS_EXPO)
	cam_tween.tween_property(talk_cam, "zoom", transitioners.get_node("TransCameraThought").global_scale, thought_trans_time).set_trans(Tween.TRANS_EXPO)
	cam_tween.play()
	
	npc_tween.tween_property(npc_sprite.get_parent(), "global_position", transitioners.get_node("TransNPCThought").global_position, thought_trans_time).set_trans(Tween.TRANS_QUINT)
	npc_tween.tween_property(npc_sprite, "scale", transitioners.get_node("TransNPCThought").global_scale, thought_trans_time).set_trans(Tween.TRANS_BACK)
	npc_tween.play()
	
	await player_tween.finished
	
	pass


func tween_to_talk(trans_time: float):
	scene = "talk"
	
	var player_tween: Tween = get_tree().create_tween().set_parallel()
	var cam_tween: Tween = get_tree().create_tween().set_parallel()
	var npc_tween: Tween = get_tree().create_tween().set_parallel()
	
	player_sprite.play("talk")
	
	player_tween.tween_property(player_sprite.get_parent(), "global_position", transitioners.get_node("TransPlayerTalk").global_position, trans_time*.8).set_trans(Tween.TRANS_BACK)
	player_tween.tween_property(player_sprite, "scale", transitioners.get_node("TransPlayerTalk").global_scale, trans_time).set_trans(Tween.TRANS_BACK)
	player_tween.play()
	
	cam_tween.tween_property(talk_cam, "global_position", transitioners.get_node("TransCameraTalk").global_position, trans_time).set_trans(Tween.TRANS_EXPO)
	cam_tween.tween_property(talk_cam, "zoom", transitioners.get_node("TransPlayerTalk").global_scale, trans_time).set_trans(Tween.TRANS_EXPO)
	cam_tween.play()
	
	npc_tween.tween_property(npc_sprite.get_parent(), "global_position", transitioners.get_node("TransNPCTalk").global_position, trans_time).set_trans(Tween.TRANS_QUINT)
	npc_tween.tween_property(npc_sprite, "scale", transitioners.get_node("TransNPCTalk").global_scale, trans_time).set_trans(Tween.TRANS_BACK)
	npc_tween.play()
	
	await player_tween.finished


func get_choices(dl: DialogueLine):
	var choices = []
	
	for child in dl.get_children():
		if child is DialogueChoice:
			choices.append(child)
	
	return choices
