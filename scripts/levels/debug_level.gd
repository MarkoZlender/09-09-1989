extends Node3D

@export var player_data: PlayerData
@export var debug_mode: bool = false

func _ready() -> void:
	pass
	# if !debug_mode:
	# 	Global.save_manager.load_game(Global.save_manager.current_save_slot)
	# 	print("saved")
	# 	Global.interaction_manager.player = get_tree().get_first_node_in_group("player")
	# else:
	# 	pass
	
