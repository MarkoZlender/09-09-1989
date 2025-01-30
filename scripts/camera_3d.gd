extends Camera3D

var start_rotation
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_rotation = rotation


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = get_parent().global_position + (get_parent().global_position - global_position)
