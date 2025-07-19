extends Camera3D

@onready var area_3d: Area3D = $Area3D
@onready var audio_listener: AudioListener3D = $AudioListener3D

# active camera stack
static var camera_stack: Array = []

func _ready() -> void:
    area_3d.body_entered.connect(_on_body_entered)
    area_3d.body_exited.connect(_on_body_exited)
    area_3d.monitorable = false

func _on_body_entered(body: Node3D) -> void:
    if body is Player:
        # add current camera to stack and make it current
        camera_stack.append(self)
        _set_camera_current(self)

func _on_body_exited(body: Node3D) -> void:
    if body is Player:
        camera_stack.erase(self)
        # set last camera in array as current
        if camera_stack.size() > 0:
            _set_camera_current(camera_stack[-1])

func _set_camera_current(cam: Camera3D) -> void:
    # set all other cameras in the stack as inactive
    for c: Camera3D in camera_stack:
        if c != cam:
            c.current = false
            c.audio_listener.current = false
    cam.current = true
    cam.audio_listener.current = true
