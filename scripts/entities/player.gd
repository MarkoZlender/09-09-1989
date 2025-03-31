class_name Player 
extends CharacterBody3D

const JUMP_VELOCITY: float = 3.5

@export var speed: float = 1.5
@export var rotation_controls: bool = true

var idle: bool
var is_moving: bool = false
var is_jumping: bool = false

var hurt:bool = false
var direction: Vector3 = Vector3.ZERO
var last_facing_direction: Vector2 = Vector2(0, -1)
var camera_velocity: Vector3 = Vector3.ZERO

var knockback_direction: Vector3 = Vector3.ZERO
var knockback_strength: float = 2.0  # Adjust the force as needed
var knockback_duration: float = 0.2  # How long the knockback lasts
var knockback_timer: float = 0.0


@onready var animation_tree: AnimationTree = $AnimationTree
@onready var camera_gimbal: Node3D = $CameraGimbal
@onready var input_dir: Vector2 = Input.get_vector("left", "right", "up", "down")

func _ready() -> void:
	$HurtSurfaceArea.connect("area_entered", _on_hurt)
	$HurtSurfaceArea.connect("area_exited", _on_disengage)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		if Global.game_controller.get_node_or_null("GUI/InventoryItemList") == null:
			_add_inventory()
		else:
			Global.game_controller.get_node("GUI/InventoryItemList").queue_free()
		
func move(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
		is_jumping = true
	else:
		is_jumping = false

	# Handle knockback
	if knockback_timer > 0:
		knockback_timer -= delta
		velocity = knockback_direction * knockback_strength
		move_and_slide()
		return  # Skip normal movement during knockback

	# Normal movement logic
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	input_dir = Input.get_vector("left", "right", "up", "down")
	var camera_basis: Basis = camera_gimbal.global_transform.basis
	var adjusted_direction: Vector3 = (camera_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	direction = (transform.basis * Vector3(adjusted_direction.x, 0, adjusted_direction.z)).normalized()

	if direction:
		is_moving = true
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		is_moving = false
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	camera_velocity = camera_gimbal.global_transform.basis.inverse() * velocity

	if direction.length() > 0.01:  # Avoid rotating when the direction is too small
		$AttackSurfaceArea.rotation.y = atan2(-direction.x, -direction.z)

	move_and_slide()
	animate_input_animation_tree()

	if hurt:
		print("Hurting player")

func animate_input_animation_tree() -> void:
	# Determine if the player is idle (no movement input)
	idle = camera_velocity.length() < 0.1  # Threshold to consider the player idle

	# Normalize the camera velocity for blending
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
		animation_tree.set("parameters/Idle/blend_position", last_facing_direction)
		animation_tree.set("parameters/State/current", 0)  # Idle state

	else:
		animation_tree.set("parameters/Run/blend_position", blend_position)
		animation_tree.set("parameters/State/current", 1)  # Run state

func _on_hurt(area: Area3D) -> void:
	if area is EnemyAttackSurfaceArea:
		hurt = true
		knockback_timer = knockback_duration
		knockback_direction = (global_position - area.global_position).normalized()

func _on_disengage(area: Area3D) -> void:
	if area is EnemyAttackSurfaceArea:
		hurt = false
		print("Disengaging")

func _add_inventory() -> void:
	var loaded_resource: Resource = load("res://scenes/ui/inventory/inventory_item_list.tscn")
	var instance: Node = loaded_resource.instantiate()
	Global.game_controller.get_node("GUI").add_child(instance)
	Global.game_controller.get_node("GUI").move_child(instance, 0)

func save() -> Dictionary:
	var save_data: Dictionary = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : global_position.x, # Vector2 is not supported by JSON
		"pos_y" : global_position.y,
		"pos_z" : global_position.z,
		"rot_x" : rotation.x,
		"rot_y" : rotation.y,
		"rot_z" : rotation.z,
	}
	return save_data

func load(data: Dictionary) -> void:
	global_position = Vector3(data["pos_x"], data["pos_y"], data["pos_z"])
	rotation = Vector3(data["rot_x"], data["rot_y"], data["rot_z"])

