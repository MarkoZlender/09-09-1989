class_name Enemy extends CharacterBody3D

@export var enemy_data: EnemyData
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

var stun_duration: float = 0.2
var stun_timer: float = 0.0  

var camera_velocity: Vector3 = Vector3.ZERO
var last_facing_direction: Vector2

var time_since_last_rotation: float = 0.0
var rotation_delay: float = 0.2

@onready var movement_speed: float = enemy_data.movement_speed
@onready var accel: float = enemy_data.accel

@onready var navigation_agent: NavigationAgent3D = get_node("NavigationAgent3D")
@onready var enemy_collision_shape: CollisionShape3D = $EnemyCollisionShape
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var camera_gimbal: Node3D = get_tree().get_first_node_in_group("player").camera_gimbal  
@onready var animated_sprite: AnimatedSprite3D = $Animation
@onready var sfx_player: AudioStreamPlayer3D = $SFXPlayer

func _ready() -> void:
	enemy_data = enemy_data.duplicate()
	for collision in get_tree().get_nodes_in_group("collisions"):
		collision.duplicate()
	animated_sprite.sprite_frames = enemy_data.spriteframes
	enemy_data.experience *= enemy_data.level
	$FrontHurtSurfaceArea.connect("area_entered", _on_hurt)
	$FrontHurtSurfaceArea.connect("area_exited", _on_disengage)
	Global.signal_bus.player_hurt.connect(_on_player_hurt)
	$PatrollTimer.start(randf_range(3.0, 4.0))

func apply_stun_and_knockback(delta: float) -> void:
	_apply_gravity(delta)
	_play_footsteps()
	time_since_last_rotation += delta
	if knockback_timer > 0:
		knockback_timer -= delta
		velocity = knockback_direction * knockback_strength
		move_and_slide()
		navigation_agent.set_velocity_forced(Vector3.ZERO)
		return  

	if stun_timer > 0:
		stun_timer -= delta
		stunned = true
		hurt = true
		velocity = Vector3.ZERO
		move_and_slide()
		navigation_agent.set_velocity_forced(Vector3.ZERO)
		navigation_agent.target_position = global_position

	else:
		stunned = false
		hurt = false
		animation_tree.active = true
		# pause aniamtion tree to give time for the animation reset
		animation_tree.set_process_callback(AnimationTree.ANIMATION_PROCESS_MANUAL)
		await get_tree().create_timer(0.1).timeout
		animation_tree.set_process_callback(AnimationTree.ANIMATION_PROCESS_IDLE)

func aggroed(delta: float) -> void:
	_apply_gravity(delta)
	_play_footsteps()
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

func deaggroed(delta: float) -> void:
	_apply_gravity(delta)
	_play_footsteps()
	time_since_last_rotation += delta
	camera_velocity = camera_gimbal.global_transform.basis.inverse() * velocity

	apply_stun_and_knockback(delta)
	if knockback_timer > 0 or stunned:
		return  

	# Handle patrolling with a stop-and-wait behavior
	if navigation_agent.is_navigation_finished():
		# If the timer is not running, start it and stop the enemy
		if $PatrollTimer.time_left <= 0:
			if velocity.length() > 0.1:
				# Stop the enemy and start the timer
				velocity = Vector3.ZERO
				move_and_slide()
				is_moving = false
				$PatrollTimer.start(randf_range(2.0, 3.0))  # Wait for a random duration
			else:
				# After waiting, pick a new random patrol target
				var random_offset: Vector3 = Vector3(
					randf_range(enemy_data.wander_range_x.x, enemy_data.wander_range_x.y), 
					0, 
					randf_range(enemy_data.wander_range_z.x, enemy_data.wander_range_z.y)
				)
				navigation_agent.target_position = global_position + random_offset

	# Move towards the new target if the timer is not running
	if $PatrollTimer.time_left <= 0:
		direction = navigation_agent.get_next_path_position() - global_position
		direction = direction.normalized()
		_rotate()
		velocity = velocity.move_toward(direction * movement_speed, accel * delta)

	is_moving = velocity.length() > 0.1
	is_jumping = not is_on_floor()

	move_and_slide()
	animate_input_animation_tree()

func _play_footsteps() -> void:
	if is_moving && is_on_floor():
		if not sfx_player.playing && $Timer.time_left <= 0:
			sfx_player.stream = enemy_data.walk_sfx
			#sfx_player.volume_db = -50
			sfx_player.pitch_scale = 1.0 + randf_range(-0.1, 0.1)
			sfx_player.play()
			$Timer.start(0.2)
	else:
		sfx_player.pitch_scale = 1.0
		sfx_player.volume_db = 0
		if sfx_player.playing:
			sfx_player.stop()

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0

