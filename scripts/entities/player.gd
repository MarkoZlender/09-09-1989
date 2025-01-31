class_name Player extends CharacterBody3D

# Grid settings
@export var cell_size := Vector3(1, 0, 1)
@export var move_speed := 5.0
@export var gridmap: GridMap

@onready var camera_rig: Marker3D = %CameraRig

var grid_position := Vector3(0.5, 0, 0.5)
var global_cell_coordinates: Array[Vector3] = []
var tween
var is_moving := false
var inputs = {
	"move_right": Vector3.RIGHT,
	"move_left": Vector3.LEFT,
	"move_forward": Vector3.FORWARD,
	"move_back": Vector3.BACK
}

func _ready():
	camera_rig.top_level = true
	position = grid_position
	for cell in gridmap.get_used_cells():
		global_cell_coordinates.append(gridmap.map_to_local(cell))

func _process(delta: float) -> void:
	camera_follows_player()
	handle_movement_input()
	update_idle_state()

func handle_movement_input():
	var direction_pressed = false
	
	if Input.is_action_pressed("move_forward"):
		direction_pressed = true
		attempt_move("move_forward")
	elif Input.is_action_pressed("move_back"):
		direction_pressed = true
		attempt_move("move_back")
	elif Input.is_action_pressed("move_left"):
		direction_pressed = true
		attempt_move("move_left")
	elif Input.is_action_pressed("move_right"):
		direction_pressed = true
		attempt_move("move_right")
	
	if !direction_pressed and !is_moving:
		$Cynthia/AnimationPlayer.play("Idle")

func attempt_move(dir: String):
	if is_moving:
		return

	match dir:
		"move_right": rotation.y = deg_to_rad(0)
		"move_left": rotation.y = deg_to_rad(180)
		"move_forward": rotation.y = deg_to_rad(90)
		"move_back": rotation.y = deg_to_rad(-90)
	
	var new_position = position + inputs[dir]
	
	if is_position_valid(new_position):
		start_movement(new_position)
	else:
		$Cynthia/AnimationPlayer.play("Idle")

func start_movement(target_pos: Vector3):
	is_moving = true
	$Cynthia/AnimationPlayer.play("Run")
	
	tween = create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(self, "position", target_pos, 1 / move_speed).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(finalize_movement)

func finalize_movement():
	is_moving = false
	# Check if still pressing direction after movement
	handle_movement_input()

func update_idle_state():
	if !is_moving && !Input.is_anything_pressed():
		$Cynthia/AnimationPlayer.play("Idle")

func camera_follows_player():
	camera_rig.global_position = global_position + Vector3(-3, 9, 7)

func is_position_valid(pos: Vector3) -> bool:
	return pos in global_cell_coordinates

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
