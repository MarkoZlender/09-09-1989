extends Node

@onready var save_manager: SaveManager
@onready var interaction_manager: InteractionManager
@onready var game_controller: GameController
@onready var quest_manager: QuestManager
@onready var utils: Utils
@onready var inventory: Inventory = $Inventory

func _ready() -> void:
	inventory.create_and_add_item("sword")
	inventory.create_and_add_item("potion")
	
	print(inventory.get_item_with_prototype_id("potion").get_property("health"))
