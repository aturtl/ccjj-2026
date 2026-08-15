extends Node2D

enum CameraAnimation {TALK, THOUGHT}
var current_camera_animation: int = 0

@export var main_cam: MainCamera
@export var talk_cam: FakeCam
@export var player_sprite: AnimatedSprite2D
@export var npc_sprite: AnimatedSprite2D
@export var transitioners: Node2D
@export var screen_fader: ColorRect

@export var instance_connectors: Node2D

@export_category("Talkers")
@export var ui_npc_talk_left: UITalkNPC
@export var ui_npc_talk_right: UITalkNPC
@export var ui_choice_display: UIChoiceDisplay
@export var ui_thought_talk: UITalkThought
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
var original_npc_pos: Vector2
var original_cam_pos: Vector2

var original_cam_trans: Transform2D

var parallel_count: int = 0

var scene = ""

var npc: NPC = null
@export var player: Player

func _ready():
	pass


func play_blip(dyn_range: float = blip_dynamic_range):
	var pitch_scale = randf_range(1-dyn_range,1+dyn_range)
	blip_player.play()


func cam_offset():
	return original_cam_pos - Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"),ProjectSettings.get_setting("display/window/size/viewport_height"))/2.0


#region dialogue loop
func dialogue_start(d_object:DialogueLine, npc: NPC):
	player.dialogue_lock = true
	main_cam.current_state = main_cam.State.DIALOGUE
	
	self.npc = npc
	
	parallel_count += 1
	
	scene = ""
	original_player_pos = player.global_position
	original_npc_pos = npc.global_position
	original_cam_pos = main_cam.global_position
	
	original_cam_trans = main_cam.global_transform
	
	display_ui()
	dialogue_loop(d_object)


func dialogue_loop(d_object:DialogueObject):
	var npc_pos = npc.global_position if npc else Vector2(0,0)
	
	if !d_object:
		dialogue_end()
		return
	
	if d_object is DialogueLine:
		if d_object.switch_npc_animation_to != "":
			if d_object.switch_npc_animation_to == "gone":
				npc_sprite.visible = false
			else:
				npc_sprite.play(d_object.switch_npc_animation_to)
		
		if d_object.switch_player_animation_to != "":
			player_sprite.play(d_object.switch_player_animation_to)
	
	if d_object is DialogueStatement:
		#player_sprite.play("talk")
		# current_camera_animation = CameraAnimation.TALK
		
		if scene == "":
			await tween_to_talk(1.5)
		else:
			tween_to_talk(1.5)
		
		var ui_npc_talk = ui_npc_talk_left if main_cam.global_position.x < npc.global_position.x else ui_npc_talk_right
		
		ui_npc_talk.talk(d_object, npc_pos + Vector2(0, -200))
		
		await ui_npc_talk.start_next
		
		if !(d_object.goto is DialogueStatement):
			ui_npc_talk.kill_all_box_instances()
		loop_with_parallels(d_object)
	
	elif d_object is DialoguePlayerThought:
		ui_thought_talk.talk(d_object, player.global_position)
		
		await ui_thought_talk.start_next
		
		if !(d_object.goto is DialoguePlayerThought):
			ui_thought_talk.kill_box_instance()
		loop_with_parallels(d_object)	
	
	elif d_object is DialogueQuestion:
		kill_boxes()
		
		await tween_to_thought()
		
		var choices = get_choices(d_object)
		ui_choice_display.display_choices(choices, transitioners.get_node("TransDisplayChoices").global_position + cam_offset())
		
		var choice_d_object: DialogueChoice = await ui_choice_display.choice_selected
		
		fade_screen(false, .5)
		
		
		tween_to_talk(1.5)
		
		loop_with_parallels(choice_d_object)
		
		print("QUESTION ASKED")
	
	elif d_object is DialogueSetCam:
		if d_object.id == "Player":
			tween_back_to_original_positions()
		if d_object.id == "Talk":
			tween_to_talk(1.5)
		if d_object.id == "Thought":
			tween_to_thought()
		loop_with_parallels(d_object)
	
	elif d_object is DialogueFadeScreen:
		await fade_screen(d_object.fade_type == d_object.FadeType.IN,d_object.fade_time)
		
		loop_with_parallels(d_object)
	
	elif d_object is DialoguePlaySound:
		AudioManager.play_sfx(d_object.audio_stream)
		loop_with_parallels(d_object) # add func
	
	elif d_object is DialogueStatSetter:
		Stats.confidence += d_object.confidence_reward
		d_object.confidence_reward = 0
		if d_object.add_item:
			Inventory.add_item(d_object.add_item)
		if d_object.remove_item:
			Inventory.remove_item(d_object.remove_item)
		loop_with_parallels(d_object) # add func
	
	elif d_object is DialogueReward:
		await ui_reward.display(d_object.reward_text)
		loop_with_parallels(d_object)
	
	elif d_object is DialogueChangeScene:
		#change scene here
		loop_with_parallels(d_object)
	
	elif d_object is DialogueSwitch:
		var switch_connector = instance_connectors.get_node(d_object.switch_connector_name)
		if switch_connector:
			switch_connector.connected_tree = d_object.switch_tree
		loop_with_parallels(d_object)


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
	ui_thought_talk.kill_box_instance()


