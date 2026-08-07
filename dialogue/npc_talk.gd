extends Node2D

enum CameraAnimation {TALK, THOUGHT}
var current_camera_animation: int = 0

@export var talk_ui: UITalk
@export var talk_cam: Camera2D

@export var player_sprite: AnimatedSprite2D
@export var npc_sprite: AnimatedSprite2D

@export var positioners: Node2D

func _ready():
	dialogue_start(get_child(0)) #temp for debug


func dialogue_start(dl:DialogueLine):
	display_ui()
	player_sprite.play("talk")
	current_camera_animation = CameraAnimation.TALK
	dialogue_loop(dl)


func dialogue_loop(dl:DialogueLine):
	talk_ui.play(dl.dialogue)
	
	if dl.dialogue_type == 0:
		await talk_ui.start_next
		
		if dl.goto:
			dialogue_loop(dl.goto)
		else:
			dialogue_end()
	elif dl.dialogue_type == 1:
		await talk_ui.start_next
		
		enter_thought_bubble()
		
		display_choices(dl)
		
		print("QUESTION ASKED")


func dialogue_end():
	pass
	#stuff


func display_ui():
	pass


func enter_thought_bubble():
	var player_tween: Tween = get_tree().create_tween().set_parallel()
	var cam_tween: Tween = get_tree().create_tween().set_parallel()
	var npc_tween: Tween = get_tree().create_tween().set_parallel()
	
	var thought_trans_time = 1.5
	
	player_sprite.play("thought")
	
	player_tween.tween_property(player_sprite, "global_position", positioners.get_node("PosPlayerThought").global_position, 1.2).set_trans(Tween.TRANS_BACK)
	player_tween.tween_property(player_sprite, "scale", Vector2(1.25,1.25), thought_trans_time).set_trans(Tween.TRANS_BACK)
	player_tween.play()
	
	cam_tween.tween_property(talk_cam, "global_position", positioners.get_node("PosCameraThought").global_position, thought_trans_time).set_trans(Tween.TRANS_EXPO)
	cam_tween.play()
	
	npc_tween.tween_property(npc_sprite, "global_position", positioners.get_node("PosNPCThought").global_position, thought_trans_time).set_trans(Tween.TRANS_QUINT)
	npc_tween.tween_property(npc_sprite, "scale", Vector2(.5,.5), thought_trans_time).set_trans(Tween.TRANS_BACK)
	npc_tween.play()
	
	pass


func get_choices(dl: DialogueLine):
	var choices = []
	
	for child in dl.get_children():
		if child is DialogueChoice:
			choices.append(child)
	
	return choices


func display_choices(dl: DialogueLine):
	var choices = get_choices(dl)
	
	var initial_angle = -PI/2.0 # will change later based on amount of choices
	
	for choice: DialogueChoice in choices:
		var text = choice.choice_text
		
