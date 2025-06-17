extends Node3D

@onready var is_deaggroed: bool = true
@onready var is_aggroed: bool = false
@onready var is_moving: bool = false
@onready var is_hurt: bool = false
@onready var is_dead: bool = false
@onready var reached_player: bool = false

func _physics_process(_delta: float) -> void:
    is_deaggroed = owner.is_deaggroed
    is_aggroed = owner.is_aggroed
    is_moving = owner.is_moving
    is_hurt = owner.is_hurt
    is_dead = owner.is_dead
    reached_player = owner.reached_player
