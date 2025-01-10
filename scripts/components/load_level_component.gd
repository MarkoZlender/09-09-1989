extends Node

@export var debug_mode: bool = false
@onready var parent: Node = get_parent()

func _ready() -> void:
	await parent.ready
	if !debug_mode:
		Global.save_manager.load_game(Global.save_manager.current_save_slot)
		Global.interaction_manager.player = get_tree().get_first_node_in_group("player")
	else:
		pass