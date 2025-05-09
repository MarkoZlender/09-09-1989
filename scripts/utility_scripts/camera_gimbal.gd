extends Node3D

var hidden_obstacles: Array = []

@onready var camera_raycast: RayCast3D = %CameraRayCast

func _ready() -> void:
	rotation_degrees.y = owner.level_camera_rotation

func _physics_process(_delta: float) -> void:
	# Make all previously hidden objects visible
	for obstacle in hidden_obstacles:
		if is_instance_valid(obstacle):
			obstacle.visible = true
	hidden_obstacles.clear()

	# Hide the currently colliding object
	if camera_raycast.is_colliding():
		var obstacle = camera_raycast.get_collider()
		if obstacle and obstacle.visible:  # Only hide if it's currently visible
			obstacle.visible = false
			hidden_obstacles.append(obstacle)


func _unhandled_input(event: InputEvent) -> void:
	if owner.player_data.rotation_controls:
		if event.is_action_pressed("rotate_cam_left"):
			var tween: Tween = get_tree().create_tween()
			tween.connect("finished", _on_tween_finished)
			tween.tween_property(self, "rotation", rotation + Vector3(0, deg_to_rad(-45), 0), 0.3)
			owner.player_data.rotation_controls = false

		elif event.is_action_pressed("rotate_cam_right"):
			var tween: Tween = get_tree().create_tween()
			tween.connect("finished", _on_tween_finished)
			tween.tween_property(self, "rotation", rotation + Vector3(0, deg_to_rad(45), 0), 0.3)
			owner.player_data.rotation_controls = false

func _on_tween_finished() -> void:
	owner.player_data.rotation_controls = true
