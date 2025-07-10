class_name PlayerData
extends Resource

@export_group("Movement")
@export var speed: float = 1.5

@export_group("Combat")
@export var health: int = 100
@export var max_health: int = 100
@export var hit_strength: int = 10

@export_group("Resources")
@export var teeth: int = 0

@export_group("Audio")
@export var walk_sfx: AudioStream
@export var jump_sfx: AudioStream
@export var footstep_timer: float = 0.2
