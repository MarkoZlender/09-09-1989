extends Node

const SLOT_BUTTON_SCENE: String = "res://scenes/ui/save_system/slot_button.tscn"
const MAIN_MENU_SCENE: String = "res://scenes/ui/main_menu.tscn"
const STARTING_LEVEL: String = "res://scenes/levels/debug_level.tscn"
const LOADING_SCREEN: String = "res://scenes/ui/save_system/loading_screen.tscn"

@export var savable_globals: Array[Node] = []

@onready var save_manager: SaveManager
@onready var interaction_manager: InteractionManager
@onready var game_controller: GameController
@onready var quest_manager: QuestManager
@onready var utils: Utils
@onready var inventory: Inventory = $Inventory

func serialize() -> Dictionary:
    var save_data: Dictionary = {}
    for node: Node in savable_globals:
        save_data[node.name] = node.call("save")
    return save_data

func deserialize(save_data: Dictionary) -> void:
    for node: Node in savable_globals:
        if node.name in save_data:
            node.call("load", save_data[node.name])
