extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
    Global.signal_bus.play_news.connect(_on_play_news)

func _on_play_news() -> void:
    animation_player.play("news")