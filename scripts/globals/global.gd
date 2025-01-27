extends Node

const SLOT_BUTTON_SCENE: String = "res://scenes/ui/save_system/slot_button.tscn"
const MAIN_MENU_SCENE: String = "res://scenes/ui/main_menu.tscn"
const STARTING_LEVEL: String = "res://scenes/levels/debug_level.tscn"
const LOADING_SCREEN: String = "res://scenes/ui/save_system/loading_screen.tscn"

@onready var save_manager: SaveManager
@onready var interaction_manager: InteractionManager
@onready var game_controller: GameController
@onready var quest_manager: QuestManager
@onready var utils: Utils
@onready var inventory: Inventory = $Inventory

func _ready() -> void:
    var dict: Dictionary = inventory.serialize()
    var json: String = JSON.stringify(dict, "\t")
    print(json)
