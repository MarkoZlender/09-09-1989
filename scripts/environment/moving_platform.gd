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
	var subtween: Tween = create_tween()
	for step: PlatformMoveStep in movement_steps:
		if step is PlatformMoveStep:
			var direction: Directions = step.direction
			var distance: float = step.distance
			var duration: float = step.duration

			# Calculate the target position based on the starting position
			var target_position: Vector3 = start_position + get_movement_vector(direction) * distance

			# Create a tween to move the platform to the target position
			
			subtween.tween_property(self, "position", target_position, duration)
			

			# Update the starting position for the next step
			start_position = target_position
	
	var tween = create_tween()
	tween.set_loops()
	tween.tween_subtween(subtween)

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
	return Vector3.ZERO
