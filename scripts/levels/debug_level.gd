extends Node3D

func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		if !Global.game_controller.gui.has_node("InventoryScreen"):
			Global.game_controller.change_gui_scene("res://scenes/ui/inventory/inventory_screen.tscn")
		elif Global.game_controller.gui.has_node("InventoryScreen"):
			Global.game_controller.change_gui_scene("")		
