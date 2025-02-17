extends Node

@export var scene_root: Node
@export var debug_mode: bool = false
@export var level_audio: LevelAudio

@onready var quest_objects: Array[Node] = get_tree().get_nodes_in_group("quest_objects")

func _ready() -> void:
	await scene_root.ready
	for quest_object: Node in quest_objects:
		if quest_object is Collectible:
			for quest: Quest in Global.quest_manager.quests:
				if quest is CollectQuest:
					quest_object.collected.connect(quest.update_collected)

	if !debug_mode:
		Global.save_manager.load_game(Global.save_manager.current_save_slot)
		Global.interaction_manager.player = get_tree().get_first_node_in_group("player")
		Global.signal_bus.level_audio_loaded.emit(level_audio)
	else:
		Global.signal_bus.level_audio_loaded.emit(level_audio)
		Global.interaction_manager.player = get_tree().get_first_node_in_group("player")
