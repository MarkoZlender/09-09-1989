class_name Enemy extends CharacterBody3D

@export var movement_speed: float = 0.5
@export var accel: float = 10
@export var player: Player

var idle: bool
var is_moving: bool = false
var is_jumping: bool = false

var hurt:bool = false
var direction: Vector3 = Vector3.ZERO

var target_rotation: float = 0.0
var time_since_last_rotation: float = 0.0
var rotation_delay: float = 1.0

var knockback_direction: Vector3 = Vector3.ZERO
var knockback_strength: float = 3.0  # Adjust the force as needed
var knockback_duration: float = 0.1  # How long the knockback lasts
var knockback_timer: float = 0.0

var wait_timer: float = 0.0
var wait_duration: float = 1.5

var camera_velocity: Vector3 = Vector3.ZERO

var last_facing_direction: Vector2 = Vector2(0, -1)

var stun_duration: float = 0.5  # Time in seconds where enemy is stunned after knockback
var stun_timer: float = 0.0  # Timer to track stun time


@onready var navigation_agent: NavigationAgent3D = get_node("NavigationAgent3D")
@onready var enemy_collision_shape: CollisionShape3D = $EnemyCollisionShape
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var camera_gimbal: Node3D = get_tree().get_first_node_in_group("player").camera_gimbal

func _ready() -> void:
	$FrontHurtSurfaceArea.connect("area_entered", _on_hurt)
	$FrontHurtSurfaceArea.connect("area_exited", _on_disengage)

func aggroed(delta: float) -> void:
	camera_velocity = camera_gimbal.global_transform.basis.inverse() * velocity
	time_since_last_rotation += delta

	# Apply knockback while timer is active
	if knockback_timer > 0:
		knockback_timer -= delta
		velocity = knockback_direction * knockback_strength
		navigation_agent.target_position = global_position  # Stop pathfinding
	else:
		knockback_timer = 0  # Knockback ends

	# Apply stun after knockback ends
	if knockback_timer <= 0:
		if stun_timer > 0:
			stun_timer -= delta  # Reduce stun timer
			hurt = true  # Keep enemy stunned
			velocity = Vector3.ZERO  # Prevent movement
			print("Enemy Stunned and hurt")
			navigation_agent.set_velocity_forced(Vector3.ZERO)
			navigation_agent.target_position = global_position  # Stop navigation
			return  # Stop further processing
		else:
			hurt = false  # Allow movement again

	# Enemy moves normally if not stunned or knocked back
	if not hurt:
		navigation_agent.target_position = player.global_position  # Update pathfinding
		direction = navigation_agent.get_next_path_position() - global_position
		direction = direction.normalized()
		_rotate()
		velocity = velocity.move_toward(direction * movement_speed, accel * delta)

	if velocity.length() > 0.1:
		is_moving = true
	else:
		is_moving = false
	
	if not is_on_floor():
		is_jumping = true
	else:
		is_jumping = false

	move_and_slide()
	animate_input_animation_tree()

func deaggroed(delta: float) -> void:
	# If the enemy is hurt or stunned, do nothing
	camera_velocity = camera_gimbal.global_transform.basis.inverse() * velocity
	time_since_last_rotation += delta
	if hurt or knockback_timer > 0 or stun_timer > 0:
		return
	
	# If no target position is set or the enemy has reached the target, start waiting
	if navigation_agent.is_navigation_finished():
		if wait_timer <= 0:  
			wait_timer = wait_duration  # Start wait timer
		else:
			wait_timer -= delta  # Decrease timer each frame
			if wait_timer > 0:
				velocity = Vector3.ZERO  # Stop movement while waiting
				is_moving = false  # Set idle animation
				animate_input_animation_tree()
				return  # Exit function to stay idle

		# After waiting, pick a new target
		if wait_timer <= 0:
			var random_offset = Vector3(
				randf_range(-3, 3),  # Increased range for more movement variety
				0,
				randf_range(-3, 3)
			)
			navigation_agent.target_position = global_position + random_offset
			wait_timer = 0  # Reset timer to allow movement

	# Move towards the target position
	direction = navigation_agent.get_next_path_position() - global_position
	direction = direction.normalized()
	_rotate()
	velocity = velocity.move_toward(direction * movement_speed, accel * delta)

	# Check if the enemy is moving or idle
	is_moving = velocity.length() > 0.1

	# Handle jumping state
	is_jumping = not is_on_floor()

	# Apply movement
	move_and_slide()
	animate_input_animation_tree()




