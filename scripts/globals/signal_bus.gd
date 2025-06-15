class_name SignalBus extends Node

signal player_hurt(health: int)
signal player_healed(health: int)
signal player_died
signal enemy_died(enemy: Enemy)

signal spawn_blood(position: Vector3)

signal item_collected(item: Collectible)

signal level_audio_loaded(level_audio: LevelAudio)
signal level_changed

func _ready() -> void:
    Global.signal_bus = self