extends Node3D

@export var debug: bool = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	Global.signal_bus.play_news.connect(_on_play_news)
	animation_player.animation_finished.connect(_on_animation_finished)

func _on_play_news() -> void:
	if debug:
		Global.game_controller.change_gui_scene(Global.ENDING_SCENE)
		Global.game_controller.change_3d_scene("")
	else:
		animation_player.play("news")

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "news":
		Global.game_controller.change_gui_scene(Global.ENDING_SCENE)
		Global.game_controller.change_3d_scene("")
