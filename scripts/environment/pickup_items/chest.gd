class_name Chest extends Node3D

var picked_up: bool = false

@onready var interact_component: InteractComponent = $InteractComponent
@onready var body_collision: CollisionShape3D = %BodyCollision
@onready var interact_collision: CollisionShape3D = %InteractCollision
@onready var audio_player: AudioStreamPlayer3D = $AudioPlayer
@onready var sprite: Sprite3D = $Sprite

func _ready() -> void:
	interact_component.interact = Callable(self, "_on_interact")

func _on_interact() -> void:
	Global.inventory.create_and_add_item("potion")
	audio_player.play()
	picked_up = true
	interact_collision.disabled = true
	sprite.texture = preload("res://assets/sprites/pickup_items/Chest_2.png")

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
		#"name" : item_data_for_cube.name,
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
		#item_data_for_cube = ItemData.new()
		#item_data_for_cube.name = data["name"]
