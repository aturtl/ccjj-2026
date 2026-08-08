extends Node2D

enum CameraAnimation {TALK, THOUGHT}
var current_camera_animation: int = 0

@export var talk_cam: Camera2D
@export var player_sprite: AnimatedSprite2D
@export var npc_sprite: AnimatedSprite2D
@export var transitioners: Node2D

@export_category("Talkers")
@export var ui_npc_talk: UITalk
@export var ui_choice_display: UIChoiceDisplay
@export var ui_thought_talk: UITalk

@onready var cheats: Cheats = %Cheats

@export_category("Cheats")
@export var dia_ex_lines: DialogueLine
@export var dia_ex_choice: DialogueLine
@export var dia_ex_thought: DialogueLine

@export_category("Temporary")
@export var debug_rect_display: ColorRect

func _ready():
	cheats.cheat_entered.connect(dialogue_cheats)


func dialogue_cheats(s: String):
	match s:
		"dia_ex":
			dialogue_start(dia_ex_lines)
		"dia_ex_choice":
			dialogue_start(dia_ex_choice)
		"dia_ex_thought":
			dialogue_start(dia_ex_thought)

#region dialogue loop
func dialogue_start(dl:DialogueLine):
	display_ui()
	dialogue_loop(dl)


func dialogue_loop(dl:DialogueLine):
	if !dl:
		dialogue_end()
		return
	
	if dl is DialogueStatement:
		player_sprite.play("talk")
		# current_camera_animation = CameraAnimation.TALK
		
		tween_to_talk()
		
		ui_npc_talk.talk(dl.dialogue)
		
		await ui_npc_talk.start_next
		
		dialogue_loop(dl.goto)
		
	elif dl is DialogueQuestion:
		ui_npc_talk.talk(dl.dialogue)
		
		await ui_npc_talk.start_next
		
		await tween_to_thought()
		
		var choices = get_choices(dl)
		ui_choice_display.display_choices(choices)
		
		var goto: DialogueLine = await ui_choice_display.choice_selected
		
		tween_to_talk()
		dialogue_loop(goto)
		print("QUESTION ASKED")
	
	elif dl is DialoguePlayerThought:
		ui_thought_talk.talk(dl.dialogue)
		
		await ui_thought_talk.start_next
		
		dialogue_loop(dl.goto)


func dialogue_end():
	pass
	#stuff
#endregion

func display_ui():
	pass


func tween_to_thought():
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


func tween_to_talk():
	var player_tween: Tween = get_tree().create_tween().set_parallel()
	var cam_tween: Tween = get_tree().create_tween().set_parallel()
	var npc_tween: Tween = get_tree().create_tween().set_parallel()
	
	var thought_trans_time = 1.5
	
	player_sprite.play("talk")
	
	player_tween.tween_property(player_sprite.get_parent(), "global_position", transitioners.get_node("TransPlayerTalk").global_position, 1.2).set_trans(Tween.TRANS_BACK)
	player_tween.tween_property(player_sprite, "scale", transitioners.get_node("TransPlayerTalk").global_scale, thought_trans_time).set_trans(Tween.TRANS_BACK)
	player_tween.play()
	
	cam_tween.tween_property(talk_cam, "global_position", transitioners.get_node("TransCameraTalk").global_position, thought_trans_time).set_trans(Tween.TRANS_EXPO)
	cam_tween.tween_property(talk_cam, "zoom", transitioners.get_node("TransPlayerTalk").global_scale, thought_trans_time).set_trans(Tween.TRANS_EXPO)
	cam_tween.play()
	
	npc_tween.tween_property(npc_sprite.get_parent(), "global_position", transitioners.get_node("TransNPCTalk").global_position, thought_trans_time).set_trans(Tween.TRANS_QUINT)
	npc_tween.tween_property(npc_sprite, "scale", transitioners.get_node("TransNPCTalk").global_scale, thought_trans_time).set_trans(Tween.TRANS_BACK)
	npc_tween.play()
	
	await player_tween.finished


func get_choices(dl: DialogueLine):
	var choices = []
	
	for child in dl.get_children():
		if child is DialogueChoice:
			choices.append(child)
	
	return choices
