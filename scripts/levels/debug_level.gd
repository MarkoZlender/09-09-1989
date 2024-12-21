extends Node3D

@export var player_data: PlayerData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SaveManager.load_game(1)
	print(get_tree().get_nodes_in_group("savable"))
	InteractionManager.player = get_tree().get_first_node_in_group("player")