func dialogue_end():
	parallel_count -= 1
	if parallel_count == 0:
		kill_boxes()
		await tween_back_to_original_positions()
		main_cam.current_state = main_cam.State.FOLLOW
		player.dialogue_lock = false
		
	else:
		pass
#endregion


func loop_with_parallels(d_object: DialogueObject):
	if d_object.after_wait > 0.0:
		await get_tree().create_timer(d_object.after_wait).timeout
	dialogue_loop(d_object.goto)
	for goto in d_object.parallel_gotos:
		print("p_loop", d_object)
		dialogue_loop(goto)


func display_ui():
	pass


func tween_back_to_original_positions(): # right now, I just send them into space
	var player_tween: Tween = get_tree().create_tween().set_parallel()
	var cam_tween: Tween = get_tree().create_tween().set_parallel()
	var npc_tween: Tween = get_tree().create_tween().set_parallel()
	
	var thought_trans_time = 1.5
	
	player.sprite.play("idle")
	
	#player_tween.tween_property(player, "global_position", original_player_pos, .6).set_trans(Tween.TRANS_CIRC)
	player_tween.tween_property(player.sprite, "scale", Vector2(1.0,1.0), .5).set_trans(Tween.TRANS_CIRC)
	player_tween.play()
	
	cam_tween.tween_property(main_cam, "global_position", original_cam_pos, .5)
	cam_tween.tween_property(main_cam, "zoom", Vector2(1.0,1.0), .5)
	
	#if npc:
		#npc_tween.tween_property(npc_sprite.get_parent(), "global_position", original_npc_pos, thought_trans_time).set_trans(Tween.TRANS_QUINT)
		#npc_tween.tween_property(npc_sprite, "scale", Vector2(1.0,1.0), thought_trans_time).set_trans(Tween.TRANS_BACK)
		#npc_tween.play()
	
	await player_tween.finished


func tween_to_talk(trans_time: float):
	scene = "talk"
	
	var player_tween: Tween = get_tree().create_tween().set_parallel()
	var cam_tween: Tween = get_tree().create_tween().set_parallel()
	var npc_tween: Tween = get_tree().create_tween().set_parallel()
	
	player.sprite.play("talk")
	
	if npc:
		player_tween.tween_property(player.sprite.get_parent(), "global_position", original_player_pos, trans_time*.8).set_trans(Tween.TRANS_BACK)
		player_tween.play()
	
		cam_tween.tween_property(main_cam, "global_position", original_cam_pos, trans_time).set_trans(Tween.TRANS_EXPO)
		cam_tween.tween_property(main_cam, "zoom", Vector2(1,1), trans_time).set_trans(Tween.TRANS_EXPO)
		cam_tween.play()
		
		#npc_tween.tween_property(npc_sprite.get_parent(), "global_position", npc.global_position, trans_time).set_trans(Tween.TRANS_QUINT)
		#npc_tween.tween_property(npc_sprite, "scale", transitioners.get_node("TransNPCTalk").global_scale, trans_time).set_trans(Tween.TRANS_BACK)
		#npc_tween.play()
	
	await player_tween.finished


func tween_to_thought():
	scene = "thought"
	
	fade_screen(true, .5)
	var player_tween: Tween = get_tree().create_tween().set_parallel()
	var cam_tween: Tween = get_tree().create_tween().set_parallel()
	var npc_tween: Tween = get_tree().create_tween().set_parallel()
	
	var trans_time = 1.5
	
	player.sprite.play("thought")
	
	if npc:
		#player_tween.tween_property(player, "global_position", main_cam.global_position, 1.2).set_trans(Tween.TRANS_BACK)
		player_tween.tween_property(player.sprite, "scale", transitioners.get_node("TransPlayerThought").global_scale, trans_time).set_trans(Tween.TRANS_BACK)
		player_tween.play()
	
		cam_tween.tween_property(main_cam, "global_position", player.global_position + Vector2(0,-120), trans_time).set_trans(Tween.TRANS_EXPO)
		cam_tween.tween_property(main_cam, "zoom", Vector2(1.5,1.5), trans_time).set_trans(Tween.TRANS_EXPO)
		
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
