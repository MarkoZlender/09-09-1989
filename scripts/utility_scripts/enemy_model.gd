extends Node3D

@onready var current_state: EnemyState.State = EnemyState.State.DEAGGROED
@onready var velocity: Vector3 = Vector3.ZERO
@onready var attack_finished: bool = true

func _physics_process(_delta: float) -> void:
	current_state = owner.current_state
	velocity = owner.velocity
	attack_finished = owner.attack_finished