extends Node3D

@onready var velocity: Vector3 = Vector3.ZERO
@onready var attack_state: bool = false
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		animation_player.get_animation("attack").loop_mode = Animation.LOOP_LINEAR
		attack_state = true

	elif event.is_action_released("attack"):
		animation_player.get_animation("attack").loop_mode = Animation.LOOP_NONE
		attack_state = false

func _physics_process(_delta: float) -> void:
	velocity = owner.velocity
