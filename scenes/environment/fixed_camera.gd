# extends Camera3D

# @onready var area_3d: Area3D = $Area3D
# @onready var audio_listener: AudioListener3D = $AudioListener3D

# func _ready() -> void:
# 	area_3d.body_entered.connect(_on_body_entered)
# 	area_3d.body_exited.connect(_on_body_exited)
# 	area_3d.monitorable = false

# func _on_body_entered(body: Node3D) -> void:
# 	if body is Player:
# 		Global.previous_active_camera = get_viewport().get_camera_3d()
# 		self.current = true
# 		audio_listener.current = true


# func _on_body_exited(body: Node3D) -> void:
# 	if body is Player:
# 		Global.previous_active_camera.current = true
# 		audio_listener.current = false

extends Camera3D

@onready var area_3d: Area3D = $Area3D
@onready var audio_listener: AudioListener3D = $AudioListener3D

# Use a static variable to track the stack of active cameras
static var camera_stack: Array = []

func _ready() -> void:
    area_3d.body_entered.connect(_on_body_entered)
    area_3d.body_exited.connect(_on_body_exited)
    area_3d.monitorable = false

func _on_body_entered(body: Node3D) -> void:
    if body is Player:
        # Push this camera onto the stack and make it current
        camera_stack.append(self)
        _set_camera_current(self)

func _on_body_exited(body: Node3D) -> void:
    if body is Player:
        # Remove this camera from the stack
        camera_stack.erase(self)
        # Set the last camera in the stack as current, if any
        if camera_stack.size() > 0:
            _set_camera_current(camera_stack[-1])
        # else:
        #     self.current = false
        #     audio_listener.current = false

func _set_camera_current(cam: Camera3D) -> void:
    # Deactivate all cameras in the stack except the current one
    for c: Camera3D in camera_stack:
        if c != cam:
            c.current = false
            c.audio_listener.current = false
    cam.current = true
    cam.audio_listener.current = true
