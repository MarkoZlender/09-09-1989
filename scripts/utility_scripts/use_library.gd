class_name UseLibrary extends Node

@onready var inventory: Inventory = Global.inventory
@onready var player_data: PlayerData = load("res://resources/player_data.tres")

func use_potion() -> void:
	if player_data.health >= player_data.max_health:
		return
	player_data.health += 10
	Global.signal_bus.player_healed.emit(player_data.health)
