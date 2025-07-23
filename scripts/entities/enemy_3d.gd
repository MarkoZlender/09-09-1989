class_name Enemy extends CharacterBody3D

@export var enemy_data: EnemyData
@export var player: Player
@export var aggro_reach_area: Area3D

var current_state: EnemyState.State = EnemyState.State.DEAGGROED

var target_reached: bool = false
var player_detected: bool = false
var player_in_range: bool = false
var attack_finished: bool = true

var turn_speed: float = 10.0

var direction: Vector3 = Vector3.ZERO

var player_in_reach_area: bool = false

var idle_timer: Timer
var last_position: Vector3
var idle_time_threshold: float = 3.0 # seconds

@onready var movement_speed: float = enemy_data.movement_speed
@onready var accel: float = enemy_data.accel

@onready var navigation_agent: NavigationAgent3D = get_node("NavigationAgent3D")
@onready var enemy_collision_shape: CollisionShape3D = $EnemyCollisionShape
@onready var enemy_hurt_box: Area3D = $EnemyHurtBox
@onready var enemy_model: Node3D = $EnemyModel
@onready var player_detector_area: Area3D = $PlayerDetectorArea

func _ready() -> void:
	enemy_data = enemy_data.duplicate()
	$PatrollTimer.start(randf_range(3.0, 4.0))
	idle_timer = Timer.new()
	idle_timer.wait_time = idle_time_threshold
	idle_timer.one_shot = true
	idle_timer.connect("timeout", Callable(self, "_on_idle_timeout"))
	add_child(idle_timer)
	last_position = global_position
	enemy_model.get_node("AnimationTree").connect("animation_finished", _on_animation_finished)
	player_detector_area.connect("body_entered", _on_player_detected)
	player_detector_area.connect("body_exited", _on_player_out_of_range)
	aggro_reach_area.connect("body_entered", _on_player_in_aggro_area_range)
	aggro_reach_area.connect("body_exited", _on_player_out_of_aggro_area_range)

func aggroed(delta: float) -> void:
	navigation_agent.target_position = player.global_position
	# if !navigation_agent.is_target_reachable():
	# 	current_state = EnemyState.State.DEAGGROED
	# 	%StateChart.send_event("deaggroed")
	# 	navigation_agent.target_position = global_position
	# 	print("Player out of aggro range, switching to DEAGROED state")
	# 	return
	if !player_in_reach_area:
		current_state = EnemyState.State.DEAGGROED
		%StateChart.send_event("deaggroed")
		navigation_agent.target_position = global_position
		print("Player out of aggro range, switching to DEAGROED state")
		return
	direction = (navigation_agent.get_next_path_position() - global_position).normalized()

	velocity = velocity.move_toward(direction * movement_speed, accel * delta)
	_rotate_towards_target(navigation_agent.target_position)

	move_and_slide()

func deaggroed(delta: float) -> void:
	if !idle_timer.is_stopped():
		if global_position.distance_to(last_position) > 0.1:
			idle_timer.stop()
			idle_timer.start()
			last_position = global_position
	else:
		idle_timer.start()
		last_position = global_position

	if $AggroArea.get_overlapping_bodies().has(player) && player_in_reach_area:
		current_state = EnemyState.State.AGGROED
		%StateChart.send_event("aggroed")
		navigation_agent.target_position = player.global_position
		print("Player detected, switching to AGGROED state")
		idle_timer.stop()
		return
	# patrolling
	if navigation_agent.is_navigation_finished():
		if $PatrollTimer.time_left <= 0:
			if velocity.length() > 0.1:
				velocity = Vector3.ZERO
				move_and_slide()
				$PatrollTimer.start(randf_range(2.0, 3.0))  # Wait for a random duration
			else:
				var random_offset: Vector3 = Vector3(
					randf_range(enemy_data.wander_range_x.x, enemy_data.wander_range_x.y), 
					0, 
					randf_range(enemy_data.wander_range_z.x, enemy_data.wander_range_z.y)
				)
				navigation_agent.target_position = global_position + random_offset

	if $PatrollTimer.time_left <= 0:
		direction = navigation_agent.get_next_path_position() - global_position
		direction = direction.normalized()

		velocity = velocity.move_toward(direction * movement_speed, accel * delta)

	_rotate_towards_target(navigation_agent.target_position)
	move_and_slide()

func _rotate_towards_target(target_position: Vector3) -> void:
	var to_target: Vector3 = target_position - global_position
	to_target.y = 0
	if to_target.length() > 0.01:
		var target_angle: float = atan2(to_target.x, to_target.z)
		rotation.y = lerp_angle(rotation.y, target_angle, turn_speed * get_process_delta_time())

func _on_player_detected(body: Node3D) -> void:
	if body is Player:
		player_detected = true
		attack_finished = false
		current_state = EnemyState.State.ATTACKING
		enemy_model.get_node("AnimationPlayer").get_animation("attack").loop_mode = Animation.LOOP_LINEAR

func _on_player_out_of_range(body: Node3D) -> void:
	if body is Player:
		player_detected = false
		enemy_model.get_node("AnimationPlayer").get_animation("attack").loop_mode = Animation.LOOP_NONE

func _on_navigation_agent_3d_target_reached() -> void:
	target_reached = true

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "hit":
		current_state = EnemyState.State.AGGROED
		enemy_hurt_box.monitoring = true
		player_detector_area.monitoring = true
		attack_finished = true

	if anim_name == "attack":
		if current_state != EnemyState.State.HURT:
			current_state = EnemyState.State.AGGROED
		attack_finished = true

func _on_aggro_area_body_entered(body: Node3D) -> void:
	if body is Player && current_state != EnemyState.State.ATTACKING:
		current_state = EnemyState.State.AGGROED

func _on_deaggro_area_body_exited(body: Node3D) -> void:
	if body is Player:
		current_state = EnemyState.State.DEAGGROED

func _on_enemy_hurt_box_area_entered(area:Area3D) -> void:
	if area is PlayerHitBox and current_state != EnemyState.State.HURT:
		current_state = EnemyState.State.HURT
		print("enemy hit by player")
		player_detector_area.monitoring = false
		enemy_model.get_node("AnimationPlayer").get_animation("attack").loop_mode = Animation.LOOP_NONE
		enemy_data.health -= 10
		Global.signal_bus.spawn_blood.emit(global_position)
		if enemy_data.health <= 0:
			_dead()
			return
		attack_finished = true

func _on_player_in_aggro_area_range(body: Node3D) -> void:
	if body is Player:
		player_in_reach_area = true

func _on_player_out_of_aggro_area_range(body: Node3D) -> void:
	if body is Player:
		player_in_reach_area = false

func _on_idle_timeout() -> void:
	print("Enemy idle for too long, searching for new target.")
	# Find a new target or patrol location
	var random_offset: Vector3 = Vector3(
		randf_range(enemy_data.wander_range_x.x, enemy_data.wander_range_x.y), 
		0, 
		randf_range(enemy_data.wander_range_z.x, enemy_data.wander_range_z.y)
	)
	navigation_agent.target_position = global_position + random_offset

func _dead() -> void:
	enemy_collision_shape.disabled = true
	$AggroArea.monitoring = false
	$DeaggroArea.monitoring = false
	$PlayerDetectorArea.monitoring = false
	$EnemyHurtBox.set_deferred("monitoring", false)
	Global.signal_bus.enemy_died.emit(self)
	current_state = EnemyState.State.DEAD
