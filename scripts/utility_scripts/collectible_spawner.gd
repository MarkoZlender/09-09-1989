extends Node

func _ready() -> void:
	Global.signal_bus.enemy_died.connect(_on_enemy_died)

func _on_enemy_died(enemy: Enemy) -> void:
	if enemy != owner:
		return
	for n: int in range(enemy.enemy_data.collectible_rigid_body_number):
		var collectible: CollectibleRigidBody3D = enemy.enemy_data.collectible_rigid_body.instantiate()
		get_tree().get_root().add_child(collectible)
		collectible.global_position = enemy.global_position
		collectible.apply_central_impulse(Vector3(randf_range(-0.2, 0.2), 0.2, randf_range(-0.2, 0.2)) * 10)
