extends Node3D

@export var item_data_for_cube: ItemData
@export var text: String = "Interact"
@export var cube_name: String
@onready var interact_component: InteractComponent = $InteractComponent
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interact_component.interact = Callable(self, "_on_interact")

func _on_interact() -> void:
	print(text)
	# await dialog finished, animation finished, etc.

func save() -> Dictionary:
	var save_data = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x,
		"pos_y" : position.y,
		"pos_z" : position.z,
		"rot_x" : rotation.x,
		"rot_y" : rotation.y,
		"rot_z" : rotation.z,
		"name" : cube_name,
	}
	return save_data