func _rotate() -> void:
	if direction.length() > 0.01 and time_since_last_rotation >= rotation_delay:
		time_since_last_rotation = 0.0  # Reset timer

		# Define the 4 possible directions
		var directions = [
			Vector3(1, 0, 0),   # Right (+X)
			Vector3(-1, 0, 0),  # Left (-X)
			Vector3(0, 0, -1),  # Forward (-Z)
			Vector3(0, 0, 1)    # Backward (+Z)
		]

		# Find the closest direction
		var closest_direction = directions[0]
		var closest_dot = -1  # Minimum possible dot product
		for dir in directions:
			var dot = direction.dot(dir)
			if dot > closest_dot:
				closest_dot = dot
				closest_direction = dir

		# Snap to the closest direction
		rotation.y = atan2(-closest_direction.x, -closest_direction.z)

func _on_hurt(area: Area3D) -> void:
	if area is PlayerAttackSurfaceArea:
		hurt = true
		knockback_timer = knockback_duration  # Knockback duration
		stun_timer = stun_duration  # Stun duration (starts after knockback)

		# Calculate the direction of the knockback based on the attacker's position
		var relative_position = (area.global_position - global_position).normalized()

		# Define the 4 possible directions
		var directions = [
			Vector3(0, 0, -1),  # Forward (-Z)
			Vector3(0, 0, 1),   # Backward (+Z)
			Vector3(-1, 0, 0),  # Left (-X)
			Vector3(1, 0, 0)    # Right (+X)
		]

		# Find the closest direction
		var closest_direction = directions[0]
		var closest_dot = -1  # Minimum possible dot product
		for dir in directions:
			var dot = relative_position.dot(dir)
			if dot > closest_dot:
				closest_dot = dot
				closest_direction = dir

		# Set the knockback direction to the closest direction
		knockback_direction = closest_direction * -1  # Knockback is in the opposite direction

func _on_disengage(area: Area3D) -> void:
	if area is PlayerAttackSurfaceArea:
		print("Disengaging")
		hurt = false


func _on_navigation_agent_3d_velocity_computed(safe_velocity:Vector3) -> void:
	velocity = velocity.move_toward(safe_velocity, accel * get_process_delta_time())
	move_and_slide()

func animate_input_animation_tree() -> void:
	# Determine if the enemy is idle (no movement input)
	idle = camera_velocity.length() < 0.1  # Threshold to consider the enemy idle

	# Normalize the velocity for blending
	var blend_position: Vector2 = Vector2(camera_velocity.x, camera_velocity.z).normalized()

	# Ensure last_facing_direction doesn't reset to zero
	if blend_position.length() > 0.1:  # Only update when there's movement
		last_facing_direction = blend_position

	# If still (0,0), ensure a fallback direction (e.g., idle forward)
	if last_facing_direction == Vector2.ZERO:
		last_facing_direction = Vector2(0, -1)  # Default to facing forward

	# Handle jump animations
	if is_jumping:
		animation_tree.set("parameters/Jump/blend_position", last_facing_direction)
		animation_tree.set("parameters/State/current", 2)  # Jump state

	elif idle:
		# Idle animations
		animation_tree.set("parameters/Idle/blend_position", last_facing_direction)
		animation_tree.set("parameters/State/current", 0)  # Idle state

	else:
		# Run animations
		animation_tree.set("parameters/Run/blend_position", blend_position)
		animation_tree.set("parameters/State/current", 1)  # Run state
