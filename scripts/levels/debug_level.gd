extends Node3D

func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		Global.game_controller.change_gui_scene("res://scenes/ui/inventory/inventory_screen.tscn")
