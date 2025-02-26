extends StaticBody3D

@export_file("*.tscn") var next_scene: String = ""

@onready var interact_component: InteractComponent = $InteractComponent

func _ready() -> void:
	interact_component.interact = Callable(self, "_on_interact")

func _on_interact() -> void:
	if next_scene != "":
		Global.game_controller.change_3d_scene(next_scene)
	else:
		printerr("No next scene set for door")
