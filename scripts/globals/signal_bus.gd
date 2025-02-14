class_name SignalBus extends Node

signal player_moved(position: Vector3)

func _ready() -> void:
    Global.signal_bus = self