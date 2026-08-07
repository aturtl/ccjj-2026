class_name EVILFISH extends Sprite2D


@export var attack_pos: Node2D
@export var cam2button: CamButton
var original_position = position


@export var custom_timer = 15.0
var tween: Tween


@export var sanity_label: RichTextLabel


func tween_towards():
	tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", attack_pos.global_position, custom_timer)
	tween.play()
	tween.finished.connect(tween_finished)


func bd():
	visible = true
	if tween:
		tween.finished.disconnect(tween_finished)
		tween.kill()
	position = original_position
	tween_towards()


func tween_finished():
	sanity_label.sanity -= 1
	sanity_label.text = "SANITY: "+str(sanity_label.sanity)
	visible = false


func _ready():
	cam2button.button_down.connect(bd)
