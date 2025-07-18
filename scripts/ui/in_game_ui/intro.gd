extends Control

func _ready() -> void:
	await Global.wait(2)
	var resource: Resource = load("res://assets/dialogue/intro.dialogue")
	DialogueManager.show_dialogue_balloon(resource, "start")
	await DialogueManager.dialogue_ended
	Global.game_controller.change_3d_scene(Global.STARTING_LEVEL)
