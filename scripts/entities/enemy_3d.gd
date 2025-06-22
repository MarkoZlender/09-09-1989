class_name Enemy extends CharacterBody3D

@export var enemy_data: EnemyData
@export var player: Player

var is_deaggroed: bool = true
var is_aggroed: bool = false
var is_moving: bool = false
var is_hurt: bool = false
var is_dead: bool = false
var is_attacking: bool = false
var target_reached: bool = false
var player_detected: bool = false
var player_in_range: bool = false
var attack_finished: bool = false

var turn_speed: float = 15.0

var direction: Vector3 = Vector3.ZERO 

@onready var movement_speed: float = enemy_data.movement_speed
@onready var accel: float = enemy_data.accel

@onready var navigation_agent: NavigationAgent3D = get_node("NavigationAgent3D")
@onready var enemy_collision_shape: CollisionShape3D = $EnemyCollisionShape
@onready var enemy_model: Node3D = $EnemyModel
@onready var player_detector_area: Area3D = $PlayerDetectorArea

func _ready() -> void:
	enemy_data = enemy_data.duplicate()
	$PatrollTimer.start(randf_range(3.0, 4.0))
	enemy_model.get_node("AnimationTree").connect("animation_finished", _on_animation_finished)
	player_detector_area.connect("body_entered", _on_player_detected)
	player_detector_area.connect("body_exited", _on_player_out_of_range)

func aggroed(delta: float) -> void:
	navigation_agent.target_position = player.global_position
	direction = (navigation_agent.get_next_path_position() - global_position).normalized()

	velocity = velocity.move_toward(direction * movement_speed, accel * delta)
	rotate_towards_target(navigation_agent.target_position)

	is_moving = velocity.length() > 0.1

	#_apply_gravity(delta)
	move_and_slide()

func deaggroed(delta: float) -> void:
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
	rotate_towards_target(navigation_agent.target_position)
	#_apply_gravity(delta)
	move_and_slide()

func rotate_towards_target(target_position: Vector3) -> void:
	var to_target: Vector3 = target_position - global_position
	to_target.y = 0  # Ignore vertical difference for horizontal rotation
	if to_target.length() > 0.01:
		var target_angle: float = atan2(to_target.x, to_target.z)
		rotation.y = lerp_angle(rotation.y, target_angle, turn_speed * get_process_delta_time())

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	else:
		velocity.y = 0.0

func _on_player_detected(body: Node3D) -> void:
	if body is Player:
		player_detected = true
		attack_finished = false
		is_attacking = true
		enemy_model.get_node("AnimationPlayer").get_animation("attack").loop_mode = Animation.LOOP_LINEAR

func _on_player_out_of_range(body: Node3D) -> void:
	if body is Player:
		player_detected = false
		is_attacking = false
		enemy_model.get_node("AnimationPlayer").get_animation("attack").loop_mode = Animation.LOOP_NONE

func _on_navigation_agent_3d_target_reached() -> void:
	target_reached = true
	if player_detected:
		is_moving = false

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "hit":
		is_hurt = false
	
	if anim_name == "attack":
		is_attacking = false
		attack_finished = true

func _on_aggro_area_body_entered(body: Node3D) -> void:
	if body is Player:
		is_aggroed = true
		is_deaggroed = false

func _on_deaggro_area_body_exited(body: Node3D) -> void:
	if body is Player:
		is_aggroed = false
		is_deaggroed = true

func _on_enemy_hurt_box_area_entered(area:Area3D) -> void:
	if area is PlayerHitBox:
		print("enemy health: ", enemy_data.health)
		if enemy_data.health <= 0:
			_dead()
			return
		enemy_data.health -= 10
		is_hurt = true
		Global.signal_bus.spawn_blood.emit(global_position)

func _dead() -> void:
		is_dead = true
		enemy_collision_shape.disabled = true
		$AggroArea.monitoring = false
		$DeaggroArea.monitoring = false
		$PlayerDetectorArea.monitoring = false
		$EnemyHurtBox.set_deferred("monitoring", false)