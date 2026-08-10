extends Node2D

@onready var front_yard: Node2D = %FrontYard
@onready var living_room: Node2D = %LivingRoom
@onready var kitchen: Node2D = %Kitchen
@onready var hallway: Node2D = %Hallway
@onready var bathroom: Node2D = %Bathroom
@onready var backyard: Node2D = %Backyard

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
	%Cheats.cheat_entered.connect(_cheat_entered)

func _cheat_entered(cheat: String):
	if cheat.match("env_*"):
		var env = Environments.get(cheat.substr(4).to_upper())
		if env:
			print("ENV:", env)
			switch_environment(env)

func switch_environment(new_evironment: Environments) -> void:
	move_old_environment(current_environment)
	current_environment = new_evironment
	
	match new_evironment:
		Environments.FRONT_YARD:
			front_yard.global_position = Vector2(0,0)
			front_yard.show()
		Environments.LIVING_ROOM:
			living_room.global_position = Vector2(0,0)
			living_room.show()
		Environments.KITCHEN:
			kitchen.global_position = Vector2(0,0)
			kitchen.show()
		Environments.HALLWAY:
			hallway.global_position = Vector2(0,0)
			hallway.show()
		Environments.BATHROOM:
			bathroom.global_position = Vector2(0,0)
			bathroom.show()
		Environments.BACKYARD:
			backyard.global_position = Vector2(0,0)
			backyard.show()
	
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
