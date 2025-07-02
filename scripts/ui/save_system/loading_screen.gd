extends Control

@onready var progress_label: Label = $ProgressLabel
@onready var progress_bar: ProgressBar = %ProgressBar
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.game_controller.connect("load_progress",_on_scene_load_update)

func _on_scene_load_update(percent: float) -> void:
	progress_label.text = str(int(percent)) + " %"
	progress_bar.value = percent
