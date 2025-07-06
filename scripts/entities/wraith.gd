extends Node3D

@export var teeth_counter: int = 5
@export_file("*.dialogue") var dialogue_resource: String
@onready var interact_component: InteractComponent = $InteractComponent

func _ready() -> void:
	interact_component.interact = Callable(self, "_on_interact")

func _on_interact() -> void:
	teeth_counter = NPCGameState.teeth_counter
	var resource: Resource = load(dialogue_resource)
	DialogueManager.show_dialogue_balloon(resource, "start")
	await DialogueManager.dialogue_ended