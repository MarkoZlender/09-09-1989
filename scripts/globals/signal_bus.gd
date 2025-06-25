class_name SignalBus extends Node

signal player_hurt(health: int)
signal player_healed(health: int)
signal player_died
signal enemy_died(enemy: Enemy)
signal player_interacting(state: bool)

signal spawn_blood(position: Vector3)

signal item_collected(item: Collectible)
signal item_rigid_body_collected(item: CollectibleRigidBody3D)

signal interaction_started
signal interaction_ended

signal level_audio_loaded(level_audio: LevelAudio)
signal level_changed

func _ready() -> void:
    Global.signal_bus = self