class_name Thought extends RichTextLabel


#@export var time = 3.0
#@export var cam2_button: CamButton
#
#
#@export var offset = 0.0
#
#
#func start_timer():
	#await get_tree().create_timer(time)
	#visible = true
#
#
#func _ready():
	#cam2_button.button_down.connect(bd)
	#
	#await get_tree().create_timer(offset).timeout
	#
	#var perma_tween = get_tree().create_tween()
	#
	#perma_tween.set_loops(-1)
	#
	#perma_tween.tween_property(self, "position", position + Vector2.UP*12.0, .8).set_trans(Tween.TRANS_SINE)
	#perma_tween.tween_property(self, "position", position + Vector2.UP*-12.0, .8).set_trans(Tween.TRANS_SINE)
	#perma_tween.play()
	#print('done')
#
#
#func bd():
	#visible = false
	#start_timer()
