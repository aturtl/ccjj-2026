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
@export var ui_npc_talk: UITalkNPC
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

func _ready():
	pass


func play_blip(dyn_range: float = blip_dynamic_range):
	var pitch_scale = randf_range(1-dyn_range,1+dyn_range)
	blip_player.play()


func cam_offset():
	return original_cam_pos - Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"),ProjectSettings.get_setting("display/window/size/viewport_height"))/2.0


#region dialogue loop
func dialogue_start(dl:DialogueLine):
	main_cam.current_state = main_cam.State.DIALOGUE
	
	parallel_count += 1
	
	scene = ""
	player_sprite.visible = true
	npc_sprite.visible = true
	original_player_pos = player_sprite.get_parent().global_position
	original_npc_pos = npc_sprite.get_parent().global_position
	original_cam_pos = main_cam.global_position
	
	original_cam_trans = main_cam.global_transform
	
	display_ui()
	dialogue_loop(dl)


func dialogue_loop(dl:DialogueLine):
	if !dl:
		dialogue_end()
		return
	
	if dl.switch_npc_animation_to != "":
		if dl.switch_npc_animation_to == "gone":
			npc_sprite.visible = false
		else:
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
		
		ui_npc_talk.talk(dl, transitioners.get_node("TransBoxTalk").global_position + cam_offset())
		
		await ui_npc_talk.start_next
		
		if !(dl.goto is DialogueStatement):
			ui_npc_talk.kill_all_box_instances()
		loop_with_parallels(dl)
		
	elif dl is DialogueQuestion:
		kill_boxes()
		
		await tween_to_thought()
		
		var choices = get_choices(dl)
		ui_choice_display.display_choices(choices, transitioners.get_node("TransDisplayChoices").global_position + cam_offset())
		
		var choice_dl: DialogueChoice = await ui_choice_display.choice_selected
		
		tween_to_talk(1.5)
		
		loop_with_parallels(choice_dl)
		
		print("QUESTION ASKED")
	
	elif dl is DialoguePlayerThought:
		ui_thought_talk.talk(dl, transitioners.get_node("TransPlayerTalk").global_position + cam_offset())
		
		await ui_thought_talk.start_next
		
		if !(dl.goto is DialoguePlayerThought):
			ui_thought_talk.kill_box_instance()
		loop_with_parallels(dl)
	
	elif dl is DialogueSetCam:
		if dl.id == "Player":
			tween_back_to_original_positions()
		if dl.id == "Talk":
			tween_to_talk(1.5)
		if dl.id == "Thought":
			tween_to_thought()
		loop_with_parallels(dl)
	
	elif dl is DialogueFadeScreen:
		screen_fader.visible = true
		
		var alpha = 1.0 if dl.fade_type == dl.FadeType.IN else 0.0
		
		var tween = get_tree().create_tween()
		tween.tween_property(screen_fader,"modulate:a",alpha,dl.fade_time)
		tween.play()
		
		await tween.finished
		
		if dl.fade_type == dl.FadeType.OUT:
			screen_fader.visible = false
		
		loop_with_parallels(dl)
	
	elif dl is DialoguePlaySound:
		AudioManager.play_sfx(dl.audio_stream)
		loop_with_parallels(dl) # add func
	
	elif dl is DialogueStatSetter:
		Stats.confidence += dl.confidence_reward
		dl.confidence_reward = 0
		if dl.add_item:
			Inventory.add_item(dl.add_item)
		if dl.remove_item:
			Inventory.remove_item(dl.remove_item)
		loop_with_parallels(dl) # add func
	
	elif dl is DialogueReward:
		await ui_reward.display(dl.reward_text)
		loop_with_parallels(dl)
	
	elif dl is DialogueChangeScene:
		#change scene here
		loop_with_parallels(dl)
	
	elif dl is DialogueSwitch:
		var switch_connector = instance_connectors.get_node(dl.switch_connector_name)
		if switch_connector:
			switch_connector.connected_tree = dl.switch_tree
		loop_with_parallels(dl)


func kill_boxes():
	ui_npc_talk.kill_all_box_instances()
	ui_thought_talk.kill_box_instance()


