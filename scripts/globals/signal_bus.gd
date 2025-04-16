class_name SignalBus extends Node

signal player_moved(position: Vector3)
signal player_hurt
signal enemy_died(enemy: Enemy)

signal level_audio_loaded(level_audio: LevelAudio)
signal level_changed

func _ready() -> void:
    Global.signal_bus = self