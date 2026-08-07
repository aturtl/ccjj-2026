extends Control

#region AUDIO

#region MASTER
func _on_master_volume_pressed() -> void:
	# mute master bus
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
