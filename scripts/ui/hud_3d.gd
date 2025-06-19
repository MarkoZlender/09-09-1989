extends Control

@onready var health_bar: ProgressBar = %HealthBar
@onready var player: Player = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	await owner.ready
	health_bar.value = player.player_data.health
	Global.signal_bus.player_hurt.connect(_on_health_changed)
	Global.signal_bus.player_healed.connect(_on_health_changed)

func _on_health_changed(health: int) -> void:
	health_bar.value = float(health) / float(player.player_data.max_health) * 100.0