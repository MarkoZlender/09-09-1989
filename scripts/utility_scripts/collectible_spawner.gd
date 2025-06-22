extends Node

func _ready() -> void:
	Global.signal_bus.enemy_died.connect(_on_enemy_died)

func _on_enemy_died(enemy: Enemy) -> void:
	for n: int in enemy.enemy_data.collectible_rigid_body_number:
		var collectible: CollectibleRigidBody3D = enemy.enemy_data.collectible_rigid_body.instantiate()
		get_tree().current_scene.add_child(collectible)
		collectible.global_position = enemy.global_position
		# apply force to each collectible so that they are thrown away from the enemy in circle
		collectible.apply_central_impulse(Vector3(randf_range(-0.2, 0.2), 0.2, randf_range(-0.2, 0.2)) * 10)    
