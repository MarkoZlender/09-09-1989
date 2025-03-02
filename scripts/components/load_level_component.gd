extends Node

@export var scene_root: Node
@export var debug_mode: bool = false
@export var level_audio: LevelAudio

func _ready() -> void:
	await scene_root.ready

	if !debug_mode:
		if Global.save_manager.fresh_load:
			Global.save_manager.load_game(Global.save_manager.current_save_slot, true)
			Global.save_manager.fresh_load = false
		else:
			Global.save_manager.load_game(Global.save_manager.current_save_slot, false)
			for node in get_tree().get_nodes_in_group("exits"):
				for marker in node.get_children():
					print("Marker: ", marker.get_scene_file_path(),"\nGlobal next_position_marker: " ,Global.game_controller.next_position_marker)
					if marker.get_scene_file_path() == Global.game_controller.next_position_marker:
						%Player.global_position = marker.global_position
						break
		Global.interaction_manager.player = get_tree().get_first_node_in_group("player")
		Global.signal_bus.level_audio_loaded.emit(level_audio)
	else:
		Global.signal_bus.level_audio_loaded.emit(level_audio)
		Global.interaction_manager.player = get_tree().get_first_node_in_group("player")
