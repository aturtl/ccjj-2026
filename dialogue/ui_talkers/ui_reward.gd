class_name UIReward extends UITalk

@export var box_template: BoxTemplate
@export var in_between_time = .06
@export var end_wait = .7
@export var reward_screen: ColorRect

var box_instance: BoxTemplate

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
	box_template.modulate.a = 0.0
	box_template.visible = true
	var tween = get_tree().create_tween()
	set_text(reward_text)
	tween.tween_property(box_template, "modulate:a", 1.0, 1.0)
	tween.tween_await(get_tree().create_timer(3.0).timeout)
	tween.tween_property(box_template, "modulate:a", 0.0, 1.0)
	tween.play()
	await tween.finished
	box_template.visible = false
	print("TweenFinished")
