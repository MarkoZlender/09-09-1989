extends Control

@onready var health_bar: ProgressBar = %HealthBar
@onready var exp_bar: ProgressBar = %ExpBar
@onready var level_label: Label = %LvlLabel
@onready var player: Player = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	await owner.ready
	health_bar.value = player.player_data.health
	_check_exp()
	level_label.text = "LVL: " + str(player.player_data.level)
	Global.signal_bus.player_hurt.connect(_on_health_changed)
	Global.signal_bus.enemy_died.connect(_on_exp_changed)

func _on_health_changed(health: int) -> void:
	health_bar.value = float(health) / float(player.player_data.max_health) * 100.0

func _on_exp_changed(_enemy: Enemy) -> void:
	_check_exp()

func _check_exp() -> void:
	var current_level: int = player.player_data.level
	var current_exp: int = player.player_data.experience

	var exp_at_current_level: int = 0
	if current_level > 1:
		exp_at_current_level = player.player_data.level_progression[current_level - 2]

	# Prevent out-of-bounds when player reaches max level
	if current_level - 1 >= player.player_data.level_progression.size():
		exp_bar.value = 100.0
		level_label.text = "LVL: " + str(current_level) + " (MAX)"
		return

	var exp_to_next_level: int = player.player_data.level_progression[current_level - 1]
	var exp_gained_this_level: int = current_exp - exp_at_current_level
	var exp_needed_this_level: int = exp_to_next_level - exp_at_current_level

	var exp_percent: float = float(exp_gained_this_level) / float(exp_needed_this_level) * 100.0

	exp_bar.value = exp_percent
	level_label.text = "LVL: " + str(current_level)
