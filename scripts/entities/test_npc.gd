extends StaticBody3D

@onready var interact_component: InteractComponent = $InteractComponent

func _ready() -> void:
	interact_component.interact = Callable(self, "_on_interact")

func _on_interact() -> void:
	print("Interacted with NPC")
	var resource: Resource = load("res://assets/dialogue/test_npc_dialogue.dialogue")
	DialogueManager.show_example_dialogue_balloon(resource)
	await DialogueManager.dialogue_ended

