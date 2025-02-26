extends Node3D
const _save_point_slot_selection_scene: String = "res://scenes/ui/save_system/slot_selection.tscn"
@onready var interact_component: InteractComponent = $InteractComponent


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interact_component.interact = Callable(self, "_on_interact")


func _on_interact() -> void:
	Global.game_controller.change_gui_scene(_save_point_slot_selection_scene)
	get_tree().paused = true
