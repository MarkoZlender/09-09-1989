@tool
extends Node3D
@onready var world_env: WorldEnvironment = $WorldEnvironment

func _ready() -> void:
    if Engine.is_editor_hint():
        world_env.environment.volumetric_fog_enabled = false
    if not Engine.is_editor_hint():
        world_env.environment.volumetric_fog_enabled = true

