class_name CollectQuest extends Quest

@export var quantity_to_collect: int = 1
@export var collectible_type: PackedScene
    

var collected: int = 0

func update_collected(collectible: Collectible) -> void:
    print("update_collected")
    if quest_state != QuestState.IN_PROGRESS:
        return
    var instance = collectible_type.instantiate()
    if !collectible.name.contains(instance.name):
        print(instance.name + " != " + collectible.name)
        print("Not the right collectible")
        return
    collected += 1
    print("instance name: ", instance.name + " == " + collectible.name)
    print("Collected: ", collected)
    if collected >= quantity_to_collect:
        Global.quest_manager.complete(self)
        collected = 0

