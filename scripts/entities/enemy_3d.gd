class_name Enemy extends CharacterBody3D

@export var enemy_data: EnemyData
@export var player: Player

var is_deaggroed: bool = true
var is_aggroed: bool = false
var is_moving: bool = false
var is_hurt: bool = false
var is_dead: bool = false
var reached_player: bool = false
var turn_speed: float = 10.0

var direction: Vector3 = Vector3.ZERO 

@onready var movement_speed: float = enemy_data.movement_speed
@onready var accel: float = enemy_data.accel

@onready var navigation_agent: NavigationAgent3D = get_node("NavigationAgent3D")
@onready var enemy_collision_shape: CollisionShape3D = $EnemyCollisionShape
@onready var enemy_model: Node3D = $EnemyModel

func _ready() -> void:
	enemy_data = enemy_data.duplicate()
	for collision in get_tree().get_nodes_in_group("collisions"):
		collision.duplicate()
	$PatrollTimer.start(randf_range(3.0, 4.0))
	enemy_model.get_node("AnimationTree").connect("animation_finished", _on_animation_finished)


func aggroed(delta: float) -> void:
	navigation_agent.target_position = player.global_position
	direction = (navigation_agent.get_next_path_position() - global_position).normalized()

	velocity = velocity.move_toward(direction * movement_speed, accel * delta)
	rotate_towards_target(navigation_agent.target_position)

	is_moving = velocity.length() > 0.1

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
				rotate_towards_target(navigation_agent.target_position)

	# Move towards the new target if the timer is not running
	if $PatrollTimer.time_left <= 0:
		direction = navigation_agent.get_next_path_position() - global_position
		direction = direction.normalized()

		velocity = velocity.move_toward(direction * movement_speed, accel * delta)

	is_moving = velocity.length() > 0.1

	move_and_slide()

func rotate_towards_target(target_position: Vector3) -> void:
	var to_target: Vector3 = target_position - global_position
	to_target.y = 0  # Ignore vertical difference for horizontal rotation
	if to_target.length() > 0.01:
		var target_angle: float = atan2(to_target.x, to_target.z)
		rotation.y = lerp_angle(rotation.y, target_angle, turn_speed * get_process_delta_time())

func _on_navigation_agent_3d_target_reached() -> void:
	reached_player = true

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "hit":
		is_hurt = false

func _on_aggro_area_body_entered(body: Node3D) -> void:
	if body is Player:
		is_aggroed = true
		is_deaggroed = false

func _on_deaggro_area_body_exited(body: Node3D) -> void:
	if body is Player:
		is_aggroed = false
		is_deaggroed = true
