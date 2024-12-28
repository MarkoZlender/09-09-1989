extends Node3D

@export var player_data: PlayerData

func _ready() -> void:
	Global.save_manager.load_game(1)
	print(get_tree().get_nodes_in_group("savable"))
	Global.interaction_manager.player = get_tree().get_first_node_in_group("player")
	print(Global.save_manager.get_current_level(1))
