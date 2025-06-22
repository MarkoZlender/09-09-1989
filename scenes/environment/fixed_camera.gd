extends Camera3D

@onready var area_3d: Area3D = $Area3D
@onready var audio_listener: AudioListener3D = $AudioListener3D

func _ready() -> void:
	area_3d.body_entered.connect(_on_body_entered)
	area_3d.body_exited.connect(_on_body_exited)
	area_3d.monitorable = false

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		self.current = true
		audio_listener.current = true

func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		#self.current = false
		audio_listener.current = false
