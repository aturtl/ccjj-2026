extends Node

const MASTER_BUS: String = "Master"
const MUSIC_BUS: String = "Music"
const SFX_BUS: String = "SFX"

const MAX_SFX := 8

var active_sfx := 0

#region VOLUME

func set_master_volume(volume: float) -> void:
	_set_bus_volume(MASTER_BUS, volume)


func set_music_volume(volume: float) -> void:
	_set_bus_volume(MUSIC_BUS, volume)


func set_sfx_volume(volume: float) -> void:
	_set_bus_volume(SFX_BUS, volume)


func _set_bus_volume(bus_name: String, volume: float) -> void:
	var bus: int = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_linear(bus, volume)

#endregion

#region MUTE

func set_master_muted(muted: bool) -> void:
	_set_bus_muted(MASTER_BUS, muted)


func set_music_muted(muted: bool) -> void:
	_set_bus_muted(MUSIC_BUS, muted)


func set_sfx_muted(muted: bool) -> void:
	_set_bus_muted(SFX_BUS, muted)


func _set_bus_muted(bus_name: String, muted: bool) -> void:
	var bus: int = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_mute(bus, muted)

#endregion

#region SFX

func play_sfx(stream: AudioStream) -> void:
	if active_sfx >= MAX_SFX:
		return

	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = SFX_BUS

	add_child(player)

	active_sfx += 1

	player.finished.connect(func():
		active_sfx -= 1
		player.queue_free()
	)

	player.play()

	#endregion
