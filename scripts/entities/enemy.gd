class_name Enemy extends CharacterBody3D

@export var movement_speed: float = 0.5
@export var accel: float = 10
@export var player: Player

var idle: bool
var is_moving: bool = false
var is_jumping: bool = false

var hurt: bool = false
var stunned: bool = false
var direction: Vector3 = Vector3.ZERO

var knockback_direction: Vector3 = Vector3.ZERO
var knockback_strength: float = 2.0
var knockback_duration: float = 0.2
var knockback_timer: float = 0.0

var stun_duration: float = 0.1
var stun_timer: float = 0.0  

var camera_velocity: Vector3 = Vector3.ZERO
var last_facing_direction: Vector2

var last_animation: StringName

var time_since_last_rotation: float = 0.0  # Tracks time since the last rotation
var rotation_delay: float = 0.2  # Delay before allowing another rotation (adjust as needed)


@onready var navigation_agent: NavigationAgent3D = get_node("NavigationAgent3D")
@onready var enemy_collision_shape: CollisionShape3D = $EnemyCollisionShape
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var camera_gimbal: Node3D = get_tree().get_first_node_in_group("player").camera_gimbal  
@onready var animated_sprite: AnimatedSprite3D = $Animation
func _ready() -> void:
	$FrontHurtSurfaceArea.connect("area_entered", _on_hurt)
	$FrontHurtSurfaceArea.connect("area_exited", _on_disengage)

### **Apply Knockback and Stun Logic**
func apply_stun_and_knockback(delta: float) -> void:
	time_since_last_rotation += delta
	if knockback_timer > 0:
		knockback_timer -= delta
		velocity = knockback_direction * knockback_strength
		move_and_slide()
		navigation_agent.set_velocity_forced(Vector3.ZERO)
		print("Enemy is being knocked back!")
		return  

	if stun_timer > 0:
		stun_timer -= delta
		stunned = true
		hurt = true
		velocity = Vector3.ZERO
		move_and_slide()
		navigation_agent.set_velocity_forced(Vector3.ZERO)
		navigation_agent.target_position = global_position

		print("Enemy is stunned!")
	else:
		stunned = false
		hurt = false
		animation_tree.active = true
		animation_tree.set_process_callback(2)
		await get_tree().create_timer(0.1).timeout
		animation_tree.set_process_callback(1)

### **Aggroed State (Chasing Player)**
func aggroed(delta: float) -> void:
	time_since_last_rotation += delta
	camera_velocity = camera_gimbal.global_transform.basis.inverse() * velocity

	apply_stun_and_knockback(delta)
	if knockback_timer > 0 or stunned:
		return  

	navigation_agent.target_position = player.global_position
	direction = (navigation_agent.get_next_path_position() - global_position).normalized()
	_rotate()
	velocity = velocity.move_toward(direction * movement_speed, accel * delta)

	is_moving = velocity.length() > 0.1
	is_jumping = not is_on_floor()

	move_and_slide()
	animate_input_animation_tree()

### **Deaggroed State (Wandering Randomly)**
func deaggroed(delta: float) -> void:
	time_since_last_rotation += delta
	camera_velocity = camera_gimbal.global_transform.basis.inverse() * velocity

	apply_stun_and_knockback(delta)
	if knockback_timer > 0 or stunned:
		return  

	# If no target or reached the target, pick a new random location
	if navigation_agent.is_navigation_finished():
		var random_offset = Vector3(randf_range(-3, 3), 0, randf_range(-3, 3))
		navigation_agent.target_position = global_position + random_offset

	# Move towards the new target
	direction = navigation_agent.get_next_path_position() - global_position
	direction = direction.normalized()
	_rotate()
	velocity = velocity.move_toward(direction * movement_speed, accel * delta)

	is_moving = velocity.length() > 0.1
	is_jumping = not is_on_floor()

	move_and_slide()
	animate_input_animation_tree()

### **Handles Getting Hurt and Knocked Back**
func _on_hurt(area: Area3D) -> void:
	if area is PlayerAttackSurfaceArea:
		last_animation = animated_sprite.animation
		animated_sprite.stop()
		animation_tree.active = false
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

### **Handles Stun End**
func _on_disengage(area: Area3D) -> void:
	if area is PlayerAttackSurfaceArea:
		#animated_sprite.play(last_animation)
		#animation_tree.active = true
		print("Disengaging")
		hurt = false

### **Enemy Rotation Logic**
func _rotate() -> void:
	if direction.length() > 0.01 and time_since_last_rotation >= rotation_delay:
		time_since_last_rotation = 0.0  # Reset timer

		# Define the 4 possible locked directions (Right, Left, Forward, Backward)
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

		# Set rotation to snap to the closest locked direction
		rotation.y = atan2(-closest_direction.x, -closest_direction.z)


### **Handles Animation State Switching**
func animate_input_animation_tree() -> void:
	# if stunned:
	# 	animation_tree.active = false
	# 	last_animation = $Animation.animation
	# 	$Animation.stop()
	# 	return
	# else:
	# 	#animation_tree.active = true
	# 	pass
	# 	#last_animation = $Animation.animation

	idle = camera_velocity.length() < 0.1
	var blend_position: Vector2 = Vector2(camera_velocity.x, camera_velocity.z).normalized()
	if blend_position.length() > 0.1:
		last_facing_direction = blend_position
	if last_facing_direction == Vector2.ZERO:
		last_facing_direction = Vector2(0, -1)
	if is_jumping:
		animation_tree.set("parameters/AnimationNodeStateMachine/Jump/blend_position", last_facing_direction)
		animation_tree.set("parameters/AnimationNodeStateMachine/State/current", 2)
	elif idle:
		animation_tree.set("parameters/AnimationNodeStateMachine/Idle/blend_position", last_facing_direction)
		animation_tree.set("parameters/AnimationNodeStateMachine/State/current", 0)
	else:
		animation_tree.set("parameters/AnimationNodeStateMachine/Run/blend_position", blend_position)
		animation_tree.set("parameters/AnimationNodeStateMachine/State/current", 1)
