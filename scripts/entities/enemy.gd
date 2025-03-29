class_name Enemy extends CharacterBody3D

@export var movement_speed: float = 0.5
@export var accel: float = 10
@export var player: Player

var hurt:bool = false
var direction: Vector3 = Vector3.ZERO

var target_rotation: float = 0.0
var time_since_last_rotation: float = 0.0
var rotation_delay: float = 1.0

var knockback_direction: Vector3 = Vector3.ZERO
var knockback_strength: float = 20.0  # Adjust the force as needed
var knockback_duration: float = 0.2  # How long the knockback lasts
var knockback_timer: float = 0.0

@onready var navigation_agent: NavigationAgent3D = get_node("NavigationAgent3D")
@onready var enemy_collision_shape: CollisionShape3D = $EnemyCollisionShape

func _ready() -> void:
	$HurtSurfaceArea.connect("area_entered", _on_hurt)
	$HurtSurfaceArea.connect("area_exited", _on_disengage)

func _physics_process(delta: float) -> void:
	time_since_last_rotation += delta
	navigation_agent.target_position = player.global_position

	if knockback_timer > 0:
		knockback_timer -= delta
		velocity += knockback_direction * knockback_strength * delta  # Apply knockback impulse
	else:
		knockback_timer = 0
		hurt = false  # Stop knockback after duration

	if not hurt:  # Regular movement only if not knocked back
		direction = navigation_agent.get_next_path_position() - global_position
		direction = direction.normalized()
		_rotate()
		velocity = velocity.move_toward(direction * movement_speed, accel * delta)
	else:
		print("Hurt")

	move_and_slide()

func _rotate() -> void:
	if direction.length() > 0.01 and time_since_last_rotation >= rotation_delay:
		time_since_last_rotation = 0.0  # Reset timer

		var directions: Array[Vector3] = [
			Vector3(0, 0, -1),  
			Vector3(1, 0, -1).normalized(),  
			Vector3(1, 0, 0),  
			Vector3(1, 0, 1).normalized(),  
			Vector3(0, 0, 1),  
			Vector3(-1, 0, 1).normalized(),  
			Vector3(-1, 0, 0),  
			Vector3(-1, 0, -1).normalized()
		]

		# Find closest direction
		var closest_direction: Vector3 = directions[0]
		var closest_dot: float = -1
		for dir: Vector3 in directions:
			var dot: float = direction.dot(dir)
			if dot > closest_dot:
				closest_dot = dot
				closest_direction = dir

		# Instantly snap to new direction
		rotation.y = atan2(-closest_direction.x, -closest_direction.z)

func _on_hurt(area: Area3D) -> void:
	if area is PlayerAttackSurfaceArea:
		hurt = true
		knockback_timer = knockback_duration  # Reset knockback duration

		# Calculate knockback direction (away from the attacker)
		knockback_direction = (global_position - area.global_position).normalized()
		

func _on_disengage(area: Area3D) -> void:
	if area is PlayerAttackSurfaceArea:
		print("Disengaging")
		hurt = false
