extends Node3D

@onready var interact_component: InteractComponent = $InteractComponent

func _ready() -> void:
	interact_component.interact = Callable(self, "_on_interact")

func _on_interact() -> void:
	var resource: Resource = load("res://assets/dialogue/test_npc_dialogue.dialogue")
	#DialogueManager.show_example_dialogue_balloon(resource)
	DialogueManager.show_dialogue_balloon(resource, "start")
	await DialogueManager.dialogue_ended
