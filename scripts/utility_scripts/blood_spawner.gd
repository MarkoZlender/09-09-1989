extends Node

const BLOOD_TEXTURES: Array = [
	preload("res://assets/sprites/blood_splatter/tile000.png"),
	preload("res://assets/sprites/blood_splatter/tile001.png"),
	preload("res://assets/sprites/blood_splatter/tile002.png"),
	preload("res://assets/sprites/blood_splatter/tile003.png"),
	preload("res://assets/sprites/blood_splatter/tile004.png"),
	preload("res://assets/sprites/blood_splatter/tile005.png"),
	preload("res://assets/sprites/blood_splatter/tile006.png"),
	preload("res://assets/sprites/blood_splatter/tile007.png"),
	preload("res://assets/sprites/blood_splatter/tile008.png"),
	preload("res://assets/sprites/blood_splatter/tile009.png"),
	preload("res://assets/sprites/blood_splatter/tile010.png"),
	preload("res://assets/sprites/blood_splatter/tile011.png"),
	preload("res://assets/sprites/blood_splatter/tile012.png"),
	preload("res://assets/sprites/blood_splatter/tile013.png"),
	preload("res://assets/sprites/blood_splatter/tile014.png"),
	preload("res://assets/sprites/blood_splatter/tile015.png"),
	preload("res://assets/sprites/blood_splatter/tile016.png"),
	preload("res://assets/sprites/blood_splatter/tile017.png"),
	preload("res://assets/sprites/blood_splatter/tile018.png"),
	preload("res://assets/sprites/blood_splatter/tile019.png"),
	preload("res://assets/sprites/blood_splatter/tile020.png"),
	preload("res://assets/sprites/blood_splatter/tile021.png"),
	preload("res://assets/sprites/blood_splatter/tile022.png"),
	preload("res://assets/sprites/blood_splatter/tile023.png"),
	preload("res://assets/sprites/blood_splatter/tile024.png"),
	preload("res://assets/sprites/blood_splatter/tile025.png"),
	preload("res://assets/sprites/blood_splatter/tile026.png"),
	preload("res://assets/sprites/blood_splatter/tile027.png"),
	preload("res://assets/sprites/blood_splatter/tile028.png"),
	preload("res://assets/sprites/blood_splatter/tile029.png"),
	preload("res://assets/sprites/blood_splatter/tile030.png"),
	preload("res://assets/sprites/blood_splatter/tile031.png"),
	preload("res://assets/sprites/blood_splatter/tile032.png"),
	preload("res://assets/sprites/blood_splatter/tile033.png"),
	preload("res://assets/sprites/blood_splatter/tile034.png"),
	preload("res://assets/sprites/blood_splatter/tile035.png"),
	preload("res://assets/sprites/blood_splatter/tile036.png"),
	preload("res://assets/sprites/blood_splatter/tile037.png"),
	preload("res://assets/sprites/blood_splatter/tile038.png"),
]

func _ready() -> void:
	Global.signal_bus.connect(Global.signal_bus.spawn_blood.get_name(), _on_spawn_blood_decal)

func _get_random_blood_texture() -> Texture2D:
	if BLOOD_TEXTURES.size() == 0:
		push_error("No blood textures defined.")
		return null
	var random_index: int = randi() % BLOOD_TEXTURES.size()
	return BLOOD_TEXTURES[random_index]

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
	query.collision_mask = 1  # adjust to match ground

	var result: Dictionary = space_state.intersect_ray(query)

	if result:
		var blood_decal: Decal = Decal.new()
		blood_decal.cull_mask = 1 << 0
		
		var blood_texture: CompressedTexture2D = _get_random_blood_texture()
		if blood_texture:
			blood_decal.texture_albedo = blood_texture
			blood_decal.size = Vector3(1, 1, 1)
			blood_decal.position = result.position + result.normal * 0.01  # prevent z fighting

			var normal: Vector3 = result.normal.normalized()
			var random_rotation: Basis = Basis(normal, randf_range(0, 2 * PI))
			blood_decal.basis = random_rotation

			get_tree().get_root().add_child(blood_decal)
