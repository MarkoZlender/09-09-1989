extends Node2D

@export var tile_size: Vector2 = Vector2(16, 16)
@export var tilemap: TileMapLayer
@onready var timer: Timer = $Timer

enum ROTATION_DIRECTION {
	LEFT,
	RIGHT
}

var tilemap_position: Vector2 = Vector2(2, 2)
var global_tilemap_coordinates: Array[Vector2] = []

var is_moving: bool= false
var inputs: Dictionary = {
	"move_right": Vector2.RIGHT,
	"move_left": Vector2.LEFT,
	"move_forward": Vector2.UP,
	"move_back": Vector2.DOWN
}

func _ready() -> void:
	global_position = tilemap.map_to_local(tilemap_position)
	for tile: Vector2i in tilemap.get_used_cells():
		global_tilemap_coordinates.append(tilemap.map_to_local(tile))

# func _process(delta: float) -> void:
# 	handle_movement_input()

# unhandled because we want to handle these input events independently of ui input
func _unhandled_input(event: InputEvent) -> void:
	handle_movement_input(event)


func handle_movement_input(event: InputEvent) -> void:
	var local_forward: Vector2 = -transform.y
	var local_back: Vector2 = transform.y
	var local_left: Vector2 = -transform.x
	var local_right: Vector2 = transform.x


#region forward_back
	# not using switch/match because it is slower in gdscript than if-elif-else statements
	if event.is_action_pressed("move_forward", true) && is_position_valid(position + local_forward * tile_size):
		move(local_forward)
		

	elif event.is_action_pressed("move_back", true) && is_position_valid(position + local_back * tile_size):
		move(local_back)
		
#endregion

#region strafing
	elif event.is_action_pressed("strafe_left", true) && is_position_valid(position + local_left * tile_size):
			move(local_left)
			

	elif event.is_action_pressed("strafe_right", true) && is_position_valid(position + local_right * tile_size):
			move(local_right)
			
#endregion

#region left_right
	elif event.is_action_pressed("move_left", true) && !event.is_action_pressed("strafe_left", true):
		rotate_player(ROTATION_DIRECTION.LEFT)
		

	elif event.is_action_pressed("move_right", true) && !event.is_action_pressed("strafe_right", true):
		rotate_player(ROTATION_DIRECTION.RIGHT)
		

	else:
		is_moving = false

func move(direction: Vector2) -> void:
	is_moving = true
	position = position + direction * tile_size
	#play_footsteps()

func rotate_player(direction: ROTATION_DIRECTION) -> void:
	is_moving = true
	
	if direction == ROTATION_DIRECTION.LEFT:
		transform = transform.rotated_local(-PI / 2)
	elif direction == ROTATION_DIRECTION.RIGHT:
		transform = transform.rotated_local(PI / 2)

func is_position_valid(pos: Vector2) -> bool:
	var tile: Vector2i = tilemap.local_to_map(pos)
	return tilemap.get_cell_tile_data(tile) != null
