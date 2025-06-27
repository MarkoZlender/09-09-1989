extends Node

func _ready() -> void:
	# Connect the spawn_blood signal to the _spawn_blood_decal method
	Global.signal_bus.connect(Global.signal_bus.spawn_blood.get_name(), _on_spawn_blood_decal)

func _get_random_blood_texture() -> String:
	var files: PackedStringArray = DirAccess.get_files_at("res://assets/sprites/blood_splatter/")
	var blood_textures: PackedStringArray = PackedStringArray()
	for file: String in files:
		if file.ends_with(".png"):
			blood_textures.append(file)
	if blood_textures.size() == 0:
		push_error("No blood textures found in the specified directory.")
		return ""
	var random_index: int = randi() % blood_textures.size()
	return blood_textures[random_index]

# func _on_spawn_blood_decal(position: Vector3) -> void:
# 	if owner.is_hurt:
# 		return
# 	else:
# 		var blood_decal: Decal = Decal.new()
# 		blood_decal.cull_mask = 1 << 0
# 		var blood_texture: CompressedTexture2D = load("res://assets/sprites/blood_splatter/" + _get_random_blood_texture())
# 		if blood_texture:
# 			blood_decal.texture_albedo = blood_texture
# 			blood_decal.size = Vector3(1, 1, 1)
# 			blood_decal.position = position
# 			blood_decal.rotation = Vector3(owner.rotation.x, randf_range(0, 2 * PI), owner.rotation.z)  # random rotation around Y-axis
# 			get_tree().get_root().add_child(blood_decal)

func _on_spawn_blood_decal(position: Vector3) -> void:
	if owner is Enemy:
		if owner.current_state == EnemyState.State.HURT:
			return
	if owner is Player:
		if owner.current_state == PlayerState.State.HURT:
			return
	
	var space_state: PhysicsDirectSpaceState3D = owner.get_world_3d().direct_space_state

	var ray_origin: Vector3 = position + Vector3.UP * 1.0
	var ray_end: Vector3 = position + Vector3.DOWN * 2.0

	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.collision_mask = 1  # Adjust to match ground

	var result: Dictionary = space_state.intersect_ray(query)

	if result:
		var blood_decal: Decal = Decal.new()
		blood_decal.cull_mask = 1 << 0
		
		var blood_texture: CompressedTexture2D = load("res://assets/sprites/blood_splatter/" + _get_random_blood_texture())
		if blood_texture:
			blood_decal.texture_albedo = blood_texture
			blood_decal.size = Vector3(1, 1, 1)
			blood_decal.position = result.position + result.normal * 0.01  # slight offset to prevent z-fighting

			var normal: Vector3 = result.normal.normalized()
			var random_rotation: Basis = Basis(normal, randf_range(0, 2 * PI))
			blood_decal.basis = random_rotation

			get_tree().get_root().add_child(blood_decal)
