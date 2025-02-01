class_name Player extends Node3D
const TRAVEL_TIME: float = 0.3
# Grid settings
@export var cell_size := Vector3(1, 0, 1)
@export var move_speed := 5.0
@export var gridmap: GridMap

@onready var camera_rig: Marker3D = %CameraRig
@onready var animation_player: AnimationPlayer = %AnimationPlayer

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
	#self.global_transform.origin = gridmap.map_to_local(Vector3i(0, 1, 0))
	global_position = grid_position
	for cell in gridmap.get_used_cells():
		global_cell_coordinates.append(gridmap.map_to_local(cell))

func _process(delta: float) -> void:
	handle_movement_input()

func handle_movement_input():
	if tween is Tween and tween.is_running():
		return
	
	var local_forward = -transform.basis.z
	var local_back = transform.basis.z
	var local_left = -transform.basis.x
	var local_right = transform.basis.x

#region front_back
	if Input.is_action_pressed("move_forward") && is_position_valid(position + local_forward * cell_size):
		if !animation_player.is_playing():
			move(local_forward)
			animation_player.play("headbob")
			#play_footsteps()


	elif Input.is_action_pressed("move_back") && is_position_valid(position + local_back * cell_size):
		if !animation_player.is_playing():
			move(local_back)
			animation_player.play("headbob")
			#play_footsteps()
		
#endregion

#region strafing
	elif Input.is_action_pressed("strafe_left") && is_position_valid(position + local_left * cell_size):
		if !animation_player.is_playing():
			move(local_left)
			animation_player.play("headbob")
			#play_footsteps()
		
	
	elif Input.is_action_pressed("strafe_right") && is_position_valid(position + local_right * cell_size):
		if !animation_player.is_playing():
			move(local_right)
			animation_player.play("headbob")
			#play_footsteps()
		
#endregion

#region left_right
	elif Input.is_action_pressed("move_left") && !Input.is_action_pressed("strafe_left"):
		tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "transform", transform.rotated_local(Vector3.UP, PI / 2), TRAVEL_TIME)
	
	elif Input.is_action_pressed("move_right") && !Input.is_action_pressed("strafe_right"):
		tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "transform", transform.rotated_local(Vector3.UP, -PI / 2), TRAVEL_TIME)


func move(direction: Vector3):
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", position + direction * cell_size, TRAVEL_TIME)

func attempt_move(dir: String):
	if is_moving:
		return

	var new_position = position + inputs[dir]
	
	if is_position_valid(new_position):
		start_movement(new_position)

func start_movement(target_pos: Vector3):
	is_moving = true
	
	tween = create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(self, "position", target_pos, 1 / move_speed).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(finalize_movement)

func finalize_movement():
	is_moving = false
	# Check if still pressing direction after movement
	handle_movement_input()


func is_position_valid(pos: Vector3) -> bool:
	var cell = gridmap.local_to_map(pos)
	return gridmap.get_cell_item(cell) != GridMap.INVALID_CELL_ITEM

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
