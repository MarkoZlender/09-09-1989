class_name Enemy extends CharacterBody3D

@export var enemy_data: EnemyData
@export var player: Player

var idle: bool
var is_moving: bool = false
var is_jumping: bool = false

var hurt: bool = false
var direction: Vector3 = Vector3.ZERO 

@onready var movement_speed: float = enemy_data.movement_speed
@onready var accel: float = enemy_data.accel

@onready var navigation_agent: NavigationAgent3D = get_node("NavigationAgent3D")
@onready var enemy_collision_shape: CollisionShape3D = $EnemyCollisionShape

func _ready() -> void:
	enemy_data = enemy_data.duplicate()
	for collision in get_tree().get_nodes_in_group("collisions"):
		collision.duplicate()
	Global.signal_bus.player_hurt.connect(_on_player_hurt)
	$PatrollTimer.start(randf_range(3.0, 4.0))


func aggroed(delta: float) -> void:
	_check_if_on_floor()
	_apply_gravity(delta)

	navigation_agent.target_position = player.global_position
	direction = (navigation_agent.get_next_path_position() - global_position).normalized()

	velocity = velocity.move_toward(direction * movement_speed, accel * delta)

	is_moving = velocity.length() > 0.1
	is_jumping = not is_on_floor()

	move_and_slide()

func deaggroed(delta: float) -> void:
	_check_if_on_floor()
	_apply_gravity(delta)

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

		velocity = velocity.move_toward(direction * movement_speed, accel * delta)

	is_moving = velocity.length() > 0.1
	is_jumping = not is_on_floor()

	move_and_slide()

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0

func _check_if_on_floor() -> void:
	# if not on floor stop navigation agent and restart it when on floor
	if !is_on_floor():
		navigation_agent.target_position = global_position
		

func _on_hurt(area: Area3D) -> void:
	if area is PlayerAttackSurfaceArea:
		# decrease enemy health
		enemy_data.health -= 10
		enemy_data.health = clamp(enemy_data.health, 0, enemy_data.health)
		# pause animation tree when hurt
		Global.signal_bus.spawn_blood.emit(global_position)
		hurt = true

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

		# death
		if enemy_data.health <= 0:
			%StateChart.send_event("dead")
			# disable collisions
			for collision: Node in get_children():
				if collision is Area3D:
					collision.get_child(0).disabled = true
			# play death sound
			# emit signal to notify that the enemy has died
			Global.signal_bus.enemy_died.emit(self)
			# animate death
			for collision: Node in get_children():
				if collision is CollisionShape3D:
					collision.disabled = true

func _on_tween_completed() -> void:
	queue_free()

func _on_disengage(area: Area3D) -> void:
	if area is PlayerAttackSurfaceArea:
		hurt = false

func _on_player_hurt(_health: int) -> void:
	pass
