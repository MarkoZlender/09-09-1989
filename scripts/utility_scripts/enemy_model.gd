extends Node3D

@onready var is_deaggroed: bool = true
@onready var is_aggroed: bool = false
@onready var is_moving: bool = false
@onready var is_hurt: bool = false
@onready var is_dead: bool = false
@onready var target_reached: bool = false
@onready var player_detected: bool = false
@onready var player_in_range: bool = false
@onready var is_attacking: bool = false
@onready var attack_finished: bool = false

func _physics_process(_delta: float) -> void:
	is_deaggroed = owner.is_deaggroed
	is_aggroed = owner.is_aggroed
	is_moving = owner.is_moving
	is_hurt = owner.is_hurt
	is_dead = owner.is_dead
	target_reached = owner.target_reached
	player_detected = owner.player_detected
	player_in_range = owner.player_in_range
	is_attacking = owner.is_attacking
	attack_finished = owner.attack_finished