func _on_hurt(area: Area3D) -> void:
	if area is PlayerAttackSurfaceArea:
		# decrease enemy health
		enemy_data.health -= 10
		sfx_player.stream = enemy_data.hurt_sfx
		sfx_player.play()
		enemy_data.health = clamp(enemy_data.health, 0, enemy_data.health)
		# pause animation tree when hurt
		animated_sprite.stop()
		animation_tree.active = false
		hurt = true
		knockback_timer = knockback_duration
		stun_timer = stun_duration

		# Calculate the direction of the knockback based on the attacker's position
		var relative_position: Vector3 = (area.global_position - global_position).normalized()

		# Define the 4 possible directions
		var directions: Array[Vector3] = [
			Vector3(0, 0, -1),  # Forward (-Z)
			Vector3(0, 0, 1),   # Backward (+Z)
			Vector3(-1, 0, 0),  # Left (-X)
			Vector3(1, 0, 0)    # Right (+X)
		]

		# Find the closest direction
		var closest_direction: Vector3 = directions[0]
		var closest_dot: float = -1  # Minimum possible dot product
		for dir: Vector3 in directions:
			var dot: float = relative_position.dot(dir)
			if dot > closest_dot:
				closest_dot = dot
				closest_direction = dir

		knockback_direction = closest_direction * -1
		# death
		if enemy_data.health <= 0:
			%StateChart.send_event("dead")
			# disable collisions
			for collision: Node in get_children():
				if collision is Area3D:
					collision.get_child(0).disabled = true
			animated_sprite.modulate = Color(0.232, 0.232, 0.232)
			# play death sound
			sfx_player.stream = enemy_data.death_sfx
			sfx_player.play()
			await sfx_player.finished
			# emit signal to notify that the enemy has died
			Global.signal_bus.enemy_died.emit(self)
			# animate death
			var tween: Tween = get_tree().create_tween()
			tween.finished.connect(_on_tween_completed)
			tween.tween_property(animated_sprite, "modulate", Color(0, 0, 0, 0), 1.0)
			navigation_agent.process_mode = Node3D.ProcessMode.PROCESS_MODE_DISABLED
			await tween.finished
			for collision: Node in get_children():
				if collision is CollisionShape3D:
					collision.disabled = true

func _on_tween_completed() -> void:
	queue_free()

func _on_disengage(area: Area3D) -> void:
	if area is PlayerAttackSurfaceArea:
		print("Disengaging")
		hurt = false

func _rotate() -> void:
	if direction.length() > 0.01 and time_since_last_rotation >= rotation_delay:
		time_since_last_rotation = 0.0  # Reset timer

		# Define the 4 possible locked directions (Right, Left, Forward, Backward)
		var directions: Array[Vector3] = [
			Vector3(1, 0, 0),   # Right (+X)
			Vector3(-1, 0, 0),  # Left (-X)
			Vector3(0, 0, -1),  # Forward (-Z)
			Vector3(0, 0, 1)    # Backward (+Z)
		]

		var closest_direction: Vector3 = directions[0]
		var closest_dot: float = -1  # Minimum possible dot product
		for dir: Vector3 in directions:
			var dot: float = direction.dot(dir)
			if dot > closest_dot:
				closest_dot = dot
				closest_direction = dir

		# Set rotation to snap to the closest locked direction
		rotation.y = atan2(-closest_direction.x, -closest_direction.z)

func animate_input_animation_tree() -> void:
	idle = camera_velocity.length() < 0.1
	var blend_position: Vector2 = Vector2(camera_velocity.x, camera_velocity.z).normalized()
	if blend_position.length() > 0.1:
		last_facing_direction = blend_position
	if last_facing_direction == Vector2.ZERO:
		last_facing_direction = Vector2(0, -1)
	if is_jumping:
		animation_tree.set("parameters/Jump/blend_position", last_facing_direction)
		animation_tree.set("parameters/State/current", 2)
	elif idle:
		animation_tree.set("parameters/Idle/blend_position", last_facing_direction)
		animation_tree.set("parameters/State/current", 0)
	else:
		animation_tree.set("parameters/Run/blend_position", blend_position)
		animation_tree.set("parameters/State/current", 1)

func _on_attack_surface_area_body_entered(body: Node3D) -> void:
	if body is Player:
		# sfx_player.stream = enemy_data.attack_sfx
		# sfx_player.play()
		pass

func _on_player_hurt(_health: int) -> void:
	sfx_player.stream = enemy_data.attack_sfx
	sfx_player.play()
