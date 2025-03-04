extends StaticBody3D

@export_file("*.tscn") var next_scene: String = ""
@export var next_position_marker: PackedScene

@onready var interact_component: InteractComponent = $InteractComponent

func _ready() -> void:
	interact_component.interact = Callable(self, "_on_interact")

func _on_interact() -> void:
	if next_scene != "":
		Global.save_manager.save_game(Global.save_manager.current_save_slot)
		Global.game_controller.next_position_marker = next_position_marker.resource_path
		Global.game_controller.change_3d_scene(next_scene)
	else:
		printerr("No next scene set for door")
