extends Node3D

@export_file("*.tscn") var next_scene: String = ""
@export var next_position_marker: PackedScene

@onready var interact_component: InteractComponent = $InteractComponent
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

func _ready() -> void:
	interact_component.interact = Callable(self, "_on_interact")

func _on_interact() -> void:
	if next_scene != "":
		audio_player.play()
		Global.save_manager.save_game(Global.save_manager.current_save_slot)
		Global.game_controller.next_position_marker = next_position_marker.resource_path
		Global.game_controller.change_3d_scene(next_scene)
		Global.signal_bus.level_changed.emit()
	else:
		printerr("No next scene set for door")
