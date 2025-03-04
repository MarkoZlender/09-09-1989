class_name TestCube extends Collectible

signal collected(item: TestCube)

@export var item_data_for_cube: ItemData
@export var text: String = "Interact"

var picked_up: bool = false

@onready var interact_component: InteractComponent = $InteractComponent
@onready var body_collision: CollisionShape3D = %BodyCollision
@onready var interact_collision: CollisionShape3D = %InteractCollision
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interact_component.interact = Callable(self, "_on_interact")

func _on_interact() -> void:
	collected.emit(self)
	Global.inventory.create_and_add_item("potion")
	picked_up = true
	visible = false
	interact_collision.disabled = true
	body_collision.disabled = true
	# await dialog finished, animation finished, etc.

func save() -> Dictionary:
	var save_data: Dictionary = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : global_position.x,
		"pos_y" : global_position.y,
		"pos_z" : global_position.z,
		"rot_x" : rotation.x,
		"rot_y" : rotation.y,
		"rot_z" : rotation.z,
		"name" : item_data_for_cube.name,
		"picked_up" : picked_up
	}
	return save_data

func load(data: Dictionary) -> void:
	if data["picked_up"]:
		visible = false
		interact_collision.disabled = true
		body_collision.disabled = true
		picked_up = true
	else:
		global_position = Vector3(data["pos_x"], data["pos_y"], data["pos_z"])
		rotation = Vector3(data["rot_x"], data["rot_y"], data["rot_z"])
		item_data_for_cube = ItemData.new()
		item_data_for_cube.name = data["name"]
