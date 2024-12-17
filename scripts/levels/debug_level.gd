extends Node3D

@export var player_data: PlayerData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SaveManager.load_data(2)