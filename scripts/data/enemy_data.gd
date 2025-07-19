class_name EnemyData extends Resource

@export_group("Movement")
@export var movement_speed: float = 0.5
@export var accel: float = 10
@export var wander_range_x: Vector2 = Vector2(-1, -1)
@export var wander_range_z: Vector2 = Vector2(1, 1)

@export_group("Combat")
@export var health: int = 100
@export var hit_strength: int = 10

@export_group("Loot")
@export var collectible_rigid_body: PackedScene
@export var collectible_rigid_body_number: int = 5

