extends Control

@onready var slot_selection_scene: String = "res://scenes/ui/save_system/slot_selection.tscn"
@onready var main_menu_bgm: String = "res://assets/sounds/sfx/main_menu/crt_tv.wav"
@onready var _start_button: Button = %StartButton

func _ready() -> void:
	_start_button.call_deferred("grab_focus")
	Global.audio_player.stream = load(main_menu_bgm)
	Global.audio_player.play()

func _on_new_game_button_pressed() -> void:
	print("New Game button pressed")
	Global.audio_player.stop()
	Global.game_controller.call_deferred("change_3d_scene", Global.STARTING_LEVEL)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
