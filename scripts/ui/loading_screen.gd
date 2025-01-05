extends Control

@onready var progress_label = $ProgressLabel
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.game_controller.connect("load_progress",_on_scene_load_update)

func _on_scene_load_update(percent: String) -> void:
	progress_label.text = percent
