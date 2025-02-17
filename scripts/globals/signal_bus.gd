class_name SignalBus extends Node

signal player_moved(position: Vector3)
signal level_audio_loaded(level_audio: LevelAudio)

func _ready() -> void:
    Global.signal_bus = self