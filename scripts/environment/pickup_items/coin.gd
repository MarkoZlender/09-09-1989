extends Collectible

var picked_up: bool = false

@onready var interact_collision: CollisionShape3D = %InteractionCollision
@onready var audio_player: AudioStreamPlayer3D = $AudioPlayer	

func _on_interaction_area_body_entered(body:Node3D) -> void:
	if body is Player:
		Global.signal_bus.item_collected.emit(self)
		audio_player.play()
		picked_up = true
		visible = false
		interact_collision.disabled = true


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
		#body_collision.disabled = true
		picked_up = true
	else:
		global_position = Vector3(data["pos_x"], data["pos_y"], data["pos_z"])
		rotation = Vector3(data["rot_x"], data["rot_y"], data["rot_z"])
		#item_data_for_cube = ItemData.new()
		#item_data_for_cube.name = data["name"]
