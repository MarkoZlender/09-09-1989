extends Node

const MAIN_MENU_SCENE: String = "res://scenes/ui/main_menu.tscn"
const CONFIG_SCENE: String = "res://scenes/ui/config_screen.tscn"
const STARTING_LEVEL: String = "res://scenes/levels/horror/open_space.tscn"
const LOADING_SCREEN: String = "res://scenes/ui/save_system/loading_screen.tscn"
const GAME_OVER_SCENE: String = "res://scenes/ui/game_over_screen.tscn"
const ENDING_SCENE: String = "res://scenes/ui/ending_scene.tscn"
const INTRO_SCENE: String = "res://scenes/ui/intro.tscn"
const CONTROLS_SCENE: String = "res://scenes/ui/control_scheme.tscn"

@export var savable_globals: Array[Node] = []

@onready var save_manager: SaveManager
@onready var interaction_manager: InteractionManager
@onready var game_controller: GameController
@onready var signal_bus: SignalBus
@onready var audio_player: AudioStreamPlayer = $AudioPlayer

func serialize() -> Dictionary:
	var save_data: Dictionary = {}
	if !save_data.size() == 0:
		for node: Node in savable_globals:
			if node != null && node.has_method("save"):
				save_data[node.name] = node.call("save")
			else:
				printerr("Node is null: ", node)
		return save_data
	else:
		printerr("No savable globals found.")
		return {}

func deserialize(save_data: Dictionary) -> void:
	for node: Node in savable_globals:
		if node.name in save_data:
			node.call("load", save_data[node.name])

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
