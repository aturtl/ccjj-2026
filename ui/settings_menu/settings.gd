extends Control

#region AUDIO

var master_slider_val: float
var master_slider_val: float
var master_slider_val: float

@onready var master_slider: HSlider = $Panel/VBoxContainer/MarginContainer/TabContainer/Audio/HBoxContainer/MasterSlider
@onready var music_slider: HSlider = $Panel/VBoxContainer/MarginContainer/TabContainer/Audio/HBoxContainer2/MusicSlider
@onready var effects_slider: HSlider = $Panel/VBoxContainer/MarginContainer/TabContainer/Audio/HBoxContainer3/EffectsSlider


#region MASTER
func _on_master_volume_toggled(toggled_on: bool) -> void:
	# mute master bus
	if toggled_on:
		master_slider.modulate = Color.DIM_GRAY
	else:
		master_slider.modulate = Color.WHITE
	pass

func _on_master_slider_changed() -> void:
	# change master audio bus
	pass
#endregion

#region MUSIC
func _on_music_volume_pressed() -> void:
	# mute music bus
	pass
	

func _on_music_slider_changed() -> void:
	# change music audio bus
	pass

#endregion

#region EFFECTS
func _on_effects_volume_pressed() -> void:
	# mute effects bus
	pass

func _on_effects_slider_changed() -> void:
	# change effects audio bus
	pass
#endregion

#endregion


func _on_back_pressed() -> void:
	UIManager.switch_to_previous()
