class_name QuestManager extends Node

@export var quests: Array[Quest] = []
@onready var quest_items = get_tree().get_nodes_in_group("quest_items")

func _ready() -> void:
    Global.quest_manager = self
    for quest_item in Global.quest_manager.quest_items:
        quest_item.connect("collected", quests[0].update_collected)

func activate(quest: Quest) -> void:
    quest.quest_state = Quest.QuestState.IN_PROGRESS

func deactivate(quest: Quest) -> void:
    quest.quest_state = Quest.QuestState.NOT_STARTED

func complete(quest: Quest) -> void:
    quest.quest_state = Quest.QuestState.COMPLETED



