extends Node

@export var debug_mode: bool = false
@onready var parent: Node = get_parent()
@onready var quest_objects = get_tree().get_nodes_in_group("quest_objects")


func _ready() -> void:
	await parent.ready
	for quest_object in quest_objects:
		if quest_object is Collectible:
			quest_object.connect("collected", Global.quest_manager.quests[0].update_collected)

	if !debug_mode:
		Global.save_manager.load_game(Global.save_manager.current_save_slot)
		Global.interaction_manager.player = get_tree().get_first_node_in_group("player")
	else:
		Global.interaction_manager.player = get_tree().get_first_node_in_group("player")