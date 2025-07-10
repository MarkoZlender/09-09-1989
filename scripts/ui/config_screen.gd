extends Control

@onready var master_slider: HSlider = %MasterSlider
@onready var bgm_slider: HSlider = %BgmSlider
@onready var sfx_slider: HSlider = %SfxSlider

func _ready() -> void:
	Global.save_manager.load_audio_config()
	master_slider.value_changed.connect(_on_master_slider_value_changed)
	bgm_slider.value_changed.connect(_on_bgm_slider_value_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_value_changed)

	master_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	bgm_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("BGM")))
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))

func _on_master_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

func _on_bgm_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BGM"), linear_to_db(value))

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))

func _on_back_button_pressed() -> void:
	Global.save_manager.save_audio_config()
	Global.game_controller.change_gui_scene(Global.MAIN_MENU_SCENE)
