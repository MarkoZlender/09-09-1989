class_name QuestManager extends Node

@export var quests: Array[Quest] = []

func _ready() -> void:
    Global.quest_manager = self

func activate(quest: Quest) -> void:
    quest.quest_state = Quest.QuestState.IN_PROGRESS

func deactivate(quest: Quest) -> void:
    quest.quest_state = Quest.QuestState.NOT_STARTED

func complete(quest: Quest) -> void:
    quest.quest_state = Quest.QuestState.COMPLETED



