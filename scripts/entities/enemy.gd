extends CharacterBody3D

@export var movement_speed: float = 0.8
@export var accel: float = 10
@export var player: Player
@onready var navigation_agent: NavigationAgent3D = get_node("NavigationAgent3D")

func _physics_process(delta: float) -> void:
	var direction: Vector3 = Vector3.ZERO

	navigation_agent.target_position = player.global_position

	direction = navigation_agent.get_next_path_position() - global_position
	direction = direction.normalized()

	velocity = velocity.move_toward(direction * movement_speed, accel * delta)
	move_and_slide()
