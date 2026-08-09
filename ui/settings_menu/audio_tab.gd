extends VBoxContainer

@onready var master_slider: HSlider = $HBoxContainer/MasterSlider
@onready var music_slider: HSlider = $HBoxContainer2/MusicSlider
@onready var effects_slider: HSlider = $HBoxContainer3/EffectsSlider

@onready var master_check_box: CheckBox = $HBoxContainer/MasterCheckBox
@onready var music_check_box: CheckBox = $HBoxContainer2/MusicCheckBox
@onready var effects_check_box: CheckBox = $HBoxContainer3/EffectsCheckBox


func _on_master_volume_toggled(toggled_on: bool) -> void:
	master_slider.modulate = Color.DIM_GRAY if not toggled_on else Color.WHITE
	AudioManager.set_master_muted(not toggled_on)


func _on_master_slider_value_changed(value: float) -> void:
	AudioManager.set_master_volume(value)


func _on_music_volume_toggled(toggled_on: bool) -> void:
	music_slider.modulate = Color.DIM_GRAY if not toggled_on else Color.WHITE
	AudioManager.set_music_muted(not toggled_on)


func _on_music_slider_value_changed(value: float) -> void:
	AudioManager.set_music_volume(value)


func _on_effects_volume_toggled(toggled_on: bool) -> void:
	effects_slider.modulate = Color.DIM_GRAY if not toggled_on else Color.WHITE
	AudioManager.set_sfx_muted(not toggled_on)


func _on_effects_slider_value_changed(value: float) -> void:
	AudioManager.set_sfx_volume(value)
