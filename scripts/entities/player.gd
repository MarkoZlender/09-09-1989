class_name Player 
extends CharacterBody3D

const JUMP_VELOCITY: float = 3.5

@export var SPEED: float = 1.0
@export var rotation_controls: bool = true

var direction: Vector3 = Vector3.ZERO
var is_moving: bool = false
var last_facing_direction: Vector2 = Vector2(0, -1)
var _last_direction: Vector3 = Vector3.ZERO
var is_jumping: bool = false
@onready var input_dir: Vector2 = Input.get_vector("left", "right", "up", "down")
var camera_velocity: Vector3 = Vector3.ZERO


@onready var animation_tree: AnimationTree = $AnimationTree
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _camera_gimbal: Node3D = $CameraGimbal
@onready var animated_sprite: AnimatedSprite3D = $AnimatedSprite3D

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		if Global.game_controller.get_node_or_null("GUI/InventoryItemList") == null:
			_add_inventory()
		else:
			Global.game_controller.get_node("GUI/InventoryItemList").queue_free()
		
func move(delta: float) -> void:
	# apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	input_dir = Input.get_vector("left", "right", "up", "down")
	var camera_basis: Basis = _camera_gimbal.global_transform.basis
	var adjusted_direction: Vector3 = (camera_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	direction = (transform.basis * Vector3(adjusted_direction.x, 0, adjusted_direction.z)).normalized()
	
	if direction:
		is_moving = true
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		is_moving = false
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	camera_velocity = _camera_gimbal.global_transform.basis.inverse() * velocity
		
	move_and_slide()
	animate_input_animation_tree()
	#animate_input()
	#animate_jump_input()


func animate_input() -> void:
	if input_dir != Vector2.ZERO:
		# Convert input direction to the player's local space
		var local_direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

		_last_direction = local_direction

		# Determine the animation based on the local direction
		if local_direction.x > 0 and abs(local_direction.x) > abs(local_direction.z):
			animated_sprite.play("run_right")
		elif local_direction.x < 0 and abs(local_direction.x) > abs(local_direction.z):
			animated_sprite.play("run_left")
		elif local_direction.z > 0 and abs(local_direction.z) > abs(local_direction.x):
			animated_sprite.play("run_back")
		elif local_direction.z < 0 and abs(local_direction.z) > abs(local_direction.x):
			animated_sprite.play("run_forward")
		# Diagonal directions
		elif local_direction.x > 0 and local_direction.z > 0:
			animated_sprite.play("run_se")
		elif local_direction.x < 0 and local_direction.z > 0:
			animated_sprite.play("run_sw")
		elif local_direction.x > 0 and local_direction.z < 0:
			animated_sprite.play("run_ne")
		elif local_direction.x < 0 and local_direction.z < 0:
			animated_sprite.play("run_nw")
	else:
		# Idle animations based on the last direction
		if _last_direction.x > 0 and abs(_last_direction.x) > abs(_last_direction.z):
			animated_sprite.play("idle_right")
		elif _last_direction.x < 0 and abs(_last_direction.x) > abs(_last_direction.z):
			animated_sprite.play("idle_left")
		elif _last_direction.z > 0 and abs(_last_direction.z) > abs(_last_direction.x):
			animated_sprite.play("idle_back")
		elif _last_direction.z < 0 and abs(_last_direction.z) > abs(_last_direction.x):
			animated_sprite.play("idle_forward")
		# Diagonal idle directions
		elif _last_direction.x > 0 and _last_direction.z > 0:
			animated_sprite.play("idle_se")
		elif _last_direction.x < 0 and _last_direction.z > 0:
			animated_sprite.play("idle_sw")
		elif _last_direction.x > 0 and _last_direction.z < 0:
			animated_sprite.play("idle_ne")
		elif _last_direction.x < 0 and _last_direction.z < 0:
			animated_sprite.play("idle_nw")
		else:
			animated_sprite.play("idle_back")

func animate_jump_input() -> void:
	# Check if the jump action is pressed and the player is not already jumping
	if Input.is_action_just_pressed("jump") and not is_jumping:
		is_jumping = true  # Set the jumping flag
		var input_dir: Vector2 = Input.get_vector("left", "right", "up", "down")
		
		if input_dir != Vector2.ZERO:
			# Convert input direction to the player's local space
			var local_direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

			_last_direction = local_direction

			# Determine the jump animation based on the local direction
			if local_direction.x > 0 and abs(local_direction.x) > abs(local_direction.z):
				animated_sprite.play("jump_right")
			elif local_direction.x < 0 and abs(local_direction.x) > abs(local_direction.z):
				animated_sprite.play("jump_left")
			elif local_direction.z > 0 and abs(local_direction.z) > abs(local_direction.x):
				animated_sprite.play("jump_back")
			elif local_direction.z < 0 and abs(local_direction.z) > abs(local_direction.x):
				animated_sprite.play("jump_forward")
			# Diagonal directions
			elif local_direction.x > 0 and local_direction.z > 0:
				animated_sprite.play("jump_se")
			elif local_direction.x < 0 and local_direction.z > 0:
				animated_sprite.play("jump_sw")
			elif local_direction.x > 0 and local_direction.z < 0:
				animated_sprite.play("jump_ne")
			elif local_direction.x < 0 and local_direction.z < 0:
				animated_sprite.play("jump_nw")
		else:
			# Idle jump animations based on the last direction
			if _last_direction.x > 0 and abs(_last_direction.x) > abs(_last_direction.z):
				animated_sprite.play("jump_right")
			elif _last_direction.x < 0 and abs(_last_direction.x) > abs(_last_direction.z):
				animated_sprite.play("jump_left")
			elif _last_direction.z > 0 and abs(_last_direction.z) > abs(_last_direction.x):
				animated_sprite.play("jump_back")
			elif _last_direction.z < 0 and abs(_last_direction.z) > abs(_last_direction.x):
				animated_sprite.play("jump_forward")
			# Diagonal idle directions
			elif _last_direction.x > 0 and _last_direction.z > 0:
				animated_sprite.play("jump_se")
			elif _last_direction.x < 0 and _last_direction.z > 0:
				animated_sprite.play("jump_sw")
			elif _last_direction.x > 0 and _last_direction.z < 0:
				animated_sprite.play("jump_ne")
			elif _last_direction.x < 0 and _last_direction.z < 0:
				animated_sprite.play("jump_nw")
			else:
				animated_sprite.play("jump_back")

func animate_input_a_player() -> void: # fallback method until they fix animation tree errors
	var input_dir: Vector2 = Input.get_vector("left", "right", "up", "down")
	
	if input_dir != Vector2.ZERO:
		_last_direction = Vector3(input_dir.x, 0, input_dir.y)

		# Determine the animation based on the input direction
		if input_dir.x > 0:
			_animation_player.play("run_right")
		elif input_dir.x < 0:
			_animation_player.play("run_left")
		elif input_dir.y > 0:
			_animation_player.play("run_down")
		elif input_dir.y < 0:
			_animation_player.play("run_up")
	else:
		if _last_direction.x > 0:
			_animation_player.play("idle_right")
		elif _last_direction.x < 0:
			_animation_player.play("idle_left")
		elif _last_direction.z > 0:
			_animation_player.play("idle_down")
		elif _last_direction.z < 0:
			_animation_player.play("idle_up")
		else:
			_animation_player.play("idle_down")


	# if direction != Vector3.ZERO:
	
	# 	_last_direction = direction;

	# 	if direction.x > 0:
	# 		_animation_player.play("run_right");
	# 	elif direction.x < 0:
	# 		_animation_player.play("run_left");
	# 	elif direction.z > 0:
	# 		_animation_player.play("run_down");
	# 	elif direction.z < 0:
	# 		_animation_player.play("run_up");
	# else:
	# 	if _last_direction.x > 0:
	# 		_animation_player.play("idle_right");
	# 	elif _last_direction.x < 0:
	# 		_animation_player.play("idle_left");
	# 	elif _last_direction.z > 0:
	# 		_animation_player.play("idle_down");
	# 	elif _last_direction.z < 0:
	# 		_animation_player.play("idle_up");
	# 	else:
	# 		_animation_player.play("idle_down");

func animate_input_animation_tree() -> void:
	var idle: bool = !camera_velocity
	var blend_position: Vector2 = Vector2(camera_velocity.x, camera_velocity.z).normalized()
	if !idle:
		last_facing_direction = blend_position

	animation_tree.set("parameters/Run/blend_position", last_facing_direction)
	animation_tree.set("parameters/Idle/blend_position", last_facing_direction)
	animation_tree.set("parameters/Jump/blend_position", last_facing_direction)

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
