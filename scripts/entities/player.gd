class_name Player 
extends CharacterBody3D

const JUMP_VELOCITY = 4.5

@export var SPEED = 5.0
@onready var animation_tree: AnimationTree = $AnimationTree
#@onready var animation: AnimatedSprite3D = $Animation
var direction
var is_moving: bool = false
var last_facing_direction: Vector2 = Vector2(0, -1)

# func _physics_process(delta: float) -> void:
# 	move(delta)

func move(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# # Handle jump.
	# if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	# 	velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("left", "right", "up", "down")
	#animate_input()
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		is_moving = true
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		is_moving = false
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		

	move_and_slide()
	animate_input()

func animate_input():
	var idle = !velocity
	var blend_position = Vector2(velocity.x, velocity.z).normalized()
	if !idle:
		last_facing_direction = blend_position

	animation_tree.set("parameters/Run/blend_position", last_facing_direction)
	animation_tree.set("parameters/Idle/blend_position", last_facing_direction)

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
