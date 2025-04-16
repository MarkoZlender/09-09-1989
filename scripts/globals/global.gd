extends Node

const SLOT_BUTTON_SCENE: String = "res://scenes/ui/save_system/slot_button.tscn"
const MAIN_MENU_SCENE: String = "res://scenes/ui/main_menu.tscn"
const STARTING_LEVEL: String = "res://scenes/levels/test_level.tscn"
const LOADING_SCREEN: String = "res://scenes/ui/save_system/loading_screen.tscn"

@export var savable_globals: Array[Node] = []

@onready var save_manager: SaveManager
@onready var interaction_manager: InteractionManager
@onready var game_controller: GameController
@onready var signal_bus: SignalBus
@onready var utils: Utils
@onready var inventory: Inventory = $Inventory

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
