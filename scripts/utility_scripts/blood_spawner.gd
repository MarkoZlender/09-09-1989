extends Node

func _ready() -> void:
	# Connect the spawn_blood signal to the _spawn_blood_decal method
	Global.signal_bus.connect(Global.signal_bus.spawn_blood.get_name(), _spawn_blood_decal)

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

func _spawn_blood_decal(position: Vector3) -> void:
	var blood_decal: Decal = Decal.new()
	blood_decal.cull_mask = 1 << 0
	var blood_texture: CompressedTexture2D = load("res://assets/sprites/blood_splatter/" + _get_random_blood_texture())
	print("Blood decal spawned at position: ", position)
	if blood_texture:
		blood_decal.texture_albedo = blood_texture
		blood_decal.size = Vector3(1, 1, 1)
		blood_decal.position = position
		blood_decal.rotation = Vector3(0, randf_range(0, 2 * PI), 0)  # Random rotation around Y-axis
		get_tree().get_root().add_child(blood_decal)