func dialogue_end():
	parallel_count -= 1
	if parallel_count == 0:
		kill_boxes()
		await tween_back_to_original_positions()
		main_cam.current_state = main_cam.State.FOLLOW
	else:
		pass
#endregion


func loop_with_parallels(dl: DialogueLine):
	if dl.after_wait > 0.0:
		await get_tree().create_timer(dl.after_wait).timeout
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
	
	cam_tween.set_trans(Tween.TRANS_EXPO)
	main_cam.tween_to_transform(original_cam_trans, cam_tween, thought_trans_time)
	
	npc_tween.tween_property(npc_sprite.get_parent(), "global_position", original_npc_pos, thought_trans_time).set_trans(Tween.TRANS_QUINT)
	npc_tween.tween_property(npc_sprite, "scale", Vector2(1.0,1.0), thought_trans_time).set_trans(Tween.TRANS_BACK)
	npc_tween.play()
	
	await player_tween.finished


func tween_to_thought():
	scene = "thought"
	
	var player_tween: Tween = get_tree().create_tween().set_parallel()
	var cam_tween: Tween = get_tree().create_tween().set_parallel()
	var npc_tween: Tween = get_tree().create_tween().set_parallel()
	
	var trans_time = 1.5
	
	player_sprite.play("thought")
	
	player_tween.tween_property(player_sprite.get_parent(), "global_position", transitioners.get_node("TransPlayerThought").global_position + cam_offset(), 1.2).set_trans(Tween.TRANS_BACK)
	player_tween.tween_property(player_sprite, "scale", transitioners.get_node("TransPlayerThought").global_scale, trans_time).set_trans(Tween.TRANS_BACK)
	player_tween.play()
	
	cam_tween.tween_property(main_cam, "global_position", transitioners.get_node("TransCameraThought").global_position + cam_offset(), trans_time).set_trans(Tween.TRANS_EXPO)
	cam_tween.tween_property(main_cam, "zoom", transitioners.get_node("TransCameraThought").global_scale, trans_time).set_trans(Tween.TRANS_EXPO)
	
	npc_tween.tween_property(npc_sprite.get_parent(), "global_position", transitioners.get_node("TransNPCThought").global_position + cam_offset(), trans_time).set_trans(Tween.TRANS_QUINT)
	npc_tween.tween_property(npc_sprite, "scale", transitioners.get_node("TransNPCThought").global_scale, trans_time).set_trans(Tween.TRANS_BACK)
	npc_tween.play()
	
	await player_tween.finished
	
	pass


func tween_to_talk(trans_time: float):
	scene = "talk"
	
	var player_tween: Tween = get_tree().create_tween().set_parallel()
	var cam_tween: Tween = get_tree().create_tween().set_parallel()
	var npc_tween: Tween = get_tree().create_tween().set_parallel()
	
	player_sprite.play("talk")
	
	player_tween.tween_property(player_sprite.get_parent(), "global_position", transitioners.get_node("TransPlayerTalk").global_position + cam_offset(), trans_time*.8).set_trans(Tween.TRANS_BACK)
	player_tween.tween_property(player_sprite, "scale", transitioners.get_node("TransPlayerTalk").global_scale, trans_time).set_trans(Tween.TRANS_BACK)
	player_tween.play()
	
	cam_tween.tween_property(main_cam, "global_position", transitioners.get_node("TransCameraTalk").global_position + cam_offset(), trans_time).set_trans(Tween.TRANS_EXPO)
	cam_tween.tween_property(main_cam, "zoom", transitioners.get_node("TransCameraTalk").global_scale, trans_time).set_trans(Tween.TRANS_EXPO)
	
	npc_tween.tween_property(npc_sprite.get_parent(), "global_position", transitioners.get_node("TransNPCTalk").global_position + cam_offset(), trans_time).set_trans(Tween.TRANS_QUINT)
	npc_tween.tween_property(npc_sprite, "scale", transitioners.get_node("TransNPCTalk").global_scale, trans_time).set_trans(Tween.TRANS_BACK)
	npc_tween.play()
	
	await player_tween.finished


func get_choices(dl: DialogueLine):
	var choices = []
	
	for child in dl.get_children():
		if child is DialogueChoice:
			choices.append(child)
	
	return choices
