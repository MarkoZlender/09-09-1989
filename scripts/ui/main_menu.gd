extends Control

@onready var slot_selection_scene: String = "res://scenes/ui/save_system/slot_selection.tscn"
@onready var main_menu_bgm: String = "res://assets/sounds/bgm/title_theme.wav"
@onready var _start_button: Button = %StartButton

func _ready() -> void:
	_start_button.grab_focus()
	Global.audio_player.stream = load(main_menu_bgm)
	Global.audio_player.play()

func _on_new_game_button_pressed() -> void:
	Global.game_controller.change_gui_scene(slot_selection_scene)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
