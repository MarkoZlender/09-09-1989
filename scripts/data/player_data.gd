class_name PlayerData
extends Resource

@export_group("Movement")
@export var speed: float = 1.5
@export var rotation_controls: bool = true

@export_group("Combat")
@export var level: int = 1
@export var level_progression: Array[int]
@export var experience: int = 10
@export var health: int = 100
@export var max_health: int = 100
@export var hit_strength: int = 10

@export_group("Audio")
@export var walk_sfx: AudioStream
@export var jump_sfx: AudioStream
