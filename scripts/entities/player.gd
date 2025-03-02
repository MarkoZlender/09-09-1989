class_name Player 
extends CharacterBody3D

@export var SPEED: float = 5.0
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
var direction: Vector3 = Vector3.ZERO
var is_moving: bool = false
var last_facing_direction: Vector2 = Vector2(0, -1)
var _last_direction: Vector3 = Vector3.ZERO


func move(delta: float) -> void:
	# apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	var input_dir: Vector2 = Input.get_vector("left", "right", "up", "down")
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

func animate_input() -> void: # fallback method until they fix animation tree errors
	
	var input_dir: Vector2 = Input.get_vector("left", "right", "up", "down");
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction != Vector3.ZERO:
	
		_last_direction = direction;

		if direction.x > 0:
			_animation_player.play("run_right");
		elif direction.x < 0:
			_animation_player.play("run_left");
		elif direction.z > 0:
			_animation_player.play("run_down");
		elif direction.z < 0:
			_animation_player.play("run_up");
	else:
		if _last_direction.x > 0:
			_animation_player.play("idle_right");
		elif _last_direction.x < 0:
			_animation_player.play("idle_left");
		elif _last_direction.z > 0:
			_animation_player.play("idle_down");
		elif _last_direction.z < 0:
			_animation_player.play("idle_up");
		else:
			_animation_player.play("idle_down");

func animate_input_animation_tree() -> void:
	var idle: bool = !velocity
	var blend_position: Vector2 = Vector2(velocity.x, velocity.z).normalized()
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
