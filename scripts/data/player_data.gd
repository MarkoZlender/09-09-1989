class_name PlayerData
extends Resource

@export var map_position: Vector3 = Vector3.ZERO
@export_range(0, 100) var health: int = clamp(100, 0, 100)
@export_range(0, 50) var mana: int = clamp(50, 0, 50)