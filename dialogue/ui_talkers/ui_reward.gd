class_name UIReward extends UITalk

@export var box_template: BoxTemplate
@export var in_between_time = .06
@export var end_wait = .7
@export var reward_screen: ColorRect

@onready var screen = $Screen
@export var label: RichTextLabel

@export var char_sticker: AnimatedSprite2D

signal talk_ended
signal start_next

func _ready():
	box_template.visible = false


#region sounds (not implemented)
func play_talk_sound():
	pass
#endregion


func set_text(reward_text: String):
	box_template.label.text = "[center]"+reward_text+"[/center]"


func display(reward_text: String):
	char_sticker.scale = Vector2(.8,1.2)
	
	box_template.rotater.rotation = -PI*.125
	box_template.modulate.a = 0.0
	box_template.visible = true
	var tween = get_tree().create_tween()
	set_text(reward_text)
	tween.tween_property(box_template, "modulate:a", 1.0, .2)
	tween.tween_await(get_tree().create_timer(1.6).timeout)
	tween.tween_property(box_template, "modulate:a", 0.0, .2)
	tween.play()
	var label_tween = get_tree().create_tween()
	label_tween.parallel().tween_property(box_template.sizer, "global_scale", Vector2(1.8,1.8), 2.0)
	label_tween.play()
	
	var sticker_tween = get_tree().create_tween()
	for i in 10:
		sticker_tween.tween_property(char_sticker, "scale", Vector2(1.2,.8), .1).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
		sticker_tween.tween_property(char_sticker, "scale", Vector2(.8,1.2), .1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	sticker_tween.play()
	
	await tween.finished
	box_template.visible = false
	print("TweenFinished")
