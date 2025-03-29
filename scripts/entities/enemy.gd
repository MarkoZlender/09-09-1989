class_name Enemy extends CharacterBody3D

@export var movement_speed: float = 0.8
@export var accel: float = 10
@export var player: Player

var hurt:bool = false
var direction: Vector3 = Vector3.ZERO

@onready var navigation_agent: NavigationAgent3D = get_node("NavigationAgent3D")
@onready var hurt_surfaces: Array[Area3D] = [
		$HurtSurfaces/BackHurtSurfaceArea,
		$HurtSurfaces/FrontHurtSurfaceArea,
		$HurtSurfaces/LeftHurtSurfaceArea,
		$HurtSurfaces/RightHurtSurfaceArea
	]

func _ready() -> void:
	for area in hurt_surfaces:
		area.connect("area_entered", _on_hurt)
		area.connect("area_exited", _on_disengage)

func _physics_process(delta: float) -> void:
	navigation_agent.target_position = player.global_position

	direction = navigation_agent.get_next_path_position() - global_position
	direction = direction.normalized()

	if direction.length() > 0.01:  # Avoid rotating when the direction is too small
		var target_rotation_y = atan2(-direction.x, -direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation_y, delta * 0.5)  # Adjust the multiplier to control rotation speed

	velocity = velocity.move_toward(direction * movement_speed, accel * delta)

	if hurt:
		print("Hurting")
	
	_rotate()

	move_and_slide()

func _rotate():
	if direction.length() > 0.01:  # Avoid rotating when the direction is too small
		# Define the 8 possible directions in radians
		var directions = [
			Vector3(0, 0, -1),  # Forward (-Z)
			Vector3(1, 0, -1).normalized(),  # Forward-Right
			Vector3(1, 0, 0),  # Right (+X)
			Vector3(1, 0, 1).normalized(),  # Backward-Right
			Vector3(0, 0, 1),  # Backward (+Z)
			Vector3(-1, 0, 1).normalized(),  # Backward-Left
			Vector3(-1, 0, 0),  # Left (-X)
			Vector3(-1, 0, -1).normalized()  # Forward-Left
		]

		# Find the closest direction
		var closest_direction = directions[0]
		var closest_dot = -1  # Minimum possible dot product
		for dir in directions:
			var dot = direction.dot(dir)
			if dot > closest_dot:
				closest_dot = dot
				closest_direction = dir

		# Set the rotation to face the closest direction
		rotation.y = atan2(-closest_direction.x, -closest_direction.z)

func _on_hurt(area: Area3D) -> void:
	if area is PlayerAttackSurfaceArea:
		hurt = true

func _on_disengage(area: Area3D) -> void:
	if area is PlayerAttackSurfaceArea:
		print("Disengaging")
		hurt = false
