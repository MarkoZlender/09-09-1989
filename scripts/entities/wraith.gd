extends Node3D

@export_file("*.dialogue") var dialogue_resource: String
@onready var interact_component: InteractComponent = $InteractComponent

func _ready() -> void:
	# reset singleton state
	NPCGameState.teeth_counter = 9
	NPCGameState.has_been_met = false
	interact_component.interact = Callable(self, "_on_interact")

func _on_interact() -> void:
	var resource: Resource = load(dialogue_resource)
	DialogueManager.show_dialogue_balloon(resource, "start")
	await DialogueManager.dialogue_ended