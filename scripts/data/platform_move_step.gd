class_name PlatformMoveStep
extends Resource

const Directions = preload("res://scripts/data/directions.gd").Directions

@export var direction: Directions
@export var distance: float = 0.0
@export var duration: float = 1.0
