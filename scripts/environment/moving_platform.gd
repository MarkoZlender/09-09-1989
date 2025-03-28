extends AnimatableBody3D

const Directions = preload("res://scripts/data/directions.gd").Directions

@export var movement_steps: Array[PlatformMoveStep] = []

# Store the platform's starting position
var start_position: Vector3

func _ready() -> void:
	# Save the initial position of the platform
	start_position = position
	# Start the movement process
	move_platform()

func move_platform() -> void:
	var tween: Tween = create_tween().set_process_mode(0).set_loops(0).set_parallel(false)
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)  # Ensure physics-based movement

	start_position = position  # Store the initial position

	for step: PlatformMoveStep in movement_steps:
		if step is PlatformMoveStep:
			var direction: Directions = step.direction
			var distance: float = step.distance
			var duration: float = step.duration

			# Calculate target position from the last known position
			var target_position: Vector3 = start_position + get_movement_vector(direction) * distance

			# Chain tweens smoothly without a separate subtween
			tween.tween_property(self, "position", target_position, duration).set_trans(Tween.TRANS_LINEAR)

			# Update start_position for the next step
			start_position = target_position



func get_movement_vector(direction: Directions) -> Vector3:
	match direction:
		Directions.FORWARD:
			return -transform.basis.z
		Directions.BACKWARD:
			return transform.basis.z
		Directions.LEFT:
			return -transform.basis.x
		Directions.RIGHT:
			return transform.basis.x
		Directions.UP:
			return transform.basis.y
		Directions.DOWN:
			return -transform.basis.y
		_:
			return Vector3.ZERO
