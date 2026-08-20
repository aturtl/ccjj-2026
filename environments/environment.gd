extends Node2D

@onready var front_yard: EnvironmentHolder = $FrontYard
@onready var living_room: EnvironmentHolder = $NewLivingRoom
@onready var kitchen: EnvironmentHolder = $Kitchen
@onready var hallway: EnvironmentHolder = $Hallway
@onready var bathroom: EnvironmentHolder = $Bathroom
@onready var backyard: EnvironmentHolder = $Backyard

var current_environment: Environments

enum Environments {
	NONE,
	FRONT_YARD,
	LIVING_ROOM,
	KITCHEN,
	HALLWAY,
	BATHROOM,
	BACKYARD
}

func _ready() -> void:
	switch_environment(Environments.FRONT_YARD)
	%CheatsUI.cheat_entered.connect(_cheat_entered)

func _cheat_entered(cheat: String):
	if cheat.match("env_*"):
		var env = Environments.get(cheat.substr(4).to_upper())
		if env:
			switch_environment(env)
	if cheat.match("en_*"):
		switch_environment(int(cheat.substr(3)))

func show_environment(env: EnvironmentHolder):
	env.global_position = Vector2.ZERO
	env.calculate_bounds()
	%MainCamera.environment_holder = env
	%MainCamera.snap_cam_to_bounds()
	env.show()

func switch_environment(new_evironment: Environments) -> void:
	move_old_environment(current_environment)
	current_environment = new_evironment
	
	match new_evironment:
		Environments.FRONT_YARD:
			show_environment(front_yard)
		Environments.LIVING_ROOM:
			show_environment(living_room)
		Environments.KITCHEN:
			show_environment(kitchen)
		Environments.HALLWAY:
			show_environment(hallway)
		Environments.BATHROOM:
			show_environment(bathroom)
		Environments.BACKYARD:
			show_environment(backyard)
	
func move_old_environment(environment: Environments) -> void:
	match environment:
		Environments.FRONT_YARD:
			front_yard.global_position = Vector2(2000,0)
			front_yard.hide()
		Environments.LIVING_ROOM:
			living_room.global_position = Vector2(3000,0)
			living_room.hide()
		Environments.KITCHEN:
			kitchen.global_position = Vector2(4000,0)
			kitchen.hide()
		Environments.HALLWAY:
			hallway.global_position = Vector2(5000,0)
			hallway.hide()
		Environments.BATHROOM:
			bathroom.global_position = Vector2(6000,0)
			bathroom.hide()
		Environments.BACKYARD:
			backyard.global_position = Vector2(7000,0)
			backyard.hide()
