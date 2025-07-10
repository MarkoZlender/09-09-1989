extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	NPCGameState.teeth_counter = 9
	Global.signal_bus.play_news.connect(_on_play_news)
	animation_player.animation_finished.connect(_on_animation_finished)

func _on_play_news() -> void:
	animation_player.play("news")

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "news":
		Global.game_controller.change_gui_scene(Global.ENDING_SCENE)
		Global.game_controller.change_3d_scene("")
