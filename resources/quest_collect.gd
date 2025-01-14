class_name CollectQuest extends Quest

@export var quantity_to_collect: int = 1

var collected: int = 0

func _ready() -> void:
    print("CollectQuest _ready")
    print("quantity_to_collect: ", quantity_to_collect)

func update_collected() -> void:
    print("update_collected")
    if quest_state != QuestState.IN_PROGRESS:
        return
    collected += 1
    print("Collected: ", collected)
    if collected >= quantity_to_collect:
        Global.quest_manager.complete(self)
        collected = 0

