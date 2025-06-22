class_name EnemyData extends Resource

@export_group("Movement")
@export var movement_speed: float = 0.5
@export var accel: float = 10

@export_group("Combat")
@export var level: int = 1
@export var experience: int = 10
@export var health: int = 100
@export var hit_strength: int = 10

@export_group("Animation")
@export var spriteframes: SpriteFrames

@export_group("Movement")
@export var wander_range_x: Vector2 = Vector2(-1, -1)
@export var wander_range_z: Vector2 = Vector2(1, 1)

@export_group("Audio")
@export var attack_sfx: AudioStream
@export var walk_sfx: AudioStream
@export var hurt_sfx: AudioStream
@export var death_sfx: AudioStream

@export_group("Loot")
@export var collectible_rigid_body: PackedScene
@export var collectible_rigid_body_number: int = 5

